#!/bin/bash

# HAMOCC DIAGNOSTICS package: clean_climo.sh
# PURPOSE: deletes files from the climo directory that are not needed
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename    experiment name
#  $first_yr    first_yr of climo (four digits)
#  $last_yr     last_yr of climo (four digits)
#  $climodir    climo directory

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4

echo " "
echo "-----------------------"
echo "clean_climo.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " "

for mon in 01 02 03 04 05 06 07 08 09 10 11 12
do
    filename=$climodir/${casename}_${mon}_${fyr_prnt}-${lyr_prnt}_climo.nc
    if [ -f $filename ]; then
        rm $filename
    fi
    filename=$climodir/${casename}_${mon}_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
    if [ -f $filename ]; then
        rm $filename
    fi
done
