#!/bin/bash

# MICOM DIAGNOSTICS package: remap_climo.sh
# PURPOSE: remap the climatology file to a rectangular 1x1 grid
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Feb 2017

# Input arguments:
#  $casename   experiment name
#  $fyr_prnt   file on standard grid
#  $lyr_prnt   remapped file
#  $climodir   directory where the climatology files are located
#  $ann_mode   0 or 1
#  $mon_mode   0 or 1

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4
ann_mode=$5
mon_mode=$6

echo " "
echo "-----------------------"
echo "remap_climo.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " ann_mode = $ann_mode"
echo " mon_mode = $mon_mode"
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

if [ $ann_mode -eq 1 ] && [ $mon_mode -eq 1 ]; then
    echo "Remapping annual and monthly climatology"
    mon_seas_list="01 02 03 04 05 06 07 08 09 10 11 12 ANN"
    max_proc=12
elif [ $ann_mode -eq 1 ] && [ $mon_mode -eq 0 ]; then
    echo "Remapping annual climatology"
    mon_seas_list="ANN"
    max_proc=0
else
    echo "Remapping monthly climatology"
    mon_seas_list="01 02 03 04 05 06 07 08 09 10 11 12"
    max_proc=11
fi

for month in $mon_seas_list
do
    infile=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo.nc
    vars_excl="mmflxd,mhflx,msflx,region" # Variables to exclude
    
    # Append grid file if necessary
    $NCKS --quiet -d depth,0 -d x,0 -d y,0 -v plon $climodir/$infile >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Appending coordinates to $climodir/$infile"
        $NCKS -A -v plon,plat,parea -o $climodir/$infile $grid_file
    fi
    # Remove variables that should not be remapped
    $NCKS --quiet -d lat,0 -d region,0 -v mmflxd $climodir/$infile >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        $NCKS -O -x -v $vars_excl --no_tmp_fl  $climodir/$infile $climodir/climo_${month}.nc
    else
        cp $climodir/$infile $climodir/climo_${month}.nc
    fi
done
    
# Use parallel cdo for remapping
pid=()
for month in $mon_seas_list
do
    infile=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo.nc
    outfile=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo_remap.nc
    echo "Remapping $climodir/$infile to a regular 1x1 grid"
    eval $CDO -s remapbil,global_1 $climodir/climo_${month}.nc $climodir/$outfile >/dev/null 2>&1 &
    pid+=($!)
done
for ((m=0;m<=${max_proc};m++))
do
    wait ${pid[$m]}
    if [ $? -ne 0 ]; then
        echo "ERROR in remapping: $CDO -s remapbil,global_1 $climodir/climo_${month}.nc $climodir/$outfile"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
done
wait

# Cleaning up
for month in $mon_seas_list
do
    if [ -f $climodir/climo_${month}.nc ]; then
        rm -f $climodir/climo_${month}.nc
    fi
done

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "REMAPPING RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
