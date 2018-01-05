#!/bin/bash

# HAMMOC DIAGNOSTICS package: zonal_mean.sh
# PURPOSE: computes the zonal mean of different basins using CDO
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018 

# Input arguments:
#  $casename    experiment name
#  $first_yr    first_yr of climo (four digits)
#  $last_yr     last_yr of climo (four digits)
#  $climodir    climo directory

casename=$1
first_yr=$2
last_yr=$3
climodir=$4

echo " "
echo "-----------------------"
echo "zonal_mean.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " climodir = $climodir"
echo " "

# Zonal mean variables
req_zm_vars=`cat $WKDIR/attributes/required_zm_vars`

# check if variables are present
infile=$climodir/${casename}_ANN_${first_yr}-${last_yr}_climo_remap.nc
zm_vars=" "
first_find=1
find_any=0
for var in `echo $req_zm_vars | sed 's/,/ /g'`
do
    $NCKS --quiet -d lon,0 -d lat,0 -d depth,0 -v $var $infile >/dev/null 2>&1
    if [ $? -eq 0 ]; then
	find_any=1
	if [ $first_find -eq 1 ]; then
	    first_find=0
	    zm_vars=$var
	else
	    zm_vars=${zm_vars},$var
	fi
    fi
done

if [ $find_any -eq 1 ]; then
    for region in glb pac atl ind so
    do
	maskfile=$DIAG_GRID/region_mask_1x1_${region}.nc
	outfile=$climodir/${casename}_ANN_${first_yr}-${last_yr}_climo_remap_zm_${region}.nc
	tmpfile1=$climodir/${casename}_${region}_tmp1.nc
	tmpfile2=$climodir/${casename}_${region}_tmp2.nc

	echo "Taking zonal mean of $req_zm_vars over $region"
	$CDO -s selvar,$zm_vars $infile $tmpfile1
	if [ $? -ne 0 ]; then
	    echo "ERROR in selecting variables: $CDO selvar,$req_zm_vars $infile $tmpfile1"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
	$CDO -s ifthen $maskfile $tmpfile1 $tmpfile2
	if [ $? -ne 0 ]; then
	    echo "ERROR in masking out $region: $CDO ifthen $maskfile $tmpfile1 $tmpfile2"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	else
	    rm -f $tmpfile1
	fi
	$CDO -s zonmean $tmpfile2 $outfile
	if [ $? -ne 0 ]; then
	    echo "ERROR in taking zonal average: $CDO zonavg $tmpfile2 $outfile"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	else
	    rm -r $tmpfile2
	fi
    done
else
    echo "Cannot compute zonal mean: variables $req_zm_vars not present in $infile"
fi

