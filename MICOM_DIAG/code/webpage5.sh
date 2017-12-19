#!/bin/bash

# MICOM DIAGNOSTICS package: webpage5.sh
# PURPOSE: modifies the html for set 5 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage5.sh"
echo "-----------------------"
echo "Modifying html for set5 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/index.html
echo "<TABLE style='width:15%'>" >> $WEBDIR/index.html
echo "<TH>Zonal means (lat-depth)" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Coming soon..." >> $WEBDIR/index.html
echo '</TABLE>' >> $WEBDIR/index.html
