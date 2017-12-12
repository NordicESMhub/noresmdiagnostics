#!/bin/bash
set -e
# MICOM DIAGNOSTICS package
# Johan Liakka, NERSC, johan.liakka@nersc.no
# built upon previous work by Detelina Ivanova
# Last update Dec 2017

#***************************
#*** USER MODIFY SECTION ***
#***************************

# ---------------------------------------------------------
# TEST CASENAME AND YEARS TO BE AVERAGED (CASE1)
# ---------------------------------------------------------
CASENAME1=N1850_f19_tn11_01_E1
#CASENAME1=B1850MICOM_f09_tn14_01
FIRST_YR_CLIMO1=21
NYRS_CLIMO1=30

# ---------------------------------------------------------
# TIME SERIES SETTING FOR TEST CASE (CASE1)
# ---------------------------------------------------------
# If TRENDS_ALL=1 the time series is computed over the
# entire simulation; otherwise between first_yr_ts
# and last_yr_ts
TRENDS_ALL=1
FIRST_YR_TS1=0
LAST_YR_TS1=0

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE1)
# ---------------------------------------------------------
pathdat_root1=/projects/NS2345K/noresm/cases
PATHDAT1=$pathdat_root1/$CASENAME1/ocn/hist

# ---------------------------------------------------------
# SELECT TYPE OF CONTROL CASE
# NOTE: CNTL=USER IS NOT YET SUPPORTED
# ---------------------------------------------------------
CNTL=OBS    # compare case1 to observations (model-obs diagnostics)
#CNTL=USER   # compare case1 to another experiment case2 (model-model diagnostics)

# ---------------------------------------------------------
# CNTL CASENAME AND YEARS TO BE AVERAGED (CASE2)
# ---------------------------------------------------------
CASENAME2=your_cntl_simulation
FIRST_YR_CLIMO2=fyr_of_cntl
NYRS_CLIMO2=nyr_of_cntl

# ---------------------------------------------------------
# TIME SERIES SETTING FOR CNTL CASE (CASE2)
# ---------------------------------------------------------
FIRST_YR_TS2=0
LAST_YR_TS2=0

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE2)
# ---------------------------------------------------------
pathdat_root2=/path/to/cntl_case/history
PATHDAT2=$pathdat_root2/$CASENAME2/ocn/hist

# ---------------------------------------------------------
# SELECT DIRECTORY WHERE THE DIAGNOSTICS ARE TO BE COMPUTED
# ---------------------------------------------------------
DIAG_ROOT=/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/test_runs

# ---------------------------------------------------------
# SELECT PALEO TIMESLICE
# ---------------------------------------------------------
# set PALEO=1 if you have a paleo land-sea mask.
# Note that if PALEO=1, the automatic grid searching is
# switched off, and the user has to provide the path to
# the grid and mask_nino34 files (PGRIDPATH).
export PALEO=0 # (1=ON,0=OFF)
export PGRIDPATH=/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/grid_files/tnx1v1/lgm

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
density=85

# ---------------------------------------------------------
# SELECT SETS (1-4)
# ---------------------------------------------------------
set_1=1 # (1=ON,0=OFF) Time series plots incl. ENSO
set_2=1 # (1=ON,0=OFF) 2D (lat-lon) contour plots
set_3=1 # (1=ON,0=OFF) MOCs for different regions
set_4=1 # (1=ON,0=OFF) Zonal mean (lat-depth) plots

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
export DIAG_HOME=/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG

#**********************************
#*** END OF USER MODIFY SECTION ***
#**********************************

# Set environmental directories
export WKDIR=$DIAG_ROOT/diag/$CASENAME1
export DIAG_CODE=$DIAG_HOME/code
export DIAG_GRID=$DIAG_HOME/grid_files
export DIAG_ETC=$DIAG_HOME/etc

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
    echo "ERROR: found no CDO (Climate Data Operators)"
    echo "You might try the following:"
    echo "module load cdo"
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

# Set directories for climatology and time series
CLIMO_TS_DIR1=$DIAG_ROOT/climo_ts/$CASENAME1
if [ $CNTL == USER ]; then
    CLIMO_TS_DIR2=$DIAG_ROOT/climo_ts/$CASENAME2
    diag_type=model1-model2
elif [ $CNTL == OBS ]; then
    CASENAME2=OBS
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

# Write years with four digits
let "LAST_YR_CLIMO1 = $NYRS_CLIMO1 + $FIRST_YR_CLIMO1 - 1"
FYR_PRNT_CLIMO1=`printf "%04d" ${FIRST_YR_CLIMO1}`
LYR_PRNT_CLIMO1=`printf "%04d" ${LAST_YR_CLIMO1}`
if [ $CNTL == USER ]; then
    let "LAST_YR_CLIMO2 = $NYRS_CLIMO2 + $FIRST_YR_CLIMO2 - 1"
    FYR_PRNT_CLIMO2=`printf "%04d" ${FIRST_YR_CLIMO2}`
    LYR_PRNT_CLIMO2=`printf "%04d" ${LAST_YR_CLIMO2}`
fi

# Set required variables for climatology and time series
required_vars_climo="depth_bnds,sst,sealv,mld,templvl,salnlvl,mmflxd,region"
required_vars_ts_ann="depth_bnds,time,section,voltr,sst,temp,saln,templvl,salnlvl,mmflxd,region,dp"
required_vars_ts_mon="sst"

# Check which sets should be plotted based on CLIMO_TIME_SERIES_SWITCH
if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO ]; then
    set_1=0 ; set_2=1 ; set_3=1 ; set_4=1
elif [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
    set_1=1 ; set_2=0 ; set_3=0 ; set_4=0
fi
compute_climo=0
compute_time_series=0
if [ $set_1 -eq 1 ]; then
    compute_time_series=1
fi
if [ $set_2 -eq 1 ] || [ $set_3 -eq 1 ] || [ $set_4 -eq 1 ]; then
    compute_climo=1
fi
if [ $compute_climo -eq 1 ] && [ $compute_time_series -eq 0 ]; then
    diag_type2="climatology"
elif [ $compute_climo -eq 0 ] && [ $compute_time_series -eq 1 ]; then
    diag_type2="time-series"
elif [ $compute_climo -eq 1 ] && [ $compute_time_series -eq 1 ]; then
    diag_type2="climatology & time-series"
else
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
echo "$diag_type $diag_type2 diagnostics:"
echo "CASENAME1 = $CASENAME1"
echo "CASENAME2 = $CASENAME2"
echo "****************************************************"

if [ $compute_climo -eq 1 ]; then
    # ---------------------------------
    # Compute annual climatology
    # ---------------------------------
    # Strategy:
    # 1. First attempt to compute climatology from the annual-mean history files (hy)
    # 2. Use the monthly-mean history files (hm) for the remaining variables, or if hy files don't exist
    echo " "
    echo "****************************************************"
    echo "COMPUTING CLIMATOLOGY ($CASENAME1)"
    echo "****************************************************"
    ANN_AVG_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo.nc
    # Check if annual climo file already exists
    if [ ! -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
	echo $required_vars_climo > $WKDIR/attributes/required_vars
	$DIAG_CODE/check_history_vars.sh $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 climo
	if [ -f $WKDIR/attributes/vars_climo_${CASENAME1}_hy ]; then
	    $DIAG_CODE/compute_climo.sh hy $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 $CLIMO_TS_DIR1
	fi
	if [ -f $WKDIR/attributes/vars_climo_${CASENAME1}_hm ]; then
	    $DIAG_CODE/compute_climo.sh hm $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 $CLIMO_TS_DIR1
	fi
	if [ ! -f $WKDIR/attributes/vars_climo_${CASENAME1}_hy ] && [ ! -f $WKDIR/attributes/vars_climo_${CASENAME1}_hm ]; then
	    echo "ERROR: Annual climatology can only be computed from hy and hm history files"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
	# Concancate files if necessary
	$DIAG_CODE/concancate_files.sh $CASENAME1 $FYR_PRNT_CLIMO1 $LYR_PRNT_CLIMO1 $CLIMO_TS_DIR1 climo
    else
	echo "$CLIMO_TS_DIR1/$ANN_AVG_FILE1 already exists."
	echo "-> SKIPPING COMPUTING CLIMATOLOGY"
    fi
    # ---------------------------------
    # Remapping climatology
    # ---------------------------------
    echo " "
    echo "****************************************************"
    echo "REMAPPING CLIMATOLOGY ($CASENAME1)"
    echo "****************************************************"
    ANN_RGR_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
    if [ ! -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
	# Check if sst file is present
	if [ ! -f $WKDIR/attributes/sst_file_${CASENAME1} ]; then
	   echo $required_vars_climo > $WKDIR/attributes/required_vars
	   $DIAG_CODE/check_history_vars.sh $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 climo
	fi
	# Determine grid type from the climo file
	if [ $PALEO -eq 0 ]; then
	    $DIAG_CODE/determine_grid_type.sh $CASENAME1
	fi
	# Add coordinate attributes if necessary
	$DIAG_CODE/add_attributes.sh $ANN_AVG_FILE1 $CLIMO_TS_DIR1
	# Remap the grid to 1x1 rectangular grid
	$DIAG_CODE/remap_climo.sh $CASENAME1 $ANN_AVG_FILE1 $ANN_RGR_FILE1 $CLIMO_TS_DIR1
    else
	echo "$CLIMO_TS_DIR1/$ANN_RGR_FILE1 already exists."
	echo "-> SKIPPING REMAPPING CLIMATOLOGY"
    fi
fi    

if [ $compute_time_series -eq 1 ]; then
    # ---------------------------------
    # Compute annual time series
    # ---------------------------------
    echo " "
    echo "****************************************************"
    echo "ANNUAL TIME SERIES ($CASENAME1)"
    echo "****************************************************"
    # Determine the first and last yr of time series (if TRENDS_ALL=1)
    if [ $TRENDS_ALL -eq 1 ]; then
	echo "TRENDS_ALL=1: time series over the entire simulation"
	# First, check annual files
	echo "Searching for annual history files..."
	file_head=$CASENAME1.micom.hy.
	file_prefix=$PATHDAT1/$file_head
	first_file=`ls ${file_prefix}* | head -n 1`
	last_file=`ls ${file_prefix}* | tail -n 1`
	if [ -z $first_file ]; then
	    echo "Found no annual history files in $PATHDAT1"
	    echo "Searcing for monthly history files"
	    file_head=$CASENAME1.micom.hm.
	    file_prefix=$PATHDAT1/$file_head
	    first_file=`ls ${file_prefix}* | head -n 1`
	    last_file=`ls ${file_prefix}* | tail -n 1`
	    if [ -z $first_file ]; then
		echo "ERROR: found no monthly history files in $PATHDAT1"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    else
		FYR_PRNT_TS1=`echo $first_file | rev | cut -c 7-10 | rev`
		FIRST_YR_TS1=`echo $FYR_PRNT_TS1 | sed 's/^0*//'`
		LYR_PRNT_TS1=`echo $last_file | rev | cut -c 7-10 | rev`
		LAST_YR_TS1=`echo $LYR_PRNT_TS1 | sed 's/^0*//'`
		# Check that last file is a december file (for a full year)
		if [ "$last_file" != "$PATHDAT1/${file_head}${LYR_PRNT_TS1}-12.nc" ]; then
		    let "LAST_YR_TS1 = $LAST_YR_TS1 - 1"
		fi
		if [ $FIRST_YR_TS1 -eq $LAST_YR_TS1 ]; then
		    echo "ERROR: first and last year in ${CASENAME1} are identical: cannot compute trends"
		    echo "*** EXITING THE SCRIPT ***"
		    exit 1
		fi
	    fi
	else
	    FYR_PRNT_TS1=`echo $first_file | rev | cut -c 4-7 | rev`
	    FIRST_YR_TS1=`echo $FYR_PRNT_TS1 | sed 's/^0*//'`
	    LYR_PRNT_TS1=`echo $last_file | rev | cut -c 4-7 | rev`
	    LAST_YR_TS1=`echo $LYR_PRNT_TS1 | sed 's/^0*//'`
	    if [ $FIRST_YR_TS1 -eq $LAST_YR_TS1 ]; then
		echo "ERROR: first and last year in ${CASENAME1} are identical: cannot compute trends"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	fi
    fi
    echo "FIRST_YR = $FIRST_YR_TS1"
    echo "LAST_YR  = $LAST_YR_TS1"

    ANN_TS_FILE1=${CASENAME1}_ANN_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_ts.nc
    # Check if annual time series file already exists
    if [ ! -f $CLIMO_TS_DIR1/$ANN_TS_FILE1 ]; then	
	echo $required_vars_ts_ann > $WKDIR/attributes/required_vars
	$DIAG_CODE/check_history_vars.sh $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 ts_ann
	if [ ! -f $WKDIR/attributes/grid_${CASENAME1} ] && [ $PALEO -eq 0 ]; then
	    $DIAG_CODE/determine_grid_type.sh $CASENAME1
	fi
	if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME1}_hy ]; then
	    $DIAG_CODE/compute_ann_time_series.sh hy $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $CLIMO_TS_DIR1
	fi
	if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME1}_hm ]; then
	    $DIAG_CODE/compute_ann_time_series.sh hm $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $CLIMO_TS_DIR1
	fi
	if [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME1}_hy ] && [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME1}_hm ]; then
	    echo "ERROR: Annual time series can only be computed from hy and hm history files"
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	fi
	# Concancate files if necessary
	$DIAG_CODE/concancate_files.sh $CASENAME1 $FYR_PRNT_TS1 $LYR_PRNT_TS1 $CLIMO_TS_DIR1 ts_ann
    else
	echo "$CLIMO_TS_DIR1/$ANN_TS_FILE1 already exists."
	echo "-> SKIPPING COMPUTING ANNUAL TIME SERIES"
    fi
    # ---------------------------------
    # Compute monthly time series
    # ---------------------------------
    echo " "
    echo "****************************************************"
    echo "MONTHLY TIME SERIES ($CASENAME1)"
    echo "****************************************************"
    MON_TS_FILE1=${CASENAME1}_MON_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_ts.nc
    if [ ! -f $CLIMO_TS_DIR1/$MON_TS_FILE1 ]; then
	echo $required_vars_ts_mon > $WKDIR/attributes/required_vars
	$DIAG_CODE/check_history_vars.sh $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 ts_mon
	# Check for grid information
	if [ ! -f $WKDIR/attributes/grid_${CASENAME1} ] && [ $PALEO -eq 0 ]; then
	    $DIAG_CODE/determine_grid_type.sh $CASENAME1
	fi
	if [ -f $WKDIR/attributes/vars_ts_mon_${CASENAME1}_hm ]; then
	    $DIAG_CODE/compute_mon_time_series.sh hm $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $CLIMO_TS_DIR1
	fi
	if [ -f $WKDIR/attributes/vars_ts_mon_${CASENAME1}_hd ]; then
	    $DIAG_CODE/compute_mon_time_series.sh hd $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $CLIMO_TS_DIR1
	fi
	if [ ! -f $WKDIR/attributes/vars_ts_mon_${CASENAME1}_hm ] && [ ! -f $WKDIR/attributes/vars_ts_mon_${CASENAME1}_hd ]; then
	    echo "WARNING: could not find required variables ($required_vars_ts_mon) for monthly time series."
	    echo "-> SKIPPING COMPUTING MONTHLY TIME SERIES"
	fi
	# Concancate files if necessary
	$DIAG_CODE/concancate_files.sh $CASENAME1 $FYR_PRNT_TS1 $LYR_PRNT_TS1 $CLIMO_TS_DIR1 ts_mon
    else
	echo "$CLIMO_TS_DIR1/$MON_TS_FILE1 already exists."
	echo "-> SKIPPING COMPUTING MONTHLY TIME SERIES"
    fi	
fi

