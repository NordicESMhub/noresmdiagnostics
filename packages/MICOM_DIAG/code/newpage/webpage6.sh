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

echo "<br>" >> $WEBDIR/indexnew.html
echo "<TABLE width='300'>" >> $WEBDIR/indexnew.html
echo "<TH colspan='2'>Equatorial cross sections" >> $WEBDIR/indexnew.html
echo "<TR>" >> $WEBDIR/indexnew.html
if [ -f $WEBDIR/set6/set6_ann_templvl_${cinfo}.png ]; then
    echo "<TD><a href='set6/set6_ann_templvl_${cinfo}.png'>Temperature</a>" >> $WEBDIR/indexnew.html
else
    echo "<TD><I>Temperature</I>" >> $WEBDIR/indexnew.html
fi
if [ -f $WEBDIR/set6/set6_ann_salnlvl_${cinfo}.png ]; then
    echo "<TD><a href='set6/set6_ann_salnlvl_${cinfo}.png'>Salinity</a>" >> $WEBDIR/indexnew.html
else
    echo "<TD><I>Salinity</I>" >> $WEBDIR/indexnew.html
fi
echo '</TABLE>' >> $WEBDIR/indexnew.html
