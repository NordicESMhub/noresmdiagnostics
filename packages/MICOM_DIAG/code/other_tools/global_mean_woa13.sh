#!/bin/bash

# MICOM DIAGNOSTICS package: global_mean_woa13.sh (not used in the diagnostics)
# PURPOSE: computes the global (horizontal) mean of WOA13 data
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017                                                                                                                                                                                     

echo " "
echo "-----------------------"
echo "global_mean_woa13.sh"
echo "-----------------------"

# Variable
NCAP2=`which ncap2`
NCWA=`which ncwa`
var=t
datadir=/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/obs_data/WOA13/1deg
infile=$datadir/woa13_decav_${var}00_01.nc
outfile=$datadir/woa13_decav_${var}00_01_gm.nc
tmpfile=$datadir/woa13_decav_${var}00_tmp.nc

echo "Adding gaussian weights"
$NCAP2 -h -O -s "weights=cos(lat*3.1415/180)" $infile $tmpfile
if [ $? -ne 0 ]; then
    echo "ERROR in adding gaussian weights"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
echo "Computing global mean"
$NCWA -h -O -v ${var}_an -w weights -a lat,lon $tmpfile $outfile
if [ $? -ne 0 ]; then
    echo "ERROR in calculating average"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
rm -r $tmpfile

