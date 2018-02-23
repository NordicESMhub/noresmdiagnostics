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
echo "<TABLE width='700'>" >> $WEBDIR/index.html
echo "<TH colspan='6'>Horizontal fields - annual means" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
#if [ -f $WEBDIR/set3/set3_ann_mld_${cinfo}.png ]; then
#    echo "<TD colspan='2'><a href='set3/set3_ann_mld_${cinfo}.png'>Mixed layer depth</a>" >> $WEBDIR/index.html
#else
#    echo "<TD colspan='2'><I>Mixed layer depth</I>" >> $WEBDIR/index.html
#fi
if [ -f $WEBDIR/set3/set3_ann_sealv_${cinfo}.png ]; then
    echo "<TD colspan='3'><a href='set3/set3_ann_sealv_${cinfo}.png'>Sea surface height</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='3'><I>Sea surface height</I>" >> $WEBDIR/index.html
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
echo "<TD>Salinity" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_salnlvl*_${cinfo}.png >/dev/null 2>&1
then
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
echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='730'>" >> $WEBDIR/index.html
echo "<TH colspan='12'>Horizontal fields - seasonal/monthly means" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Mixed-layer depth" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_*_mld_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_01_mld_${cinfo}.png'>Jan</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_02_mld_${cinfo}.png'>Feb</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_03_mld_${cinfo}.png'>Mar</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_04_mld_${cinfo}.png'>Apr</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_05_mld_${cinfo}.png'>May</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_06_mld_${cinfo}.png'>Jun</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_07_mld_${cinfo}.png'>Jul</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_08_mld_${cinfo}.png'>Aug</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_09_mld_${cinfo}.png'>Sep</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_10_mld_${cinfo}.png'>Oct</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_11_mld_${cinfo}.png'>Nov</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_12_mld_${cinfo}.png'>Dec</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_mld_${cinfo}.png'>ANN</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Jan</I>" >> $WEBDIR/index.html
    echo "<TD><I>Feb</I>" >> $WEBDIR/index.html
    echo "<TD><I>Mar</I>" >> $WEBDIR/index.html
    echo "<TD><I>Apr</I>" >> $WEBDIR/index.html
    echo "<TD><I>May</I>" >> $WEBDIR/index.html
    echo "<TD><I>Jun</I>" >> $WEBDIR/index.html
    echo "<TD><I>Jul</I>" >> $WEBDIR/index.html
    echo "<TD><I>Aug</I>" >> $WEBDIR/index.html
    echo "<TD><I>Sep</I>" >> $WEBDIR/index.html
    echo "<TD><I>Oct</I>" >> $WEBDIR/index.html
    echo "<TD><I>Nov</I>" >> $WEBDIR/index.html
    echo "<TD><I>Dec</I>" >> $WEBDIR/index.html
    echo "<TD><I>ANN</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD colspan='3'>Sea surface temperature" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_*_sst_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_JFM_sst_${cinfo}.png'>JFM</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_AMJ_sst_${cinfo}.png'>AMJ</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_JAS_sst_${cinfo}.png'>JAS</a>" >> $WEBDIR/index.html
    echo "<TD colspan='2'><a href='set3/set3_OND_sst_${cinfo}.png'>OND</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>JFM</I>" >> $WEBDIR/index.html
    echo "<TD><I>AMJ</I>" >> $WEBDIR/index.html
    echo "<TD><I>JAS</I>" >> $WEBDIR/index.html
    echo "<TD colspan='2'><I>OND</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD colspan='3'>Sea surface salinity" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_*_sst_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_JFM_sss_${cinfo}.png'>JFM</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_AMJ_sss_${cinfo}.png'>AMJ</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_JAS_sss_${cinfo}.png'>JAS</a>" >> $WEBDIR/index.html
    echo "<TD colspan='2'><a href='set3/set3_OND_sss_${cinfo}.png'>OND</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>JFM</I>" >> $WEBDIR/index.html
    echo "<TD><I>AMJ</I>" >> $WEBDIR/index.html
    echo "<TD><I>JAS</I>" >> $WEBDIR/index.html
    echo "<TD colspan='2'><I>OND</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
