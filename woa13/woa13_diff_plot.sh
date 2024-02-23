#!/usr/bin/env bash
set -x 

cwd=$(pwd)
droot=/diagnostics/noresm/packages/BLOM_DIAG/obs_data/WOA13/1deg

function plot_latlon(){
    # plot difference
    levidx=(47 67 77 87)
    depth=(1000 2000 3000 4000)
    for k in 0 1 2 3
    do
      echo ${levidx[$k]}
      cdo shaded,device=pdf,min=0.2,max=0.4,count=5,RGB=TRUE,colour_table=$HOME/local/cdo/palette/YlOrBr5.rgb -sellevidx,${levidx[$k]} -sub -selname,t_an $droot/woa13_decav_t00_01.nc -chname,potmp,t_an -selname,potmp $droot/woa13_decav_potmp00_01.nc $cwd/potmp_ann_diff_${depth[$k]}m
    done
}

function plot_latdepth(){
    export pid=$$
    for region in glb atl ind pac so
    do
      echo $region
      cdo sub -selname,t_an $droot/woa13_decav_t00_01_zm_${region}.nc -selname,t_an -chname,potmp,t_an $droot/woa13_decav_potmp00_01_zm_${region}.nc /tmp/in${pid}.nc

      export VAR=t_an
      ncl ~/tools/micom/plot_latz2d.ncl
      mv figure${pid}.pdf $cwd/woa13_decav_potmp00_01_zm_${region}_diff.pdf
      rm -f /tmp/in${pid}.nc
    done
}

plot_latlon
#plot_latdepth
