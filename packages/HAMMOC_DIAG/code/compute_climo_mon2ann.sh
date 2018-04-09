#!/bin/bash

# HAMOCC DIAGNOSTICS package: compute_climo_mon2ann.sh
# PURPOSE: computes annual climatology from monthly climatology files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  experiment name
#  $fyr_prnt  first yr climatology (4 digits)
#  $lyr_prnt  last yr climatology (4 digits)
#  $climodir  climo directory
#  $mode      "default" or "remap"

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4
mode=$5

echo " "
echo "-------------------------"
echo "compute_climo_mon2ann.sh"
echo "-------------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " mode     = $mode"
echo " "

var_list_tot=`cat $WKDIR/attributes/required_vars | sed 's/,/ /g'`
if [ $mode == remap ]; then
    mon_file=$climodir/${casename}_01_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
    ann_file=$climodir/${casename}_ANN_${fyr_prnt}-${lyr_prnt}_climo_remap_mon2ann.nc
else
    mon_file=$climodir/${casename}_01_${fyr_prnt}-${lyr_prnt}_climo.nc
    ann_file=$climodir/${casename}_ANN_${fyr_prnt}-${lyr_prnt}_climo_mon2ann.nc
fi

# Loop over variables
var_list=""
first_find=1
for var in $var_list_tot
do
    if [ $mode == remap ]; then
	$NCKS --quiet -d lon,0 -d lat,0 -v $var $mon_file >/dev/null 2>&1
    else
	$NCKS --quiet -d x,0 -d y,0 -v $var $mon_file >/dev/null 2>&1
    fi
    if [ $? -eq 0 ]; then
	echo "$var exists in monthly climatology"
	# Updating $var_list
	if [ $first_find -eq 1 ]; then
	    var_list=$var
	    first_find=0
	else
	    var_list=${var_list},${var}
	fi
	if grep -q ,$var $WKDIR/attributes/required_vars
	then
            sed -i "s/,${var}//g" $WKDIR/attributes/required_vars
	else
            sed -i "s/${var},//g" $WKDIR/attributes/required_vars
	fi
    fi
done

mon_avg_files=()
for month in 01 02 03 04 05 06 07 08 09 10 11 12
do
    if [ $mode == remap ]; then
	mon_avg_file=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
    else
	mon_avg_file=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo.nc
    fi
    mon_avg_files+=($mon_avg_file)
done
$NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v $var_list -p $climodir ${mon_avg_files[*]} $ann_file
if [ $? -ne 0 ]; then
    echo "ERROR in calculating annual climo from monthly climo: $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v $var_list -p $climodir ${mon_avg_files[*]} $ann_file"
    exit 1
fi
