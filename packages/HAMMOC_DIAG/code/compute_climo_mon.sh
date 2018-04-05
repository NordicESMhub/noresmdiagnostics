#!/bin/bash

script_start=`date +%s`
#
# HAMMOC DIAGNOSTICS package: compute_climo_mon.sh
# PURPOSE: computes climatology from annual or monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $climodir  directory where the climatology files are located

casename=$1
first_yr=$2
last_yr=$3
pathdat=$4
climodir=$5

echo " "
echo "-----------------------"
echo "compute_climo_mon.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " climodir = $climodir"
echo " "

var_list=`cat $WKDIR/attributes/vars_climo_mon_${casename}_hbgcm`
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
mon_avg_file=${climodir}/${casename}_MON_${first_yr_prnt}-${last_yr_prnt}_climo.nc

pid=()
mon_avg_files=()
for month in 01 02 03 04 05 06 07 08 09 10 11 12
do
    echo "Climatological monthly mean of $var_list for month=${month}"
    filenames=()
    YR=$first_yr
    while [ $YR -le $last_yr ]
    do
	yr_prnt=`printf "%04d" ${YR}`
        filename=${casename}.micom.hbgcm.${yr_prnt}-${month}.nc
        if [ -f $pathdat/$filename ]; then
	    filenames+=($filename)
        else
	    echo "ERROR: $pathdat/$filename does not exist."
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
        let YR++
    done
    mon_avg_file=${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
    mon_avg_files+=($mon_avg_file)
    eval $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $climodir/$mon_avg_file &
    pid+=($!)
done
for ((m=0;m<=11;m++))
do
    wait ${pid[$m]}
    if [ $? -ne 0 ]; then
        echo "ERROR in computation of climatological monthly mean: $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $mon_avg_file"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
done
wait

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "CLIMO RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
