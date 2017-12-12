#!/bin/bash

script_start=`date +%s`
#
# MICOM DIAGNOSTICS package: compute_mon_time_series.sh
# PURPOSE: computes monthly time series from monthly or daily history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $tsdir     directory where the climatology files are located

filetype=$1
casename=$2
first_yr=$3
last_yr=$4
pathdat=$5
tsdir=$6

echo " "
echo "---------------------------"
echo "compute_mon_time_series.sh"
echo "---------------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " tsdir    = $tsdir"
echo " "

var_list=`cat $WKDIR/attributes/vars_ts_mon_${casename}_${filetype}`
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
mon_ts_file=${casename}_MON_${first_yr_prnt}-${last_yr_prnt}_ts_${filetype}.nc
mask_file=$DIAG_GRID/`cat $WKDIR/attributes/grid_${casename}`/mask_nino34.nc
if [ $PALEO -eq 1 ]; then
    mask_file=$PGRIDPATH/mask_nino34.nc
fi
if [ ! -f $mask_file ]; then
    echo "ERROR: nino3.4 mask file $mask_file doesn't exist."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

YR=$first_yr
while [ $YR -le $last_yr ]
do
    yr_prnt=`printf "%04d" ${YR}`
    if [ $filetype == hm ]; then
	# Extract variables from monthly history files
	pid=()
	for month in 01 02 03 04 05 06 07 08 09 10 11 12
	do
	    infile=${casename}.micom.hm.${yr_prnt}-${month}.nc
	    tmpfile=${casename}_${yr_prnt}-${month}.nc
	    eval $NCKS --no_tmp_fl -O -v $var_list $pathdat/$infile $WKDIR/$tmpfile &
	    pid+=($!)
	done
	for ((m=1;m<=$12;m++))
	do
	    wait ${pid[$m]}
	    if [ $? -ne 0 ]; then
		echo "ERROR in extracting variables from monthly history files: $NCKS --no_tmp_fl -O -v $var_list $pathdat/$infile $WKDIR/$tmpfile"
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
	    infile=${casename}.micom.hm.${yr_prnt}-${month}.nc
	    tmpfile=${casename}_${yr_prnt}-${month}.nc
	    eval $NCRA --no_tmp_fl -O -F -d time,1,,1 -v $var_list $pathdat/$infile $WKDIR/$tmpfile &
	    pid+=($!)
	done
	for ((m=1;m<=$12;m++))
	do
	    wait ${pid[$m]}
	    if [ $? -ne 0 ]; then
		echo "ERROR in calculating monthly means from daily history files: $NCRA --no_tmp_fl -O -F -d time,1,,1 -v $var_list $pathdat/$infile $WKDIR/$tmpfile"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	done
	wait
    fi
    # Append the nino3.4 mask
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
	tmpfile=${casename}_${yr_prnt}-${month}.nc
	$NCKS --no_tmp_fl -A -v nino_mask -o $WKDIR/$tmpfile $mask_file
	if [ $? -ne 0 ]; then
	    echo "ERROR in appending nino_mask: $NCKS -A -v nino_mask -o $WKDIR/$tmpfile $mask_file"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
    done
    # Loop over variables
    for var in `echo $var_list | sed 's/,/ /g'`
    do
	outfile=${var}_${casename}_MON_${yr_prnt}.nc
	if [ $var == sst ]; then
	    # Compute the nino3.4 SST index
	    echo "Computing monthly time series of $var (nino3.4) for yr=${yr_prnt}"
	    pid=()
	    for month in 01 02 03 04 05 06 07 08 09 10 11 12
	    do
		tmpfile=${casename}_${yr_prnt}-${month}.nc
		eval $NCWA --no_tmp_fl -O -v $var -w nino_mask -a x,y $WKDIR/$tmpfile $WKDIR/${var}_${casename}_MON_${yr_prnt}-${month}.nc &
		pid+=($!)
	    done
	    for ((m=1;m<=$12;m++))
	    do
		wait ${pid[$m]}
		if [ $? -ne 0 ]; then
		    echo "ERROR in calculating nino3.4: $NCWA --no_tmp_fl -O -v $var -w nino_mask -a x,y $WKDIR/$tmpfile $WKDIR/${var}_${casename}_MON_${yr_prnt}-${month}.nc"
		    echo "*** EXITING THE SCRIPT ***"
		    exit 1
		fi
	    done
	    wait
	    # Merge monthly files
	    $NCRCAT --no_tmp_fl -O $WKDIR/${var}_${casename}_MON_${yr_prnt}-??.nc $WKDIR/$outfile
	    if [ $? -ne 0 ]; then
		echo "ERROR in merging monthly files: $NCRCAT --no_tmp_fl -O $WKDIR/${var}_${casename}_MON_${yr_prnt}-??.nc $WKDIR/$outfile"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	    # Clean up
	    rm $WKDIR/${var}_${casename}_MON_${yr_prnt}-*.nc
	    if [ $? -ne 0 ]; then
		echo "ERROR: rm $WKDIR/${var}_${casename}_MON_${yr_prnt}-*.nc"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	fi
    done
    # Clean up some more
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
	tmpfile=${casename}_${yr_prnt}-${month}.nc
	rm $WKDIR/$tmpfile
	if [ $? -ne 0 ]; then
	    echo "ERROR in removing ${tmpfile}: rm $WKDIR/$tmpfile"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
    done
    let YR++
done
# Merge all annual files
first_var=1
for var in `echo $var_list | sed 's/,/ /g'`
do
    echo "Merging all $var time-series files"
    $NCRCAT --no_tmp_fl -O $WKDIR/${var}_${casename}_MON_????.nc $WKDIR/${var}_${casename}_MON_${first_yr_prnt}-${last_yr_prnt}.nc
    if [ $? -eq 0 ]; then
        if [ $first_var -eq 1 ]; then
	    first_var=0
  	    mv $WKDIR/${var}_${casename}_MON_${first_yr_prnt}-${last_yr_prnt}.nc $tsdir/$mon_ts_file
	    if [ $? -ne 0 ]; then
		echo "ERROR in moving: mv ${var}_${casename}_MON_${first_yr_prnt}-${last_yr_prnt}.nc $tsdir/$mon_ts_file"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	else
	    $NCKS -A -o $tsdir/$mon_ts_file $WKDIR/${var}_${casename}_MON_${first_yr_prnt}-${last_yr_prnt}.nc
	    if [ $? -ne 0 ]; then
		echo "ERROR in appending variables: $NCKS -A -o $tsdir/$mon_ts_file $WKDIR/${var}_${casename}_MON_${first_yr_prnt}-${last_yr_prnt}.nc"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	fi
    fi
    # Delete all annual files
    rm -f $WKDIR/${var}_${casename}_MON_*.nc
    if [ $? -ne 0 ]; then
	echo "ERROR in deleting: rm -f $WKDIR/${var}_${casename}_MON_*.nc"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
done

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "MONTHLY TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
