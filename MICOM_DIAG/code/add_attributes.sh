#!/bin/bash

# MICOM DIAGNOSTICS package: add_attributes.sh
# PURPOSE: Add coordinate attributes to variables if necessary
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $casename  experiment name
#  $ann_file  annual climo file
#  $climodir  climo directory

casename=$1
ann_file=$2
climodir=$3

echo " "
echo "-----------------------"
echo "add_attributes.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " ann_file = $ann_file"
echo " climodir = $climodir"
echo " "

var_list=`cat $WKDIR/attributes/vars_climo_${casename} | sed 's/,/ /g'`

for var in $var_list
do
    $NCKS -O -v $var -d x,0 -d y,0 $climodir/$ann_file $WKDIR/tmp.nc
    $NCKS --quiet -d x,0 -d y,0 -v $var $WKDIR/tmp.nc >/dev/null 2>&1
    if [ $? -eq 0 ]; then
	echo "Adding coordinate attributes to $var"
	$NCATTED -a coordinates,$var,c,c,"plon plat" $climodir/$ann_file
    fi
    rm -f $WKDIR/tmp.nc
done
