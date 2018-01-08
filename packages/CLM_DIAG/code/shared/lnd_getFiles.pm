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

sub getDec
{
	$mydir = `pwd`;
	chdir("$casedir");

        $err = 0;
        local($y) = @_;
        local $yp = printYear($y);
        print("==> Processing getDec  for year=$yp\n") if ($DEBUG);
        print("==> getLocalFlag = $localFlag\n") if ($DEBUG);
        print("==> mss_tarfile = $MSS_tarfile\n") if ($DEBUG);
	if ( $localFlag) { getLocal($yp); }
	else {
          if ($MSS_tarfile == 0) {
        	print("Retrieving Dec \[Y=$yp\] from HPSS -- \n");
        	$filename = $caseid.".".$mode.".h0.".$yp."-12.nc";
        	$err = system("hsi -P \'get $MSS_path\/$filename\' ");
        	print "HPSS file does not exist:  $filename \n\n" if $err;
	  } else {
                if ($y > 0) {
        		print("Retrieving Dec \[Y=$yp\] from HPSS -- \n");
        		$filename = $caseid.".".$mode.".h0.".$yp.".tar";
        		$err = system("hsi -P \'get $MSS_path\/$filename\' ");
			if ($err) { print "HPSS file does not exist:  $filename \n\n"; } 
			else { 
        			system("tar -xvf $filename");
        			system("rm $filename");
			}
                } else { print "HPSS file for year $yp does not exist:  $filename \n\n"; return(-1); }
	   }
	}
        $err = 0;
        $fname = $casedir.$filename;
	chdir("$mydir");
        return(-1)    if !-e $fname || -z $fname;
}
sub getJanFeb
{
	$mydir = `pwd`;
	chdir("$casedir");

        print("==> Processing getJanFeb \n") if ($DEBUG);
        local($yp) = @_;
	if ( $localFlag) { getLocal($yp); }
	else {
          if ($MSS_tarfile == 0) {
        	print("Retrieving JanFeb \[Y=$yp\] from HPSS --  \n");
        	$filename = $caseid.".".$mode.".h0.".$yp;
        	$fname    = $casedir.$caseid.".".$mode.".h0.".$yp."-01.nc";
        	$err = system("hsi -P \'get $MSS_path\/$filename\' ");
        	print "HPSS file does not exist:  $filename \n\n" if $err;
          } else {
        	print("Retrieving JanFeb \[Y=$yp\] from HPSS --  \n");
                $filename = $caseid.".".$mode.".h0.".$yp.".tar";
        	$err = system("hsi -P \'get $MSS_path\/$filename\' ");
                if (!$err) {
                        system("tar -xvf $filename");
        		system("rm $filename");
                 } else { print "HPSS file for year $yp does not exist:  $filename \n\n"; }
           }
	}
        $err = 0;
	chdir("$mydir");
        return(-1)    if !-e $fname || -z $fname;
}
sub getMssYear
{
	$mydir = `pwd`;
	chdir("$casedir");

        local($yp) = @_;
	if ( $localFlag) { getLocal($yp); }
	else {
          if ($MSS_tarfile == 0) {
                print("==> getMssYear: Retrieving year $yp from HPSS -- \n");
                $filename = $caseid.".".$mode.".h0.".$yp;
                print("hsi -P \'prompt; mget $MSS_path\/$filename-{01,02,03,04,05,06,07,08,09,10,11,12}.nc\' \n");
                $err = system("hsi -P \'prompt; mget $MSS_path\/$filename-{01,02,03,04,05,06,07,08,09,10,11,12}.nc\' ");
                print "HPSS file does not exist:  $filename \n\n" if $err;
                $err = 0;
          } else {
                print("==> getMssYear: Retrieving year $yp from HPSS -- \n");
                $filename = $caseid.".".$mode.".h0.".$yp.".tar";
        	$err = system("hsi -P \'get $MSS_path\/$filename\' ");
                if (!$err) {
                        system("tar -xvf $filename");
        		system("rm $filename");
                 } else { print "HPSS file does not exist:  $filename \n\n"; }
           }

	}
        if ( checkMonthlyFiles($yr_prnt) )
        {  die "\n ===>> lnd_preProcess.pl:  \n\n HPSS retrieval Failed.  Check PathName and ReSubmit.  <<======\n"; }
	chdir("$mydir");
}
sub getLocal
{
        local($yp) = @_;
        print("==> copying local year $yp from $localDir --  \n");
        $filename = $caseid.".".$mode.".h0.".$yp;
	if ($local_link == 0) {
        	print(" cp $localDir\/$filename*.nc $casedir\n");
        	$err = system("cp $localDir\/$filename*.nc $casedir\n");
	} elsif ($local_link == 1) {
        	print(" ln -s $localDir\/$caseid*.nc $casedir\n");
        	$err = system("ln -s $localDir\/$caseid*.nc $casedir\/.\n");
	}
        print "local file does not exist:  $filename \n\n" if $err;
}

1	# make 'em happy

