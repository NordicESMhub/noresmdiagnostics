#!/bin/bash

script_start=`date +%s`
#
# HAMOCC DIAGNOSTICS package: compute_ann_time_series.sh
# PURPOSE: computes annual time series from annual or monthly history files
# Johan Liakka
# Yanchun He, NERSC
# Last update Oct 2018

# STRATEGY: Split the data into chucks of 10 years each.
# Run the 10 chunk year in parallel for 3D operations

# Input arguments:
#  $filetype  hbgcm or hbgcy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $tsdir     directory where the climatology files are located

filetype=$1
casename=$2
first_yr=$3
last_yr=$4
pathdat=$5
tsdir=$6

echo " "
echo "---------------------------"
echo "compute_ann_time_series.sh"
echo "---------------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " tsdir    = $tsdir"
echo " "

var_list=`cat $WKDIR/attributes/vars_ts_ann_${casename}_${filetype}`
first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
ann_ts_file=${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts_ann_${filetype}.nc

# Calculate number of chunks and the residual
nproc=10
let "nyrs = $last_yr - $first_yr + 1"
let "nchunks = $nyrs / $nproc"
let "residual = $nyrs % $nproc"

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
    if [ $filetype == hbgcy ]; then
        # Extract variables from annual file if in hbgcy mode
        echo "Extracting time-series variables from annual history files (yrs ${YR_start}-${YR_end})"
        while [ $iproc -le $nyrs ]
        do
            let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
            yr_prnt=`printf "%04d" ${YR}`
            filename=${casename}.micom.hbgcy.${yr_prnt}.nc

            fflag=1     #check if all required annual ts files exist
            for var in $(echo $var_list | sed 's/,/ /g'|sed 's/pddpo//') ; do
                tsfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ ! -f  $tsdir/ann_ts/${tsfile} ]; then
                    echo "$tsdir/ann_ts/${tsfile} does not exist, ncks required variables..."
                    fflag=0
                    break
                fi
            done
            if [ $fflag  = 0 ]; then
                eval $NCKS -O -v $var_list --no_tmp_fl $pathdat/$filename $WKDIR/${casename}_ANN_${yr_prnt}.nc &
                pid+=($!)
            else
                echo Skip computing year ${yr_prnt}, time-series variables already exist.
            fi

            let iproc++
        done
        for ((m=0;m<${#pid[*]};m++))
        do
            wait ${pid[$m]}
            if [ $? -ne 0 ]; then
                echo "ERROR in extracting variables from annual history file: $NCKS -O -v $var_list --no_tmp_fl $pathdat/$filename $WKDIR/${casename}_ANN_${yr_prnt}.nc"
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
        done
        wait
    else 
        # Compute annual means if in hbgcm mode
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
                filename=${casename}.micom.hbgcm.${yr_prnt}-${mon}.nc
                filenames+=($filename)
            done
            fflag=1     #check if all required annual ts files exist
            for var in $(echo $var_list | sed 's/,/ /g'|sed 's/pddpo//') ; do
                tsfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ ! -f  $tsdir/ann_ts/${tsfile} ]; then
                    echo "$tsdir/ann_ts/${tsfile} does not exist"
                    fflag=0
                    break
                fi
            done
            if [ $fflag  = 0 ]; then
                eval $NCRA -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v $var_list -p $pathdat ${filenames[*]} $WKDIR/${casename}_ANN_${yr_prnt}.nc &
                pid+=($!)
            else
                echo Skip computing year ${yr_prnt}, time-series variables already exist.
            fi
            let iproc++
        done
               for ((m=0;m<${#pid[*]};m++))
        do
            wait ${pid[$m]}
            if [ $? -ne 0 ]; then
                echo "ERROR in computing annual means from monthly history files: $NCRA -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v $var_list -p $pathdat $filenames $WKDIR/${casename}_ANN_${yr_prnt}.nc"
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
        done
        wait
    fi
    # Append parea if necessary
    iproc=1
    echo "Appending parea to annual files (yrs ${YR_start}-${YR_end})"
    while [ $iproc -le $nyrs ]
    do
        let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
        yr_prnt=`printf "%04d" ${YR}`
        filename=${casename}_ANN_${yr_prnt}.nc
        if [ -f $WKDIR/$filename ]; then
            $NCKS --quiet -d depth,0 -d x,0 -d y,0 -v parea $WKDIR/$filename >/dev/null 2>&1
        fi
        if [ $? -ne 0 ]; then
            $NCKS -A -v parea -o $WKDIR/$filename $grid_file
        fi
        let iproc++
    done
    # Loop over variables and do some averaging...
    for var in `echo $var_list | sed 's/,/ /g'`
    do
        # Mass weighted 3D averaging of nutrients
        if [ $var == o2 ] || [ $var == si ] || [ $var == po4 ] || \
           [ $var == no3 ] || [ $var == dissic ]; then
            echo "Mass weighted global average of $var (yrs ${YR_start}-${YR_end})"
            pid=()
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    eval $NCWA --no_tmp_fl -O -v $var -w pddpo -a sigma,y,x $WKDIR/$infile $WKDIR/$outfile &
                    pid+=($!)
                fi
                let iproc++
            done
            for ((m=0;m<${#pid[*]};m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in calculating mass weighted global average: $NCWA --no_tmp_fl -O -v $var -w pddpo -a sigma,y,x $WKDIR/$infile $WKDIR/$outfile"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
        fi
        # Export production
        if [ $var == epc100 ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'epc100_area=epc100*parea' $WKDIR/$infile $WKDIR/$outfile_tmp
                    $NCAP2 -O -s 'epc100_tot=epc100_area.total($x,$y)*12.011*86400.0*365.0*1.0e-15' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
                    $NCKS --no_tmp_fl -O -v epc100_tot $WKDIR/$outfile_tmp $WKDIR/$outfile
                    rm -f $WKDIR/$outfile_tmp
                fi
                let iproc++
            done
        fi
        # Export CaCO3
        if [ $var == epcalc100 ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'epcalc100_area=epcalc100*parea' $WKDIR/$infile $WKDIR/$outfile_tmp
                    $NCAP2 -O -s 'epcalc100_tot=epcalc100_area.total($x,$y)*12.0*86400.0*365.0*1.0e-15' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
                    $NCKS --no_tmp_fl -O -v epcalc100_tot $WKDIR/$outfile_tmp $WKDIR/$outfile
                    rm -f $WKDIR/$outfile_tmp
                fi
                let iproc++
            done
        fi
        # Total downward co2 flux
        if [ $var == co2fxd ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'co2fxd_area=co2fxd*parea' $WKDIR/$infile $WKDIR/$outfile_tmp
                    $NCAP2 -O -s 'co2fxd_tot=co2fxd_area.total($x,$y)*86400.0*365.0*1.0e-12' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
                    $NCKS --no_tmp_fl -O -v co2fxd_tot $WKDIR/$outfile_tmp $WKDIR/$outfile
                    rm -f $WKDIR/$outfile_tmp
                fi
                let iproc++
            done
        fi
        # Total upward co2 flux
        if [ $var == co2fxu ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'co2fxu_area=co2fxu*parea' $WKDIR/$infile $WKDIR/$outfile_tmp
                    $NCAP2 -O -s 'co2fxu_tot=co2fxu_area.total($x,$y)*86400.0*365.0*1.0e-12' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
                    $NCKS --no_tmp_fl -O -v co2fxu_tot $WKDIR/$outfile_tmp $WKDIR/$outfile
                    rm -f $WKDIR/$outfile_tmp
                fi
                let iproc++
            done
        fi
        # Total DMS flux
        if [ $var == dmsflux ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'dmsflux_area=dmsflux*parea' $WKDIR/$infile $WKDIR/$outfile_tmp
                    $NCAP2 -O -s 'dmsflux_tot=dmsflux_area.total($x,$y)*86400.0*365.0*62.13*1.0e-12' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
                    $NCKS --no_tmp_fl -O -v dmsflux_tot $WKDIR/$outfile_tmp $WKDIR/$outfile
                    rm -f $WKDIR/$outfile_tmp
                fi
                let iproc++
            done
        fi
        # Total primary production
        if [ $var == pp ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            pid=()
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    eval $NCAP2 -O -s 'pp_vol=pp*parea*pddpo' $WKDIR/$infile $WKDIR/$outfile_tmp &
                    pid+=($!)
                fi
                let iproc++
            done
            for ((m=0;m<${#pid[*]};m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in calculating pp_vol: $NCAP2 -O -s 'pp_vol=pp*parea*pddpo' $WKDIR/$infile $WKDIR/$outfile_tmp"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            pid=()
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'pp_tot=pp_vol.total($sigma,$y,$x)*12.0*86400.0*365.0*1.0e-15' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp &
                    pid+=($!)
                fi
                let iproc++
            done
            for ((m=0;m<${#pid[*]};m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in calculating pp_tot: $NCAP2 -O -s 'pp_tot=pp_vol.total($x,$y,$sigma)*12.0*86400.0*365.0*1.0e-15' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            pid=()
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    eval $NCKS --no_tmp_fl -O -v pp_tot $WKDIR/$outfile_tmp $WKDIR/$outfile &
                    pid+=($!)
                fi
                let iproc++
            done
            for ((m=0;m<${#pid[*]};m++))
            do
                wait ${pid[$m]}
                if [ $? -ne 0 ]; then
                    echo "ERROR in calculating pp_tot: $NCAP2 -O -s 'pp_tot=pp_vol.total($x,$y,$sigma)*12.0*86400.0*365.0*1.0e-15' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp"
                    echo "*** EXITING THE SCRIPT ***"
                    exit 1
                fi
            done
            wait
            # Clean tmp files
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                outfile_tmp=${var}_${casename}_ANN_${yr_prnt}_tmp.nc
                rm -f $WKDIR/$outfile_tmp
                let iproc++
            done
        fi
        # Total primary production (ppint, model output)
        if [ $var == ppint ]; then
            echo "Total $var (yrs ${YR_start}-${YR_end})"
            iproc=1
            while [ $iproc -le $nyrs ]
            do
                let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
                yr_prnt=`printf "%04d" ${YR}`
                infile=${casename}_ANN_${yr_prnt}.nc
                outfile_tmp=${var}_${casename}_ANN_${filetype}_${yr_prnt}_tmp.nc
                outfile=${var}_${casename}_ANN_${filetype}_${yr_prnt}.nc
                if [ -f $WKDIR/$infile ] && [ ! -f $tsdir/ann_ts/$outfile ]; then
                    $NCAP2 -O -s 'ppint_area=ppint*parea' $WKDIR/$infile $WKDIR/$outfile_tmp
                    $NCAP2 -O -s 'ppint_tot=ppint_area.total($x,$y)*86400.0*365.0*12*1.0e-15' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
                    $NCKS --no_tmp_fl -O -v ppint_tot $WKDIR/$outfile_tmp $WKDIR/$outfile
                    rm -f $WKDIR/$outfile_tmp
                fi
                let iproc++
            done
        fi
    done
    # clean up
    iproc=1
    while [ $iproc -le $nyrs ]
    do
        let "YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1"
        yr_prnt=`printf "%04d" ${YR}`
        filename=${casename}_ANN_${yr_prnt}.nc
        if [ -f  $WKDIR/$filename ]; then
            rm -f $WKDIR/$filename
        fi
        let iproc++
    done
    let ichunk++
done

# Concancate files
if [ ! -d $tsdir/ann_ts ]; then
    mkdir -p $tsdir/ann_ts
fi
let "nyrs = $last_yr - $first_yr + 1"
first_var=1
for var in `echo $var_list | sed 's/,/ /g'`
do
    mv $WKDIR/${var}_${casename}_ANN_${filetype}_*.nc $tsdir/ann_ts/ >/dev/null 2>&1
    first_file=${var}_${casename}_ANN_${filetype}_${first_yr_prnt}.nc
    if [ -f $tsdir/ann_ts/$first_file ]; then
        echo "Merging all $var time series files..."
        #$NCRCAT -3 --no_tmp_fl -O $WKDIR/${var}_${casename}_ANN_????.nc $WKDIR/${var}_${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}.nc
        $NCRCAT -3 --no_tmp_fl -O -p $tsdir/ann_ts -n ${nyrs},4,1 ${first_file} -o $WKDIR/${var}_${casename}_ANN_${filetype}_${first_yr_prnt}-${last_yr_prnt}.nc
        if [ $? -eq 0 ]; then
            if [ $first_var -eq 1 ]; then
                first_var=0
                mv $WKDIR/${var}_${casename}_ANN_${filetype}_${first_yr_prnt}-${last_yr_prnt}.nc $tsdir/$ann_ts_file
            else
                $NCKS -A -o $tsdir/$ann_ts_file $WKDIR/${var}_${casename}_ANN_${filetype}_${first_yr_prnt}-${last_yr_prnt}.nc
                rm -f $WKDIR/${var}_${casename}_ANN_${filetype}_${first_yr_prnt}-${last_yr_prnt}.nc
            fi
        else
            echo "ERROR: $NCRCAT -3 --no_tmp_fl -O $WKDIR/${var}_${casename}_ANN_????.nc $WKDIR/${var}_${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}.nc"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
        rm -f $WKDIR/${var}_${casename}_ANN_*.nc
    fi
done

script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "ANNUAL TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
