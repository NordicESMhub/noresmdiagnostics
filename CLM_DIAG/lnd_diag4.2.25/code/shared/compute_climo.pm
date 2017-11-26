#!/usr/bin/perl

# written by Johan Liakka
# October 2017


$share_code = $ENV{'DIAG_SHARED'};   
use lib '$share_code'; 

use lnd_ann;
use lnd_util;
use lnd_getFiles;
use lnd_mons;
use lnd_seas_climo;
use lnd_seas_means;

sub create_climo
{
  print("\ncreate_climo: computes lnd climatology using ncclimo \n") ;

  # -- Input:  monthly history files over climate period, first year, last year
  # -- Output:  annual, seasonal and monthly climatologies

  if ($decFlag == 1) {
      $djf_md = "scd";
  }
  else {
      $djf_md = "sdd";
  }
  
  $err = system("$ncclimoDir/ncclimo --clm_md=mth -m $mode -a $djf_md --no_amwg_links -c $caseid -s $clim_fyr -e $clim_lyr -i $casedir -o $prefixDir"); die "ncclimo failed\n" if $err;
  chdir("$prefixDir");

  # -- Concancate the monthly files
  print("\n--Merge all monthly files\n");
  if ($decFlag == 1) {
     system("/usr/local/bin/ncrcat -O ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyrm_prnt}12_${clim_lyrm_prnt}12_climo.nc ${prefix}_MONS_climo.nc"); die "ncrcat failed\n" if $err;
     system("rm ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyrm_prnt}12_${clim_lyrm_prnt}12_climo.nc"); die "rm failed\n" if $err;
  }
  else {
      system("/usr/local/bin/ncrcat -O ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyr_prnt}12_${clim_lyr_prnt}12_climo.nc ${prefix}_MONS_climo.nc"); die "ncrcat failed\n" if $err;
      system("rm ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyr_prnt}12_${clim_lyr_prnt}12_climo.nc"); die "rm failed\n" if $err;
  }

  # -- Change names of seasonal and annual files
  if ( $mode eq "clm2" ) {
      system("mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc ${prefix}_JJA_climo.nc"); die "mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc failed\n" if $err;
      system("mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc ${prefix}_SON_climo.nc"); die "mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      system("mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc ${prefix}_MAM_climo.nc"); die "mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc failed\n" if $err;
      if ($decFlag == 1) {
	  system("mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc ${prefix}_DJF_climo.nc"); die "mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc ${prefix}_ANN_climo.nc"); die "mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      }
      else {
	  system("mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_DJF_climo.nc"); die "mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_ANN_climo.nc"); die "mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
      }
  }
  if ( $mode eq "cam" or $mode eq "cam2" ) {
      system("mv ${prefix}_MONS_climo.nc ${prefix}_MONS_climo_atm.nc"); die "mv ${prefix}_MONS_climo.nc failed\n" if $err;
      system("mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc ${prefix}_JJA_climo_atm.nc"); die "mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc failed\n" if $err;
      system("mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc ${prefix}_SON_climo_atm.nc"); die "mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      system("mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc ${prefix}_MAM_climo_atm.nc"); die "mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc failed\n" if $err;
      if ($decFlag == 1) {
	  system("mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc ${prefix}_DJF_climo_atm.nc"); die "mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc ${prefix}_ANN_climo_atm.nc"); die "mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      }
      else {
	  system("mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_DJF_climo_atm.nc"); die "mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_ANN_climo_atm.nc"); die "mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
      }
  }
  
  print(" END  ----  create_climo\n") ;
}

sub create_climo_atm
{
  print("\ncreate_climo_atm: computes atm climatology using ncclimo \n") ;

  # -- Input:  monthly history files over climate period, first year, last year
  # -- Output:  annual, seasonal and monthly climatologies

  $atmVars = "T,Q,Z3";
  
  if ($decFlag == 1) {
      $djf_md = "scd";
  }
  else {
      $djf_md = "sdd";
  }

  $err = system("$ncclimoDir/ncclimo --clm_md=mth -m $mode -v $atmVars -a $djf_md --no_amwg_links -c $caseid -s $clim_fyr -e $clim_lyr -i $casedir -o $prefixDir"); die "ncclimo failed\n" if $err;
  chdir("$prefixDir");

  # -- Concancate the monthly files
  print("\n--Merge all monthly files\n");
  if ($decFlag == 1) {
     system("/usr/local/bin/ncrcat -O ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyrm_prnt}12_${clim_lyrm_prnt}12_climo.nc ${prefix}_MONS_climo.nc"); die "ncrcat failed\n" if $err;
     system("rm ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyrm_prnt}12_${clim_lyrm_prnt}12_climo.nc"); die "rm failed\n" if $err;
  }
  else {
      system("/usr/local/bin/ncrcat -O ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyr_prnt}12_${clim_lyr_prnt}12_climo.nc ${prefix}_MONS_climo.nc"); die "ncrcat failed\n" if $err;
      system("rm ${caseid}_01_${clim_fyr_prnt}01_${clim_lyr_prnt}01_climo.nc ${caseid}_02_${clim_fyr_prnt}02_${clim_lyr_prnt}02_climo.nc ${caseid}_03_${clim_fyr_prnt}03_${clim_lyr_prnt}03_climo.nc ${caseid}_04_${clim_fyr_prnt}04_${clim_lyr_prnt}04_climo.nc ${caseid}_05_${clim_fyr_prnt}05_${clim_lyr_prnt}05_climo.nc ${caseid}_06_${clim_fyr_prnt}06_${clim_lyr_prnt}06_climo.nc ${caseid}_07_${clim_fyr_prnt}07_${clim_lyr_prnt}07_climo.nc ${caseid}_08_${clim_fyr_prnt}08_${clim_lyr_prnt}08_climo.nc ${caseid}_09_${clim_fyr_prnt}09_${clim_lyr_prnt}09_climo.nc ${caseid}_10_${clim_fyr_prnt}10_${clim_lyr_prnt}10_climo.nc ${caseid}_11_${clim_fyr_prnt}11_${clim_lyr_prnt}11_climo.nc ${caseid}_12_${clim_fyr_prnt}12_${clim_lyr_prnt}12_climo.nc"); die "rm failed\n" if $err;
  }

  # -- Change names of seasonal and annual files
  if ( $mode eq "clm2" ) {
      system("mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc ${prefix}_JJA_climo.nc"); die "mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc failed\n" if $err;
      system("mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc ${prefix}_SON_climo.nc"); die "mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      system("mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc ${prefix}_MAM_climo.nc"); die "mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc failed\n" if $err;
      if ($decFlag == 1) {
	  system("mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc ${prefix}_DJF_climo.nc"); die "mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc ${prefix}_ANN_climo.nc"); die "mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      }
      else {
	  system("mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_DJF_climo.nc"); die "mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_ANN_climo.nc"); die "mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
      }
  }
  if ( $mode eq "cam" or $mode eq "cam2" ) {
      system("mv ${prefix}_MONS_climo.nc ${prefix}_MONS_climo_atm.nc"); die "mv ${prefix}_MONS_climo.nc failed\n" if $err;
      system("mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc ${prefix}_JJA_climo_atm.nc"); die "mv ${caseid}_JJA_${clim_fyr_prnt}06_${clim_lyr_prnt}08_climo.nc failed\n" if $err;
      system("mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc ${prefix}_SON_climo_atm.nc"); die "mv ${caseid}_SON_${clim_fyr_prnt}09_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      system("mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc ${prefix}_MAM_climo_atm.nc"); die "mv ${caseid}_MAM_${clim_fyr_prnt}03_${clim_lyr_prnt}05_climo.nc failed\n" if $err;
      if ($decFlag == 1) {
	  system("mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc ${prefix}_DJF_climo_atm.nc"); die "mv ${caseid}_DJF_${clim_fyrm_prnt}12_${clim_lyr_prnt}02_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc ${prefix}_ANN_climo_atm.nc"); die "mv ${caseid}_ANN_${clim_fyrm_prnt}12_${clim_lyr_prnt}11_climo.nc failed\n" if $err;
      }
      else {
	  system("mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_DJF_climo_atm.nc"); die "mv ${caseid}_DJF_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
	  system("mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc ${prefix}_ANN_climo_atm.nc"); die "mv ${caseid}_ANN_${clim_fyr_prnt}01_${clim_lyr_prnt}12_climo.nc failed\n" if $err;
      }
  }
  
  print(" END  ----  create_climo_atm\n") ;
}

1	# make 'em happy
