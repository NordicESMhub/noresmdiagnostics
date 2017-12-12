#!/bin/csh -f

set script_start = `date +%s`

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

set CASENAME = B1850MICOM_f09_tn14_01
#set CASENAME = N1850_f19_tn11_230815
set PATHDAT = /projects/NS2345K/noresm/cases/${CASENAME}/atm/hist
set WORKDIR = /scratch/johiak/micom_diag/climo
set MODEL = cam
set var_list = TS,PRECC,PRECL
set FILETYPE = h0
set FILE_HEADER = ${CASENAME}.${MODEL}.${FILETYPE}.
set SEAS_MEAN = mon
set first_yr  = 41
set last_yr   = 50

#if ($#argv != 3) then
#  echo "usage: mon_climo.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR "
#  exit
#endif

# set echo on

# set DATE_FORMAT = $1

if ( ! -d $WORKDIR/$CASENAME ) then
   mkdir -p $WORKDIR/$CASENAME
endif

/projects/NS2345K/noresm_diagnostics_dev/bin/crontab/ncclimo -m $MODEL -h $FILETYPE --seasons=ANN --no_amwg_links -v $var_list -c $CASENAME -s $first_yr -e $last_yr -i $PATHDAT -o $WORKDIR/$CASENAME

#foreach month (01 02 03 04 05 06 07 08 09 10 11 12) 

#  if (-e $SEAS_MEAN.asc) 'rm' -f $SEAS_MEAN.asc
#  @ first_yr = $2
#  @ last_yr = $3
#  @ YR = $first_yr

#  while ($YR <= $last_yr)

#     set filenames = ()
#     set yr_prnt   = `printf "%04d" {$YR}`
#     set date      = ${yr_prnt}-${month}
#     set filenames = ($filenames ${PATHDAT}/${FILE_HEADER}${date}.nc)
#     ls ${filenames} >> $SEAS_MEAN.asc

#     @ YR++
#  end

#  set files = `cat {$SEAS_MEAN}.asc`
#  set AVG_FILE = ${WORKDIR}/${CASENAME}/${CASENAME}.${MODEL}.${FILETYPE}.${first_yr}_${last_yr}y_${month}.nc
#  ncra -O $files $AVG_FILE

#end # end loop over mth

set script_end       = `date +%s`
set runtime_s        = `expr ${script_end} - ${script_start}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo "RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
