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
set PATHDAT = /projects/NS2345K/noresm/cases/${CASENAME}/ocn/hist
set WORKDIR = /scratch/johiak/micom_diag/climo
set MODEL = micom
set FILETYPE = hm
set FILE_HEADER = ${CASENAME}.${MODEL}.${FILETYPE}.
set SEAS_MEAN = mon
set first_yr  = 21
set last_yr   = 50
set var_list  = templvl,salnlvl

#if ($#argv != 3) then
#  echo "usage: mon_climo.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR "
#  exit
#endif

# set echo on

# set DATE_FORMAT = $1

if ( ! -d $WORKDIR/$CASENAME ) then
   mkdir -p $WORKDIR/$CASENAME
endif

set pid = ()
foreach month (01 02 03 04 05 06 07 08 09 10 11 12) 
  echo "Climatological monthly mean for month=${month}"
  set filenames = ()
  @ YR = $first_yr
  while ($YR <= $last_yr)

     set yr_prnt           = `printf "%04d" {$YR}`
     set date              = ${yr_prnt}-${month}
     set filename          = ${FILE_HEADER}${date}.nc
     if (-e $PATHDAT/$filename) then
        set filenames = ($filenames $filename)
     else
        echo "ERROR: $PATHDAT/$filename does not exist."
	 echo "*** EXITING THE SCRIPT ***"
	 exit 
     endif
     @ YR++
  end
  set AVG_FILE = ${WORKDIR}/${CASENAME}/${CASENAME}.${MODEL}.${FILETYPE}.${first_yr}_${last_yr}y_${month}.nc
  /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $AVG_FILE &
  set pid = ($pid $!)
end
@ m = 1
while ($m <= 12)
   if (`ps -p "$pid[$m]" | wc -l` < 2) then
      echo "ERROR in computation of climatological monthly mean: /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $AVG_FILE"
      echo "*** EXITING THE SCRIPT ***"
      exit
   endif
   @ m++
end
wait
# Proceed with seasonal means


# /usr/local/bin/ncra --cb -O --no_tmp_fl -v TS,PRECC,PRECL --hdr_pad=10000 --gaa climo_script=ncclimo --gaa climo_command="'/projects/NS2345K/noresm_diagnostics_dev/bin/crontab/ncclimo -m cam -h h0 --seasons=ANN --no_amwg_links -v TS,PRECC,PRECL -c B1850MICOM_f09_tn14_01 -s 41 -e 50 -i /projects/NS2345K/noresm/cases/B1850MICOM_f09_tn14_01/atm/hist -o /scratch/johiak/micom_diag/climo/B1850MICOM_f09_tn14_01'" --gaa climo_hostname=tos-spw08.nird.sigma2.no --gaa climo_version=4.6.9 --gaa yrs_averaged=41-50 -p /projects/NS2345K/noresm/cases/B1850MICOM_f09_tn14_01/atm/hist B1850MICOM_f09_tn14_01.cam.h0.0040-12.nc B1850MICOM_f09_tn14_01.cam.h0.0041-12.nc B1850MICOM_f09_tn14_01.cam.h0.0042-12.nc B1850MICOM_f09_tn14_01.cam.h0.0043-12.nc B1850MICOM_f09_tn14_01.cam.h0.0044-12.nc B1850MICOM_f09_tn14_01.cam.h0.0045-12.nc B1850MICOM_f09_tn14_01.cam.h0.0046-12.nc B1850MICOM_f09_tn14_01.cam.h0.0047-12.nc B1850MICOM_f09_tn14_01.cam.h0.0048-12.nc B1850MICOM_f09_tn14_01.cam.h0.0049-12.nc /scratch/johiak/micom_diag/climo/B1850MICOM_f09_tn14_01/B1850MICOM_f09_tn14_01_12_004012_004912_climo.nc &


set script_end       = `date +%s`
set runtime_s        = `expr ${script_end} - ${script_start}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo "RUNTIME: ${runtime_script_m}m${runtime_script_s}s"

