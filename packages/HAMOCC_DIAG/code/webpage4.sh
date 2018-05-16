#!/bin/bash

# HAMOCC DIAGNOSTICS package: webpage4.sh
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
echo "<TABLE width='500'>" >> $WEBDIR/index.html
echo "<TH colspan='3'>Regionally-averaged monthly climatologies [<a href='regions2.png'>regions</a>]" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_pp_tot_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_pp_tot_${cinfo}.png'>Column-integrated PP (pp)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Column-integrated PP (pp)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_ppint_tot_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_ppint_tot_${cinfo}.png'>Column-integrated PP (ppint)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Column-integrated PP (ppint)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_pco2_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_pco2_${cinfo}.png'>pCO2 (pco2)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>pCO2 (pco2)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_co2fxn_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_co2fxn_${cinfo}.png'>CO2 flux (co2fxd-co2fxu)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>CO2 flux (co2fxd-co2fxu)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_srfo2_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_srfo2_${cinfo}.png'>Surface oxygen (srfo2)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Surface oxygen (srfo2)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_srfsi_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_srfsi_${cinfo}.png'>Surface silicate (srfsi)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Surface silicate (srfsi)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_srfpo4_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_srfpo4_${cinfo}.png'>Surface phosphate (srfpo4)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Surface phosphate (srfpo4)</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set4/set4_srfno3_${cinfo}.png ]; then
    echo "<TD><a href='set4/set4_srfno3_${cinfo}.png'>Surface nitrate (srfno3)</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Surface nitrate (srfno3)</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
