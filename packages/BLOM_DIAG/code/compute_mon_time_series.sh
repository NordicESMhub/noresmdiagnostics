#!/bin/bash

script_start=`date +%s`
#
# BLOM DIAGNOSTICS package: compute_mon_time_series.sh
# PURPOSE: computes ENSO time series from monthly or daily history files
# along with a regional climatology.

# Johan Liakka, NERSC; Dec 2017
# Yanchun He, NERSC; Jun 2020

# Input arguments:
#  $filetype   hm or hy
#  $casename   name of experiment
#  $first_yr   first year of the average
#  $last_yr    last year of the average
#  $pathdat    directory where the history files are located
#  $tsdir      directory where the climatology files are located
#  $ENSOidx    3 or 34

filetype=$1
casename=$2
first_yr=$3
last_yr=$4
pathdat=$5
tsdir=$6
ENSOidx=$7

echo " "
echo "---------------------------"
echo "compute_mon_time_series.sh"
echo "---------------------------"
echo "Input arguments:"
echo " filetype  = $filetype"
echo " casename  = $casename"
echo " first_yr  = $first_yr"
echo " last_yr   = $last_yr"
echo " pathdat   = $pathdat"
echo " tsdir     = $tsdir"
echo " ENSOidx   = $ENSOidx"
echo " "

first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`

# Determine file tag
for ocn in blom micom
do
    ls $pathdat/${casename}.${ocn}.*.${first_yr_prnt}*.nc >/dev/null 2>&1
    [ $? -eq 0 ] && filetag=$ocn && break
done
[ -z $filetag ] && echo "** NO ocean data found, EXIT ... **" && exit 1

if [ -z $PGRIDPATH ]; then
    mask_file=$DIAG_GRID/`cat $WKDIR/attributes/grid_${casename}`/mask_nino${ENSOidx}.nc
else
    mask_file=$PGRIDPATH/mask_nino${ENSOidx}.nc
fi
if [ ! -f $mask_file ]; then
    echo "ERROR: nino${ENSOidx} mask file $mask_file doesn't exist."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
mon_ts_file=${casename}_MON_${first_yr_prnt}-${last_yr_prnt}_sst${ENSOidx}_ts.nc

YR=$first_yr
while [ $YR -le $last_yr ]
do
    yr_prnt=`printf "%04d" ${YR}`
    if [ $filetype == hm ]; then
        # Extract sst from monthly history files
        pid=()
        for month in 01 02 03 04 05 06 07 08 09 10 11 12
        do
            infile=${casename}.$filetag.hm.${yr_prnt}-${month}.nc
            tmpfile=${casename}_${yr_prnt}-${month}.nc
            eval $NCKS --no_tmp_fl -O -v sst $pathdat/$infile $WKDIR/$tmpfile &
            pid+=($!)
        done
        for ((m=0;m<=11;m++))
        do
            wait ${pid[$m]}
            if [ $? -ne 0 ]; then
                echo "ERROR in extracting variables from monthly history files: $NCKS --no_tmp_fl -O -v sst $pathdat/$infile $WKDIR/$tmpfile"
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
        done
        wait
    fi
    if [ $filetype == hd ]; then
        # Calculate monthly means from daily means
        pid=()
        for month in 01 02 03 04 05 06 07 08 09 10 11 12
        do
            infile=${casename}.$filetag.hd.${yr_prnt}-${month}.nc
            tmpfile=${casename}_${yr_prnt}-${month}.nc
            eval $NCRA --no_tmp_fl -O -F -d time,1,,1 -v sst $pathdat/$infile $WKDIR/$tmpfile &
            pid+=($!)
        done
        for ((m=0;m<=11;m++))
        do
            wait ${pid[$m]}
            if [ $? -ne 0 ]; then
                echo "ERROR in calculating monthly means from daily history files: $NCRA --no_tmp_fl -O -F -d time,1,,1 -v sst $pathdat/$infile $WKDIR/$tmpfile"
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
        done
        wait
    fi
    # Append the spatial mask
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        tmpfile=${casename}_${yr_prnt}-${month}.nc
        $NCKS --no_tmp_fl -A -v mask${ENSOidx} -o $WKDIR/$tmpfile $mask_file
        if [ $? -ne 0 ]; then
            echo "ERROR in appending nino_mask: $NCKS -A -v mask${ENSOidx} -o $WKDIR/$tmpfile $mask_file"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    done
    # Compute the average SSTs for the index region
    let "YRM = $YR - 1"
    let "residual = $YRM % 10"
    if [ $residual -eq 0 ]; then
        let "YRP = $YRM + 10"
        if [ $YRP -gt $last_yr ]; then
           YRP=$last_yr
        fi
        echo "Monthly time series of nino$ENSOidx sst (yrs=${YR}-${YRP})"
    fi
    pid=()
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
        do
            infile=${casename}_${yr_prnt}-${month}.nc
            outfile=${casename}_${yr_prnt}-${month}_ave.nc
            eval $NCWA --no_tmp_fl -O -v sst -w mask${ENSOidx} -a x,y $WKDIR/$infile $WKDIR/$outfile &
            pid+=($!)
        done
    for ((m=0;m<=11;m++))
    do
        wait ${pid[$m]}
        if [ $? -ne 0 ]; then
            echo "ERROR in calculating nino${ENSOidx}: $NCWA --no_tmp_fl -O -v sst -w mask${ENSOidx} -a x,y $WKDIR/$infile $WKDIR/$outfile"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    done
    wait
    # Merge monthly files
    outfile=${casename}_${yr_prnt}.nc
    $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_${yr_prnt}-??_ave.nc $WKDIR/$outfile
    if [ $? -ne 0 ]; then
        echo "ERROR in merging monthly files: $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_${yr_prnt}-??_ave.nc $WKDIR/$outfile"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
    # Cleaning up
    rm $WKDIR/${casename}_${yr_prnt}-*.nc
    if [ $? -ne 0 ]; then
        echo "ERROR: rm $WKDIR/${casename}_MON_${yr_prnt}-*.nc"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
    let YR++
done
# Merge all annual files
echo "Merging all nino${ENSOidx} annual files"
$NCRCAT --no_tmp_fl -O $WKDIR/${casename}_????.nc $tsdir/$mon_ts_file
if [ $? -ne 0 ]; then
    echo "ERROR in merging annual files: $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_????.nc $tsdir/$mon_ts_file"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
# Change attribute
$NCATTED -O -a long_name,sst,o,c,"SST in Nino${ENSOidx} region" $tsdir/$mon_ts_file
if [ $? -ne 0 ]; then
    echo "ERROR in changing long_name attributed: $NCATTED -O -a long_name,sst,o,c,Average SST in Nino${ENSOidx} region $tsdir/$mon_ts_file"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
# Remane the sst variable
$NCRENAME -v sst,sst$ENSOidx $tsdir/$mon_ts_file
if [ $? -ne 0 ]; then
    echo "ERROR in renaming: $NCRENAME -v sst,sst$ENSOidx $tsdir/$mon_ts_file"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
# Delete all annual files
rm -f $WKDIR/${casename}_*.nc
if [ $? -ne 0 ]; then
    echo "ERROR in deleting: $WKDIR/${casename}_*.nc"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "MONTHLY TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
