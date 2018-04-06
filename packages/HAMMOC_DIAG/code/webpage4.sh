#!/bin/bash

# HAMMOC DIAGNOSTICS package: webpage4.sh
# PURPOSE: modifies the html for set 4 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Apr 2018

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
echo "<TABLE width='700'>" >> $WEBDIR/index.html
echo "<TH colspan='3'>Regionally-averaged monthly climatologies [<a href='regions.png'>regions</a>]" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_pp_tot_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_pp_tot_${cinfo}.png'>Column-integrated PP (pp)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Column-integrated PP (pp)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set4/set4_pco2_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_pco2_${cinfo}.png'>pCO2 (pco2)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>pCO2 (pco2)</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set4/set4_co2fxn_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_co2fxn_${cinfo}.png'>CO2 flux (co2fxd-co2fxu)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>CO2 flux (co2fxd-co2fxu)</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
