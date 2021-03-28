#!/bin/bash

# CISM DIAGNOSTICS package: webpage1.sh
# Create set 1 webpage for existing plots
# Heiko Goelzer, NORCE; Jan 2021
#source $BIN_DIR/.ncofilters

echo " "
echo "-----------------------"
echo "webpage1new.sh"
echo "-----------------------"
echo "Modifying html for set1 plots"

# Original scalar variables
cat << 'EOF' >> $WEBDIR/index.html
    <h3 id="Scalars">Scalars </h3>
EOF
echo $(ls $WEBDIR/set1/set1_ann*.png |wc -l)
if [ $(ls $WEBDIR/set1/set1_ann*.png |wc -l) == 13 ]
then
    cat << 'EOF' >> $WEBDIR/index.html
    <TABLE width='100%'>
    <TR>
        <TH> Ice mass
        <TH> Ice mass above flotation
        <TH> Grounded ice area
        <TH> Floating ice area
    <TR>
        <TD><a target="_self" href="set1/set1_ann_imass_CINFO.png"><img src="set1/set1_ann_imass_CINFO.png" alt="Ice mass"></a>
        <TD><a target="_self" href="set1/set1_ann_imass_above_flotation_CINFO.png"><img src="set1/set1_ann_imass_above_flotation_CINFO.png" alt="Ice mass above flotation"></a>
        <TD><a target="_self" href="set1/set1_ann_iareag_CINFO.png"><img src="set1/set1_ann_iareag_CINFO.png" alt="Grounded ice area"></a>
        <TD><a target="_self" href="set1/set1_ann_iareaf_CINFO.png"><img src="set1/set1_ann_iareaf_CINFO.png" alt="Floating ice area"></a>
    </TR>
        <TH> Total SMB flux
        <TH> Total calving flux
        <TH> Total grounding line flux
        <TH> Total basal melt flux
    <TR>
        <TD><a target="_self" href="set1/set1_ann_total_smb_flux_CINFO.png"><img src="set1/set1_ann_total_smb_flux_CINFO.png" alt="Total SMB flux"></a>
        <TD><a target="_self" href="set1/set1_ann_total_calving_flux_CINFO.png"><img src="set1/set1_ann_total_calving_flux_CINFO.png" alt="Total calving flux"></a>
        <TD><a target="_self" href="set1/set1_ann_total_gl_flux_CINFO.png"><img src="set1/set1_ann_total_gl_flux_CINFO.png" alt="Total grounding line flux"></a>
        <TD><a target="_self" href="set1/set1_ann_total_bmb_flux_CINFO.png"><img src="set1/set1_ann_total_bmb_flux_CINFO.png" alt="Total basal melt flux"></a>
    </TR>

    </TABLE>
EOF

cat << 'EOF' >> $WEBDIR/index.html
    <h3 id="Recomputed-scalars">Recomputed scalars </h3>
EOF

cat << 'EOF' >> $WEBDIR/index.html
    <TABLE width='100%'>
    <TR>
        <TH> Mean ice thickness
        <TH> Mean surface mass balance
        <TH> Mean surface temperature
        <TH> Mean bedrock topography
        <TH> Mean surface elevation
    <TR>
        <TD><a target="_self" href="set1/set1_ann_thkga_CINFO.png"><img src="set1/set1_ann_thkga_CINFO.png" alt="Mean ice thickness"></a>
        <TD><a target="_self" href="set1/set1_ann_smbga_CINFO.png"><img src="set1/set1_ann_smbga_CINFO.png" alt="Mean surface mass balance"></a>
        <TD><a target="_self" href="set1/set1_ann_artmga_CINFO.png"><img src="set1/set1_ann_artmga_CINFO.png" alt="Mean surface temperature"></a>
        <TD><a target="_self" href="set1/set1_ann_topgga_CINFO.png"><img src="set1/set1_ann_topgga_CINFO.png" alt="Mean bedrock topography"></a>
        <TD><a target="_self" href="set1/set1_ann_usurfga_CINFO.png"><img src="set1/set1_ann_usurfga_CINFO.png" alt="Mean surface elevation"></a>
    </TR>
    </TABLE>
EOF
else
    echo "ERROR: Unknown number of files SKIP..."
fi
