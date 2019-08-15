#!/bin/bash

# MICOM DIAGNOSTICS package: webpage1.sh
# Create set 1 webpage for existing plots
# Yanchun He, NERSC, yanchun.he@nersc.no
# Last update, Aug 2019
#source $BIN_DIR/.ncofilters

echo " "
echo "-----------------------"
echo "webpage1.sh"
echo "-----------------------"
echo "Modifying html for set1 plots"

# Section transport
cat << 'EOF' >> $WEBDIR/indexnew.html
    <h3 id="Section-transports">Section transports </h3>
EOF
if [ $(ls $WEBDIR/set1/set1_ann_voltr*_*.png |wc -l) == 15 ]
then
cat << 'EOF' >> $WEBDIR/indexnew.html
    <TABLE width='100%'>
    <TR>
        <TH> Barents opening
        <TH> Bering strait
        <TH> Canadian archipelago
        <TH> Denmark strait
        <TH> Drake passage
    <TR>
        <TD><a target="_self" href="set1/set1_ann_voltr0_CINFO.png"><img src="set1/set1_ann_voltr0_CINFO.png" alt="Barents opening"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr1_CINFO.png'><img src="set1/set1_ann_voltr1_CINFO.png" alt="Bering strait"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr2_CINFO.png'><img src="set1/set1_ann_voltr2_CINFO.png" alt="Canadian archipelago"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr3_CINFO.png'><img src="set1/set1_ann_voltr3_CINFO.png" alt="Denmark strait"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr4_CINFO.png'><img src="set1/set1_ann_voltr4_CINFO.png" alt="Drake passage"></a>
    </TR>
    <TR>
        <TH>English channel
        <TH>Equatorial undercurrent
        <TH>Faroe Scotland channel
        <TH>Florida Bahamas
        <TH>Fram strait
    </TR>
    <TR>
        <TD><a target="_self" href='set1/set1_ann_voltr5_CINFO.png'><img src="set1/set1_ann_voltr5_CINFO.png" alt="English channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr6_CINFO.png'><img src="set1/set1_ann_voltr6_CINFO.png" alt="Equatorial undercurrent"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr7_CINFO.png'><img src="set1/set1_ann_voltr7_CINFO.png" alt="Faroe Scotland channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr8_CINFO.png'><img src="set1/set1_ann_voltr8_CINFO.png" alt="Florida Bahamas"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr9_CINFO.png'><img src="set1/set1_ann_voltr9_CINFO.png" alt="Fram strait"></a>
    </TR>
    <TR>
        <TH>Iceland Faroe channel
        <TH>Indonesian throughflow
        <TH>Mozambique channel
        <TH>Taiwan and Luzon straits
        <TH>Windward passage
    </TR>
    <TR>
        <TD><a target="_self" href='set1/set1_ann_voltr10_CINFO.png'><img src="set1/set1_ann_voltr10_CINFO.png" alt="Iceland Faroe channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr11_CINFO.png'><img src="set1/set1_ann_voltr11_CINFO.png" alt="Indonesian throughflow"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr12_CINFO.png'><img src="set1/set1_ann_voltr12_CINFO.png" alt="Mozambique channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr13_CINFO.png'><img src="set1/set1_ann_voltr13_CINFO.png" alt="Taiwan and Luzon straits"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr14_CINFO.png'><img src="set1/set1_ann_voltr14_CINFO.png" alt="Windward passage"></a>
    </TR>
    </TABLE>
EOF
elif [ $(ls $WEBDIR/set1/set1_ann_voltr*_*.png |wc -l) == 17 ]
then
    cat << 'EOF' >> $WEBDIR/indexnew.html
    <TABLE width='100%'>
    <TR>
        <TH> Barents opening
        <TH> Bering strait
        <TH> Canadian archipelago
        <TH> Davis strait 
        <TH> Denmark strait
    <TR>
        <TD><a target="_self" href="set1/set1_ann_voltr0_CINFO.png"><img src="set1/set1_ann_voltr0_CINFO.png" alt="Barents opening"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr1_CINFO.png'><img src="set1/set1_ann_voltr1_CINFO.png" alt="Bering strait"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr2_CINFO.png'><img src="set1/set1_ann_voltr2_CINFO.png" alt="Canadian archipelago"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr3_CINFO.png'><img src="set1/set1_ann_voltr3_CINFO.png" alt="Davis strait"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr4_CINFO.png'><img src="set1/set1_ann_voltr4_CINFO.png" alt="Denmark strait"></a>
    </TR>
    <TR>
        <TH>Drake passage
        <TH>English channel
        <TH>Faroe Scotland channel
        <TH>Florida Bahamas strit
        <TH>Fram strait
    </TR>
    <TR>
        <TD><a target="_self" href='set1/set1_ann_voltr5_CINFO.png'><img src="set1/set1_ann_voltr5_CINFO.png" alt="Drake Passage"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr6_CINFO.png'><img src="set1/set1_ann_voltr6_CINFO.png" alt="English channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr7_CINFO.png'><img src="set1/set1_ann_voltr7_CINFO.png" alt="Faroe Scotland channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr8_CINFO.png'><img src="set1/set1_ann_voltr8_CINFO.png" alt="Florida Bahamas"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr9_CINFO.png'><img src="set1/set1_ann_voltr9_CINFO.png" alt="Fram strait"></a>
    </TR>
    <TR>
        <TH>Gibraltar strait
        <TH>Iceland Faroe channel
        <TH>Indonesian throughflow
        <TH>Mozambique channel
        <TH>Pacific equatorial undercurrent
    </TR>
    <TR>
        <TD><a target="_self" href='set1/set1_ann_voltr10_CINFO.png'><img src="set1/set1_ann_voltr10_CINFO.png" alt="Gibraltar strait"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr11_CINFO.png'><img src="set1/set1_ann_voltr11_CINFO.png" alt="Iceland Faroe channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr12_CINFO.png'><img src="set1/set1_ann_voltr12_CINFO.png" alt="Indonesian throughflow"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr13_CINFO.png'><img src="set1/set1_ann_voltr13_CINFO.png" alt="Mozambique channel"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr14_CINFO.png'><img src="set1/set1_ann_voltr14_CINFO.png" alt="Pacific equatorial undercurrent"></a>
    </TR>
    <TR>
        <TH>Taiwan and luzon straits
        <TH>Windward passage
    </TR>
    <TR>
        <TD><a target="_self" href='set1/set1_ann_voltr15_CINFO.png'><img src="set1/set1_ann_voltr15_CINFO.png" alt="Taiwan and luzon strait"></a>
        <TD><a target="_self" href='set1/set1_ann_voltr16_CINFO.png'><img src="set1/set1_ann_voltr16_CINFO.png" alt="Windward passage"></a>
    </TR>
    </TABLE>
<br>
EOF
else
    echo "ERROR: Unknown number of transport sections. SKIP..."
fi

cat << 'EOF' >> $WEBDIR/indexnew.html
<h3 id="Global-averages">Global averages </h3>
EOF

if ls $WEBDIR/set1/set1_ann_temp_${cinfo}.png >/dev/null 2>&1
then
cat << 'EOF' >> $WEBDIR/indexnew.html
<TABLE width='80%'>
<TR>
    <TH>Temperature
    <TH>Salinity
    <TH>SST
    <TH>SSS
</TR>
<TR>
    <TD><a target="_self" href='set1/set1_ann_temp_CINFO.png'><img src="set1/set1_ann_temp_CINFO.png" alt="Temperature"></a>
    <TD><a target="_self" href='set1/set1_ann_saln_CINFO.png'><img src="set1/set1_ann_saln_CINFO.png" alt="Salinity"></a>
    <TD><a target="_self" href='set1/set1_ann_sst_CINFO.png'><img src="set1/set1_ann_sst_CINFO.png" alt="SST"></a>
    <TD><a target="_self" href='set1/set1_ann_sss_CINFO.png'><img src="set1/set1_ann_sss_CINFO.png" alt="SSS"></a>
</TR>
</TABLE>
<br>
EOF
elif ls $WEBDIR/set1/set1_ann_tempga_${cinfo}.png >/dev/null 2>&1
then
cat << 'EOF' >> $WEBDIR/indexnew.html
<TABLE width='80%'>
<TR>
    <TH>Temperature <br> (tempga)
    <TH>Salinity <br> (salnga)
    <TH>SST <br> (sstga)
    <TH>SSS <br> (sssga)
</TR>
<TR>
    <TD><a target="_self" href='set1/set1_ann_tempga_CINFO.png'><img src="set1/set1_ann_tempga_CINFO.png" alt="Temperature"></a>
    <TD><a target="_self" href='set1/set1_ann_salnga_CINFO.png'><img src="set1/set1_ann_salnga_CINFO.png" alt="Salinity"></a>
    <TD><a target="_self" href='set1/set1_ann_sstga_CINFO.png'><img src="set1/set1_ann_sstga_CINFO.png" alt="SST"></a>
    <TD><a target="_self" href='set1/set1_ann_sssga_CINFO.png'><img src="set1/set1_ann_sssga_CINFO.png" alt="SSS"></a>
</TR>
</TABLE>
<br>
EOF
else
    echo "WARNING: global averages do not exist, SKIP..."
fi

cat << 'EOF' >> $WEBDIR/indexnew.html
<h3 id="Maximum-AMOC">Maximum AMOC </h3>
<TABLE width='80%'>
<TR>
    <TH>"Region of mmflxd included:"
    <TH>26.5N
    <TH>45N
    <TH>20N-60N
</TR>
<TR>
    <TH style="vertical-align:middle">"atlantic_arctic_ocean"
    <TD><a target="_self" href='set1/set1_ann_mmflxd265_CINFO.png'><img src="set1/set1_ann_mmflxd265_CINFO.png" alt="26.5N"></a>
    <TD><a target="_self" href='set1/set1_ann_mmflxd45_CINFO.png'><img src="set1/set1_ann_mmflxd45_CINFO.png" alt="45N"></a>
    <TD><a target="_self" href='set1/set1_ann_mmflxd_max_CINFO.png'><img src="set1/set1_ann_mmflxd_max_CINFO.png" alt="20N-60N"></a>
</TR>
EOF
if ls $WEBDIR/set1/set1_ann_mmflx*ext_${cinfo}.png >/dev/null 2>&1
then
cat << 'EOF' >> $WEBDIR/indexnew.html
<TR>
    <TH style="vertical-align:middle">"atlantic_arctic_extend_ocean"
    <TD><a target="_self" href='set1/set1_ann_mmflxd265ext_CINFO.png'><img src="set1/set1_ann_mmflxd265ext_CINFO.png" alt="26.5N"></a>
    <TD><a target="_self" href='set1/set1_ann_mmflxd45ext_CINFO.png'><img src="set1/set1_ann_mmflxd45ext_CINFO.png" alt="45N"></a>
    <TD><a target="_self" href='set1/set1_ann_mmflxd_maxext_CINFO.png'><img src="set1/set1_ann_mmflxd_maxext_CINFO.png" alt="20N-60N"></a>
</TR>
EOF
fi
cat << 'EOF' >> $WEBDIR/indexnew.html
</TABLE>
<br>
EOF

cat << 'EOF' >> $WEBDIR/indexnew.html
<h3 id="Hovmoeller-plots">Hovm&ouml;ller plots</h3>
<TABLE width='80%'>
<TR>
    <TH>
    <TH>Temperature
    <TH>Salinity
</TR>
<TR>
    <TH style="vertical-align:middle">Relative to start of simulation
    <TD><a target="_self" href='set1/set1_ann_templvl1_CINFO.png'><img src="set1/set1_ann_templvl1_CINFO.png" alt="Temperature" class="img_wider"></a>
    <TD><a target="_self" href='set1/set1_ann_salnlvl1_CINFO.png'><img src="set1/set1_ann_salnlvl1_CINFO.png" alt="Salinity" class="img_wider"></a>
</TR>
<TR>
    <TH style="vertical-align:middle">Relative to WOA13 climatology
    <TD><a target="_self" href='set1/set1_ann_templvl2_CINFO.png'><img src="set1/set1_ann_templvl2_CINFO.png" alt="Temperature" class="img_wider"></a>
    <TD><a target="_self" href="set1/set1_ann_salnlvl2_CINFO.png"> <img src="set1/set1_ann_salnlvl2_CINFO.png" alt="Salinity" class="img_wider"></a>
</TR>
</TABLE>
<br>
EOF
