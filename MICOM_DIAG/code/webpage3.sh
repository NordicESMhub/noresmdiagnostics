#!/bin/bash

# MICOM DIAGNOSTICS package: webpage3.sh
# PURPOSE: modifies the html for set 3 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage3.sh"
echo "-----------------------"
echo "Modifying html for set3 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/index.html
echo "<TABLE style='width:30%'>" >> $WEBDIR/index.html
echo "<TH colspan='6'>Horizontal contour plots" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set3/set3_ann_mld_${cinfo}.png ]; then
    echo "<TD colspan='2'><a href='set3/set3_ann_mld_${cinfo}.png'>Mixed layer depth</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='2'><I>Mixed layer depth</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set3/set3_ann_sealv_${cinfo}.png ]; then
    echo "<TD colspan='3'><a href='set3/set3_ann_sealv_${cinfo}.png'>Sea level</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='3'><I>Sea level</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Temperature" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_templvl*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_ann_templvl0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl50_${cinfo}.png'>50m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl250_${cinfo}.png'>250m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_templvl4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>50m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>250m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_templvl*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD>Salinity" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl50_${cinfo}.png'>50m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl250_${cinfo}.png'>250m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_salnlvl4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>50m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>250m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
