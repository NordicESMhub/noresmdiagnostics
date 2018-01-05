#!/bin/bash
#
# HAMMOC DIAGNOSTICS package
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018
set -e
#***************************
#*** USER MODIFY SECTION ***
#***************************
time_start_script=`date +%s`
# ---------------------------------------------------------
# TEST CASENAME AND YEARS TO BE AVERAGED (CASE1)
# ---------------------------------------------------------
CASENAME1=N1850OCDMS_Test_01
FIRST_YR_CLIMO1=10
NYRS_CLIMO1=20

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
CASENAME2=N18_f19_tn11_080617
FIRST_YR_CLIMO2=21
NYRS_CLIMO2=30

# ---------------------------------------------------------
# TIME SERIES SETTING FOR CNTL CASE (CASE2)
# ---------------------------------------------------------
FIRST_YR_TS2=0
LAST_YR_TS2=0

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE2)
# ---------------------------------------------------------
pathdat_root2=/projects/NS2345K/noresm/cases
PATHDAT2=$pathdat_root2/$CASENAME2/ocn/hist

# ---------------------------------------------------------
# SELECT DIRECTORY WHERE THE DIAGNOSTICS ARE TO BE COMPUTED
# ---------------------------------------------------------
DIAG_ROOT=/projects/NS2345K/noresm_diagnostics_dev/out/$USER/HAMMOC_DIAG

# ---------------------------------------------------------
# SELECT SETS (1-3)
# ---------------------------------------------------------
set_1=1 # (1=ON,0=OFF) Annual time series plots
set_2=0 # (1=ON,0=OFF) 2D (lat-lon) contour plots
set_3=0 # (1=ON,0=OFF) Zonal mean (lat-depth) plot

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
# figures is determined by the density variable. You can
# also choose the colormap for the full fields
# (difference fields are always plotted with blue-white-red)
publish_html=1 # (1=ON,0=OFF)
publish_html_root=/projects/NS2345K/www/hammoc_test
density=85
# Available colormap options:
#  default = purple-brown palette provided by Marco Van Hulten
#  blueyellowred = color map from MICOM diagnostics
colormap=default

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
export DIAG_HOME=/projects/NS2345K/noresm_diagnostics_dev/packages/HAMMOC_DIAG

#**********************************
#*** END OF USER MODIFY SECTION ***
#**********************************

# Set environmental directories
export WKDIR=$DIAG_ROOT/diag/$CASENAME1
export DIAG_CODE=$DIAG_HOME/code
export DIAG_OBS=$DIAG_HOME/obs_data
export DIAG_HTML=$DIAG_HOME/html
export DIAG_GRID=$DIAG_HOME/grid_files

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
required_vars_climo="depth_bnds,o2lvl,silvl,po4lvl,no3lvl,dissiclvl"
required_vars_climo_zm="o2lvl,silvl,po4lvl,no3lvl,dissiclvl"
required_vars_ts_ann="o2,si,po4,no3,dissic,co2fxd,co2fxu,pp,pddpo"

# Check which sets should be plotted based on CLIMO_TIME_SERIES_SWITCH
if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO ]; then
    set_1=0 ; set_2=1 ; set_3=1
elif [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
    set_1=1 ; set_2=0 ; set_3=0
fi
compute_climo=0
compute_time_series_ann=0
if [ $set_1 -eq 1 ]; then
    compute_time_series_ann=1
fi
if [ $set_2 -eq 1 ] || [ $set_3 -eq 1 ]; then
    compute_climo=1
fi
if [ $set_1 -eq 0 ] && [ $set_2 -eq 0 ] && [ $set_3 -eq 0 ]; then
    echo "ERROR: All sets are zero. Please modify."
    echo "*** EXITING THE SCRIPT ***"
    exit 1
fi

echo " "
echo "****************************************************"
echo "          HAMMOC DIAGNOSTICS PACKAGE"
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
	# Compute annual climatology
	# ---------------------------------
	# Strategy:
	# 1. First attempt to compute climatology from the annual-mean history files (hbgcy)
	# 2. Use the monthly-mean history files (hbgcm) for the remaining variables, or if hy files don't exist
	echo " "
	echo "****************************************************"
	echo "COMPUTING CLIMATOLOGY ($CASENAME)"
	echo "****************************************************"
	ANN_AVG_FILE=${CASENAME}_ANN_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo.nc
	# Check if annual climo file already exists
	if [ ! -f $CLIMO_TS_DIR/$ANN_AVG_FILE ]; then
	    echo $required_vars_climo > $WKDIR/attributes/required_vars
	    $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo
	    if [ -f $WKDIR/attributes/vars_climo_${CASENAME}_hbgcy ]; then
		$DIAG_CODE/compute_climo.sh hbgcy $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ -f $WKDIR/attributes/vars_climo_${CASENAME}_hbgcm ]; then
		$DIAG_CODE/compute_climo.sh hbgcm $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ ! -f $WKDIR/attributes/vars_climo_${CASENAME}_hbgcy ] && [ ! -f $WKDIR/attributes/vars_climo_${CASENAME}_hbgcm ]; then
		echo "ERROR: Annual climatology can only be computed from hbgcy and hbgcm history files"
		echo "*** EXITING THE SCRIPT ***"
		exit 1
	    fi
	    # Concancate files if necessary
	    $DIAG_CODE/concancate_files.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR climo
	else
	    echo "$CLIMO_TS_DIR/$ANN_AVG_FILE already exists."
	    echo "-> SKIPPING COMPUTING CLIMATOLOGY"
	fi
	# ---------------------------------
	# Remapping climatology
	# ---------------------------------
	echo " "
	echo "****************************************************"
	echo "REMAPPING CLIMATOLOGY ($CASENAME)"
	echo "****************************************************"
	ANN_RGR_FILE=${CASENAME}_ANN_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo_remap.nc
	if [ ! -f $CLIMO_TS_DIR/$ANN_RGR_FILE ]; then
	    # Check if sst file is present
	    if [ ! -f $WKDIR/attributes/co2fxd_file_${CASENAME} ]; then
		echo $required_vars_climo > $WKDIR/attributes/required_vars
		$DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo
	    fi
	    # Determine grid type from the climo file
	    if [ -z $PGRIDPATH ]; then
		$DIAG_CODE/determine_grid_type.sh $CASENAME
	    fi
	    # Add coordinate attributes if necessary
	    $DIAG_CODE/add_attributes.sh $CASENAME $ANN_AVG_FILE $CLIMO_TS_DIR
	    # Remap the grid to 1x1 rectangular grid
	    $DIAG_CODE/remap_climo.sh $CASENAME $ANN_AVG_FILE $ANN_RGR_FILE $CLIMO_TS_DIR
	    # Compute zonal mean
	    echo $required_vars_climo_zm > $WKDIR/attributes/required_zm_vars
	    $DIAG_CODE/zonal_mean.sh $CASENAME $FYR_PRNT_CLIMO $LYR_PRNT_CLIMO $CLIMO_TS_DIR
	else
	    echo "$CLIMO_TS_DIR/$ANN_RGR_FILE already exists."
	    echo "-> SKIPPING REMAPPING CLIMATOLOGY"
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
	    if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hbgcy ]; then
		$DIAG_CODE/compute_ann_time_series.sh hbgcy $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hbgcm ]; then
		$DIAG_CODE/compute_ann_time_series.sh hbgcm $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR
	    fi
	    if [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hbgcy ] && [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_hbgcm ]; then
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
# set_2: ANN_RGR_FILE
ANN_RGR_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap.nc
if [ $set_2 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_RGR_FILE1 not found: skipping set_2"
    set_2=0
elif [ $set_2 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_RGR_FILE1 ]; then
    ANN_RGR_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_RGR_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ANN_RGR_FILE2 not found: skipping set_2"
	set_2=0
    fi
fi
# set_3: ZM_FILE: assumes that all zm files exist if "glb" is present
ZM_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_remap_zm_glb.nc
if [ $set_3 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ZM_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ZM_FILE1 not found: skipping set_3"
    set_3=0
elif [ $set_3 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ZM_FILE1 ]; then
    ZM_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_remap_zm_glb.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ZM_FILE2 ]; then
	echo "$CLIMO_TS_DIR2/$ZM_FILE2 not found: skipping set_3"
	set_3=0
    fi
fi

# ---------------------------------
# Create the web interface
# ---------------------------------
WEBFOLDER=yrs${FIRST_YR_CLIMO1}to${LAST_YR_CLIMO1}-$CASENAME2
TARFILE=${WEBFOLDER}.tar
export WEBDIR=$WKDIR/$WEBFOLDER
if [ -d $WEBDIR ]; then
    rm -rf $WEBDIR
fi
mkdir -p $WEBDIR/set1
mkdir -p $WEBDIR/set2
mkdir -p $WEBDIR/set3
cp $DIAG_HTML/index.html $WEBDIR
cdate=`date`
sed -i "s/test_run/$CASENAME1/g" $WEBDIR/index.html
sed -i "s/date_and_time/$cdate/g" $WEBDIR/index.html
if [ $CNTL == USER ]; then
    sed -i "17i<br>and $CASENAME2" $WEBDIR/index.html
fi
if [ $set_1 -eq 1 ]; then
    echo "<font color=maroon size=+1><b><u>Time series plots</u></b></font><br>" >> $WEBDIR/index.html
    echo "<br>" >> $WEBDIR/index.html
fi

# ------------------
# Determine colormap
# ------------------
export RGB_FILE_DIFF=$DIAG_HOME/rgb/bluered2.rgb
export RGB_FILE=$DIAG_HOME/rgb/rainbow_marco.rgb
if [ $colormap == blueyellowred ]; then
    export RGB_FILE=$DIAG_HOME/rgb/blueyellowred2.rgb
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
    echo "Plotting time series (plot_time_series_ann.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_time_series_ann.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set1 $density
    if [ $? -ne 0 ]; then
	"ERROR occurred in ps2png.sh (set1)"
	"*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage1.sh
fi
if [ $set_2 -eq 1 ] || [ $set_3 -eq 1 ]; then
    if [ $set_1 -eq 1 ]; then
        echo "<br>" >> $WEBDIR/index.html
    fi
    echo "<font color=maroon size=+1><b><u>Climatology plots</u></b></font><br>" >> $WEBDIR/index.html
fi
#----------------------------------
# set 2: lat/lon plots
# ---------------------------------
if [ $set_2 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 2: 2D LAT/LON CONTOUR PLOTS"
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
    echo "2D contour plots (plot_latlon.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_latlon.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set2 $density
    if [ $? -ne 0 ]; then
	"ERROR occurred in ps2png.sh (set2)"
	"*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage2.sh
fi
# ---------------------------------
# set 3: zonal means
# ---------------------------------
if [ $set_3 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 3: ZONAL MEAN PLOTS"
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
    
    $DIAG_CODE/ps2png.sh set3 $density
    if [ $? -ne 0 ]; then
	"ERROR occurred in ps2png.sh (set3)"
	"*** EXITING THE SCRIPT ***"
	exit 1
    fi
    $DIAG_CODE/webpage3.sh
fi

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
    publish_html_path=$publish_html_root/$CASENAME1/HAMMOC_DIAG
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


