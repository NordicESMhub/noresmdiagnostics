#!/bin/bash
# set -e
#
# CISM DIAGNOSTICS package
# Heiko Goelzer, NORCE, heig@norceresearch.no 
# Last update 11.01.2022

## LOAD MODULES AND SET ENVIRONMENTS
HOST="$(uname -n) $(hostname -f)"
if [ "$(echo $HOST |grep 'ipcc.nird')" ];then
    export NCARG_ROOT=/opt/ncl66
    export NCARG_COLORMAPS=$NCARG_ROOT/lib/ncarg/colormaps
    export PATH=/usr/bin:/opt/ncl66/bin:/opt/cdo201/bin
elif [ "$(echo $HOST |grep 'login[0-9].nird')" ];then
    export NCARG_ROOT=/usr
    export NCARG_COLORMAPS=$NCARG_ROOT/lib/ncarg/colormaps
    export PATH=/usr/bin:/usr/local/bin:/opt
elif [ "$(echo $HOST |grep 'betzy')" ]; then
     module -q purge
     module -q load NCO/4.9.3-intel-2019b
     module -q load CDO/1.9.8-intel-2019b
     module -q load NCL/6.6.2-intel-2019b
     module unload HDF/4.2.14-GCCcore-8.3.0
     module -q load ImageMagick/7.1.0-4-GCCcore-11.2.0
else
    echo "** UNKNOWN HOST $HOST **"
    echo "** EXIT                   **"
    exit
fi

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

# Control if align the USER case time series to the TEST case (fyr1)
# Valide values: [0 (default) | 1]
export NO_ALIGN=if_align_ts_flag
# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE1)
# ---------------------------------------------------------
pathdat_root1=/path/to/test_case/history
PATHDAT1=$pathdat_root1/$CASENAME1/glc/hist

# ---------------------------------------------------------
# SELECT TYPE OF CONTROL CASE
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
PATHDAT2=$pathdat_root2/$CASENAME2/glc/hist

# ---------------------------------------------------------
# SELECT DIRECTORY WHERE THE DIAGNOSTICS ARE TO BE COMPUTED
# ---------------------------------------------------------
DIAG_ROOT=/path/to/your/diagnostics

# ---------------------------------------------------------
# SELECT SETS (1-2)
# ---------------------------------------------------------
set_1=1 # (1=ON,0=OFF) time series
set_2=1 # (1=ON,0=OFF) Atlas 2D (x-y) geometry plots

# ---------------------------------------------------------
# WEB OPTIONS
# ---------------------------------------------------------
# Publish the html on the NIRD web server, and set the path
# where it should be published. If the path is left empty,
# it is set to /projects/NS2345K/www/noresm.
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
export NCARG_USRRESFILE=${DIAG_HOME}/../../bin/.hluresfile

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
export NCDUMP=`which ncdump`
if [ $? -ne 0 ]; then
    echo "Could not find ncdump (which ncdump)"
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
required_vars_climo="artm,smb,thk"
required_vars_ts_ann="artm,smb,thk,usurf,topg"

# Check which sets should be plotted based on CLIMO_TIME_SERIES_SWITCH
if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO ]; then
    set_1=0 ; set_2=1 
elif [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
    set_1=1 ; set_2=0 
    FIRST_YR_CLIMO1=0 ; NYRS_CLIMO1=0
    FIRST_YR_CLIMO2=0 ; NYRS_CLIMO2=0
fi
compute_climo=0
compute_time_series_ann=0
if [ $set_1 -eq 1 ]; then
    compute_time_series_ann=1
fi
if [ $set_2 -eq 1 ]; then
    compute_climo=1
fi
#if [ $set_1 -eq 0 ] && [ $set_2 -eq 0 ] && [ $set_3 -eq 0 ] && \
#   [ $set_4 -eq 0 ] && [ $set_5 -eq 0 ] && [ $set_6 -eq 0 ] && [ $set_7 -eq 0 ]; then
#    echo "ERROR: All sets are zero. Please modify."
#    echo "*** EXITING THE SCRIPT ***"
#    exit 1
#fi

echo " "
echo "****************************************************"
echo "          CISM DIAGNOSTICS PACKAGE"
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

## CISM yearly filenames are offset by one year
#echo "Adjust timestamps for CISM" 
#let "FIRST_YR_CLIMO1 = $FIRST_YR_CLIMO1 + 1"
#let "FIRST_YR_TS1 = $FIRST_YR_TS1 + 1"
#let "LAST_YR_TS1 = $LAST_YR_TS1 + 1"
#echo "FIRST_YR_CLIMO1 = ${FIRST_YR_CLIMO1}"
#echo "FIRST_YR_TS1  = ${FIRST_YR_TS1}"
#echo "LAST_YR_TS1  = ${LAST_YR_TS1}"


#if [ $CNTL == USER ]; then
    #let "FIRST_YR_CLIMO2 = $FIRST_YR_CLIMO2 + 1"
    #let "FIRST_YR_TS2 = $FIRST_YR_TS2 + 1"
    #let "LAST_YR_TS2 = $LAST_YR_TS2 + 1"
    #echo "FIRST_YR_CLIMO2 = ${FIRST_YR_CLIMO2}"
    #echo "FIRST_YR_TS2  = ${FIRST_YR_TS2}"
    #echo "LAST_YR_TS2  = ${LAST_YR_TS2}"
#fi

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
            if [ -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_h ]; then
                $DIAG_CODE/compute_ann_time_series.sh h $CASENAME $FIRST_YR_TS $LAST_YR_TS $PATHDAT $CLIMO_TS_DIR
            fi
            if [ ! -f $WKDIR/attributes/vars_ts_ann_${CASENAME}_h ]; then
                echo "WARNING: could not find required variables ($required_vars_ts_mon) for annual time series."
                echo "-> SKIPPING COMPUTING ANNUAL TIME SERIES"
            fi
        else
            echo "$CLIMO_TS_DIR/$ANN_TS_FILE already exists."
            echo "-> SKIPPING COMPUTING ANNUAL TIME SERIES"
        fi
    fi

    if [ $compute_climo -eq 1 ]; then
        # ---------------------------------
        # Compute climatology
        # ---------------------------------
        echo " "
        echo "****************************************************"
        echo "COMPUTING CLIMATOLOGY ($CASENAME)"
        echo "****************************************************"
        ANN_AVG_FILE=${CASENAME}_ANN_${FYR_PRNT_CLIMO}-${LYR_PRNT_CLIMO}_climo.nc
        # Check if annual climo file already exists
        if [ -f $CLIMO_TS_DIR/$ANN_AVG_FILE ] ; then
            echo "$CLIMO_TS_DIR/$ANN_AVG_FILE already exist."
            echo "-> SKIPPING COMPUTING CLIMATOLOGY"
        else
            echo $required_vars_climo > $WKDIR/attributes/required_vars
            $DIAG_CODE/check_history_vars.sh $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT climo_ann
            if [ -f $WKDIR/attributes/vars_climo_ann_${CASENAME}_h ]; then
                $DIAG_CODE/compute_climo.sh h $CASENAME $FIRST_YR_CLIMO $LAST_YR_CLIMO $PATHDAT $CLIMO_TS_DIR
            fi
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

# set_2: ANN_AVG_FILE
ANN_AVG_FILE1=${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_h.nc
if [ $set_2 -eq 1 ] && [ ! -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
    echo "$CLIMO_TS_DIR1/$ANN_AVG_FILE1 not found: skipping set_2"
    set_2=0
elif [ $set_2 -eq 1 ] && [ -f $CLIMO_TS_DIR1/$ANN_AVG_FILE1 ]; then
    ANN_AVG_FILE2=${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_h.nc
    if [ $CNTL == USER ] && [ ! -f $CLIMO_TS_DIR2/$ANN_AVG_FILE2 ]; then
        echo "$CLIMO_TS_DIR2/$ANN_AVG_FILE2 not found: skipping set_2"
        set_2=0
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
#if [ -d $WEBDIR ]; then
#    rm -rf $WEBDIR
#fi
mkdir -m 775 -p $WEBDIR/set1
mkdir -m 775 -p $WEBDIR/set2
if [ ! -d $WEBDIR ]
then
    echo "** ERROR: making web folder: $WEBDIR **"
    echo "**                 EXIT              **"
    exit 1
fi

export cinfo=1model
if [ $CNTL == USER ]; then
    export cinfo=2models
fi

# BLOM format index page
cp -r $DIAG_HTML/images/ $WEBDIR/
chmod g+w $WEBDIR/images
cp $DIAG_HTML/index1.html $WEBDIR/index.html
cdate=`date`
sed -i "s/test_run/$CASENAME1/g" $WEBDIR/index.html
sed -i "s/date_and_time/$cdate/g" $WEBDIR/index.html
#if [ $CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES ]; then
    sed -i "s/FY1/$FIRST_YR_TS1/g" $WEBDIR/index.html
    sed -i "s/LY1/$LAST_YR_TS1/g" $WEBDIR/index.html
#fi
if [ $CNTL == USER ]; then
    sed -i "12i<br><b>and $CASENAME2 yrs${FIRST_YR_CLIMO2}to${LAST_YR_CLIMO2}<b><br>" $WEBDIR/index.html
fi
if [ $set_1 -eq 1 ] ; then
    echo '<h2 id="Time-series-plots">Time series plots</h2>' >> $WEBDIR/index.html
fi

cd $WKDIR
# ---------------------------------
# set 1: Time series
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
    echo "Plotting time series avg (plot_time_series_ann.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_time_series_ann.ncl

    # scalars
    export COMPARE=$CNTL
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_ts_scl.nc
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_TS1
    if [ $CNTL == USER ]; then
        export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_TS2}-${LYR_PRNT_TS2}_ts_scl.nc
        export CASE2=$CASENAME2
        export FYR2=$FIRST_YR_TS2
    fi
    echo "Plotting time series scl (plot_time_series_ann_scl.ncl)..."
    $NCL -Q < $DIAG_CODE/plot_time_series_ann_scl.ncl
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set1 $density
    if [ $? -ne 0 ]; then
        "ERROR occurred in ps2png.sh (set1)"
        #"*** EXITING THE SCRIPT ***"
        #exit 1
    fi

    echo " "
    echo "-----------------------"
    echo "Generating html for set1 plots"
    echo "-----------------------"
    echo " "
    $DIAG_CODE/webpage1new.sh
    sed -i "s/CINFO.png/${cinfo}.png/g" $WEBDIR/index.html
fi

if [ $set_2 -eq 1 ] ; then
    echo '<hr noshade size=2 width="62.8%"><br>' >> $WEBDIR/index.html
    echo '<h2 id="Climatology-plots">Climatology plots</h2>' >> $WEBDIR/index.html
fi

# ---------------------------------
# set 2: 2d plots x,y
# ---------------------------------
if [ $set_2 -eq 1 ]; then
    echo " "
    echo "****************************************************"
    echo "SET 2: 2d Plots"
    echo "****************************************************"
    export COMPARE=$CNTL
    export CASE1=$CASENAME1
    export FYR1=$FIRST_YR_CLIMO1
    export LYR1=$LAST_YR_CLIMO1
    export INFILE1=$CLIMO_TS_DIR1/${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo_h.nc
    if [ $CNTL == USER ]; then
        export CASE2=$CASENAME2
        export FYR2=$FIRST_YR_CLIMO2
        export LYR2=$LAST_YR_CLIMO2
        export INFILE2=$CLIMO_TS_DIR2/${CASENAME2}_ANN_${FYR_PRNT_CLIMO2}-${LYR_PRNT_CLIMO2}_climo_h.nc
    fi
    echo "2d plots (Atlas_CISM.sh, atlas_fun.ncl) ..."

    # Atlas configuration
    defaults_file="$DIAG_CODE/Atlas_defaults_CISM.txt"
    
    ##########################################
    
    # Arrays for parameters
    exps=()
    vars=()
    tsps=()
    pals=()
    mods=()
    mins=()
    maxs=()
    lsps=()
    lvls=()
    
    count=0
    
    # Read parameters from file line by line
    while read -r parameters
    do
	IFS=" " read -a par_array <<< "$parameters"
	exps+=(${par_array[0]})
	vars+=(${par_array[1]})
	tsps+=(${par_array[2]})
	pals+=(${par_array[3]})
	mods+=(${par_array[4]})
	mins+=(${par_array[5]})
	maxs+=(${par_array[6]})
	lsps+=(${par_array[7]})
	lvls+=(${par_array[8]})
	count=$count+1
    done < "$defaults_file"
    
    
    # Loop through variables 
    for (( i=0; i<$count; i++ ))
    do
	
	export aexp=${exps[i]}
	export avar=${vars[i]}
	export atsp=${tsps[i]}
	export apal=${pals[i]}
	export amod=${mods[i]}
	export amin=${mins[i]}
	export amax=${maxs[i]}
	export alsp=${lsps[i]}	
	export alvl1=${lvls[i]}
	export alvl=`echo $alvl1 | tr -d '"'`
	echo $apal
	# call ncl script passing shell variable (-Q supresses startup note)  
	$NCL -Q < $DIAG_CODE/atlas_fun.ncl

    done
    
    # Convert time series figure to png
    $DIAG_CODE/ps2png.sh set2 $density
    if [ $? -ne 0 ]; then
        echo "ERROR occurred in ps2png.sh (set2)"
        #echo "*** EXITING THE SCRIPT ***"
        #exit 1
    fi
    $DIAG_CODE/webpage2.sh

    # new index page
    echo " "
    echo "-----------------------"
    echo "Generating html for set2 plots"
    echo "-----------------------"
    echo " "
    $DIAG_CODE/webpage2new.sh
fi

# Closing the webpage
cat $DIAG_HTML/index2.html >> $WEBDIR/index.html
# cleanup orphan links
$DIAG_CODE/webpage_rmorphan.sh $WEBDIR/index.html

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
        publish_html_root=${web_server_path}/diagnostics/noresm
    fi
    publish_html_path=$publish_html_root/$CASENAME1/CISM_DIAG
    if [ ! -d $publish_html_path ]; then
        mkdir -m 775 -p $publish_html_path
    else
        if [ $(stat -c %a ${publish_html_path}) != 775 ];then
            chmod 775 ${publish_html_path}
        fi
    fi
    web_server=http://ns2345k.web.sigma2.no
    path_pref=`echo ${publish_html_path} | cut -c -21`
    path_suff=`echo ${publish_html_path} | cut -c 23-`
    tar -xf $TARFILE -C $publish_html_path
    if [ $? -eq 0 ]; then
        if [ $path_pref == $web_server_path ]; then
            full_url=${web_server}/${path_suff}/${WEBFOLDER}/index.html
            $DIAG_CODE/redirect_html.sh $WEBFOLDER $publish_html_path ${WEBFOLDER}/index.html
            echo " "
            echo "URL:"
            echo "***********************************************************************************"
            echo "${web_server}/${path_suff}/${WEBFOLDER}/index.html"
            echo "***********************************************************************************"
            echo "Copy and paste the URL into the address bar of your web browser to view the results"
        else
            echo " "
            echo "The html files are located in:"
            echo "${publish_html_path}/"
            echo "(not on the NIRD web server)"
        fi
    fi
fi
# Cleaning up
#if [ -d $WEBDIR ]; then
#    rm -rf $WEBDIR
#fi
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


