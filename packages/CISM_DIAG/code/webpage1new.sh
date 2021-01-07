#!/bin/bash

# CISM DIAGNOSTICS package: webpage1.sh
# Create set 1 webpage for existing plots
# Heiko Goelzer, NORCE; Jan 2021
#source $BIN_DIR/.ncofilters

echo " "
echo "-----------------------"
echo "webpage1.sh"
echo "-----------------------"
echo "Modifying html for set1 plots"

# Scalar variables
cat << 'EOF' >> $WEBDIR/indexnew.html
    <h3 id="Time series">Time series </h3>
EOF
if [ $(ls $WEBDIR/set1/set1_ann_vol*_*.png |wc -l) == 15 ]
then
cat << 'EOF' >> $WEBDIR/indexnew.html
    <TABLE width='100%'>
    <TR>
        <TH> Ice volume
    <TR>
        <TD><a target="_self" href="set1/set1_ann_vol_CINFO.png"><img src="set1/set1_ann_vol_CINFO.png" alt="Ice volume"></a>
    </TR>
    </TABLE>
EOF
elif [ $(ls $WEBDIR/set1/set1_ann_vol*_*.png |wc -l) == 17 ]
then
    cat << 'EOF' >> $WEBDIR/indexnew.html
    <TABLE width='100%'>
    <TR>
        <TH> Ice Volume
    <TR>
        <TD><a target="_self" href="set1/set1_ann_vol_CINFO.png"><img src="set1/set1_ann_vol_CINFO.png" alt="Ice volume"></a>
    </TR>
    </TABLE>
<br>
EOF
else
    echo "ERROR: Unknown number of files SKIP..."
fi
