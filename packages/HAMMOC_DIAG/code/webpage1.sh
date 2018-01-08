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
echo "<TABLE width='900'>" >> $WEBDIR/index.html
echo "<TH colspan='3'>Global fluxes" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_co2fxd_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_co2fxd_${cinfo}.png'>Total downward CO2 (co2fxd)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Total downward CO2 (co2fxd)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_co2fxu_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_co2fxu_${cinfo}.png'>Total upward CO2 (co2fxu)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Total upward CO2 (co2fxu)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_co2fxn_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_co2fxn_${cinfo}.png'>Net downward CO2 (co2fxd-co2fxu)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Net downward CO2 (co2fxd-co2fxu)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_pp_${cinfo}.png ]; then
    echo "<TR>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_pp_${cinfo}.png'>Primary production (pp)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Primary production (pp)</I>" >> $WEBDIR/index.html
fi
echo "</TABLE>" >> $WEBDIR/index.html
# AMOC
echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='700'>" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TH colspan='5'>Global averages" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_o2_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_o2_${cinfo}.png'>Oxygen (o2)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Oxygen (o2)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_si_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_si_${cinfo}.png'>Silicate (si)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Silicate (si)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_po4_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_po4_${cinfo}.png'>Phosphate (po4)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Phosphate (po4)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_no3_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_no3_${cinfo}.png'>Nitrate (no3)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Nitrate (no3)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_dissic_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_dissic_${cinfo}.png'>DIC (dissic)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>DIC (dissic)</I>" >> $WEBDIR/index.html
fi
echo "</TABLE>" >> $WEBDIR/index.html

