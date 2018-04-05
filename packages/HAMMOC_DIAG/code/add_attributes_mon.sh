#!/bin/bash

# HAMMOC DIAGNOSTICS package: add_attributes_mon.sh
# PURPOSE: Add coordinate attributes to variables if necessary
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  experiment name
#  $fyr_prnt  first year of climatology (4 digits)
#  $lyr_prnt  last year of climatology (4 digits)
#  $climodir  climo directory

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4

echo " "
echo "-----------------------"
echo "add_attributes_mon.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " "

var_list=`cat $WKDIR/attributes/vars_climo_mon_${casename} | sed 's/,/ /g'`

for var in $var_list
do
    echo "Adding coordinate attributes to $var"
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        mon_file=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo.nc
        $NCKS --quiet -d x,0 -d y,0 -v $var $climodir/$mon_file >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            $NCATTED -a coordinates,$var,c,c,"plon plat" $climodir/$mon_file
        fi
    done
done
