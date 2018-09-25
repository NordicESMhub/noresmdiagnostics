#!/bin/bash

# MICOM DIAGNOSTICS package: webpage5.sh
# PURPOSE: modifies the html for set 5 depending on existing plots
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

echo " "
echo "-----------------------"
echo "webpage5.sh"
echo "-----------------------"
echo "Modifying html for set5 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi

echo "<br>" >> $WEBDIR/indexnew.html
echo "<TABLE width='500'>" >> $WEBDIR/indexnew.html
echo "<TH colspan='5'>Zonal means (lat-depth)" >> $WEBDIR/indexnew.html
echo "<TR>" >> $WEBDIR/indexnew.html
echo "<TD>Temperature" >> $WEBDIR/indexnew.html
if ls $WEBDIR/set5/set5_ann_templvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set5/set5_ann_templvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_templvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_templvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_templvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_templvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/indexnew.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/indexnew.html
fi
echo "<TR>" >> $WEBDIR/indexnew.html
echo "<TD>Salinity" >> $WEBDIR/indexnew.html
if ls $WEBDIR/set5/set5_ann_salnlvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set5/set5_ann_salnlvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_salnlvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_salnlvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_salnlvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/indexnew.html
    echo "<TD><a href='set5/set5_ann_salnlvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/indexnew.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/indexnew.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/indexnew.html
fi
echo '</TABLE>' >> $WEBDIR/indexnew.html

