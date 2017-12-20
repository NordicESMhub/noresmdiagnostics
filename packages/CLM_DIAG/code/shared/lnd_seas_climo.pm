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

# Note:  There are differences btwn MONS_climo_step1 and SEAS_climo_step1:
#  1.    SEAS_climo files may include the first-year-minus1 December in the long-term climatology.      
#        MONS_climo uses only months from fyr-lyr of the climate period.       


sub create_SEAS_climo_step1
{
  print("     create_SEAS_climo_step1:   ncra over months in climo period year   \[Y=$yr\] to monthly climatology. \n") ;

  # -- Input:  monthly history files over climate period
  # -- Output: monthly averages over climate period. (12 files)
  # --	 Final file:  avgSumFile.<mon>
  # --   Interim file:   sumFile.<mon>
  # -- 1.  subroutine sums all years for a given month. 
  # -- 2.  adjusting for a long term mean by dividing the final file by nyrs.
  # -- 3.  note that the final step tricks ncflint into division by using weights to divide the first file by nyrs,
  # --     and simultaneously create a zeroed file by weighting the second file by 0.0.

  # -- exclude time variables that overrun in flint operation
  # if ($mode eq "clm2") { $atts = "-O -x -v mcdate,mcsec,mdcur,mscur,nstep,pftmask,indxupsc"; }
  if ($mode eq "clm2") { $atts = "-O -x -v ZSOI,DZSOI,WATSAT,SUCSAT,BSW,HKSAT,ZLAKE,DZLAKE,mcdate,mcsec,mdcur,mscur,nstep"; }
  if ($mode eq "cam2") { $atts = "-O -x -v nbdate,date,nsteph"; }
  if ($mode eq "cam")  { $atts = "-O -x -v nbdate,date,nsteph"; }
  if ($mode eq "rtm") { $atts = "-O -x -v fthresh"; }

  #  D/JF --------------------------------------D/JF
  #   /clim_fyr--------------------------clim_lyr/
  # Options:
  #  1.  if dec of previous year (clim_fyr-1) exists, use it to create DJF.  Dec:  fyr-1 thru lyr-1 JanFeb: fyr   thru lyr
  #  2.  else, use JanFeb from year following last year (clim_lyr+1).        Dec:  fyr   thru lyr   JanFeb: fyr+1 thru lyr+1
  #  3.  else, use JanFeb from fyr-lyr and use dec from fyr-lyr inclusive.   Dec:  fyr   thru lyr   JanFeb: fyr thr lyr  **
  #     ** Note:  Times will not be monotonic

  local($yp)  = printYear($clim_fyr);
  local($ym1) = $clim_fyr-1;

  $decYr = $clim_fyr - 1    if ($decFlag == 1);                # use Dec from fyr-1 + JanFeb from fyr
  $decYr = $clim_lyr        if ($decFlag == 2);                # use Dec from last year + JanFeb from following year
  $decYr = $clim_lyr        if ($decFlag == 3);                # use Dec from last year + JanFeb from first year
  $JanFebYr = $clim_fyr     if ($decFlag == 1);                # use JanFeb from same year + Dec from previous year
  $JanFebYr = $clim_lyr + 1 if ($decFlag == 2);                # use JanFeb from following year + Dec from same year
  $JanFebYr = $clim_fyr     if ($decFlag == 3);                # use JanFeb from first year + Dec from last year

  print("decFlag = $decFlag + decYr = $decYr and JanFebYr = $JanFebYr\n");

  print ("mkdir $procDir\/lnd_seas_climoDir\/\n");
  system("mkdir $procDir\/lnd_seas_climoDir\/");
  $lnd_seas_climoDir = $procDir."\/lnd_seas_climoDir\/";

  # Get december for DJF
  $useYr = $decYr; 
  $use_prnt = printYear($useYr);  
  $ifile = $casedir.$caseid.".".$mode.".h0.".$use_prnt."-12.nc";
  print(" grabbing december for year:  $use_prnt\n");
  print(" ln -s $ifile $lnd_seas_climoDir\n");
  $err = system("ln -s $ifile $lnd_seas_climoDir\/.\n");

  # Get Janurary, Feb for DJF
  $useYr = $JanFebYr; 
  $use_prnt = printYear($useYr);  

  print(" grabbing Jan/Feb for year:  $useYr\n");
  $ifile = $casedir.$caseid.".".$mode.".h0.".$use_prnt."-01.nc";
  print(" ln -s $ifile $lnd_seas_climoDir\n");
  $err = system("ln -s $ifile $lnd_seas_climoDir\/.\n");
  
  $ifile = $casedir.$caseid.".".$mode.".h0.".$use_prnt."-02.nc";
  print(" ln -s $ifile $lnd_seas_climoDir\n");
  $err = system("ln -s $ifile $lnd_seas_climoDir\/.\n");
 
  # soft link climo files in proc dir so we can use wildcard ncra
  $ctr=0;
  $yrct = $clim_fyr;
  while ($yrct <= $clim_lyr) {
  	$use_prnt = printYear($yrct);  
	$ifile = $casedir.$caseid.".".$mode.".h0.".$use_prnt."-??.nc";
	print(" ln -s $ifile $lnd_seas_climoDir\n");
	$err = system("ln -s $ifile $lnd_seas_climoDir\/.\n");
	$yrct++;
  }
  # Now remove the last december if I have the PRIOR december for DJF
  # file name of PRIOR december
  if ($decFlag == 1 ) {
  	$useYr = $clim_fyr-1; 
	$use_prior = printYear($useYr);  
  	$priorDec = $lnd_seas_climoDir.$caseid.".".$mode.".h0.".$use_prior."-12.nc";
	print("priorDec = $priorDec\n");

  	# file name of last year december
  	$useYr = $clim_lyr; 
	$use_last = printYear($useYr);  
  	$lastDecember = $lnd_seas_climoDir.$caseid.".".$mode.".h0.".$use_last."-12.nc";
	print("lastDec = $lastDecember\n");

  	if (-e $priorDec) { 
  		print(" Removing  LAST YEAR Dec  for year:  $use_last because PRIOR Dec  exists for year $use_prio\n");
  		print(" rm $lastDecember \n");
  		$err = system("rm $lastDecember \n");
  	}
  }
  # Now remove the first Jan-Feb if I have the Following year for DJF
  if ($decFlag == 2 ) {
  	$useYr = $clim_fyr; 
	$use_prior = printYear($useYr);  
  	$firstJan = $lnd_seas_climoDir.$caseid.".".$mode.".h0.".$use_prior."-01.nc";
  	$firstFeb = $lnd_seas_climoDir.$caseid.".".$mode.".h0.".$use_prior."-02.nc";

  	# file name of following year Jan-Feb
  	$useYr = $clim_lyr+1; 
	$use_last = printYear($useYr);  
  	$lastJan = $lnd_seas_climoDir.$caseid.".".$mode.".h0.".$use_last."-01.nc";
  	$lastFeb = $lnd_seas_climoDir.$caseid.".".$mode.".h0.".$use_last."-02.nc";
	print("lastJan = $lastJan\n");
	print("lastFeb = $lastFeb\n");

  	if (-e $lastJan) { 
  		print(" Removing  first Jan  for year:  $use_prior because following Jan exists for year $use_last\n");
  		print(" rm $firstJan \n");
  		$err = system("rm $firstJan \n");
  	}
  	if (-e $lastFeb) { 
  		print(" Removing  first Feb  for year:  $use_prior because following Feb exists for year $use_last\n");
  		print(" rm $firstFeb \n");
  		$err = system("rm $firstFeb \n");
  	}
  }

  # Create monthly averages
  print("Starting the month list in create_SEAS_climo_step1\n") if $DEBUG;
  foreach $m (@monList) {

        $ifile = $lnd_seas_climoDir.$caseid.".".$mode.".h0.????".$m.".nc";
        $ofile = $procDir.$prefix.".climo".$m.".nc";
	print( "processing $ifile to $ofile\n");
        if ($DEBUG) { print("/usr/local/bin/ncra $atts $ifile $ofile\n"); }
        $err = system("/usr/local/bin/ncra $atts $ifile $ofile\n");  die "ncra climo failed\n" if $err;

        $ctr++;
  }
  print("Ending the month list in create_SEAS_climo_step1\n") if $DEBUG;
  print(" END ----  create_SEAS_climo_step1:   \[Y=$yr\]\n") ;
}

sub create_SEAS_climo_step2
{
  	# -- Input:  averaged monthly files - avgSumFile
  	# -- Output: climatology files  - <seas>_climo
  	# --	 Final file:  <seas>_climo.nc
  	# -- 1.  subroutine averages monthly long term climatologys for each season.
  	# -- 2.  (OPTIONAL) weight by number of days in month.

        print(" start ----  create_SEAS_climo_step2:   \[Y=$yr\]\n") ;
        print("Processing SEASONAL Climo files (Climo) \n");

        if ($mode eq "clm2") {
                $ofileDJF = $prefixDir.$prefix."_DJF_climo.nc";
                $ofileMAM = $prefixDir.$prefix."_MAM_climo.nc";
                $ofileJJA = $prefixDir.$prefix."_JJA_climo.nc";
                $ofileSON = $prefixDir.$prefix."_SON_climo.nc";
        }
        if ($mode eq "cam2") {
                $ofileDJF = $prefixDir.$prefix."_DJF_climo_atm.nc";
                $ofileMAM = $prefixDir.$prefix."_MAM_climo_atm.nc";
                $ofileJJA = $prefixDir.$prefix."_JJA_climo_atm.nc";
                $ofileSON = $prefixDir.$prefix."_SON_climo_atm.nc";
        }
	if ($mode eq "cam") {
                $ofileDJF = $prefixDir.$prefix."_DJF_climo_atm.nc";
                $ofileMAM = $prefixDir.$prefix."_MAM_climo_atm.nc";
                $ofileJJA = $prefixDir.$prefix."_JJA_climo_atm.nc";
                $ofileSON = $prefixDir.$prefix."_SON_climo_atm.nc";
        }
        if ($mode eq "rtm") {
                $ofileDJF = $prefixDir.$prefix."_DJF_climo_rtm.nc";
                $ofileMAM = $prefixDir.$prefix."_MAM_climo_rtm.nc";
                $ofileJJA = $prefixDir.$prefix."_JJA_climo_rtm.nc";
                $ofileSON = $prefixDir.$prefix."_SON_climo_rtm.nc";
        }
	print(" rm -f $ofileDJF") if -e $ofileDJF;
	print(" rm -f $ofileMAM") if -e $ofileMAM;
	print(" rm -f $ofileJJA") if -e $ofileJJA;
	print(" rm -f $ofileSON") if -e $ofileSON;
	system("rm -f $ofileDJF") if -e $ofileDJF;
	system("rm -f $ofileMAM") if -e $ofileMAM;
	system("rm -f $ofileJJA") if -e $ofileJJA;
	system("rm -f $ofileSON") if -e $ofileSON;

        system("/usr/bin/rm -f *.tmp") if -e "*.tmp";

	if ( $weightAnnAvg) {
	   foreach $seas ("DJF","MAM","JJA","SON") {
		if ($seas eq "DJF") { @months = ("-12","-01","-02"); @nd = (31,31,28); $ofile=$ofileDJF;}
		if ($seas eq "MAM") { @months = ("-03","-04","-05"); @nd = (31,30,31); $ofile=$ofileMAM;}
		if ($seas eq "JJA") { @months = ("-06","-07","-08"); @nd = (30,31,31); $ofile=$ofileJJA;}
		if ($seas eq "SON") { @months = ("-09","-10","-11"); @nd = (30,31,30); $ofile=$ofileSON;}

        	$sdays=$ctr=0; 
		foreach $m (@months) {
		
			# Sum the number of days in the season
			$sdays += $nd[$ctr];			
	
			$ifile   = $procDir.$prefix.".climo".$m.".nc"; 
			$out     = $procDir.$prefix.".t1".".nc"; 
			$tmpfile = $procDir.$prefix.".t2".".nc"; 
			if ($ctr == 0) {
                        	system("cp $ifile $tmpfile");
                        	$wt1 = 0.0;
				$atts = "-O -x -v time_written,date_written"; 
                	}
                	else {
                        	system("mv $out $tmpfile");
                        	$wt1 = 1.0;
                        	$atts = "-O ";
                	}
                	$wt2 = $nd[$ctr];
                	$weights = "-w $wt1,$wt2";
                	print("/usr/local/bin/ncflint $atts $weights $tmpfile $ifile $out\n") if $DEBUG; 
                	$err = system("/usr/local/bin/ncflint $atts $weights $tmpfile $ifile $out\n"); die "seasonal ncflint failed \n" if $err;
                	$ctr++;
		}
        	$wt1 = 1./$sdays;		# divide by number of days in the season
		$wt2 = 0.0;
		system("mv $out $tmpfile");
		$weights = "-w $wt1,$wt2";
		print("/usr/local/bin/ncflint $weights $tmpfile $tmpfile $ofile\n") if $DEBUG;
		$err = system("/usr/local/bin/ncflint $weights $tmpfile $tmpfile $ofile");

	   }
	   print(" rm $out $tmpfile\n");
	   system("rm $out $tmpfile");
	}  else {
           $ctr=0; foreach $m ("-12","-01","-02") { @DJF[$ctr] = $procDir.$prefix.".climo".$m.".nc"; $ctr++; }
           $ctr=0; foreach $m ("-03","-04","-05") { @MAM[$ctr] = $procDir.$prefix.".climo".$m.".nc"; $ctr++; }
           $ctr=0; foreach $m ("-06","-07","-08") { @JJA[$ctr] = $procDir.$prefix.".climo".$m.".nc"; $ctr++; }
           $ctr=0; foreach $m ("-09","-10","-11") { @SON[$ctr] = $procDir.$prefix.".climo".$m.".nc"; $ctr++; }

           $flags = "-O -x -v date_written,time_written";

           print("/usr/local/bin/ncra $flags @DJF $ofileDJF\n") if $DEBUG;
           print("/usr/local/bin/ncra $flags @MAM $ofileMAM\n") if $DEBUG;
           print("/usr/local/bin/ncra $flags @JJA $ofileJJA\n") if $DEBUG;
           print("/usr/local/bin/ncra $flags @SON $ofileSON\n") if $DEBUG;

           # $DJF = $procDir.$prefix."_DJF_????.nc";
           # $MAM = $procDir.$prefix."_MAM_????.nc";
           # $JJA = $procDir.$prefix."_JJA_????.nc";
           # $SON = $procDir.$prefix."_SON_????.nc";

           print("/usr/local/bin/ncra $flags @DJF $ofileDJF\n") if $DEBUG;
           print("/usr/local/bin/ncra $flags @MAM $ofileMAM\n") if $DEBUG;
           print("/usr/local/bin/ncra $flags @JJA $ofileJJA\n") if $DEBUG;
           print("/usr/local/bin/ncra $flags @SON $ofileSON\n") if $DEBUG;

           # print("/usr/local/bin/ncra $flags $DJF $ofileDJF\n") if $DEBUG;
           # print("/usr/local/bin/ncra $flags $MAM $ofileMAM\n") if $DEBUG;
           # print("/usr/local/bin/ncra $flags $JJA $ofileJJA\n") if $DEBUG;
           # print("/usr/local/bin/ncra $flags $SON $ofileSON\n") if $DEBUG;

           $err = system("/usr/local/bin/ncra $flags @DJF $ofileDJF"); die "SEAS_climo DJF failed \n" if $err;
           $err = system("/usr/local/bin/ncra $flags @MAM $ofileMAM"); die "SEAS_climo MAM failed \n" if $err;
           $err = system("/usr/local/bin/ncra $flags @JJA $ofileJJA"); die "SEAS_climo JJA failed \n" if $err;
           $err = system("/usr/local/bin/ncra $flags @SON $ofileSON"); die "SEAS_climo SON failed \n" if $err;

           # $err = system("/usr/local/bin/ncra $flags $DJF $ofileDJF"); die "SEAS_climo DJF failed \n" if $err;
           # $err = system("/usr/local/bin/ncra $flags $MAM $ofileMAM"); die "SEAS_climo MAM failed \n" if $err;
           # $err = system("/usr/local/bin/ncra $flags $JJA $ofileJJA"); die "SEAS_climo JJA failed \n" if $err;
           # $err = system("/usr/local/bin/ncra $flags $SON $ofileSON"); die "SEAS_climo SON failed \n" if $err;
       }

       system("/usr/local/bin/ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofileDJF");
       system("/usr/local/bin/ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofileMAM");
       system("/usr/local/bin/ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofileJJA");
       system("/usr/local/bin/ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofileSON");

       system("/usr/local/bin/ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofileDJF");
       system("/usr/local/bin/ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofileMAM");
       system("/usr/local/bin/ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofileJJA");
       system("/usr/local/bin/ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofileSON");

       if ( $weightAnnAvg) 
               { $wtFlag = "\"annual means computed from monthly means with months weighted by number of days in month\""; }
       else    { $wtFlag = "\"annual means computed from monthly means with all months weighted equally\""; }     

       system("/usr/local/bin/ncatted \-O \-a weighted_avg,global,c,c,$wtFlag $ofileDJF");  
       system("/usr/local/bin/ncatted \-O \-a weighted_avg,global,c,c,$wtFlag $ofileMAM");  
       system("/usr/local/bin/ncatted \-O \-a weighted_avg,global,c,c,$wtFlag $ofileJJA");  
       system("/usr/local/bin/ncatted \-O \-a weighted_avg,global,c,c,$wtFlag $ofileSON");  
       # ... nanr 8/24/07
       # Prob:  Landmask is set to 0 by averaging process.  (this only affects set9, but is still misleading.    
       # Soln:  Remove bad landmask and overwrite landmask directly from a history file. 
       if ($mode eq "clm2") { 
		$yr_prnt = printYear($clim_lyr);
                $usefile = $casedir.$caseid.".".$mode.".h0.".$yr_prnt."-01.nc";
                $lmask   = $procDir.$prefix.".lmask.nc";                 
                system("/usr/local/bin/ncks -v landmask $usefile $lmask") if !-e $lmask; 
                system("/usr/local/bin/ncks -q \-A -v landmask $lmask $ofileDJF"); 
                system("/usr/local/bin/ncks -q \-A -v landmask $lmask $ofileMAM"); 
                system("/usr/local/bin/ncks -q \-A -v landmask $lmask $ofileJJA"); 
                system("/usr/local/bin/ncks -q \-A -v landmask $lmask $ofileSON"); 
       }
       print(" END  ----  create_SEAS_climo_step2:   \[Y=$yr\]\n") ;
}

1	# make 'em happy
