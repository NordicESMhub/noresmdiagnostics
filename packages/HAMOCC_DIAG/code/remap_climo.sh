#!/bin/bash

# HAMOCC DIAGNOSTICS package: remap_climo.sh
# PURPOSE: remap the climatology file to a rectangular 1x1 grid
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018

# Input arguments:
#  $casename  experiment name
#  $infile    file on standard grid
#  $outfile   remapped file
#  $climodir  directory where the climatology files are located

casename=$1
infile=$2
outfile=$3
climodir=$4

echo " "
echo "-----------------------"
echo "remap_climo.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " infile   = $infile"
echo " outfile  = $outfile"
echo " climodir = $climodir"
echo " "

script_start=`date +%s`
# Read the ascii grid description (created in determine_grid_type.sh)
if [ -z $PGRIDPATH ]; then
    grid_type=`cat $WKDIR/attributes/grid_${casename}`
    grid_file=$DIAG_GRID/$grid_type/grid.nc
    wgt_file=$DIAG_GRID/$grid_type/map_${grid_type}_to_1x1_bilin.nc
else
    grid_file=$PGRIDPATH/grid.nc
fi
if [ ! -f $grid_file ] || [ ! -f $wgt_file ]; then
    echo "ERROR: grid file $grid_file or weight file $wgt_file doesn't exist."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
# Append grid file if necessary
$NCKS --quiet -d depth,0 -d x,0 -d y,0 -v plon $climodir/$infile >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Appending coordinates to $climodir/$infile"
    $NCKS -A -v plon,plat,parea -o $climodir/$infile $grid_file
fi
# Use cdo for remapping (courtesy of Yanchun He)
echo "Remapping $climodir/$infile to a regular 1x1 grid"
$CDO -s remap,global_1,$wgt_file $climodir/$infile $climodir/$outfile >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR in remapping: $CDO -s remap,global_1,$wgt_file $climodir/climo_tmp.nc $rgrdir/$outfile"
    exit 1
fi

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "REMAPPING RUNTIME: ${runtime_script_m}m${runtime_script_s}s"

