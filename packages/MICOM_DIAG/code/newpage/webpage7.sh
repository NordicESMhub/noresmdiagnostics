#!/bin/bash

# MICOM DIAGNOSTICS package: webpage7.sh
# PURPOSE: modifies the html for set 7 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Feb 2018

echo " "
echo "-----------------------"
echo "webpage7.sh"
echo "-----------------------"
echo "Modifying html for set7 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/indexnew.html
echo "<TABLE width='500'>" >> $WEBDIR/indexnew.html
echo "<TH>Meridional fluxes (vertically integrated)" >> $WEBDIR/indexnew.html
echo '</TABLE>' >> $WEBDIR/indexnew.html
echo "<TABLE width='250'>" >> $WEBDIR/indexnew.html
if [ -f $WEBDIR/set7/set7_ann_mhflx_${cinfo}.png ]; then
    echo "<TD><a href='set7/set7_ann_mhflx_${cinfo}.png'>Heat</a>" >> $WEBDIR/indexnew.html
else
    echo "<TD><I>Heat</I>" >> $WEBDIR/indexnew.html
fi
if [ -f $WEBDIR/set7/set7_ann_msflx_${cinfo}.png ]; then
    echo "<TD><a href='set7/set7_ann_msflx_${cinfo}.png'>Salinity</a>" >> $WEBDIR/indexnew.html
else
    echo "<TD><I>Salinity</I>" >> $WEBDIR/indexnew.html
fi
echo '</TABLE>' >> $WEBDIR/indexnew.html
