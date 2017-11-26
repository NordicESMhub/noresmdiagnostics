#!/bin/csh -f

#*****************************************************************
# Get the file from the MSS if they don't exist locally
#*****************************************************************

# This file reads in files from HPSS
# $path_HPSS      The HPSS location for history files
# $path_local     The local directory for  history files
# $first_year     The first year of data
# $nyrs           The number of years of data 
# $rootname      The "root" for filename  

if ($#argv != 5) then
  echo "usage: read_from_mss.csh $path_HPSS $path_history  $first_year $nyrs $rootname"
  exit
endif

set path_HPSS = $1
set path_local  = $2
@ first_year = $3
@ nyrs = $4
set rootname = $5

  # December prior to first year
  if ($first_year >= 1) then    # so we don t get a negative number
    @ yri = $first_year - 1
    set filename = {$rootname}`printf "%04d" {$yri}`

    if (! -e ${path_local}/${filename}-12.nc || -z ${path_local}/${filename}-12.nc) then
         hsi ls  ${path_HPSS}{$filename}-12.nc    # Check whether history files are stored by month or year
         if(${status} == 0) then
	    echo 'GETTING '{$path_HPSS}{$filename}-12.nc
            hsi -q get ${path_local}{$filename}-12.nc :  {$path_HPSS}{$filename}-12.nc
         else
    	    echo 'GETTING '{$path_HPSS}{$filename}.tar
            hsi -q get  $path_local/{$filename}.tar : {$path_HPSS}{$filename}.tar               
	    tar -xvf ${path_local}/${filename}.tar    -C ${path_local}  
	    rm    -f ${path_local}/${filename}.tar
         endif
    else
    	 echo 'FOUND '{$path_local}{$filename}-12.nc
    endif
  else
    echo ERROR: FIRST YEAR OF TEST DATA $first_year MUST BE GT ZERO
    exit
  endif

  # Get the monthly outputs for the full period  
  @ yri = $first_year
  @ yr_end = $first_year + $nyrs - 1    # space between "-" and "1"
  while ( $yri <= $yr_end )           # loop over years
    set filename = {$rootname}`printf "%04d" {$yri}`
    @ mon = 1
    set months = (01 02 03 04 05 06 07 08 09 10 11 12)
    while ($mon <= 12)
    	set tname = {$rootname}`printf "%04d" {$yri}`-${months[$mon]}.nc
        if (! -e ${path_local}/$tname || -z ${path_local}/$tname) then
	    hsi ls ${path_HPSS}${tname}     # Check whether history files are stored by month or year
	    if(${status} == 0) then
   		echo  'GETTING '${path_HPSS}${tname}''     
                hsi  "get '${path_local}${tname}'  : '${path_HPSS}${tname}'  "
            else 
    	        echo 'GETTING '{$path_HPSS}{$filename}.tar
                hsi  get  ${path_local}/${filename}.tar  : ${path_HPSS}{$filename}.tar 
		tar -xvf ${path_local}/${filename}.tar   -C ${path_local} 
		rm    -f ${path_local}/${filename}.tar
	        @ mon = 12
            endif
    	else
    	    echo  'FOUND '{$path_local}{$tname}
	endif
	@ mon++
    end
    @ yri++                             # advance year
  end 

  # Jan, Feb of year following the last year
  @ yri = $yr_end + 1 
  set filename = {$rootname}`printf "%04d" {$yri}`
  if (! -e ${path_local}${filename}-01.nc || -z ${path_local}${filename}-01.nc ) then
         hsi ls ${path_HPSS}${tname}     # Check whether history files are stored by month or year
	 if(${status} == 0) then
	    echo 'GETTING '{$path_HPSS}{$filename}-01.nc
	    hsi "get  ${path_local}{$filename}-01.nc : {$path_HPSS}{$filename}-01.nc"
         else
	    echo 'GETTING '{$path_HPSS}{$filename}.tar
	    hsi get  ${path_local}{$filename}.tar : {$path_HPSS}{$filename}.tar
	    tar -xvf ${path_local}/${filename}.tar    -C ${path_local}  
	    rm    -f ${path_local}/${filename}.tar
	 endif  
  else
       	    echo  'FOUND '${path_local}${filename}-01.nc
  endif
  if (! -e ${path_local}${filename}-02.nc || -z ${path_local}${filename}-02.nc ) then
         hsi ls ${path_HPSS}${tname}     # Check whether history files are stored by month or year
	 if(${status} == 0) then
	    echo 'GETTING '{$path_HPSS}{$filename}-02.nc
	    hsi "get  ${path_local}{$filename}-02.nc : {$path_HPSS}{$filename}-02.nc"
         else
	    echo 'GETTING '{$path_HPSS}{$filename}.tar
	    hsi get  ${path_local}{$filename}.tar : {$path_HPSS}{$filename}.tar
	    tar -xvf ${path_local}/${filename}.tar    -C ${path_local}  
	    rm    -f ${path_local}/${filename}.tar
	 endif   
  else
     	    echo  'FOUND '${path_local}${filename}-02.nc
  endif

echo ' '
echo ' '
