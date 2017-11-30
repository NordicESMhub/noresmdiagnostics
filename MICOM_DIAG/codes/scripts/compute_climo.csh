#!/bin/csh -f

set script_start = `date +%s`

# MICOM DIAGNOSTICS package (NCO tools)
# Johan Liakka, johan.liakka@nersc.no
# (built upon preliminary work by Detelina Ivanova)
# Last update Dec 2017

# This script "compute_climo.csh" computes annual climatology of MICOM data
# Input arguments:
#  $CASENAME name of test case
#  $FIRST_YEAR first year of the average
#  $LAST_YEAR last year of the average
#  $PATHDAT  directory where the history files are located
#  $WORKDIR directory where the output is saved

#set CASENAME    = B1850MICOM_f09_tn14_01
#set CASENAME    = N1850_f19_tn11_230815
set CASENAME    = N1850_f19_tn11_01_E1
set PATHDAT     = /projects/NS2345K/noresm/cases/${CASENAME}/ocn/hist
set CLIMODIR    = /scratch/johiak/micom_diag/climo/$CASENAME
set DIAGDIR     = /scratch/johiak/micom_diag/diag/$CASENAME
set SCRIPT_HOME = /projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/codes/scripts
set first_yr    = 21
set last_yr     = 50

#if ($#argv != 3) then
#  echo "usage: mon_climo.csh $DATE_FORMAT $FIRST_YEAR $LAST_YEAR "
#  exit
#endif

if ( ! -d $CLIMODIR ) then
   mkdir -p $CLIMODIR
endif

if ( ! -d $DIAGDIR/attributes ) then
   mkdir -p $DIAGDIR/attributes
endif

echo "---------------------------------"
echo "MICOM_DIAG: COMPUTING CLIMATOLOGY"
echo "---------------------------------"

# Check if the annual climo file has already been computed.
# If the annual climo file does not exist, it is computed using the following priority (in descending order):
#  1. from annual history files         (compute_ANN=1)
#  2. from existing seasonal            (compute_ANN=2)
#  3. from existing monthly climatology (compute_ANN=3)
#  4. from monthly history files        (compute_ANN=4)
set first_yr_prnt = `printf "%04d" ${first_yr}`
set last_yr_prnt  = `printf "%04d" ${last_yr}`
set ANN_AVG_FILE  = ${CLIMODIR}/${CASENAME}_ANN_${first_yr_prnt}-${last_yr_prnt}_climo.nc
echo "Searching for existing annual climo file..."
if (! -e $ANN_AVG_FILE) then
   echo "${ANN_AVG_FILE} does not exist."
   echo "Searching for annual history files..."
   set compute_ANN  = 1
   @ YR = $first_yr
   while ($YR <= $last_yr)
      set yr_prnt = `printf "%04d" ${YR}`
      set filename = ${CASENAME}.micom.hy.${yr_prnt}.nc
      if (! -e $PATHDAT/$filename) then
	 set compute_ANN = 2
	 break
      endif
      @ YR++
   end
   if ($compute_ANN == 1) then
      echo "FOUND all annual history files (hy) for ${CASENAME} between yrs $first_yr and $last_yr"
      echo "-> COMPUTING CLIMATOLOGY FROM ANNUAL HISTORY FILES"
   else
      echo "$PATHDAT/${filename} does not exist."
      echo "Searching for seasonal climatogy files..."
      foreach seas (DJF MAM JJA SON)
         set SEAS_AVG_FILE = ${CLIMODIR}/${CASENAME}_${seas}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
	 if (! -e $SEAS_AVG_FILE) then
            set compute_ANN = 3
	    break
         endif
      end
      if ($compute_ANN == 2) then
         echo "FOUND all seasonal climatology files ${CLIMODIR}/${CASENAME}_*_${first_yr_prnt}-${last_yr_prnt}_climo.nc"
         echo "-> COMPUTING ANNUAL CLIMATOLOGY FROM SEASONAL CLIMATOLOGY"
      else
         echo "${SEAS_AVG_FILE} does not exist."
         echo "Searching for monthly climatogy files..."
         foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
            set MON_AVG_FILE = ${CLIMODIR}/${CASENAME}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
            if (! -e $MON_AVG_FILE) then
               set compute_ANN = 4
	       break
            endif
         end
         if ($compute_ANN == 3) then
            echo "FOUND all monthly climatology files ${CLIMODIR}/${CASENAME}_*_${first_yr_prnt}-${last_yr_prnt}_climo.nc"
            echo "-> COMPUTING ANNUAL CLIMATOLOGY FROM MONTHLY CLIMATOLOGY"
         else
            echo "${MON_AVG_FILE} does not exist."
	    echo "-> COMPUTING ANNUAL CLIMATOLOGY FROM MONTHLY HISTORY FILES."
         endif
      endif
   endif
else
   echo "$ANN_AVG_FILE already exists."
   echo "->SKIPPING COMPUTING CLIMATOLOGY"
   exit 0
endif

# Compute climatology from annual history files
if ($compute_ANN == 1) then
   # Check if vars exist in history files
   $SCRIPT_HOME/check_vars_climo.csh hy $first_yr $CASENAME $PATHDAT $DIAGDIR
   set var_list  = `cat $DIAGDIR/attributes/var_list_climo`
   set filenames = ()
   @ YR = $first_yr 
   while ($YR <= $last_yr)
      set yr_prnt = `printf "%04d" ${YR}`
      set filename = ${CASENAME}.micom.hy.${yr_prnt}.nc
      set filenames = ($filenames $filename)
      @ YR++
   end
   /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $ANN_AVG_FILE
   if ($status > 0) then
      echo "ERROR in computation of climatological annual mean: /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $ANN_AVG_FILE"
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
else
   # Compute climatology from monthly history files
   if ($compute_ANN == 4) then
      # Check if vars exist in history files
      $SCRIPT_HOME/check_vars_climo.csh hm $first_yr $CASENAME $PATHDAT $DIAGDIR
      set var_list = `cat $DIAGDIR/attributes/var_list_climo`
      # Determine dec flag
      #  dec_flag = SCD (Seasonally Continous December): default (consistent with amwg, lmwg, etc.)
      #  dec_flag = SDD (Seasonally Discontinous December): if simulation yr=first_yr-1 does not exist
      @ first_yr_prev           = $first_yr - 1
      set first_yr_prev_prnt    = `printf "%04d" ${first_yr_prev}`
      set date                  = ${first_yr_prev_prnt}-12
      set filename              = ${CASENAME}.micom.hm.${date}.nc
      if (-e $PATHDAT/$filename) then
         echo "FOUND December history file from yr=${first_yr_prev_prnt} -> using dec_flag=SCD"
         set dec_flag           = SCD
      else
         echo "CANNOT find December history file from yr=${first_yr_prev_prnt} -> using dec_flag=SDD"
         set dec_flag = SDD
      endif
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
            set filename = ${CASENAME}.micom.hm.${date}.nc
            if (-e $PATHDAT/$filename) then
               set filenames = ($filenames $filename)
            else
               echo "ERROR: $PATHDAT/$filename does not exist."
	       echo "ERROR: Cannot compute climatology based on the following info (please dubbel check):"
       	       echo "       CASENAME = $CASENAME"
	       echo "       PATHDAT  = $PATHDAT"
      	       echo "       first_yr = $first_yr"
       	       echo "       last_yr  = $last_yr"
               echo "*** EXITING THE SCRIPT ***"
               exit 1
            endif
            @ YR++
         end
	 set MON_AVG_FILE = ${CLIMODIR}/${CASENAME}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
         /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $MON_AVG_FILE &
         set pid = ($pid $!)
         @ m++
      end
      @ m = 1
      while ($m <= 12)
         if (`ps -p "$pid[$m]" | wc -l` < 2) then
            echo "ERROR in computation of climatological monthly mean: /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $PATHDAT $filenames $MON_AVG_FILE"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
         endif
         @ m++
      end
      wait
   endif
   if ($compute_ANN >= 3) then
      set pid = ()
      foreach seas (DJF MAM JJA SON)
         if ($seas == DJF) then
	    set wgt       = 31,31,28
	    set filenames = (${CASENAME}_12_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                     ${CASENAME}_01_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
			     ${CASENAME}_02_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
	 endif
	 if ($seas == MAM) then
 	    set wgt       = 31,30,31
	    set filenames = (${CASENAME}_03_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                     ${CASENAME}_04_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
			     ${CASENAME}_05_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
	 endif
     	 if ($seas == JJA) then
 	    set wgt       = 30,31,31
	    set filenames = (${CASENAME}_06_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                     ${CASENAME}_07_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
			     ${CASENAME}_08_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
	 endif
      	 if ($seas == SON) then
 	    set wgt       = 30,31,30
	    set filenames = (${CASENAME}_09_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                     ${CASENAME}_10_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
			     ${CASENAME}_11_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
	 endif
      	 set SEAS_AVG_FILE = ${CLIMODIR}/${CASENAME}_${seas}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
         /usr/local/bin/ncra -O -w $wgt --no_tmp_fl --hdr_pad=10000 -p $CLIMODIR $filenames $SEAS_AVG_FILE &
         set pid = ($pid $!)
      end
      @ m = 1
      while ($m <= 4)
         if (`ps -p "$pid[$m]" | wc -l` < 2) then
            echo "ERROR in computation of climatological seasonal mean: /usr/local/bin/ncra -O -w $wgt --no_tmp_fl --hdr_pad=10000 -p $CLIMODIR $filenames $SEAS_AVG_FILE"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
         endif
         @ m++
      end
      wait      
   endif
   set filenames = ()
   foreach seas (DJF MAM JJA SON)
      set filename  = ${CASENAME}_${seas}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
      set filenames = ($filenames $filename)
   end
   /usr/local/bin/ncra -O -w 90,92,92,91 --no_tmp_fl --hdr_pad=10000 -p $CLIMODIR $filenames $ANN_AVG_FILE
   if ($status > 0) then
      echo "ERROR in computation of climatological annual mean: /usr/local/bin/ncra -O -w 90,92,92,91 --no_tmp_fl --hdr_pad=10000 -p $CLIMODIR $filenames $ANN_AVG_FILE"
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
endif

set script_end       = `date +%s`
set runtime_s        = `expr ${script_end} - ${script_start}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo "RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
