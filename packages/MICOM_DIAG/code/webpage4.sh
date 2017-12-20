#!/bin/bash

# MICOM DIAGNOSTICS package: webpage4.sh
# PURPOSE: modifies the html for set 4 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage4.sh"
echo "-----------------------"
echo "Modifying html for set4 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/index.html
echo "<TABLE style='width:15%'>" >> $WEBDIR/index.html
echo "<TH colspan='3'>Overturning circulation" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if ls $WEBDIR/set4/set4_ann_mmflxd*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set4/set4_ann_mmflxd0_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set4/set4_ann_mmflxd1_${cinfo}.png'>Indian-Pacific</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set4/set4_ann_mmflxd2_${cinfo}.png'>Global</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indian-Pacific</I>" >> $WEBDIR/index.html
    echo "<TD><I>Global</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
