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


if ($#argv != 10) then
  echo "Usage: determine_output_attributes.csh: needs 10 arguments "
  exit
endif

set casetype = $1  # test or control
set casename = $2
set path_HPSS = $3
set path_history  = $4
set path_climo = $5
set path_diag  = $6
@ first_year = $7
set compute_climo = $8
set file_type = $9
set ts_filename = $10

##
## Pick a file for which we will do check
##
set rootname = ' ' 
if ( $compute_climo == 0) then
  if ($file_type == monthly_history) then
    set rootname     = ${casename}.cam.h0.    # new terminology
    set filename     = ${rootname}`printf "%04d" ${first_year}`-01.nc
    set filename_tar = ${rootname}`printf "%04d" ${first_year}`.tar   
    set fullpath_filename  = ${path_history}/${filename} 
  else
    set rootname     = ${casename}.cam2.h0.    # new terminology
    set filename     = $ts_filename 
    set fullpath_filename  = ${filename}
    set filename_tar = ${rootname}`printf "%04d" ${first_year}`.tar
  endif
else    
    set filename           = ${casename}_01_climo.nc
    set fullpath_filename  = ${path_climo}/${filename} 
endif

##
## Check file is present locally - otherwise try to get it from HPSS   
##

if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
    hsi -q ls ${path_HPSS}/${filename}     # Check whether history files are stored by month or year
    if(${status} == 0) then
        echo 'GETTING '${path_HPSS}/${filename}''     
        hsi "get '${path_history}/${filename}': '${path_HPSS}/${filename}'"
    else 
        hsi -q ls ${path_HPSS}/${filename_tar}    
        if(${status} == 0) then
            echo 'GETTING '${path_HPSS}/${filename_tar}
            hsi "get '${path_history}/${filename_tar}': '${path_HPSS}/${filename_tar}'"
            tar -xvf ${path_history}/${filename_tar} -C ${path_history} 
            rm -f ${path_history}/${filename_tar}
        endif     
    endif

endif

##
## If we didn't find any file with the filename, we assume it is an old file name
##

if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
   
    set rootname     = ${casename}.cam2.h0.    # old terminology
    set filename     = ${rootname}`printf "%04d" ${first_year}`-01.nc
    set filename_tar = ${rootname}`printf "%04d" ${first_year}`.tar   
    set fullpath_filename  = ${path_history}/${filename} 
   
    if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
        hsi -q ls ${path_HPSS}/${filename}     # Check whether history files are stored by month or year
        if(${status} == 0) then
            echo 'GETTING '${path_HPSS}/${filename}''     
            hsi "get '${path_history}/${filename}': '${path_HPSS}/${filename}'"
        else 
            hsi -q ls ${path_HPSS}/${filename_tar}    
            if(${status} == 0) then            
                echo 'GETTING '${path_HPSS}/${filename_tar}
                hsi "get '${path_history}/${filename_tar}': '${path_HPSS}/${filename_tar}'"
                tar -xvf ${path_history}/${filename_tar} -C ${path_history} 
                rm -f ${path_history}/${filename_tar}
            endif
        endif
    endif

endif

##
## If we cannot still find any file with the filename, there is a problem
##

echo "ATTEMPT TO LOCATE FILE TO DETERMINE HISTORY ATTRIBUTES "  
if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
      echo 'ERROR: cannot find a file with the required file name' 
      echo 'Check in the script:  determine_output_attributes.csh '
      exit
else
     echo 'FOUND '${fullpath_filename}
     echo 'FILE IS USED TO DETERMINE HISTORY FILES ATTRIBUTES'
endif


## ========================================================
## Get all attributes
## ========================================================

##
## Make a directory that contains the attributes 
##
if (! -e ${path_diag}/attributes) then
    mkdir ${path_diag}/attributes
endif


##
## Rootname
##
echo ${rootname} >  ${path_diag}/attributes/${casetype}_rootname

##
## Determine case grid
##
ncks  -q -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v gw $fullpath_filename  >&! /dev/null 
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
   ncl  $DIAG_CODE/get_res_se.ncl 'dataFile=addfile("'${fullpath_filename}'", "r")'  'resFile="'${path_diag}/attributes/${casetype}_res'"'  
else 
   echo ' ' > ${path_diag}/attributes/${casetype}_res 

endif


##
## Determine which variables are present
##


# List of variables that are time-independant
if ($cam_grid != SE) then 
       set non_time_var_list = (gw,hyam,hybm,hyai,hybi,P0,lev,ilev,lat,lon,P0)
else
       set non_time_var_list = (area,hyam,hybm,hyai,hybi,P0,lev,ilev,lat,lon,P0) 
endif
echo  ${non_time_var_list}  > ${path_diag}/attributes/${casetype}_non_time_var_list

# List of variables that are time-dependant
# set of required variables for AMWG package
set required_vars = (AODVIS AODDUST AODDUST1 AODDUST2 AODDUST3 \
                     ANRAIN ANSNOW AQRAIN AQSNOW AREI AREL AWNC AWNI \
                     CCN3 CDNUMC CLDHGH CLDICE CLDLIQ CLDMED CLDLOW CLDTOT   \
                     CLOUD DCQ DTCOND DTV FICE FLDS FLNS FLNSC FLNT FLNTC    \
                     FLUT FLUTC FREQI FREQL FREQR FREQS FSDS FSDSC FSNS FSNSC \
                     FSNTC FSNTOA FSNTOAC FSNT ICEFRAC ICIMR ICWMR IWC LANDFRAC \
                     LHFLX LWCF NUMICE NUMLIQ OCNFRAC OMEGA OMEGAT P0 PBLH PRECC \
                     PRECL PRECSC PRECSL PS PSL Q QFLX QRL QRS RELHUM SHFLX   \
                     SNOWHICE SNOWHLND SOLIN SWCF T TAUX TAUY TGCLDIWP \
                     TGCLDLWP TMQ TREFHT TS U UU V VD01 VQ VT VU VV WSUB Z3 \
                     CLD_MISR FMISR1 \
                     FISCCP1_COSP FISCCP1 CLDTOT_ISCCP \
                     MEANPTOP_ISCCP MEANCLDALB_ISCCP \
                     CLMODIS FMODIS1 \
                     CLTMODIS CLLMODIS CLMMODIS CLHMODIS CLWMODIS CLIMODIS \
                     IWPMODIS LWPMODIS REFFCLIMODIS REFFCLWMODIS \
                     TAUILOGMODIS TAUWLOGMODIS TAUTLOGMODIS \
                     TAUIMODIS TAUWMODIS TAUTMODIS PCTMODIS \
                     CFAD_DBZE94_CS CFAD_SR532_CAL \
                     CLDTOT_CAL CLDLOW_CAL CLDMED_CAL CLDHGH_CAL CLDTOT_CS2 U10)

set first_find = 1
set var_list = " "
foreach var ($required_vars)
        if ($cam_grid != SE) then 
            ncks --quiet  -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename  >&! /dev/null 
            set var_present = $status
        else  
            ncks --quiet   -d ncol,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename >&! /dev/null 
            set var_present = $status
        endif
        if ($var_present == 0) then
            if ($first_find) then
                set var_list = $var
                set first_find=0
            else
                set var_list = ${var_list},$var
            endif
        endif
end

echo  ${var_list}  > ${path_diag}/attributes/${casetype}_var_list
echo  ${required_vars}  > ${path_diag}/attributes/required_vars 
