#!/bin/bash

script_start=`date +%s`
#
# CLM DIAGNOSTICS package: compute_climo.sh
# PURPOSE: computes climatology from monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Apr 2017

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $climodir  directory where the climatology files are located
#  $procdir   work directory
#  $model     clm or cam

casename=$1
first_yr=$2
last_yr=$3
pathdat=$4
climodir=$5
procdir=$6
model=$7

echo " "
echo "-----------------------"
echo "compute_climo.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " climodir = $climodir"
echo " procdir  = $procdir"
echo " model    = $model"
echo " "

let "first_yrm = $first_yr - 1"
let "last_yrm = $last_yr - 1"
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
first_yr_prntm=`printf "%04d" ${first_yrm}`
last_yr_prntm=`printf "%04d" ${last_yrm}`
var_list=`cat $procdir/vars_climo_${model}`
dec_flag=`cat $procdir/dec_flag`

# Compute climatology
$ncclimo_dir/ncclimo --no_stdin --clm_md=mth -m $model -a $dec_flag -v $var_list --no_amwg_links -c $casename -s $first_yr -e $last_yr -i $pathdat -o $climodir
if [ $? -ne 0 ]; then
    echo "ERROR in computing climatology: $ncclimo_dir/ncclimo --no_stdin --clm_md=mth -m $model -a $dec_flag --no_amwg_links -c $casename -s $first_yr -e $last_yr -i $pathdat -o $climodir"
    exit 1
fi

# Merge monthly files
monfiles=()
for mon in 01 02 03 04 05 06 07 08 09 10 11 12
do
    if [ $dec_flag == scd ] && [ $mon -eq 12 ]; then
	monfiles+=(${casename}_12_${first_yr_prntm}12_${last_yr_prntm}12_climo.nc)
    else
	monfiles+=(${casename}_${mon}_${first_yr_prnt}${mon}_${last_yr_prnt}${mon}_climo.nc)
    fi
done

echo "Merging monthly files."
$ncksbin/ncrcat --no_tmp_fl -O -p $climodir ${monfiles[*]} $climodir/${casename}_MON_${first_yr_prnt}-${last_yr_prnt}_climo.nc
if [ $? -ne 0 ]; then
    echo "ERROR in merging monthly climo files: $ncksbin/ncrcat --no_tmp_fl -O -p $climodir ${monfiles[*]} $climodir/${casename}_MON_${first_yr_prnt}-${last_yr_prnt}_climo.nc"
    exit 1
fi
$ncksbin/ncatted -O -a yrs_averaged,global,c,c,"${first_yr}-${last_yr}" $climodir/${casename}_MON_${first_yr_prnt}-${last_yr_prnt}_climo.nc

# Delete monthly files
echo "Deleting monthy files."
for mon in 01 02 03 04 05 06 07 08 09 10 11 12
do
    if [ $dec_flag == scd ] && [ $mon -eq 12 ]; then
	monfile_path=$climodir/${casename}_12_${first_yr_prntm}12_${last_yr_prntm}12_climo.nc
    else
	monfile_path=$climodir/${casename}_${mon}_${first_yr_prnt}${mon}_${last_yr_prnt}${mon}_climo.nc
    fi
    rm -f $monfile_path
done

echo "Renaming seasonal and annual files."
for seas in DJF MAM JJA SON ANN
do
    outfile=$climodir/${casename}_${seas}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
    if [ $seas == DJF ]; then
	if [ $dec_flag == scd ]; then
	    infile=$climodir/${casename}_${seas}_${first_yr_prntm}12_${last_yr_prnt}02_climo.nc
	else
	    infile=$climodir/${casename}_${seas}_${first_yr_prnt}01_${last_yr_prnt}12_climo.nc
	fi
    elif [ $seas == MAM ]; then
	infile=$climodir/${casename}_${seas}_${first_yr_prnt}03_${last_yr_prnt}05_climo.nc
    elif [ $seas == JJA ]; then
	infile=$climodir/${casename}_${seas}_${first_yr_prnt}06_${last_yr_prnt}08_climo.nc
    elif [ $seas == SON ]; then
	infile=$climodir/${casename}_${seas}_${first_yr_prnt}09_${last_yr_prnt}11_climo.nc
    else
	if [ $dec_flag == scd ]; then
	    infile=$climodir/${casename}_${seas}_${first_yr_prntm}12_${last_yr_prnt}11_climo.nc
	else
	    infile=$climodir/${casename}_${seas}_${first_yr_prnt}01_${last_yr_prnt}12_climo.nc
	fi
    fi
    mv $infile $outfile
    $NCATTED -O -a yrs_averaged,global,c,c,"${first_yr}-${last_yr}" $outfile
done
       
script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "CLIMO RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
