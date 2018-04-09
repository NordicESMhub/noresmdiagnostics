#!/bin/bash

# HAMOCC DIAGNOSTICS package: regional_mean.sh
# PURPOSE: computes the regional mean of different basins using CDO
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018 

# Input arguments:
#  $casename    experiment name
#  $fyr_prnt    first_yr of climo (four digits)
#  $lyr_prnt    last_yr of climo (four digits)
#  $climodir    climo directory

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4

echo " "
echo "-----------------------"
echo "regional_mean.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " "

# check if variables are present
infile=$climodir/${casename}_MON_${fyr_prnt}-${lyr_prnt}_climo_remap.nc

for region in ARC NATL NPAC TATL TPAC IND MSO HSO
do
    maskfile=$DIAG_GRID/region_mask_1x1_${region}.nc
    outfile=$climodir/${casename}_MON_${fyr_prnt}-${lyr_prnt}_climo_remap_${region}.nc
    tmpfile=$climodir/${casename}_${region}_tmp.nc

    echo "Regional mean over $region"
    $CDO -s ifthen $maskfile $infile $tmpfile
    if [ $? -ne 0 ]; then
	echo "ERROR in masking out $region: $CDO ifthen $maskfile $infile $tmpfile"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $CDO -s fldmean $tmpfile $outfile
    if [ $? -ne 0 ]; then
	echo "ERROR in taking zonal average: $CDO fldmean $tmpfile $outfile"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    rm -f $tmpfile
done
