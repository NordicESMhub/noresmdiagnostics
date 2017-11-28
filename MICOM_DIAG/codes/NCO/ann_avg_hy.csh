#!/bin/csh -f

# MICOM DIAGNOSTICS package (NCO tools)
# Detelina Ivanova, detelina.ivanova@nersc.no
# 25/03/2015

# This script creates a list of netCDF files and averages these to get
# seasonal or annual means.  Input data:
# $DATE_FORMAT  form of date in the history file name (eg. yyyy-mm or yyyy), input
# $PATHDAT  directory  where the history files are located
# $WORKDIR directory where the output is saved (create this in advance)
# $FILE_HEADER  beginning of filename
# $FILETYPE "hy" or "hm"
# $first_year first year to be averaged
# $last_year last year to be averaged
# $SEAS_MEAN Choose between: jfm, amj, jas, ond, fm, on, ann
#
# Usage: ./ann_avg_hy.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR


set CASENAME = N1850_f19_tn11_E17
set PATHDAT = /fimm/work/detivan/mnt/viljework/archive/${CASENAME}/ocn/hist
set WORKDIR = /fimm/work/detivan/noresm/micom_diag/diag_new/
set MODEL = micom
set FILETYPE = hy
set FILE_HEADER = ${CASENAME}.${MODEL}.${FILETYPE}.
set SEAS_MEAN = ann

echo $FILE_HEADER

if ($#argv != 3) then
  echo "usage: ./ann_avg_hy.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR "
  exit
endif

set echo on

set DATE_FORMAT = $1
@ first_yr = $2
@ last_yr = $3

@ YR = $first_yr
# Delete existing djf file, or it gets bigger and bigger
if (-e $SEAS_MEAN.asc) 'rm' -f $SEAS_MEAN.asc

while ($YR <= $last_yr) 

  set filenames = ()
  set four_digit_year = `printf "%04d" {$YR}`
  set date_string = `echo $DATE_FORMAT | sed s/yyyy/$four_digit_year/`
  set date_no_mnth = `echo $date_string | sed s/dd/01/`

  if ($SEAS_MEAN == jfm) then
    foreach month (01 02 03)
      set date = `echo $date_no_mnth | sed s/mm/$month/`
      set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
    end
  endif

  if ($SEAS_MEAN == fm) then
    foreach month (02 03)
      set date = `echo $date_no_mnth | sed s/mm/$month/`
      set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
    end
  endif

  if ($SEAS_MEAN == amj) then
    foreach month (04 05 06)
      set date = `echo $date_no_mnth | sed s/mm/$month/`
      set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
    end
  endif

  if ($SEAS_MEAN == jas) then
    foreach month (07 08 09)
      set date = `echo $date_no_mnth | sed s/mm/$month/`
      set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
    end
  endif

  if ($SEAS_MEAN == ond) then
    foreach month (10 11 12)
      set date = `echo $date_no_mnth | sed s/mm/$month/`
      set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
    end
  endif

  if ($SEAS_MEAN == on) then
    foreach month (10 11)
      set date = `echo $date_no_mnth | sed s/mm/$month/`
      set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
    end
  endif

  if ($SEAS_MEAN == ann) then
    set filenames = (${filenames} ${PATHDAT}/${FILE_HEADER}${four_digit_year}*.nc)
  endif

  ls ${filenames} >> $SEAS_MEAN.asc

  @ YR++

end

set files = `cat {$SEAS_MEAN}.asc`

# Average files in $SEAS_MEAN.asc , overwriting existing output file

set AVG_FILE = ${WORKDIR}/${CASENAME}/${CASENAME}.${MODEL}.${FILETYPE}.${first_yr}_${last_yr}y.nc
ncra -O $files $AVG_FILE

#if (-e $SEAS_MEAN.asc) 'rm' -f $SEAS_MEAN.asc  # Remove .asc files after computing avg

