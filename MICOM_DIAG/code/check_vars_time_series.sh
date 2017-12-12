#!/bin/bash
#
# MICOM DIAGNOSTICS package: check_vars_time_series.sh
# PURPOSE: checks if time series variables are present in history files.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last updated: Dec 2017

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the time series (four digits)
#  $pathdat   directory where the history files are located
#  $tsmode    ann or mon

filetype=$1
casename=$2
first_yr=$3
pathdat=$4
tsmode=$5

echo " "
echo "-----------------------------"
echo "check_vars_time_series.sh"
echo "-----------------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " pathdat  = $pathdat"
echo " tsmode   = $tsmode"
echo " "

if [ -f $WKDIR/attributes/vars_remaining ]; then
    rm -f $WKDIR/attributes/vars_remaining
fi

# Check which variables are present
req_varsc=`cat $WKDIR/attributes/required_vars`
echo "Searching for $filetype variables: $req_varsc"
req_vars=`cat $WKDIR/attributes/required_vars | sed 's/,/ /g'`
first_find=1
first_find_remaining=1
find_any=0
remaining_any=0
var_list=" "
var_list_remaining=" "
if [ $filetype == hy ]; then
    fullpath_filename=$pathdat/${casename}.micom.hy.${first_yr}.nc
else
    fullpath_filename=$pathdat/${casename}.micom.hm.${first_yr}-01.nc
fi

for var in $req_vars
do
    $NCKS --quiet -d y,0 -d x,0 -d sigma,0 -d depth,0 -d region,0 -d slenmax,0 -d section,0 -d lat,0 -v $var $fullpath_filename  >/dev/null 2>&1
    if [ $? -eq 0 ]; then
	find_any=1
	if [ $first_find -eq 1 ]; then
            var_list=$var
            first_find=0
	else
            var_list=${var_list},$var
	fi
    else
	remaining_any=1
	if [ $first_find_remaining -eq 1 ]; then
            var_list_remaining=$var
            first_find_remaining=0
	else
            var_list_remaining=${var_list_remaining},$var
	fi
    fi
done
echo "Variables in history files: $var_list"
if [ $find_any -eq 1 ]; then
    echo ${var_list} > $WKDIR/attributes/vars_${casename}_ts_${tsmode}_${filetype}
fi
echo "Variables remaining: $var_list_remaining"
if [ $remaining_any -eq 1 ]; then
    echo ${var_list_remaining} > $WKDIR/attributes/vars_remaining
fi


