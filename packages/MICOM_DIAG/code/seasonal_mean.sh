#!/bin/bash

# MICOM DIAGNOSTICS package: seasonal_mean.sh
# PURPOSE: computes the seasonal mean from monthly mean climatologies
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017                                                                                                                                                                                     

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
echo "seasonal_mean.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " climodir = $climodir"
echo " "

season_vars="sst,sss"
file_suff=${first_yr}-${last_yr}_climo_remap

for season in JFM AMJ JAS OND
do
    seas_avg_file=$climodir/${casename}_${season}_${file_suff}.nc

    if [ $season == JFM ]; then
        infiles=(${casename}_01_${file_suff}.nc ${casename}_02_${file_suff}.nc ${casename}_03_${file_suff}.nc)
        wgts=31,28,31
    elif [ $season == AMJ ]; then
        infiles=(${casename}_04_${file_suff}.nc ${casename}_05_${file_suff}.nc ${casename}_06_${file_suff}.nc)
        wgts=30,31,30
    elif [ $season == JAS ]; then
        infiles=(${casename}_07_${file_suff}.nc ${casename}_08_${file_suff}.nc ${casename}_09_${file_suff}.nc)
        wgts=31,31,30
    elif [ $season == OND ]; then
        infiles=(${casename}_10_${file_suff}.nc ${casename}_11_${file_suff}.nc ${casename}_12_${file_suff}.nc)
        wgts=31,30,31
    fi
    $NCRA -O -w $wgts --no_tmp_fl --hdr_pad=10000 -v $season_vars -p $climodir ${infiles[*]} $seas_avg_file
    if [ $? -ne 0 ]; then
        echo "ERROR in computation of climatological annual mean: $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v $var_list_ann -p $climodir ${mon_tmp_files[*]} $ann_avg_file"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
done
