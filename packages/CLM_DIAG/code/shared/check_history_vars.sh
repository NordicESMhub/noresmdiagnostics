#!/bin/bash
#
# CLM DIAGNOSTICS package: check_history_vars.sh
# PURPOSE: checks if the history files exist, and which variables are present.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last updated: Apr 2018

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $model     clm or cam
#  $procdir   work directory
#  $mode      climo or ts

casename=$1
first_yr=$2
last_yr=$3
pathdat=$4
model=$5
procdir=$6
mode=$7

echo " "
echo "-----------------------"
echo "check_history_vars.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " model    = $model"
echo " procdir  = $procdir"
echo " mode     = $mode"
echo " "

NCKS=`which ncks`
if [ $? -ne 0 ]; then
    echo "Could not find ncks (which ncks)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

file_flag=0
var_flag=0
check_vars=1
# Check if all history files are present
echo "Searching for $filetype history files between yrs ${first_yr} and ${last_yr}..."
let "iyr = $first_yr"
while [ $iyr -le $last_yr ]
do
    #fullpath_filename=$pathdat/$casename.${model}.h0.`printf "%04d" ${iyr}`-01.nc
    fullpath_filename=$(ls $pathdat/$casename.${model}.h0.`printf "%04d" ${iyr}`-*.nc |head -1)
    if [ ! -f $fullpath_filename ]; then
	echo "$fullpath_filename does not exist."
	check_vars=0
	break
    fi
    let iyr++
done

# Check which variables are present
if [ $check_vars -eq 1 ]; then
    file_flag=1
    # Check december flag
    let "iyr = $first_yr - 1"
    fullpath_filename=$pathdat/$casename.${model}.h0.`printf "%04d" ${iyr}`-12.nc
    if [ -f $fullpath_filename ] && [ $mode == climo ]; then
	dec_flag=scd
	echo $dec_flag > $procdir/dec_flag
    else
	dec_flag=sdd
	echo $dec_flag > $procdir/dec_flag
    fi
    echo "FOUND ALL $model history files (dec_flag: ${dec_flag})"
    req_varsc=`cat $procdir/required_vars`
    echo "Searching for ${model}.h0 variables: $req_varsc"
    req_vars=`echo $req_varsc | sed 's/,/ /g'`
    first_find=1
    find_any=0
    remaining_any=0
    first_find_remaining=1
    var_list=" "
    var_list_remaining=" "
    fullpath_filename=$pathdat/$casename.${model}.h0.`printf "%04d" ${first_yr}`-01.nc
    var_in_file=$(cdo -s showname $fullpath_filename)
    for var in $req_vars
    do
        #speed up by check only ocean available variables
        echo $var_in_file |grep -w $var >/dev/null
        #if [ $model == clm2 ]; then
            #$NCKS --quiet -d lat,0 -d lon,0 -d levsoi,0 -v $var $fullpath_filename >/dev/null 2>&1
        #else
            #$NCKS --quiet -d lat,0 -d lon,0 -d lev,0 -v $var $fullpath_filename >/dev/null 2>&1
        #fi
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
    echo "Variables in ${model}.h0 history files: $var_list"
    if [ $find_any -eq 1 ]; then
	var_flag=1
	echo ${var_list} > $procdir/vars_${mode}_${model}
    fi
    echo "Variables not found: $var_list_remaining"
fi

if [ $file_flag -eq 0 ]; then
    echo "ERROR: could not find the required history files for $casename in $pathdat"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

if [ $var_flag -eq 0 ]; then
    echo "ERROR: could not find any required variables (${req_vars}) in $casename history files"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

