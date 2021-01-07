#!/bin/bash

# CISM DIAGNOSTICS package: webpage1.sh
# PURPOSE: modifies the html for set 1 depending on existing plots
# Heiko Goelzer, NORCE; Jan 2021
# Based on BLOM package

echo " "
echo "-----------------------"
echo "webpage1.sh"
echo "-----------------------"
echo "Modifying html for set1 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

# Scalars
echo "<TABLE width='1000'>" >> $WEBDIR/index.html
echo "<TH colspan='5'>Scalar variables" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if ls $WEBDIR/set1/set1_ann_vol*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set1/set1_ann_vol_${cinfo}.png'>Ice volume</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
else
    echo "<TD><I>Ice volume</I>" >> $WEBDIR/index.html
fi

if ls $WEBDIR/set1/set1_ann_smbga*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set1/set1_ann_smbga_${cinfo}.png'>Mean smb</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
else
    echo "<TD><I>Mean SMB</I>" >> $WEBDIR/index.html
fi

if ls $WEBDIR/set1/set1_ann_artmga*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set1/set1_ann_artmga_${cinfo}.png'>Mean temperature</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
else
    echo "<TD><I>Mean temperature</I>" >> $WEBDIR/index.html
fi

if ls $WEBDIR/set1/set1_ann_topgga*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set1/set1_ann_topgga_${cinfo}.png'>Mean topography</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
else
    echo "<TD><I>Mean topography</I>" >> $WEBDIR/index.html
fi

if ls $WEBDIR/set1/set1_ann_usurfga*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set1/set1_ann_usurfga_${cinfo}.png'>Mean surface elevation</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
else
    echo "<TD><I>Mean surface elevation</I>" >> $WEBDIR/index.html
fi

echo "</TABLE>" >> $WEBDIR/index.html
