#!/bin/bash

# MICOM DIAGNOSTICS package: webpage6.sh
# PURPOSE: modifies the html for set 6 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage6.sh"
echo "-----------------------"
echo "Modifying html for set6 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='300'>" >> $WEBDIR/index.html
echo "<TH colspan='2'>Equatorial cross sections" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set6/set6_ann_templvl_${cinfo}.png ]; then
    echo "<TD><a href='set6/set6_ann_templvl_${cinfo}.png'>Temperature</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Temperature</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set6/set6_ann_salnlvl_${cinfo}.png ]; then
    echo "<TD><a href='set6/set6_ann_salnlvl_${cinfo}.png'>Salinity</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Salinity</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
