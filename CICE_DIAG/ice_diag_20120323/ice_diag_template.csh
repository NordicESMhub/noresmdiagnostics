#!/bin/csh -f
#set PATH = ($PATH ./ )

unset echo verbose
# Modified by Johan Liakka, Oct 2017
# Major updates include:
# - Better performance climatology computation (ncclimo)
# - Updated web interface for NIRD
# - NCL updates to version 4.6.0.

#--------------------------------------------------------------------#
#----------------- USER DEFINED INPUT -------------------------------#
#--------------------------------------------------------------------#

# Set the cases to contour and/or difference

setenv CASE_TO_CONT your_test_simulation     # For plotting a single case 
setenv CASE_TO_DIFF your_cntl_simulation     # Difference plots will be of the form:
                                             # CASE_TO_CONT - CASE_TO_DIFF

# Grid type is only necessary for difference plots
# If both cases are on the same grid, differences and plots will be
#    done on native grid.  
# If these grids are different, both cases will be interpolated to 1x1
#    grid, top 2 case plots will be done on the native grid, and difference
#    plots will be done on 1x1 grid.  This requires SCRIP remapping files,
#    currently set up for gx3v4->1x1 and gx1v3->1x1.

setenv GRID_CONT tn11       
setenv GRID_DIFF tn11

# Determine if all completed model years should be used for plotting trends
# JL, Nov 2017
set TRENDS_ALL = 1

# If TRENDS_ALL=0, the following needs to be set
set BEGYRS = ( 1 1 )           # Beginning years for line plots
set ENDYRS = ( 100 100 )           # Ending years for line plots

# NCLIMO=1: Manually set the years over which climatology should be computed
# NCLIMO=0: Climatology computed over the last $YRS_TO_AVG years of the trends,
#           set by BEGYRS and ENDYRS above.
set NCLIMO = 1

if ($NCLIMO == 1) then
    set FIRST_YR_CLIMO1 = fyr_of_test # First year of climatology in CASE_TO_CONT
    set NYRS_CLIMO1     = nyr_of_test # Numbers of year of climatology in CASE_TO_CONT
    set FIRST_YR_CLIMO2 = fyr_of_cntl # First year of climatology in CASE_TO_CONT
    set NYRS_CLIMO2     = nyr_of_cntl # Numbers of year of climatology in CASE_TO_CONT
else
    set YRS_TO_AVG =  30                # for contour plots
endif

# Check if climo/time-series switch has been used by diag_run
# -JL, Nov 2017 
set CLIMO_TIME_SERIES_SWITCH = SWITCHED_OFF

setenv X1_OFF 0
setenv X2_OFF 0

setenv HIRES 1 # Should be set to 1 for tripolar grids -JL, Nov 2017

#----------------------------
#---- Set the pathnames  ----
#----------------------------

#--- The directory location of this script:
#--- It is recommded that this stay the same as DIAG_HOME.

set SCRIPT_HOME = /path/to/your/diagnostics

#--- Set DIAG_HOME to the root location of the diagnostic code.

setenv DIAG_HOME /path/to/code/and/data

#--- setenv SCRATCH /work/$LOGNAME/noresm/cice_diag
setenv SCRATCH $SCRIPT_HOME

#--- The data for CASE_TO_CONT and CASE_TO_DIFF will be read from here:
#--- Don't forget the trailing /
set DATA_ROOT1 = /path/to/test_case/history/
set DATA_ROOT2 = /path/to/cntl_case/history/

#--- The root directory for the .png and .ps plots:
setenv PLOT_ROOT  $SCRATCH/web_plots/$CASE_TO_CONT

#--- The pre-processed data for the line plots will go here:
setenv PRE_PROC_ROOT ${SCRIPT_HOME}/pre_process

#--- These data files are now in the diagnostics directory
#set SSMI_PATH = ${DIAG_HOME}/data/SSMI_fi_1x1d.nc
#--- newer ccsm/polar directory *and* filename for 1979-2000 SSMI data:
set SSMI_PATH = ${DIAG_HOME}/data/SSMI.ifrac.1979-2000monthlymean.gx1v5.nc
#--- ccsm/polar directory *and* filename for ASPeCt ice and snow thickness data:
set ASPeCt_PATH = ${DIAG_HOME}/data/ASPeCt_monthly_1x1.nc

# Move to new filenames for CICE
# b31.020ws uses FILE_VAR_TYPE=OLD, VAR_NAME_TYPE=OLD, BEGYRS=1
# b31.021   uses FILE_VAR_TYPE=NEW, VAR_NAME_TYPE=NEW, BEGYRS=1

set FILE_VAR_TYPE = ( NEW NEW )   # OLD/NEW for ice/hist directories
set VAR_NAME_TYPE = ( NEW NEW )   # OLD for $CASE csim netCDF filenames
                                  # NEW for $CASE cice netCDF filenames
                                  # OLD for u, v var names
                                  # NEW for uvel, vvel var names
set DATE_FORMAT = 'yyyy-mm'       # History filename date format

# Select type of data to compare your simulation with (JL, Nov 2017).
# CNTL = OBS   : plots a single case vs. observations:
#                (PLOT_CONT=1     , PLOT_VECT=1     , PLOT_LINE=1)
#                (PLOT_CONT_DIFF=0, PLOT_VECT_DIFF=0, PLOT_LINE_DIFF=0) 
# CNTL = USER  : makes difference plots between two cases:
#                (PLOT_CONT=0     , PLOT_VECT=0     , PLOT_LINE=0)
#                (PLOT_CONT_DIFF=1, PLOT_VECT_DIFF=1, PLOT_LINE_DIFF=1)
# CNTL = OFF   : user must set all PLOT_* variables manually.
set CNTL = type_of_control_case

# Set these to plot a single case:  CASE_TO_CONT
set PLOT_CONT =  0               # 1--> make contour plots
set PLOT_VECT =  0               # 1--> make vector plots
setenv PLOT_LINE  0               # 1--> make line plots 

# Set these to plot difference plots, CASE_TO_CONT - CASE_TO_DIFF
set PLOT_CONT_DIFF =  0          # 1 --> make contour plots
set PLOT_VECT_DIFF =  0          # 1 --> make vector plots
setenv PLOT_LINE_DIFF 0          # 1 --> make line plots 

# Set this to plot regional plots: 0 = NH/SH only, NH,SH and all regions
set PLOT_REGIONS = 1		 # 1 --> make regional plots

# set YRS_TO_KEEP =   $YRS_TO_AVG  # years of data to keep
set KEEP_PS_FILES = 0            # Keep .ps files, 1 = yes 

# Transfer the tarred .png plots to a remote system and email me
# when it's done.

# The transfer option is no longer supported.
#set transfer = 0                 # 1 --> true
#set remote_system = $LOGNAME'@ucar.edu'
#set remote_dir = /data/southern/d2/$LOGNAME
#set email_address = $LOGNAME'@ucar.edu'

# JL, Oct 2017
# Follows the same structure as AMWG and LMWG:
# web_pages = 1 creates a tar file with all figures and html
# publish_html = 1 publishes the html in $publish_html_root
# on NIRD. If publish_html_root is left empty, it will be set
# to /projects/NS2345K/www/noresm_diagnostics

set web_pages         = 1                 # 1 --> true
set publish_html      = 1
set publish_html_root = /path/to/html/directory

#-----------------------------------------------------------------#
#---------------- END OF USER DEFINED INPUT ----------------------#
#-----------------------------------------------------------------#

#-----------------------------------------------------------------#
# set global and environment variables
#-----------------------------------------------------------------#
unset noclobber
if (! $?NCARG_ROOT) then
  echo "ERROR: environment variable NCARG_ROOT is not set"
  echo "Do this in your .cshrc file (or whatever shell you use)"
  echo "setenv NCARG_ROOT /contrib"      # most NCAR systems
  echo "***EXITING THE SCRIPT"
  exit
else
  set NCL = "$NCARG_ROOT/bin/ncl -Q"    # works everywhere
endif

# Set directory to ncclimo.
# This is changed by diag_run when running with crontab
setenv ncclimo_dir  /usr/local/bin
set NCRCAT = `which ncrcat`

# set c-shell limits
limit stacksize unlimited
limit datasize  unlimited

set AVERAGES = (jfm amj jas ond ann on fm)

if ( `which convert | wc -w` == 1 ) then
  set CONVERT_PATH = `which convert`
  set CONVERT = "${CONVERT_PATH} -density 85 -background white -flatten"
else
  echo "ERROR: CONVERT NOT FOUND"
  echo "***EXITING THE SCRIPT"
  exit
endif

echo " "
echo "***************************************************"
echo "           CCSM CICE DIAGNOSTIC PACKAGE        "
echo "          "`date`
echo "***************************************************"
echo " "

#-----------------------------------------------------------------------
#  Check all combinations of CNTL and CLIMO_TIME_SERIES_SWITCH
#-----------------------------------------------------------------------
if ($CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO) then
   if ($CNTL == OBS) then
      echo "CNTL = ${CNTL}: plotting climotology sets for a single case"
      echo "PLOT_CONT     =1, PLOT_VECT     =1, PLOT_LINE     =0"
      echo "PLOT_CONT_DIFF=0, PLOT_VECT_DIFF=0, PLOT_LINE_DIFF=0"
      set PLOT_CONT = 1
      set PLOT_VECT = 1
      setenv PLOT_LINE 0
      set PLOT_CONT_DIFF = 0
      set PLOT_VECT_DIFF = 0
      setenv PLOT_LINE_DIFF 0
   else if ($CNTL == USER) then
      echo "CNTL = ${CNTL}: plotting climatology sets for two cases"
      echo "PLOT_CONT     =0, PLOT_VECT     =0, PLOT_LINE     =0"
      echo "PLOT_CONT_DIFF=1, PLOT_VECT_DIFF=1, PLOT_LINE_DIFF=0"
      set PLOT_CONT = 0
      set PLOT_VECT = 0
      setenv PLOT_LINE 0
      set PLOT_CONT_DIFF = 1
      set PLOT_VECT_DIFF = 1
      setenv PLOT_LINE_DIFF 0
   else
      echo "ERROR: CNTL must be set to either OBS or USER if CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO"
      echo "***EXITING THE SCRIPT"
      exit
   endif
else if ($CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES) then
   if ($CNTL == OBS) then
      echo "CNTL = ${CNTL}: plotting time series set for a single case"
      echo "PLOT_CONT     =0, PLOT_VECT     =0, PLOT_LINE     =1"
      echo "PLOT_CONT_DIFF=0, PLOT_VECT_DIFF=0, PLOT_LINE_DIFF=0"
      set PLOT_CONT = 0
      set PLOT_VECT = 0
      setenv PLOT_LINE 1
      set PLOT_CONT_DIFF = 0
      set PLOT_VECT_DIFF = 0
      setenv PLOT_LINE_DIFF 0
   else if ($CNTL == USER) then
      echo "CNTL = ${CNTL}: plotting time series set for two cases"
      echo "PLOT_CONT     =0, PLOT_VECT     =0, PLOT_LINE     =0"
      echo "PLOT_CONT_DIFF=0, PLOT_VECT_DIFF=0, PLOT_LINE_DIFF=1"
      set PLOT_CONT = 0
      set PLOT_VECT = 0
      setenv PLOT_LINE 0
      set PLOT_CONT_DIFF = 0
      set PLOT_VECT_DIFF = 0
      setenv PLOT_LINE_DIFF 1
   else
      echo "ERROR: CNTL must be set to either OBS or USER if CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES"
      echo "***EXITING THE SCRIPT"
   endif
else
   if ($CNTL == OBS) then
      echo "CNTL = ${CNTL}: plotting all sets for a single case"
      echo "PLOT_CONT     =1, PLOT_VECT     =1, PLOT_LINE     =1"
      echo "PLOT_CONT_DIFF=0, PLOT_VECT_DIFF=0, PLOT_LINE_DIFF=0"
      set PLOT_CONT = 1
      set PLOT_VECT = 1
      setenv PLOT_LINE 1
      set PLOT_CONT_DIFF = 0
      set PLOT_VECT_DIFF = 0
      setenv PLOT_LINE_DIFF 0
   else if ($CNTL == USER) then
      echo "CNTL = ${CNTL}: plotting all sets for two cases"
      echo "PLOT_CONT     =0, PLOT_VECT     =0, PLOT_LINE     =0"
      echo "PLOT_CONT_DIFF=1, PLOT_VECT_DIFF=1, PLOT_LINE_DIFF=1"
      set PLOT_CONT = 0
      set PLOT_VECT = 0
      setenv PLOT_LINE 0
      set PLOT_CONT_DIFF = 1
      set PLOT_VECT_DIFF = 1
      setenv PLOT_LINE_DIFF 1
   else if ($CNTL == OFF) then
      echo "CNTL = ${CNTL}: plotting specifics set by user"
      echo "PLOT_CONT     =${PLOT_CONT}, PLOT_VECT     =${PLOT_VECT}, PLOT_LINE     =${PLOT_LINE}"
      echo "PLOT_CONT_DIFF=${PLOT_CONT_DIFF}, PLOT_VECT_DIFF=${PLOT_VECT_DIFF}, PLOT_LINE_DIFF=${PLOT_LINE_DIFF}"
   else
      echo "ERROR: CNTL must be set to either OBS, USER or OFF"
      echo "***EXITING THE SCRIPT"
   endif
endif

#-----------------------------------------------------------------------
#  Set up some arrays for easy looping and do some error checking. 
#-----------------------------------------------------------------------

set TO_DIFF = -1
if ($PLOT_CONT == 1 || $PLOT_VECT == 1 || $PLOT_LINE == 1) then
  set TO_DIFF = 0 # Make plots of a single case
  set CASES_TO_READ = ($CASE_TO_CONT)
  set DATA_ROOT_VEC = ($DATA_ROOT1)
  set FIRST_YR_CLIMO = ($FIRST_YR_CLIMO1)
  set NYRS_CLIMO = ($NYRS_CLIMO1)
endif

if ($PLOT_CONT_DIFF == 1 || $PLOT_VECT_DIFF == 1 || $PLOT_LINE_DIFF == 1) then
  set TO_DIFF = 1   # Make difference plots of two model cases
  set CASES_TO_READ = ($CASE_TO_CONT $CASE_TO_DIFF)
  set DATA_ROOT_VEC = ($DATA_ROOT1 $DATA_ROOT2)
  set FIRST_YR_CLIMO = ($FIRST_YR_CLIMO1 $FIRST_YR_CLIMO2)
  set NYRS_CLIMO = ($NYRS_CLIMO1 $NYRS_CLIMO2)
endif

if ($TO_DIFF < 0) then
   echo "ERROR: TO_DIFF must be either 0 or 1."
   echo "***EXITING THE SCRIPT"
   exit
endif

set FILE_HEAD = ()
@ m = 1
foreach case ($CASES_TO_READ)
  if ($VAR_NAME_TYPE[$m] == OLD) then
    set JUNK = ${CASES_TO_READ[$m]}.csim.h.
  else
    set JUNK = ${CASES_TO_READ[$m]}.cice.h.
  endif
  set FILE_HEAD = ($FILE_HEAD $JUNK)
  @ m++
end

# Determine BEGYRS and ENDYRS if TRENDS_ALL=1
if ($PLOT_LINE == 1 || $PLOT_LINE_DIFF == 1) then
    if ($TRENDS_ALL == 1) then
	echo "-----------------------------------------"
	echo "TRENDS_ALL=1:                            "
        echo "COMPUTE TRENDS OVER THE ENTIRE SIMULATION"
        echo "-----------------------------------------"
    	# Initialize
	set BEGYRS = ()
        set ENDYRS = ()
	@ m = 1
	foreach CASE_TO_READ ($CASES_TO_READ)
	    setenv DATA_ROOT $DATA_ROOT_VEC[$m]
	    set file_prefix = ${DATA_ROOT}/${CASE_TO_READ}/ice/hist/$FILE_HEAD[$m]
	    set first_file  = `ls ${file_prefix}* | head -n 1`
	    set last_file   = `ls ${file_prefix}* | tail -n 1`
	    if ("$first_file" == "") then
		echo "ERROR: No history files ${CASE_TO_READ} exist in $DATA_ROOT"
		echo "***EXITING THE SCRIPT"
		exit
	    endif
	    set fyr_in_dir_prnt = `echo $first_file | rev | cut -c 7-10 | rev`
	    set fyr_in_dir      = `echo $fyr_in_dir_prnt | sed 's/^0*//'`
	    set lyr_in_dir_prnt = `echo $last_file | rev | cut -c 7-10 | rev`
	    set lyr_in_dir      = `echo $lyr_in_dir_prnt | sed 's/^0*//'`
	    if ($fyr_in_dir == $lyr_in_dir) then
		echo "ERROR: First and last year in ${CASE_TO_READ} are identical: cannot compute trends"
		echo "***EXITING THE SCRIPT"
		exit
	    endif
	    set BEGYRS = ($BEGYRS $fyr_in_dir)
   	    set ENDYRS = ($ENDYRS $lyr_in_dir)
	    @ m++
	end
        echo " BEGYRS = $BEGYRS"
        echo " ENDYRS = $ENDYRS"
    endif
endif

echo "--------------------------------------------------------------------"
echo "Part 1:                                                             "
echo "Read in the data 10 years at a time to save disk space.             " 
echo "Pre-process 10 yrs of data (calculate ice/snow vol. area)           "
echo "then delete 10 yrs of data, read next 10, etc, keeping enough years "
echo "for contour plots.                                                  "
echo "--------------------------------------------------------------------"

@ m = 1                              # Count the cases
foreach CASE_TO_READ ($CASES_TO_READ)

  setenv FILE_HEADER $FILE_HEAD[$m]
  setenv DATA_ROOT $DATA_ROOT_VEC[$m]
#  if ($CASE_TO_READ == $CASE_TO_CONT) then
#     setenv PATH_MSS $MSSPATH_CONT
#  endif
#  if ($CASE_TO_READ == $CASE_TO_DIFF) then
#     setenv PATH_MSS $MSSPATH_DIFF
#  endif

  setenv PATHJLS ${SCRATCH}/diags/${CASE_TO_READ}
  setenv PATHDAT ${DATA_ROOT}/${CASE_TO_READ}/ice/hist
  setenv CASE_READ ${CASE_TO_READ}
  setenv PRE_PROC_DIR ${PRE_PROC_ROOT}/${CASE_TO_READ}
  if !(-d $PRE_PROC_DIR) mkdir -p $PRE_PROC_DIR
  if !(-d $PATHJLS) mkdir -p $PATHJLS
  if !(-d $PATHDAT) mkdir -p $PATHDAT

  if ($PLOT_LINE == 1 || $PLOT_LINE_DIFF == 1) then  # Need data for line plots?

#   Need to delete concatenated file if created previously.
    setenv YR1 `printf "%04d" {$BEGYRS[$m]}`
    setenv YR2 `printf "%04d" {$ENDYRS[$m]}`

    @ NYRS_TOT = ( $ENDYRS[$m] - $BEGYRS[$m] ) + 1

    /bin/rm -f $PRE_PROC_DIR/ice_vol_${CASE_TO_READ}_$YR1-$YR2.nc

# Checking if pre-processed data exists, need years to do this.
    @ BEG_READ = $BEGYRS[$m]
    @ END_READ = 1
    while ($END_READ < $ENDYRS[$m])

      if ($BEG_READ + 9 <= $ENDYRS[$m]) then
        @ END_READ = $BEG_READ + 9
      else
        @ END_READ = $ENDYRS[$m]
      endif
      setenv YR1 `printf "%04d" {$BEG_READ}`
      setenv YR2 `printf "%04d" {$END_READ}`

      setenv PRE_PROC_FILE ice_vol_${CASE_TO_READ}_$YR1-$YR2.nc

      @ NYRS = ( $END_READ - $BEG_READ ) + 1
      setenv NYEARS $NYRS

      if !(-e $PRE_PROC_DIR/${PRE_PROC_FILE}) then

        setenv TAR 0

#       Pre-processed data does not exist. See if data exists.
        $DIAG_HOME/check_history.csh $DATE_FORMAT $BEG_READ $END_READ
	if ($status > 0) then
           echo "Part 1: ERROR IN check_history.csh"
	   echo "***EXITING THE SCRIPT"
           exit
        endif
     
        echo " Calling NCL preprocessing"
        echo " Pre-processing years $BEG_READ to $END_READ for $CASES_TO_READ[$m]"

        if ($FILE_VAR_TYPE[$m] == "NEW") then
           $NCL ${DIAG_HOME}/pre_proc.ncl
        else
           $NCL ${DIAG_HOME}/pre_proc_csim.ncl
        endif

      else

        echo " $PRE_PROC_DIR/$PRE_PROC_FILE file exists. Done."

      endif   # end of check for pre-processed data

      setenv YR1 `printf "%04d" {$BEGYRS[$m]}`
      setenv YR2 `printf "%04d" {$ENDYRS[$m]}`

      set PRE_PROC_CAT = ice_vol_${CASE_TO_READ}_$YR1-$YR2.nc

      if !(-e $PRE_PROC_DIR/${PRE_PROC_CAT}) then
         $NCRCAT $PRE_PROC_DIR/$PRE_PROC_FILE $PRE_PROC_DIR/$PRE_PROC_CAT
      else
         if ($NYRS_TOT > 10) then
	    $NCRCAT $PRE_PROC_DIR/$PRE_PROC_CAT $PRE_PROC_DIR/$PRE_PROC_FILE tmp_$YR1-$YR2.nc
            mv -f tmp_$YR1-$YR2.nc $PRE_PROC_DIR/$PRE_PROC_CAT
         endif

      endif

      @ BEG_READ = $END_READ + 1

    end            # End of while END_READ < ENDYRS

  else
     echo " NOT NEEDED: skipping."
  endif     # end of PLOT_LINE or PLOT_LINE_DIFF

  @ m++
end                # End of cases to read

echo "-------------------------------------------"
echo "Part 2:                                    "
echo "Average the data for contour, vector plots "
echo "if any of these plots are being made       "
echo "-------------------------------------------"

@ m = 1                              # Count the cases
foreach CASE_TO_READ ($CASES_TO_READ)

#  if ($CASE_TO_READ == $CASE_TO_CONT) then
#     setenv PATH_MSS $MSSPATH_CONT
#  endif
#  if ($CASE_TO_READ == $CASE_TO_DIFF) then
#     setenv PATH_MSS $MSSPATH_DIFF
#  endif

  setenv DATA_ROOT $DATA_ROOT_VEC[$m]
  setenv PATHJLS ${SCRATCH}/diags/$CASE_TO_READ
  setenv PATHDAT ${DATA_ROOT}/$CASE_TO_READ/ice/hist
  setenv CASE_READ ${CASE_TO_READ}
  setenv FILE_HEADER $FILE_HEAD[$m]
  if ($NCLIMO == 1) then
    @ NYRS_TO_AVG = $NYRS_CLIMO[$m]
    @ FRST_YR_AVG = $FIRST_YR_CLIMO[$m]
    @ END_YR_AVG  = ($FRST_YR_AVG + $NYRS_TO_AVG) - 1
  else
    @ NYRS_TO_AVG = $YRS_TO_AVG
    @ FRST_YR_AVG = ($ENDYRS[$m] - $NYRS_TO_AVG) + 1
    @ END_YR_AVG  = $ENDYRS[$m]
  endif

  if ($PLOT_CONT == 1 || $PLOT_VECT == 1 ||  \
      $PLOT_CONT_DIFF == 1 || $PLOT_VECT_DIFF == 1) then  

# Convert first and last year to 4 digits for file name
    setenv FRST_FOUR_DIG `printf "%04d" {$FRST_YR_AVG}`
    setenv LAST_FOUR_DIG `printf "%04d" {$END_YR_AVG}`

    set compute_climo = 0
    foreach EACH_MEAN ($AVERAGES)

# Don't calculte mean again if file already exists
      setenv SEAS_MEAN $EACH_MEAN
      setenv AVG_FILE ${PATHJLS}/${SEAS_MEAN}_avg_${FRST_FOUR_DIG}-${LAST_FOUR_DIG}.nc

      if (-e $AVG_FILE) then
         echo " $AVG_FILE file exists. Done."
      else
         echo " $AVG_FILE file does not exist."
	 set compute_climo = 1
      endif
    end

    if ($compute_climo == 1) then
       $DIAG_HOME/check_history.csh $DATE_FORMAT $FRST_YR_AVG $END_YR_AVG
       if ($status > 0) then
          echo "Part 2: ERROR IN check_history.csh"
          echo "***EXITING THE SCRIPT"
          exit
       endif
       echo " ========================================="
       echo " Computing climatology for cont/vect plots"
       echo " ========================================="
       ${DIAG_HOME}/avg_netcdf.csh $FRST_YR_AVG $END_YR_AVG $VAR_NAME_TYPE[$m]
    endif
  @ m++
  endif            # End of PLOT_CONT, PLOT_VECT, etc. for averaging
end                # End of cases

#---------------------------------------
# Part 3:  Plot a single case
#---------------------------------------

#setenv PATH_PLOT ${PATH_ROOT}/${CASE_TO_CONT}
setenv PATH_PLOT $SCRATCH/diags/${CASE_TO_CONT}

if ($PLOT_CONT == 1 || $PLOT_CONT_DIFF == 1) then
# Read over SSMI and ASPeCt data for ice area, ice thickness and snow depth contour plots
    if !(-e $PATH_PLOT/SSMI.ifrac.1979-2000monthlymean.gx1v5.nc) then
      cp "$SSMI_PATH" $PATH_PLOT/SSMI.ifrac.1979-2000monthlymean.gx1v5.nc
    endif
    if !(-e $PATH_PLOT/ASPeCt_monthly_1x1.nc) then
      cp "$ASPeCt_PATH" $PATH_PLOT/ASPeCt_monthly_1x1.nc
    endif
endif

if ($TO_DIFF == 0) then
  echo "---------------------------"
  echo "Part 3: Plot a single case "
  echo "---------------------------"
  @ m = 1
  
  if ($NCLIMO == 1) then
    @ NYRS_TO_AVG = $NYRS_CLIMO[$m]
    @ FRST_YR_AVG = $FIRST_YR_CLIMO[$m]
    @ END_YR_AVG  = ($FRST_YR_AVG + $NYRS_TO_AVG) - 1
  else
    @ NYRS_TO_AVG = $YRS_TO_AVG
    @ FRST_YR_AVG = ($ENDYRS[$m] - $NYRS_TO_AVG) + 1
    @ END_YR_AVG  = $ENDYRS[$m]
  endif

  #    @ FRST_YR_AVG = ($ENDYRS[$m] - $NYRS_TO_AVG) + 1
  setenv YR_AVG_FRST $FRST_YR_AVG
  setenv YR_AVG_LAST $END_YR_AVG
  setenv VAR_NAMES $VAR_NAME_TYPE[$m]
  set TAR_FILE = yrs${FRST_YR_AVG}to${END_YR_AVG}
  setenv WKDIR  ${PLOT_ROOT}/${TAR_FILE}/
  if !(-d ${WKDIR}maps) mkdir -p ${WKDIR}maps
  if !(-d ${WKDIR}obs) mkdir -p ${WKDIR}obs
  if !(-d ${WKDIR}contour) mkdir -p ${WKDIR}contour
  if !(-d ${WKDIR}line) mkdir -p ${WKDIR}line
  if !(-d ${WKDIR}vector) mkdir -p ${WKDIR}vector

  cd $WKDIR
  
  if ($PLOT_CONT == 1) then
    echo " RUNNING contour.ncl"
    $NCL < ${DIAG_HOME}/contour.ncl  

    echo " RUNNING IceSat_iceThickness.ncl"
    $NCL < ${DIAG_HOME}/IceSat_iceThickness.ncl  

    echo " CONVERTING NCL icesat .ps files to .png"
    foreach file (*icesat*.ps)
       $CONVERT $file ./obs/$file:r.png
       if ($KEEP_PS_FILES == 0) rm -f $file
    end    

    echo " CONVERTING NCL contour .ps files to .png"
    foreach file (con*.ps)
      $CONVERT $file ./contour/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end

    echo " CONVERTING NCL ASPeCt .ps files to .png"
    foreach file (*ASPeCt*.ps)
      $CONVERT $file ./obs/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end
  endif

  if ($PLOT_VECT == 1) then
    echo " RUNNING vector.ncl"
    $NCL < ${DIAG_HOME}/vector.ncl

    echo " CONVERTING NCL vector .ps files to .png"
    foreach file (vec*.ps)
      $CONVERT $file ./vector/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end
  endif

  if ($PLOT_LINE == 1) then

    echo " RUNNING timeseries ncl script"
    $NCL ${DIAG_HOME}/web_hem_avg.ncl

    echo " RUNNING climatology ncl script"
    $NCL ${DIAG_HOME}/web_hem_clim.ncl

    if ($PLOT_REGIONS == 1) then
       echo " RUNNING regional ncl script"
       $NCL ${DIAG_HOME}/web_reg_avg.ncl
    endif   # End of PLOT_REGIONS

    echo " CONVERTING NCL line .ps files to .png"
    foreach file (line*.ps)
      $CONVERT $file ./line/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end
    foreach file (clim*.ps)
      $CONVERT $file ./line/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end

#   Copy maps
    cp -rf $DIAG_HOME/web/maps $WKDIR
    
  endif   # End of PLOT_LINE

endif  # End of TO_CONT

#------------------------------------------------------
# Part 4.  Make difference plots
#------------------------------------------------------

if ($TO_DIFF == 1) then

  echo "--------------------------------"
  echo "Part 3: Making difference plots "
  echo "--------------------------------"
  
  if (-e $CASES_TO_READ[2] && $TO_DIFF == 1) then
    echo " Need 2 cases for difference plots"
    exit
  endif

  setenv CASE_PREV $CASES_TO_READ[2]      # getenv in ncl only
  setenv CASE_NEW  $CASES_TO_READ[1]      # takes scalar values
  setenv VAR_NAME_PREV $VAR_NAME_TYPE[2]
  setenv VAR_NAME_NEW  $VAR_NAME_TYPE[1]
  setenv PATH_PREV  $SCRATCH/diags/$CASES_TO_READ[2]
  setenv PATH_NEW   $SCRATCH/diags/$CASES_TO_READ[1]
#  setenv PATH_PREV  $PATH_ROOT/$CASES_TO_READ[2]
#  setenv PATH_NEW   $PATH_ROOT/$CASES_TO_READ[1]

  if ($NCLIMO == 1) then
    @ NYRS_TO_AVG = $NYRS_CLIMO[1]
    @ FRST_YR_AVG = $FIRST_YR_CLIMO[1]
    @ END_YR_AVG  = ($FRST_YR_AVG + $NYRS_TO_AVG) - 1
  else
    @ NYRS_TO_AVG = $YRS_TO_AVG
    @ FRST_YR_AVG = ($ENDYRS[1] - $NYRS_TO_AVG) + 1
    @ END_YR_AVG  = $ENDYRS[1]
  endif
#  @ TMP = ($ENDYRS[1] - $NYRS_TO_AVG) + 1
  setenv NEW_YR_AVG_FRST $FRST_YR_AVG
  setenv NEW_YR_AVG_LAST $END_YR_AVG

  if ($NCLIMO == 1) then
    @ NYRS_TO_AVG = $NYRS_CLIMO[2]
    @ FRST_YR_AVG = $FIRST_YR_CLIMO[2]
    @ END_YR_AVG  = ($FRST_YR_AVG + $NYRS_TO_AVG) - 1
  else
    @ NYRS_TO_AVG = $YRS_TO_AVG
    @ FRST_YR_AVG = ($ENDYRS[2] - $NYRS_TO_AVG) + 1
    @ END_YR_AVG  = $ENDYRS[2]
  endif
#  @ TMP = ($ENDYRS[2] - $NYRS_TO_AVG) + 1
  setenv PREV_YR_AVG_FRST $FRST_YR_AVG
  setenv PREV_YR_AVG_LAST $END_YR_AVG

  set TAR_FILE  = yrs${FRST_YR_AVG}to${END_YR_AVG}-${CASE_TO_DIFF}
  setenv WKDIR  ${PLOT_ROOT}/${TAR_FILE}/
  if !(-d ${WKDIR}maps) mkdir -p ${WKDIR}maps
  if !(-d ${WKDIR}obs) mkdir -p ${WKDIR}obs
  if !(-d ${WKDIR}contour) mkdir -p ${WKDIR}contour
  if !(-d ${WKDIR}line) mkdir -p ${WKDIR}line
  if !(-d ${WKDIR}vector) mkdir -p ${WKDIR}vector

  cd ${WKDIR}
  
  if ($PLOT_CONT_DIFF == 1) then
     echo " RUNNING cont_diff.ncl"
     $NCL < ${DIAG_HOME}/cont_diff.ncl 

     echo " RUNNING IceSat_iceThickness_diff.ncl"
     $NCL < ${DIAG_HOME}/IceSat_iceThickness_diff.ncl

     echo " CONVERTING NCL icesat .ps files to .png"
     foreach file (*icesat*.ps)
        $CONVERT $file ./obs/$file:r.png
        if ($KEEP_PS_FILES == 0) rm -f $file
     end    
     
     echo " CONVERTING NCL diff_con .ps files to .png"
     foreach file (diff_con*.ps)
        $CONVERT $file ./contour/$file:r.png
        if ($KEEP_PS_FILES == 0) rm -f $file
     end

     echo " CONVERTING NCL ASPeCt .ps files to .png"
     foreach file (*ASPeCt*.ps)
        $CONVERT $file ./obs/$file:r.png
        if ($KEEP_PS_FILES == 0) rm -f $file
     end    
  endif

  if ($PLOT_VECT_DIFF == 1) then
     echo " RUNNING vect_diff.ncl"
     $NCL < ${DIAG_HOME}/vect_diff.ncl
     
     echo " CONVERTING NCL diff_vec .ps files to .png"
     foreach file (diff_vec*.ps)
        $CONVERT $file ./vector/$file:r.png
        if ($KEEP_PS_FILES == 0) rm -f $file
     end
  endif
  
  if ($PLOT_LINE_DIFF == 1) then

    setenv YR1 `printf "%04d" {$BEGYRS[1]}`
    setenv YR2 `printf "%04d" {$ENDYRS[1]}`
    setenv YR1_DIFF `printf "%04d" {$BEGYRS[2]}`
    setenv YR2_DIFF `printf "%04d" {$ENDYRS[2]}`

    echo " RUNNING timeseries ncl diff script"
    $NCL ${DIAG_HOME}/web_hem_avg.ncl

    echo " RUNNING climatology ncl diff script"
    $NCL ${DIAG_HOME}/web_hem_clim.ncl

    if ($PLOT_REGIONS == 1) then
       echo " RUNNING regional ncl diff script"
       $NCL ${DIAG_HOME}/web_reg_avg.ncl
    endif  # End of PLOT_REGIONS

    echo " CONVERTING NCL line .ps files to .png"
    foreach file (line*diff.ps)
      $CONVERT $file ./line/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end
    foreach file (clim*diff.ps)
      $CONVERT $file ./line/$file:r.png
      if ($KEEP_PS_FILES == 0) rm -f $file
    end
#   Copy maps
    cp -rf $DIAG_HOME/web/maps $WKDIR
  endif  # End of PLOT_LINE_DIFF

endif  # End of TO_DIFF

#------------------------------------------------------
# Part 5.  Set up html interface and tar plots
#------------------------------------------------------

echo "--------------------------------"
echo "Part 4: Setting up html and tar "
echo "--------------------------------"
if ($web_pages == 1) then
   ${DIAG_HOME}/web/setup_ice_plots.csh $TAR_FILE $TO_DIFF
endif
cd ${PLOT_ROOT}
tar -cf ${TAR_FILE}.tar $TAR_FILE
rm -rf $TAR_FILE
# Publish html data (JL Oct 2017)
if ($web_pages == 1 && $publish_html == 1) then
   set web_server_path = /projects/NS2345K/www
   if ( "$publish_html_root" == "" ) then
      set publish_html_root = ${web_server_path}/noresm_diagnostics
   endif
   set publish_html_path = ${publish_html_root}/${CASE_TO_CONT}/CICE_DIAG
   if (! -e ${publish_html_path}) then
      mkdir -p ${publish_html_path}
      if (! -e ${publish_html_path}) then
         echo ERROR: Unable to create \$publish_html_path : ${publish_html_path}
         echo "***EXITING THE SCRIPT"
         exit
      endif
   endif
   set web_server      = ns2345k.web.sigma2.no
   set path_pref       = `echo ${publish_html_path} | cut -c -21`
   set path_suff       = `echo ${publish_html_path} | cut -c 23-`
   tar -xf ${TAR_FILE}.tar -C ${publish_html_path}
   if ( $status == 0 ) then
      if ( $path_pref == $web_server_path) then
         set full_url = ${web_server}/${path_suff}/${TAR_FILE}/index.html
         echo " URL:                                                                               "
         echo " ***********************************************************************************"
         echo " ${full_url}                                                                        "
         echo " ***********************************************************************************"
         echo " COPY AND PASTE THE URL INTO THE ADDRESS BAR OF YOUR WEB BROWSER TO VIEW THE RESULTS"
	 ${DIAG_HOME}/web/redirect_html.csh $TAR_FILE $publish_html_path $full_url
      else
         echo " THE HTML FILES ARE LOCATED IN:                                                     "
         echo " ${publish_html_path}/${TAR_FILE}                                                   "
         echo " (NOT ON THE NIRD WEB SERVER)                                                       "
      endif
   endif
endif
date
