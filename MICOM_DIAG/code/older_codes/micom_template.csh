#!/bin/csh -f
#
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
#set CASENAME1       = N1850_f19_tn11_01_E1
set CASENAME1       = B1850MICOM_f09_tn14_01
set FIRST_YR_CLIMO1 = 21
set NYRS_CLIMO1     = 30

# ---------------------------------------------------------
# TIME SERIES SETTING FOR TEST CASE (CASE1)
# ---------------------------------------------------------
# If TRENDS_ALL=1 the time series is computed over the
# entire simulation; otherwise between first_yr_ts
# and last_yr_ts
set TRENDS_ALL      = 1
set FIRST_YR_TS1    = 0
set LAST_YR_TS1     = 0

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE1)
# ---------------------------------------------------------
set pathdat_root1   = /projects/NS2345K/noresm/cases
set PATHDAT1        = $pathdat_root1/$CASENAME1/ocn/hist

# ---------------------------------------------------------
# SELECT TYPE OF CONTROL CASE
# NOTE: CNTL=USER IS NOT YET SUPPORTED
# ---------------------------------------------------------
set CNTL = OBS    # compare case1 to observations (model-obs diagnostics)
#set CNTL = USER   # compare case1 to another experiment case2 (model-model diagnostics)

# ---------------------------------------------------------
# CNTL CASENAME AND YEARS TO BE AVERAGED (CASE2)
# ---------------------------------------------------------
set CASENAME2       = your_cntl_simulation
set FIRST_YR_CLIMO2 = fyr_of_cntl
set NYRS_CLIMO2     = nyr_of_cntl

# ---------------------------------------------------------
# TIME SERIES SETTING FOR CNTL CASE (CASE2)
# ---------------------------------------------------------
set FIRST_YR_TS2    = 0
set LAST_YR_TS2     = 0

# ---------------------------------------------------------
# ROOT DIRECTORY FOR HISTORY FILES (CASE2)
# ---------------------------------------------------------
set pathdat_root2   = /path/to/cntl_case/history
set PATHDAT2        = $pathdat_root2/$CASENAME2/ocn/hist

# ---------------------------------------------------------
# SELECT DIRECTORY WHERE THE DIAGNOSTICS ARE TO BE COMPUTED
# ---------------------------------------------------------
set DIAG_ROOT       = /scratch/johiak/micom_diag

# ---------------------------------------------------------
# WEB OPTIONS
# ---------------------------------------------------------
# Publish the html on the NIRD web server, and set the path
# where it should be published. If the path is left empty,
# it is set to /projects/NS2345K/www/noresm_diagnostics.
# The figures are converted to png. The quality of the
# figures is determined by the density variable.
set publish_html      = 1 # (1=ON,0=OFF)
set publish_html_root = /path/to/html/directory
set density           = 85

# ---------------------------------------------------------
# SELECT SETS (1-4)
# ---------------------------------------------------------
set set_1 = 1 # (1=ON,0=OFF) Time series plots incl. ENSO
set set_2 = 1 # (1=ON,0=OFF) 2D (lat/lon) contour plots
set set_3 = 1 # (1=ON,0=OFF) 2D (lat/lon) vector plots
set set_4 = 1 # (1=ON,0=OFF) MOCs for different regions

# ---------------------------------------------------------
# SWITCH BETWEEN CLIMO AND TIME-SERIES COMPUTATION
# ---------------------------------------------------------
# Valid options: ONLY_CLIMO, ONLY_TIME_SERIES  AND
# SWITCHED_OFF (computes both).
set CLIMO_TIME_SERIES_SWITCH = ONLY_TIME_SERIES

# ---------------------------------------------------------
# ROOT DIRECTORY TO ALL THE DIAGNOSTICS SCRIPTS
# ---------------------------------------------------------
# Do not change this unless you copy the whole diagnostics
# package (including all grid files and observational data)
# to another directory.
setenv DIAG_HOME /projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG

#**********************************
#*** END OF USER MODIFY SECTION ***
#**********************************

# --------------------
# PART0: INITAL CHECKS
# --------------------

# Set c-shell limits
limit stacksize unlimited
limit datasize  unlimited

# Check for NCL environment
unset noclobber
if (! $?NCARG_ROOT) then
  echo "ERROR: environment variable NCARG_ROOT is not set"
  echo "Do this in your .bashrc file (or whatever shell you use)"
  echo "*** EXITING THE SCRIPT ***"
  exit 1
else
  set NCL = $NCARG_ROOT/bin/ncl
endif

# Check for CDO
setenv CDO `which cdo`
if ($status > 0) then
   echo "ERROR: found no CDO (Climate Data Operators)"
   echo "You might try the following:"
   echo "module load cdo"
   echo "*** EXITING THE SCRIPT ***"
   exit 1
endif

# Set environmental directories
setenv WKDIR     $DIAG_ROOT/diag/$CASENAME1
setenv DIAG_CODE $DIAG_HOME/code
setenv DIAG_GRID $DIAG_HOME/grid_files
setenv DIAG_ETC  $DIAG_HOME/etc

# Set directories for climatology and time series
set CLIMODIR1 = $DIAG_ROOT/climo/$CASENAME1
set RGRDIR1   = $DIAG_ROOT/climo_rgr/$CASENAME1
set ZMDIR1    = $DIAG_ROOT/climo_zm/$CASENAME1
set TSDIR1    = $DIAG_ROOT/time_series/$CASENAME1
if ($CNTL == USER) then
   set CLIMODIR2 = $DIAG_ROOT/climo/$CASENAME2
   set RGRDIR2   = $DIAG_ROOT/climo_rgr/$CASENAME2
   set ZMDIR2    = $DIAG_ROOT/climo_zm/$CASENAME2
   set TSDIR2    = $DIAG_ROOT/time_series/$CASENAME2
   set diag_type = model1-model2
else if ($CNTL == OBS) then
   set CASENAME2 = OBS
   set diag_type = model-obs
else
   echo "ERROR: CNTL must be set to either OBS or USER"
   echo "*** EXITING THE SCRIPT ***"
   exit 1
endif

# Create directories
if (-d $WKDIR/attributes) then
   rm -rf $WKDIR/attributes
endif
mkdir -p $WKDIR/attributes
if (! -d $CLIMODIR1) then
   mkdir -p $CLIMODIR1
endif
if (! -d $RGRDIR1) then
   mkdir -p $RGRDIR1
endif
if (! -d $ZMDIR1) then
   mkdir -p $ZMDIR1
endif
if (! -d $TSDIR1) then
   mkdir -p $TSDIR1
endif

if ($CNTL == USER) then
   if (! -d $CLIMODIR2) then
      mkdir -p $CLIMODIR2
   endif
   if (! -d $RGRDIR2) then
      mkdir -p $RGRDIR2
   endif
   if (! -d $ZMDIR2) then
      mkdir -p $ZMDIR2
   endif
   if (! -d $TSDIR2) then
      mkdir -p $TSDIR2
   endif
endif

# Write years with four digits
@ LAST_YR_CLIMO1    = $NYRS_CLIMO1 + $FIRST_YR_CLIMO1 - 1
set FYR_PRNT_CLIMO1 = `printf "%04d" ${FIRST_YR_CLIMO1}`
set LYR_PRNT_CLIMO1 = `printf "%04d" ${LAST_YR_CLIMO1}`
if ($CNTL == USER) then
   @ LAST_YR_CLIMO2    = $NYRS_CLIMO2 + $FIRST_YR_CLIMO2 - 1
   set FYR_PRNT_CLIMO2 = `printf "%04d" ${FIRST_YR_CLIMO2}`
   set LYR_PRNT_CLIMO2 = `printf "%04d" ${LAST_YR_CLIMO2}`
endif

# Set required variables for climatology and time series
set required_vars_climo = "depth_bnds,sst,templvl,salnlvl,mmflxd,region"
set required_vars_ts    = "depth_bnds,time,section,voltr,sst,temp,saln,templvl,salnlvl,mmflxd,region,dp"

# Check which sets should be plotted based on CLIMO_TIME_SERIES_SWITCH
if ($CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO) then
   set set_1 = 0 ; set set_2 = 1 ; set set_3 = 1 ; set set_4 = 1
else if ($CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES) then
   set set_1 = 1 ; set set_2 = 0 ; set set_3 = 0 ; set set_4 = 0
endif
set compute_climo = 0
set compute_time_series = 0
if ($set_1 == 1) then
   set compute_time_series = 1
endif
if ($set_2 == 1 || $set_3 == 1 || $set_4 == 1) then
   set compute_climo = 1
endif
if ($compute_climo == 1 && $compute_time_series == 0) then
   set diag_type2 = "climatology"
else if ($compute_climo == 0 && $compute_time_series == 1) then
   set diag_type2 = "time-series"
else if ($compute_climo == 1 && $compute_time_series == 1) then
   set diag_type2 = "climatology & time-series"
else
   echo "ERROR: All sets are zero. Please modify."
   echo "*** EXITING THE SCRIPT ***"
   exit 1
endif

echo " "
echo "***************************************************"
echo "          MICOM DIAGNOSTICS PACKAGE"
echo "          NCARG_ROOT = "$NCARG_ROOT
echo "          CDO        = "$CDO
echo "          "`date`
echo "***************************************************"
echo "Computing $diag_type $diag_type2 diagnostics for"
echo "CASENAME1 = $CASENAME1"
echo "CASENAME2 = $CASENAME2"
echo "***************************************************"

if ($compute_climo == 1) then
# ---------------------------------
# PART1: Compute annual climatology
# ---------------------------------
# Strategy:
# 1. First attempt to compute climatology from the annual-mean history files (hy)
# 2. Use the monthly-mean history files (hm) for the remaining variables, or if hy files don't exist
echo " "
echo "***************************************************"
echo "COMPUTING CLIMATOLOGY ($CASENAME1)"
echo "***************************************************"
set ANN_AVG_FILE1 = ${CASENAME1}_ANN_${FYR_PRNT_CLIMO1}-${LYR_PRNT_CLIMO1}_climo.nc
# Check if annual climo file already exists
if (! -e $CLIMODIR1/$ANN_AVG_FILE1) then
   echo $required_vars_climo > $WKDIR/attributes/required_vars
   # Check if the annual files with the required vars are present ...
   $DIAG_CODE/check_history_climo.csh hy $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1
   if (-e $WKDIR/attributes/vars_${CASENAME1}_climo_hy) then
      # ... if they are: compute climatology
      $DIAG_CODE/compute_climo.csh hy $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 $CLIMODIR1
      if (-e $WKDIR/attributes/vars_remaining) then
         cp $WKDIR/attributes/vars_remaining $WKDIR/attributes/required_vars
         # Check if vars not included in annual files are included in the monthly files ...
         $DIAG_CODE/check_history_climo.csh hm $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1
         if (-e $WKDIR/attributes/vars_${CASENAME1}_climo_hm) then
            # ...if they are: compute climatology
            $DIAG_CODE/compute_climo.csh hm $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 $CLIMODIR1
         endif
      endif
   else
      # If no annual history files are present: resort to monthly files
      $DIAG_CODE/check_history_climo.csh hm $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1
      if (-e $WKDIR/attributes/vars_${CASENAME1}_climo_hm) then
         $DIAG_CODE/compute_climo.csh hm $CASENAME1 $FIRST_YR_CLIMO1 $LAST_YR_CLIMO1 $PATHDAT1 $CLIMODIR1
      else
         echo "ERROR: none of the required variables found in the annual (hy) or monthly (hm) history files."
	 exit 1
      endif
   endif
   # Concancate files if necessary
   $DIAG_CODE/concancate_files.csh $CASENAME1 $FYR_PRNT_CLIMO1 $LYR_PRNT_CLIMO1 $CLIMODIR1 climo
else
   echo "$CLIMODIR1/$ANN_AVG_FILE1 already exists."
   echo "-> SKIPPING COMPUTING CLIMATOLOGY"
endif

# ---------------------------------
# PART2: Remapping climatology
# ---------------------------------
echo " "
echo "***************************************************"
echo "REMAPPING CLIMATOLOGY ($CASENAME1)"
echo "***************************************************"
# Determine grid type from the climo file
$DIAG_CODE/determine_grid_type.csh $CASENAME1 $ANN_AVG_FILE1 $CLIMODIR1
# Add coordinate attributes if necessary
$DIAG_CODE/add_attributes.csh $ANN_AVG_FILE1 $CLIMODIR1
# Remap the grid to 1x1 rectangular grid
$DIAG_CODE/remap_climo.csh $CASENAME1 $ANN_AVG_FILE1 $CLIMODIR1 $RGRDIR1
endif

if ($compute_time_series == 1) then
# ---------------------------------
# PART3: Compute annual time series
# ---------------------------------
echo " "
echo "***************************************************"
echo "ANNUAL TIME SERIES ($CASENAME1)"
echo "***************************************************"
# Determine the first and last yr of time series (if TRENDS_ALL=1)
if ($TRENDS_ALL == 1) then
   echo "TRENDS_ALL=1: time series over the entire simulation"
   # First, check annual files
   echo "Searching for annual history files..."
   set file_head   = $CASENAME1.micom.hy.
   set file_prefix = $PATHDAT1/$file_head
   set first_file  = `ls ${file_prefix}* | head -n 1`
   set last_file   = `ls ${file_prefix}* | tail -n 1`
   if ("$first_file" == "") then
      echo "Found no annual history files in $PATHDAT1"
      echo "Searcing for monthly history files"
      set file_head   = $CASENAME1.micom.hm.
      set file_prefix = $PATHDAT1/$file_head
      set first_file  = `ls ${file_prefix}* | head -n 1`
      set last_file   = `ls ${file_prefix}* | tail -n 1`
      if ("$first_file" == "") then
         echo "ERROR: found no monthly history files in $PATHDAT1"
	 echo "*** EXITING THE SCRIPT ***"
	 exit 1
      else
         set FYR_PRNT_TS1 = `echo $first_file | rev | cut -c 7-10 | rev`
         set FIRST_YR_TS1 = `echo $FYR_PRNT_TS1 | sed 's/^0*//'`
         set LYR_PRNT_TS1 = `echo $last_file | rev | cut -c 7-10 | rev`
         set LAST_YR_TS1  = `echo $LYR_PRNT_TS1 | sed 's/^0*//'`
	 # Check that last file is a december file (for a full year)
	 if ($last_file != $PATHDAT1/${file_head}${LYR_PRNT_TS1}-12.nc) then
	    @ LAST_YR_TS1 = $LAST_YR_TS1 - 1
	 endif
         if ($FIRST_YR_TS1 == $LAST_YR_TS1) then
            echo "ERROR: first and last year in ${CASENAME1} are identical: cannot compute trends"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
         endif
      endif
   else
      set FYR_PRNT_TS1 = `echo $first_file | rev | cut -c 4-7 | rev`
      set FIRST_YR_TS1 = `echo $FYR_PRNT_TS1 | sed 's/^0*//'`
      set LYR_PRNT_TS1 = `echo $last_file | rev | cut -c 4-7 | rev`
      set LAST_YR_TS1  = `echo $LYR_PRNT_TS1 | sed 's/^0*//'`
      if ($FIRST_YR_TS1 == $LAST_YR_TS1) then
         echo "ERROR: first and last year in ${CASENAME1} are identical: cannot compute trends"
         echo "*** EXITING THE SCRIPT ***"
         exit 1
      endif
   endif
endif
echo "FIRST_YR = $FIRST_YR_TS1"
echo "LAST_YR  = $LAST_YR_TS1"

set ANN_TS_FILE1 = ${CASENAME1}_ANN_${FYR_PRNT_TS1}-${LYR_PRNT_TS1}_ts.nc
# Check if annual time series file already exists
if (! -e $TSDIR1/$ANN_TS_FILE1) then
   # Determine grid type if it hasn't been done above
   if (! -e $WKDIR/attributes/grid_${CASENAME1}) then
      set test_file_name = ${CASENAME1}.micom.hy.${FYR_PRNT_TS1}.nc
      $DIAG_CODE/determine_grid_type.csh $CASENAME1 $test_file_name $PATHDAT1
      if (! -e $WKDIR/attributes/grid_${CASENAME1}) then
         set test_file_name = ${CASENAME1}.micom.hm.${FYR_PRNT_TS1}-01.nc
         $DIAG_CODE/determine_grid_type.csh $CASENAME1 $test_file_name $PATHDAT1
	 if (! -e $WKDIR/attributes/grid_${CASENAME1}) then
	    echo "*** EXITING THE SCRIPT ***"
	    exit 1
	 endif
      endif
   endif
   echo $required_vars_ts > $WKDIR/attributes/required_vars
   # Check if the annual files with the required vars are present ...
   $DIAG_CODE/check_vars_time_series.csh hy $CASENAME1 $FYR_PRNT_TS1 $PATHDAT1
   if (-e $WKDIR/attributes/vars_${CASENAME1}_ts_hy) then
      # ... if they are: compute time-series
      $DIAG_CODE/compute_time_series.csh hy $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $TSDIR1
      if (-e $WKDIR/attributes/vars_remaining) then
         cp $WKDIR/attributes/vars_remaining $WKDIR/attributes/required_vars
         # Check if vars not included in annual files are included in the monthly files ...
         $DIAG_CODE/check_vars_time_series.csh hm $CASENAME1 $FYR_PRNT_TS1 $PATHDAT1
         if (-e $WKDIR/attributes/vars_${CASENAME1}_ts_hm) then
            # ...if they are: compute climatology
            $DIAG_CODE/compute_time_series.csh hm $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $TSDIR1
         endif
      endif
   else
      # If no annual history files are present: resort to monthly files
      $DIAG_CODE/check_vars_time_series.csh hm $CASENAME1 $FYR_PRNT_TS1 $PATHDAT1
      if (-e $WKDIR/attributes/vars_${CASENAME1}_ts_hm) then
         $DIAG_CODE/compute_time_series.csh hm $CASENAME1 $FIRST_YR_TS1 $LAST_YR_TS1 $PATHDAT1 $TSDIR1
      else
         echo "ERROR: none of the required variables found in the annual (hy) or monthly (hm) history files."
	 exit 1
      endif
   endif
   # Concancate files if necessary
   $DIAG_CODE/concancate_files.csh $CASENAME1 $FYR_PRNT_TS1 $LYR_PRNT_TS1 $TSDIR1 ts
else
   echo "$TSDIR1/$ANN_TS_FILE1 already exists."
   echo "-> SKIPPING COMPUTING TIME SERIES"
endif
endif

#$DIAG_CODE/check_vars_time_series.csh
