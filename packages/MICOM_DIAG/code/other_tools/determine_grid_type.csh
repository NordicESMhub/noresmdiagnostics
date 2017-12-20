#!/bin/csh -f

# MICOM DIAGNOSTICS package: determine_grid_type.csh
# PURPOSE: Determine grid type, size and version
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# STRATEGY: Unfortunately the micom history files do not include any grid information.
# Therefore, the grid size and type is determined by the total number of grid points of the sst variable,
# and the grid version is determined by the number of missing values from that variable.

# Input arguments:
#  $casename  simulation name
#  $test_file some test netcdf file
#  $test_dir  directory of $test_file

set casename  = $1
set test_file = $2
set test_dir  = $3

echo " "
echo "-----------------------"
echo "determine_grid_type.csh"
echo "-----------------------"
echo "Input arguments:"
echo " casename  = $casename"
echo " test_file = $test_file"
echo " test_dir  = $test_dir"
echo " "

@ gp_tn0083 = 14934240 # (4320x3457) number of gridpoints on tn0.083 grids
@ gp_tn025  = 1660320  # (1440x1153) number of gridpoints on tn0.25  grids (multiple choices)
@ gp_tn1    = 138600   # (360x385)   number of gridpoints on tn1     grids (multiple choices)
@ gp_tn15   = 61680    # (240x257)   number of gridpoints on tn1.5   grids
@ gp_tn2    = 34740    # (180x193)   number of gridpoints on tn2     grids
@ gp_g1     = 122880   # (320x384)   number of gridpoints on g1      grids (multiple choices)
@ gp_g3     = 11600    # (100x116)   number of gridpoints on g3      grids

@ nmiss_tn025v1 = 682899
@ nmiss_tn025v3 = 681867
@ nmiss_tn025v4 = 682843
@ nmiss_tn1v1   = 51715
@ nmiss_tn1v2   = 51775
@ nmiss_tn1v3   = 51828
@ nmiss_tn1v4   = 51892
@ nmiss_gv6     = 36649

/usr/bin/cdo -s selvar,sst $test_dir/$test_file $WKDIR/sst_tmp.nc >&! /dev/null
if (-e $WKDIR/sst_tmp.nc) then
   @ gp = `/usr/bin/cdo -s griddes $WKDIR/sst_tmp.nc | grep gridsize | sed -e 's/^[^=]*=//g'`
   if ($gp == $gp_tn0083) then
      set grid_type = tnx0.083
      set grid_ver  = 1
   else if ($gp == $gp_tn025) then
      set grid_type = tnx0.25
      @ nmiss = `/usr/bin/cdo -s info $WKDIR/sst_tmp.nc | awk '{print $7}' | tail -n 1`
      if ($nmiss == $nmiss_tn025v1) then
         set grid_ver = 1
      else if ($nmiss == $nmiss_tn025v3) then
         set grid_ver = 3
      else if ($nmiss == $nmiss_tn025v4) then
         set grid_ver = 4
      else
         echo "ERROR: could not determine version of tn0.25 grid:"
         echo "Number of missing values found: $nmiss"
         echo "Should be ${nmiss_tn025v1},${nmiss_tn025v3},${nmiss_tn025v4} in v1,3,4 respectively."
         echo "*** EXITING THE SCRIPT ***"
         exit 1
      endif
   else if ($gp == $gp_tn1) then
      set grid_type = tnx1
      @ nmiss = `/usr/bin/cdo -s info $WKDIR/sst_tmp.nc | awk '{print $7}' | tail -n 1`
      if ($nmiss == $nmiss_tn1v1) then
         set grid_ver = 1
      else if ($nmiss == $nmiss_tn1v2) then
         set grid_ver = 2
      else if ($nmiss == $nmiss_tn1v3) then
         set grid_ver = 3
      else if ($nmiss == $nmiss_tn1v4) then
         set grid_ver = 4
      else
         echo "ERROR: could not determine version of tn1 grid:"
         echo "Number of missing values found: $nmiss"
         echo "Should be ${nmiss_tn1v1},${nmiss_tn1v2},${nmiss_tn1v3},${nmiss_tn1v4} in v1,2,3,4 respectively."
         echo "*** EXITING THE SCRIPT ***"
         exit 1
      endif
   else if ($gp == $gp_tn15) then
      set grid_type = tnx1.5
      set grid_ver  = 1
   else if ($gp == $gp_tn2) then
      set grid_type = tnx2
      set grid_ver  = 1
   else if ($gp == $gp_g1) then
      set grid_type = g1x
      set grid_ver  = 6
   else if ($gp == $gp_g3) then
      set grid_type = g3x
      set grid_ver  = 7
   else
      echo "ERROR: the horizontal grid does not match any of the predefined grids (tn0.083,tn0.25,tn1,tn2,g1,g3)"
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
   echo "$casename grid: ${grid_type}v${grid_ver}"
   echo "${grid_type}v${grid_ver}" > $WKDIR/attributes/grid_$casename
   if (-e $WKDIR/sst_tmp.nc) then
      rm -f $WKDIR/sst_tmp.nc
   endif
else
   echo "Grid type and version could not be determined from ${test_file}: sst variable does not exist."
endif


