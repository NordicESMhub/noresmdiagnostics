#!/bin/csh
# file: amwg_template.csh
# Last updated: Johan Liakka, Nov 2017
# Last updated: Yanchun He, Sept. 2020
#
# Based on file: diag140804.csh
# Updated: 2014/08/04

unset echo verbose
setenv DIAG_VERSION 140804  # version number YYMMDD

## LOAD MODULES AND SET ENVIRONMENTS
set MACHINE = "`uname -n` `hostname -f`"
if ( `echo "$MACHINE" |grep 'ipcc'` != '' ) then
    set MACHINE = 'ipcc.nird'
    setenv NCARG_ROOT /conda/miniconda3
    setenv NCARG_COLORMAPS $NCARG_ROOT/lib/ncarg/colormaps
    setenv PATH /conda/miniconda3/bin:/usr/local/bin:/usr/bin
    setenv UDUNITS2_XML_PATH /conda/miniconda3/share/udunits/udunits2.xml
    setenv ncksbin  `which ncks`
    setenv nco_dir  `dirname $ncksbin`
    setenv cdobin   `which cdo`
    setenv cdo_dir  `dirname $cdobin`
else if ( `echo "$MACHINE" |grep 'login[0-9]-nird-tos|login[0-9]-nird-trd'` != '' ) then
    set MACHINE = 'login.nird'
    setenv NCARG_ROOT /usr
    setenv NCARG_COLORMAPS $NCARG_ROOT/lib/ncarg/colormaps
    setenv ncksbin  `which ncks`
    setenv nco_dir  `dirname $ncksbin`
    setenv cdo_dir  /opt
else if ( `echo "$MACHINE" |grep 'login[0-9]-nird-lmd'` != '' ) then
    set MACHINE = 'nird-lmd'
    setenv NCARG_ROOT /usr
    setenv NCARG_COLORMAPS $NCARG_ROOT/lib/ncarg/colormaps
    setenv ncksbin  `which ncks`
    setenv nco_dir  `dirname $ncksbin`
    setenv cdo_dir  /usr/local/bin
else if ( `echo "$MACHINE" |grep 'betzy'` != '' )  then
    set MACHINE = 'betzy'
    module -q purge
    module -q load NCO/4.9.3-intel-2019b
    module -q load CDO/1.9.8-intel-2019b
    module -q load NCL/6.6.2-intel-2019b
    module unload HDF/4.2.14-GCCcore-8.3.0
    module -q load ImageMagick/7.1.0-4-GCCcore-11.2.0
    setenv nco_dir  ${EBROOTNCO}/bin
    setenv cdo_dir  ${EBROOTCDO}/bin
else
    echo "** UNKNOWN MACHINE $MACHINE **"
    echo "**       EXIT         **"
    exit 1
endif

#******************************************************************
#  C-shell control script for AMWG Diagnostics Package.           *
#  Written by Dr. Mark J. Stevens, 2001-2003.                     *
#  Updated by many people                                         *                                    
#                                                                 *
#  NorESM contact:                                                *
#  e-mail: (johan.liakka@nersc.no)                                *
#           yanchun.he@nersc.no                                   *
#  For recent changes in the NorESM version, see the README file  *
#                                                                 *
#  CESM contact:                                                  *
#  e-mail: hannay@ucar.edu   phone: 303-497-1327                  *
#                                                                 *
#  - Please see the AMWG diagnostics package webpage at:          *
#  http://www.cgd.ucar.edu/amp/amwg/diagnostics                   *
#                                                                 *
#  - Subscribe to the ccsm-amwgdiag mailing list:                 *
#  http://mailman.cgd.ucar.edu/mailman/listinfo/ccsm_amwgdiag     *
#  to receive updates from the AMWG diagnostic package.           *
#                                                                 *
#  Implementation of parallel version with Swift sponsored by the *
#  Office of Biological and Environmental Research of the         *
#  U.S. Department of Energy's Office of Science.                 *
#                                                                 *
#******************************************************************
#                                                                
#
#******************************************************************
#                   PLEASE READ THIS                              *
#******************************************************************

# This script can be placed in any directory provided that
# access to the working directory and local directories are 
# available (see below).
#
# Using this script your model output can be compared with
# observations (observed and reanalysis, data) 
# or with another model run. With all the diagnostic sets 
# turned on the package will produce over 600 plots and 
# tables in your working directory. In addition, files are
# produced for the climatological monthly means and the DJF
# and JJA seasonal means, as well as the annual (ANN) means.
# 
# Input file names are of the standard CCSM type and
# they must be in netcdf format. Filenames are of the 
# form YYYY-MM.nc where YYYY are the model years and MM
# are the months, for example 00010-09.nc. The files
# can reside on the Mass Storage System (MSS), if they 
# are on the MSS the script will get them using msrcp.
# If your files are not on the MSS they must be in a local
# directory. 
#
# Normally 5 years of monthly means are used for the
# comparisons, however only 1 year of data will work. 
# The December just prior to the starting year is also
# needed for the DJF seasonal mean, or Jan and Feb of
# the year following the last full year. For example,  
# for 5-year means the following months are needed 
#
# 0000-12.nc      prior december
# 0001-01.nc      first year (must be 0001 or greater)
#  ...
# 0001-12.nc
#  ...
# 0005-01.nc      last year
#  ...
# 0005-12.nc

#--> OR you can do this 
#
# 0001-01.nc      first year (must be 0001 or greater)
#  ...
# 0001-12.nc
#  ...
# 0005-01.nc      last year full year
#  ...
# 0005-12.nc
# 0006-01.nc      following jan
# 0006-02.nc      following feb
#
set time_start_script = `date +%s`
#******************************************************************
#                       USER MODIFY SECTION                       *
#              Modify the following sections as needed.           *
#******************************************************************

# In the following "test case" refers to the model run to be
# compared with the "control case", which may be model or obs data.

#******************************************************************

#******************************************************************

# *****************
# *** Test case ***
# *****************

# Set the identifying casename and paths for your test case run. 
# The output netcdf files are in: $test_path_history
# The climatology files are in: $test_path_climo
# The diagnostic plots are: $test_path_diag
#
set test_casename = your_test_simulation
set test_filetype = monthly_history

set diag_dir = /path/to/your/diagnostics

set test_path_history_root = /path/to/test_case/history
set test_path_history      = $test_path_history_root/$test_casename/atm/hist
set test_path_climo        = $diag_dir/climo/$test_casename
set test_path_diag         = $diag_dir/diag/$test_casename

#******************************************************************

# ********************
# *** Control case ***
# ******************** 

# Select the type of control case to be compared with your model
# test case (select one). 

set CNTL = type_of_control_case # OBS or USER
#set CNTL = OBS                 # observed data (reanalysis etc)
#set CNTL = USER                # user defined model control (see below)

#------------------------------------------------------------------
# FOR CNTL == USER ONLY (otherwise skip this section)

# Set the identifying casename and paths for your control case run. 
# The output netcdf files are in: $cntl_path_history
# The climatology files are in: $cntl_path_climo
#
set cntl_casename = your_cntl_simulation
set cntl_filetype = monthly_history

set cntl_path_history_root = /path/to/cntl_case/history
set cntl_path_history      = $cntl_path_history_root/$cntl_casename/atm/hist
set cntl_path_climo        = $diag_dir/climo/$cntl_casename

#******************************************************************

# *********************
# *** Climatologies ***
# ********************* 

# Use these settings if computing climatological means 
# from the local test case data and/or local control case data

#-----------------------------------------------------------------
# Turn on/off the computation of climatologies 
      
set test_compute_climo = 0  # (0=ON,1=OFF) 
set cntl_compute_climo = 0  # (0=ON,1=OFF) 

#-----------------------------------------------------------------

# If computing climatological means for test/cntl case, specify the first 
# year of your data, and the number of years of data to be used.

# First year of data is: $test_first_yr     (must be >= 1)
# Number of years is: $test_nyrs         (must be >= 1)

set test_first_yr = fyr_of_test  # first year (must be >= 1)
set test_nyrs     = nyr_of_test  # number of yrs (must be >= 1)

# FOR CNTL == USER ONLY (otherwise skip this section)
# First year of data is: $cntl_first_yr     (must be >= 1)
# Number of years is: $cntl_nyrs         (must be >= 1)

set cntl_first_yr = fyr_of_cntl   # first year (must be >= 1)
set cntl_nyrs     = nyr_of_cntl   # number of yrs (must be >= 1)

#-----------------------------------------------------------------
# Strip off all the variables that are not required by the AMWG package
# in the computation of the climatology

set strip_off_vars = 0     # (0=ON,1=OFF)

#-----------------------------------------------------------------
# Weight the months by their number of days when computing
# averages for ANN, DJF, JJA. This takes much longer to compute 
# the climatologies. Many users might not care about the small
# differences and leave this turned off.
#
# JL Sep 2017:
# Not needed anymore because of the updated procedure to calculate
# the climatologies (now it is always set to 0).
# set weight_months = 1     # (0=ON,1=OFF)

# ********************
# *** Time series ***
# ********************
# Set path where the time series files should be stored
set timeseries_path = $diag_dir/time_series

set TRENDS_ALL = ts_all_switch
set test_first_yr_ts = fyr_of_ts_test
set test_last_yr_ts = lyr_of_ts_test
set cntl_first_yr_ts = fyr_of_ts_cntl
set cntl_last_yr_ts = lyr_of_ts_cntl

# ********************
# *** Web options ***
# ********************
#---------------------------------------------------------------
# JL Sep 2017:
# Publish the html on the NIRD web server
# (does only work in conjunction with web_pages = 0 [default]),
# and set the path where it should be published.
# If the path is left empty it is set to
# /projects/NS2345K/www/noresm
# The URL will appear in the terminal right before the termination
# of this script, as well as in ${test_path_diag}/URL

set publish_html      = 0   # (0=ON,1=OFF)
set publish_html_root = /path/to/html/directory

#******************************************************************

# ******************************
# *** Select diagnostic sets ***
# ****************************** 

# Select the diagnostic sets to be done. You can do one at a
# time or as many as you want at one time, or all at once.

set all_sets = 0  # (0=ON,1=OFF)  Do all the CAM sets (1-16)
set set_1  = 1    # (0=ON,1=OFF)  tables of global,regional means
set set_2  = 1    # (0=ON,1=OFF)  implied transport plots 
set set_3  = 1    # (0=ON,1=OFF)  zonal mean line plots
set set_4  = 1    # (0=ON,1=OFF)  vertical zonal mean contour plots
set set_4a = 1    # (0=ON,1=OFF)  vertical zonal mean contour plots
set set_5  = 1    # (0=ON,1=OFF)  2D-field contour plots
set set_6  = 1    # (0=ON,1=OFF)  2D-field vector plots
set set_7  = 1    # (0=ON,1=OFF)  2D-field polar plots
set set_8  = 1    # (0=ON,1=OFF)  annual cycle (vs lat) contour plots
set set_9  = 1    # (0=ON,1=OFF)  DJF-JJA difference plots
set set_10 = 1    # (0=ON,1=OFF)  annual cycle line plots    
set set_11 = 1    # (0=ON,1=OFF)  miscellaneous plots
set set_12 = 1    # (0=selected stations: 1=NONE)
set set_13 = 1    # (0=ON,1=OFF)  COSP cloud simulator plots
set set_14 = 1    # (0=ON,1=OFF)  Taylor diagram plots 
set set_15 = 1    # (0=ON,1=OFF)  Annual Cycle Plots for Select stations
set set_16 = 1    # (0=ON,1=OFF)  Budget Terms for Select stations

set tset_1 = 0         # (0=ON,1=OFF)  Enable annual time series plots (JL, Nov 2017)

set all_waccm_sets = 1 # (0=ON,1=OFF)  Do all the WACCM sets
set all_chem_sets = 1  # (0=ON,1=OFF)   Do all the CHEM sets
set wset_1 = 1         # (0=ON,1=OFF)  vertical zonal mean contour plots (log scale)
set cset_1 = 1         # (0=ON,1=OFF)  tables of global budgets 
set cset_2 = 1         # (0=ON,1=OFF)  vertical zonal mean contour plots (log scale)
set cset_3 = 1         # (0=ON,1=OFF)  Ozonesonde comparisions 
set cset_4 = 1         # (0=ON,1=OFF)  Column Ozone/CO Comparisons
set cset_5 = 1         # (0=ON,1=OFF)  NOAA Aircraft comparisons
set cset_6 = 1         # (0=ON,1=OFF)  Emmons Aircraft climatology 
set cset_7 = 1         # (0=ON,1=OFF)  surface comparisons (ozone, co, improve)

# Select the control case to compare against for Taylor Diagrams
# Cam run select cam3_5; coupled run select ccsm3_5  
 
setenv TAYLOR_BASECASE cam5.3  # Base case to compare against
                                # Options are cam3_5, ccsm3_5
                                # cam5.3, lens
                                # They are both fv_1.9x2.5

# Switch between climo and time-series computation, used by diag_run
# -JL, Nov 2017
set CLIMO_TIME_SERIES_SWITCH = SWITCHED_OFF

# Switch on comparison with observation for time series (default=off)
set time_series_obs = 1 # (0=ON,1=OFF)

#******************************************************************

# **************************************
# *** Customize plots (output/style) ***
# ************************************** 

# Select seasonal output to be plotted  
#  four_seasons = 0     # DJF, MAM, JJA, SON, ANN    
#  four_seasons = 1     # DJF, JJA, ANN 
#  four_seasons = 2     # Custom: Select the season you want to be plotted

# Note:  four_seasons is not currently supported for model vs OBS diagnostics.
# if ($CNTL == OBS) then four_seasons is turned OFF.

set four_seasons = 0            # (0=ON; 1=OFF)

#------------------------------------------------------------------
# For four_seasons == 2 (otherwise skip this section)
# Select the seasons you want to be plotted

if ($four_seasons == 2) then
    set plot_ANN_climo = 0       # (0=ON,1=OFF) used by sets 1-7,11 
    set plot_DJF_climo = 0       # (0=ON,1=OFF) used by sets 1,3-7,9,11
    set plot_JJA_climo = 0       # (0=ON,1=OFF) used by sets 1,3-7,9,11
    set plot_MAM_climo = 0       # (0=ON,1=OFF) used by sets 1,3-7,9,11
    set plot_SON_climo = 0       # (0=ON,1=OFF) used by sets 1,3-7,9,11
    set plot_MON_climo = 0       # (0=ON,1=OFF) used by sets 8,10,11,12
endif

#-----------------------------------------------------------------
# Select the output file type and style for plots.

set p_type = ps     # postscript
#set p_type = pdf    # portable document format (ncl ver 4.2.0.a028)
#set p_type = eps    # encapsulated postscript
#set p_type = epsi   # encapsulated postscript with bitmap 
#set p_type = ncgm   # ncar computer graphics metadata

#-------------------------------------------------------------------
# Select the output color type for plots.

 set c_type = COLOR      # color
#set c_type = MONO       # black and white

# If needed select one of the following color schemes,
# you can see the colors by clicking on the links from
# http://www.cgd.ucar.edu/cms/diagnostics

#set color_bar = default           # the usual colors
set color_bar = blue_red           # blue,red 
#set color_bar = blue_yellow_red   # blue,yellow,red (nice!) 

#----------------------------------------------------------------
# Turn ON/OFF date/time stamp at bottom of plots.
# Leaving this OFF makes the plots larger.

set time_stamp = 1       # (0=ON,1=OFF)

#---------------------------------------------------------------
# Turn ON/OFF tick marks and labels for sets 5,6, and 7
# Turning these OFF make the areas plotted larger, which makes
# the images easier to look at. 

set tick_marks = 1       # (0=ON,1=OFF)
 
#----------------------------------------------------------------
# Use custom case names for the PLOTS instead of the 
# case names encoded in the netcdf files (default). 
# Also useful for publications.

set custom_names = 1     # (0=ON,1=OFF)

# if needed set the names
set test_name = cam3_5_test               # test case name 
set cntl_name = cam3_5_cntl               # control case name

#----------------------------------------------------------------
# Convert output postscript files to GIF, JPG or PNG image files 
# and place them in subdirectories along with html files.
# Then make a tar file of the web pages and GIF,JPG or PNG files.
# On Dataproc and CGD Suns GIF images are smallest since I built
# ImageMagick from source and compiled in the LZW compression.
# On Linux systems JPG will be smallest if you have an rpm or
# binary distribution of ImageMagick (and hence convert) since
# NO LZW compression is the default. Only works if you have
# convert on your system and for postscript files (p_type = ps).
# NOTE: Unless you have rebuilt ImageMagick on your Linux system
# the GIF files can be as large as the postscript plots. I 
# recommend that PNG always be used. The density option can be
# used with convert to make higher resolution images which will
# work better in powerpoint presentations, try density = 150.

set web_pages = 0    # (0=ON,1=OFF)  make images and html files
set delete_ps = 0    # (0=ON,1=OFF)  delete postscript files 
set img_type  = 0    # (0=PNG,1=GIF,2=JPG) select image type
set density   = 150  # pixels/inch, use larger number for higher 
                     # resolution images (default is 85)

#----------------------------------------------------------------
# Save the output netcdf files of the derived variables
# used to make the plots. These are normally deleted 
# after the plots are made. If you want to save the 
# netcdf files for your own uses then switch to ON. 

set save_ncdfs = 1       # (0=ON,1=OFF)
#----------------------------------------------------------------

# Compute whether the means of the test case and control case 
# are significantly different from each other at each grid point.
# Tests are performed only for model-to-model comparisons.  
# REQUIRES at least 10 years of model data for each case.
# Number of years from above (test_nyrs and cntl_nyrs) is used.
# Also set the significance level for the t-test.
 
set significance = 1        # (0=ON,1=OFF)

# if needed set default level
set sig_lvl = 0.05           # level of significance

#******************************************************************

# ***************************
# *** Source code location ***
# *************************** 

# Below is defined the amwg diagnostic package root location 
# on CGD machines (tramhill,...), on old CSIL machines (mirage), 
# on new CSIL machines (geyser),  NERSC (euclid), and  LBNL (lens).            
#
# If you are installing the diagnostic package on your computer system. 
# you need to set DIAG_HOME to the root location of the diagnostic code. 
# The code is in $DIAG_HOME/code 
# The obs data in $DIAG_HOME/obs_data
# The cam3.5 data in $DIAG_HOME/cam_data 

# CGD machines (tramhill, leehill...)
#setenv DIAG_HOME /project/amp/amwg/amwg_diagnostics 

# NIRD
setenv DIAG_HOME /path/to/code/and/data
setenv NCARG_USRRESFILE ${DIAG_HOME}../../bin/.hluresfile


#*****************************************************************

# ****************************
# *** Additional settings  ***
# **************************** 

# Send yourself an e-mail message when everything is done. 

set email = 1        # (0=ON,1=OFF) 
set email_address = your@email.com

#*****************************************************************
#*****************************************************************

# **************************
# *** Advanced settings  ***
# **************************

#*****************************************************************

#-------------------------------------------------
# For CAM-SE grid, specify a lat/lon to interpolate to
#-------------------------------------------------
# By default, the CAM-SE output is interpolated CAM_SE on a 1 degree grid
# You can select another grid below.

set test_res_out = 0.9x1.25
set cntl_res_out = 0.9x1.25

# Set the interpolation method for regridding: bilinear, patch, conserver
setenv INTERP_METHOD bilinear

#-------------------------------------------------
# Set to 0 to use swift
#-------------------------------------------------
# JL Sep 2017:
# Needs to be switched off on NIRD until further notice!!
#
setenv use_swift  1           # (0=ON,1=OFF)
setenv swift_scratch_dir ${diag_dir}/swift_scratch/
set test_inst =  -1
set cntl_inst =  -1

#------------------------------------------------- 
# For set 12:
#-------------------------------------------------
# Select vertical profiles to be computed. Select from list below,
# or do all stations, or none. You must have computed the monthly
# climatological means for this to work. Preset to the 17 selected
# stations.


# Specify selected stations for computing vertical profiles.
if ($set_12 == 0 || $all_sets == 0) then
# ARCTIC (60N-90N)
  set western_alaska      = 1  # (0=ON,1=OFF)
  set whitehorse_canada   = 1  # (0=ON,1=OFF)
  set resolute_canada     = 0  # (0=ON,1=OFF)
  set thule_greenland     = 0  # (0=ON,1=OFF)
# NORTHERN MIDLATITUDES (23N-60N)
  set new_dehli_india     = 1  # (0=ON,1=OFF)
  set kagoshima_japan     = 1  # (0=ON,1=OFF)
  set tokyo_japan         = 1  # (0=ON,1=OFF)
  set midway_island       = 0  # (0=ON,1=OFF)
  set shipP_gulf_alaska   = 0  # (0=ON,1=OFF)
  set san_francisco_ca    = 0  # (0=ON,1=OFF)
  set denver_colorado     = 1  # (0=ON,1=OFF)
  set great_plains_usa    = 0  # (0=ON,1=OFF)
  set oklahoma_city_ok    = 1  # (0=ON,1=OFF)
  set miami_florida       = 0  # (0=ON,1=OFF)
  set new_york_usa        = 1  # (0=ON,1=OFF)
  set w_north_atlantic    = 1  # (0=ON,1=OFF)
  set shipC_n_atlantic    = 1  # (0=ON,1=OFF)
  set azores              = 1  # (0=ON,1=OFF)
  set gibraltor           = 1  # (0=ON,1=OFF)
  set london_england      = 1  # (0=ON,1=OFF)
  set western_europe      = 0  # (0=ON,1=OFF)
  set crete               = 1  # (0=ON,1=OFF)
# TROPICS (23N-23S)
  set central_india       = 1  # (0=ON,1=OFF)
  set madras_india        = 1  # (0=ON,1=OFF)
  set diego_garcia        = 0  # (0=ON,1=OFF)
  set cocos_islands       = 1  # (0=ON,1=OFF)
  set christmas_island    = 1  # (0=ON,1=OFF)
  set singapore           = 1  # (0=ON,1=OFF)
  set danang_vietnam      = 1  # (0=ON,1=OFF)
  set manila              = 1  # (0=ON,1=OFF)
  set darwin_australia    = 1  # (0=ON,1=OFF)
  set yap_island          = 0  # (0=ON,1=OFF)
  set port_moresby        = 1  # (0=ON,1=OFF)
  set truk_island         = 0  # (0=ON,1=OFF)
  set raoui_island        = 1  # (0=ON,1=OFF)
  set gilbert_islands     = 1  # (0=ON,1=OFF)
  set marshall_islands    = 0  # (0=ON,1=OFF)
  set samoa               = 1  # (0=ON,1=OFF)
  set hawaii              = 0  # (0=ON,1=OFF)
  set panama              = 0  # (0=ON,1=OFF)
  set mexico_city         = 1  # (0=ON,1=OFF)
  set lima_peru           = 1  # (0=ON,1=OFF)
  set san_juan_pr         = 1  # (0=ON,1=OFF)
  set recife_brazil       = 1  # (0=ON,1=OFF)
  set ascension_island    = 0  # (0=ON,1=OFF)
  set ethiopia            = 1  # (0=ON,1=OFF)
  set nairobi_kenya       = 1  # (0=ON,1=OFF)
# SOUTHERN MIDLATITUDES (23S-60S)
  set heard_island        = 1  # (0=ON,1=OFF)
  set w_desert_australia  = 1  # (0=ON,1=OFF)
  set sydney_australia    = 1  # (0=ON,1=OFF)
  set christchurch_nz     = 1  # (0=ON,1=OFF)
  set easter_island       = 0  # (0=ON,1=OFF)
  set san_paulo_brazil    = 1  # (0=ON,1=OFF)
  set falkland_islands    = 1  # (0=ON,1=OFF)
# ANTARCTIC (60S-90S)
  set mcmurdo_antarctica  = 0  # (0=ON,1=OFF)
endif


#-----------------------------------------------------------------

# PALEOCLIMATE coastlines
# Allows users to plot paleoclimate coastlines for sets 5,6,7,9.
# Two special files are created which contain the needed data 
# from each different model orography. The names for these files
# are derived from the variables $test_casename and $cntl_casename 
# defined above by the user.  
# If the user wants to compare results from two different times
# when the coastlines are different then the difference plots 
# can be turned off. No difference plots are made when the
# paleoclimate model is compared to OBS DATA.
 
set paleo = 1             # (0=use or create coastlines,1=OFF)

# if needed set these
set land_mask1 = 1      # define value for land in test case ORO
set land_mask2 = 1      # define value for land in cntl case ORO
set diff_plots = 1      # make difference plots for different
                        # continental outlines  (0=ON,1=OFF)

#*****************************************************************

# **************************
# *** Obsolete settings  ***
# **************************

# These settings were used in older versions of the diagnostic
# package. It is uncommon to use these settings. 
# These settings are not somewhat obsolete  but left here 
# for the user s convenience.

#-----------------------------------------------------------------
# Morrison-Gettleman Microphysics plots (beginning in CAM3.5, with MG 
# microphysics on)
# NOTE: for model-to-model only
set microph = 1          # (0=ON,1=OFF) 


#******************************************************************
#                 INSTALLATION SPECIFIC THINGS
#      ONLY MAKE CHANGES IF YOU ARE INSTALLING THE DIAGNOSTIC
#      PACKAGE (NCL CODE ETC) ON YOUR LOCAL SYSTEM (NON NCAR SITES)
#******************************************************************

# set global and environment variables
unset noclobber
if (! $?NCARG_ROOT) then
  echo ERROR: environment variable NCARG_ROOT is not set
  echo "Do this in your .cshrc file (or whatever shell you use)"
  echo setenv NCARG_ROOT /contrib      # most NCAR systems 
  exit 1
else
  set NCL = $NCARG_ROOT/bin/ncl       # works everywhere
endif 

# Set directory to ncclimo.
# This is changed by diag_run when running with crontab
#setenv ncclimo_dir  /usr/local/bin
#setenv nco_dir  /opt/nco-4.7.6-intel/bin


#******************************************************************
#******************************************************************
#                     S T O P   H E R E 
#                  END OF USER MODIFY SECTION
#******************************************************************
#******************************************************************

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#******************************************************************
#******************************************************************
#                 DON T CHANGE ANYTHING BELOW HERE
#                 OR ELSE YOUR LIFE WILL BE SHORT
#******************************************************************
#******************************************************************
# set c-shell limits
limit stacksize unlimited
limit datasize  unlimited

setenv WKDIR      $test_path_diag/
setenv OBS_DATA   $DIAG_HOME/obs_data 
setenv CAM_DATA   $DIAG_HOME/cam_data 
setenv MAP_DATA   $DIAG_HOME/map_files 
setenv DIAG_CODE  $DIAG_HOME/code
setenv COMPARE    $CNTL
setenv PLOTTYPE   $p_type
setenv COLORTYPE  $c_type
setenv DELETEPS   $delete_ps
setenv MG_MICRO   $microph
setenv HTML_HOME  $DIAG_HOME/html

#-----------------------------------------------------------------

if ($CNTL != OBS) then
if ($CNTL != USER) then
   echo "ERROR: CNTL MUST BE EITHER =OBS OR =USER"
   exit 1
endif
endif            

# Turn off four_seasons if comparing against OBS b/c
# AMWG does not have SON and MAM for all vars in obs_data. 
# nanr 29apr10

if ($CNTL == OBS) then
   set four_seasons = 1
endif                              

# Check if climo/time-series switch has been used by diag_run
# -JL, Nov 2017
if ($CLIMO_TIME_SERIES_SWITCH == ONLY_CLIMO) then
   set tset_1 = 1
   set all_sets = 0
endif

set climo_required = 0
if ($CLIMO_TIME_SERIES_SWITCH == ONLY_TIME_SERIES) then
   set tset_1 = 0
   set test_compute_climo = 1
   set cntl_compute_climo = 1
   set all_sets = 1
   set set_1  = 1 ; set set_2  = 1 ; set set_3  = 1 ; set set_4  = 1
   set set_5  = 1 ; set set_6  = 1 ; set set_7  = 1 ; set set_8  = 1
   set set_9  = 1 ; set set_10 = 1 ; set set_11 = 1 ; set set_12 = 1
   set set_13 = 1 ; set set_14 = 1 ; set set_15 = 1 ; set set_16 = 1
endif

if ($all_sets == 1 && \
    $set_1 == 1 && $set_2 == 1 && $set_3 == 1 && $set_4 == 1 && \
    $set_5 == 1 && $set_6 == 1 && $set_7 == 1 && $set_8 == 1 && \
    $set_9 == 1 && $set_10 == 1 && $set_11 == 1 && $set_12 == 1 && \
    $set_13 == 1 && $set_14 == 1 && $set_15 == 1 && $set_16 == 1) then
   set climo_required     = 1
   set test_compute_climo = 1
   set cntl_compute_climo = 1
endif

#-----------------------------------------------------------------        
# Select the climatological means to be PLOTTED or in tables.
# You must have the appropriate set(s) turned on to make plots.
   
if ($four_seasons == 1 ) then
    set plot_ANN_climo = 0       # (0=ON,1=OFF) 
    set plot_DJF_climo = 0       # (0=ON,1=OFF) 
    set plot_JJA_climo = 0       # (0=ON,1=OFF) 
    set plot_MAM_climo = 1       # (0=ON,1=OFF) 
    set plot_SON_climo = 1       # (0=ON,1=OFF) 
    set plot_MON_climo = 0       # (0=ON,1=OFF) 
endif

if ($four_seasons == 0) then
    set plot_ANN_climo = 0       # (0=ON,1=OFF) 
    set plot_DJF_climo = 0       # (0=ON,1=OFF) 
    set plot_JJA_climo = 0       # (0=ON,1=OFF) 
    set plot_MAM_climo = 0       # (0=ON,1=OFF) 
    set plot_SON_climo = 0       # (0=ON,1=OFF) 
    set plot_MON_climo = 0       # (0=ON,1=OFF) 
endif

#-----------------------------------------------------------------
# Set the rgb file name
if ($c_type == COLOR) then
  if (! $?color_bar) then
    setenv RGB_FILE $DIAG_HOME/rgb/amwg.rgb  # use default
  else
    if ($color_bar == default) then
      setenv RGB_FILE $DIAG_HOME/rgb/amwg.rgb
    else
      if ($color_bar == blue_red) then
           setenv RGB_FILE $DIAG_HOME/rgb/bluered.rgb
      endif
      if ($color_bar == blue_yellow_red) then
        setenv RGB_FILE $DIAG_HOME/rgb/blueyellowred.rgb
      endif
    endif
  endif
endif

#------------------------------------------------------------------------
echo " "
echo "***************************************************"
echo "          CCSM AMWG DIAGNOSTIC PACKAGE"
echo "          Script Version: "$DIAG_VERSION
echo "          NCARG_ROOT = "$NCARG_ROOT
echo "          "`date`
echo "***************************************************"
echo " "
#------------------------------------------------------------
# check for .hluresfile in $HOME
if (! -e $HOME/.hluresfile) then
  echo NO .hluresfile PRESENT IN YOUR $HOME DIRECTORY
  echo COPYING .hluresfile to $HOME
  cp $DIAG_CODE/.hluresfile $HOME
endif

#------------------------------------------------------------
# check if directories exist

if (! -e ${test_path_diag}) then
  echo The directory \$test_path_diag ${test_path_diag} does not exist
  echo Trying to create \$test_path_diag ${test_path_diag} 
  mkdir -p ${test_path_diag} 
  if (! -e ${test_path_diag}) then
    echo ERROR: Unable to create \$test_path_diag : ${test_path_diag}    
    echo ERROR: Please create: ${test_path_diag} 
  exit 1
  endif
endif

if (! -w ${test_path_diag}) then
  echo ERROR: YOU DO NOT HAVE WRITE ACCESS TO \$test_path_diag ${test_path_diag}
  exit 1
endif

if (! -e ${test_path_history}) then
  echo The directory \$test_path_history ${test_path_history} does not exist
  echo Trying to create \$test_path_history ${test_path_history} 
  mkdir -p ${test_path_history} 
  if (! -e ${test_path_history}) then
    echo ERROR: Unable to create \$test_path_history: ${test_path_history} 
    echo ERROR: Please create ${test_path_history} 
   exit 1
  endif
endif

if (! -e ${test_path_climo}) then
  echo The directory \$test_path_climo ${test_path_climo} does not exist
  echo Trying to create \$test_path_climo ${test_path_climo} 
  mkdir -p ${test_path_climo} 
  if (! -e ${test_path_climo}) then
    echo ERROR: Unable to create \$test_path_climo: ${test_path_climo} 
    echo ERROR: Please create ${test_path_climo} 
   exit 1
  endif
endif

if (! -e ${test_path_diag}) then
  echo The directory \$test_path_diag ${test_path_diag} does not exist
  echo Trying to create \$test_path_diag ${test_path_diag} 
  mkdir -p ${test_path_diag} 
  if (! -e ${test_path_diag}) then
    echo ERROR: Unable to create \$test_path_diag: ${test_path_diag} 
    echo ERROR: Please create ${test_path_diag} 
   exit 1
  endif
endif

if ($CNTL == USER) then
  if (! -e ${cntl_path_history}) then
    echo The directory \$cntl_path_history ${cntl_path_history} does not exist
    echo Trying to create \$cntl_path_history ${cntl_path_history} 
    mkdir -p ${cntl_path_history}    
    if (! -e ${cntl_path_history}) then
       echo ERROR: Unable to create \$cntl_path_history: ${cntl_path_history} 
       echo ERROR: Please create ${cntl_path_history} 
       exit 1
    endif
  endif
endif

if ($CNTL == USER) then
  if (! -e ${cntl_path_climo}) then
    echo The directory \$cntl_path_climo ${cntl_path_climo} does not exist
    echo Trying to create \$cntl_path_climo ${cntl_path_climo} 
    mkdir -p ${cntl_path_climo}    
    if (! -e ${cntl_path_climo}) then
       echo ERROR: Unable to create \$cntl_path_climo: ${cntl_path_climo} 
       echo ERROR: Please create  ${cntl_path_climo} 
       exit 1
    endif
  endif
endif


#-----------------------------------------------------------------
if ($paleo == 0) then
  setenv PALEO True
  if ($diff_plots == 0) then    # only allow when paleoclimate true
    setenv DIFF_PLOTS True      
  else
    setenv DIFF_PLOTS False
  endif
else
  setenv PALEO False
  setenv PALEOCOAST1 null
  setenv PALEOCOAST2 null
  setenv DIFF_PLOTS False
endif

#-----------------------------------------------------------------
if ($time_stamp == 0) then
  setenv TIMESTAMP True
else
  setenv TIMESTAMP False
endif
if ($tick_marks == 0) then
  setenv TICKMARKS True
else
  setenv TICKMARKS False
endif
if ($custom_names == 0) then
  setenv CASENAMES True
  setenv CASE1 $test_name
  setenv CASE2 $cntl_name
else
  setenv CASENAMES False
  setenv CASE1 null 
  setenv CASE2 null
  setenv CNTL_PLOTVARS null  
endif

#--------------------------------------------------------------------
# Variables for significance
if ($significance == 0) then 
  if ($CNTL == OBS) then
    echo "SIGNIFICANCE TEST ONLY AVAILABLE FOR MODEL-TO-MODEL COMPARISONS."
    echo "-----> USING significance=1"
    set        significance = 1
    setenv SIG_PLOT False
    setenv SIG_LVL "null"
  else if ($CNTL == USER && $test_nyrs < 10) then
    echo "ERROR: NUMBER OF TEST CASE YRS $test_nyrs IS TOO SMALL FOR SIGNIFICANCE TEST."
    exit 1
  else if ($CNTL == USER && $cntl_nyrs < 10) then
    echo "ERROR: NUMBER OF CNTL CASE YRS $cntl_nyrs IS TOO SMALL FOR SIGNIFICANCE TEST."
    exit 1
  else
    setenv SIG_PLOT True
    setenv SIG_LVL $sig_lvl
  endif
else
  setenv SIG_PLOT False
  setenv SIG_LVL "null"
endif 

#-----------------------------------------------------------------
# set test directory names
#-----------------------------------------------------------------
set test_in  = ${test_path_climo}/${test_casename}       # input files 
set test_out = ${test_path_climo}/${test_casename}       # output files

#--------------------------------------------------------------------
# set control case names
#-----------------------------------------------------------------
echo ' '
if ($CNTL == OBS) then        # observed data
 echo '------------------------------'
 echo  COMPARISONS WITH OBSERVED DATA 
 echo '------------------------------'
 set cntl_in = $OBS_DATA
endif

if ($CNTL == USER) then        # user specified
 echo '------------------------------------'
 echo  COMPARISONS WITH USER SPECIFIED CNTL 
 echo '------------------------------------'
 echo ' '
 set cntl_in  = ${cntl_path_climo}/${cntl_casename}
 set cntl_out = ${cntl_path_climo}/${cntl_casename}
endif


#----------------------------------------------------------------
# Do some safety checks
#----------------------------------------------------------------

#if ($test_in == $cntl_in) then
#  echo ERROR: THE CLIMO PATHS ARE IDENTICAL FOR TEST AND CNTL
#  echo EROOR: test_path_climo and cntl_path_climo SHOULD BE DIFFERENT
#  echo ERROR: test_path_climo   $test_in 
#  echo ERROR: cntl_path_climo   $cntl_in 
#  exit 1 ##++ hannay  =>want to change script to allow to compare two 2 time-periods of the same run
#endif   
if ($CNTL == USER) then    
  if ($test_casename == $cntl_casename) then
    echo "WARNING: THE TEST AND CNTL AND CASENAME NAMES ARE IDENTICAL"
    echo "->SWITCHING OFF TIME SERIES COMPUTATIONS"
    set tset_1 = 1
    ##exit  ## ++ hannay  =>want to change script to allow to compare two 2 time-periods of the same run
  endif
#  if ($test_path_history == $cntl_path_history) then
#    echo ERROR: THE TEST PATH AND CNTL PATH ARE IDENTICAL
#    echo THEY MUST BE DIFFERENT TO RECEIVE HPSS DOWNLOADS!
#    exit 1  
#  endif
endif   

#*****************************************************************
# Determine attributes of history files
#*****************************************************************
## Hannay: Later on, we want to add: 'physics' attribute
if ($CLIMO_TIME_SERIES_SWITCH != ONLY_TIME_SERIES) then
  @ test_last_yr = $test_first_yr + $test_nyrs - 1
  set test_first_yr_prnt = `printf "%04d" ${test_first_yr}`
  set test_last_yr_prnt = `printf "%04d" ${test_last_yr}`

  if ($CNTL == USER) then
    @ cntl_last_yr = $cntl_first_yr + $cntl_nyrs - 1
    set cntl_first_yr_prnt = `printf "%04d" ${cntl_first_yr}`
    set cntl_last_yr_prnt = `printf "%04d" ${cntl_last_yr}`
  endif
else
  set test_first_yr_prnt = `printf "%04d" ${test_first_yr_ts}`
  set test_last_yr_prnt = `printf "%04d" ${test_last_yr_ts}`

  if ($CNTL == USER) then
    set cntl_first_yr_prnt = `printf "%04d" ${cntl_first_yr_ts}`
    set cntl_last_yr_prnt = `printf "%04d" ${cntl_last_yr_ts}`
  endif
endif
  
if ($CLIMO_TIME_SERIES_SWITCH != ONLY_TIME_SERIES) then
  echo "DETERMINE ATTRIBUTES FOR HISTORY FILES"
  echo ' '

  if ($test_filetype == "monthly_history") then
    set test_keyFile = "null"
  else
    set test_keyFile = `ls ${test_path_history}/${test_casename}*.nc | head -n 1`
  endif

  $DIAG_CODE/determine_output_attributes.csh   test  \
                                                     $test_casename \
                                               $test_path_history \
                                               $test_path_climo \
                                               $test_path_diag \
                                               $test_first_yr \
                                               $test_compute_climo \
                                               $test_filetype \
                                               $test_keyFile \
                                               $climo_required \
                                               $test_last_yr

  if ($status > 0) then
    echo "*** CRASH IN determine_output_attributes.csh (test)"  
    echo "*** EXITING THE SCRIPT"
    exit 1
  endif
    
  set test_rootname  = `cat $test_path_diag/attributes/test_rootname`
  set test_grid      = `cat $test_path_diag/attributes/test_grid`
  set test_res_in    = `cat $test_path_diag/attributes/test_res`
  set test_var_list  = `cat $test_path_diag/attributes/test_var_list`

  echo ' '
  echo 'TEST CASE ATTRIBUTES'
  echo '  test_rootname' =  $test_rootname
  echo '  test_grid' = $test_grid
  echo '  test_res_in' = $test_res_in
  echo '  test_res_in' = $test_res_in

  if ($CNTL == USER) then  

    if ($cntl_filetype == "monthly_history") then
      set cntl_keyFile = "null"
    else
      set cntl_keyFile = `ls ${cntl_path_history}/${cntl_casename}*.nc | head -n 1`
    endif

    $DIAG_CODE/determine_output_attributes.csh   cntl \
                                                 $cntl_casename \
                                                 $cntl_path_history \
                                                 $cntl_path_climo \
                                                 $test_path_diag \
                                                 $cntl_first_yr \
                                                 $cntl_compute_climo \
                                                 $cntl_filetype \
                                                 $cntl_keyFile \
                                                 $climo_required \
                                                 $cntl_last_yr
                                                 
    if ($status > 0) then
       echo "*** CRASH IN determine_output_attributes.csh (cntl)"
       echo "*** EXITING THE SCRIPT"
       exit 1
    endif

    set cntl_rootname  = `cat $test_path_diag/attributes/cntl_rootname`
    set cntl_grid      = `cat $test_path_diag/attributes/cntl_grid`
    set cntl_res_in    = `cat $test_path_diag/attributes/cntl_res`
    set cntl_var_list  = `cat $test_path_diag/attributes/cntl_var_list`

    echo ' '
    echo 'CNTL CASE ATTRIBUTES'
    echo '  cntl_rootname' =  $cntl_rootname
    echo '  cntl_grid' = $cntl_grid
    echo '  cntl_res_in' = $cntl_res_in
  else
    set cntl_rootname  = " " 
    set cntl_grid      = " " 
    set cntl_res_in    = " " 
    set cntl_var_list  = " " 
  endif

#*************************************************************************
# If computing climatological means, check if all monthly file are present 
#*************************************************************************

#-----------
# Test case
#-----------

  if ($test_compute_climo == 0) then
    if ($test_filetype == "monthly_history") then
      # We check the monthly files are present
      $DIAG_CODE/check_history_present.csh  MONTHLY \
                                            $test_path_history \
                                            $test_first_yr \
                                            $test_nyrs \
                                            $test_rootname \
                                            $test_casename \
                                            $test_path_climo

      if ($status > 0) then
        echo "*** CRASH IN check_history_present.csh (test)"
        echo "*** EXITING THE SCRIPT"
        exit 1
      endif
    
      # For DJF determine if we use December from previous year or from
      # the same year (seasonally discontinuous DJF)
      @ prev_yri = $test_first_yr - 1
      set filename_prev_year = ${test_rootname}`printf "%04d" ${prev_yri}`
      if ( -e ${test_path_history}/${filename_prev_year}-12.nc ) then   
        set test_djf = SCD # Seasonally Continuous DJF
        echo "-->FOUND DECEMBER FILE FROM YEAR ${prev_yri}: USING test_djf=SCD"
      else
        set test_djf = SDD # Seasonally Discontinuous DJF
        echo "-->NO DECEMBER FILE FROM YEAR ${prev_yri} WAS FOUND: USING test_djf=SDD"
      endif
      echo ' '
    else
      @ test_end = $test_first_yr + $test_nyrs - 1
      $DIAG_CODE/check_timeSeries.pl $test_path_history \
                                     $test_rootname \
                                     $test_first_yr \
                                     $test_end \
                                     $test_path_climo \
                                     $strip_off_vars \
                                     $test_var_list \
                                     test_file_list.txt
      if ($status > 0) then
        echo "*** Test case: not all CAM output files were found."  
        echo "*** Check that the casename and year ranges are correct."
        echo "*** Exiting the script."
        exit 1
      endif
      set test_djf = `head -n 1 $test_path_climo/DJF.txt`
    endif
  endif

#-----------
# Control
#-----------

  if ($CNTL == USER && $cntl_compute_climo == 0) then

    if ($cntl_filetype == "monthly_history") then
      # We check the monthly files are present
      $DIAG_CODE/check_history_present.csh  MONTHLY \
                                             $cntl_path_history \
                                            $cntl_first_yr \
                                            $cntl_nyrs \
                                            $cntl_rootname \
                                            $cntl_casename \
                                            $cntl_path_climo

      if ($status > 0) then
        echo "*** CRASH IN check_history_present.csh (cntl)"
        echo "*** EXITING THE SCRIPT"
        exit 1
      endif
    
      # For DJF determine if we use December from previous year or from
      # the same year (seasonally discontinuous DJF)
      @ prev_yri = $cntl_first_yr - 1
      set filename_prev_year = ${cntl_rootname}`printf "%04d" ${prev_yri}`
      if ( -e ${cntl_path_history}/${filename_prev_year}-12.nc) then   
        set cntl_djf = SCD # Seasonally Continuous DJF
        echo "-->FOUND DECEMBER FILE FROM YEAR ${prev_yri}: USING cntl_djf=SCD"
      else
         set cntl_djf = SDD # Seasonally Discontinuous DJF
        echo "-->NO DECEMBER FILE FROM YEAR ${prev_yri} WAS FOUND: USING cntl_djf=SDD"
      endif
      echo ' '
    else
      @ cntl_end = $cntl_first_yr + $cntl_nyrs - 1
      $DIAG_CODE/check_timeSeries.pl $cntl_path_history \
                                     $cntl_rootname \
                                     $cntl_first_yr \
                                     $cntl_end \
                                     $cntl_path_climo \
                                     $strip_off_vars \
                                     $cntl_var_list \
                                     cntl_file_list.txt
      if ($status == 1) then
        echo "*** Control case: Not all CAM output files were found."  
        echo "*** Check that the casename and year ranges are correct."
        echo "*** Exiting the script."
        exit 1
      endif
      set cntl_djf = `head -n 1 $cntl_path_climo/DJF.txt`
    endif
  endif
endif
#**************************************************************
#***************************************************************
# If not using swift => beginning of non swift branch
setenv use_swift 1
echo "SWIFT:" $use_swift
# Swift is not yet supported on NIRD. / JL
#***************************************************************
#**************************************************************

if ($use_swift == 1) then  # beginning of use_swift branch
  if ($CLIMO_TIME_SERIES_SWITCH != ONLY_TIME_SERIES) then

  #**********************************************************************
  # COMPUTE CLIMATOLOGIES
  #**********************************************************************
  # JL Sep 2017:
  # Updated methodology for computing the climatologies
  # (see README.NorESM for more info)
  #---------------------------------------------------------------------
  #  COMPUTE CLIMATOLOGIES FOR TEST CASE
  #---------------------------------------------------------------------

    if ($test_compute_climo == 0) then
      set time_start_climo = `date +%s`
      $DIAG_CODE/compute_climo.csh  $test_path_history \
                                    $test_path_climo \
                                    $test_path_diag \
                                    $test_first_yr \
                                    $test_nyrs \
                                    $test_casename \
                                    $test_rootname \
                                    $strip_off_vars \
                                    test \
                                    $test_djf \
                                    $test_filetype \
                                    $DIAG_CODE \
                                    $significance

      if ($status > 0) then
        echo "*** CRASH IN compute_climo.csh (test)"  
        echo "*** EXITING THE SCRIPT"
        exit 1
      endif
    endif

#---------------------------------------------------------------------
#  COMPUTE CLIMATOLOGIES FOR CTNL CASE
#---------------------------------------------------------------------

    if ( ($CNTL == USER) && ($cntl_compute_climo == 0)  ) then 

      $DIAG_CODE/compute_climo.csh  $cntl_path_history \
                                    $cntl_path_climo \
                                    $test_path_diag \
                                    $cntl_first_yr \
                                    $cntl_nyrs \
                                    $cntl_casename \
                                    $cntl_rootname \
                                    $strip_off_vars \
                                    cntl \
                                    $cntl_djf \
                                    $cntl_filetype \
                                    $DIAG_CODE \
                                    $significance

      if ($status > 0) then
        echo "*** CRASH IN compute_climo.csh (cntl)"  
        echo "*** EXITING THE SCRIPT"
        exit 1
      endif
    endif  ## end of if ( ($CNTL == USER) && ($cntl_compute_climo == 0) )
    set time_end_climo = `date +%s`

#---------------------------------------------------------------------
#  If SE grid, convert to lat/lon grid
#---------------------------------------------------------------------

    if ($test_grid == SE && $test_compute_climo == 0) then

      echo Regridding Test case

      setenv INGRID $test_res_in
      setenv OUTGRID $test_res_out
      mkdir ${test_path_climo}/sav_se
      ls ${test_out}*.nc > ${test_path_climo}/climo_files
      set files = `cat ${test_path_climo}/climo_files`
      foreach file ($files)
        set se_file=$file:r_$test_grid.nc
        echo " "
        echo REMAP $file from CAM-SE grid to RECTILINEAR $OUTGRID
        mv $file $se_file
        setenv TEST_INPUT ${se_file}
        setenv TEST_PLOTVARS ${file}
        $NCL <  $DIAG_CODE/regridclimo.ncl
        mv $se_file ${test_path_climo}/sav_se
      end
    endif   

    if ($CNTL == USER) then
      if ($cntl_grid == SE && $cntl_compute_climo == 0) then

        echo Regridding CNTL case

        setenv INGRID $cntl_res_in
        setenv OUTGRID $cntl_res_out 
        mkdir ${cntl_path_climo}/sav_se
        ls ${cntl_out}*.nc > ${cntl_path_climo}/climo_files
        cat ${cntl_path_climo}/climo_files
        set files = `cat ${cntl_path_climo}/climo_files`
   
        foreach file ($files)
          set se_file=$file:r_$cntl_grid.nc
          echo " "
          echo REMAP $file from CAM-SE grid to RECTILINEAR $OUTGRID
          mv $file $se_file
          setenv TEST_INPUT ${se_file}
          setenv TEST_PLOTVARS ${file}
          $NCL <  $DIAG_CODE/regridclimo.ncl
          mv $se_file ${cntl_path_climo}/sav_se
        end
      endif
    endif

#**************************************************************
# Check if climos are present
#**************************************************************

    if ($climo_required == 0) then
      echo "====>" $four_seasons

      if ($four_seasons == 0) then
        set climo_months = (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF MAM JJA SON)
      else
        set climo_months = (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF JJA)   
      endif

#--------------------------------------------------------------------
# check for test case climo files always needed
#--------------------------------------------------------------------

      echo 'CHECKING FOR TEST CLIMO FILES'
      echo ' '

      foreach mth ($climo_months)
        set climo_file=${test_path_climo}/${test_casename}_${mth}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
        if (! -e $climo_file) then    
          echo ' '
          echo ERROR: $climo_file  NOT FOUND
          exit 1
        else
          echo FOUND : $climo_file
        endif
      end

      # climatological files are present
      echo '-->ALL NEEDED '${test_casename}' CLIMO AND/OR MEANS FILES FOUND'
      echo ' '

#--------------------------------------------------------------------
# check for cntl case climo files if needed
#--------------------------------------------------------------------
      if ($CNTL == USER) then

        echo 'CHECKING FOR CTNL CLIMO FILES'
        echo ' '

        foreach mth ($climo_months)
          set climo_file=${cntl_path_climo}/${cntl_casename}_${mth}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
          if (! -e $climo_file) then    
            echo ' '
            echo ERROR: $climo_file  NOT FOUND
            exit 1
          else
            echo FOUND : $climo_file
          endif
        end

        # climatological files are present
        echo '-->ALL NEEDED '${cntl_casename}' CLIMO AND/OR MEANS FILES FOUND'
      endif
    endif
  endif
    
#---------------------------------------------------------------------
# COMPUTE TIME SERIES
#---------------------------------------------------------------------
# code largely copied from ice_diag -- JL, Nov 2017

  if ($tset_1 == 0) then
    if ($CNTL == OBS) then
      set CASES_TO_READ = ( $test_casename )
      set DATA_ROOT_VEC = ( $test_path_history_root )
      set CASE_TYPES    = ( test )
    else
      set CASES_TO_READ = ( $test_casename $cntl_casename )
      set DATA_ROOT_VEC = ( $test_path_history_root $cntl_path_history_root )
      set CASE_TYPES    = ( test cntl )
    endif

    echo "---------------------------"
    echo "COMPUTE ANNUAL TIME SERIES "
    echo "---------------------------"
    if ($TRENDS_ALL == 1) then
      # Make trends over the entire experiment
      echo "COMPUTING FIRST AND LAST YR OF TRENDS:"
      set BEGYRS = ()
      set ENDYRS = ()
      @ m = 1
      foreach CASE_TO_READ ($CASES_TO_READ)
        set DATA_ROOT   = $DATA_ROOT_VEC[$m]
        set file_prefix = ${DATA_ROOT}/${CASE_TO_READ}/atm/hist/${CASE_TO_READ}.cam.h0.
        set first_file  = `ls ${file_prefix}* | head -n 1`
        set last_file   = `ls ${file_prefix}* | tail -n 1`
        if ("$first_file" == "") then
          set file_prefix = ${DATA_ROOT}/${CASE_TO_READ}/atm/hist/${CASE_TO_READ}.cam2.h0.
          set first_file  = `ls ${file_prefix}* | head -n 1`
          set last_file   = `ls ${file_prefix}* | tail -n 1`
          if ("$first_file" == "") then
            echo "ERROR: No history files ${CASE_TO_READ} exist in $DATA_ROOT"
            echo "***EXITING THE SCRIPT"
            exit 1
          endif
        endif
        set fyr_in_dir_prnt = `echo $first_file | rev | cut -c 7-10 | rev`
        set fyr_in_dir      = `echo $fyr_in_dir_prnt | sed 's/^0*//'`
        set lyr_in_dir_prnt = `echo $last_file | rev | cut -c 7-10 | rev`
        set lyr_in_dir      = `echo $lyr_in_dir_prnt | sed 's/^0*//'`
        if (! -e ${file_prefix}${lyr_in_dir_prnt}-12.nc) then
          @ lyr_in_dir = $lyr_in_dir - 1
          set lyr_in_dir_prnt = `printf "%04d" ${fyr_in_dir}`
        endif
        if ($fyr_in_dir == $lyr_in_dir) then
          echo "ERROR: First and last year in ${CASE_TO_READ} are identical: cannot compute trends"
          echo "***EXITING THE SCRIPT"
          exit 1
        endif
        set BEGYRS = ($BEGYRS $fyr_in_dir)
        set ENDYRS = ($ENDYRS $lyr_in_dir)
        @ m++
      end
    else
      if ($CNTL == OBS) then
        set BEGYRS = ($test_first_yr_ts)
        set ENDYRS = ($test_last_yr_ts)
      else
        set BEGYRS = ($test_first_yr_ts $cntl_first_yr_ts)
        set ENDYRS = ($test_last_yr_ts $cntl_last_yr_ts)
      endif
    endif
    echo " BEGYRS = $BEGYRS"
    echo " ENDYRS = $ENDYRS"
    echo "---------------------------"
    @ m = 1
    foreach CASE_TO_READ ($CASES_TO_READ)
      set DATA_ROOT   = $DATA_ROOT_VEC[$m]
      $DIAG_CODE/determine_output_attributes_ts.csh ${CASE_TYPES[$m]} $CASE_TO_READ $DATA_ROOT $test_path_diag ${BEGYRS[$m]}
      set CAM_GRID = `cat $test_path_diag/attributes/test_grid`
      $DIAG_CODE/compute_time_series.csh $timeseries_path $CASE_TO_READ ${DATA_ROOT_VEC[$m]} ${BEGYRS[$m]} ${ENDYRS[$m]} $test_path_diag ${CASE_TYPES[$m]} $CAM_GRID $four_seasons
      @ m++
    end
    if ($time_series_obs == 0) then
      $DIAG_CODE/global_mean_obs.csh $timeseries_path $test_casename
    endif
  endif

#**************************************************************************

if ($set_1 == 1 && $set_2 == 1 && $set_3 == 1 && $set_4 == 1 && $set_4a == 1 && \
    $set_5 == 1 && $set_6 == 1 && $set_7 == 1 && $set_8 == 1 && \
    $set_9 == 1 && $set_10 == 1 && $set_11 == 1 && $set_12 &&  \
    $set_13 == 1 && $set_14 == 1 && $set_15 == 1 && $set_16 == 1 && \
    $tset_1 == 1 && \
    $wset_1 == 1 && \
    $cset_1 == 1 && $cset_2 == 1 && $cset_3 == 1 && $cset_4 == 1 && $cset_5 == 1 && $cset_6 == 1 &&  $cset_7 == 1 && \
    $all_sets == 1 && $all_waccm_sets == 1 && $all_chem_sets == 1) then
  echo ' '
  echo "NO DIAGNOSTIC SETS SELECTED (1-13)" 
  exit 1
endif

# Set this to 0; WACCM sets can turn it on.
setenv USE_WACCM_LEVS 0

#**************************************************************************
if ($CLIMO_TIME_SERIES_SWITCH != ONLY_TIME_SERIES) then
  if ($plot_ANN_climo == 1 && $plot_DJF_climo == 1 && \
    $plot_SON_climo == 1 && $plot_MAM_climo == 1 && \
    $plot_JJA_climo == 1 && $plot_MON_climo == 1) then
    echo ' '
    echo "NO SELECTION MADE (ANN, MAM, JJA, SON, DJF, MON) FOR TABLES AND/OR PLOTS"
    exit 1
  endif
endif

if ($four_seasons == 0) then
  set plots = (ANN DJF MAM JJA SON)
else
  set plots = (ANN DJF JJA)
endif


#**********************************************************************
# check for plot variable files and delete them if present

if ($CLIMO_TIME_SERIES_SWITCH != ONLY_TIME_SERIES) then
  foreach mth  (ANN DJF MAM JJA SON 01 02 03 04 05 06 07 08 09 10 11 12)

    set file=${test_path_diag}/${test_casename}_${mth}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
    if (-e ${file}) then
      \rm -f ${file}
    endif

    if ($CNTL != OBS) then
      set file=${test_path_diag}/${cntl_casename}_${mth}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
      if (-e ${file} ) then
        \rm -f ${file}  
      endif
    endif

    set file=${test_path_diag}/${test_casename}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
    if (-e ${file}) then
      \rm -f ${file}
    endif
  
    if ($CNTL != OBS) then
      set file=${test_path_diag}/${cntl_casename}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
      if (-e ${file} ) then
        \rm -f ${file}  
      endif
    endif

    if ($significance == 0) then 
      set file=${test_path_diag}/${test_casename}_${mth}_${test_first_yr_prnt}-${test_last_yr_prnt}_variance.nc
      if (-e ${file}) then
        \rm -f ${file}
      endif
    
      if ($CNTL != OBS) then
        set file=${test_path_diag}/${cntl_casename}_${mth}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_variance.nc
        if (-e ${file} ) then
           \rm -f ${file}  
        endif
      endif
    endif
  end
endif

# initial mode is to create new netcdf files
setenv NCDF_MODE create

#***************************************************************
# Setup webpages and make tar file
if ($web_pages == 0) then
  setenv DENSITY $density
  if ($img_type == 0) then
    set image = png
  else
    if ($img_type == 1) then
      set image = gif
    else
      set image = jpg
    endif
  endif
  if ($p_type != ps) then
    echo "ERROR: WEBPAGES ARE ONLY MADE FOR POSTSCRIPT PLOT TYPE"
    exit 1
  endif
  if ($CLIMO_TIME_SERIES_SWITCH != ONLY_TIME_SERIES) then
    @ test_end = $test_first_yr + $test_nyrs - 1
    if ($CNTL == OBS) then
      setenv WEBDIR ${test_path_diag}/yrs${test_first_yr}to${test_end}-obs
      if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
      if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
      cd $WEBDIR
      $HTML_HOME/setup_obs $test_casename $image $time_series_obs
      cd $test_path_diag
      set tarfile = yrs${test_first_yr}to${test_end}-obs.tar
    else          # model-to-model
      @ cntl_end = $cntl_first_yr + $cntl_nyrs - 1
      setenv WEBDIR ${test_path_diag}/yrs${test_first_yr}to${test_end}-${cntl_casename}-yrs${cntl_first_yr}to${cntl_end}
      if ($test_casename == $cntl_casename) then
        setenv WEBDIR ${test_path_diag}/yrs${test_first_yr}to${test_end}-yrs${cntl_first_yr}to${cntl_end}
      endif
      if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
      if (! -e ${WEBDIR}) then
         echo ERROR: Unable to create \$WEBDIR: ${WEBDIR}
         echo "***EXITING THE SCRIPT"
         exit 1
      endif
      if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
      cd $WEBDIR
      $HTML_HOME/setup_2models $test_casename $cntl_casename $image yrs${test_first_yr}to${test_end} yrs${cntl_first_yr}to${cntl_end}
      cd $test_path_diag
      if ($test_casename == $cntl_casename) then
        set tarfile = yrs${test_first_yr}to${test_end}-yrs${cntl_first_yr}to${cntl_end}.tar
      else
        set tarfile = yrs${test_first_yr}to${test_end}-${cntl_casename}-yrs${cntl_first_yr}to${cntl_end}.tar
      endif
    endif
  else # time series
    if ($CNTL == OBS) then
      setenv WEBDIR ${test_path_diag}/ts${BEGYRS[1]}to${ENDYRS[1]}
      if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
      if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
      cd $WEBDIR
      $HTML_HOME/setup_obs $test_casename $image $time_series_obs
      cd $test_path_diag
      set tarfile = ts${BEGYRS[1]}to${ENDYRS[1]}.tar
    else          # model-to-model
      setenv WEBDIR ${test_path_diag}/ts${BEGYRS[1]}to${ENDYRS[1]}-${cntl_casename}
      if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
      if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
      cd $WEBDIR
      $HTML_HOME/setup_2models $test_casename $cntl_casename $image yrs${test_first_yr_ts}to${test_last_yr_ts} yrs${cntl_first_yr_ts}to${cntl_last_yr_ts}
      cd $test_path_diag
      set tarfile = ts${BEGYRS[1]}to${ENDYRS[1]}-${cntl_casename}.tar
    endif
  endif

#****************************************************************
#   SET 1 - TABLES OF MEANS, DIFFS, RMSE
#****************************************************************
if ($all_sets == 0 || $set_1 == 0) then

    echo " "
    echo SET 1 TABLES OF MEANS, DIFFS, RMSES

    foreach name ($plots)
        setenv SEASON $name 
        setenv TEST_INPUT    ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
        if ($CNTL == OBS) then 
            setenv CNTL_INPUT $OBS_DATA
        else
            setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
            setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
        endif
        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif
        echo MAKING $SEASON TABLES 
        $NCL <  $DIAG_CODE/tables.ncl
        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
    end
    if ($web_pages == 0) then
        mv *.asc $WEBDIR/set1
    endif

endif

#*****************************************************************
#   SET 2 - ANNUAL LINE PLOTS OF IMPLIED FLUXES
#*****************************************************************

if ($all_sets == 0 || $set_2 == 0) then
    echo " "
    echo SET 2 ANNUAL IMPLIED TRANSPORTS
    setenv TEST_INPUT ${test_path_climo}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
    setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
    if ($CNTL == OBS) then
        setenv CNTL_INPUT $OBS_DATA
    else
        setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_ANN_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
        setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_ANN_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
    endif
    if (-e $TEST_PLOTVARS) then
        setenv NCDF_MODE write
    else
        setenv NCDF_MODE create
    endif
    echo OCEAN FRESHWATER TRANSPORT 
    $NCL < $DIAG_CODE/plot_oft.ncl
    if ($NCDF_MODE == create) then
        setenv NCDF_MODE write
    endif
    echo OCEAN AND ATMOSPHERIC TRANSPORT
    $NCL < $DIAG_CODE/plot_oaht.ncl
    if ($NCDF_MODE == create) then
        setenv NCDF_MODE write
    endif

    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh set2 $image &
    endif

endif

#*****************************************************************
#   SET 3 - ZONAL LINE PLOTS
#*****************************************************************

if ($all_sets == 0 || $set_3 == 0) then
    echo " "
    echo SET 3 ZONAL LINE PLOTS

    foreach name ($plots)
        setenv SEASON $name
        setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc  
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
        if ($CNTL == OBS) then
            setenv CNTL_INPUT $OBS_DATA 
        else
            setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc    
            setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
        endif 
        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif
        echo MAKING $SEASON PLOTS 
        $NCL < $DIAG_CODE/plot_zonal_lines.ncl
        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
    end

    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh set3 $image &
    endif

endif

#*****************************************************************
#   SET 4 - LAT/PRESS CONTOUR PLOTS
#*****************************************************************

if ($all_sets == 0 || $set_4 == 0) then
echo " "
echo SET 4 VERTICAL CONTOUR PLOTS

foreach name ($plots)
  setenv SEASON $name 
  setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
  if ($CNTL == OBS) then
    setenv CNTL_INPUT $OBS_DATA
  else
    setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
    setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
  endif
  if (-e $TEST_PLOTVARS) then
    setenv NCDF_MODE write
  else
    setenv NCDF_MODE create
  endif
  echo MAKING $SEASON PLOTS 
  $NCL < $DIAG_CODE/plot_vertical_cons.ncl
  if ($NCDF_MODE == create) then
    setenv NCDF_MODE write
  endif
end

if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set4 $image &
endif

endif

#*****************************************************************
#   SET 4a - LON/PRESS CONTOUR PLOTS (10N-10S)
#*****************************************************************

if ($all_sets == 0 || $set_4a == 0) then
    echo " "
    echo SET 4a VERTICAL LON-PRESS CONTOUR PLOTS
    
    foreach name ($plots)
        setenv SEASON $name 
        setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
        if ($CNTL == OBS) then
            setenv CNTL_INPUT $OBS_DATA
        else
            setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
            setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
        endif
        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif
        echo MAKING $SEASON PLOTS 
        $NCL < $DIAG_CODE/plot_vertical_xz_cons.ncl
        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
     end

    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh set4a $image &
    endif

endif

#****************************************************************
#   SET 5 - LAT/LONG CONTOUR PLOTS
#****************************************************************
if ($all_sets == 0 || $set_5 == 0) then
    echo " "
    echo SET 5 LAT/LONG CONTOUR PLOTS 

    if ($paleo == 0) then
        echo ' '
        setenv MODELFILE ${test_path_climo}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
        setenv LANDMASK $land_mask1
        if (-e ${test_path_climo}/${test_casename}.lines && -e ${test_path_climo}/${test_casename}.names) then
            echo TEST CASE COASTLINE DATA FOUND
            setenv PALEODATA ${test_path_climo}/${test_casename}
        else
            echo CREATING TEST CASE PALEOCLIMATE COASTLINE FILES 
            setenv PALEODATA ${test_path_climo}/${test_casename}
        endif
        $NCL < $DIAG_CODE/plot_paleo.ncl
        setenv PALEOCOAST1 $PALEODATA
        if ($CNTL == OBS) then
            setenv PALEOCOAST2 "null"
        endif
        if ($CNTL == USER) then
            echo ' '
            setenv MODELFILE ${cntl_path_climo}/${cntl_casename}_ANN_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
            setenv LANDMASK $land_mask2
            if (-e ${cntl_path_climo}/${cntl_casename}.lines && -e ${cntl_path_climo}/${cntl_casename}.names) then
                echo CNTL CASE COASTLINE DATA FOUND
                setenv PALEODATA $cntl_in
            else
                echo CREATING CNTL CASE PALEOCLIMATE COASTLINE FILES 
                setenv PALEODATA $cntl_out
            endif
            $NCL < $DIAG_CODE/plot_paleo.ncl
            setenv PALEOCOAST2 $PALEODATA 
        endif
    endif

    foreach name ($plots)
        setenv SEASON $name 
        setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
        if ($CNTL == OBS) then
            setenv CNTL_INPUT $OBS_DATA
        else
            setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
            setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
        endif
        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif   
        if ($significance == 0) then
            setenv TEST_MEANS    ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_means.nc
            setenv TEST_VARIANCE ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_variance.nc
            setenv CNTL_MEANS    ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_means.nc
            setenv CNTL_VARIANCE ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_variance.nc
            if (-e $TEST_VARIANCE) then
                setenv VAR_MODE write
            else
                setenv VAR_MODE create
            endif  
        else
            setenv SIG_LVL null
            setenv TEST_MEANS null
            setenv TEST_VARIANCE null
            setenv CNTL_MEANS null
            setenv CNTL_VARIANCE null
            setenv VAR_MODE null
        endif
        echo MAKING $SEASON PLOTS
        $NCL < $DIAG_CODE/plot_surfaces_cons.ncl 
        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
        if ($significance == 0) then 
            if($VAR_MODE == create) then
                setenv VAR_MODE write
            endif
        endif
    end

if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set5 $image &
endif

endif

#****************************************************************
#   SET 6 - LAT/LONG VECTOR PLOTS
#****************************************************************
if ($all_sets == 0 || $set_6 == 0) then

echo " "
echo SET 6 LAT/LONG VECTOR PLOTS 

if ($paleo == 0) then
  echo ' '
  setenv MODELFILE ${test_path_climo}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv LANDMASK $land_mask1
  if (-e ${test_path_climo}/${test_casename}.lines && -e ${test_path_climo}/${test_casename}.names) then
    echo TEST CASE COASTLINE DATA FOUND
    setenv PALEODATA ${test_path_climo}/${test_casename}
  else
    echo CREATING TEST CASE PALEOCLIMATE COASTLINE FILES 
    setenv PALEODATA ${test_path_climo}/${test_casename}
  endif
  $NCL < $DIAG_CODE/plot_paleo.ncl
  setenv PALEOCOAST1 $PALEODATA
  if ($CNTL == USER) then
    echo ' '
    setenv MODELFILE ${cntl_path_climo}/${cntl_casename}_ANN_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
    setenv LANDMASK $land_mask2
    if (-e ${cntl_path_climo}/${cntl_casename}.lines && -e ${cntl_path_climo}/${cntl_casename}.names) then
      echo CNTL CASE COASTLINE DATA FOUND
      setenv PALEODATA $cntl_in
    else
      echo CREATING CNTL CASE PALEOCLIMATE COASTLINE FILES 
      setenv PALEODATA $cntl_out
    endif
    $NCL < $DIAG_CODE/plot_paleo.ncl
    setenv PALEOCOAST2 $PALEODATA 
  endif
endif

foreach name ($plots)
  setenv SEASON $name 
  setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
  if ($CNTL == OBS) then
    setenv CNTL_INPUT $OBS_DATA
  else
    setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
    setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
  endif
  if (-e $TEST_PLOTVARS) then
    setenv NCDF_MODE write
  else
    setenv NCDF_MODE create
  endif   
  echo MAKING $SEASON PLOTS 
  $NCL < $DIAG_CODE/plot_surfaces_vecs.ncl
  if ($NCDF_MODE == create) then
    setenv NCDF_MODE write
  endif
end

if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set6 $image &
endif

endif

#****************************************************************
#   SET 7 - POLAR CONTOUR AND VECTOR PLOTS
#****************************************************************

if ($all_sets == 0 || $set_7 == 0) then
echo " "
echo SET 7 POLAR CONTOUR AND VECTOR PLOTS 

if ($paleo == 0) then
  echo ' '
  setenv MODELFILE ${test_path_climo}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv LANDMASK $land_mask1
  if (-e ${test_path_climo}/${test_casename}.lines && -e ${test_path_climo}/${test_casename}.names) then
    echo TEST CASE COASTLINE DATA FOUND
    setenv PALEODATA ${test_path_climo}/${test_casename}
  else
    echo CREATING TEST CASE PALEOCLIMATE COASTLINE FILES 
    setenv PALEODATA ${test_path_climo}/${test_casename}
  endif
  $NCL < $DIAG_CODE/plot_paleo.ncl
  setenv PALEOCOAST1 $PALEODATA
  if ($CNTL == USER) then
    echo ' '
    setenv MODELFILE ${cntl_path_climo}/${cntl_casename}_ANN_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
    setenv LANDMASK $land_mask2
    if (-e ${cntl_path_climo}/${cntl_casename}.lines && -e ${cntl_path_climo}/${cntl_casename}.names) then
      echo CNTL CASE COASTLINE DATA FOUND
      setenv PALEODATA $cntl_in
    else
      echo CREATING CNTL CASE PALEOCLIMATE COASTLINE FILES 
      setenv PALEODATA $cntl_out
    endif
    $NCL < $DIAG_CODE/plot_paleo.ncl
    setenv PALEOCOAST2 $PALEODATA 
  endif
endif

foreach name ($plots)
  setenv SEASON $name 
  setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
  if ($CNTL == OBS) then
    setenv CNTL_INPUT $OBS_DATA
  else
    setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
    setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
  endif
  if (-e $TEST_PLOTVARS) then
    setenv NCDF_MODE write
  else
    setenv NCDF_MODE create
  endif   
  if ($significance == 0) then
    setenv TEST_MEANS    ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_means.nc
    setenv TEST_VARIANCE ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_variance.nc
    setenv CNTL_MEANS    ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_means.nc
    setenv CNTL_VARIANCE ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_variance.nc
    if (-e $TEST_VARIANCE) then
      setenv VAR_MODE write
    else
      setenv VAR_MODE create
    endif   
  endif
  echo MAKING $SEASON PLOTS 
  $NCL < $DIAG_CODE/plot_polar_cons.ncl
  if ($NCDF_MODE == create) then
    setenv NCDF_MODE write
  endif
  if ($significance == 0) then 
    if($VAR_MODE == create) then
      setenv VAR_MODE write
    endif
  endif
  $NCL < $DIAG_CODE/plot_polar_vecs.ncl
  if ($NCDF_MODE == create) then
    setenv NCDF_MODE write
  endif
end

if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set7 $image &
endif

endif

#****************************************************************
#   SET 8 - ZONAL ANNUAL CYCLE PLOTS
#****************************************************************

if ($all_sets == 0 || $set_8 == 0) then
echo " "
echo SET 8 ANNUAL CYCLE PLOTS 
setenv TEST_INPUT ${test_path_climo}/${test_casename}    # path/casename
setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_MONTHS_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
if ($CNTL == OBS) then
  setenv CNTL_INPUT $OBS_DATA
else
  setenv CNTL_INPUT $cntl_in       # path/casename
  setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_MONTHS_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
  setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
endif
if (-e $TEST_PLOTVARS) then
  setenv NCDF_MODE write
else
  setenv NCDF_MODE create
endif
$NCL < $DIAG_CODE/plot_ann_cycle.ncl
if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set8 $image &
endif
endif
#****************************************************************
#  SET 9 - DJF-JJA LAT/LONG PLOTS
#****************************************************************
if ($all_sets == 0 || $set_9 == 0) then
echo ' '
echo SET 9 DJF-JJA CONTOUR PLOTS
if ($paleo == 0) then
  setenv MODELFILE ${test_path_climo}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv LANDMASK $land_mask1
  if (-e ${test_path_climo}/${test_casename}.lines && -e ${test_path_climo}/${test_casename}.names) then
    echo TEST CASE COASTLINE DATA FOUND
    setenv PALEODATA ${test_path_climo}/${test_casename}
  if ($CNTL == OBS) then
    setenv PALEOCOAST2 "null"
  endif
  else
    echo CREATING TEST CASE PALEOCLIMATE COASTLINE FILES 
    setenv PALEODATA ${test_path_climo}/${test_casename}
  endif
  $NCL < $DIAG_CODE/plot_paleo.ncl
  setenv PALEOCOAST1 $PALEODATA
  if ($CNTL == USER) then
    echo ' '
    setenv MODELFILE ${cntl_path_climo}/${cntl_casename}_ANN_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
    setenv LANDMASK $land_mask2
    if (-e ${cntl_path_climo}/${cntl_casename}.lines && -e ${cntl_path_climo}/${cntl_casename}.names) then
      echo CNTL CASE COASTLINE DATA FOUND
      setenv PALEODATA $cntl_in
    else
      echo CREATING CNTL CASE PALEOCLIMATE COASTLINE FILES 
      setenv PALEODATA $cntl_out 
    endif
    $NCL < $DIAG_CODE/plot_paleo.ncl
    setenv PALEOCOAST2 $PALEODATA 
  endif
endif

echo MAKING PLOTS
setenv TEST_INPUT    ${test_path_climo}/${test_casename}
setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}
setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
if ($CNTL == OBS) then
  setenv CNTL_INPUT $OBS_DATA
else
  setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}
  setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}
  setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
endif
if (-e ${test_path_diag}/${test_casename}_DJF_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc) then
  setenv NCDF_DJF_MODE write
else
  setenv NCDF_DJF_MODE create
endif   
if (-e ${test_path_diag}/${test_casename}_JJA_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc) then
  setenv NCDF_JJA_MODE write
else
  setenv NCDF_JJA_MODE create
endif   
$NCL < $DIAG_CODE/plot_seasonal_diff.ncl
if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set9 $image &
endif
endif
#***************************************************************
# SET 10 - Annual cycle line plots 
#***************************************************************
if ($all_sets == 0 || $set_10 == 0) then
echo " **** ${NCDF_MODE} ****"
echo " "
echo SET 10 ANNUAL CYCLE LINE PLOTS 
setenv TEST_INPUT    ${test_path_climo}/${test_casename}        # path/casename
setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}
setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
if ($CNTL == OBS) then
  setenv CNTL_INPUT $OBS_DATA        # path
else
  setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}
  setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}
  setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
endif
if (-e ${test_path_diag}/${test_casename}_01_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc) then
  setenv NCDF_MODE write
else
  setenv NCDF_MODE create
endif
echo " **** ${NCDF_MODE} ****"
$NCL < $DIAG_CODE/plot_seas_cycle.ncl
if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set10 $image &
endif
endif
#***************************************************************
# SET 11 - Miscellaneous plot types
#***************************************************************
if ($all_sets == 0 || $set_11 == 0) then
echo " "
if ($plot_ANN_climo == 0 && $plot_DJF_climo == 0 && $plot_JJA_climo == 0) then 
  echo SET 11 SWCF/LWCF SCATTER PLOTS 
  setenv TEST_INPUT    ${test_path_climo}/${test_casename}
  setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}
  setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
  if ($CNTL == OBS) then
    setenv CNTL_INPUT $OBS_DATA
  else
    setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}
    setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}
    setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
  endif
  if (-e ${test_path_diag}/${test_casename}_ANN_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc) then
    setenv NCDF_ANN_MODE write
  else
    setenv NCDF_ANN_MODE create
  endif
  if (-e ${test_path_diag}/${test_casename}_DJF_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc) then
    setenv NCDF_DJF_MODE write
  else
    setenv NCDF_DJF_MODE create
  endif
  if (-e ${test_path_diag}/${test_casename}_JJA_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc) then
    setenv NCDF_JJA_MODE write
  else
    setenv NCDF_JJA_MODE create
  endif
  $NCL < $DIAG_CODE/plot_swcflwcf.ncl
else
  echo "WARNING: plot_ANN_climo, plot_DJF_climo, and plot_JJA_climo"
  echo "must be turned on (=0) for SET 11 LWCF/SWCF scatter plots"
endif

echo " "
if ($plot_MON_climo == 0) then
  echo "SET 11 EQUATORIAL ANNUAL CYCLE"
  $NCL < $DIAG_CODE/plot_cycle_eq.ncl
else
  echo "WARNING: plot_MON_climo must be turned on (=0)"
  echo "for set 11 ANNUAL CYCLE plots"
endif

if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set11 $image &
endif
endif

#****************************************************************
# SET 12 - Vertical profiles
#***************************************************************
if ($all_sets == 0 || $set_12 == 0) then
echo ' '
echo SET 12 VERTICAL PROFILES
setenv TEST_CASE ${test_path_climo}/${test_casename}
setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
if ($CNTL == OBS) then     
  setenv STD_CASE NONE 
else
  setenv STD_CASE $cntl_in
  setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
endif

if (-e ${test_path_diag}/station_ids) then
 \rm ${test_path_diag}/station_ids
endif
if ($set_12 == 2) then    # all stations
  echo 56 >> ${test_path_diag}/station_ids
else
  if ($ascension_island == 0) then
    echo 0 >> ${test_path_diag}/station_ids
  endif
  if ($diego_garcia == 0) then
    echo 1 >> ${test_path_diag}/station_ids
  endif
  if ($truk_island == 0) then
    echo 2 >> ${test_path_diag}/station_ids
  endif
  if ($western_europe == 0) then
    echo 3 >> ${test_path_diag}/station_ids
  endif
  if ($ethiopia == 0) then
    echo 4 >> ${test_path_diag}/station_ids
  endif
  if ($resolute_canada == 0) then
    echo 5 >> ${test_path_diag}/station_ids
  endif
  if ($w_desert_australia == 0) then
    echo 6 >> ${test_path_diag}/station_ids
  endif
  if ($great_plains_usa == 0) then
    echo 7 >> ${test_path_diag}/station_ids
  endif
  if ($central_india == 0) then
    echo 8 >> ${test_path_diag}/station_ids
  endif
  if ($marshall_islands == 0) then
    echo 9 >> ${test_path_diag}/station_ids
  endif
  if ($easter_island == 0) then
    echo 10 >> ${test_path_diag}/station_ids
  endif
  if ($mcmurdo_antarctica == 0) then
    echo 11 >> ${test_path_diag}/station_ids
  endif
# skipped south pole antarctica - 12
  if ($panama == 0) then
    echo 13 >> ${test_path_diag}/station_ids
  endif
  if ($w_north_atlantic == 0) then
    echo 14 >> ${test_path_diag}/station_ids
  endif
  if ($singapore == 0) then
    echo 15 >> ${test_path_diag}/station_ids
  endif
  if ($manila == 0) then
    echo 16 >> ${test_path_diag}/station_ids
  endif
  if ($gilbert_islands == 0) then
    echo 17 >> ${test_path_diag}/station_ids
  endif
  if ($hawaii == 0) then
    echo 18 >> ${test_path_diag}/station_ids
  endif
  if ($san_paulo_brazil == 0) then
    echo 19 >> ${test_path_diag}/station_ids
  endif
  if ($heard_island == 0) then
    echo 20 >> ${test_path_diag}/station_ids
  endif
  if ($kagoshima_japan == 0) then
    echo 21 >> ${test_path_diag}/station_ids
  endif
  if ($port_moresby == 0) then
    echo 22 >> ${test_path_diag}/station_ids
  endif
  if ($san_juan_pr == 0) then
    echo 23 >> ${test_path_diag}/station_ids
  endif
  if ($western_alaska == 0) then
    echo 24 >> ${test_path_diag}/station_ids
  endif
  if ($thule_greenland == 0) then
    echo 25 >> ${test_path_diag}/station_ids
  endif
  if ($san_francisco_ca == 0) then
    echo 26 >> ${test_path_diag}/station_ids
  endif
  if ($denver_colorado == 0) then
    echo 27 >> ${test_path_diag}/station_ids
  endif
  if ($london_england == 0) then
    echo 28 >> ${test_path_diag}/station_ids
  endif
  if ($crete == 0) then
    echo 29 >> ${test_path_diag}/station_ids
  endif
  if ($tokyo_japan == 0) then
    echo 30 >> ${test_path_diag}/station_ids
  endif
  if ($sydney_australia == 0) then
    echo 31 >> ${test_path_diag}/station_ids
  endif
  if ($christchurch_nz == 0) then
    echo 32 >> ${test_path_diag}/station_ids
  endif
  if ($lima_peru == 0) then
    echo 33 >> ${test_path_diag}/station_ids
  endif
  if ($miami_florida == 0) then
    echo 34 >> ${test_path_diag}/station_ids
  endif
  if ($samoa == 0) then
    echo 35 >> ${test_path_diag}/station_ids
  endif
  if ($shipP_gulf_alaska == 0) then
    echo 36 >> ${test_path_diag}/station_ids
  endif
  if ($shipC_n_atlantic == 0) then
    echo 37 >> ${test_path_diag}/station_ids
  endif
  if ($azores == 0) then
    echo 38 >> ${test_path_diag}/station_ids
  endif
  if ($new_york_usa == 0) then
    echo 39 >> ${test_path_diag}/station_ids
  endif
  if ($darwin_australia == 0) then
    echo 40 >> ${test_path_diag}/station_ids
  endif
  if ($christmas_island == 0) then
    echo 41 >> ${test_path_diag}/station_ids
  endif
  if ($cocos_islands == 0) then
    echo 42 >> ${test_path_diag}/station_ids
  endif
  if ($midway_island == 0) then
    echo 43 >> ${test_path_diag}/station_ids
  endif
  if ($raoui_island == 0) then
    echo 44 >> ${test_path_diag}/station_ids
  endif
  if ($whitehorse_canada == 0) then
    echo 45 >> ${test_path_diag}/station_ids
  endif
  if ($oklahoma_city_ok == 0) then
    echo 46 >> ${test_path_diag}/station_ids
  endif
  if ($gibraltor == 0) then
    echo 47 >> ${test_path_diag}/station_ids
  endif
  if ($mexico_city == 0) then
    echo 48 >> ${test_path_diag}/station_ids
  endif
  if ($recife_brazil == 0) then
    echo 49 >> ${test_path_diag}/station_ids
  endif
  if ($nairobi_kenya == 0) then
    echo 50 >> ${test_path_diag}/station_ids
  endif
  if ($new_dehli_india == 0) then
    echo 51 >> ${test_path_diag}/station_ids
  endif
  if ($madras_india == 0) then
    echo 52 >> ${test_path_diag}/station_ids
  endif
  if ($danang_vietnam == 0) then
    echo 53 >> ${test_path_diag}/station_ids
  endif
  if ($yap_island == 0) then
    echo 54 >> ${test_path_diag}/station_ids
  endif
  if ($falkland_islands == 0) then
    echo 55 >> ${test_path_diag}/station_ids
  endif
endif
$NCL < $DIAG_CODE/profiles.ncl
\rm ${test_path_diag}/station_ids

if ($web_pages == 0) then
  $DIAG_CODE/ps2imgwww.csh set12 $image &
endif

endif

#*****************************************************************
# SET 13 - COSP Cloud Simulator Plots
#*****************************************************************
if ($all_sets == 0 || $set_13 == 0) then
echo " "
echo "SET 13 COSP CLOUD SIMULATOR PLOTS"
set set_13_flag  = `cat $test_path_diag/attributes/set_13_flag`
if ( $set_13_flag == 1 ) then
   echo " "
   echo "SKIPPING: REQUIRED VARIABLES NOT IN INPUT FILE"
else
  foreach name ($plots)   # do any or all of ANN,DJF,JJA
    setenv SEASON $name 
    setenv TEST_INPUT    ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
    setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
    if ($CNTL == OBS) then
      setenv CNTL_INPUT $OBS_DATA
      setenv CNTL_PLOTVARS $OBS_DATA
    else
      setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc
      setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
    endif
    if (-e $TEST_PLOTVARS) then
      setenv NCDF_MODE write
    else
      setenv NCDF_MODE create
    endif   
    $NCL < $DIAG_CODE/plot_matrix.ncl
    if ($NCDF_MODE == create) then
      setenv NCDF_MODE write
    endif
  end
  if ($web_pages == 0) then
    $DIAG_CODE/ps2imgwww.csh set13 $image &
  endif
endif
endif

#*****************************************************************
# SET 14 - Taylor Diagram Plots
#*****************************************************************

if ($all_sets == 0 || $set_14 == 0) then
setenv TEST_INPUT ${test_path_climo}/${test_casename}
setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
if ($CNTL != OBS) then 
    setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}
    setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
else
    setenv CNTL_INPUT $OBS_DATA
endif

if ($plot_MON_climo == 0) then
  echo ' '
  echo "SET 14 TAYLOR DIAGRAM PLOTS"
  echo ' '
  $NCL < $DIAG_CODE/plot_taylor.ncl
else
  echo "WARNING: plot_MON_climo must be turned on (=0)"
  echo "for set 14 TAYLOR DIAGRAM plots"
endif

if ($web_pages == 0) then
  $DIAG_HOME/code/ps2imgwww.csh set14 $image &
endif
endif

#*****************************************************************
# SET 15 - Annual Cycle Select Sites Plots
#*****************************************************************

if ($all_sets == 0 || $set_15 == 0) then

    setenv TEST_INPUT    ${test_path_climo}/${test_casename}
    setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${test_first_yr_prnt}-${test_last_yr_prnt}_plotvars.nc
    setenv TEST_YRS_PRNT ${test_first_yr_prnt}-${test_last_yr_prnt}
    if ($CNTL == OBS) then
        setenv CNTL_INPUT $OBS_DATA
    else
        setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}
        setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_plotvars.nc
        setenv CNTL_YRS_PRNT ${cntl_first_yr_prnt}-${cntl_last_yr_prnt}
    endif
    if (-e $TEST_PLOTVARS) then
        setenv NCDF_MODE write
    else
        setenv NCDF_MODE create
    endif   
    if ($plot_MON_climo == 0) then
        echo ' '
        echo "SET 15 ANNUAL CYCLE SELECT SITES PLOTS"
        echo ' '
        $NCL < $DIAG_CODE/plot_ac_select_sites.ncl
        else
        echo "WARNING: plot_MON_climo must be turned on (=0)"
        echo "for set 15 SELECT SITES plots"
    endif

    if ($web_pages == 0) then
        $DIAG_HOME/code/ps2imgwww.csh set15 $image &
    endif

endif

#*****************************************************************
# SET 16 - Budget Terms Select Sites Plots
#*****************************************************************
if ( $all_sets == 0 || $set_16 == 0 ) then
   echo " "
   echo "SKIPPING SET 16: STILL IN DEVELOPMENT"
   set set_16 = 1
   set all_sets = 1
endif
      
if ($all_sets == 0 || $set_16 == 0) then

    echo " "
    echo SET 16 BUDGET TERMS

    foreach name ($plots)
        setenv SEASON $name
        setenv TEST_INPUT    ${test_path_climo}/${test_casename}_${SEASON}_climo.nc  
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_plotvars.nc
        if ($CNTL == OBS) then
            setenv CNTL_INPUT $OBS_DATA 
        else
            setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}_${SEASON}_climo.nc    
            setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_plotvars.nc
        endif
        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif
        echo MAKING $SEASON PLOTS 
        $NCL < $DIAG_CODE/plot_budget_select_sites.ncl
        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
    end

    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh set16 $image &
    endif

endif

#*****************************************************************
# TIME SERIES SET 1 - GLOBAL AND ANNUAL MEAN TIME SERIES
#*****************************************************************
if ($tset_1 == 0) then

    echo " "
    echo "TSET 1 GLOBAL MEAN TIME SERIES PLOTS"
    foreach name ($plots)
        setenv SEASON     $name
        setenv CASE1      $test_casename
        setenv TEST_INPUT $timeseries_path/$test_casename
        setenv SYR1       ${BEGYRS[1]}
        setenv EYR1       ${ENDYRS[1]}

        if ($CNTL == USER) then
            setenv CASE2      $cntl_casename
            setenv CNTL_INPUT $timeseries_path/$cntl_casename
            setenv SYR2       ${BEGYRS[2]}
            setenv EYR2       ${ENDYRS[2]}
        endif

        echo " "
        echo " COMPUTING $SEASON MEAN ..."
        if ($time_series_obs == 0) then
           if ($SEASON == DJF || $SEASON == JJA || $SEASON == ANN) then
              $NCL < $DIAG_CODE/plot_time_series_vs_obs.ncl
              $NCL < $DIAG_CODE/plot_time_series_Rnet.ncl
           else
              $NCL < $DIAG_CODE/plot_time_series.ncl
           endif
        else
           $NCL < $DIAG_CODE/plot_time_series.ncl
        endif
    end
    
    if ($web_pages == 0) then
        $DIAG_HOME/code/ps2imgwww.csh tset1 $image &
    endif

endif


#*****************************************************************
# WACCM SET 1 - LAT/PRESS CONTOUR PLOTS (VERTICAL LOG SCALE)
#*****************************************************************
if ($all_waccm_sets == 0 || $wset_1 == 0) then

    setenv USE_WACCM_LEVS 1

    echo " "
    echo "WACCM SET 1 VERTICAL CONTOUR PLOTS (LOG SCALE)"

    if ($CNTL == OBS) then
      echo WACCM set 1 does not support comparison with OBS
      echo Skipping WACCM set 1
    else

    foreach name ($plots)
        setenv SEASON $name
        setenv TEST_INPUT    ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc  
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_waccm_plotvars.nc

        setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc    
        setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_waccm_plotvars.nc

        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif
        echo MAKING $SEASON PLOTS
        $NCL < $DIAG_CODE/plot_vertical_cons.ncl

        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
    end

    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh wset1 $image &
    endif

    endif # CNTL != OBS

    setenv USE_WACCM_LEVS 0

endif

wait
# Make links for climatologies without time stamp for csets
 foreach mth ( 01 02 03 04 05 06 07 08 09 10 11 12 DJF MAM JJA SON ANN )
    ln -sf $test_path_climo/${test_casename}_${mth}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc $test_path_climo/${test_casename}_${mth}_climo.nc
    if ($CNTL == USER) then
        ln -sf $cntl_path_climo/${cntl_casename}_${mth}_${cntl_first_yr_prnt}-${cntl_last_yr_prnt}_climo.nc $cntl_path_climo/${cntl_casename}_${mth}_climo.nc
    endif
end

#****************************************************************
#   CSET 1 - Chemistry TABLES OF Budgets 
#****************************************************************
if ($all_chem_sets == 0 || $cset_1 == 0) then

    echo " "
    echo CSET 1 TABLES OF MEANS, DIFFS, RMSES

    foreach name ($plots)
        setenv SEASON $name 
        setenv TEST_INPUT    ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
        setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_plotvars.nc
        if ($CNTL == OBS) then 
            setenv CNTL_INPUT $OBS_DATA
        else
            setenv CNTL_INPUT    ${cntl_path_climo}/${cntl_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
            setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_plotvars.nc
        endif
        if (-e $TEST_PLOTVARS) then
            setenv NCDF_MODE write
        else
            setenv NCDF_MODE create
        endif
        echo MAKING $SEASON CHEMISTRY TABLES 
        $NCL <  $DIAG_CODE/tables_chem.ncl
        echo MAKING $SEASON AEROSOL TABLES 
        $NCL <  $DIAG_CODE/tables_soa.ncl
        if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
        endif
    end
    if ($web_pages == 0) then
        mv *.asc $WEBDIR/cset1
    endif

endif
#*****************************************************************
# CSET 2 - LAT/PRESS CONTOUR PLOTS 
#*****************************************************************

if ($all_chem_sets == 0 || $cset_2 == 0) then
echo " "
echo CSET2 VERTICAL CONTOUR PLOTS

setenv USE_WACCM_LEVS 0
foreach name ($plots)
  setenv SEASON $name
  setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
  setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_plotvars.nc
  if ($CNTL == OBS) then
    setenv CNTL_INPUT $OBS_DATA
  else
    setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
    setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_plotvars.nc
  endif
  if (-e $TEST_PLOTVARS) then
    setenv NCDF_MODE write
  else
    setenv NCDF_MODE create
  endif
  echo MAKING $SEASON PLOTS
  if ($CNTL == OBS) then
    CSET2 does not support comparison with OBS
    Skipping CSET2 
   else
     $NCL < $DIAG_CODE/plot_vertical_zonal_mean_chem.ncl
     $NCL < $DIAG_CODE/plot_vertical_zonal_mean_chem_perc.ncl
    endif
   if ($NCDF_MODE == create) then
     setenv NCDF_MODE write
   endif
end
if ($web_pages == 0) then
    $DIAG_CODE/ps2imgwww.csh cset2 $image &
endif
setenv USE_WACCM_LEVS 0

endif

#*****************************************************************
#   CSET 3  Ozonesonde comparisions
#****************************************************************
if ($all_chem_sets == 0 || $cset_3 == 0) then

    echo CSET 3 Chemistry COMPARISON TO OZONESONDES

    foreach name ($plots)
       setenv TEST_CASE ${test_path_climo}/${test_casename}
       if ($CNTL == OBS) then
         setenv STD_CASE NONE
       else
        setenv STD_CASE $cntl_in
       endif
       setenv SEASON $name
       
       echo $SEASON
       echo $name 
       if ($name == "ANN") then
        $NCL < $DIAG_CODE/profiles_station_regions_comp.ncl
        $NCL < $DIAG_CODE/profiles_station_regions_comp_strat.ncl
       $NCL < $DIAG_CODE/seasonal_cycle_o3_regions_comp.ncl
       if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
       endif
       endif
    end
    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh cset3 $image &
    endif
endif

#*****************************************************************
#   CSET 4  Column O3/CO comparisions
#****************************************************************

if ($all_chem_sets == 0 || $cset_4 == 0) then

    echo CSET 4 Column O3 and CO COMPARISON

    foreach name ($plots)
       setenv TEST_CASE ${test_path_climo}/${test_casename}
       if ($CNTL == OBS) then
         setenv STD_CASE NONE
       else
        setenv STD_CASE $cntl_in
       endif
       setenv SEASON $name

       echo $SEASON
       echo Column O3 COMPARISON
       $NCL < $DIAG_CODE/plot_surface_mean_o3_col.ncl
       echo $name
       if ($name == "ANN") then
         echo Column O3 COMPARISON
         $NCL < $DIAG_CODE/plot_surface_mean_co_col.ncl
       endif
    end
    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh cset4 $image &
    endif
endif

#*****************************************************************
#   CSET 5  COMPARISON TO NOAA Aircraft
#****************************************************************

if ($all_chem_sets == 0 || $cset_5 == 0) then

    echo " "
     echo CSET 5 Chemistry COMPARISON TO NOAA Aircraft

    foreach name ($plots)
      setenv TEST_CASE ${test_path_climo}/${test_casename}
       if ($CNTL == OBS) then
         setenv STD_CASE NONE
       else
        setenv STD_CASE $cntl_in
       endif
       setenv SEASON $name
       if ($name == "ANN") then
        $NCL < $DIAG_CODE/profiles_aircraft_noaa.ncl
       endif
     end
     if ($web_pages == 0) then
       $DIAG_CODE/ps2imgwww.csh cset5 $image &
     endif
endif

#*****************************************************************
#   CSET 6  COMPARISON TO EMMONS Aircraft Climatology
#****************************************************************

if ($all_chem_sets == 0 || $cset_6 == 0) then

    echo " "
     echo CSET 6 Chemistry COMPARISON TO EMMONS Aircraft Climatology

    foreach name ($plots)
      setenv DATA_PLOTVARS ${test_path_diag}/data_aircraft_plotvars.nc
      setenv TEST_CASE ${test_path_climo}/${test_casename}
      setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_aircraft_plotvars.nc

       if ($CNTL == OBS) then
         setenv STD_CASE NONE
       else
        setenv STD_CASE $cntl_in
        setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_aircraft_plotvars.nc
       endif
       setenv SEASON $name
       if ($name == "ANN") then
        $NCL < $DIAG_CODE/profiles_aircraft_emmons.ncl
       if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
       endif
       endif
     end
     if ($web_pages == 0) then
       $DIAG_CODE/ps2imgwww.csh cset6 $image &
     endif
endif

#*****************************************************************
#   CSET 7  Surface comparison ozone, co, improve 
#***************************************************************
if ($all_chem_sets == 0 || $cset_7 == 0) then

    echo CSET 7 Surface comparison ozone, CO, IMPROVE

    foreach name ($plots)
       setenv SEASON $name
       setenv TEST_INPUT ${test_path_climo}/${test_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
       setenv TEST_PLOTVARS ${test_path_diag}/${test_casename}_${SEASON}_plotvars.nc
       if ($CNTL == OBS) then
         setenv CNTL_INPUT $OBS_DATA
       else
         setenv CNTL_INPUT ${cntl_path_climo}/${cntl_casename}_${SEASON}_${test_first_yr_prnt}-${test_last_yr_prnt}_climo.nc
         setenv CNTL_PLOTVARS ${test_path_diag}/${cntl_casename}_${SEASON}_plotvars.nc
       endif
       echo MAKING $SEASON PLOTS
       $NCL < $DIAG_CODE/plot_improve_scatter_pdf.ncl
       if ($NCDF_MODE == create) then
            setenv NCDF_MODE write
       endif
    end
    if ($web_pages == 0) then
        $DIAG_CODE/ps2imgwww.csh cset7 $image &
    endif
endif

# Remove links
foreach mth ( 01 02 03 04 05 06 07 08 09 10 11 12 DJF MAM JJA SON ANN )
    rm -f $test_path_climo/${test_casename}_${mth}_climo.nc
    rm -f $cntl_path_climo/${cntl_casename}_${mth}_climo.nc
end

#***************************************************************
# end of non-swift branch
#***************************************************************

else

#**************************************************************
#***************************************************************
# If using swift => beginning of use_swift branch
#***************************************************************
#**************************************************************
  set mydir = `pwd`

#***************************************************************
# Setup webpages and make tar file
if ($web_pages == 0) then
  setenv DENSITY $density
  if ($img_type == 0) then
    set image = png
  else
    if ($img_type == 1) then
      set image = gif
    else
      set image = jpg
    endif
  endif
  if ($p_type != ps) then
    echo ERROR: WEBPAGES ARE ONLY MADE FOR POSTSCRIPT PLOT TYPE
    exit 1
  endif
  if ($CNTL == OBS) then
    setenv WEBDIR ${test_path_diag}/$test_casename-obs
    if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
    if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
    cd $WEBDIR
    $HTML_HOME/setup_obs $test_casename $image
    cd $test_path_diag
    set tarfile = ${test_casename}-obs.tar
  else          # model-to-model 
    setenv WEBDIR ${test_path_diag}/$test_casename-$cntl_casename
    if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
    if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
    cd $WEBDIR
    $HTML_HOME/setup_2models $test_casename $cntl_casename $image yrs${test_first_yr}to${test_end} yrs${cntl_first_yr}to${cntl_end}
    cd $test_path_diag
    set tarfile = $test_casename-${cntl_casename}.tar
  endif
endif


  #---------------------------------------------------------------
  # Determine how to deal with the DJF season for the test dataset
  #---------------------------------------------------------------
  @ cnt = $test_first_yr
  @ cnt --
  set yearnum = ${test_rootname}`printf "%04d" ${cnt}`
  if ($test_filetype == "monthly_history") then
    if ( -e ${test_path_history}/${yearnum}-12.nc ) then    # dec of previous year
       set test_djf = SCD
    else
       set test_djf = SDD
    endif
    echo 'test_djf: ' $test_djf
  endif

 #--------------------------------------------------------------
 # Determine which plots need to be drawn
 #--------------------------------------------------------------
  echo 'four_seasons: ' $four_seasons
  echo 'plot_ANN_climo: ' $plot_ANN_climo
  echo 'plot_DJF_climo: ' $plot_DJF_climo
  echo 'plot_JJA_climo: ' $plot_JJA_climo
  echo 'plot_MAM_climo: ' $plot_MAM_climo
  echo 'plot_SON_climo: ' $plot_SON_climo
  if ($four_seasons == 0) then
        set plots = "ANN,DJF,MAM,JJA,SON"
  else
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 0 && \
         $plot_JJA_climo == 1 && \
         $plot_MAM_climo == 1 && \
         $plot_SON_climo == 1) then
         set plots = "ANN,DJF"
     endif
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 1 && \
         $plot_JJA_climo == 1 && \
         $plot_MAM_climo == 0 && \
         $plot_SON_climo == 1) then
         set plots = "ANN,MAM"
     endif
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 1 && \
         $plot_JJA_climo == 0 && \
         $plot_MAM_climo == 1 && \
         $plot_SON_climo == 1) then
         set plots = "ANN,JJA"
     endif
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 1 && \
         $plot_JJA_climo == 1 && \
         $plot_MAM_climo == 1 && \
         $plot_SON_climo == 0) then
         set plots = "ANN,SON"
     endif
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 0 && \
         $plot_JJA_climo == 0 && \
         $plot_MAM_climo == 1 && \
         $plot_SON_climo == 1) then
         set plots = "ANN,DJF,JJA"
     endif
     if ($plot_ANN_climo == 1 && \
         $plot_DJF_climo == 0 && \
         $plot_JJA_climo == 0 && \
         $plot_MAM_climo == 1 && \
         $plot_SON_climo == 1) then
         set plots = "DJF,JJA"
     endif
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 1 && \
         $plot_JJA_climo == 1 && \
         $plot_MAM_climo == 0 && \
         $plot_SON_climo == 0) then
         set plots = "ANN,MAM,SON"
     endif
     if ($plot_ANN_climo == 1 && \
         $plot_DJF_climo == 1 && \
         $plot_JJA_climo == 1 && \
         $plot_MAM_climo == 0 && \
         $plot_SON_climo == 0) then
         set plots = "MAM,SON"
     endif
     if ($plot_ANN_climo == 1 && \
         $plot_DJF_climo == 0 && \
         $plot_JJA_climo == 0 && \
         $plot_MAM_climo == 0 && \
         $plot_SON_climo == 0) then
         set plots = "DJF,MAM,JJA,SON"
     endif
     if ($plot_ANN_climo == 0 && \
         $plot_DJF_climo == 1 && \
         $plot_JJA_climo == 1 && \
         $plot_MAM_climo == 1 && \
         $plot_SON_climo == 1) then
         set plots = "ANN"
     endif
  endif
#****************************************************************
# For SET 12 - Create the station_ids file
#***************************************************************
if ($all_sets == 0 || $set_12 == 0 || $set_12 == 2) then
if (-e ${test_path_diag}/station_ids) then
 \rm ${test_path_diag}/station_ids
endif
if ($set_12 == 2) then    # all stations
  echo 56 >> ${WKDIR}/station_ids
else
  if ($ascension_island == 0) then
    echo 0 >> ${WKDIR}/station_ids
  endif
  if ($diego_garcia == 0) then
    echo 1 >> ${WKDIR}/station_ids
  endif
  if ($truk_island == 0) then
    echo 2 >> ${WKDIR}/station_ids
  endif
  if ($western_europe == 0) then
    echo 3 >> ${WKDIR}/station_ids
  endif
  if ($ethiopia == 0) then
    echo 4 >> ${WKDIR}/station_ids
  endif
  if ($resolute_canada == 0) then
    echo 5 >> ${WKDIR}/station_ids
  endif
  if ($w_desert_australia == 0) then
    echo 6 >> ${WKDIR}/station_ids
  endif
  if ($great_plains_usa == 0) then
    echo 7 >> ${WKDIR}/station_ids
  endif
  if ($central_india == 0) then
    echo 8 >> ${WKDIR}/station_ids
  endif
  if ($marshall_islands == 0) then
    echo 9 >> ${WKDIR}/station_ids
  endif
  if ($easter_island == 0) then
    echo 10 >> ${WKDIR}/station_ids
  endif
  if ($mcmurdo_antarctica == 0) then
    echo 11 >> ${WKDIR}/station_ids
  endif
# skipped south pole antarctica - 12
  if ($panama == 0) then
    echo 13 >> ${WKDIR}/station_ids
  endif
  if ($w_north_atlantic == 0) then
    echo 14 >> ${WKDIR}/station_ids
  endif
  if ($singapore == 0) then
    echo 15 >> ${WKDIR}/station_ids
  endif
  if ($manila == 0) then
    echo 16 >> ${WKDIR}/station_ids
  endif
  if ($gilbert_islands == 0) then
    echo 17 >> ${WKDIR}/station_ids
  endif
  if ($hawaii == 0) then
    echo 18 >> ${WKDIR}/station_ids
  endif
  if ($san_paulo_brazil == 0) then
    echo 19 >> ${WKDIR}/station_ids
  endif
  if ($heard_island == 0) then
    echo 20 >> ${WKDIR}/station_ids
  endif
  if ($kagoshima_japan == 0) then
    echo 21 >> ${WKDIR}/station_ids
  endif
  if ($port_moresby == 0) then
    echo 22 >> ${WKDIR}/station_ids
  endif
  if ($san_juan_pr == 0) then
    echo 23 >> ${WKDIR}/station_ids
  endif
  if ($western_alaska == 0) then
    echo 24 >> ${WKDIR}/station_ids
  endif
  if ($thule_greenland == 0) then
    echo 25 >> ${WKDIR}/station_ids
  endif
  if ($san_francisco_ca == 0) then
    echo 26 >> ${WKDIR}/station_ids
  endif
  if ($denver_colorado == 0) then
    echo 27 >> ${WKDIR}/station_ids
  endif
  if ($london_england == 0) then
    echo 28 >> ${WKDIR}/station_ids
  endif
  if ($crete == 0) then
    echo 29 >> ${WKDIR}/station_ids
  endif
  if ($tokyo_japan == 0) then
    echo 30 >> ${WKDIR}/station_ids
  endif
  if ($sydney_australia == 0) then
    echo 31 >> ${WKDIR}/station_ids
  endif
  if ($christchurch_nz == 0) then
    echo 32 >> ${WKDIR}/station_ids
  endif
  if ($lima_peru == 0) then
    echo 33 >> ${WKDIR}/station_ids
  endif
  if ($miami_florida == 0) then
    echo 34 >> ${WKDIR}/station_ids
  endif
  if ($samoa == 0) then
    echo 35 >> ${WKDIR}/station_ids
  endif
  if ($shipP_gulf_alaska == 0) then
    echo 36 >> ${WKDIR}/station_ids
  endif
  if ($shipC_n_atlantic == 0) then
    echo 37 >> ${WKDIR}/station_ids
  endif
  if ($azores == 0) then
    echo 38 >> ${WKDIR}/station_ids
  endif
  if ($new_york_usa == 0) then
    echo 39 >> ${WKDIR}/station_ids
  endif
  if ($darwin_australia == 0) then
    echo 40 >> ${WKDIR}/station_ids
  endif
  if ($christmas_island == 0) then
    echo 41 >> ${WKDIR}/station_ids
  endif
  if ($cocos_islands == 0) then
    echo 42 >> ${WKDIR}/station_ids
  endif
  if ($midway_island == 0) then
    echo 43 >> ${WKDIR}/station_ids
  endif
  if ($raoui_island == 0) then
    echo 44 >> ${WKDIR}/station_ids
  endif
  if ($whitehorse_canada == 0) then
    echo 45 >> ${WKDIR}/station_ids
  endif
  if ($oklahoma_city_ok == 0) then
    echo 46 >> ${WKDIR}/station_ids
  endif
  if ($gibraltor == 0) then
    echo 47 >> ${WKDIR}/station_ids
  endif
  if ($mexico_city == 0) then
    echo 48 >> ${WKDIR}/station_ids
  endif
  if ($recife_brazil == 0) then
    echo 49 >> ${WKDIR}/station_ids
  endif
  if ($nairobi_kenya == 0) then
    echo 50 >> ${WKDIR}/station_ids
  endif
  if ($new_dehli_india == 0) then
    echo 51 >> ${WKDIR}/station_ids
  endif
  if ($madras_india == 0) then
    echo 52 >> ${WKDIR}/station_ids
  endif
  if ($danang_vietnam == 0) then
    echo 53 >> ${WKDIR}/station_ids
  endif
  if ($yap_island == 0) then
    echo 54 >> ${WKDIR}/station_ids
  endif
  if ($falkland_islands == 0) then
    echo 55 >> ${WKDIR}/station_ids
  endif
endif
endif

#***************************************************************
# Setup webpages and make tar file
if ($web_pages == 0) then
  setenv DENSITY $density
  if ($img_type == 0) then
    set image = png
  else
    if ($img_type == 1) then
      set image = gif
    else
      set image = jpg
    endif
  endif
  if ($p_type != ps) then
    echo ERROR: WEBPAGES ARE ONLY MADE FOR POSTSCRIPT PLOT TYPE
    exit 1
  endif
  if ($CNTL == OBS) then
    setenv WEBDIR ${WKDIR}/$test_casename-obs
    if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
    if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
    cd $WEBDIR
    $HTML_HOME/setup_obs $test_casename $image
    cd $WKDIR
    set tarfile = ${test_casename}-obs.tar
  else          # model-to-model 
    setenv WEBDIR ${WKDIR}/$test_casename-$cntl_casename
    if (! -e $WEBDIR) mkdir -m 775 $WEBDIR
    if (-e $WEBDIR && `stat -c %a $WEBDIR` != 775 ) chmod 775 $WEBDIR
    cd $WEBDIR
    $HTML_HOME/setup_2models $test_casename $cntl_casename $image  yrs${test_first_yr}to${test_end} yrs${cntl_first_yr}to${cntl_end}
    cd $WKDIR
    set tarfile = $test_casename-${cntl_casename}.tar
  endif
endif

#---------------------------------------------------------
# Set dummy variables
#---------------------------------------------------------
set weight_months = 0
set non_time_vars = " "   
set test_non_time_var_list = " "
set cntl_non_time_var_list = " "

#---------------------------------------------------------
# Set RGB_FILE to null if c_type == MONO 
#---------------------------------------------------------
if ($c_type != COLOR) then
   setenv RGB_FILE " "
endif

# Set this to 0; WACCM sets can turn it on.
setenv USE_WACCM_LEVS 0

#---------------------------------------------------------
# Create yearly files that map where each month is located
#---------------------------------------------------------

if ($test_filetype == time_series) then
if ($test_compute_climo == 0 ) then
@ yr_end = $test_first_yr + $test_nyrs
@ yr_cnt = $test_first_yr - 1
  while ($yr_cnt <= $yr_end)
    set year_slice_file = ${test_path_climo}/${yr_cnt}_slice.txt
    $DIAG_CODE/find_time_series_year.pl ${test_path_climo}/test_file_list.txt \
                                        $yr_cnt \
                                        $test_path_climo \
                                        "null" \
                                        $year_slice_file
    @ yr_cnt = $yr_cnt + 1
  end
endif
endif

if ($cntl_filetype == time_series) then
if ($cntl_compute_climo == 0 ) then
@ yr_end = $cntl_first_yr + $cntl_nyrs
@ yr_cnt = $cntl_first_yr - 1
  while ($yr_cnt <= $yr_end)
    set year_slice_file = ${cntl_path_climo}/${yr_cnt}_slice.txt
    $DIAG_CODE/find_time_series_year.pl ${cntl_path_climo}/cntl_file_list.txt \
                                        $yr_cnt \
                                        $cntl_path_climo \
                                        "null" \
                                       $year_slice_file
   @ yr_cnt = $yr_cnt + 1
  end
endif
endif

cd $mydir

  if($CNTL != "OBS" ) then
     #---------------------------------------------------------------
     # Determine how to deal with the DJF season for the cntl dataset
     #---------------------------------------------------------------
     @ cnt = $cntl_first_yr
     @ cnt --
     set yearnum = ${cntl_rootname}`printf "%04d" ${cnt}`
     # echo ${cntl_path}${yearnum}-12.nc
     if ($cntl_filetype == "monthly_history") then
       if ( -e ${cntl_path_history}/${yearnum}-12.nc ) then    # dec of previous year
          set cntl_djf = SCD
       else
          set cntl_djf = SDD
       endif
       echo 'cntl_djf: ' $cntl_djf
     endif

     #------------------------------------------
     # Comparsion between two different datasets
     #------------------------------------------

      echo PLOTS: $plots

       cd $swift_scratch_dir

      swift -config $mydir/cf.properties \
      -sites.file $mydir/sites.xml  -tc.file $mydir/tc.data -cdm.file $mydir/fs.data \
      $mydir/swift/amwg_stats.swift -workdir=$test_path_diag -sig=$significance -test_inst=$test_inst -cntl_inst=$cntl_inst \
      -test_case=${test_casename} -test_djf=$test_djf -test_path=$test_path_history -test_nyrs=$test_nyrs -test_begin=$test_first_yr \
      -test_compute_climo=$test_compute_climo -cntl_compute_climo=$cntl_compute_climo \
      -test_path_climo=$test_path_climo -cntl_path_climo=$cntl_path_climo \
      -cntl_case=${cntl_casename} -cntl_djf=$cntl_djf -cntl_path=$cntl_path_history -cntl_nyrs=$cntl_nyrs -cntl_begin=$cntl_first_yr \
      -plot_ANN_climo=$plot_ANN_climo -plot_DJF_climo=$plot_DJF_climo \
      -plot_JJA_climo=$plot_JJA_climo -plot_MON_climo=$plot_MON_climo -plot_MAM_climo=$plot_MAM_climo -plot_SON_climo=$plot_SON_climo \
      -all_sets=$all_sets -set_1=$set_1 -set_2=$set_2 -set_3=$set_3 -set_4=$set_4 -set_4a=$set_4a -set_5=$set_5 -set_6=$set_6 \
      -set_7=$set_7 -set_8=$set_8 -set_9=$set_9 -set_10=$set_10 -set_11=$set_11 -set_12=$set_12 -set_13=$set_13 -set_14=$set_14 \
      -set_15=$set_15 -set_16=$set_16 -cntl=$CNTL -obs_data=$OBS_DATA -custom_names=$custom_names -casenames=$CASENAMES -case1=$CASE1 -case2=$CASE2 \
      -diag_code=$DIAG_CODE  -plots=$plots -plot_type=$PLOTTYPE -version=$DIAG_VERSION -color_type=$COLORTYPE -time_stamp=$TIMESTAMP \
      -web_pages=$web_pages -imageType=$image -webdir=$WEBDIR -rgb_file=$RGB_FILE -mg_micro=$MG_MICRO -paleo=$PALEO -land_mask1=$land_mask1 \
      -land_mask2=$land_mask2 -tick_marks=$TICKMARKS -sig_plot=$SIG_PLOT -sig_lvl=$SIG_LVL -diffs=$DIFF_PLOTS -significance=$significance \
      -diaghome=$DIAG_HOME -cam_data=$CAM_DATA -cam_base=$TAYLOR_BASECASE -ncarg_root=$NCARG_ROOT -strip_off_vars=$strip_off_vars \
      -test_var_list=$test_var_list -cntl_var_list=$cntl_var_list -test_non_time_var_list=$test_non_time_var_list \
      -cntl_non_time_var_list=$cntl_non_time_var_list  -weight_months=$weight_months \
      -save_ncdfs=$save_ncdfs -delete_ps=$DELETEPS -conv_test=$test_rootname -conv_cntl=$cntl_rootname -test_res_in=$test_res_in \
      -test_res_out=$test_res_out -cntl_res_in=$cntl_res_in -cntl_res_out=$cntl_res_out -map_dir=$MAP_DATA -interp_method=$INTERP_METHOD \
      -test_grid=$test_grid -cntl_grid=$cntl_grid -test_filetype=$test_filetype -cntl_filetype=$cntl_filetype -use_waccm_levs=$USE_WACCM_LEVS 

      set cntl_in = $cntl_out

      cd $mydir
   else

     echo 'Comparison against observations'
     #---------------------------------
     # Comparsion against observations
     #---------------------------------

       cd $swift_scratch_dir 

       swift -config $mydir/cf.properties \
      -sites.file $mydir/sites.xml  -tc.file $mydir/tc.data -cdm.file $mydir/fs.data \
      $mydir/swift/amwg_stats.swift -workdir=$test_path_diag -sig=$significance -test_inst=$test_inst \
      -test_case=${test_casename} -test_djf=$test_djf -test_path=$test_path_history -test_nyrs=$test_nyrs -test_begin=$test_first_yr \
      -test_path_climo=$test_path_climo -plot_ANN_climo=$plot_ANN_climo \
      -test_compute_climo=$test_compute_climo -cntl_compute_climo=$cntl_compute_climo -plot_DJF_climo=$plot_DJF_climo \
      -plot_JJA_climo=$plot_JJA_climo -plot_MON_climo=$plot_MON_climo -plot_MAM_climo=$plot_MAM_climo -plot_SON_climo=$plot_SON_climo \
      -all_sets=$all_sets -set_1=$set_1 -set_2=$set_2 -set_3=$set_3 -set_4=$set_4 -set_4a=$set_4a -set_5=$set_5 -set_6=$set_6 \
      -set_7=$set_7 -set_8=$set_8 -set_9=$set_9 -set_10=$set_10 -set_11=$set_11 -set_12=$set_12 -set_13=$set_13 -set_14=$set_14 \
      -set_15=$set_15 -set_16=$set_16 -cntl=$CNTL -obs_data=$OBS_DATA -custom_names=$custom_names -casenames=$CASENAMES -case1=$CASE1 -case2=$CASE2 \
      -diag_code=$DIAG_CODE -plots=$plots -plots=$plots -plot_type=$PLOTTYPE -version=$DIAG_VERSION -color_type=$COLORTYPE -time_stamp=$TIMESTAMP \
      -web_pages=$web_pages -imageType=$image -webdir=$WEBDIR -rgb_file=$RGB_FILE -mg_micro=$MG_MICRO -paleo=$PALEO -land_mask1=$land_mask1 \
      -land_mask2=$land_mask2 -tick_marks=$TICKMARKS -sig_plot=$SIG_PLOT -sig_lvl=$SIG_LVL -diffs=$DIFF_PLOTS -significance=$significance \
      -diaghome=$DIAG_HOME -cam_data=$CAM_DATA -cam_base=$TAYLOR_BASECASE -ncarg_root=$NCARG_ROOT -strip_off_vars=$strip_off_vars \
      -test_var_list=$test_var_list -cntl_var_list=$cntl_var_list -test_non_time_var_list=$test_non_time_var_list -weight_months=$weight_months \
      -save_ncdfs=$save_ncdfs -delete_ps=$DELETEPS -conv_test=$test_rootname -conv_cntl=$cntl_rootname -test_res_in=$test_res_in \
      -test_res_out=$test_res_out -cntl_res_in=$cntl_res_in -cntl_res_out=$cntl_res_out -map_dir=$MAP_DATA -interp_method=$INTERP_METHOD \
      -test_grid=$test_grid -cntl_grid=$cntl_grid -cntl_non_time_var_list=$cntl_non_time_var_list -cntl_non_time_var_list=$cntl_non_time_var_list \
      -test_filetype=$test_filetype -cntl_filetype=$cntl_filetype -use_waccm_levs=$USE_WACCM_LEVS 

      cd $mydir

   endif

   set test_in = $test_out

   rm -rf _concurrent
   rm -f $test_path_diag/*.tar
   rm -f $test_path_climo/dummy*
   rm -f ${test_path_climo}/*_slice.txt
   rm -f ${cntl_path_climo}/*_slice.txt

   if ($set_1 == 0) then
      if ($web_pages == 0) then
       mv *.asc $WEBDIR/set1
   endif
endif

endif # end of !use_swift  branch

#***************************************************************
# end of swift branch
#***************************************************************

EXIT:
wait          # wait for all child precesses to finish
echo ' '
# make tarfile of web pages
if ($web_pages == 0) then
  cd $WKDIR
  set tardir = $tarfile:r
  echo MAKING TAR FILE OF DIRECTORY $tardir
  tar -cf ${test_path_diag}/$tarfile $tardir
  \rm -fr $WEBDIR
endif
# send email message
if ($email == 0) then
  echo `date` > email_msg
  echo MESSAGE FROM THE AMWG DIAGNOSTIC PACKAGE. >> email_msg
  echo THE PLOTS FOR $tardir ARE NOW READY! >> email_msg
  mail -s 'DIAG plots' $email_address < email_msg
  echo E-MAIL SENT
  \rm -f email_msg
endif  
# Publish html data (JL Sep 2017)
if ($web_pages == 0 && $publish_html == 0) then
   set web_server_path = /projects/NS2345K/www
   if ( "$publish_html_root" == "" ) then
      set publish_html_root = ${web_server_path}/noresm
   endif
   set publish_html_path = $publish_html_root/$test_casename/CAM_DIAG
   if (! -e ${publish_html_path}) then
      mkdir -m 775 -p ${publish_html_path}
      if (! -e ${publish_html_path}) then
         echo ERROR: Unable to create \$publish_html_path : ${publish_html_path}
         exit 1
      endif
   endif
   if (-e ${publish_html_path} && `stat -c %a ${publish_html_path}` != 775 ) then
      chmod 775 ${publish_html_path}
   endif
   set web_server      = http://ns2345k.web.sigma2.no
   set path_pref       = `echo ${publish_html_path} | cut -c -21`
   set path_suff       = `echo ${publish_html_path} | cut -c 23-`
   echo ' '
   tar -xf ${test_path_diag}/$tarfile -C ${publish_html_path}
   if ( $status == 0 ) then
      if ( $path_pref == $web_server_path) then
         set full_url = ${web_server}/${path_suff}/${tardir}/sets.htm
         echo "URL:"
         echo "***********************************************************************************"
         echo "${full_url}"
         echo "***********************************************************************************"
         echo "COPY AND PASTE THE URL INTO THE ADDRESS BAR OF YOUR WEB BROWSER TO VIEW THE RESULTS"
         $HTML_HOME/redirect_html.csh $tardir $publish_html_path ${tardir}/sets.htm
      else
         echo "THE HTML FILES ARE LOCATED IN:"
         echo "${publish_html_path}/${tardir}"
         echo "(NOT ON THE NIRD WEB SERVER)"
      endif
   endif
endif
# cleanup
if ($save_ncdfs == 1) then
  if ($climo_required == 0) then
    echo ' '
    echo CLEANING UP
    \rm -f ${test_path_diag}/${test_casename}*_plotvars.nc
    if ($CNTL != OBS) then
      \rm -f ${test_path_diag}/${cntl_casename}*_plotvars.nc  
    endif
    if ($significance == 0) then
      \rm -f ${test_path_diag}/${test_casename}*_variance.nc
      if ($CNTL == USER) then
        \rm -f ${test_path_diag}/${cntl_casename}*_variance.nc     
      endif
   endif
endif
# Calculate the runtime (JL Sep 2017)
set time_end_script  = `date +%s`
set runtime_s        = `expr ${time_end_script} - ${time_start_script}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo ' '
echo "NORMAL EXIT FROM SCRIPT"
echo "TOTAL RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
if ( $test_compute_climo == 0 || $cntl_compute_climo == 0 ) then
   set runtime_s       = `expr ${time_end_climo} - ${time_start_climo}`
   set runtime_climo_m = `expr ${runtime_s} / 60`
   set min_in_secs     = `expr ${runtime_climo_m} \* 60`
   set runtime_climo_s = `expr ${runtime_s} - ${min_in_secs}`
   echo "--CLIMO COMPUTATION: ${runtime_climo_m}m${runtime_climo_s}s"
   echo "  (test_compute_climo=${test_compute_climo}, cntl_compute_climo=${cntl_compute_climo}, significance=${significance})"
endif
date
#***************************************************************
#***************************************************************
# Known Bugs
# 29mar10 ------ nanr - Should season plots missing
#    /set5_6/set5_[MAM,SON]_PRECIP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_ALBSURF_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_PS_c.png                        ! Plot not created
#    /set5_6/set5_[MAM,SON]_TTRP_TROP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_ALBEDO_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_ALBEDOC_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_TICLDIWP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_TICLDLIQWP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_TICLDLWP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_MEANPTOP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_MEANTTOP_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_MEANTAU_c.png                ! Plot not created
#    /set5_6/set5_[MAM,SON]_TCLDAREA_c.png                ! Plot not created
#***************************************************************
