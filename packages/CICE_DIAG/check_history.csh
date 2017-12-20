#!/bin/csh -f

#*****************************************************************
# Check to see if all history files are present
# Johan Liakka, Oct 2017
#*****************************************************************

# This file reads in files from MSS or HPSS
# $DATE_FORMAT  form of date in history file name (eg. yyyy-mm), input
# $BEG_READ     first year of data to read  , input
# $END_READ     last year of data to read   , input
# $FILE_HEADER  beginning of filename
# $PATH_MSS     directory on MSS or HPSS where data resides
# $PATHDAT      directory on dataproc where data will be put

if ($#argv != 3) then
  echo "usage: check_history.csh $DATE_FORMAT $BEG_READ $END_READ"
  exit
endif

set DATE_FORMAT = $1
@ BEG_READ = $2
@ END_READ = $3

if ($BEG_READ < 1) then    # so we don't get a negative number
  echo "ERROR: FIRST YEAR OF TEST DATA $BEG_READ MUST BE GT ZERO"
  exit 1
endif

@ IYEAR = $BEG_READ
#-------------------------------------------------------
# Loop through years
#-------------------------------------------------------
while ($IYEAR <= $END_READ)
  @ IMONTH = 1
  while ($IMONTH <= 12)

    set four_digit_year = `printf "%04d" {$IYEAR}`
    set date_string = `echo $DATE_FORMAT | sed s/yyyy/$four_digit_year/`
    set two_digit_month = `printf "%02d" {$IMONTH}`
    set date_string = `echo $date_string | sed s/mm/${two_digit_month}/`
    set date_string = `echo $date_string | sed s/dd/01/`
    set filename = ${FILE_HEADER}${date_string}

    if (! -e ${PATHDAT}/${filename}.nc) then
       echo "ERROR: File ${filename}.nc not present in $PATHDAT"
       exit 1
    endif
    @ IMONTH++
  end        # End of IMONTH <=12
  @ IYEAR++                             # advance year
end        # End of IYEAR <= END_READ

echo " FOUND ALL ${CASE_READ} history files between yr=${BEG_READ} and yr=${END_READ}"


