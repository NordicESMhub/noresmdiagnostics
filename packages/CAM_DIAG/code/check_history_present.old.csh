#!/bin/csh -f

#*****************************************************************
# Check all history files are present
#*****************************************************************

# MONTH             Type of climo: ANN, DJF,... 
# $path_local     The local directory for  history files
# $first_yr       The first yr of data
# $nyrs             The number of yrs of data 
# $rootname       The "root" for filename  

#-----------------------------------------------------------
# Check arguments and set input variables

if ($#argv != 6) then
  echo $#argv
  echo "usage: check_history_present.csh  MONTH $path_local  $first_year $nyrs $rootname $casename"  
  exit
endif

set MONTH = $1
set path_local  = $2
@ first_yr = $3
@ nyrs = $4
set rootname = $5
set casename = $6

#-----------------------------------------------------------
# Set months
if ($MONTH == MONTHLY) then
  set months = (01 02 03 04 05 06 07 08 09 10 11 12)
else
  if ($MONTH == MAM) then
    set months = (03 04 05)
  else
     if ($MONTH == JJA) then
       set months = (06 07 08)
     else 
        if ($MONTH == SOM) then
            set months = (09 10 11)
        else 
            if ($MONTH != DJF) then 
                echo ERROR: Check usage: check_history_present.csh 
                echo MONTH is not set properly
            endif        
        endif
     endif
  endif
endif

#-----------------------------------------------------------
if ($MONTH != DJF) then 
  echo ' '
  echo CHECKING $path_local 
  echo FOR ALL $MONTH FILES 

  # check for the all months
  @ yri = $first_yr
  @ yr_end = $first_yr + $nyrs - 1      # space between "-" and "1"
  while ( $yri <= $yr_end )    # loop over yrs
    foreach month ($months)
      set filename = ${rootname}`printf "%04d" ${yri}`-${month}
      echo  'CHECKING FOR '${path_local}/${filename}.nc
      if (! -e ${path_local}/${filename}.nc || -z ${path_local}/${filename}.nc) then      #file does not exist
        echo ${path_local}/${filename}.nc NOT FOUND
        echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
        exit
      endif
    end
    @ yri++
  end
  echo '-->ALL' $casename $MONTH FILES FOUND
  echo ' '

else
#-----------------------------------------------------------
  # For DJF we need to use december of previous year 
  # or Jan and Feb from next year

  echo CHECKING $path_local 
  echo FOR DJF MONTHLY FILES

  if ($first_yr >= 1) then    # so we don t get a negative number
    @ prev_yri = $first_yr - 1
    @ next_yri = $first_yr + $nyrs
    set filename_prev_year = ${rootname}`printf "%04d" ${prev_yri}`
    set filename_next_year = ${rootname}`printf "%04d" ${next_yri}`
  else
    echo ERROR: FIRST YEAR OF TEST DATA $first_yr MUST BE GT ZERO
    exit
  endif    

  #----------- 
  # if dec of previous year is not present, we need to have Jan and Feb and next year
  if (! -e ${path_local}/${filename_prev_year}-12.nc || -z ${path_local}/${filename_prev_year}-12.nc) then    # dec of previous year is not present
    # check for Jan, Feb of the year following the last year
    if (! -e ${path_local}/${filename_next_year}-01.nc || -z ${path_local}/${filename_next_year}-01.nc) then
      echo ERROR: ${path_local}/${filename_next_year}-01.nc NOT FOUND
      echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
      exit
    endif
    if (! -e ${path_local}/${filename_next_year}-02.nc || -z ${path_local}/${filename_next_year}-02.nc) then
      echo ERROR: ${path_local}/${filename_next_year}-02.nc NOT FOUND
      echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
      exit
    endif

    @ yri = $first_yr + 1
    @ yr_end = $first_yr + $nyrs     
    while ( $yri <= $yr_end )               # loop over years
      @ prev_yr = $yri - 1
      set filename = ${rootname}`printf "%04d" ${prev_yr}`-12
      echo  'CHECKING FOR '${path_local}/${filename}.nc
      if (! -e ${path_local}/${filename}.nc || -z ${path_local}/${filename}.nc) then
        echo ERROR: ${path_local}/${filename}.nc NOT FOUND
        echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
        exit
      endif                 
      foreach month (01 02)
        set filename = ${rootname}`printf "%04d" ${yri}`-${month}     
        echo  'CHECKING FOR '${path_local}/${filename}.nc
        if (! -e ${path_local}/${filename}.nc || -z ${path_local}/${filename}.nc) then      #file does not exist
          echo ERROR: ${path_local}/${filename}.nc NOT FOUND
          echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
          exit
        endif
      end
      @ yri++
    end    
 
  #----------- 
  else
    # dec of previous year is present
    @ yri = $first_yr
    @ yr_end = $first_yr + $nyrs - 1
    while ( $yri <= $yr_end )               # loop over years
      @ prev_yr = $yri - 1
      set filename = ${rootname}`printf "%04d" ${prev_yr}`-12
      echo  'CHECKING FOR '${path_local}/${filename}.nc
      if (! -e ${path_local}/${filename}.nc || -z ${path_local}/${filename}.nc) then
        echo ERROR: ${path_local}/${filename}.nc NOT FOUND
        echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
        exit
      endif                 
      foreach month (01 02)
        set filename = ${rootname}`printf "%04d" ${yri}`-${month}     
        echo  'CHECKING FOR '${path_local}/${filename}.nc
        if (! -e ${path_local}/${filename}.nc || -z ${path_local}/${filename}.nc) then      #file does not exist
          echo ERROR: ${path_local}/${filename}.nc NOT FOUND
          echo ERROR: NEEDED MONTHLY FILES NOT IN $path_local
          exit
        endif
      end
      @ yri++
    end
  endif
  echo '-->ALL' $casename DJF FILES FOUND
  echo ' '

endif
