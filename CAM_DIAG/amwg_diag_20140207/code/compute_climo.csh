#!/bin/csh -f

unset echo verbose

#*******************************************************************
# Updated version which uses ncclimo to calculate the climatologies
# (the old verstion is saved under compute_climo.old.csh)
# This version has thus far only been developed for
# $filetype = monthly_history.
# Please use the old version for $filetype=time_series.
#
# Johan Liakka, 26/09/17
#*******************************************************************

# This file reads in files from HPSS
# $path_history     The local directory for history files
# $path_climo       The local directory for climo files
# $path_diag        The local directory for diag files
# $first_yr       The first year of data
# $nyrs             The number of years of data 
# $casename         The casename  
# $rootname         The rootname  
# $strip_off_vars   Flag to strip variables 
# $casetype         test or cntl 
# $djf              PREV or NEXT 


if ($#argv != 13) then
  echo "usage: compute_climo.csh needs 13 arguments"
  exit 1
endif

set path_history  = $1
set path_climo = $2
set path_diag  = $3
@ first_yr = $4
@ nyrs = $5
set casename = $6
set rootname = $7
set strip_off_vars  = $8
set casetype = $9
set djf = $10
set filetype = $11
set diagcode = $12
set significance = $13

set var_list=`cat ${path_diag}/attributes/${casetype}_var_list`
set modelname=`cat ${path_diag}/attributes/${casetype}_modelname`

if ($filetype == "time_series") then
   echo "ERROR: compute_climo.csh can only be used for monthly_history."
   echo "ERROR: Use compute_climo.old.csh for time_series."
   exit 1
endif

#------------------------------------------------------------------------
# CALCULATING MONTHLY, SEASONAL AND ANNUAL CLIMOS
# DETERMINE FLAGS FOR NCCLIMO

# flag -e: Simulation end year
@ yr_end = $first_yr + $nyrs - 1

# flag -a: December seasonally continuous of discontinuous?
set djf_md = scd
if ( $djf == SDD ) then
   set djf_md = sdd
endif

echo ' '
echo "-------------------------"
echo "COMPUTING CLIMO FOR $casetype"
echo "-------------------------"

if ( $strip_off_vars == 0 ) then
#   /usr/local/bin/ncclimo --model_name=$modelname --var_lst=$var_list --dec_md=$djf_md --case=$casename --yr_srt=$first_yr --yr_end=$yr_end --drc_in=$path_history --drc_out=$path_climo
   $ncclimo_dir/ncclimo --clm_md=mth -m $modelname -v $var_list -a $djf_md -c $casename -s $first_yr -e $yr_end -i $path_history -o $path_climo
else
   $ncclimo_dir/ncclimo --clm_md=mth -m $modelname              -a $djf_md -c $casename -s $first_yr -e $yr_end -i $path_history -o $path_climo
endif
echo "-------------------------"

#------------------------------------------------------------------------
# CALCULATING YEARLY AVERAGES FOR significance=0

if ( $significance == 0 ) then
   echo ' '
   echo "significance = 0 --->"
   echo "--------------------------------------"
   echo "COMPUTING ANNUAL AND SEASONAL AVERAGES"
   echo "--------------------------------------"

   @ yr_cnt = $first_yr
   while ( $yr_cnt <= $yr_end )
      set fjan = ${rootname}`printf "%04d" ${yr_cnt}`-01.nc
      set ffeb = ${rootname}`printf "%04d" ${yr_cnt}`-02.nc
      set fmar = ${rootname}`printf "%04d" ${yr_cnt}`-03.nc
      set fapr = ${rootname}`printf "%04d" ${yr_cnt}`-04.nc
      set fmay = ${rootname}`printf "%04d" ${yr_cnt}`-05.nc
      set fjun = ${rootname}`printf "%04d" ${yr_cnt}`-06.nc
      set fjul = ${rootname}`printf "%04d" ${yr_cnt}`-07.nc
      set faug = ${rootname}`printf "%04d" ${yr_cnt}`-08.nc
      set fsep = ${rootname}`printf "%04d" ${yr_cnt}`-09.nc
      set foct = ${rootname}`printf "%04d" ${yr_cnt}`-10.nc
      set fnov = ${rootname}`printf "%04d" ${yr_cnt}`-11.nc
      if ( $djf == SCD ) then
         @ yr_prev = $yr_cnt - 1
 	 set fdec = ${rootname}`printf "%04d" ${yr_prev}`-12.nc
      else
      	 set fdec = ${rootname}`printf "%04d" ${yr_cnt}`-12.nc
      endif
      echo " FOR YEAR: $yr_cnt"
      if ( $strip_off_vars == 0 ) then
         /usr/local/bin/ncra -O -p ${path_history} -w 31,31,28    -v $var_list $fdec $fjan $ffeb ${path_climo}/tmp_djf_${yr_cnt}.nc
         /usr/local/bin/ncra -O -p ${path_history} -w 31,30,31    -v $var_list $fmar $fapr $fmay ${path_climo}/tmp_mam_${yr_cnt}.nc
         /usr/local/bin/ncra -O -p ${path_history} -w 30,31,31    -v $var_list $fjun $fjul $faug ${path_climo}/tmp_jja_${yr_cnt}.nc
         /usr/local/bin/ncra -O -p ${path_history} -w 30,31,30    -v $var_list $fsep $foct $fnov ${path_climo}/tmp_son_${yr_cnt}.nc
	 /usr/local/bin/ncra -O -p ${path_climo}   -w 90,92,92,91 -v $var_list tmp_djf_${yr_cnt}.nc tmp_mam_${yr_cnt}.nc tmp_jja_${yr_cnt}.nc tmp_son_${yr_cnt}.nc ${path_climo}/tmp_ann_${yr_cnt}.nc
      else
         /usr/local/bin/ncra -O -p ${path_history} -w 31,31,28    $fdec $fjan $ffeb ${path_climo}/tmp_djf_${yr_cnt}.nc
         /usr/local/bin/ncra -O -p ${path_history} -w 31,30,31    $fmar $fapr $fmay ${path_climo}/tmp_mam_${yr_cnt}.nc
         /usr/local/bin/ncra -O -p ${path_history} -w 30,31,31    $fjun $fjul $faug ${path_climo}/tmp_jja_${yr_cnt}.nc
         /usr/local/bin/ncra -O -p ${path_history} -w 30,31,30    $fsep $foct $fnov ${path_climo}/tmp_son_${yr_cnt}.nc
	 /usr/local/bin/ncra -O -p ${path_climo}   -w 90,92,92,91 tmp_djf_${yr_cnt}.nc tmp_mam_${yr_cnt}.nc tmp_jja_${yr_cnt}.nc tmp_son_${yr_cnt}.nc ${path_climo}/tmp_ann_${yr_cnt}.nc
      endif
      @ yr_cnt++
   end

   # Concatenate files
   echo " CONCATENATING DJF FILES ..."
   /usr/local/bin/ncrcat -O ${path_climo}/tmp_djf_*.nc ${path_climo}/${casename}_DJF_means.nc
   echo " CONCATENATING MAM FILES ..."
   /usr/local/bin/ncrcat -O ${path_climo}/tmp_mam_*.nc ${path_climo}/${casename}_MAM_means.nc
   echo " CONCATENATING JJA FILES ..."
   /usr/local/bin/ncrcat -O ${path_climo}/tmp_jja_*.nc ${path_climo}/${casename}_JJA_means.nc
   echo " CONCATENATING SON FILES ..."
   /usr/local/bin/ncrcat -O ${path_climo}/tmp_son_*.nc ${path_climo}/${casename}_SON_means.nc
   echo " CONCATENATING ANN FILES ..."
   /usr/local/bin/ncrcat -O ${path_climo}/tmp_ann_*.nc ${path_climo}/${casename}_ANN_means.nc

   # Clean up
   rm -f ${path_climo}/tmp_*.nc
endif

	     
