#!/bin/bash

# HAMMOC DIAGNOSTICS package: webpage3.sh
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
echo "<TABLE width='500'>" >> $WEBDIR/index.html
echo "<TH colspan='5'>Zonal mean fields" >> $WEBDIR/index.html
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Oxygen (o2lvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_o2lvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_ann_o2lvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_o2lvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_o2lvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_o2lvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_o2lvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/index.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/index.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/index.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Silicate (silvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_silvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_ann_silvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_silvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_silvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_silvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_silvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/index.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/index.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/index.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Phosphate (po4lvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_po4lvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_ann_po4lvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_po4lvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_po4lvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_po4lvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_po4lvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/index.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/index.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/index.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>Nitrate (no3lvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_no3lvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_ann_no3lvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_no3lvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_no3lvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_no3lvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_no3lvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/index.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/index.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/index.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/index.html
fi
echo "<TR>" >> $WEBDIR/index.html
echo "<TD>DIC (dissiclvl)" >> $WEBDIR/index.html
if ls $WEBDIR/set3/set3_ann_dissiclvl_*_${cinfo}.png >/dev/null 2>&1
then
    echo "<TD><a href='set3/set3_ann_dissiclvl_glb_${cinfo}.png'>Global</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_dissiclvl_atl_${cinfo}.png'>Atlantic</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_dissiclvl_pac_${cinfo}.png'>Pacific</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_dissiclvl_ind_${cinfo}.png'>Indian</a>" >> $WEBDIR/index.html
    echo "<TD><a href='set3/set3_ann_dissiclvl_so_${cinfo}.png'>Southern</a>" >> $WEBDIR/index.html
else
    echo "<TD><I>Global</I>" >> $WEBDIR/index.html
    echo "<TD><I>Atlantic</I>" >> $WEBDIR/index.html
    echo "<TD><I>Pacific</I>" >> $WEBDIR/index.html
    echo "<TD><I>Indian</I>" >> $WEBDIR/index.html
    echo "<TD><I>Southern</I>" >> $WEBDIR/index.html
fi
echo '</TABLE>' >> $WEBDIR/index.html
