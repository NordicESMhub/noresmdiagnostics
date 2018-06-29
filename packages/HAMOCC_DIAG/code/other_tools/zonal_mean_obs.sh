#!/bin/bash

# HAMOCC DIAGNOSTICS package: zonal_mean_obs.sh (not used in the diagnostics)
# PURPOSE: computes the zonal mean of different basins of 1x1 obs data
# Johan Liakka, NERSC
# Last update Dec 2017
# Yanchun He, NERSC
# Last update June 2018

echo " "
echo "-----------------------"
echo "zonal_mean_obs.sh"
echo "-----------------------"

CDO=`which cdo`
# Zonal mean variables
#var=i
#datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/GLODAPv2
datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/EideM-etal_2017
#infile=$datadir/woa13_all_${var}00_01.nc
#infile=$datadir/GLODAPv2.2016b.TAlk_reordered.nc
infile=$datadir/C13_Climatology.nc

for region in glb pac atl ind so
do
    maskfile=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files/1x1d/generic/region_mask_1x1_${region}.nc
#    outfile=$datadir/woa13_all_${var}00_01_zm_${region}.nc
    #outfile=$datadir/GLODAPv2.2016b.TAlk_reordered_zm_${region}.nc
    outfile=$datadir/C13_Climatology_zm_${region}.nc
#    tmpfile=$datadir/woa13_all_${var}00_tmp.nc
    #tmpfile=$datadir/GLODAPv2.2016b.TAlk_reordered_tmp.nc
    tmpfile=$datadir/C13_Climatology_tmp.nc

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
