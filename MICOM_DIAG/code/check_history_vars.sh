#!/bin/bash
#
# MICOM DIAGNOSTICS package: check_history_vars.sh
# PURPOSE: checks if the history files exist, and which variables are present.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last updated: Dec 2017

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $mode      climo, ts_ann or ts_mon

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
filetypes="hy hm hd"
if [ $mode == ts_mon ]; then
    filetypes="hm hd"
fi
for filetype in $filetypes
do
    check_vars=1
    # Check if all history files are present
    if [ $filetype == hy ]; then
	echo "Searching for hy history files between yrs ${first_yr} and ${last_yr}..."
	let "iyr = $first_yr"
	while [ $iyr -le $last_yr ]
	do
	    fullpath_filename=$pathdat/$casename.micom.$filetype.`printf "%04d" ${iyr}`.nc
	    if [ ! -f $fullpath_filename ]; then
		echo "$fullpath_filename does not exist."
		check_vars=0
		break
	    fi
	    let iyr++
	done
    else
	echo "Searching for $filetype history files between yrs ${first_yr} and ${last_yr}..."
	let "iyr = $first_yr"
	while [ $iyr -le $last_yr ]
	do
	    fullpath_filename=$pathdat/$casename.micom.$filetype.`printf "%04d" ${iyr}`-01.nc
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
	req_vars=`cat $WKDIR/attributes/required_vars | sed 's/,/ /g'`
	first_find=1
	find_any=0
	remaining_any=0
	first_find_remaining=1
	var_list=" "
	var_list_remaining=" "
	for var in $req_vars
	do
	    $NCKS --quiet -d y,0 -d x,0 -d sigma,0 -d depth,0 -v $var $fullpath_filename >/dev/null 2>&1
	    if [ $? -eq 0 ]; then
		find_any=1
		# Save info about sst history file for later (used to determine grid version)
		if [ $var == sst ] && [ ! -f $WKDIR/attributes/sst_file_${casename} ]; then
		    echo $fullpath_filename > $WKDIR/attributes/sst_file_${casename}
		fi
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
	if [ $remaining_any -eq 1 ] && [ $filetype == hy ]; then
	    echo ${var_list_remaining} > $WKDIR/attributes/required_vars
	elif [ $remaining_any -eq 1 ] && [ $filetype == hm ]; then
	    echo ${var_list_remaining} > $WKDIR/attributes/required_vars
	else
	    break
	fi
    fi
done

if [ $mode == climo ]; then
    if [ -f $WKDIR/attributes/vars_climo_${casename}_hy ] && [ -f $WKDIR/attributes/vars_climo_${casename}_hm ]; then
	var_list_hy=`cat $WKDIR/attributes/vars_climo_${casename}_hy`
	var_list_hm=`cat $WKDIR/attributes/vars_climo_${casename}_hm`
	var_list_tot="${var_list_hy},${var_list_hm}"
	echo $var_list_tot > $WKDIR/attributes/vars_climo_${casename}
    elif [ ! -f $WKDIR/attributes/vars_${mode}_${casename}_hy ] && [ -f $WKDIR/attributes/vars_${mode}_${casename}_hm ]; then
	cp $WKDIR/attributes/vars_climo_${casename}_hm $WKDIR/attributes/vars_climo_${casename}
    elif [ -f $WKDIR/attributes/vars_${mode}_${casename}_hy ] && [ ! -f $WKDIR/attributes/vars_${mode}_${casename}_hm ]; then
	cp $WKDIR/attributes/vars_climo_${casename}_hy $WKDIR/attributes/vars_climo_${casename}
    fi
fi

if [ $file_flag -eq 0 ]; then
    echo "ERROR: could not find the required history files for $casename in $pathdat"
    echo "*** EXITING THE SCRIPT (with status 0) ***"
    exit 0
fi

if [ $var_flag -eq 0 ]; then
    echo "ERROR: could not find any required variables (${req_vars}) in $casename history files"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

if [ ! -f $WKDIR/attributes/sst_file_${casename} ]; then
    echo "ERROR: the variable sst was not found in any of the history files (hy, hm and hd)."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
