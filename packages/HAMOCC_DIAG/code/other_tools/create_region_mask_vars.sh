#!/bin/bash
#set -ex
ulimit -s unlimited
# create 1x1 regional mask files, where observation data are available for each month
# Yanchun He, NERSC
# 2019.06.27

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/MLD
#datafile=mld_clim_WOCE.nc
#mvar=mld
#ovar=mld

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#datafile=woa13_all_iMON_01.nc
#mvar=srfsi
#ovar=i_an

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#datafile=woa13_all_nMON_01.nc
#mvar=srfno3
#ovar=n_an

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#datafile=woa13_all_oMON_01.nc
#mvar=srfo2
#ovar=o_an

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#datafile=woa13_all_pMON_01.nc
#mvar=srfpo4
#ovar=p_an

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#datafile=woa13_decav_tMON_01.nc
#mvar=sst
#ovar=t_an

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/WOA13
#datafile=woa13_decav_sMON_01.nc
#mvar=sss
#ovar=s_an

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/OcnProd_MODIS
#datafile=ave.m.clim_MON_2003-2012.nc
#mvar=ppint
#ovar=pp

#obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/Landschuetzer_2015
#datafile=spco2_ETH_MON_1982-2011.nc
#mvar=pco2
#ovar=spco2

obs_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/Landschuetzer_2015
datafile=spco2_ETH_MON_1982-2011.nc
mvar=co2fxd
ovar=fgco2

cd $obs_dir
if [[ $mvar == "mld" ]]
then
    cdo -s setname,mask -setmisstoc,0 -ifthenc,1 -remapbil,global_1 -sellevidx,1 -selname,$ovar ${datafile} ${mvar}_mask_1x1.nc
elif [[ $mvar == "pp" ]]
then
    cdo -s setname,mask -setmisstoc,0 -ifthenc,1 ${datafile} ${mvar}_mask_1x1.nc
elif [[ $mvar == "pco2" || $mvar == "co2fxn" ]]
then
    cdo -s setname,mask -setmisstoc,0 -ifthenc,1 -selname,$ovar ${datafile} ${mvar}_mask_1x1.nc
else
    # several steps to avoid segment fault error
    cdo -s selname,$ovar ${datafile} tmp.nc
    cdo -s sellevidx,1 tmp.nc tmp2.nc
    cdo -s ifthenc,1 tmp2.nc tmp3.nc
    cdo -s setmisstoc,0 tmp3.nc tmp4.nc
    cdo -s setname,mask tmp4.nc ${mvar}_mask_1x1.nc
    rm -f tmp*.nc
fi
if [ $? -ne 0 ]; then
    echo "ERROR during creating global mask"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi


grid_dir=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files
cd $grid_dir
mkdir -p $grid_dir/1x1d/${mvar}
mv $obs_dir/${mvar}_mask_1x1.nc 1x1d/${mvar}/

for regname in ARC NATL NPAC TATL TPAC IND MSO HSO
do
    cdo -s setmisstoc,0 -ifthenc,1 -mul 1x1d/generic/region_mask_1x1_${regname}.nc 1x1d/${mvar}/${mvar}_mask_1x1.nc 1x1d/${mvar}/region_mask_1x1_${regname}.nc
    if [ $? -ne 0 ]; then
        echo "ERROR during creating regional masks"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
done

echo "SUCESSFULL"
