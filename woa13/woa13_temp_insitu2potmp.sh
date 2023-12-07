#!/usr/bin/env bash

# Convert WOA13 in-situ temperature to potential temperature refered to ocean surface.

# yanchun.he@nersc.no, 6 Dec. 2023

cwd=$(pwd)
export droot=/diagnostics/noresm/packages/BLOM_DIAG/obs_data/WOA13/1deg

tfiles=()
tfiles+=(woa13_decav_t00_01.nc)
tfiles+=(woa13_decav_t13_01.nc)
tfiles+=(woa13_decav_t14_01.nc)
tfiles+=(woa13_decav_t15_01.nc)
tfiles+=(woa13_decav_t16_01.nc)

potmpfiles=()
potmpfiles+=(woa13_decav_potmp00_01.nc)
potmpfiles+=(woa13_decav_potmp13_01.nc)
potmpfiles+=(woa13_decav_potmp14_01.nc)
potmpfiles+=(woa13_decav_potmp15_01.nc)
potmpfiles+=(woa13_decav_potmp16_01.nc)

sfiles=()
sfiles+=(woa13_decav_s00_01.nc)
sfiles+=(woa13_decav_s13_01.nc)
sfiles+=(woa13_decav_s14_01.nc)
sfiles+=(woa13_decav_s15_01.nc)
sfiles+=(woa13_decav_s16_01.nc)

for (( n = 0; n < ${#tfiles[*]}; n++ )); do
  export tfile=${tfiles[n]}
  export sfile=${sfiles[n]}
  export potmpfile=${potmpfiles[n]}
 
  echo $tfile

  # copy file 
  cd $droot
  ncks -O -v t_an $tfile $potmpfile
  cd $cwd

  ncl -Q <woa13_temp_insitu2potmp.ncl
  cd $droot
  ncrename -v t_an,potmp $potmpfile
  ncatted -a standard_name,potmp,m,c,"sea_water_potential_temperature" $potmpfile
  ncatted -a long_name,potmp,m,c,"Potential temperature calculated from t_an and s_an, referred to ocean surface" $potmpfile

done

# plot difference
levidx=(47 67 77 87)
depth=(1000 2000 3000 4000)
for k in 1 2 3 4
do
  cdo shaded,device=pdf,min=0.15,max=0.35,count=5,RGB=TRUE,colour_table=$HOME/local/cdo/palette/YlGnBu5.rgb -sellevidx,${levidx[$k]} -sub -selname,t_an woa13_decav_t00_01.nc -chname,potmp,t_an -selname,potmp woa13_decav_potmp00_01.nc $cwd/potmp_ann_diff_${depth[$k]}m
done
