#!/bin/bash

script_start=`date +%s`
#
# CLM DIAGNOSTICS package: compute_ann_time_series.sh
# PURPOSE: computes annual time series from monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Apr 2018

# STRATEGY: Split the data into chucks of 10 years each.
# Run each chunk serially and the 10 chunk year in parallel.

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $tsdir     directory where the climatology files are located
#  $procdir   work directory

casename=$1
first_yr=$2
last_yr=$3
pathdat=$4
tsdir=$5
procdir=$6

echo " "
echo "---------------------------"
echo "compute_ann_time_series.sh"
echo "---------------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " tsdir    = $tsdir"
echo " procdir  = $procdir"
echo " "

NCRA=`which ncra`
if [ $? -ne 0 ]; then
    echo "Could not find ncra (which ncra)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

NCRCAT=`which ncrcat`
if [ $? -ne 0 ]; then
    echo "Could not find ncrcat (which ncrcat)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

NCATTED=`which ncatted`
if [ $? -ne 0 ]; then
    echo "Could not find ncatted (which ncatted)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

var_list=`cat $procdir/vars_ts_clm2`
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
ann_ts_file=${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts.nc

# Calculate number of chunks and the residual
nproc=10
let "nyrs = $last_yr - $first_yr + 1"
let "nchunks = $nyrs / $nproc"
let "residual = $nyrs % $nproc"

if [ $residual -gt 0 ]; then
    let "nchunkp = $nchunks + 1"
else
    let "nchunkp = $nchunks"
fi
ichunk=1
while [ $ichunk -le $nchunkp ]
do
    if [ $residual -gt 0 ]; then
	if [ $ichunk -lt $nchunkp ]; then
            nyrs=$nproc
	else
            nyrs=$residual
	fi
    else
	nyrs=$nproc
    fi
    let "nyrsm = $nyrs - 1"
    pid=()
    iproc=1
    let "YR_start = ($ichunk - 1) * $nproc + $first_yr"
    let "YR_end = ($ichunk - 1) * $nproc + $nyrs + $first_yr - 1"
    # Compute annual means from h0 files
    echo "Computing annual means from monthly history files (yrs ${YR_start}-${YR_end})"
    pid=()
    iproc=1
    while [ $iproc -le $nyrs ]
    do
        let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
        yr_prnt=`printf "%04d" ${YR}`
	filenames=()
	for mon in 01 02 03 04 05 06 07 08 09 10 11 12
	do
	    filename=${casename}.clm2.h0.${yr_prnt}-${mon}.nc
	    filenames+=($filename)
	done
	eval $NCRA -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v $var_list -p $pathdat ${filenames[*]} $tsdir/${casename}_ANN_${yr_prnt}_tmp.nc &
        pid+=($!)
        let iproc++
    done
    for ((m=0;m<=$nyrsm;m++))
    do
        wait ${pid[$m]}
	if [ $? -ne 0 ]; then
	    echo "ERROR in computing annual means from monthly history files: $NCRA -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v $var_list -p $pathdat $filenames $tsdir/${casename}_ANN_${yr_prnt}.nc"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
    done
    wait
    let ichunk++
done

# Concancate files
first_file=${casename}_ANN_${first_yr_prnt}_tmp.nc
if [ -f $tsdir/$first_file ]; then
    echo "Merging all time series files..."
    $NCRCAT --no_tmp_fl -O $tsdir/${casename}_ANN_????_tmp.nc $tsdir/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts.nc
    if [ $? -ne 0 ]; then
	echo "ERROR in merging annual time-series files: $NCRCAT --no_tmp_fl -O $tsdir/${casename}_ANN_????_tmp.nc $tsdir/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts.nc"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    # Clean up
    rm $tsdir/${casename}_ANN_*_tmp.nc

    $NCATTED -O -a yrs_averaged,global,c,c,"1" $tsdir/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts.nc
    # Create symbolic link for NCL
    if [ -L $tsdir/${casename}_ANN_ALL.nc ]; then
	rm $tsdir/${casename}_ANN_ALL.nc
    fi
    ln -s $tsdir/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts.nc $tsdir/${casename}_ANN_ALL.nc
fi



script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "ANNUAL TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
