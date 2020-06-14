#!/bin/bash

# BLOM DIAGNOSTICS package: ps2png.sh
# PURPOSE: convert ps figs to png
# Johan Liakka, NERSC; Dec 2017
# Yanchun He, NERSC; Jun 2020

# Input arguments:
#  $nset      figure set
#  $density   figure quality

nset=$1
density=$2

echo " "
echo "-----------------------"
echo "ps2png.sh"
echo "-----------------------"
echo "Input arguments:"
echo " nset    = $nset"
echo " density = $density"
echo " "

CONVERT=`which convert`
if [ $? -ne 0 ]; then
    echo "ERROR: convert not found."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
CONVERT_ARGS="-density $density -trim -bordercolor white -border 5x5"

figs_exist=0
echo -n "Converting $nset figures to png... "
for figps in ${nset}_*.ps
do
    if [ -f $figps ]; then
        figs_exist=1
        $CONVERT $CONVERT_ARGS $figps $WEBDIR/$nset/${figps%.*}.png
        if [ $? -ne 0 ]; then
            echo "ERROR in converting from ps to png: $CONVERT $CONVERT_ARGS $figps $WEBDIR/$nset/${figps%.*}.png"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    fi
done
if [ $figs_exist -eq 1 ]; then
    echo "Done!"
    echo "Deleting all $nset ps files"
    rm -f ${nset}_*.ps
else
    echo ""
    echo "ERROR: $nset figures not found."
    echo "Cannot create web interface for $nset"
    exit 1
fi
