#!/bin/bash

script_start=`date +%s`
#
# BLOM DIAGNOSTICS package: compute_climo.sh
# PURPOSE: computes climatology from annual or monthly history files

# Detelina Ivanova, NERSC
# Johan Liakka, NERSC; Dec 2017
# Yanchun He, NERSC; Jun 2020

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $climodir  directory where the climatology files are located

filetype=$1
casename=$2
first_yr=$3
last_yr=$4
pathdat=$5
climodir=$6

echo " "
echo "-----------------------"
echo "compute_climo.sh"
echo "-----------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " climodir = $climodir"
echo " "

first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
ann_avg_file=${climodir}/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_climo_${filetype}.nc

# Determine file tag
for ocn in blom micom
do
    ls $pathdat/${casename}.${ocn}.*.${first_yr_prnt}*.nc >/dev/null 2>&1
    [ $? -eq 0 ] && filetag=$ocn && break
done
[ -z $filetag ] && echo "** NO ocean data found, EXIT ... **" && exit 1

# COMPUTE CLIMATOLOGY FROM ANNUAL FILES
if [ $filetype == hy ]; then
    var_list=`cat $WKDIR/attributes/vars_climo_ann_${casename}_hy`
    filenames=()
    YR=$first_yr
    while [ $YR -le $last_yr ]
    do
        yr_prnt=`printf "%04d" ${YR}`
        filename=${casename}.$filetag.hy.${yr_prnt}.nc
        filenames+=($filename)
        let YR++
    done
    if [ "$var_list" == "depth_bnds" ]
    then
        echo "No fields from hy files, skip calculate annual mean from hy files"
    else
        echo "Climatological annual mean of $var_list"
        $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $ann_avg_file
        if [ $? -ne 0 ]; then
            echo "ERROR in computation of climatological annual mean: $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $ann_avg_file"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    fi
fi

# COMPUTE CLIMATOLOGY FROM MONTHLY FILES
if [ $filetype == hm ]; then
    annual_climo=0
    monthly_climo=0
    if [ -f $WKDIR/attributes/vars_climo_ann_${casename}_hm ]; then
        annual_climo=1
        var_list_ann=`cat $WKDIR/attributes/vars_climo_ann_${casename}_hm`
    fi
    if [ -f $WKDIR/attributes/vars_climo_mon_${casename}_hm ]; then
        monthly_climo=1
        var_list_mon=`cat $WKDIR/attributes/vars_climo_mon_${casename}_hm`
    fi
    if [ $annual_climo -eq 1 ] && [ $monthly_climo -eq 1 ]; then
        var_list=`echo ${var_list_ann},${var_list_mon}`
    elif [ $annual_climo -eq 1 ] && [ $monthly_climo -eq 0 ]; then
        var_list=${var_list_ann}
    elif [ $annual_climo -eq 0 ] && [ $monthly_climo -eq 1 ]; then
        var_list=${var_list_mon}
    else
        echo "ERROR: No annual or monthly climo variables present in hm files"
        exit 1
    fi
    if [ ! -f $WKDIR/attributes/grid_${casename} ] && [ -z $PGRIDPATH ]; then
        $DIAG_CODE/determine_grid_type.sh $casename
    fi
    grid_type=$(cat $WKDIR/attributes/grid_${casename} |cut -d'v' -f1)
    pid=()
    mon_tmp_files=()
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        echo "Climatological monthly mean of $var_list for month=${month}"
        filenames=()
        YR=$first_yr
        while [ $YR -le $last_yr ]
        do
            yr_prnt=`printf "%04d" ${YR}`
            filename=${casename}.$filetag.hm.${yr_prnt}-${month}.nc
            if [ -f $pathdat/$filename ]; then
                filenames+=($filename)
            else
                echo "ERROR: $pathdat/$filename does not exist."
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
            let YR++
        done
        mon_tmp_file=${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_tmp.nc
        mon_tmp_files+=($mon_tmp_file)
        eval $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $climodir/$mon_tmp_file &
        if [ $grid_type == "tnx0.125" ]
        then
            wait $!
        else
            pid+=($!)
        fi
    done
    for ((m=0;m<=11;m++))
    do
        wait ${pid[$m]}
        if [ $? -ne 0 ]; then
            echo "ERROR in computation of climatological monthly mean: $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $climodir/$mon_tmp_file"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    done
    wait
    # COMPUTE ANNUAL MEAN
    if [ $annual_climo -eq 1 ]; then
        echo "Climatological weighted annual mean of $var_list_ann"
        $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v $var_list_ann -p $climodir ${mon_tmp_files[*]} $ann_avg_file
        if [ $? -ne 0 ]; then
            echo "ERROR in computation of climatological annual mean: $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v $var_list_ann -p $climodir ${mon_tmp_files[*]} $ann_avg_file"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    fi
    # CREATE MONTHLY CLIMATOLOGY
    if [ $monthly_climo -eq 1 ]; then
        echo "Creating monthly climatology files of ${var_list_mon}..."
        pid=()
        for month in 01 02 03 04 05 06 07 08 09 10 11 12
        do
            mon_tmp_file=$climodir/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_tmp.nc
            mon_avg_file=$climodir/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
            eval $NCKS -O --no_tmp_fl -v $var_list_mon $mon_tmp_file $mon_avg_file &
            pid+=($!)
        done
        for ((m=0;m<=11;m++))
        do
            wait ${pid[$m]}
            if [ $? -ne 0 ]; then
                echo "ERROR in creating monthly climatology: $NCKS -O --no_tmp_fl -v $var_list_mon $mon_tmp_file $mon_avg_file"
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
        done
        wait
    fi
    # DELETE TMP MONTHLY FILES
    echo "Deleting temporary monthly files"
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        rm $climodir/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_tmp.nc
        if [ $? -ne 0 ]; then
            echo "ERROR: could not remove $climodir/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_tmp.nc"
            exit 1
        fi
    done
fi

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "CLIMO RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
