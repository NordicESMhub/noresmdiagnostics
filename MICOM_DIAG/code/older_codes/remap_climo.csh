#!/bin/csh -f

# MICOM DIAGNOSTICS package: remap_climo.csh
# PURPOSE: remap the climatology file to a rectangular 1x1 grid
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $casename  experiment name
#  $ann_file  annual climotology file
#  $climodir  directory where the climatology files are located
#  $rgrdir    directory for the regridded climotology files

set casename = $1
set ann_file = $2
set climodir = $3
set rgrdir   = $4

echo " "
echo "-----------------------"
echo "remap_climo.csh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " ann_file = $ann_file"
echo " climodir = $climodir"
echo " rgrdir   = $rgrdir"
echo " "

if (! -e $rgrdir/$ann_file) then
   set script_start = `date +%s`
   # Read the grid (created in determine_grid_type.csh)
   set grid_type = `cat $WKDIR/attributes/grid_${casename}`
   set grid_file  = $DIAG_GRID/$grid_type/grid.nc

   # Append grid file if necessary
   /usr/local/bin/ncks --quiet -d depth,0 -d x,0 -d y,0 -v plon $climodir/$ann_file >&! /dev/null
   if ($status > 0) then
      echo "Appending coordinates to $climodir/$ann_file"
      /usr/local/bin/ncks -A -v plon,plat,parea -o $climodir/$ann_file $grid_file
   endif
   # Use cdo for remapping (courtesy of Yanchun He)
   echo "Remapping $climodir/$ann_file to a regular 1x1 grid"
   /usr/bin/cdo -s remapbil,global_1 $climodir/$ann_file $rgrdir/$ann_file

   set script_end       = `date +%s`
   set runtime_s        = `expr ${script_end} - ${script_start}`
   set runtime_script_m = `expr ${runtime_s} / 60`
   set min_in_secs      = `expr ${runtime_script_m} \* 60`
   set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
   echo "REMAPPING RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
else
   echo "$rgrdir/$ann_file already exists."
   echo "-> SKIPPING REMAPPING CLIMATOLOGY"
endif
