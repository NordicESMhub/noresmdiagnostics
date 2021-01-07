#!/bin/bash
#
# CISM DIAGNOSTICS package: check_history_vars.sh
# PURPOSE: checks if the history files exist, and which variables are present.
# Johan Liakka, NERSC; Feb 2018
# Yanchun He, NERSC; Jun 2020
# Heiko Goelzer, NORCE Jan 2021 (heig@horceresearch.no)
# Based on BLOM version

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $mode      climo_ann, climo_mon, ts_ann or ts_mon

casename=$1
first_yr=$2
last_yr=$3
pathdat=$4
mode=$5

echo " "
echo "-----------------------"
echo "check_history_vars.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " mode     = $mode"
echo " "

file_flag=0
var_flag=0
filetypes="h"

# Determine file tag
ls $pathdat/${casename}.cism.*.$(printf "%04d" ${first_yr})*.nc >/dev/null 2>&1
[ $? -eq 0 ] && filetag=cism 

# Look for thk (used to determine grid type and version)
if [ ! -f $WKDIR/attributes/thk_file_${casename} ]; then
    for filetype in $filetypes
    do
        fullpath_filename=$(ls -1 $pathdat/$casename.$filetag.$filetype.$(printf "%04d" ${first_yr})-01-01-00000.nc 2>/dev/null |head -1)

	echo ${fullpath_filename}
        $NCKS --quiet -d y1,0 -d x1,0 -v thk $fullpath_filename >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo $fullpath_filename > $WKDIR/attributes/thk_file_${casename}
        fi
    done
fi

if [ ! -f $WKDIR/attributes/thk_file_${casename} ]; then
    echo "ERROR: the variable thk was not found in the history file ."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

for filetype in $filetypes
do
    check_vars=1
    # Check if all history files are present
    if [ $filetype == h ]; then
        echo "Searching for h history files between yrs ${first_yr} and ${last_yr}..."
        let "iyr = $first_yr"
        while [ $iyr -le $last_yr ]
        do
            fullpath_filename=$(ls -1 $pathdat/$casename.$filetag.$filetype.$(printf "%04d" ${iyr})-01-01-00000.nc 2>/dev/null |head -1)
            if [ ! -f $fullpath_filename ]; then
                echo "$fullpath_filename does not exist."
                check_vars=0
                break
            fi
            let iyr++
        done
    fi
    
    # Check which variables are present
    if [ $check_vars -eq 1 ]; then
        file_flag=1
        echo "FOUND ALL $filetype history files"
        req_varsc=`cat $WKDIR/attributes/required_vars`
        echo "Searching for $filetype variables: $req_varsc"
        req_vars=`echo $req_varsc | sed 's/,/ /g'`
        first_find=1
        find_any=0
        remaining_any=0
        first_find_remaining=1
        var_list=" "
        var_list_remaining=" "
        for var in $req_vars
        do
            $NCKS --quiet -d y1,0 -d x1,0  -v $var $fullpath_filename >/dev/null 2>&1
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
        echo "Variables in $filetype history files: $var_list"
        if [ $find_any -eq 1 ]; then
            var_flag=1
            echo ${var_list} > $WKDIR/attributes/vars_${mode}_${casename}_${filetype}
        fi
        echo "Variables remaining: $var_list_remaining"
        if [ $remaining_any -eq 1 ] && [ $filetype == h ]; then
            echo ${var_list_remaining} > $WKDIR/attributes/required_vars
        else
            break
        fi
    fi
done

if [ $mode == climo_ann ]; then
    if [ -f $WKDIR/attributes/vars_${mode}_${casename}_h ] ; then
        var_list_h=`cat $WKDIR/attributes/vars_climo_ann_${casename}_h`
        var_list_tot="${var_list_h}"
    fi
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

