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

## prepare SST,SSS,MLD climatologies
#datadir_micom=/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/obs_data/WOA13/1deg
#datadir_hamocc=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#cd $datadir_micom

## salinity
#cdo -O mergetime `seq -f woa13_decav_s%02g_01.nc 1 12` woa13_decav_sMON_01.nc
#ncks -O -v s_an -d depth,0 woa13_decav_sMON_01.nc woa13_decav_sMON_01.nc

## temperature
#cdo -O mergetime `seq -f woa13_decav_t%02g_01.nc 1 12` woa13_decav_tMON_01.nc
#ncks -O -v t_an -d depth,0 woa13_decav_tMON_01.nc woa13_decav_tMON_01.nc
#mv woa13_decav_sMON_01.nc woa13_decav_tMON_01.nc $datadir_hamocc

#datadir_micom=/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/obs_data/MLD
#datadir_hamocc=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/MLD
#mkdir -p $datadir_hamocc
#cp $datadir_micom/mld_clim_WOCE.nc $datadir_hamocc/
#cdo remapbil,global_1 mld_clim_WOCE.nc mld_clim_WOCE_1x1.nc

# regional mean variables
#datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#infile=$datadir/woa13_all_nMON_01

#datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#infile=$datadir/woa13_decav_sMON_01

#datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#infile=$datadir/woa13_decav_tMON_01

datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/MLD
infile=$datadir/mld_clim_WOCE_1x1

for region in ARC NATL NPAC TATL TPAC IND MSO HSO
do
    maskfile=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files/1x1d/generic/region_mask_1x1_${region}
    #maskfile=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files/2x2d/region_mask4mld_2x2_${region}
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
