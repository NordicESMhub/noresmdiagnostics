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



sub printYear
{
  local($iyr) = @_;
  if    ($iyr <    10)                { $y = "000".$iyr; }
  elsif ($iyr >=   10 && $iyr <  100) { $y =  "00".$iyr; }
  elsif ($iyr >=  100 && $iyr < 1000) { $y =   "0".$iyr; }
  elsif ($iyr >= 1000)                { $y =       $iyr; }
  return($y);
}

sub checkAnnualFile {
        if ($mode eq "clm2") {
                $annFile = $procDir.$caseid."_annT_".$yr_prnt.".nc";
                return(-1) if !-e $annFile ||  -z $annFile;
        }
        if ($mode eq "cam2") {
                $annFile = $procDir.$caseid."_annT_atm_".$yr_prnt.".nc";
                return(-1) if !-e $annFile ||  -z $annFile;
        }
	if ($mode eq "cam") {
                $annFile = $procDir.$caseid."_annT_atm_".$yr_prnt.".nc";
                return(-1) if !-e $annFile ||  -z $annFile;
        }
        if ($mode eq "rtm") {
                $annFile = $procDir.$caseid."_annT_rtm_".$yr_prnt.".nc";
                return(-1) if !-e $annFile ||  -z $annFile;
        }
}
sub checkAnnualSeasClimoFiles
{
        $flag = 0;
        foreach $season (@seaList2)
        {
                $seaFile = $procDir.$prefix."_".$season."_".$yr_prnt.".nc";
                $flag = -1  if !-e $seaFile ||  -z $seaFile;
        }
        return($flag);
}
sub checkMonthlyFiles
{
  local($yr_prnt) = @_;
  foreach $mon (@monList) {
        $fname = $casedir.$caseid.".".$mode.".h0.".$yr_prnt.$mon.".nc";
        print "  $fname does not exist\n" if !-e $fname || -z $fname;
        return(-1)    if !-e $fname || -z $fname;
  }
}
sub lastJanFeb
{
    local($year) = @_;
    $yp1 = $year+1;
    $yp = printYear($yp1);
    if ( ! checkJanFeb($y) )    { print("FOUND:  Jan+Feb \[Y=$yp\]. \n"); return(0); }
    else        {
        if ( ! getJanFeb($yp) ) { print("FOUND:  Jan+Feb \[Y=$yp\].\n");  return(0);  }
        else {
            if ( ! checkJanFeb($clim_fyr) )
                                { print("NOTE:  Using JanFeb from first climo year \[Y=$clim_fyr\]\n"); }
            else                { print("NOT FOUND:  JanFeb \[Y=$yp\] \n");  return(-1); }
            # else              { die "\n ===>> FILE NOT FOUND.  Check climate period and restart.<<====\n"; }
        }
    }
}
sub firstDec
{
    local($y) = @_;
    local($ym1) = $y-1;
    print("==> Processing firstDec for year=$y and ym1=$ym1\n") if ($DEBUG);
    if (      ! &checkDec($ym1) )   { print("FOUND:  Dec     \[Y=$ym1\].\n"); return(0); }
    else { if ( ! &getDec($ym1) )   { print("FOUND:  Dec     \[Y=$ym1\] \n"); return(0); }
           else                     { print("NOT FOUND:  Dec \[Y=$ym1\] \n");  return(-1); }
    }
}
sub checkDec
{
        local ($y) = @_;
        $yp = printYear($y);
        $fname = $casedir.$caseid.".".$mode.".h0.".$yp."-12.nc";
        print("==> Processing checkDec for year=$yp (fname=$fname)\n") if ($DEBUG);
        print "  $fname does not exist\n" if !-e $fname || -z $fname;
        return(-1)    if !-e $fname || -z $fname;
}
sub checkJanFeb
{
        print("==> Processing checkJanFeb \n") if ($DEBUG);
        local($yp) = @_;
        $fname = $casedir.$caseid.".".$mode.".h0.".$yp."-01.nc";
        print "  $fname does not exist\n" if !-e $fname || -z $fname;
        return(-1)    if !-e $fname || -z $fname;
}

sub initialFileCheck {
 if ($t eq "climo") {
#        $fname = "Climo";
        foreach $f (@reqFileListClimo) {
                if ($mode eq "clm2") { $file = $prefixDir.$prefix.$f.".nc"; }
                if ($mode eq "cam2") { $file = $prefixDir.$prefix.$f."_atm.nc"; }
                if ($mode eq "cam")  { $file = $prefixDir.$prefix.$f."_atm.nc"; }
                if ($mode eq "rtm")  { $file = $prefixDir.$prefix.$f."_rtm.nc"; }
                print("Found: $f\n") if -e $file;
                if (-e $file && $runClimo) { $runClimo = 0; }
#                        die "\n\n==> $t Files exist.  To overwrite $f set overWrite$fname to 1 in Runscript and restart.\n"; }
        }
 }
 if ($t eq "means") {
#        $fname = "Climo";
        foreach $f (@reqFileListMeans) {
                if ($mode eq "clm2") { $file = $prefixDir.$prefix.$f.".nc"; }
                if ($mode eq "cam2") { $file = $prefixDir.$prefix.$f."_atm.nc"; }
                if ($mode eq "cam")  { $file = $prefixDir.$prefix.$f."_atm.nc"; }
                if ($mode eq "rtm")  { $file = $prefixDir.$prefix.$f."_rtm.nc"; }
                print("Found: $f\n") if -e $file;
                if (-e $file && $meansFlag) { $meansFlag = 0; }
#                        die "\n\n==> $t Files exist.  To overwrite $f set overWrite$fname to 1 in Runscript and restart.\n"; }
        }
 }
 if ($t eq "trends") {
#        $fname = "Trend";
        foreach $f (@reqFileListTrends) {
                if ($mode eq "clm2") { $file = $prefixDir.$prefix.$f.".nc"; }
                if ($mode eq "cam2") { $file = $prefixDir.$prefix.$f."_atm.nc"; }
                if ($mode eq "cam")  { $file = $prefixDir.$prefix.$f."_atm.nc"; }
                if ($mode eq "rtm")  { $file = $prefixDir.$prefix.$f."_rtm.nc"; }
                print("Found: $f\n") if -e $file;
                if (-e $file && $runTrends) { $runTrends = 0; }
#                        die "\n\n==> $fname Files exist.  To overwrite $f set overWrite$fname to 1 in Runscript and restart.\n"; }
        }
 }
}
sub finalCheck {
  if ( $runClimo) {
      if ($meansFlag && $mode eq "clm2") {
	  foreach $f (@reqFileListMeans) {
	      $file = $prefixDir.$prefix.$f.".nc";
	      $num = $castCtr+1;
	      $flag = "climo_".$num;
	      if (! -e $file && flag) {
		  die "\n\n==> Required post-processed file: $f does not exist\n    Set $flag to 1 in Runscript and restart.\n"; }
	      else { print("Found: $mode - $f\n"); }
	  }
      }
      foreach $f (@reqFileListClimo) {
	  if ($mode eq "clm2") { $file = $prefixDir.$prefix.$f.".nc"; }
	  if ($mode eq "cam2") { $file = $prefixDir.$prefix.$f."_atm.nc"; }
	  if ($mode eq "cam")  { $file = $prefixDir.$prefix.$f."_atm.nc"; }
	  if ($mode eq "rtm")  { $file = $prefixDir.$prefix.$f."_rtm.nc"; }
	  $num = $castCtr+1;
	  $flag = "climo_".$num;
	  if (! -e $file && flag) {
	      die "\n\n==> Required post-processed file: $f does not exist\n    Set $flag to 1 in Runscript and restart.\n"; }
	  else { print("Found: $mode - $f\n"); }
      }
  }
  if ( $runTrends ) {
    foreach $f (@reqFileListTrends) {
        if ($mode eq "clm2") { $file = $prefixDir.$prefix.$f.".nc"; }
        if ($mode eq "cam2") { $file = $prefixDir.$prefix.$f."_atm.nc"; }
        if ($mode eq "cam")  { $file = $prefixDir.$prefix.$f."_atm.nc"; }
        if ($mode eq "rtm")  { $file = $prefixDir.$prefix.$f."_rtm.nc"; }
        $num = $castCtr+1;
        $flag = "trends_".$num;
        if (! -e $file && flag) {
           die "\n\n==> Required post-processed file: $f does not exist\n    Set $flag to 1 in Runscript and restart.\n"; }
        else { print("Found: $mode - $f\n"); }
    }
  }
}
1	# make 'em happy

