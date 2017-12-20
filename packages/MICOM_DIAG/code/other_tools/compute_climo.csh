#!/bin/csh -f

set script_start = `date +%s`
#
# MICOM DIAGNOSTICS package: compute_climo.csh
# PURPOSE: computes climatology from annual or monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# (built upon previous work by Detelina Ivanova)
# Last update Dec 2017

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $climodir  directory where the climatology files are located

set filetype = $1
set casename = $2
set first_yr = $3
set last_yr  = $4
set pathdat  = $5
set climodir = $6

echo " "
echo "-----------------------"
echo "compute_climo.csh"
echo "-----------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " climodir = $climodir"
echo " "

set var_list      = `cat $WKDIR/attributes/vars_${casename}_climo_${filetype}`
set first_yr_prnt = `printf "%04d" ${first_yr}`
set last_yr_prnt  = `printf "%04d" ${last_yr}`
set ann_avg_file  = ${climodir}/${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_climo_${filetype}.nc

# COMPUTE CLIMATOLOGY FROM ANNUAL FILES
if ($filetype == hy) then
   set filenames = ()
   @ YR = $first_yr 
   while ($YR <= $last_yr)
      set yr_prnt = `printf "%04d" ${YR}`
      set filename = ${casename}.micom.hy.${yr_prnt}.nc
      set filenames = ($filenames $filename)
      @ YR++
   end
   echo "Climatological seasonal mean for ANN"
   /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat $filenames $ann_avg_file
   if ($status > 0) then
      echo "ERROR in computation of climatological annual mean: /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat $filenames $ann_avg_file"
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
endif

# COMPUTE CLIMATOLOGY FROM MONTHLY FILES
if ($filetype == hm) then
   # Determine dec flag
   #  dec_flag = SCD (Seasonally Continous December): default (consistent with amwg, lmwg, etc.)
   #  dec_flag = SDD (Seasonally Discontinous December): if simulation yr=first_yr-1 does not exist
   @ first_yr_prev           = $first_yr - 1
   set first_yr_prev_prnt    = `printf "%04d" ${first_yr_prev}`
   set date                  = ${first_yr_prev_prnt}-12
   set filename              = ${casename}.micom.hm.${date}.nc
   if (-e $pathdat/$filename) then
      echo "FOUND December history file from yr=${first_yr_prev_prnt} -> using dec_flag=SCD"
      set dec_flag = SCD
   else
      echo "CANNOT find December history file from yr=${first_yr_prev_prnt} -> using dec_flag=SDD"
      set dec_flag = SDD
   endif
   # COMPUTE MONTHLY MEAN
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
         set filename = ${casename}.micom.hm.${date}.nc
         if (-e $pathdat/$filename) then
            set filenames = ($filenames $filename)
         else
            echo "ERROR: $pathdat/$filename does not exist."
            echo "*** EXITING THE SCRIPT ***"
            exit 1
         endif
         @ YR++
      end
      set mon_avg_file = ${climodir}/${casename}_${month}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
      /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat $filenames $mon_avg_file &
      set pid = ($pid $!)
      @ m++
   end
   @ m = 1
   while ($m <= 12)
      if (`ps -p "$pid[$m]" | wc -l` < 2) then
         echo "ERROR in computation of climatological monthly mean: /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -v $var_list -p $pathdat $filenames $mon_avg_file"
         echo "*** EXITING THE SCRIPT ***"
         exit 1
      endif
      @ m++
   end
   wait
   # COMPUTE SEASONAL MEAN
   set pid = ()
   foreach seas (DJF MAM JJA SON)
      echo "Climatological seasonal mean for ${seas}"
      if ($seas == DJF) then
         set wgt       = 31,31,28
         set filenames = (${casename}_12_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
                          ${casename}_01_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
                          ${casename}_02_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
      endif
      if ($seas == MAM) then
         set wgt       = 31,30,31
         set filenames = (${casename}_03_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
                          ${casename}_04_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
                          ${casename}_05_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
      endif
      if ($seas == JJA) then
         set wgt       = 30,31,31
	 set filenames = (${casename}_06_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                  ${casename}_07_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                  ${casename}_08_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
      endif
      if ($seas == SON) then
 	 set wgt       = 30,31,30
	 set filenames = (${casename}_09_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                  ${casename}_10_${first_yr_prnt}-${last_yr_prnt}_climo.nc \
	                  ${casename}_11_${first_yr_prnt}-${last_yr_prnt}_climo.nc)
      endif
      set seas_avg_file = ${climodir}/${casename}_${seas}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
      /usr/local/bin/ncra -O -w $wgt --no_tmp_fl --hdr_pad=10000 -p $climodir $filenames $seas_avg_file &
      set pid = ($pid $!)
   end
#   @ m = 1
#   while ($m <= 4)
#      ps -p $pid[$m]
#      if (`ps -p "$pid[$m]" | wc -l` < 2) then
#         echo "ERROR in computation of climatological seasonal mean: /usr/local/bin/ncra -O -w $wgt --no_tmp_fl --hdr_pad=10000 -p $climodir $filenames $seas_avg_file"
#         echo "*** EXITING THE SCRIPT ***"
#         exit 1
#      endif
#      @ m++
#   end
   wait      
   # COMPUTE ANNUAL MEAN
   set filenames = ()
   foreach seas (DJF MAM JJA SON)
      set filename  = ${casename}_${seas}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
      set filenames = ($filenames $filename)
   end
   echo "Climatological seasonal mean for ANN"
   /usr/local/bin/ncra -O -w 90,92,92,91 --no_tmp_fl --hdr_pad=10000 -p $climodir $filenames $ann_avg_file
   if ($status > 0) then
      echo "ERROR in computation of climatological annual mean: /usr/local/bin/ncra -O -w 90,92,92,91 --no_tmp_fl --hdr_pad=10000 -p $climodir $filenames $ann_avg_file"
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
endif

set script_end       = `date +%s`
set runtime_s        = `expr ${script_end} - ${script_start}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo "CLIMO RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
