#!/bin/csh -f

# MICOM DIAGNOSTICS package (NCO tools)
# Detelina Ivanova, detelina.ivanova@nersc.no
# Last update 28/04/2015

# This script "mon_climo.csh" creates monthly climatologies 
# 1. Creates a list of netCDF files 
# 2. Creates the mean with nco operators
# Input arguments:
#  $DATE_FORMAT format of date in the history file name (yyyy-mm )
#  $FIRST_YEAR first year of the average
#  $LAST_YEAR last year of the average
#  $PATHDAT  directory where the history files are located
#  $WORKDIR directory where the output is saved
#  $FILE_HEADER  beginning of filename
#
# Usage: ./mon_climo.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR

set CASENAME = N1850_f19_tn11_MLE1
set PATHDAT = /fimm/work/detivan/mnt/norstore/NS2345K/${CASENAME}/ocn/hist
set WORKDIR = /fimm/work/detivan/noresm/micom_diag/diag_new/
set MODEL = micom
set FILETYPE = hm
set FILE_HEADER = ${CASENAME}.${MODEL}.${FILETYPE}.
set SEAS_MEAN = mon

if ($#argv != 3) then
  echo "usage: mon_climo.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR "
  exit
endif

set echo on

set DATE_FORMAT = $1

foreach month (01 02 03 04 05 06 07 08 09 10 11 12) 

  if (-e $SEAS_MEAN.asc) 'rm' -f $SEAS_MEAN.asc
  @ first_yr = $2
  @ last_yr = $3
  @ YR = $first_yr

  while ($YR <= $last_yr)

     set filenames = ()
     set four_digit_year = `printf "%04d" {$YR}`
     set date_string = `echo $DATE_FORMAT | sed s/yyyy/$four_digit_year/`
     set date_no_mnth = `echo $date_string | sed s/dd/01/`


     set date = `echo $date_no_mnth | sed s/mm/$month/`
     set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
     ls ${filenames} >> $SEAS_MEAN.asc

     @ YR++
  end

  set files = `cat {$SEAS_MEAN}.asc`
  set AVG_FILE = ${WORKDIR}/${CASENAME}/${CASENAME}.${MODEL}.${FILETYPE}.${first_yr}_${last_yr}y_${month}.nc
  ncra -O $files $AVG_FILE

end # end loop over mth

