#!/bin/csh -f
#----------------------------------------
# Compute time series of atmospheric data
# Johan Liakka, NERSC, Nov 2017
#----------------------------------------
# Input variables:
# $timeseries_root     Local directory of time series file
# $casename            Experiment name
# $history_path_root   Local directory to history files
# $syr                 Experiment start yr
# $eyr                 Experiment end yr
# $path_diag           Local directory of diagnostics
# $casetype            test or cntl

if ($#argv != 9) then
  echo "usage: compute_time_series.csh needs 9 arguments"
  exit 1
endif

set timeseries_root   = $1
set casename          = $2
set history_path_root = $3
set syr               = $4
set eyr               = $5
set path_diag         = $6
set casetype          = $7
set cam_grid          = $8
set four_seas         = $9

set modelname = `cat ${path_diag}/attributes/${casetype}_modelname`
set req_vars = "gw FSNT FLNT TREFHT PRECT PRECC PRECL CLDTOT CLDLOW CLDMED CLDHGH SWCF LWCF"
set history_path = $history_path_root/$casename/atm/hist
set fullpath_filename = $history_path/$casename.$modelname.h0.`printf "%04d" ${syr}`-01.nc

set first_find = 1
set var_list = " "
foreach var ($req_vars)
   if ($cam_grid != SE) then
      $nco_dir/ncks --quiet  -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename  >&! /dev/null
      set var_present = $status
   else
      $nco_dir/ncks --quiet  -d ncol,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename >&! /dev/null
      set var_present = $status
   endif
   if ($var_present == 0) then
      if ($first_find) then
         set var_list = $var
         set first_find=0
      else
         set var_list = ${var_list},$var
      endif
   endif
end

echo  ${var_list}  > ${path_diag}/attributes/${casetype}_var_list_ts
echo  ${req_vars}  > ${path_diag}/attributes/required_vars_ts

if ($four_seas == 1) then
   if ( -e $timeseries_root/$casename/time_series_ANN_yrs${syr}-${eyr}.nc && \
        -e $timeseries_root/$casename/time_series_DJF_yrs${syr}-${eyr}.nc && \
        -e $timeseries_root/$casename/time_series_JJA_yrs${syr}-${eyr}.nc ) then
      echo " ANN, DJF and JJA time_series for $casename already exist."
   else     
      if ( ! -d $timeseries_root/$casename ) then
         mkdir -p $timeseries_root/$casename
      endif

      set time_out_path = $timeseries_root/$casename
    
      set iyr = $syr
      while ( $iyr <= $eyr )
          set iyr_prnt = `printf "%04d" ${iyr}`
         echo " COMPUTING ANN, DJF, JJA AND GLOBAL MEAN OF $casename FOR YR=$iyr_prnt"
         $nco_dir/ncclimo --clm_md=mth -m $modelname -v $var_list -a sdd --no_amwg_links -c $casename -s $iyr -e $iyr -i $history_path -o $time_out_path > $time_out_path/tmp_ncclimo.txt
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_ANN_${iyr_prnt}01_${iyr_prnt}12_climo.nc $time_out_path/global_mean_ANN_${iyr_prnt}.nc
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_DJF_${iyr_prnt}01_${iyr_prnt}12_climo.nc $time_out_path/global_mean_DJF_${iyr_prnt}.nc
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_JJA_${iyr_prnt}06_${iyr_prnt}08_climo.nc $time_out_path/global_mean_JJA_${iyr_prnt}.nc
         @ iyr = $iyr + 1
      end

      $nco_dir/ncrcat -O $time_out_path/global_mean_ANN_*.nc $time_out_path/time_series_ANN_yrs${syr}-${eyr}.nc
      $nco_dir/ncrcat -O $time_out_path/global_mean_DJF_*.nc $time_out_path/time_series_DJF_yrs${syr}-${eyr}.nc
      $nco_dir/ncrcat -O $time_out_path/global_mean_JJA_*.nc $time_out_path/time_series_JJA_yrs${syr}-${eyr}.nc

      foreach mon (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF JJA)
         rm $time_out_path/${casename}_${mon}_*_climo.nc
      end
      rm $time_out_path/global_mean_*.nc
      rm $time_out_path/tmp_*.txt
   endif
else
   if ( -e $timeseries_root/$casename/time_series_ANN_yrs${syr}-${eyr}.nc && \
        -e $timeseries_root/$casename/time_series_DJF_yrs${syr}-${eyr}.nc && \
        -e $timeseries_root/$casename/time_series_MAM_yrs${syr}-${eyr}.nc && \
        -e $timeseries_root/$casename/time_series_JJA_yrs${syr}-${eyr}.nc && \
        -e $timeseries_root/$casename/time_series_SON_yrs${syr}-${eyr}.nc ) then
      echo " ANN, DJF, MAM, JJA and SON time_series for $casename already exist."
   else     
      if ( ! -d $timeseries_root/$casename ) then
         mkdir -p $timeseries_root/$casename
      endif

      set time_out_path = $timeseries_root/$casename
    
      set iyr = $syr
      while ( $iyr <= $eyr )
          set iyr_prnt = `printf "%04d" ${iyr}`
         echo " COMPUTING SEASONAL AND GLOBAL MEAN OF $casename FOR YR=$iyr_prnt"
         $nco_dir/ncclimo --clm_md=mth -m $modelname -v $var_list -a sdd --no_amwg_links -c $casename -s $iyr -e $iyr -i $history_path -o $time_out_path > $time_out_path/tmp_ncclimo.txt
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_ANN_${iyr_prnt}01_${iyr_prnt}12_climo.nc $time_out_path/global_mean_ANN_${iyr_prnt}.nc
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_DJF_${iyr_prnt}01_${iyr_prnt}12_climo.nc $time_out_path/global_mean_DJF_${iyr_prnt}.nc
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_MAM_${iyr_prnt}03_${iyr_prnt}05_climo.nc $time_out_path/global_mean_MAM_${iyr_prnt}.nc
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_JJA_${iyr_prnt}06_${iyr_prnt}08_climo.nc $time_out_path/global_mean_JJA_${iyr_prnt}.nc
         $nco_dir/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_SON_${iyr_prnt}09_${iyr_prnt}11_climo.nc $time_out_path/global_mean_SON_${iyr_prnt}.nc
         @ iyr = $iyr + 1
      end

      $nco_dir/ncrcat -O $time_out_path/global_mean_ANN_*.nc $time_out_path/time_series_ANN_yrs${syr}-${eyr}.nc
      $nco_dir/ncrcat -O $time_out_path/global_mean_DJF_*.nc $time_out_path/time_series_DJF_yrs${syr}-${eyr}.nc
      $nco_dir/ncrcat -O $time_out_path/global_mean_MAM_*.nc $time_out_path/time_series_MAM_yrs${syr}-${eyr}.nc
      $nco_dir/ncrcat -O $time_out_path/global_mean_JJA_*.nc $time_out_path/time_series_JJA_yrs${syr}-${eyr}.nc
      $nco_dir/ncrcat -O $time_out_path/global_mean_SON_*.nc $time_out_path/time_series_SON_yrs${syr}-${eyr}.nc

      foreach mon (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF MAM JJA SON)
         rm $time_out_path/${casename}_${mon}_*_climo.nc
      end
      rm $time_out_path/global_mean_*.nc
      rm $time_out_path/tmp_*.txt
   endif
endif

