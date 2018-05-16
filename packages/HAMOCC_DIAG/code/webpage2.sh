#!/bin/bash

# HAMOCC DIAGNOSTICS package: webpage2.sh
# PURPOSE: modifies the html for set 2 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018

echo " "
echo "-----------------------"
echo "webpage2.sh"
echo "-----------------------"
echo "Modifying html for set2 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='700'>" >> $WEBDIR/index.html
echo "<TH colspan='6'>Horizontal fields" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Dissolved oxygen (o2lvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_o2lvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_o2lvl_0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_o2lvl_100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_o2lvl_500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_o2lvl_1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_o2lvl_2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_o2lvl_3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_o2lvl_4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Silicate (silvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_silvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_silvl_0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_silvl_100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_silvl_500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_silvl_1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_silvl_2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_silvl_3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_silvl_4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Phosphate (po4lvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_po4lvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_po4lvl_0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_po4lvl_100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_po4lvl_500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_po4lvl_1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_po4lvl_2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_po4lvl_3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_po4lvl_4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Nitrate (no3lvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_no3lvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_no3lvl_0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_no3lvl_100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_no3lvl_500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_no3lvl_1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_no3lvl_2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_no3lvl_3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_no3lvl_4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>DIC (dissiclvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_dissiclvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_dissiclvl_0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_dissiclvl_100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_dissiclvl_500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_dissiclvl_1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_dissiclvl_2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_dissiclvl_3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_dissiclvl_4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Alkalinity (talklvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_talklvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_talklvl_0_${cinfo}.png'>0m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_talklvl_100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_talklvl_500_${cinfo}.png'>500m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_talklvl_1000_${cinfo}.png'>1000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_talklvl_2000_${cinfo}.png'>2000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_talklvl_3000_${cinfo}.png'>3000m</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set2/set2_ann_talklvl_4000_${cinfo}.png'>4000m</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>0m</I>" >> $WEBDIR/index.html
    echo "<TD><I>100m</I>" >> $WEBDIR/index.html
    echo "<TD><I>500m</I>" >> $WEBDIR/index.html
    echo "<TD><I>1000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>2000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>3000m</I>" >> $WEBDIR/index.html
    echo "<TD><I>4000m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Primary productivity (pp)" >> $WEBDIR/index.html
if [ -f $WEBDIR/set2/set2_ann_pp_tot_${cinfo}.png ]; then
    echo "<TD colspan='7'><a href='set2/set2_ann_pp_tot_${cinfo}.png'>column-integrated (diagnosed offline)</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='7'><I>column-integrated (diagnosed offline)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Primary productivity (ppint)" >> $WEBDIR/index.html
if [ -f $WEBDIR/set2/set2_ann_ppint_${cinfo}.png ]; then
    echo "<TD colspan='7'><a href='set2/set2_ann_ppint_${cinfo}.png'>column-integrated (diagnosed online)</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='7'><I>column-integrated (diagnosed online)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Export production (epc100)" >> $WEBDIR/index.html
if [ -f $WEBDIR/set2/set2_ann_epc100_${cinfo}.png ]; then
    echo "<TD colspan='2'><a href='set2/set2_ann_epc100_${cinfo}.png'>100m</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='2'><I>100m</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>pCO2 (pco2)" >> $WEBDIR/index.html
if [ -f $WEBDIR/set2/set2_ann_pco2_${cinfo}.png ]; then
    echo "<TD colspan='5'><a href='set2/set2_ann_pco2_${cinfo}.png'>surface</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='5'><I>surface</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>CO2 flux (co2fxd-co2fxu)" >> $WEBDIR/index.html
if [ -f $WEBDIR/set2/set2_ann_co2fxn_${cinfo}.png ]; then
    echo "<TD colspan='5'><a href='set2/set2_ann_co2fxn_${cinfo}.png'>surface</a>" >> $WEBDIR/index.html
else
    echo "<TD colspan='5'><I>surface</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
