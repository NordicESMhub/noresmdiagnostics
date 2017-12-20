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


sub createAnnualFile
{
	print("  Start ---------- createAnnualFile --------\n");
        if ( $weightAnnAvg) {
           print("    $yr_prnt TIME WEIGHTED AVERAGE\n") if $DEBUG;
           $ifile   = $casedir.$caseid.".".$mode.".h0.".$yr_prnt."-01.nc";
           $ofile   = $procDir.$prefix."_".$yr_prnt."_annFile.nc";
           $tmpfile = $procDir.$prefix."_".$yr_prnt."_atmp.nc";
           $ctr=0;
           foreach $m (@monList) {
                $ifile   = $casedir.$caseid.".".$mode.".h0.".$yr_prnt.$m.".nc";
                if ($m eq "-01") {
                        system("cp $ifile $tmpfile");
                        $wt1 = 0.0;
                        if ($mode eq "clm2") { $atts = "-O -x -v ZSOI,DZSOI,WATSAT,SUCSAT,BSW,HKSAT,ZLAKE,DZLAKE,time_written,date_written,time_bounds,mcdate,mcsec,mdcur,nstep"; }
                        if ($mode eq "cam2") { $atts = "-O -x -v time_written,date_written,nbdate,date,nsteph"; }
                        if ($mode eq "rtm")  { $atts = "-O -x -v time_written,date_written,fthresh"; }
                }
                else {
                        system("mv $ofile $tmpfile");
                        $wt1 = 1.0;
                        $atts = "-O ";
                }
                $wt2 = @ndays[$ctr];
                $weights = "-w $wt1,$wt2";
                $err = system("ncflint $atts $weights $tmpfile $ifile $ofile\n");   die "annT ncflint failed \n" if $err;
                $ctr++;
           }
           $wt1 = 1/365.;       # divide by 365 days to get annual average
           $wt2 = 0.0;
           system("mv $ofile $tmpfile");
           if ($mode eq "clm2") { $ofile = $casedir.$caseid."_annT_".$yr_prnt.".nc";     }
           if ($mode eq "cam2") { $ofile = $casedir.$caseid."_annT_atm_".$yr_prnt.".nc"; }
           if ($mode eq "rtm")  { $ofile = $casedir.$caseid."_annT_rtm_".$yr_prnt.".nc"; }
           $weights = "-w $wt1,$wt2";
           print("ncflint $weights $tmpfile $tmpfile $ofile\n");
           $err = system("ncflint $weights $tmpfile $tmpfile $ofile\n");
        }
        else {
                print("    $yr_prnt SIMPLE TIME AVERAGE\n") if $DEBUG;
                $ifile = $casedir.$caseid.".".$mode.".h0.".$yr_prnt."-01.nc";
                if ($mode eq "clm2") { 
			$atts = "-O -x -v ZSOI,DZSOI,WATSAT,SUCSAT,BSW,HKSAT,ZLAKE,DZLAKE,time_written,date_written,time_bounds,mcdate,mcsec,mdcur,nstep"; 
			$ofile = $casedir.$caseid."_annT_".$yr_prnt.".nc";     
		}
                if ($mode eq "cam2") { 
			$ofile = $casedir.$caseid."_annT_atm_".$yr_prnt.".nc"; 
			$atts = "-O -x -v time_written,date_written,nbdate,date,nsteph"; 
		}
                if ($mode eq "rtm") { 
                       $ofile = $casedir.$caseid."_annT_rtm_".$yr_prnt.".nc"; 
                       $atts = "-O -x -v time_written,date_written,fthresh"; 
                }
                print(" ncra $atts \-n 12,2,1 $ifile $ofile\n") if $DEBUG;
                $err = system("ncra $atts \-n 12,2,1 $ifile $ofile\n"); die "ncra failed \n" if $err;
        }
	# ... nanr 8/24/07
	# Prob:  Landmask is set to 0 by averaging process.  (this only affects set9, but is still misleading.
        # Soln:  Remove bad landmask and overwrite landmask directly from a history file.
        if ($mode eq "clm2") { 
                $usefile = $casedir.$caseid.".".$mode.".h0.".$yr_prnt."-01.nc";
               	$lmask   = $procDir.$prefix.".lmask.nc";                 
		system("ncks -v landmask $usefile $lmask") if !-e $lmask; 
		system("ncks -q \-A -v landmask $lmask $ofile"); 
	}
	print("  END  ---------- createAnnualFile --------\n");
}
sub create_ANN_ALL
{
        print("start -------- create_ANN_ALL\n") if $DEBUG;
        print("Processing ANN_ALL (Trends)\n") if $DEBUG;

        if ($mode eq "clm2") {
                $ifile = $casedir.$caseid."_annT_".$trends_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_ALL.nc";
        }
        if ($mode eq "cam2") {
                $ifile = $casedir.$caseid."_annT_atm_".$trends_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_ALL_atm.nc";
        }
        if ($mode eq "rtm") {
                $ifile = $casedir.$caseid."_annT_rtm_".$trends_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_ALL_rtm.nc";
        }
        print("ncrcat -\O \-n $trends_nyr,4,1 $ifile $ofile\n") if $DEBUG;
        $err = system("ncrcat  -\O \-n $trends_nyr,4,1 $ifile $ofile");  die "ANN_ALL ncrcat failed \n" if $err;
        system("ncatted \-O \-a yrs_averaged,global,c,c,$trends_range $ofile");
        system("ncatted \-O \-a num_yrs_averaged,global,c,i,$trends_nyr $ofile");
        print("END -------- create_ANN_ALL\n") if $DEBUG;
}

sub create_ANN_climo
{
        print("Processing ANN_climo (Climo) $mode $casedir \n") if $DEBUG;

        system("/usr/bin/rm -f *.tmp") if (-e "*.tmp");

        $ctr=0;
        local @ifiles;
        chdir("$casedir");

        if ($mode eq "clm2") {
                $ifile = $casedir.$caseid."_annT_".$clim_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_climo.nc";
        }
        if ($mode eq "cam2") {
                $ifile = $casedir.$caseid."_annT_atm_".$clim_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_climo_atm.nc";
        }
        if ($mode eq "rtm") {
                $ifile = $casedir.$caseid."_annT_rtm_".$clim_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_climo_rtm.nc";
        }
        print("ncra -\O \-n $clim_nyr,4,1 $ifile $ofile\n") if $DEBUG;
        $err = system("ncra -\O \-n $clim_nyr,4,1 $ifile $ofile"); die "ANN_climo ncra failed\n" if $err;

        system("ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofile");
        system("ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofile");
        chdir("$prefixDir");
}
sub create_ANN_means
{
        print("Processing ANN_means (Climo)\n");

        chdir("$casedir");
        system("/usr/bin/rm -f *.tmp") if (-e "*.tmp");

        if ($mode eq "clm2") {
                $ifile = $casedir.$caseid."_annT_".$clim_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_means.nc";
        }
        if ($mode eq "cam2") {
                $ifile = $casedir.$caseid."_annT_atm_".$clim_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_means_atm.nc";
        }
        if ($mode eq "rtm") {
                $ifile = $casedir.$caseid."_annT_rtm_".$clim_fyr_prnt.".nc";
                $ofile = $prefixDir.$prefix."_ANN_means_rtm.nc";
        }
        print("ncrcat -\O \-n $clim_nyr,4,1 $ifile $ofile\n") if $DEBUG;
        $err = system("ncrcat -\O \-n $clim_nyr,4,1 $ifile $ofile");  die "ANN_means ncrcat failed \n" if $err;

        system("ncatted \-O \-a yrs_averaged,global,c,c,$clim_range $ofile");
        system("ncatted \-O \-a num_yrs_averaged,global,c,i,$clim_nyr $ofile");

        if ( $weightAnnAvg) 
                { $wtFlag = "\"annual means computed from monthly means with months weighted by number of days in month\""; }
        else    { $wtFlag = "\"annual means computed from monthly means with all months weighted equally\""; }     

        system("ncatted \-O \-a weighted_avg,global,c,c,$wtFlag $ofile");  

        chdir("$prefixDir");
}

1	# to make use and require happy.
