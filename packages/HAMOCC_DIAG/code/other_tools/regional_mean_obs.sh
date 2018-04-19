#!/bin/bash

# HAMOCC DIAGNOSTICS package: regional_mean_obs.sh (not used in the diagnostics)
# PURPOSE: computes the regional means of different basins of 1x1 obs data
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2017
echo " "
echo "-----------------------"
echo "regional_mean_woa13.sh"
echo "-----------------------"

CDO=`which cdo`
# Zonal mean variables
datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
infile=$datadir/ave.m.clim_MON_2003-2012

for region in ARC NATL NPAC TATL TPAC IND MSO HSO
do
    maskfile=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files/region_mask_1x1_${region}
    outfile=${infile}_${region}
    tmpfile=${infile}_tmp

    echo "Taking regional mean over $region"
    $CDO ifthen ${maskfile}.nc ${infile}.nc ${tmpfile}.nc
    if [ $? -ne 0 ]; then
	echo "ERROR in masking out $region: $CDO ifthen ${maskfile}.nc ${infile}.nc ${tmpfile}.nc"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $CDO -s fldmean ${tmpfile}.nc ${outfile}.nc
    if [ $? -ne 0 ]; then
	echo "ERROR in taking zonal average: $CDO zonavg ${tmpfile}.nc ${outfile}.nc"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    else
	rm -f ${tmpfile}.nc
    fi
done
