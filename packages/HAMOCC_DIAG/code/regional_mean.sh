#!/bin/bash

# HAMOCC DIAGNOSTICS package: regional_mean.sh
# PURPOSE: computes the regional mean of different basins using CDO
# Johan Liakka, NERSC
# Yanchun He, NERSC, yanchun.he@nersc.no
# Last update June 2018 

# Input arguments:
#  $casename    experiment name
#  $fyr_prnt    first_yr of climo (four digits)
#  $lyr_prnt    last_yr of climo (four digits)
#  $climodir    climo directory

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4

echo " "
echo "-----------------------"
echo "regional_mean.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " "

# check if variables are present
infile=$climodir/${casename}_MON_${fyr_prnt}-${lyr_prnt}_climo_remap.nc

# append MICOM sst,sss climatology to $infile, if available
climodir2=${climodir//HAMOCC_DIAG/MICOM_DIAG}
if [[ -f $climodir2/${casename}_01_${fyr_prnt}-${lyr_prnt}_climo_remap.nc ]]
then
    $NCRCAT --no_tmp_fl -O -v sst,sss `seq -f $climodir2/${casename}_%02g_${fyr_prnt}-${lyr_prnt}_climo_remap.nc 1 12` $climodir2/sst_sss_MON_tmp.nc
    if [ $? -ne 0 ]; then
        echo "WARNING: merging monthly sst,sss climatogies fails: $NCRCAT --no_tmp_fl -O -v sst,sss $climodir2/${casename}_??_${fyr_prnt}-${lyr_prnt}_climo_remap.nc $climodir2/sst_sss_MON_tmp.nc"
    else
        $NCKS -A $climodir2/sst_sss_MON_tmp.nc $infile
        if [ $? -ne 0 ]; then
            echo "WARNING: merging monthly sst,sss climatogies fails: $NCKS -A $climodir2/sst_sss_MON_tmp.nc $infile"
        else
            rm -f sst_sss_MON_tmp.nc
        fi
    fi
else
    echo "WARNING: SST, SSS climatologies in MICOM diagnostic do not exist; should run MICOM diagnostics first"
fi

# append MICOM mxld climatology to $infile, if available
climodir2=${climodir//HAMOCC_DIAG/MICOM_DIAG}/MLD
if [[ -f $climodir2/mld_${fyr_prnt}-${lyr_prnt}_01.nc ]]
then
    $NCRCAT --no_tmp_fl -O -v mld `seq -f $climodir2/mld_${fyr_prnt}-${lyr_prnt}_%02g.nc 1 12` $climodir2/mld_MON_tmp.nc
    if [ $? -ne 0 ]; then
        echo "WARNING: merging monthly mld climatogies fails: $NCRCAT --no_tmp_fl -O -v mld $climodir2/${casename}_??_${fyr_prnt}-${lyr_prnt}_climo_remap.nc $climodir2/mld_MON_tmp.nc"
    else
        $NCKS -A $climodir2/mld_MON_tmp.nc $infile
        if [ $? -ne 0 ]; then
            echo "WARNING: merging monthly mld climatogies fails: $NCKS -A $climodir2/mld_MON_tmp.nc $infile"
        else
            rm -f $climodir2/mld_MON_tmp.nc
        fi
    fi
else
    echo "WARNING: mld climatology in MICOM diagnostic does not exist"
fi

vars=`$CDO -s showname $infile`

for region in ARC NATL NPAC TATL TPAC IND MSO HSO
do
    tmpfile=$climodir/${casename}_${region}_tmp.nc
    for var in $vars
        do
        maskfile=$DIAG_GRID/1x1d/${var}/region_mask_1x1_${region}.nc
        outfile=$climodir/${casename}_MON_${fyr_prnt}-${lyr_prnt}_climo_remap_${region}.nc

        echo "Regional mean over $region for $var"
        $CDO -s ifthen $maskfile -selname,$var $infile ${tmpfile%.*}_${var}.nc
        if [ $? -ne 0 ]; then
            echo "ERROR in masking out $region: $CDO ifthen $maskfile $infile $tmpfile"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    done
    $CDO -s merge ${tmpfile%.*}_*.nc  $tmpfile

        $CDO -s fldmean $tmpfile $outfile
        if [ $? -ne 0 ]; then
            echo "ERROR in taking zonal average: $CDO fldmean $tmpfile $outfile"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
        rm -f $tmpfile ${tmpfile%.*}_*.nc
done

