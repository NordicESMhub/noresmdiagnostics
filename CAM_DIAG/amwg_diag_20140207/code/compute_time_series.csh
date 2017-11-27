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

if ($#argv != 8) then
  echo "usage: compute_time_series.csh needs 7 arguments"
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

set modelname=`cat ${path_diag}/attributes/${casetype}_modelname`
set req_vars="gw FSNT FLNT TREFHT CLDTOT CLDLOW CLDMED CLDHGH SWCF LWCF SST TS OCNFRAC"
set history_path=$history_path_root/$casename/atm/hist
set fullpath_filename=$history_path/$casename.$modelname.h0.`printf "%04d" ${syr}`-01.nc

set first_find = 1
set var_list = " "
foreach var ($req_vars)
   if ($cam_grid != SE) then
      /usr/local/bin/ncks --quiet  -d lat,0 -d lon,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename  >&! /dev/null
      set var_present = $status
   else
      /usr/local/bin/ncks --quiet  -d ncol,0 -d lev,0 -d ilev,0 -v $var $fullpath_filename >&! /dev/null
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

echo "$var_list"
echo  ${var_list}  > ${path_diag}/attributes/${casetype}_var_list_ts
echo  ${req_vars}  > ${path_diag}/attributes/required_vars_ts

if ( ! -e $timeseries_root/$casename/time_series_ANN_yrs${syr}-${eyr}.nc ) then

    if ( ! -d $timeseries_root/$casename ) then
	mkdir -p $timeseries_root/$casename
    endif

    set time_out_path = $timeseries_root/$casename
    
    set iyr = $syr
    while ( $iyr <= $eyr )
	set iyr_prnt = `printf "%04d" ${iyr}`
	echo " COMPUTING GLOBAL AND ANNUAL MEAN OF $casename FOR YR=$iyr_prnt"
	$ncclimo_dir/ncclimo --clm_md=mth -m $modelname -v $var_list -a sdd --season=ANN --no_amwg_links -c $casename -s $iyr -e $iyr -i $history_path -o $time_out_path > $time_out_path/tmp_ncclimo.txt
	/usr/bin/ncwa -h -O -w gw -a lat,lon $time_out_path/${casename}_ANN_${iyr_prnt}01_${iyr_prnt}12_climo.nc $time_out_path/global_mean_${iyr_prnt}.nc
	@ iyr = $iyr + 1
    end

    /usr/local/bin/ncrcat -O $time_out_path/global_mean_*.nc $time_out_path/time_series_ANN_yrs${syr}-${eyr}.nc

    foreach mon (01 02 03 04 05 06 07 08 09 10 11 12 ANN)
	rm $time_out_path/${casename}_${mon}_*_climo.nc
    end
    rm $time_out_path/global_mean_*.nc
    rm $time_out_path/tmp_*.txt
else
    echo " $timeseries_root/$casename/time_series_ANN_yrs${syr}-${eyr}.nc already exists."
endif
