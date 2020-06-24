#!/bin/bash

# MICOM DIAGNOSTICS package: zonal_mean_woa13.sh (not used in the diagnostics)
# PURPOSE: computes the zonal mean of different basins of WOA13 data
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017                                                                                                                                                                                     

echo " "
echo "-----------------------"
echo "zonal_mean_woa13.sh"
echo "-----------------------"

CDO=`which cdo`
# Zonal mean variables
var=s
datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/obs_data/WOA13/1deg
infile=$datadir/woa13_decav_${var}00_01.nc

for region in glb pac atl ind so
do
    maskfile=/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/grid_files/region_mask_woa13_1x1_${region}.nc
    outfile=$datadir/woa13_decav_${var}00_01_zm_${region}.nc
    tmpfile=$datadir/woa13_decav_${var}00_tmp.nc

    echo "Taking zonal mean over $region"
    $CDO ifthen $maskfile $infile $tmpfile
    if [ $? -ne 0 ]; then
	echo "ERROR in masking out $region: $CDO ifthen $maskfile $tmpfile1 $tmpfile2"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $CDO -s zonmean $tmpfile $outfile
    if [ $? -ne 0 ]; then
	echo "ERROR in taking zonal average: $CDO zonavg $tmpfile2 $outfile"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    else
	rm -r $tmpfile
    fi
done
