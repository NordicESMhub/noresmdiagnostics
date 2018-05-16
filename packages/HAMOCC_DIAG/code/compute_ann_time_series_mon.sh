#!/bin/bash

script_start=`date +%s`
#
# HAMOCC DIAGNOSTICS package: compute_ann_time_series_mon.sh
# PURPOSE: computes annual from monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $tsdir     directory where the climatology files are located

casename=$1
first_yr=$2
last_yr=$3
pathdat=$4
tsdir=$5

echo " "
echo "-------------------------------"
echo "compute_ann_time_series_mon.sh"
echo "-------------------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " tsdir    = $tsdir"
echo " "

var_list=`cat $WKDIR/attributes/vars_ts_mon_${casename}_hbgcm`
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
ann_ts_file=${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts_mon.nc
ann_ts_file_others=${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts_mon_others.nc
ann_ts_file_pp=${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts_mon_pp.nc

if [ -z $PGRIDPATH ]; then
    grid_file=$DIAG_GRID/`cat $WKDIR/attributes/grid_${casename}`/grid.nc
else
    grid_file=$PGRIDPATH/grid.nc
fi
if [ ! -f $grid_file ]; then
    echo "ERROR: grid file $grid_file doesn't exist."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

# First do all variables except pp
var_list_others=""
var_list_pp=""
if `echo $var_list | grep -q ,pp`
then
    var_list_others=`echo $var_list | sed "s/,pp//g"`
    var_list_pp=pp,pddpo
fi
if `echo $var_list | grep -q pp,`
then
    var_list_others=`echo $var_list | sed "s/pp,//g"`
    var_list_pp=pp,pddpo
fi
if `echo $var_list | grep -q pp`
then
    var_list_pp=pp,pddpo
fi

if [ ! -f $tsdir/$ann_ts_file_others ]; then
    if [ ! -z $var_list_others ]; then
        iyear=$first_yr
        while [ $iyear -le $last_yr ]
        do
            yr_prnt=`printf "%04d" ${iyear}`
            echo "Annual means from monthly history files (yr=$yr_prnt)"
            pid=()
            monfiles=()
            # Compute global averages for each month
            for mon in 01 02 03 04 05 06 07 08 09 10 11 12
            do
                infile=${casename}.micom.hbgcm.${yr_prnt}-${mon}.nc
                outfile=${casename}_${yr_prnt}-${mon}_ts_mon.nc
                monfiles+=($outfile)
                eval $NCWA --no_tmp_fl -O -v $var_list_others -w pddpo -a sigma,y,x $pathdat/$infile $WKDIR/$outfile &
                pid+=($!)
            done
            for ((m=0;m<=11;m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in computing annual means from monthly history files: $NCWA --no_tmp_fl -O -v $var_list -w pddpo -a sigma,y,x $pathdat/$infile $WKDIR/$outfile"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            # Compute annual means from monthly means
            $NCRA -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v $var_list_others -p $WKDIR ${monfiles[*]} $WKDIR/${casename}_ANN_${yr_prnt}_ts_mon.nc
            # Clean monthly files
            rm -f $WKDIR/${casename}_${yr_prnt}-*_ts_mon.nc
            let iyear++
        done
        # Concancate files
        echo "Merging all annual time series files..."
        $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_ANN_????_ts_mon.nc $tsdir/$ann_ts_file_others
        if [ $? -ne 0 ]; then
            echo "ERROR in merging annual time series files: $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_ANN_????_ts_mon.nc $tsdir/$ann_ts_file_others"
            exit 1
        fi
        # Cleaning
        rm -f $WKDIR/${casename}_ANN_*_ts_mon.nc
    else
        echo "WARNING: variables $var_list_others not in monthly history files"
    fi
else
    echo "$tsdir/$ann_ts_file_others already exists."
fi

# Compute pp
if [ ! -f $tsdir/$ann_ts_file_pp ]; then
    if [ ! -z $var_list_pp ]; then
        iyear=$first_yr
        while [ $iyear -le $last_yr ]
        do
            yr_prnt=`printf "%04d" ${iyear}`
            echo "Annual total pp from monthly history files (yr=$yr_prnt)"
            # Take out pp from monthly history files
            pid=()
            monfiles=()
            for mon in 01 02 03 04 05 06 07 08 09 10 11 12
            do
                infile=${casename}.micom.hbgcm.${yr_prnt}-${mon}.nc
                outfile=${casename}_${yr_prnt}-${mon}.nc
                monfiles+=($outfile)            
                eval $NCKS -O -v $var_list_pp $pathdat/$infile $WKDIR/$outfile &
                pid+=($!)
            done
            for ((m=0;m<=11;m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in extracting pp from monthly history files: $NCKS -O -v $var_list_pp $pathdat/$infile $WKDIR/$outfile"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            # Append parea
            pid=()
            for mon in 01 02 03 04 05 06 07 08 09 10 11 12
            do
                    filename=${casename}_${yr_prnt}-${mon}.nc
                eval $NCKS -A -v parea -o $WKDIR/$filename $grid_file &
                pid+=($!)
            done
            for ((m=0;m<=11;m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in appending parea to monthly files: $NCKS -A -v parea -o $WKDIR/$filename $grid_file"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            # Calculate total pp for every grid box (pp_vol)
            pid=()
            for mon in 01 02 03 04 05 06 07 08 09 10 11 12
            do
                filename=${casename}_${yr_prnt}-${mon}.nc
                eval $NCAP2 -O -s 'pp_vol=pp*parea*pddpo' $WKDIR/$filename $WKDIR/$filename &
                pid+=($!)
            done
            for ((m=0;m<=11;m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in calculating pp_vol: $NCAP2 -O -s 'pp_vol=pp*parea*pddpo' $WKDIR/$filename $WKDIR/$filename"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            # Calculate global pp (pp_tot)
            pid=()
            for mon in 01 02 03 04 05 06 07 08 09 10 11 12
            do
                filename=${casename}_${yr_prnt}-${mon}.nc
                $NCAP2 -O -s 'pp_tot=pp_vol.total($sigma,$y,$x)*12.0*86400.0*365.0*1.0e-15' $WKDIR/$filename $WKDIR/$filename &
                pid+=($!)
            done
            for ((m=0;m<=11;m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in calculating pp_tot: $NCAP2 -O -s 'pp_tot=pp_vol.total($x,$y,$sigma)*12.0*86400.0*365.0*1.0e-15' $WKDIR/$filename $WKDIR/$filename"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            # Calculate annual mean
            $NCRA -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v pp_tot -p $WKDIR ${monfiles[*]} $WKDIR/${casename}_${yr_prnt}.nc        
            # Clean monthly files
            rm -f $WKDIR/${casename}_${yr_prnt}-*.nc
            let iyear++
        done
    else
        echo "WARNING: variable pp does not exist in monthly history files."
    fi
    # Merging all files
    echo "Merging all annual pp time series files..."
    $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_????.nc $tsdir/$ann_ts_file_pp
    if [ $? -ne 0 ]; then
        echo "ERROR in merging annual pp time series files: $NCRCAT --no_tmp_fl -O $WKDIR/${casename}_????.nc $tsdir/$ann_ts_file_pp"
        exit 1
    fi
    # Cleaning
    rm -f $WKDIR/${casename}_*.nc
    # Change pp_tot unit
    $NCATTED -O -a units,pp_tot,m,c,"Pg yr-1" $tsdir/$ann_ts_file_pp
else
    echo "$tsdir/$ann_ts_file_pp already exists."
fi

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "ANNUAL TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
