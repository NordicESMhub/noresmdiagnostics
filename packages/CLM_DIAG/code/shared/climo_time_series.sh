#!/bin/bash
#set -x

# CLM DIAGNOSTICS package: climo_time_series.sh
# PURPOSE: compute climatology and time-series of a case
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Apr 2018

# Input arguments:
#  $casename          simulation name
#  $fyr_climo         first yr climatology
#  $lyr_climo         last yr climatology
#  $fyr_ts            first yr time series
#  $lyr_ts            last yr time series
#  $trends_all        compute time series over entire simulation
#  $pathdat_root      directory of monthly history files
#  $c_climo_clm       compute clm climatology switch
#  $c_climo_cam       compute clm climatology switch
#  $c_ts              compute time series switch
#  $climo_dir_lnd     directory of clm climo and time series files
#  $climo_dir_atm     directory of cam climo files
#  $procdir_lnd       work directory (clm)
#  $procdir_atm       work directory (cam)
#  $diag_shared       script directory

casename=$1
fyr_climo=$2
lyr_climo=$3
fyr_ts=$4
lyr_ts=$5
trends_all=$6
pathdat_root=$7
c_climo_clm=$8
c_climo_cam=$9
c_ts=${10}
climo_dir_lnd=${11}
climo_dir_atm=${12}
procdir_lnd=${13}
procdir_atm=${14}
diag_shared=${15}

echo " "
echo "-----------------------"
echo "climo_time_series.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename      = $casename"
echo " fyr_climo     = $fyr_climo"
echo " lyr_climo     = $lyr_climo"
echo " fyr_ts        = $fyr_ts"
echo " lyr_ts        = $lyr_ts"
echo " trends_all    = $trends_all"
echo " pathdat_root  = $pathdat_root"
echo " c_climo_clm   = $c_climo_clm"
echo " c_climo_cam   = $c_climo_cam"
echo " c_ts          = $c_ts"
echo " climo_dir_lnd = $climo_dir_lnd"
echo " climo_dir_atm = $climo_dir_atm"
echo " procdir_lnd   = $procdir_lnd"
echo " procdir_atm   = $procdir_atm"
echo " diag_shared   = $diag_shared"
echo " "

NCAP2=`which ncap2`
if [ $? -ne 0 ]; then
    echo "Could not find ncap2 (which ncap2)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

required_vars_climo_clm="TSA,RAIN,SNOW,FSR,FSDS,FSA,FIRA,FCTR,FCEV,FGEV,QOVER,QDRAI,QRGWL,SNOWDP,FPSN,FSH,FSH_V,FSH_G,TV,TG,TSNOW,SABV,SABG,FIRE,FGR,FSM,TAUX,TAUY,ELAI,ESAI,TLAI,TSAI,LAISUN,LAISHA,BTRAN2,H2OSNO,H2OCAN,SNOWLIQ,SNOWICE,QINFL,QINTR,QDRIP,QSNOMELT,QSOIL,QVEGE,QVEGT,ERRSOI,ERRSEB,FSNO,ERRSOL,ERRH2O,TBOT,TLAKE,WIND,THBOT,QBOT,ZBOT,FLDS,FSDSNDLN,FSDSNI,FSDSVD,FSDSVDLN,FSDSVI,FSDSND,FSRND,FSRNDLN,FSRNI,FSRVD,FSRVDLN,FSRVI,Q2M,TREFMNAV,TREFMXAV,SOILLIQ,SOILICE,H2OSOI,TSOI,WA,WT,ZWT,QCHARGE,FCOV,PCO2,NEE,GPP,NPP,AR,HR,NEP,ER,SUPPLEMENT_TO_SMINN,SMINN_LEACHED,COL_FIRE_CLOSS,COL_FIRE_NLOSS,PFT_FIRE_CLOSS,PFT_FIRE_NLOSS,FIRESEASONL,FIRE_PROB,ANN_FAREA_BURNED,MEAN_FIRE_PROB,PBOT,landfrac,area"
required_vars_climo_cam="T,Q,Z3"
required_vars_ts="TSA,RAIN,SNOW,TSOI,FPSN,ELAI,ESAI,TLAI,TSAI,LAISUN,LAISHA,BTRAN2,QINFL,QOVER,QRGWL,QDRAI,QINTR,QSOIL,QVEGT,SOILLIQ,SOILICE,SOILPSI,SNOWLIQ,SNOWICE,WA,ZWT,QCHARGE,FCOV,PCO2,NEE,landfrac,area,FSR,PBOT,SNOWDP,FSDS,FSA,FLDS,FIRE,FIRA,FSH,FCTR,FCEV,FGEV,FGR,WT"
# append vars for snow and dust depostion
required_vars_climo_clm="$required_vars_climo_clm,SNOBCMCL,SNOBCMSL,SNODSTMCL,SNODSTMSL,SNOOCMCL,SNOOCMSL,BCDEP,DSTDEP,OCDEP"
# append vars from master_set1.txt (include dust deposit)
required_vars_ts="$required_vars_ts,$(cat ${WKDIR}master_set1.txt |awk -F" " '{print $NF}' |tr '\n' , |sed 's/,$//')"
# remove duplicated entries
required_vars_ts=$(echo $required_vars_ts |sed 's/,/\n/g' |sort | uniq | tr '\n' , |sed 's/,$//')

fyr_prnt_climo=`printf "%04d" ${fyr_climo}`
lyr_prnt_climo=`printf "%04d" ${lyr_climo}`

if [ $c_climo_clm -eq 0 ] && [ $c_climo_cam -eq 0 ] && [ $c_ts -eq 0 ]; then
    echo "ERROR: all available sets (1-6) are zero. Please modify."
    echo "***EXITING THE SCRIPT***"
    exit 1
fi

## Compute CLM climo
if [ $c_climo_clm -eq 1 ]; then
    climo_ts_dir=$climo_dir_lnd
    pathdat=$pathdat_root/$casename/lnd/hist
    model=clm2
    procdir=$procdir_lnd
    # Check if climo files already exist
    file_exist=1
    for seas in ANN DJF MAM JJA SON MON
    do
	TEST_FILE=$climo_ts_dir/${casename}_${seas}_${fyr_prnt_climo}-${lyr_prnt_climo}_climo.nc
	if [ ! -f $TEST_FILE ]; then
	    file_exist=0
	fi
    done
    if [ $file_exist -eq 0 ]; then
	echo $required_vars_climo_clm > $procdir/required_vars
	$diag_shared/check_history_vars.sh $casename $fyr_climo $lyr_climo $pathdat $model $procdir climo
	if [ -f $procdir/vars_climo_${model} ]; then
            $diag_shared/compute_climo.sh $casename $fyr_climo $lyr_climo $pathdat $climo_ts_dir $procdir $model
	else
	    echo "ERROR: no clm climo variables found."
	    echo "***EXITING THE SCRIPT***"
	    exit 1
        fi
    else
	echo "CLIMATOLOGY FILES ALREADY EXIST: SKIPPING $model CLIMATOLOGY COMPUTATION."
    fi
    ## Create symbolic links
    if [ -L $climo_ts_dir/${casename}_MONS_climo.nc ]; then
        rm $climo_ts_dir/${casename}_MONS_climo.nc
    fi
    echo "Creating symbolic links."
    ln -s $climo_ts_dir/${casename}_MON_${fyr_prnt_climo}-${lyr_prnt_climo}_climo.nc $climo_ts_dir/${casename}_MONS_climo.nc
    for seas in ANN DJF MAM JJA SON
    do
	outfile=$climo_ts_dir/${casename}_${seas}_${fyr_prnt_climo}-${lyr_prnt_climo}_climo.nc
        if [ -L $climo_ts_dir/${casename}_${seas}_climo.nc ]; then
	    rm $climo_ts_dir/${casename}_${seas}_climo.nc
        fi
	ln -s $outfile $climo_ts_dir/${casename}_${seas}_climo.nc
    done
fi

## Compute CAM climo
if [ $c_climo_cam -eq 1 ]; then
    climo_ts_dir=$climo_dir_atm
    pathdat=$pathdat_root/$casename/atm/hist
    model=cam
    procdir=$procdir_atm
    filename_atm=${pathdat}/${casename}.${model}.h0.${fyr_prnt_climo}-07.nc
    if [ ! -f $filename_atm ]; then
	model=cam2
	filename_atm=${pathdat}/${casename}.${model}.h0.${fyr_prnt_climo}-07.nc
	if [ ! -f $filename_atm ]; then
	    echo "ERROR: test file $filename_atm does not exist."
	    echo "***EXITING THE SCRIPT***"
	    exit 1
	fi
    fi
    # Check if climo files already exist
    file_exist=1
    for seas in ANN DJF MAM JJA SON MON
    do
	TEST_FILE=$climo_ts_dir/${casename}_${seas}_${fyr_prnt_climo}-${lyr_prnt_climo}_climo.nc
	if [ ! -f $TEST_FILE ]; then
	    file_exist=0
	fi
    done
    if [ $file_exist -eq 0 ]; then
	echo $required_vars_climo_cam > $procdir/required_vars
	$diag_shared/check_history_vars.sh $casename $fyr_climo $lyr_climo $pathdat $model $procdir climo
	if [ -f $procdir/vars_climo_${model} ]; then
            $diag_shared/compute_climo.sh $casename $fyr_climo $lyr_climo $pathdat $climo_ts_dir $procdir $model
	else
	    echo "ERROR: no cam climo variables found."
	    echo "***EXITING THE SCRIPT***"
	    exit 1
        fi
    else
	echo "CLIMATOLOGY FILES ALREADY EXIST: SKIPPING $model CLIMATOLOGY COMPUTATION."
    fi
    # Create symbolic links
    if [ -L $climo_ts_dir/${casename}_MONS_climo_atm.nc ]; then
        rm $climo_ts_dir/${casename}_MONS_climo_atm.nc
    fi
    echo "Creating symbolic links."
    ln -s $climo_ts_dir/${casename}_MON_${fyr_prnt_climo}-${lyr_prnt_climo}_climo.nc $climo_ts_dir/${casename}_MONS_climo_atm.nc
    for seas in ANN DJF MAM JJA SON
    do
	outfile=$climo_ts_dir/${casename}_${seas}_${fyr_prnt_climo}-${lyr_prnt_climo}_climo.nc
	if [ -L $climo_ts_dir/${casename}_${seas}_climo_atm.nc ]; then
	    rm $climo_ts_dir/${casename}_${seas}_climo_atm.nc
	fi
	ln -s $outfile $climo_ts_dir/${casename}_${seas}_climo_atm.nc
    done
fi

if [ $c_ts -eq 1 ]; then
    climo_ts_dir=$climo_dir_lnd
    pathdat=$pathdat_root/$casename/lnd/hist
    model=clm2
    procdir=$procdir_lnd
    if [ $trends_all -eq 1 ]; then
	echo "trends_all=1: computing time series over entire simulation."
	echo "Searching for monthly history files..."
	file_head=$casename.clm2.h0.
	file_prefix=$pathdat/$file_head
	first_file=`ls ${file_prefix}????-??.nc | head -n 1`
	last_file=`ls ${file_prefix}????-??.nc | tail -n 1`
	if [ -z $first_file ]; then
            echo "ERROR: found no monthly history files in $pathdat"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
	else
            fyr_prnt_ts=$(basename $first_file |awk -F"." '{print $(NF-1)}' |cut -d'-' -f1)
            fyr_ts=`echo $fyr_prnt_ts | sed 's/^0*//'`
            lyr_prnt_ts=$(basename $last_file |awk -F"." '{print $(NF-1)}' |cut -d'-' -f1)
            lyr_ts=`echo $lyr_prnt_ts | sed 's/^0*//'`
            # Check that last file is a december file (for a full year)
            if [ "$last_file" != "$pathdat/${file_head}${lyr_prnt_ts}-12.nc" ]; then
		let "lyr_ts = $lyr_ts - 1"
            fi
            if [ $fyr_ts -eq $lyr_ts ]; then
                echo "ERROR: first and last year in $casename are identical: cannot compute trends"
                echo "*** EXITING THE SCRIPT ***"
                exit 1
            fi
	fi
	echo "fyr_ts = $fyr_ts"
	echo "lyr_ts = $lyr_ts"
    fi
    fyr_prnt_ts=`printf "%04d" ${fyr_ts}`
    lyr_prnt_ts=`printf "%04d" ${lyr_ts}`    
    TEST_FILE=$climo_ts_dir/${casename}_ANN_${fyr_prnt_ts}-${lyr_prnt_ts}_ts.nc
    if [ ! -f $TEST_FILE ]; then
	echo $required_vars_ts > $procdir/required_vars
	$diag_shared/check_history_vars.sh $casename $fyr_ts $lyr_ts $pathdat $model $procdir ts
	if [ -f $procdir/vars_ts_${model} ]; then
	    $diag_shared/compute_ann_time_series.sh $casename $fyr_ts $lyr_ts $pathdat $climo_ts_dir $procdir
	fi
    else
	echo "TIME-SERIES FILE ALREADY EXISTS: SKIPPING $model TIME-SERIES COMPUTATION."
    fi
    let "nyrs_ts = $lyr_ts - fyr_ts + 1"
    echo $fyr_ts > $procdir/fyr_ts
    echo $nyrs_ts > $procdir/nyrs_ts
    if [ -L $climo_ts_dir/${casename}_ANN_ALL.nc ]; then
        rm $climo_ts_dir/${casename}_ANN_ALL.nc
    fi
    ln -s $climo_ts_dir/${casename}_ANN_${fyr_prnt_ts}-${lyr_prnt_ts}_ts.nc $climo_ts_dir/${casename}_ANN_ALL.nc
fi

