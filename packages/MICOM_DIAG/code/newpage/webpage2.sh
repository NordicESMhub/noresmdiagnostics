#!/bin/bash

# MICOM DIAGNOSTICS package: webpage2.sh
# PURPOSE: modifies the html for set 2 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage2.sh"
echo "-----------------------"
echo "Modifying html for set2 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

cat $DIAG_CODE/newpage/webpage2.html >> $WEBDIR/index.html
sed -i "s/CINFO.png/${cinfo}.png/g" $WEBDIR/index.html
