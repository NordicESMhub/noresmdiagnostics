#!/bin/csh -f
#------------------------------------------
# Compute global mean of observational data
# Johan Liakka, NERSC, Nov 2017
#------------------------------------------
# Input variables:
# $timeseries_root     Local directory of time series file
# $casename            Experiment name

if ($#argv != 2) then
  echo "usage: global_mean_obs.csh needs 2 arguments"
  exit 1
endif

set timeseries_root   = $1
set casename          = $2

set obs_sources   = (LEGATES CLOUDSAT ERBE)
set time_out_path = $timeseries_root/$casename

if ( ! -d $time_out_path ) then
   mkdir -p $time_out_path
endif

foreach obs_source ($obs_sources)
   echo " COMPUTING GLOBAL MEANS OF $obs_source OBSERVATIONAL DATA."
   foreach seas (DJF JJA ANN)
      $nco_dir/ncwa -h -O -w gw -a lat,lon $OBS_DATA/${obs_source}_${seas}_climo.nc $time_out_path/${obs_source}_${seas}_gm.nc
   end
end
