#!/bin/bash

# HAMOCC DIAGNOSTICS package: merge_monClim.sh
# PURPOSE: Merge monthly climatology files to one file
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  name of experiment
#  $fyr_prnt  first yr of climatology (4 digits)
#  $lyr_prnt  last yr of climatology (4 digits)
#  $climodir  climatology directory

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4

echo " "
echo "-----------------------"
echo "merge_monClim.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " "

testfile=$climodir/${casename}_01_${fyr_prnt}-${lyr_prnt}_climo.nc
if [ ! -f $testfile ]; then
    echo "ERROR in merging: $testfile does not exist"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

testfile=$climodir/${casename}_01_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
if [ ! -f $testfile ]; then
    echo "ERROR in merging: $testfile does not exist"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

echo "Merging monthly climo files (default)"
outfile=$climodir/${casename}_MON_${fyr_prnt}-${lyr_prnt}_climo.nc
$NCRCAT --no_tmp_fl -O $climodir/${casename}_??_${fyr_prnt}-${lyr_prnt}_climo.nc $outfile
echo "Merging monthly climo files (remap)"
outfile=$climodir/${casename}_MON_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
$NCRCAT --no_tmp_fl -O $climodir/${casename}_??_${fyr_prnt}-${lyr_prnt}_climo_remap.nc $outfile
