#!/bin/bash
# CISM DIAGNOSTICS package: webpage2.sh
# PURPOSE: modifies the html for set 2 depending on existing plots
# Heiko Goelzer, NORCE; Jan 2021
# Based on BLOM package

echo " "
echo "-----------------------"
echo "webpage2.sh"
echo "-----------------------"
echo "Modifying html for set2 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

# 2d plots
echo "<TABLE width='1000'>" >> $WEBDIR/index.html
echo "<TH colspan='5'>2d Plots" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
if ls $WEBDIR/set2/set2_ann_test_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set2/set2_ann_test_smb_${cinfo}.png'>SMB</a>" >> $WEBDIR/index.html
    echo "<TR>" >> $WEBDIR/index.html
else
    echo "<TD><I>SMB</I>" >> $WEBDIR/index.html
fi

echo "</TABLE>" >> $WEBDIR/index.html
