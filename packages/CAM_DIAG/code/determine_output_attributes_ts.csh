#!/bin/csh -f

unset echo verbose

#*****************************************************************
# Get the file from the MSS if they don't exist locally
#*****************************************************************

# This file reads in files from HPSS
# $path_HPSS      The HPSS location for history files
# $path_history     The local directory for  history files
# $path_diag       The local directory for diag files
# $first_year     The first year of data
# $nyrs           The number of years of data 
# $casename      The casename  
# $compute_climo   # compute_climo is (0=ON,1=OFF) 


if ($#argv != 5) then
  echo "Usage: determine_output_attributes_ts.csh: needs 5 arguments "
  exit 1
endif

set casetype = $1  # test or control
set casename = $2
set path_history  = $3
set path_diag  = $4
@ first_year = $5

##
## Make a directory that contains the attributes 
##
if (! -e ${path_diag}/attributes) then
    mkdir ${path_diag}/attributes
endif

##
## Pick a file for which we will do check
##
set rootname = ' '
set modelname    = cam
set rootname     = ${casename}.${modelname}.h0.    # new terminology
set filename     = ${rootname}`printf "%04d" ${first_year}`-01.nc
set filename_tar = ${rootname}`printf "%04d" ${first_year}`.tar   
set fullpath_filename  = ${path_history}/${casename}/atm/hist/${filename}
echo ${modelname} > ${path_diag}/attributes/${casetype}_modelname
##  If file does not exist check, the old terminology
if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
    set modelname    = cam2
    set rootname     = ${casename}.${modelname}.h0.    # old terminology
    set filename     = ${rootname}`printf "%04d" ${first_year}`-01.nc
    set filename_tar = ${rootname}`printf "%04d" ${first_year}`.tar   
    set fullpath_filename  = ${path_history}/${casename}/atm/hist/${filename}
    echo $fullpath_filename
    echo ${modelname} > ${path_diag}/attributes/${casetype}_modelname
endif

echo "ATTEMPT TO LOCATE FILE TO DETERMINE HISTORY ATTRIBUTES "  
if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
      echo 'ERROR: cannot find a file with the required file name' 
      echo 'Check in the script:  determine_output_attributes.csh '
      exit 1
else
     echo 'FOUND '${fullpath_filename}
     echo 'FILE IS USED TO DETERMINE HISTORY FILES ATTRIBUTES'
endif


## ========================================================
## Get all attributes
## ========================================================

##
## Rootname
##
echo ${rootname} >  ${path_diag}/attributes/${casetype}_rootname

##
## Determine case grid
##
/usr/local/bin/ncks  -q -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v gw $fullpath_filename  >&! /dev/null 
set var_present = $status

if ($var_present == 0) then
    set cam_grid = 'Lat/Lon'
else
    set cam_grid = 'SE'
endif

echo ${cam_grid} >  ${path_diag}/attributes/${casetype}_grid

##
## Determine case resolution
##
if ($cam_grid == SE) then
   $NCARG_ROOT/bin/ncl $DIAG_CODE/get_res_se.ncl 'dataFile=addfile("'${fullpath_filename}'", "r")'  'resFile="'${path_diag}/attributes/${casetype}_res'"'  
else 
   echo ' ' > ${path_diag}/attributes/${casetype}_res 

endif
