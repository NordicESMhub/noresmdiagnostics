#!/bin/bash

# HAMOCC DIAGNOSTICS package: determine_grid_type.sh
# PURPOSE: Determine grid type, size and version
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018

# STRATEGY: Unfortunately the micom history files do not include any grid information.
# Therefore, the grid size and type is determined by the total number of grid points of the co2fxd variable,
# and the grid version is determined by the number of missing values from that variable.

# Input arguments:
#  $casename  simulation name

casename=$1

echo " "
echo "-----------------------"
echo "determine_grid_type.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename  = $casename"
echo " "

gp_tn0083=14934240 # (4320x3457) number of gridpoints on tn0.083 grids
gp_tn025=1660320   # (1440x1153) number of gridpoints on tn0.25  grids (multiple choices)
gp_tn1=138600      # (360x385)   number of gridpoints on tn1     grids (multiple choices)
gp_tn15=61680      # (240x257)   number of gridpoints on tn1.5   grids
gp_tn2=34740       # (180x193)   number of gridpoints on tn2     grids
gp_g1=122880       # (320x384)   number of gridpoints on g1      grids (multiple choices)
gp_g3=11600        # (100x116)   number of gridpoints on g3      grids

nmiss_tn025v1=682899
nmiss_tn025v3=681867
nmiss_tn025v4=682843
nmiss_tn1v1=51715
nmiss_tn1v1_lgm=60417
nmiss_tn1v1_mis3=60675
nmiss_tn1v1_plio=52387
nmiss_tn1v2=51775
nmiss_tn1v3=51828
nmiss_tn1v4=51892
nmiss_gv6=36649

fullpath_filename=`cat $WKDIR/attributes/co2fxd_file_${casename}`
$CDO selvar,co2fxd $fullpath_filename $WKDIR/co2fxd_tmp.nc >/dev/null 2>&1
if [ $? -eq 0 ]; then
    gp=`$CDO -s griddes $WKDIR/co2fxd_tmp.nc | grep gridsize | sed -e 's/^[^=]*=//g'`
    if [ $gp -eq $gp_tn0083 ]; then
        grid_type=tnx0.083
        grid_ver=1
    elif [ $gp -eq $gp_tn025 ]; then
        grid_type=tnx0.25
        nmiss=`$CDO -s info $WKDIR/co2fxd_tmp.nc | awk '{print $7}' | tail -n 1`
        if [ $nmiss -eq $nmiss_tn025v1 ]; then
            grid_ver=1
        elif [ $nmiss -eq $nmiss_tn025v3 ]; then
            grid_ver=3
        elif [ $nmiss -eq $nmiss_tn025v4 ]; then
            grid_ver=4
        else
            echo "ERROR: could not determine version of tn0.25 grid:"
            echo "Number of missing values found: $nmiss"
            echo "Should be ${nmiss_tn025v1},${nmiss_tn025v3},${nmiss_tn025v4} in v1,3,4 respectively."
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
   elif [ $gp -eq $gp_tn1 ]; then
        grid_type=tnx1
        nmiss=`$CDO -s info $WKDIR/co2fxd_tmp.nc | awk '{print $7}' | tail -n 1`
        if [ $nmiss -eq $nmiss_tn1v1 ]; then
            grid_ver=1
        elif [ $nmiss -eq $nmiss_tn1v2 ]; then
            grid_ver=2
        elif [ $nmiss -eq $nmiss_tn1v3 ]; then
            grid_ver=3
        elif [ $nmiss -eq $nmiss_tn1v4 ]; then
            grid_ver=4
        elif [ $nmiss -eq $nmiss_tn1v1_lgm ]; then
            grid_ver=1_lgm
        elif [ $nmiss -eq $nmiss_tn1v1_mis3 ]; then
            grid_ver=1_mis3
        elif [ $nmiss -eq $nmiss_tn1v1_plio ]; then
            grid_ver=1_PlioMIP2
        else
            echo "ERROR: could not determine version of tn1 grid:"
            echo "Number of missing values found: $nmiss"
            echo "Should be ${nmiss_tn1v1},${nmiss_tn1v2},${nmiss_tn1v3},${nmiss_tn1v4} in v1,2,3,4 respectively."
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
   elif [ $gp -eq $gp_tn15 ]; then
        grid_type=tnx1.5
        grid_ver=1
   elif [ $gp -eq $gp_tn2 ]; then
        grid_type=tnx2
        grid_ver=1
   elif [ $gp -eq $gp_g1 ]; then
        grid_type=g1x
        grid_ver=6
   elif [ $gp -eq $gp_g3 ]; then
        grid_type=g3x
        grid_ver=7
   else
       echo "ERROR: the horizontal grid does not match any of the predefined grids (tn0.083,tn0.25,tn1,tn2,g1,g3)"
       echo "*** EXITING THE SCRIPT ***"
       exit 1
    fi
    echo "Grid type and version: ${grid_type}v${grid_ver}"
    echo "${grid_type}v${grid_ver}" > $WKDIR/attributes/grid_${casename}
    if [ -f $WKDIR/co2fxd_tmp.nc ]; then
        rm -f $WKDIR/co2fxd_tmp.nc
    fi
else
    echo "ERROR in reading co2fxd from the history file: $CDO selvar,sst $fullpath_filename $WKDIR/sst_tmp.nc >/dev/null 2>&1"
    exit 1
fi
