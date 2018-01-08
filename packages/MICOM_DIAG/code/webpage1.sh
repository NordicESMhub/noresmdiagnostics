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
echo "<TABLE width='1000'>" >> $WEBDIR/index.html
echo "<TH colspan='5'>Section transports" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if ls $WEBDIR/set1/set1_ann_voltr*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set1/set1_ann_voltr0_${cinfo}.png'>Barents opening</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr1_${cinfo}.png'>Bering strait</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr2_${cinfo}.png'>Canadian archipelago</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr3_${cinfo}.png'>Denmark strait</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr4_${cinfo}.png'>Drake passage</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr5_${cinfo}.png'>English channel</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr6_${cinfo}.png'>Equatorial undercurrent</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr7_${cinfo}.png'>Faroe Scotland channel</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr8_${cinfo}.png'>Florida Bahamas</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr9_${cinfo}.png'>Fram strait</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr10_${cinfo}.png'>Iceland Faroe channel</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr11_${cinfo}.png'>Indonesian throughflow</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr12_${cinfo}.png'>Mozambique channel</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr13_${cinfo}.png'>Taiwan and Luzon straits</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set1/set1_ann_voltr14_${cinfo}.png'>Windward passage</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Barents opening</I>" >> $WEBDIR/index.html
    echo "<TD><I>Bering strait</I>" >> $WEBDIR/index.html
    echo "<TD><I>Canadian archipelago</I>" >> $WEBDIR/index.html
    echo "<TD><I>Denmark strait</I>" >> $WEBDIR/index.html
    echo "<TD><I>Drake passage</I>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
    echo "<TD><I>English channel</I>" >> $WEBDIR/index.html
    echo "<TD><I>Equatorial undercurrent</I>" >> $WEBDIR/index.html
    echo "<TD><I>Faroe Scotland channel</I>" >> $WEBDIR/index.html
    echo "<TD><I>Florida Bahamas</I>" >> $WEBDIR/index.html
    echo "<TD><I>Fram strait</I>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
    echo "<TD><I>Iceland Faroe channel</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indonesian throughflow</I>" >> $WEBDIR/index.html
    echo "<TD><I>Mozambique channel</I>" >> $WEBDIR/index.html
    echo "<TD><I>Taiwan and Luzon straits</I>" >> $WEBDIR/index.html
    echo "<TD><I>Windward passage</I>" >> $WEBDIR/index.html
fi
echo "</TABLE>" >> $WEBDIR/index.html
# Global averages
echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='200'>" >> $WEBDIR/index.html
echo "<TH colspan='2'>Global averages" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_temp_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_temp_${cinfo}.png'>Temperature</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Temperature</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_saln_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_saln_${cinfo}.png'>Salinity</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Salinity</I>" >> $WEBDIR/index.html
fi
echo "</TABLE>" >> $WEBDIR/index.html
# AMOC
echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='200'>" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TH colspan='3'>Maximum AMOC" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_mmflxd265_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_mmflxd265_${cinfo}.png'>26.5N</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>26.5N</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_mmflxd45_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_mmflxd45_${cinfo}.png'>45N</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>45N</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_mmflxd_max_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_mmflxd_max_${cinfo}.png'>20N-60N</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>20N-60N</I>" >> $WEBDIR/index.html
fi
echo "</TABLE>" >> $WEBDIR/index.html
# Hovmöller
echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='450'>" >> $WEBDIR/index.html
echo "<TH colspan='2'>Hovmoeller plots" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Relative to start of simulation" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_templvl1_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_templvl1_${cinfo}.png'>Temperature</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Temperature (temp)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_salnlvl1_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_salnlvl1_${cinfo}.png'>Salinity</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Salinity (saln)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Relative to WOA13 climatology" >> $WEBDIR/index.html
if [ -f $WEBDIR/set1/set1_ann_templvl1_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_templvl2_${cinfo}.png'>Temperature</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Temperature (temp)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set1/set1_ann_salnlvl1_${cinfo}.png ]; then
    echo "<TD><a href='set1/set1_ann_salnlvl2_${cinfo}.png'>Salinity</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Salinity (saln)</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
