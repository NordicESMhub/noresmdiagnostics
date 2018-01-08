#!/bin/csh -f

set script_start = `date +%s`

# MICOM DIAGNOSTICS package (NCO tools)
# Johan Liakka, johan.liakka@nersc.no
# (built upon preliminary work by Detelina Ivanova)
# Last update Dec 2017

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
set first_yr  = 1
set last_yr   = 10
set var_list  = sst,templvl,salnlvl

#if ($#argv != 3) then
#  echo "usage: mon_climo.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR "
#  exit
#endif

if ( ! -d $WORKDIR/$CASENAME ) then
   mkdir -p $WORKDIR/$CASENAME
endif

echo "-------------------------------"
echo "MICOM_DIAG: COMPUTE CLIMATOLOGY"
echo "-------------------------------"

# Check if the annual climo file has already been computed.
# If the annual climo file does not exist, it is computed using 
# check for annual-mean output (FILETYPE=hy)
set first_yr_prnt = `printf "%04d" ${first_yr}`
set last_yr_prnt  = `printf "%04d" ${last_yr}`
set ANN_AVG_FILE  = ${WORKDIR}/${CASENAME}/${CASENAME}_ANN_${first_yr_prnt}-${last_yr_prnt}_climo.nc
if (! -e $ANN_AVG_FILE) then


else
   echo "${ANN_AVG_FILE} already exists."
endif

# Determine date stamps on monthy climatology
set first_yr_prnt  = `printf "%04d" ${first_yr}`
set last_yr_prnt   = `printf "%04d" ${last_yr}`
set date_stamp_mon = ()
@ m = 1
foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
   set date_stamp_mon = ($date_stamp_mon ${month}_${first_yr_prnt}${month}_${last_yr_prnt}${month})
   @ m++
end

# Determine dec flag
#  dec_flag = SCD (Seasonally Continous December)
#  -> default (to be consistent with amwg, lmwg, etc.)
#  dec_flag = SDD (Seasonally Discontinous December)
#  -> chosen if simulation yr=first_yr-1 does not exist
@ first_yr_prev           = $first_yr - 1
set first_yr_prev_prnt    = `printf "%04d" ${first_yr_prev}`
set date                  = ${first_yr_prev_prnt}-12
set filename              = ${FILE_HEADER}${date}.nc
if (-e $PATHDAT/$filename) then
   echo "FOUND December file from yr=${first_yr_prev_prnt} -> using dec_flag=SCD"
   set dec_flag           = SCD
   @ last_yr_prev         = $last_yr - 1
   set last_yr_prev_prnt  = `printf "%04d" ${last_yr_prev}`   
   set date_stamp_mon[12] = 12_${first_yr_prev_prnt}12_${last_yr_prev_prnt}12
else
   echo "NO December file from yr=${first_yr_prev_prnt} -> using dec_flag=SDD"
   set dec_flag = SDD
endif

# Check if a monthly climatogy already exists
set run_climo_mon = 0
@ m = 1
foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
  set AVG_FILE = ${WORKDIR}/${CASENAME}/${CASENAME}_${date_stamp_mon[$m]}_climo.nc
  if (! -e $AVG_FILE) then
     echo "$AVG_FILE does not exist: computing new monthly climo."
     set run_climo_mon = 1
  else
     echo "$AVG_FILE already exists."
  endif
  @ m++
end

# Compute monthly climatologies
if ($run_climo_mon == 1) then
   set pid = ()
   @ m = 1
   foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
      echo "Climatological monthly mean for month=${month}"
      set filenames = ()
      @ YR = $first_yr
      while ($YR <= $last_yr)
         if ($dec_flag == SCD && $month == 12) then
         @ prev_yr = $YR - 1
         set yr_prnt = `printf "%04d" ${prev_yr}`
      else
         set yr_prnt = `printf "%04d" ${YR}`
      endif
      set date     = ${yr_prnt}-${month}
      set filename = ${FILE_HEADER}${date}.nc
      if (-e $PATHDAT/$filename) then
         set filenames = ($filenames $filename)
      else
         echo "ERROR: $PATHDAT/$filename does not exist."
         echo "*** EXITING THE SCRIPT ***"
         exit 1
      endif
      @ YR++
   end
   set AVG_FILE = ${WORKDIR}/${CASENAME}/${CASENAME}_${date_stamp_mon[$m]}_climo.nc
   /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $AVG_FILE &
   set pid = ($pid $!)
   @ m++
   end
   @ m = 1
   while ($m <= 12)
      if (`ps -p "$pid[$m]" | wc -l` < 2) then
         echo "ERROR in computation of climatological monthly mean: /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $AVG_FILE"
         echo "*** EXITING THE SCRIPT ***"
         exit 1
      endif
      @ m++
   end
   wait
endif

# Proceed with seasonal climatologies
set pid = ()
foreach seas (DJF MAM JJA SON)


# /usr/local/bin/ncra --cb -O --no_tmp_fl -v TS,PRECC,PRECL --hdr_pad=10000 --gaa climo_script=ncclimo --gaa climo_command="'/projects/NS2345K/noresm_diagnostics_dev/bin/crontab/ncclimo -m cam -h h0 --seasons=ANN --no_amwg_links -v TS,PRECC,PRECL -c B1850MICOM_f09_tn14_01 -s 41 -e 50 -i /projects/NS2345K/noresm/cases/B1850MICOM_f09_tn14_01/atm/hist -o /scratch/johiak/micom_diag/climo/B1850MICOM_f09_tn14_01'" --gaa climo_hostname=tos-spw08.nird.sigma2.no --gaa climo_version=4.6.9 --gaa yrs_averaged=41-50 -p /projects/NS2345K/noresm/cases/B1850MICOM_f09_tn14_01/atm/hist B1850MICOM_f09_tn14_01.cam.h0.0040-12.nc B1850MICOM_f09_tn14_01.cam.h0.0041-12.nc B1850MICOM_f09_tn14_01.cam.h0.0042-12.nc B1850MICOM_f09_tn14_01.cam.h0.0043-12.nc B1850MICOM_f09_tn14_01.cam.h0.0044-12.nc B1850MICOM_f09_tn14_01.cam.h0.0045-12.nc B1850MICOM_f09_tn14_01.cam.h0.0046-12.nc B1850MICOM_f09_tn14_01.cam.h0.0047-12.nc B1850MICOM_f09_tn14_01.cam.h0.0048-12.nc B1850MICOM_f09_tn14_01.cam.h0.0049-12.nc /scratch/johiak/micom_diag/climo/B1850MICOM_f09_tn14_01/B1850MICOM_f09_tn14_01_12_004012_004912_climo.nc &


set script_end       = `date +%s`
set runtime_s        = `expr ${script_end} - ${script_start}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo "RUNTIME: ${runtime_script_m}m${runtime_script_s}s"

