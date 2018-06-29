#!/bin/bash

#Yanchun He, yanchun.he@nersc.no
#2018.06.07
gpath=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files
cd $gpath
for gtype in gx1v5 gx1v6 gx3v7 tnx0.083v1 tnx0.25v1 tnx0.25v3 tnx0.25v4 tnx1.5v1 tnx1v1 tnx1v1_lgm tnx1v1_mis3 tnx1v1_PlioMIP2 tnx1v2 tnx1v3 tnx1v4 tnx2v1
do
    echo $gtype
    cdo -f nc4 random,${gtype}/grid.nc random.nc
    ncatted -a coordinates,random,o,c,"plon plat" random.nc
    ncatted -a cell_measures,random,o,c,"area: parea" random.nc
    ncks -A -v plat,plon,parea ${gtype}/grid.nc random.nc
    cdo genbil,global_1 random.nc map_${gtype}_to_1x1_bilin.nc
    ncatted  --history -a  history,global,a,c,"\nCreated by Yanchun He, yanchun.he@nersc.no, `date`" map_${gtype}_to_1x1_bilin.nc
    mv map_${gtype}_to_1x1_bilin.nc ${gtype}/
    rm -f random.nc
done 

