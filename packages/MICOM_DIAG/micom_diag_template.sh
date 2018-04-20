#!/bin/bash
#
# MICOM DIAGNOSTICS package
# Johan Liakka, NERSC, johan.liakka@nersc.no
# built upon previous work by Detelina Ivanova
# Last update Feb 2018
# set -e
export NCARG_ROOT=/opt/ncl64
export PATH=/opt/ncl64/bin/:/usr/local/bin:/usr/bin
#***************************
#*** USER MODIFY SECTION ***
#***************************
time_start_script=`date +%s`
# ---------------------------------------------------------
# TEST CASENAME AND YEARS TO BE AVERAGED (CASE1)
# ---------------------------------------------------------
CASENAME1=your_test_simulation
FIRST_YR_CLIMO1=fyr_of_test
NYRS_CLIMO1=nyr_of_test

# ---------------------------------------------------------
# TIME SERIES SETTING FOR TEST CASE (CASE1)
# ---------------------------------------------------------
# If TRENDS_ALL=1 the time series is computed over the
# entire simulation; otherwise between first_yr_ts
# and last_yr_ts
TRENDS_ALL=ts_all_switch
FIRST_YR_TS1=fyr_of_ts_test
LAST_YR_TS1=lyr_of_ts_test

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE1)
# ---------------------------------------------------------
pathdat_root1=/path/to/test_case/history
PATHDAT1=$pathdat_root1/$CASENAME1/ocn/hist

# ---------------------------------------------------------
# SELECT TYPE OF CONTROL CASE
# NOTE: CNTL=USER IS NOT YET SUPPORTED
# ---------------------------------------------------------
CNTL=type_of_control_case   # compare case1 to another experiment case2 (model-model diagnostics)

# ---------------------------------------------------------
# CNTL CASENAME AND YEARS TO BE AVERAGED (CASE2)
# ---------------------------------------------------------
CASENAME2=your_cntl_simulation
FIRST_YR_CLIMO2=fyr_of_cntl
NYRS_CLIMO2=nyr_of_cntl

# ---------------------------------------------------------
# TIME SERIES SETTING FOR CNTL CASE (CASE2)
# ---------------------------------------------------------
FIRST_YR_TS2=fyr_of_ts_cntl
LAST_YR_TS2=lyr_of_ts_cntl

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE2)
# ---------------------------------------------------------
pathdat_root2=/path/to/cntl_case/history
PATHDAT2=$pathdat_root2/$CASENAME2/ocn/hist

# ---------------------------------------------------------
# SELECT DIRECTORY WHERE THE DIAGNOSTICS ARE TO BE COMPUTED
# ---------------------------------------------------------
DIAG_ROOT=/path/to/your/diagnostics

# ---------------------------------------------------------
# SELECT SETS (1-5)
# ---------------------------------------------------------
set_1=1 # (1=ON,0=OFF) Annual time series plots
set_2=1 # (1=ON,0=OFF) ENSO indices
set_3=1 # (1=ON,0=OFF) 2D (lat-lon) climatology plots
set_4=1 # (1=ON,0=OFF) MOCs for different regions
set_5=1 # (1=ON,0=OFF) Zonal mean (lat-depth) plot
set_6=1 # (1=ON,0=OFF) Equatorial (lon-depth) plots
set_7=1 # (1=ON,0=OFF) Meridional fluxes vs. lat

# ---------------------------------------------------------
# NINO SST INDICES
# ---------------------------------------------------------
# Select the Nino SST indices to plot for set_2.
# Currently supported options: 3, 34 (nino 3, 3.4).
NINO_INDICES=3,34

# ---------------------------------------------------------
# SELECT GRID FILE (OPTIONAL)
# ---------------------------------------------------------
# This package uses the following predefined grid files (grid.nc) for the diagnostics:
# gx1v5, gx1v6, gx3v7, tnx0.083v1, tnx0.25v1, tnx0.25v3, tnx0.25v4,
# tnx1.5v1, tnx1v1, tnx1v1 (LGM), tnx1v1 (MIS3), tnx1v1 (PlioMIP2),
# tnx1v2, tnx1v3, tnx1v4 and tnx2v1.
# If your experiement has not used one of those grids,
# you may set the path (PGRIDPATH) to your own grid file here. 

#export PGRIDPATH=

# ---------------------------------------------------------
# WEB OPTIONS
# ---------------------------------------------------------
# Publish the html on the NIRD web server, and set the path
# where it should be published. If the path is left empty,
# it is set to /projects/NS2345K/www/noresm_diagnostics.
# The figures are converted to png. The quality of the
# figures is determined by the density variable.
publish_html=1 # (1=ON,0=OFF)
publish_html_root=/path/to/html/directory
density=150

# ---------------------------------------------------------
# SWITCH BETWEEN CLIMO AND TIME-SERIES COMPUTATION
# ---------------------------------------------------------
# Valid options: ONLY_CLIMO, ONLY_TIME_SERIES  AND
# SWITCHED_OFF (computes both).
CLIMO_TIME_SERIES_SWITCH=SWITCHED_OFF

# ---------------------------------------------------------
# ROOT DIRECTORY TO ALL THE DIAGNOSTICS SCRIPTS
# ---------------------------------------------------------
# Do not change this unless you copy the whole diagnostics
# package (including all grid files and observational data)
# to another directory.
export DIAG_HOME=/path/to/code/and/data

#**********************************
#*** END OF USER MODIFY SECTION ***
#**********************************

# Set environmental directories
export WKDIR=$DIAG_ROOT/diag/$CASENAME1
export DIAG_CODE=$DIAG_HOME/code
export DIAG_OBS=$DIAG_HOME/obs_data
export DIAG_HTML=$DIAG_HOME/html
export DIAG_GRID=$DIAG_HOME/grid_files
export DIAG_RGB=$DIAG_HOME/rgb

# Set bash-shell limits
ulimit -s unlimited
ulimit -d unlimited

# Check for NCL environment
if [ -z $NCARG_ROOT ]; then
    echo "ERROR: environment variable NCARG_ROOT is not set"
    echo "Do this in your .bashrc file (or whatever shell you use)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
else
    NCL=$NCARG_ROOT/bin/ncl
fi

# Check for .hluresfile in $HOME
if [ ! -e $HOME/.hluresfile ]; then
    echo "No .hluresfile present in $HOME"
    echo "Copying .hluresfile to $HOME"
    cp $DIAG_CODE/.hluresfile $HOME
fi

# Check for CDO
export CDO=`which cdo`
if [ $? -ne 0 ]; then
    echo "ERROR: CDO (Climate Data Operators) not found."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

# Check for NCO operators
export NCKS=`which ncks`
if [ $? -ne 0 ]; then
    echo "Could not find ncks (which ncks)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
export NCRA=`which ncra`
if [ $? -ne 0 ]; then
    echo "Could not find ncra (which ncra)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
export NCATTED=`which ncatted`
if [ $? -ne 0 ]; then
    echo "Could not find ncatted (which ncatted)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
export NCWA=`which ncwa`
if [ $? -ne 0 ]; then
    echo "Could not find ncwa (which ncwa)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
export NCAP2=`which ncap2`
if [ $? -ne 0 ]; then
    echo "Could not find ncap2 (which ncap2)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
export NCRCAT=`which ncrcat`
if [ $? -ne 0 ]; then
    echo "Could not find ncrcat (which ncrcat)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi
export NCRENAME=`which ncrename`
if [ $? -ne 0 ]; then
    echo "Could not find ncrename (which ncrename)"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

# Set directories for climatology and time series
CLIMO_TS_DIR1=$DIAG_ROOT/climo_ts/$CASENAME1
if [ $CNTL == USER ]; then
    CLIMO_TS_DIR2=$DIAG_ROOT/climo_ts/$CASENAME2
    diag_type=model1-model2
elif [ $CNTL == OBS ]; then
    CASENAME2=obs
    diag_type=model-obs
else
    echo "ERROR: CNTL must be set to either OBS or USER"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

# Create directories
if [ -d $WKDIR/attributes ]; then
    rm -rf $WKDIR/attributes
fi
mkdir -p $WKDIR/attributes
if [ ! -d $CLIMO_TS_DIR1 ]; then
    mkdir -p $CLIMO_TS_DIR1
fi

if [ $CNTL == USER ]; then
    if [ ! -d $CLIMO_TS_DIR2 ]; then
	mkdir -p $CLIMO_TS_DIR2
    fi
fi

# Set required variables for climatology and time series
required_vars_climo="depth_bnds,sealv,templvl,salnlvl,mmflxd,region,temp,saln,dz,sst,sss,mhflx,msflx"
required_vars_climo_ann="depth_bnds,sealv,templvl,salnlvl,mmflxd,region,mhflx,msflx"
required_vars_climo_mon="temp,saln,dz,sst,sss"
required_vars_ts_ann="depth_bnds,time,section,mmflxd,voltr,temp,saln,templvl,salnlvl,region,dp"

# Check which sets should be plotted based on CLIMO_TIME_SERIES_SWITCH
if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO ]; then
    set_1=0 ; set_2=0 ; set_3=1 ; set_4=1 ; set_5=1 ; set_6=1 ; set_7=1
elif [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
    set_1=1 ; set_2=1 ; set_3=0 ; set_4=0 ; set_5=0 ; set_6=0 ; set_7=0
    FIRST_YR_CLIMO1=0 ; NYRS_CLIMO1=0
    FIRST_YR_CLIMO2=0 ; NYRS_CLIMO2=0
fi
compute_climo=0
compute_time_series_ann=0
compute_time_series_mon=0
if [ $set_1 -eq 1 ]; then
    compute_time_series_ann=1
fi
if [ $set_2 -eq 1 ]; then
    compute_time_series_mon=1
fi
if [ $set_3 -eq 1 ] || [ $set_4 -eq 1 ] || [ $set_5 -eq 1 ] || [ $set_6 -eq 1 ] || [ $set_7 -eq 1 ]; then
    compute_climo=1
fi
if [ $set_1 -eq 0 ] && [ $set_2 -eq 0 ] && [ $set_3 -eq 0 ] && \
   [ $set_4 -eq 0 ] && [ $set_5 -eq 0 ] && [ $set_6 -eq 0 ] && [ $set_7 -eq 0 ]; then
    echo "ERROR: All sets are zero. Please modify."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

echo " "
echo "****************************************************"
echo "          MICOM DIAGNOSTICS PACKAGE"
echo "          NCARG_ROOT = "$NCARG_ROOT
echo "          CDO        = "$CDO
echo "          "`date`
echo "****************************************************"
echo "$diag_type diagnostics:"
echo "CASENAME1 = $CASENAME1"
echo "CASENAME2 = $CASENAME2"
echo "****************************************************"
echo "Selected sets:"
echo "set_1 = $set_1"
echo "set_2 = $set_2"
echo "set_3 = $set_3"
echo "set_4 = $set_4"
echo "set_5 = $set_5"
echo "set_6 = $set_6"
echo "set_7 = $set_7"

# Determine the first and last yr of time series (if TRENDS_ALL=1)
if [ $TRENDS_ALL -eq 1 ]; then
    $DIAG_CODE/determine_ts_yrs.sh $CASENAME1 $PATHDAT1
    if [ $? -ne 0 ]; then
	echo "ERROR in determine_ts_yrs.sh $CASENAME1 $PATHDAT1"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    FIRST_YR_TS1=`cat $WKDIR/attributes/ts_yrs_${CASENAME1} | head -n 1`
    LAST_YR_TS1=`cat $WKDIR/attributes/ts_yrs_${CASENAME1} | tail -n 1`
    echo "FIRST_YR_TS1 = ${FIRST_YR_TS1}"
    echo "LAST_YR_TS1  = ${LAST_YR_TS1}"
    if [ $CNTL == USER ]; then
	$DIAG_CODE/determine_ts_yrs.sh $CASENAME2 $PATHDAT2
	if [ $? -ne 0 ]; then
	    echo "ERROR in determine_ts_yrs.sh $CASENAME2 $PATHDAT2"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
	FIRST_YR_TS2=`cat $WKDIR/attributes/ts_yrs_${CASENAME2} | head -n 1`
	LAST_YR_TS2=`cat $WKDIR/attributes/ts_yrs_${CASENAME2} | tail -n 1`
	echo "FIRST_YR_TS2 = ${FIRST_YR_TS2}"
	echo "LAST_YR_TS2  = ${LAST_YR_TS2}"
    fi
fi

# Calculate climo last yr and define years with four digits
let "LAST_YR_CLIMO1 = $FIRST_YR_CLIMO1 + $NYRS_CLIMO1 - 1"
FYR_PRNT_CLIMO1=`printf "%04d" ${FIRST_YR_CLIMO1}`
LYR_PRNT_CLIMO1=`printf "%04d" ${LAST_YR_CLIMO1}`
FYR_PRNT_TS1=`printf "%04d" ${FIRST_YR_TS1}`
LYR_PRNT_TS1=`printf "%04d" ${LAST_YR_TS1}`
if [ $CNTL == USER ]; then
    let "LAST_YR_CLIMO2 = $FIRST_YR_CLIMO2 + $NYRS_CLIMO2 - 1"
    FYR_PRNT_CLIMO2=`printf "%04d" ${FIRST_YR_CLIMO2}`
    LYR_PRNT_CLIMO2=`printf "%04d" ${LAST_YR_CLIMO2}`
    FYR_PRNT_TS2=`printf "%04d" ${FIRST_YR_TS2}`
    LYR_PRNT_TS2=`printf "%04d" ${LAST_YR_TS2}`
fi

# Define vectors for looping over cases
CASENAME_VEC=($CASENAME1)
PATHDAT_VEC=($PATHDAT1)
CLIMO_TS_DIR_VEC=($CLIMO_TS_DIR1)
FIRST_YR_CLIMO_VEC=($FIRST_YR_CLIMO1)
LAST_YR_CLIMO_VEC=($LAST_YR_CLIMO1)
FIRST_YR_TS_VEC=($FIRST_YR_TS1)
LAST_YR_TS_VEC=($LAST_YR_TS1)
FYR_PRNT_CLIMO_VEC=($FYR_PRNT_CLIMO1)
LYR_PRNT_CLIMO_VEC=($LYR_PRNT_CLIMO1)
FYR_PRNT_TS_VEC=($FYR_PRNT_TS1)
LYR_PRNT_TS_VEC=($LYR_PRNT_TS1)
if [ $CNTL == USER ]; then
    CASENAME_VEC+=($CASENAME2)
    PATHDAT_VEC+=($PATHDAT2)
    CLIMO_TS_DIR_VEC+=($CLIMO_TS_DIR2)
    FIRST_YR_CLIMO_VEC+=($FIRST_YR_CLIMO2)
    LAST_YR_CLIMO_VEC+=($LAST_YR_CLIMO2)
    FIRST_YR_TS_VEC+=($FIRST_YR_TS2)
    LAST_YR_TS_VEC+=($LAST_YR_TS2)
    FYR_PRNT_CLIMO_VEC+=($FYR_PRNT_CLIMO2)
    LYR_PRNT_CLIMO_VEC+=($LYR_PRNT_CLIMO2)
    FYR_PRNT_TS_VEC+=($FYR_PRNT_TS2)
    LYR_PRNT_TS_VEC+=($LYR_PRNT_TS2)
fi

# Loop over cases
i=0
for CASENAME in ${CASENAME_VEC[*]}
do
    PATHDAT=${PATHDAT_VEC[$i]}
    CLIMO_TS_DIR=${CLIMO_TS_DIR_VEC[$i]}
    FIRST_YR_CLIMO=${FIRST_YR_CLIMO_VEC[$i]}
    LAST_YR_CLIMO=${LAST_YR_CLIMO_VEC[$i]}
    FIRST_YR_TS=${FIRST_YR_TS_VEC[$i]}
    LAST_YR_TS=${LAST_YR_TS_VEC[$i]}
    FYR_PRNT_CLIMO=${FYR_PRNT_CLIMO_VEC[$i]}
    LYR_PRNT_CLIMO=${LYR_PRNT_CLIMO_VEC[$i]}
    FYR_PRNT_TS=${FYR_PRNT_TS_VEC[$i]}
    LYR_PRNT_TS=${LYR_PRNT_TS_VEC[$i]}

    if [ $compute_climo -eq 1 ]; then
	# ---------------------------------
	# Compute climatology
	# ---------------------------------
	# Strategy for annual climatologies:
	# 1. First attempt to compute climatology from the annual-mean history files (hy)
	# 2. Use the monthly-mean history files (hm) for the remaining variables, or if hy files don't exist
	echo " "
	echo "****************************************************"
	echo "COMPUTING CLIMATOLOGY ($CASENAME)"
	echo "****************************************************"
	ANN_AVG_FILE=${CASENAME}_ANN_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo.nc
	MON_AVG_FILE=${CASENAME}_01_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo.nc # Check first month
	# Check if annual climo file already exists
	if [ -f $CLIMO_TS_DIR/$ANN_AVG_FILE ] && [ -f $CLIMO_TS_DIR/$MON_AVG_FILE ]; then
	    echo "$CLIMO_TS_DIR/$ANN_AVG_FILE and $CLIMO_TS_DIR/$MON_AVG_FILE already exist."
	    echo "-> SKIPPING COMPUTING CLIMATOLOGY"
	else
   	    echo $required_vars_climo_ann > $WKDIR/attributes/required_vars
	    $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo_ann
	    echo $required_vars_climo_mon > $WKDIR/attributes/required_vars
	    $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo_mon
	    if [ -f $WKDIR/attributes/vars_climo_ann_${CASENAME}_hy ]; then
		$DIAG_CODE/compute_climo.sh hy $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ -f $WKDIR/attributes/vars_climo_ann_${CASENAME}_hm ] || [ -f $WKDIR/attributes/vars_climo_mon_${CASENAME}_hm ]; then
		$DIAG_CODE/compute_climo.sh hm $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ ! -f $WKDIR/attributes/vars_climo_ann_${CASENAME}_hy ] && [ ! -f $WKDIR/attributes/vars_climo_ann_${CASENAME}_hm ]; then
		echo "ERROR: Climatology can only be computed from hy and hm history files"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	    # Concancate files if necessary
	    $DIAG_CODE/concancate_files.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR climo_ann
	fi
	# ---------------------------------
	# Remapping climatology
	# ---------------------------------
	echo " "
	echo "****************************************************"
	echo "REMAPPING CLIMATOLOGY ($CASENAME)"
	echo "****************************************************"

	# Check if annual and monthly remapped files already exist
	ANN_RGR_FILE=${CASENAME}_ANN_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo_remap.nc
	remap_ann=0
	remap_mon=0
	remap_seas=0
	if [ ! -f $CLIMO_TS_DIR/$ANN_RGR_FILE ]; then
	    remap_ann=1
	fi
	for month in 01 02 03 04 05 06 07 08 09 10 11 12
	do
	    MON_RGR_FILE=${CASENAME}_${month}_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo_remap.nc
	    if [ ! -f $CLIMO_TS_DIR/$MON_RGR_FILE ]; then
		remap_mon=1
	    fi
	done
	for season in JFM AMJ JAS OND
	do
	    SEAS_RGR_FILE=${CASENAME}_${season}_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo_remap.nc
	    if [ ! -f $CLIMO_TS_DIR/$SEAS_RGR_FILE ]; then
		remap_seas=1
	    fi
	done

	if [ $remap_ann -eq 1 ] || [ $remap_mon -eq 1 ]; then
	    # Check if sst file is present
	    if [ ! -f $WKDIR/attributes/sst_file_${CASENAME} ]; then
		if [ $remap_ann -eq 1 ]; then
		    echo $required_vars_climo_ann > $WKDIR/attributes/required_vars
		    $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo_ann
		fi
		if [ $remap_mon -eq 1 ]; then
		    echo $required_vars_climo_mon > $WKDIR/attributes/required_vars
		    $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo_mon
		fi
	    fi
	    # Determine grid type from the climo file
	    if [ ! -f $WKDIR/attributes/grid_${CASENAME} ] && [ -z $PGRIDPATH ]; then
		$DIAG_CODE/determine_grid_type.sh $CASENAME
	    fi
	    # Add coordinate attributes if necessary
	    $DIAG_CODE/add_attributes.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR $remap_ann $remap_mon
	    # Remap the grid to 1x1 rectangular grid
	    $DIAG_CODE/remap_climo.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR $remap_ann $remap_mon
	    # Compute zonal mean
	    $DIAG_CODE/zonal_mean.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR
	else
	    echo "Annual and monthly remapped climatology files already exists."
	    echo "-> SKIPPING REMAPPING CLIMATOLOGY"
	fi
	# Compute seasonal mean
        if [ $remap_seas -eq 1 ]; then
	    $DIAG_CODE/seasonal_mean.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR
	else
	    echo "Seasonal remapped climatology files already exists."
	    echo "-> SKIPPING COMPUTING SEASONAL CLIMATOLOGY"
	fi
    fi

    if [ $compute_time_series_ann -eq 1 ]; then
	# ---------------------------------
	# Compute annual time series
	# ---------------------------------
	echo " "
	echo "****************************************************"
	echo "ANNUAL TIME SERIES ($CASENAME)"
	echo "****************************************************"
	echo "FIRST_YR_TS = $FIRST_YR_TS"
	echo "LAST_YR_TS  = $LAST_YR_TS"

	ANN_TS_FILE=${CASENAME}_ANN_${FYR_PRNT_TS}-${LYR_PRNT_TS}_ts.nc
	# Check if annual time series file already exists
	if [ ! -f $CLIMO_TS_DIR/$ANN_TS_FILE ]; then	
	    echo $required_vars_ts_ann > $WKDIR/attributes/required_vars
	    $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT ts_ann
	    if [ ! -f $WKDIR/attributes/grid_${CASENAME} ] && [ -z $PGRIDPATH ]; then
		$DIAG_CODE/determine_grid_type.sh $CASENAME
	    fi
	    if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hy ]; then
		$DIAG_CODE/compute_ann_time_series.sh hy $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hm ]; then
		$DIAG_CODE/compute_ann_time_series.sh hm $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hy ] && [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hm ]; then
		echo "WARNING: could not find required variables ($required_vars_ts_mon) for annual time series."
		echo "-> SKIPPING COMPUTING ANNUAL TIME SERIES"
	    fi
	    # Concancate files if necessary
	    $DIAG_CODE/concancate_files.sh $CASENAME $FYR_PRNT_TS $LYR_PRNT_TS $CLIMO_TS_DIR ts_ann
	else
	    echo "$CLIMO_TS_DIR/$ANN_TS_FILE already exists."
	    echo "-> SKIPPING COMPUTING ANNUAL TIME SERIES"
	fi
    fi

    if [ $compute_time_series_mon -eq 1 ]; then
	# ---------------------------------
	# Compute nino time series
	# ---------------------------------
	echo " "
	echo "****************************************************"
	echo "NINO MONTHLY TIME SERIES ($CASENAME)"
	echo "****************************************************"
	# Loop over Nino indices
	for NINOidx in `echo $NINO_INDICES | sed 's/,/ /g'`
	do
	    MON_TS_FILE=${CASENAME}_MON_${FYR_PRNT_TS}-${LYR_PRNT_TS}_sst${NINOidx}_ts.nc
	    if [ ! -f $CLIMO_TS_DIR/$MON_TS_FILE ]; then
		echo "sst" > $WKDIR/attributes/required_vars
		$DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT ts_mon
		# Check for grid information
		if [ ! -f $WKDIR/attributes/grid_${CASENAME} ] && [ -z $PGRIDPATH ]; then
		    $DIAG_CODE/determine_grid_type.sh $CASENAME
		fi
		if [ -f $WKDIR/attributes/vars_ts_mon_${CASENAME}_hm ]; then
		    $DIAG_CODE/compute_mon_time_series.sh hm $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR $NINOidx
		elif [ -f $WKDIR/attributes/vars_ts_mon_${CASENAME}_hd ]; then
		    $DIAG_CODE/compute_mon_time_series.sh hd $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR $NINOidx
		else
		    echo "WARNING: could not find the sst variable for Nino time series."
		    echo "-> SKIPPING COMPUTING NINO TIME SERIES"
		fi
	    else
		echo "$CLIMO_TS_DIR/$MON_TS_FILE already exists."
		echo "-> SKIPPING COMPUTING NINO TIME SERIES"
	    fi
	done
    fi
    let i=$i+1
done

# ---------------------------------------------
# Check that the climo and ts files are present
# ---------------------------------------------
# set_1: ANN_TS_FILE
ANN_TS_FILE1=${CASENAME1}_ANN_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_ts.nc
if [ $set_1 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_TS_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_TS_FILE1 not found: skipping set_1"
    set_1=0
elif [ $set_1 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_TS_FILE1 ]; then
    ANN_TS_FILE2=${CASENAME2}_ANN_${FYR_PRNT_TS2}-${LYR_PRNT_TS2}_ts.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_TS_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ANN_TS_FILE2 not found: skipping set_1"
	set_1=0
    fi
fi
# set_2: MON_TS_FILES
if [ $set_2 -eq 1 ]; then
    for NINOidx in `echo $NINO_INDICES | sed 's/,/ /g'`
    do
	MON_TS_FILE1=${CASENAME1}_MON_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_sst${NINOidx}_ts.nc
	if [ ! -f $CLIMO_TS_DIR1/$MON_TS_FILE1 ]; then
	    echo "$CLIMO_TS_DIR1/$MON_TS_FILE1 not found: skipping set_2"
	    set_2=0
	else
	    MON_TS_FILE2=${CASENAME2}_MON_${FYR_PRNT_TS2}-${LYR_PRNT_TS2}_sst${NINOidx}_ts.nc
	    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$MON_TS_FILE2 ]; then
		echo "$CLIMO_TS_DIR2/$MON_TS_FILE2 not found: skipping set_2"
		set_2=0
	    fi
	fi
    done
fi
# set_3: ANN_RGR_FILE & MON_RGR_FILE
ANN_RGR_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
if [ $set_3 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_RGR_FILE1 not found: skipping set_3"
    set_3=0
elif [ $set_3 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
    ANN_RGR_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_RGR_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ANN_RGR_FILE2 not found: skipping set_3"
	set_3=0
    fi
fi
MON_RGR_FILE1=${CASENAME1}_01_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
if [ $set_3 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$MON_RGR_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$MON_RGR_FILE1 not found: skipping set_3"
    set_3=0
elif [ $set_3 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$MON_RGR_FILE1 ]; then
    MON_RGR_FILE2=${CASENAME2}_01_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$MON_RGR_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$MON_RGR_FILE2 not found: skipping set_3"
	set_3=0
    fi
fi
# set_4: ANN_AVG_FILE
ANN_AVG_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo.nc
if [ $set_4 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_AVG_FILE1 not found: skipping set_4"
    set_4=0
elif [ $set_4 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
    ANN_AVG_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_AVG_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ANN_AVG_FILE2 not found: skipping set_4"
	set_4=0
    fi
fi
# set_5: ZM_FILE: assumes that all zm files exist if "glb" is present
ZM_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap_zm_glb.nc
if [ $set_5 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ZM_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ZM_FILE1 not found: skipping set_5"
    set_5=0
elif [ $set_5 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ZM_FILE1 ]; then
    ZM_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap_zm_glb.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ZM_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ZM_FILE2 not found: skipping set_5"
	set_5=0
    fi
fi
# set_6: ANN_RGR_FILE
ANN_RGR_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
if [ $set_6 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_RGR_FILE1 not found: skipping set_6"
    set_6=0
elif [ $set_6 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
    ANN_RGR_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_RGR_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ANN_RGR_FILE2 not found: skipping set_6"
	set_6=0
    fi
fi
# set_7: ANN_AVG_FILE
ANN_AVG_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo.nc
if [ $set_7 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_AVG_FILE1 not found: skipping set_7"
    set_7=0
elif [ $set_7 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
    ANN_AVG_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_AVG_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ANN_AVG_FILE2 not found: skipping set_7"
	set_7=0
    fi
fi

# ---------------------------------
# Create the web interface
# ---------------------------------
if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
    if [ $CNTL == OBS ]; then
	WEBFOLDER=ts${FIRST_YR_TS1}to${LAST_YR_TS1}
    else
	WEBFOLDER=ts${FIRST_YR_TS1}to${LAST_YR_TS1}-$CASENAME2
    fi
else
    WEBFOLDER=yrs${FIRST_YR_CLIMO1}to${LAST_YR_CLIMO1}-$CASENAME2
    if [ $CNTL == USER ] && [ $CASENAME1 == $CASENAME2 ]; then
	WEBFOLDER=yrs${FIRST_YR_CLIMO1}to${LAST_YR_CLIMO1}-yrs${FIRST_YR_CLIMO2}to${LAST_YR_CLIMO2}
    fi
fi
TARFILE=${WEBFOLDER}.tar
export WEBDIR=$WKDIR/$WEBFOLDER
if [ -d $WEBDIR ]; then
    rm -rf $WEBDIR
fi
mkdir -p $WEBDIR/set1
mkdir -p $WEBDIR/set2
mkdir -p $WEBDIR/set3
mkdir -p $WEBDIR/set4
mkdir -p $WEBDIR/set5
mkdir -p $WEBDIR/set6
mkdir -p $WEBDIR/set7
cp $DIAG_HTML/index.html $WEBDIR
cdate=`date`
sed -i "s/test_run/$CASENAME1/g" $WEBDIR/index.html
sed -i "s/date_and_time/$cdate/g" $WEBDIR/index.html
if [ $CNTL == USER ]; then
    sed -i "17i<br>and $CASENAME2" $WEBDIR/index.html
fi
if [ $set_1 -eq 1 ] || [ $set_2 -eq 1 ]; then
    echo "<font color=maroon size=+1><b><u>Time series plots</u></b></font><br>" >> $WEBDIR/index.html
    echo "<br>" >> $WEBDIR/index.html
fi

cd $WKDIR
# ---------------------------------
# set 1: annual time series plots
# ---------------------------------
if [ $set_1 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 1: ANNUAL TIME SERIES PLOTS"
    echo "****************************************************"
    export COMPARE=$CNTL
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_ts.nc
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_TS1
    if [ $CNTL == USER ]; then
	export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_TS2}-${LYR_PRNT_TS2}_ts.nc
	export CASE2=$CASENAME2
	export FYR2=$FIRST_YR_TS2
    fi
    echo "Plotting time series of volume transport (plot_time_series_voltr.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_time_series_voltr.ncl
    echo "Plotting time series of temp, saln and mmflxd (plot_time_series_ann.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_time_series_ann.ncl
    echo "Plotting Hovmoeller of temp and saln (plot_hovmoeller*.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_hovmoeller1.ncl
    $NCL -Q < $DIAG_CODE/plot_hovmoeller2.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set1 $density
    if [ $? -ne 0 ]; then
	"ERROR occurred in ps2png.sh (set1)"
	"*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage1.sh
fi
# ---------------------------------
# set 2: nino index
# ---------------------------------
if [ $set_2 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 2: NINO INDEX PLOTS"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR_TS1=$FYR_PRNT_TS1
    export LYR_TS1=$LYR_PRNT_TS1
    if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
	export FYR_CLIMO1=$FIRST_YR_TS1
	export LYR_CLIMO1=$LAST_YR_TS1
    else
	export FYR_CLIMO1=$FIRST_YR_CLIMO1
	export LYR_CLIMO1=$LAST_YR_CLIMO1
    fi
    export DATADIR1=$CLIMO_TS_DIR1
    if [ $CNTL == USER ]; then
	export CASE2=$CASENAME2
	export FYR_TS2=$FYR_PRNT_TS2
	export LYR_TS2=$LYR_PRNT_TS2
	if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
	    export FYR_CLIMO2=$FIRST_YR_TS2
	    export LYR_CLIMO2=$LAST_YR_TS2
	else
	    export FYR_CLIMO2=$FIRST_YR_CLIMO2
	    export LYR_CLIMO2=$LAST_YR_CLIMO2
	fi
        export DATADIR2=$CLIMO_TS_DIR2
    fi
    echo "Plotting NINO SST index (plot_nino.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_nino.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set2 $density
    if [ $? -ne 0 ]; then
	echo "ERROR occurred in ps2png.sh (set2)"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage2.sh
fi

if [ $set_3 -eq 1 ] || [ $set_4 -eq 1 ] || [ $set_5 -eq 1 ] || [ $set_6 -eq 1 ]; then
    if [ $set_1 -eq 1 ] || [ $set_2 -eq 1 ]; then
	echo "<br>" >> $WEBDIR/index.html
    fi
    echo "<font color=maroon size=+1><b><u>Climatology plots</u></b></font><br>" >> $WEBDIR/index.html
fi
# ---------------------------------
# set 3: lat/lon plots
# ---------------------------------
if [ $set_3 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 3: 2D LAT/LON CONTOUR PLOTS"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_CLIMO1
    export LYR1=$LAST_YR_CLIMO1
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
    export INFILE2=$DIAG_OBS
    if [ $CNTL == USER ]; then
	export CASE2=$CASENAME2
	export FYR2=$FIRST_YR_CLIMO2
	export LYR2=$LAST_YR_CLIMO2
	export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
    fi
    # Plot annual temp, saln and ssh
    echo "2D annual contour plots (plot_latlon_annual.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_latlon_annual.ncl
    # Plot seasonal climatology
    echo "2D seasonal plots (plot_latlon_seasons.ncl)..."
    m=13
    for season in JFM AMJ JAS OND
    do
	export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_${season}_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
	export INFILE2=$DIAG_OBS
	export OBS_NUM=$m
	export SEAS=$season
	if [ $CNTL == USER ]; then
	    export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_${season}_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
	fi
	$NCL -Q < $DIAG_CODE/plot_latlon_seasons.ncl
	let m++
    done
    # Plot monthly MLD
    # Check if temp, saln and dz are in monthly climotology files
    TEST_FILE=$CLIMO_TS_DIR1/${CASENAME1}_01_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
    $NCKS --quiet -d lon,0 -d lat,0 -d sigma,0 -v temp,saln,dz $TEST_FILE >/dev/null 2>&1
    if [ $? -eq 0 ]; then
	echo "2D monthly MLD plots (plot_mld_monthly.ncl)..."
	MLD_CLIM_DIR1=$CLIMO_TS_DIR1/MLD
	if [ -d $MLD_CLIM_DIR1 ]; then
	    rm -rf $MLD_CLIM_DIR1
	fi
	mkdir -p $MLD_CLIM_DIR1
	if [ $CNTL == USER ]; then
	    MLD_CLIM_DIR2=$CLIMO_TS_DIR2/MLD
	    if [ -d $MLD_CLIM_DIR2 ]; then
		rm -rf $MLD_CLIM_DIR2
	    fi
	    mkdir -p $MLD_CLIM_DIR2
	fi
	pid=()
	for month in 01 02 03 04 05 06 07 08 09 10 11 12
	do
	    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_${month}_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
	    export INFILE2=$DIAG_OBS/MLD/mld_clim_WOCE_${month}.nc
	    export CMONTH=$month
	    export NCOUTPATH1=$MLD_CLIM_DIR1/mld_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_${month}.nc
	    if [ $CNTL == USER ]; then
		export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_${month}_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
		export NCOUTPATH2=$MLD_CLIM_DIR2/mld_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_${month}.nc
	    fi
	    eval $NCL -Q < $DIAG_CODE/plot_mld_monthly.ncl &
	    pid+=($!)
	done
	for ((m=0;m<=11;m++))
	do
            wait ${pid[$m]}
            if [ $? -ne 0 ]; then
		echo "ERROR in computation of monthly MLD: $NCL -Q < $DIAG_CODE/plot_mld_monthly.ncl" 
		echo "*** EXITING THE SCRIPT ***"
		exit 1
            fi
	done
	wait
	# Check if monthly MLD files were created
	mld_files1=()
	mld_files2=()
	for month in 01 02 03 04 05 06 07 08 09 10 11 12
	do
	    mld_file1=mld_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_${month}.nc
	    if [ -f $MLD_CLIM_DIR1/$mld_file1 ]; then
		mld_files1+=($mld_file1)
	    else
		echo "ERROR: cannot find $MLD_CLIM_DIR1/mld_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_${month}.nc"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	    if [ $CNTL == USER ]; then
		mld_file2=mld_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_${month}.nc
		if [ -f $MLD_CLIM_DIR2/$mld_file2 ]; then
		    mld_files2+=($mld_file2)
		else
		    echo "ERROR: cannot find $MLD_CLIM_DIR2/mld_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_${month}.nc"
		    echo "*** EXITING THE SCRIPT ***"
		    exit 1
		fi
	    fi
	done
	# Calculate annual mean MLD
	mld_ann_file1=$MLD_CLIM_DIR1/mld_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_ANN.nc
	$NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v mld -p $MLD_CLIM_DIR1 ${mld_files1[*]} $mld_ann_file1
	if [ $CNTL == USER ]; then
	    mld_ann_file2=$MLD_CLIM_DIR2/mld_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_ANN.nc
	    $NCRA -O -w 31,28,31,30,31,30,31,31,30,31,30,31 --no_tmp_fl --hdr_pad=10000 -v mld -p $MLD_CLIM_DIR2 ${mld_files2[*]} $mld_ann_file2
	fi
	echo "2D annual-mean MLD plot (plot_mld_annual.ncl)..."
	export INFILE1=$mld_ann_file1
	export INFILE2=$DIAG_OBS/MLD/mld_clim_WOCE_ANN.nc
	if [ $CNTL == USER ]; then
	    export INFILE2=$mld_ann_file2
	fi
	$NCL -Q < $DIAG_CODE/plot_mld_annual.ncl
    else
	echo "Variables temp, saln or dz not found in ${TEST_FILE}: SKIPPING MLD PLOTS"
    fi
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set3 $density
    if [ $? -ne 0 ]; then
	echo "ERROR occurred in ps2png.sh (set3)"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage3.sh
fi
# ---------------------------------
# set 4: MOCs
# ---------------------------------
if [ $set_4 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 4: MOC PLOTS"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_CLIMO1
    export LYR1=$LAST_YR_CLIMO1
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo.nc
    if [ $CNTL == USER ]; then
	export CASE2=$CASENAME2
	export FYR2=$FIRST_YR_CLIMO2
	export LYR2=$LAST_YR_CLIMO2
	export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo.nc
    fi
    echo "MOC plots (plot_moc.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_moc.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set4 $density
    if [ $? -ne 0 ]; then
	echo "ERROR occurred in ps2png.sh (set4)"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage4.sh
fi
# ---------------------------------
# set 5: Zonal means
# ---------------------------------
if [ $set_5 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 5: ZONAL MEAN PLOTS"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_CLIMO1
    export LYR1=$LAST_YR_CLIMO1
    export INFILE2=$DIAG_OBS
    if [ $CNTL == USER ]; then
	export CASE2=$CASENAME2
	export FYR2=$FIRST_YR_CLIMO2
	export LYR2=$LAST_YR_CLIMO2
    fi
    for reg in glb pac atl ind so
    do
	export REGION=$reg
	export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap_zm_$REGION.nc
	if [ $CNTL == USER ]; then
	    export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap_zm_$REGION.nc
	fi
	echo "Zonal mean plots of region $REGION (plot_zonal_mean.ncl)..."
	$NCL -Q < $DIAG_CODE/plot_zonal_mean.ncl
    done
    
    $DIAG_CODE/ps2png.sh set5 $density
    if [ $? -ne 0 ]; then
	"ERROR occurred in ps2png.sh (set5)"
	"*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage5.sh
fi
# ---------------------------------
# set 6: Equatorial plots
# ---------------------------------
if [ $set_6 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 6: EQUATORIAL PLOTS"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_CLIMO1
    export LYR1=$LAST_YR_CLIMO1
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
    export INFILE2=$DIAG_OBS
    if [ $CNTL == USER ]; then
	export CASE2=$CASENAME2
	export FYR2=$FIRST_YR_CLIMO2
	export LYR2=$LAST_YR_CLIMO2
	export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
    fi
    echo "Equatorial plots of temp and saln (plot_eq.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_eq.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set6 $density
    if [ $? -ne 0 ]; then
	echo "ERROR occurred in ps2png.sh (set6)"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage6.sh
fi
# ---------------------------------
# set 7: Meridional fluxes
# ---------------------------------
if [ $set_7 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 7: MERIDIONAL FLUXES"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_CLIMO1
    export LYR1=$LAST_YR_CLIMO1
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo.nc
    if [ $CNTL == USER ]; then
	export CASE2=$CASENAME2
	export FYR2=$FIRST_YR_CLIMO2
	export LYR2=$LAST_YR_CLIMO2
	export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo.nc
    fi
    echo "Meridional fluxes (plot_meridional_fluxes.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_meridional_fluxes.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set7 $density
    if [ $? -ne 0 ]; then
	echo "ERROR occurred in ps2png.sh (set7)"
	echo "*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage7.sh
fi
# Closing the webpage
echo "</BODY>" >> $WEBDIR/index.html
echo "</HTML>" >> $WEBDIR/index.html
# Making tar file
echo " "
echo "****************************************************"
echo "TAR PLOTS AND PUBLISH HTML"
echo "****************************************************"
echo "Making tar file of directory: $WEBFOLDER"
tar -cf $TARFILE $WEBFOLDER
if [ $? -eq 0 ] && [ $publish_html -eq 1 ]; then
    web_server_path=/projects/NS2345K/www
    if [ -z $publish_html_root ]; then
	publish_html_root=${web_server_path}/noresm_diagnostics
    fi
    publish_html_path=$publish_html_root/$CASENAME1/MICOM_DIAG
    if [ ! -d $publish_html_path ]; then
	mkdir -p $publish_html_path
    fi
    web_server=ns2345k.web.sigma2.no
    path_pref=`echo ${publish_html_path} | cut -c -21`
    path_suff=`echo ${publish_html_path} | cut -c 23-`
    tar -xf $TARFILE -C $publish_html_path
    if [ $? -eq 0 ]; then
	if [ $path_pref == $web_server_path ]; then
            full_url=${web_server}/${path_suff}/${WEBFOLDER}/index.html
	    $DIAG_CODE/redirect_html.sh $WEBFOLDER $publish_html_path $full_url
	    echo " "
            echo "URL:"
            echo "***********************************************************************************"
            echo "${full_url}"
            echo "***********************************************************************************"
            echo "Copy and paste the URL into the address bar of your web browser to view the results"
	else
	    echo " "
            echo "The html files are located in:"
            echo "${publish_html_path}/${tardir}"
            echo "(not on the NIRD web server)"
	fi
    fi
fi
# Cleaning up
if [ -d $WEBDIR ]; then
    rm -rf $WEBDIR
fi
time_end_script=`date +%s`
runtime_s=`expr ${time_end_script} - ${time_start_script}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`

echo " "
echo "****************************************************"
echo "NORMAL EXIT FROM SCRIPT"
echo "TOTAL RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
date
echo "****************************************************"


