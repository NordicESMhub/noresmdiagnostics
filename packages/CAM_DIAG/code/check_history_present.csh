#!/bin/csh -f

#*****************************************************************
# Check all history files are present
#
# 09/2017:
# Modified by Johan Liakka (johan.liakka@nersc.no)
# 12/2018:
# calculate AODVIS, yanchun.he@nersc.no
# Reason:
# due to the updated climatology computation there is no need
# to check for DJF specifically
#*****************************************************************

# MONTH          Type of climo: ANN, DJF,... 
# $path_local     The local directory for  history files
# $first_yr       The first yr of data
# $nyrs           The number of yrs of data 
# $rootname       The "root" for filename  
# $test_casename  Case name
# $path_climo     The local directory for climo files

#-----------------------------------------------------------
# Check arguments and set input variables

if ($#argv != 7) then
  echo $#argv
  echo 'usage: check_history_present.csh  MONTH $path_local  $first_year $nyrs $rootname $casename $path_climo'
  exit 1
endif

set MONTH = $1
set path_local  = $2
@ first_yr = $3
@ nyrs = $4
set rootname = $5
set casename = $6
set path_climo = $7

#-----------------------------------------------------------
# Set months
if ($MONTH == MONTHLY) then
  set months = (01 02 03 04 05 06 07 08 09 10 11 12)
else if ($MONTH == MAM) then
    set months = (03 04 05)
else if ($MONTH == JJA) then
    set months = (06 07 08)
else if ($MONTH == SOM) then
    set months = (09 10 11)
else if ($MONTH == DJF) then
    set months = (01 02 12)
else
    echo "ERROR: Check usage: check_history_present.csh"
    echo "MONTH is not set properly"
    exit 1
endif

#-----------------------------------------------------------
echo ' '
echo "CHECKING ${path_local}"
echo "FOR ALL $MONTH FILES"

@ yri = $first_yr
@ yr_end = $first_yr + $nyrs - 1      # space between "-" and "1"
while ( $yri <= $yr_end )    # loop over yrs
   foreach month ($months)
      set filename = ${rootname}`printf "%04d" ${yri}`-${month}
      if (! -e ${path_local}/${filename}.nc || -z ${path_local}/${filename}.nc) then      #file does not exist
         echo "${path_local}/${filename}.nc NOT FOUND"
         echo "ERROR: NEEDED MONTHLY FILES NOT IN ${path_local}"
         exit 1
      else  # calculate AODVIS if necessary variables present
         if (! -e ${path_climo}/derived/${filename}.nc) then
            if (! -d ${path_climo}/derived) then
                mkdir -p ${path_climo}/derived
            endif
            $nco_dir/ncks --quiet -d lat,0 -d lon,0 -d time,0 -v AOD_VIS,AODVVOLC,DAYFOC ${path_local}/${filename}.nc >/dev/null
            if ($? == 0) then
               cdo --history -s expr,'AODVIS=(AOD_VIS+AODVVOLC)/DAYFOC' ${path_local}/${filename}.nc ${path_climo}/derived/${filename}.nc
            else
               $nco_dir/ncks --quiet -d lat,0 -d lon,0 -d time,0 -v AOD_VIS,DAYFOC ${path_local}/${filename}.nc >/dev/null
               if ($? == 0) then
                   cdo --history -s expr,'AODVIS=AOD_VIS/DAYFOC' ${path_local}/${filename}.nc ${path_climo}/derived/${filename}.nc
               endif
            endif
            if ($? == 0) then
               set long_name = `cdo -s showattribute,AOD_VIS@long_name ${path_local}/${filename}.nc |cut -d'"' -f2`
               set units = `(cdo -s showattribute,AOD_VIS@units ${path_local}/${filename}.nc |cut -d'"' -f2`
               set cell_methods = `cdo -s showattribute,AOD_VIS@units ${path_local}/${filename}.nc |cut -d'"' -f2`
               $nco_dir/ncatted -h -a long_name,AODVIS,a,c,"$long_name" ${path_climo}/derived/${filename}.nc
               $nco_dir/ncatted -h -a units,AODVIS,a,c,"$units" ${path_climo}/derived/${filename}.nc
               $nco_dir/ncatted -h -a cell_methods,AODVIS,a,c,"$cell_methods" ${path_climo}/derived/${filename}.nc
            endif
         endif
      endif
   end
   @ yri++
end
echo "-->ALL $casename $MONTH FILES FOUND"
