#!/bin/bash
# CISM DIAGNOSTICS package: webpage2.sh
# Create set 2 webpage for existing plots
# Heiko Goelzer, NORCE; Jan 2021

echo " "
echo "-----------------------"
echo "webpage2.sh"
echo "-----------------------"
echo "Modifying html for set2 plots"

# Scalar variables
cat << 'EOF' >> $WEBDIR/index.html
    <h3 id="2d plots">2d Plots </h3>
EOF
if [ $(ls $WEBDIR/set2/set2_ann_test_*.png |wc -l) == 13 ]
then
cat << 'EOF' >> $WEBDIR/index.html
    <TABLE width='100%'>
    <TR>
        <TH> Ice volume
    <TR>
        <TD><a target="_self" href="set2/set2_ann_test_smb_CINFO.png"><img src="set1/set1_ann_vol_CINFO.png" alt="SMB"></a>
    </TR>
    </TABLE>
EOF
elif [ $(ls $WEBDIR/set2/set2_ann_test_*.png |wc -l) == 17 ]
then
    cat << 'EOF' >> $WEBDIR/index.html
    <TABLE width='100%'>
    <TR>
        <TH> Ice Volume
    <TR>
        <TD><a target="_self" href="set2/set2_ann_test_smb_CINFO.png"><img src="set1/set1_ann_vol_CINFO.png" alt="SMB"></a>
    </TR>
    </TABLE>
<br>
EOF
else
    echo "ERROR: Unknown number of files SKIP..."
fi
