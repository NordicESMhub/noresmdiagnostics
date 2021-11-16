#!/bin/csh -f

#set echo verbose

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


if ($#argv != 11) then
  echo "Usage: determine_output_attributes.csh: needs 11 arguments "
  exit 1
endif

set casetype = $1  # test or control
set casename = $2
set path_history  = $3
set path_climo = $4
set path_diag  = $5
@ first_year = $6
set compute_climo = $7
set file_type = $8
set ts_filename = $9
set climo_req = $10
@ last_year = $11

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
set fullpath_filename  = ${path_history}/${filename} 
echo ${modelname} > ${path_diag}/attributes/${casetype}_modelname
##  If file does not exist check, the old terminology
if (! -e ${fullpath_filename} || -z ${fullpath_filename} ) then
    set modelname    = cam2
    set rootname     = ${casename}.${modelname}.h0.    # old terminology
    set filename     = ${rootname}`printf "%04d" ${first_year}`-01.nc
    set filename_tar = ${rootname}`printf "%04d" ${first_year}`.tar   
    set fullpath_filename  = ${path_history}/${filename}
    echo ${modelname} > ${path_diag}/attributes/${casetype}_modelname
endif

if ($compute_climo == 1 && $climo_req == 0) then
   set first_yr_prnt = `printf "%04d" ${first_year}`
   set last_yr_prnt  = `printf "%04d" ${last_year}`
   set filename           = ${casename}_01_${first_yr_prnt}-${last_yr_prnt}_climo.nc
   set fullpath_filename  = ${path_climo}/${filename} 
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
$nco_dir/ncks  -q -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v gw $fullpath_filename  >&! /dev/null 
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


##
## Determine which variables are present
##

# List of variables that are time-dependant
# set of required variables for AMWG package
set required_vars = (AODVIS AODDUST AODDUST1 AODDUST2 AODDUST3 \
                     ANRAIN ANSNOW AQRAIN AQSNOW AREI AREL AWNC AWNI \
                     CCN3 CDNUMC CLDHGH CLDICE CLDLIQ CLDMED CLDLOW CLDTOT   \
                     CLOUD DCQ DTCOND DTV FICE FLDS FLNS FLNSC FLNT FLNTC    \
                     FLUT FLUTC FREQI FREQL FREQR FREQS FSDS FSDSC FSNS FSNSC \
                     FSNTC FSNTOA FSNTOAC FSNT ICEFRAC ICIMR ICWMR IWC LANDFRAC \
                     LHFLX LWCF NUMICE NUMLIQ OCNFRAC OMEGA OMEGAT P0 PBLH PRECC \
                     PRECL PRECT PRECSC PRECSL PS PSL Q QFLX QRL QRS RELHUM SHFLX   \
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
                     CFAD_DBZE94_CS CFAD_SR532_CAL CLISCCP CLMISR \
                     CLDTOT_CAL CLDLOW_CAL CLDMED_CAL CLDHGH_CAL CLDTOT_CS2 U10 \
                     O3 SO2\
                     gw)

set first_find = 1
set var_list = " "
set var_in_file="`${cdo_dir}/cdo -s showname $fullpath_filename`"
foreach var ($required_vars)
        if ($cam_grid != SE) then 
            #$nco_dir/ncks --quiet  -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename  >&! /dev/null 
            echo ${var_in_file} |grep -w $var >/dev/null
            set var_present = $status
        else  
            #$nco_dir/ncks --quiet  -d ncol,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename >&! /dev/null 
            echo ${var_in_file} |grep -w $var >/dev/null
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
# add extra coordinate varibles
set var_list = ${var_list},ilev,hyai,hybi

echo  ${var_list}  > ${path_diag}/attributes/${casetype}_var_list
echo  ${required_vars}  > ${path_diag}/attributes/required_vars 

set set_13_flag = 1
foreach var ($var_list)
   if ( $var == CLISCCP || $var == CLMODIS || $var == CLMISR || $var == CFAD_DBZE94_CS ) then
      set set_13_flag = 0
   endif
end

echo ${set_13_flag} > ${path_diag}/attributes/set_13_flag
