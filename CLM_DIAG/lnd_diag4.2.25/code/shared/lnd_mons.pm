#!/usr/bin/perl

# written by Nan Rosenbloom
# December 2006

$share_code = $ENV{'DIAG_SHARED'};   
use lib '$share_code'; 

use lnd_ann;
use lnd_util;
use lnd_getFiles;
use lnd_mons;
use lnd_seas_climo;
use lnd_seas_means;


sub create_MONS_climo_step2
{
        print(" START ------create_MONS_climo_step2 \n");
        print("Processing MONS climo (Climo) - Step 2\n");

	print ("mkdir $procDir\/lnd_monsDir\/\n");
	system("mkdir $procDir\/lnd_monsDir\/");
	$lnd_monsDir = $procDir."\/lnd_monsDir\/";

   	# soft link climo files in proc dir so we can use wildcard ncra
   	$ctr=0;
   	$yrct = $clim_fyr;
   	while ($yrct <= $clim_lyr) {
       		$use_prnt = printYear($yrct);
       		$ifile = $casedir.$caseid.".".$mode.".h0.".$use_prnt."-??.nc";
       		print(" ln -s $ifile $lnd_monsDir\n");
       		$err = system("ln -s $ifile $lnd_monsDir\/.\n");
       		$yrct++;
    	}


  # -- exclude time variables that overrun in flint operation
  #     if ($mode eq "clm2") { $atts = "-O -x -v mcdate,mcsec,mdcur,mscur,nstep,pftmask,indxupsc"; }
        if ($mode eq "clm2") { $atts = "-O -x -v ZSOI,DZSOI,WATSAT,SUCSAT,BSW,HKSAT,ZLAKE,DZLAKE,mcdate,mcsec,mdcur,mscur,nstep"; }
        if ($mode eq "cam2") { $atts = "-O -x -v nbdate,date,nsteph"; }
        if ($mode eq "cam")  { $atts = "-O -x -v nbdate,date,nsteph"; }


  	# Create monthly averages
  	print("Starting the month list in create_SEAS_climo_step1\n") if $DEBUG;
  	foreach $m (@monList) {
  
         	$ifile = $lnd_monsDir.$caseid.".".$mode.".h0.????".$m.".nc";
         	$ofile = $lnd_monsDir.$prefix.".climo".$m.".nc";
         	print( "processing $ifile to $ofile\n");
         	if ($DEBUG) { print("/usr/local/bin/ncra $atts $ifile $ofile\n"); }
         	$err = system("/usr/local/bin/ncra $atts $ifile $ofile\n");  die "ncra climo failed\n" if $err;

         	$ctr++;
  	}

        $ifile = $lnd_monsDir.$prefix.".climo-??.nc";
        if ($mode eq "clm2") { $ofile = $prefixDir.$prefix."_MONS_climo.nc"; }
        if ($mode eq "cam2") { $ofile = $prefixDir.$prefix."_MONS_climo_atm.nc"; }
        if ($mode eq "cam")  { $ofile = $prefixDir.$prefix."_MONS_climo_atm.nc"; }
        if ($mode eq "rtm")  { $ofile = $prefixDir.$prefix."_MONS_climo_rtm.nc"; }

        print("/usr/local/bin/ncrcat \-O  $ifile $ofile\n") if $DEBUG;
        $err = system("/usr/local/bin/ncrcat \-O  $ifile $ofile");  die "MONS_climo ncrcat failed \n" if $err;
        system("/usr/local/bin/ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofile");
        system("/usr/local/bin/ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofile");
        print(" Cleaning up $lnd_monsDir directory\n");
        print(" rm -r $lnd_monsDir\n");
	system("rm -r $lnd_monsDir");
        print(" END  ------create_MONS_climo_step2 \n");
}

1
