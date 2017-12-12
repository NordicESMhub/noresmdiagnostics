#!/bin/bash

script_start=`date +%s`
#
# MICOM DIAGNOSTICS package: compute_climo.sh
# PURPOSE: computes climatology from annual or monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# (built upon previous work by Detelina Ivanova)
# Last update Dec 2017

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $climodir  directory where the climatology files are located

filetype=$1
casename=$2
first_yr=$3
last_yr=$4
pathdat=$5
climodir=$6

echo " "
echo "-----------------------"
echo "compute_climo.sh"
echo "-----------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " climodir = $climodir"
echo " "

var_list=`cat $WKDIR/attributes/vars_climo_${casename}_${filetype}`
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
ann_avg_file=${climodir}/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_climo_${filetype}.nc

# COMPUTE CLIMATOLOGY FROM ANNUAL FILES
if [ $filetype == hy ]; then
    filenames=()
    YR=$first_yr
    while [ $YR -le $last_yr ]
    do
	yr_prnt=`printf "%04d" ${YR}`
	filename=${casename}.micom.hy.${yr_prnt}.nc
	filenames+=($filename)
	let YR++
    done
    echo "Climatological annual mean"
    $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $ann_avg_file
    if [ $? -ne 0 ]; then
	echo "ERROR in computation of climatological annual mean: $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $ann_avg_file"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
fi

# COMPUTE CLIMATOLOGY FROM MONTHLY FILES
if [ $filetype == hm ]; then
    pid=()
    mon_avg_files=()
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
	echo "Climatological monthly mean for month=${month}"
	filenames=()
	YR=$first_yr
	while [ $YR -le $last_yr ]
	do
	    yr_prnt=`printf "%04d" ${YR}`
            filename=${casename}.micom.hm.${yr_prnt}-${month}.nc
            if [ -f $pathdat/$filename ]; then
		filenames+=($filename)
            else
		echo "ERROR: $pathdat/$filename does not exist."
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
            let YR++
	done
	mon_avg_file=${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
	mon_avg_files+=($mon_avg_file)
	eval $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $climodir/$mon_avg_file &
	pid+=($!)
    done
    for ((m=1;m<=12;m++))
    do
	wait ${pid[$m]}
        if [ $? -ne 0 ]; then
            echo "ERROR in computation of climatological monthly mean: $NCRA -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat ${filenames[*]} $mon_avg_file"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
	fi
    done
    wait
    # COMPUTE ANNUAL MEAN
    echo "Climatological weighted annual mean"
    $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -p $climodir ${mon_avg_files[*]} $ann_avg_file
    if [ $? -ne 0 ]; then
	echo "ERROR in computation of climatological annual mean: $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -p $climodir ${mon_avg_files[*]} $ann_avg_file"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    # MOVE MONTHLY FILE
    if [ ! -d $climodir/mon_climo ]; then
	mkdir -p $climodir/mon_climo
    fi
    for month in 01 02 03 04 05 06 07 08 09 10 11 12
    do
	mv $climodir/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc $climodir/mon_climo
	if [ $? -ne 0 ]; then
	    echo "ERROR: could not move $climodir/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc to $climodir/mon_seas/"
	    exit 1
	fi
    done
fi

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "CLIMO RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
