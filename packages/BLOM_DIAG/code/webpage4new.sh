#!/bin/bash

# BLOM DIAGNOSTICS package: webpage4.sh
# PURPOSE: modifies the html for set 4 depending on existing plots
# Yanchun He, NERSC

echo " "
echo "-----------------------"
echo "webpage4.sh"
echo "-----------------------"
echo "Modifying html for set4 plots"

cinfo=1model
if [ $COMPARE == USER ]; then
    cinfo=2models
fi
#
nreg=$($NCDUMP -v region $INFILE1 |grep 'region = ' |sed 's/[^0-9]//g')
#nreg=${nreg:0:1}

if [ $nreg -eq 3 ]; then
    cat <<EOF >>$WEBDIR/indexnew.html
<h2 id='Overturning-circulation'>Overturning circulation</h2>
<TABLE width='100%'>
<TR>
    <TH> Atlantic
    <TH> Indian-Pacific
    <TH> Global
</TR>
<TR>
    <TD><a target='_self' href='set4/set4_ann_mmflxd0_${cinfo}.png'><img src='set4/set4_ann_mmflxd0_${cinfo}.png' atl='Atlantic' class='img_wider'></a>
    <TD><a target='_self' href='set4/set4_ann_mmflxd1_${cinfo}.png'><img src='set4/set4_ann_mmflxd1_${cinfo}.png' atl='Indian-Pacific' class='img_wider'></a>
    <TD><a target='_self' href='set4/set4_ann_mmflxd2_${cinfo}.png'><img src='set4/set4_ann_mmflxd2_${cinfo}.png' atl='Glboal' class='img_wider'></a>
</TR>
</TABLE>
<br>
EOF
elif [ $nreg -eq 4 ]; then
    cat <<EOF >>$WEBDIR/indexnew.html
<h2 id='Overturning-circulation'>Overturning circulation</h2>
<TABLE width='100%'>
<TR>
    <TH> Atlantic
    <TH> Atlantic extended
</TR>
<TR>
    <TD><a target='_self' href='set4/set4_ann_mmflxd0_${cinfo}.png'><img src='set4/set4_ann_mmflxd0_${cinfo}.png' atl='Atlantic' class='img_wider'></a>
    <TD><a target='_self' href='set4/set4_ann_mmflxd1_${cinfo}.png'><img src='set4/set4_ann_mmflxd1_${cinfo}.png' atl='Atlantic (extended)' class='img_wider'></a>
</TR>
<TR>
    <TH> Indian-Pacific
    <TH> Global
</TR>
<TR>
    <TD><a target='_self' href='set4/set4_ann_mmflxd2_${cinfo}.png'><img src='set4/set4_ann_mmflxd2_${cinfo}.png' atl='Indian-Pacific' class='img_wider'></a>
    <TD><a target='_self' href='set4/set4_ann_mmflxd3_${cinfo}.png'><img src='set4/set4_ann_mmflxd3_${cinfo}.png' atl='Glboal' class='img_wider'></a>
</TR>
</TABLE>
<br>
EOF
else
    echo "ERROR: Unkown number of regions"
fi

