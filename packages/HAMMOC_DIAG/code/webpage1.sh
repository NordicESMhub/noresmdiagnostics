#!/bin/bash

# MICOM DIAGNOSTICS package: webpage1.sh
# PURPOSE: modifies the html for set 1 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage1.sh"
echo "-----------------------"
echo "Modifying html for set1 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

# Volume transports
echo "<TABLE width='300'>" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_flx_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_flx_${cinfo}.png'>Global fluxes</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global fluxes</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_avg_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_${cinfo}.png'>Global averages</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global averages</I>" >> $WEBDIR/index.html
fi
echo "</TABLE>" >> $WEBDIR/index.html

