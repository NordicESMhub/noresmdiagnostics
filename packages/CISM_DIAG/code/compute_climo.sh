#!/bin/bash

script_start=`date +%s`
#
# CISM DIAGNOSTICS package: compute_climo.sh
# PURPOSE: computes climatology from annual history files
# Heiko Goelzer, NORCE; Jan 2021
# Based on BLOM package

# Input arguments:
#  $filetype  h
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
filetag=cism 

# COMPUTE CLIMATOLOGY FROM ANNUAL FILES
if [ $filetype == h ]; then
    var_list=`cat $WKDIR/attributes/vars_climo_ann_${casename}_h`
    filenames=()
    YR=$first_yr
    while [ $YR -le $last_yr ]
    do
        yr_prnt=`printf "%04d" ${YR}`
        filename=${casename}.$filetag.h.${yr_prnt}-01-01-00000.nc
	echo $filename
        filenames+=($filename)
        let YR++
    done
    echo "Climatological annual mean of $var_list"
    echo ${filenames[*]}
    $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $ann_avg_file
    if [ $? -ne 0 ]; then
        echo "ERROR in computation of climatological annual mean: $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $ann_avg_file"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
fi


script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "CLIMO RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
