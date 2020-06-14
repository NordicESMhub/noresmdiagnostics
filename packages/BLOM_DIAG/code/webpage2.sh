#!/bin/bash

# BLOM DIAGNOSTICS package: webpage2.sh
# PURPOSE: modifies the html for set 2 depending on existing plots
# Johan Liakka, NERSC; Dec 2017
# Yanchun He, NERSC; Jun 2020

echo " "
echo "-----------------------"
echo "webpage2.sh"
echo "-----------------------"
echo "Modifying html for set2 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

# Time series plots
echo "<br>" >> $WEBDIR/index.html
echo "<TABLE width='200'>" >> $WEBDIR/index.html
echo "<TH colspan='2'>ENSO indices [<a href='https://climatedataguide.ucar.edu/climate-data/nino-sst-indices-nino-12-3-34-4-oni-and-tni' target='_blank'>?</a>]" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if [ -f $WEBDIR/set2/set2_mon_sst3_${cinfo}.png ]; then
    echo "<TD><a href='set2/set2_mon_sst3_${cinfo}.png'>NINO 3</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>NINO 3</I>" >> $WEBDIR/index.html
fi
if [ -f $WEBDIR/set2/set2_mon_sst34_${cinfo}.png ]; then
    echo "<TD><a href='set2/set2_mon_sst34_${cinfo}.png'>NINO 3.4</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>NINO 3.4</I>" >> $WEBDIR/index.html
fi
# End of table
echo '</TABLE>' >> $WEBDIR/index.html
