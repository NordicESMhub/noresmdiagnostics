#!/bin/bash
#
# HAMMOC DIAGNOSTICS package: check_history_vars.sh
# PURPOSE: checks if the history files exist, and which variables are present.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last updated: Jan 2018

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
filetypes="hbgcy hbgcm"

# Look for co2fxd (used to determine grid type and version)
if [ ! -f $WKDIR/attributes/co2fxd_file_${casename} ]; then
    for filetype in $filetypes
    do
	if [ $filetype == hbgcy ]; then
	    fullpath_filename=$pathdat/$casename.micom.$filetype.`printf "%04d" ${first_yr}`.nc
	else
	    fullpath_filename=$pathdat/$casename.micom.$filetype.`printf "%04d" ${first_yr}`-01.nc
	fi
	$NCKS --quiet -d y,0 -d x,0 -v co2fxd $fullpath_filename >/dev/null 2>&1
	if [ $? -eq 0 ]; then
	    echo $fullpath_filename > $WKDIR/attributes/co2fxd_file_${casename}
	fi
    done
fi

if [ ! -f $WKDIR/attributes/co2fxd_file_${casename} ]; then
    echo "ERROR: the variable co2fxd was not found in any of the history files (hbgcy and hbgcm)."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

for filetype in $filetypes
do
    check_vars=1
    # Check if all history files are present
    if [ $filetype == hbgcy ]; then
	echo "Searching for $filetype history files between yrs ${first_yr} and ${last_yr}..."
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
	if [ $remaining_any -eq 1 ] && [ $filetype == hbgcy ]; then
	    echo ${var_list_remaining} > $WKDIR/attributes/required_vars
	else
	    break
	fi
    fi
done

if [ $mode == climo ]; then
    if [ -f $WKDIR/attributes/vars_climo_${casename}_hbgcy ] && [ -f $WKDIR/attributes/vars_climo_${casename}_hbgcm ]; then
	var_list_hy=`cat $WKDIR/attributes/vars_climo_${casename}_hbgcy`
	var_list_hm=`cat $WKDIR/attributes/vars_climo_${casename}_hbgcm`
	var_list_tot="${var_list_hy},${var_list_hm}"
	echo $var_list_tot > $WKDIR/attributes/vars_climo_${casename}
    elif [ ! -f $WKDIR/attributes/vars_${mode}_${casename}_hbgcy ] && [ -f $WKDIR/attributes/vars_${mode}_${casename}_hbgcm ]; then
	cp $WKDIR/attributes/vars_climo_${casename}_hbgcm $WKDIR/attributes/vars_climo_${casename}
    elif [ -f $WKDIR/attributes/vars_${mode}_${casename}_hbgcy ] && [ ! -f $WKDIR/attributes/vars_${mode}_${casename}_hbgcm ]; then
	cp $WKDIR/attributes/vars_climo_${casename}_hbgcy $WKDIR/attributes/vars_climo_${casename}
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

