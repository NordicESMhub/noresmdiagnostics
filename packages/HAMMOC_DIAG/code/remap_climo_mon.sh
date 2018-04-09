#!/bin/bash

# HAMOCC DIAGNOSTICS package: remap_climo_mon.sh
# PURPOSE: remap the climatology file to a rectangular 1x1 grid
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018

# Input arguments:
#  $casename  experiment name
#  $fyr_prnt  first year of climatology (4 digits)
#  $lyr_prnt  last year of climatology (4 digits)
#  $climodir  directory where the climatology files are located

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4

echo " "
echo "-----------------------"
echo "remap_climo_mon.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " "

script_start=`date +%s`
# Read the ascii grid description (created in determine_grid_type.sh)
if [ -z $PGRIDPATH ]; then
    grid_type=`cat $WKDIR/attributes/grid_${casename}`
    grid_file=$DIAG_GRID/$grid_type/grid.nc
else
    grid_file=$PGRIDPATH/grid.nc
fi
if [ ! -f $grid_file ]; then
    echo "ERROR: grid file $grid_file doesn't exist."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

for mon in 01 02 03 04 05 06 07 08 09 10 11 12
do
    infile=${casename}_${mon}_${fyr_prnt}-${lyr_prnt}_climo.nc
    # Append grid file if necessary
    $NCKS --quiet -d depth,0 -d x,0 -d y,0 -v plon $climodir/$infile >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "Appending coordinates to $climodir/$infile"
	$NCKS -A -v plon,plat,parea -o $climodir/$infile $grid_file
    fi
done

pid=()
for mon in 01 02 03 04 05 06 07 08 09 10 11 12
do
    infile=${casename}_${mon}_${fyr_prnt}-${lyr_prnt}_climo.nc
    outfile=${casename}_${mon}_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
    # Use cdo for remapping (courtesy of Yanchun He)
    echo "Remapping $climodir/$infile to a regular 1x1 grid"
    eval $CDO -s remapbil,global_1 $climodir/$infile $climodir/$outfile >/dev/null 2>&1 &
    pid+=($!)
done
for ((m=0;m<=11;m++))
do
    wait ${pid[$m]}
    if [ $? -ne 0 ]; then
        echo "ERROR in remapping: $CDO -s remapbil,global_1 $climodir/$infile $climodir/$outfile"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
done
wait

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "REMAPPING RUNTIME: ${runtime_script_m}m${runtime_script_s}s"

