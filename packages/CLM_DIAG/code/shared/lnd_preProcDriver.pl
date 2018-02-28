#!/usr/bin/perl

# written by Nan Rosenbloom
# June 2006
# Usage:  called by /code/lnd_driver.csh to retrieve all required files
# and preprocess them for diagnostics package.  Combines and replaces 
# lnd_retrieve*, lnd_netcdf*, and lnd_climo*

# Usage:  1 = ON; 0 = OFF

# Updated by Johan Liakka, NERSC, Nov 2017

$share_code =    $ENV{'DIAG_SHARED'};

@INC = (@INC,".",$share_code);

require lnd_ann;
require lnd_util;
require lnd_getFiles;
require lnd_mons;
require lnd_seas_climo;
require lnd_seas_means;
require compute_climo;

# -------------------------------
#  Developer Preferences:
# -------------------------------

$DEBUG = 1;		# ON=1; OFF=0 Turn on verbose messages.

# -------------------------------
# Environment variables:
# -------------------------------

  &getEnvironmentVariables();

# -------------------------------
# define arrays
# -------------------------------
  @modeList = ("clm2","cam2","mrt");
  @monList  = ("-01","-02","-03","-04","-05","-06","-07","-08","-09","-10","-11","-12");
  @monList2 = ("01","02","03","04","05","06","07","08","09","10","11","12");
  @monList3 = ("01","02","03","04","05","06","07","08","09","10","11");
  @ndays    = (  31,   28,   31,   30,   31,   30,   31,   31,   30,   31,   30,   31);
  @seaList  = ("DJF","MAM","JJA","SON");
  @seaList2 = ("DJF","MAM","JJA","SON","ANN");
  @reqFileListClimo  = ( "_ANN_climo","_DJF_climo","_MAM_climo",
                         "_JJA_climo","_SON_climo","_MONS_climo");
  @reqFileListMeans  = ( "_ANN_means","_DJF_means",
                         "_MAM_means","_JJA_means","_SON_means");
  @reqFileListTrends = ( "_ANN_ALL" );

  if ($runtype eq "model-obs") { 
  	@caseList   = ($caseid_1);
  	@prefList   = ($prefix_1);
  	@prefListB  = ($bran_1_prefix);
  	@branPath   = ($bran_1_path);
        @locDir     = ($local1_dir,  $local1_atm_dir,  $local1_rtm_dir);
        @locFlag    = ($localFlag1,  $localFlag1_atm,  $localFlag1_rtm);
        @caseDir    = ($case_1_dir,  $case_1_atm_dir,  $case_1_rtm_dir);
        @prefDir    = ($pref_1_dir,  $pref_1_atm_dir,  $pref_1_rtm_dir);
        @prefDirB   = ($bran_1_dir,  $bran_1_atm_dir,  $bran_1_rtm_dir);
  	@climo      = ($clim_first_yr_1);
  	@trends     = ($trends_first_yr_1);
  	@nclimo     = ($clim_num_yrs_1);
  	@ntrends    = ($trends_num_yrs_1);
        @MSS_tar    = ($MSS_tarfile_1);
        @MSS        = ($MSS_path_1,  $MSS_path_atm_1,  $MSS_path_rtm_1);
        @createTrends = ($trends_1,  $trends_atm_1,    $trends_rtm_1);
        @createClimo  = ($climo_1,   $climo_atm_1,     $climo_rtm_1);
	@camNames   = ($camname1);
	@varList    = ($var_list_1);
  } else { 
  	@caseList   = ($caseid_1, $caseid_2);
  	@prefList   = ($prefix_1, $prefix_2);
  	@prefListB  = ($bran_1_prefix,     $bran_2_prefix);
  	@branPath   = ($bran_1_path,       $bran_2_path);
  	@climo      = ($clim_first_yr_1,   $clim_first_yr_2);
  	@trends     = ($trends_first_yr_1, $trends_first_yr_2);
  	@nclimo     = ($clim_num_yrs_1,    $clim_num_yrs_2);
  	@ntrends    = ($trends_num_yrs_1,  $trends_num_yrs_2);
        @locDir     = ($local1_dir,        $local1_atm_dir, $local1_rtm_dir, $local2_dir, $local2_atm_dir, $local2_rtm_dir);
        @locFlag    = ($localFlag1,        $localFlag1_atm, $localFlag1_rtm, $localFlag2, $localFlag2_atm, $localFlag2_rtm);
        @caseDir    = ($case_1_dir,        $case_1_atm_dir, $case_1_rtm_dir, $case_2_dir, $case_2_atm_dir, $case_2_rtm_dir);
        @prefDir    = ($pref_1_dir,        $pref_1_atm_dir, $pref_1_rtm_dir, $pref_2_dir, $pref_2_atm_dir, $pref_2_rtm_dir);
        @prefDirB   = ($bran_1_dir,        $bran_1_atm_dir, $bran_1_rtm_dir, $bran_2_dir, $bran_2_atm_dir, $bran_2_rtm_dir);
        @MSS_tar    = ($MSS_tarfile_1,	   $MSS_tarfile_2);
        @MSS        = ($MSS_path_1,        $MSS_path_atm_1, $MSS_path_rtm_1, $MSS_path_2, $MSS_path_atm_2, $MSS_path_rtm_2);
        @createTrends   = ($trends_1,      $trends_atm_1,   $trends_rtm_1,   $trends_2,   $trends_atm_2,   $trends_rtm_2);
        @createClimo    = ($climo_1,       $climo_atm_1,    $climo_rtm_1,    $climo_2,    $climo_atm_2,    $climo_rtm_2);
	@camNames   = ($camname1, $camname2);
	@varList    = ($var_list_1, $var_list_2);
  }

$modeCtr=0;
$caseCtr=0;

# --------------------------------
foreach $case (@caseList) 			# Case loop (caseid1 + caseid2)
# --------------------------------
{
   @modeList = ("clm2",@camNames[$caseCtr],"mrt");
   # --------------------------------
   foreach $mode (@modeList) 			# Mode loop (clm2 + cam2 + rtm)
   # --------------------------------
   {
      print("\nProcessing Case $caseCtr \[$prefList[$caseCtr]\] $mode files. \n");

      $casedir     = @caseDir[  $modeCtr];
      $localDir    = @locDir[   $modeCtr];
      $localFlag   = @locFlag[   $modeCtr];
      $prefixDir   = @prefDir[  $modeCtr];
      $prefixDirB  = @prefDirB[ $modeCtr];

      $procDir	   = $prefixDir."proc/";
      $procDirB	   = $prefixDirB."/proc/";

      $caseid      = @caseList[ $caseCtr];
      $prefix      = @prefList[ $caseCtr];
      $prefixB     = @prefListB[$caseCtr];
      $pathB       = @branPath[ $caseCtr];
      $MSS_tarfile = @MSS_tar[  $caseCtr];
      $MSS_path    = @MSS[     $modeCtr];
      $runTrends   = @createTrends[$modeCtr];
      $runClimo    = @createClimo[ $modeCtr];
      $var_list    = @varList[$caseCtr];
      
      $trends_fyr      = @trends[ $caseCtr];
      $trends_nyr      = @ntrends[$caseCtr];
      $trends_lyr      = ($trends_fyr + $trends_nyr) - 1;
      $trends_range    = $trends_fyr."-".$trends_lyr;
      $trends_fyr_prnt = printYear($trends_fyr);

      $clim_fyr      = @climo[$caseCtr];
      $clim_nyr      = @nclimo[$caseCtr];
      $clim_lyr      = ($clim_fyr + $clim_nyr) - 1;
      $clim_range    = $clim_fyr."-".$clim_lyr;
      $clim_fyr_prnt = printYear($clim_fyr);
      $clim_lyr_prnt = printYear($clim_lyr);
      $clim_fyrm_prnt = printYear($clim_fyr-1);
      $clim_lyrm_prnt = printYear($clim_lyr-1);

      $decFlag = 0;

      # Check which climatologies/trends need to be computed (JL, Nov 2017)
      $runTrends = 0;
      $runClimo = 0;
      $meansFlag = 0;
      if ( $mode eq "clm2" ) {
	  if ($set_1 || $set_6) {
	      $runTrends = 1;
	      $t = "trends";
	      &initialFileCheck($t) if !$overWriteTrend;
	  }
	  if ($set_2 || $set_3 || $set_5 || $set_9) {
	      $runClimo = 1;
	      $t = "climo";
	      &initialFileCheck($t) if !$overWriteClimo;
	  }
	  if ($set_2 || $set_9) {
	      if ($runtype eq "model1-model2") {
		  #		  $meansFlag = 1;
		  $meansFlag = 0;
		  $t = "means";
		  &initialFileCheck($t) if !$overWriteMeans;
	      }
	  }
      }
      if ( $mode eq "cam" || $mode eq "cam2" ) {
	  if ($set_4) {
	      $runClimo = 1;
	      $t = "climo";
	      &initialFileCheck($t) if !$overWriteClimo;
	  }
      }

      # Summarize
      print("----------------------------------------------\n");
      print("SUMMARY ($case, $mode):\n");
      print("----------------------------------------------\n");
      print(" runTrends = $runTrends\n");
      print(" runClimo  = $runClimo\n");
      print(" meansFlag = $meansFlag\n\n");

      # -------------
      # -- Main Loop
      # -------------
      if    ( $local_link && (!$runTrends || !$runClimo) ) { &getLocal; }

      # --------------------------------------------------------------------------------
      if ( $runTrends) { print("\nCreating $mode trends for years: $trends_fyr - $trends_lyr \n\n");    
      # --------------------------------------------------------------------------------

#         $t = "trends";
#	 &initialFileCheck($t) if !$overWriteTrend;	# 1=ON
			 
         foreach $yr ($trends_fyr .. $trends_lyr) {

                # -- translate model year into 4 digit character.
                $yr_prnt = printYear($yr);
		print("\nProcessing trends for \[$prefList[$caseCtr]\] $mode files. yr = \[$yr_prnt\]\n");
  
                # -- Annual Files:  check for annual files.
                #    Retrieve monthly files if necessary.
                #    Create annual file if necessary.
  
                # -- Create Annual trend files
                if ( ! checkAnnualFile() ) { print("FOUND:      Annual file  \[Y=$yr\] .. \n") }
                else {
                   if ( ! checkMonthlyFiles($yr_prnt) ) {
                              print("FOUND:  Climatology files \[Y=$yr_prnt\] .. Creating $mode annual files.\n");
                   }
                   else       { &getMssYear($yr_prnt); }
  
                   &createAnnualFileNew();
                }
                if ( $rmTrendFlag  ) { $buffer = 0;  &rmMonthlyFiles(); }  # 0=ON

         }      # end trends year loop


         &create_ANN_ALL()    if !-e $ann_all_file;  # trends - concatenation of annual avg files   (nvalues =     nyrs)

      }

      # --------------------------------------------------------------------------------
      if ( $runClimo) {	print("\nCreating $mode climo for years: $clim_fyr - $clim_lyr\n\n");	# 0=ON }
      # --------------------------------------------------------------------------------

	 # ------------------------------
         # Check for existing files
	 # ------------------------------
#	 $t = "climo";
#         &initialFileCheck($t) if !$overWriteClimo;  	# 1=ON
   
         for ($yr = $clim_fyr; $yr <= $clim_lyr; $yr++) {

  	   	# -- translate model year into 4 digit character.
  	   	$yr_prnt = printYear($yr);
		print("\nProcessing climo for \[$prefList[$caseCtr]\] - $mode files. yr = \[$yr_prnt\]\n");

		# -- Retrieve first Dec or Last Jan+Feb for DJF averaging.  If the climatology for the full run 
		#    length is desired (e.g., run years = 1-50, and climo period = 1-50) then all 50 decembers (inclusive)
		#    are used for averaging (assuming the run starts in year1 and ends in year50).
		# 
		$ym1 = $clim_fyr-1;
		$yp1 = $clim_lyr+1;
		if ($yr == $clim_fyr) { 
			print("\nLooking for DJF Files\n\n");
			if ( ! firstDec($yr) ) { print("\nNOTE:\tDJF uses Dec of previous year \[Y=$ym1\].  \n");        
							   $decFlag = 1;	# 1 = Dec of previous year
			}
		        else  { 
#			   if (! lastJanFeb($clim_lyr) ) { print("\nNOTE:\tDJF uses JanFeb of following year for DJF \[Y=$yp1\].  \n");
#							   $decFlag = 2;	# 2 = JanFeb of last_year + 1
#			   } 
			   print("\nNOTE:\tDJF uses Dec ($clim_lyr) + JanFeb ($clim_fyr)\n");      
			   $decFlag = 3;	# 3 = wrapMonths
			   print("\n\nNOTE:  TIMES MAY NOT INCREASE MONOTONICALLY \n\n"); 
			}
		}

                if ( ! checkMonthlyFiles($yr_prnt) ) { print("FOUND:      Monthly files \[Y=$yr\]\n"); }
                else                                 { print("NOT FOUND:  Monthly files \[Y=$yr\]\n");  &getMssYear($yr_prnt); }

         }  	# End climo years loop

         # -- Create Annual seasonal files nanr-4.2-swift
  	 # -- add the monthly records to a running total.
#	 if ($yr >= $clim_fyr) { &create_SEAS_climo_step1(); }
#         &create_ANN_climo();          # ann avg across climo years		        (nvalues =        1)
#         &create_SEAS_climo_step2();   # seasonal average for climo years	        (nvalues =        1)
#         &create_MONS_climo_step2();   # monthly avg for climo years		        (nvalues =       12)
	 if ($mode eq "clm2") { &create_climo(); }
 	 else { &create_climo_atm(); }
	 # nanr-4.2-swift
  	 # -- Remove monthly history files to save space
	 if ($rmClimoFlag ) { $buffer = 2;  &rmMonthlyFiles(); }	
	
      }

      if ($meansFlag && $mode eq "clm2") {
	  for ($yr = $clim_fyr; $yr <= $clim_lyr; $yr++) {
  	      $yr_prnt = printYear($yr);
	      print("\nProcessing means for \[$prefList[$caseCtr]\] - $mode files. yr = \[$yr_prnt\]\n");
	      $ym1 = $clim_fyr-1;
	      $yp1 = $clim_lyr+1;
	      if ($yr == $clim_fyr) { 
		  if ( ! firstDec($yr) ) { 
		      print("\nNOTE:\tDJF uses Dec of previous year \[Y=$ym1\].  \n");        
		      $decFlag = 1;	# 1 = Dec of previous year
		  }
		  else  { 
		      print("\nNOTE:\tDJF uses Dec ($clim_lyr) + JanFeb ($clim_fyr)\n");      
		      $decFlag = 3;	# 3 = wrapMonths
		      print("\n\nNOTE:  TIMES MAY NOT INCREASE MONOTONICALLY \n\n"); 
		  }
	      }
	      if ( ! checkAnnualSeasClimoFiles() ) { print("FOUND: Seasonal file  \[Y=$yr\] .. \n") }
	      else {
		  if ( ! checkMonthlyFiles($yr_prnt) ) {
		      print("FOUND:  Climatology files \[Y=$yr_prnt\] .. Creating $mode annual files.\n");
		  }
		  else       { &getMssYear($yr_prnt); }
		  &create_SEAS_means_step1_new($yr);
	      }      # end climo year loop
	  }			
#	  &create_ANN_means();          # trends - concat annual avgs for climo period  (nvalues = nclimyrs)  
	  &create_SEAS_means_step2(); # trends - concat seasonal avg for climo period (nvalues = nclimyrs)
      }
      # --------------------------------------------------------------------------------
	
       &finalCheck;
       &cleanUp;

       $modeCtr++;
    }		# End Mode Loop
    $caseCtr++;

}	# End Case Loop

$errorFile = $wkdir."/preProc_error_file";
system("rm $errorFile");

# clean up the rest

&cleanAll;

$modeCtr=$caseCtr=0;
if($deleteProcDir) { 
	foreach    $case (@caseList) { 
	   foreach $mode (@modeList) {
      		$prefixDir = @prefDir[  $modeCtr];
      		$procDir   = $prefixDir."proc/";
		print("Removing processing directory: $procDir\n"); 
		system("rm -rf $procDir"); 
       		$modeCtr++;
	   }
    	   $caseCtr++;
        }
}


# -- End main loop ---------------------------------------------------------------------------

sub printYear 
{
  local($iyr) = @_;
  if    ($iyr <    10) 		      { $y = "000".$iyr; }
  elsif ($iyr >=   10 && $iyr <  100) { $y =  "00".$iyr; }
  elsif ($iyr >=  100 && $iyr < 1000) { $y =   "0".$iyr; }
  elsif ($iyr >= 1000) 		      { $y =       $iyr; }
  return($y);
}
sub rmMonthlyFiles() { 
	$rm_yr = $yr-$buffer;			# retain buffer of 1 year for DJF.
	$rm_prnt = printYear($rm_yr);
	$ym1 = $clim_fyr-1;
	$yp1 = $clim_lyr+1;
	$safe = $casedir;
	if ($rm_yr == $ym1) { 
		foreach $m (@monList) {
		    if ($m ne "-12") { 
			$fn = $casedir.$caseid.".".$mode.".h0.".$rm_prnt.$m.".nc";  
			system("rm -f $fn")       if -e $fn; 
		    }
		}
	}
	elsif ($rm_yr == $yp1) { 
		foreach $m (@monList) {
		    if ($m ne "-01" && $m ne "-02" ) { 
			$fn = $casedir.$caseid.".".$mode.".h0.".$rm_prnt.$m.".nc";  
			system("rm -f $fn")       if -e $fn; 
		    }
		}
	}
	else {
		$fn6 = $casedir.$caseid.".".$mode.".h0.".$rm_prnt."-06.nc";  
		$fn  = $casedir.$caseid.".".$mode.".h0.".$rm_prnt."-*.nc";  
        	print("Removing monthly History Files for yr:  $rm_prnt\n") if -e $fn6;
		system("rm -f $fn")       if -e $fn6; 
	}
}

sub set_Active {
        if ($set ==  1)   { $f1 = "_ANN_ALL"; }
        if ($set ==  2)   { $f1 = "climo"; $f2 = "means"; }
        if ($set ==  3 || $set == 6) { $f1 = "_MONS_climo"; $f2 = "_ANN_ALL"; }
        if ($set ==  4)   { $f1 = "_ANN_climo_atm"; }
        if ($set ==  5)   { $f1 = "_ANN_climo"; }
        if ($set ==  7)   { $f1 = "_ANN_climo"; $f2 = "_MONS_climo"; }
        if ($set ==  8)   { $f1 = "_climo_atm"; }
}

sub cleanUp {
      foreach $m (@monList) {
      	$tf = $procDir.$prefix.".tmpFile".$m.".nc";  system("rm -f $tf") if -e $tf; 
      	$tf = $procDir.$prefix.".tmp2File".$m.".nc"; system("rm -f $tf") if -e $tf; 
      }
}

sub cleanAll {
$modeCtr=$caseCtr=0;
if($deleteProcDir) { 
	foreach    $case (@caseList) { 
	   foreach $mode (@modeList) {
      		$prefixDir = @prefDir[  $modeCtr];
      		$procDir   = $prefixDir."proc/";
 		foreach $y ($clim_fyr .. $clim_lyr) {
			$f = $procDir.$prefix.".sumFile_".$clim_fyr."-".$y."*.nc";    system("\/bin\/rm -f $f\n") if -e $f;
			$f = $procDir.$prefix.".monFile_".$clim_fyr."-".$y."*.nc";    system("\/bin\/rm -f $f\n") if -e $f;
			$f = $procDir.$prefix.".avgSumFile_".$clim_fyr."-".$y."*.nc"; system("\/bin\/rm -f $f\n") if -e $f;
			$f = $procDir.$prefix.".avgMonFile_".$clim_fyr."-".$y."*.nc"; system("\/bin\/rm -f $f\n") if -e $f;
 		}
		# print("\n\nRemoving processing directory: $procDir\n\n"); 
		# system("rm -f $procDir"); 
       		$modeCtr++;
	   }
    	   $caseCtr++;
        }
}
}

sub getEnvironmentVariables
{
  $weightAnnAvg      = $ENV{'weightAnnAvg'};
  $overWriteTrend    = $ENV{'overWriteTrend'};
  $overWriteClimo    = $ENV{'overWriteClimo'};
  $overWriteMeans    = $ENV{'overWriteClimo'};
  $runtype           = $ENV{'RUNTYPE'};
  $wkdir             = $ENV{'WKDIR'};
  $ptmpdir           = $ENV{'PTMPDIR'};
  $local_link        = $ENV{'LOCAL_LN'};
  $localFlag1        = $ENV{'LOCAL_FLAG_1'};
  $localFlag2        = $ENV{'LOCAL_FLAG_2'};
  $localFlag1_atm    = $ENV{'LOCAL_FLAG_atm_1'};
  $localFlag2_atm    = $ENV{'LOCAL_FLAG_atm_2'};
  $localFlag1_rtm    = $ENV{'LOCAL_FLAG_rtm_1'};
  $localFlag2_rtm    = $ENV{'LOCAL_FLAG_rtm_2'};
  $local1_dir        = $ENV{'LOCAL_1'};
  $local2_dir        = $ENV{'LOCAL_2'};
  $local1_atm_dir    = $ENV{'LOCAL_atm_1'};
  $local2_atm_dir    = $ENV{'LOCAL_atm_2'};
  $local1_rtm_dir    = $ENV{'LOCAL_rtm_1'};
  $local2_rtm_dir    = $ENV{'LOCAL_rtm_2'};
  $webdir            = $ENV{'WEBDIR'};
  $diag_code         = $ENV{'DIAG_CODE'};
  $cn                = $ENV{'CN'};
  $casa              = $ENV{'CASA'};
  $plot_type         = $ENV{'PLOTTYPE'};
  $trends_1          = $ENV{'trends_1'};
  $trends_2          = $ENV{'trends_2'};
  $climo_1           = $ENV{'climo_1'};
  $climo_2           = $ENV{'climo_2'};
  $rtm_1             = $ENV{'rtm_1'};
  $rtm_2             = $ENV{'rtm_2'};
  $trends_atm_1      = $ENV{'trends_atm_1'};
  $trends_atm_2      = $ENV{'trends_atm_2'};
  $climo_atm_1       = $ENV{'climo_atm_1'};
  $climo_atm_2       = $ENV{'climo_atm_2'};
  $trends_rtm_1      = $ENV{'trends_rtm_1'};
  $trends_rtm_2      = $ENV{'trends_rtm_2'};
  $climo_rtm_1       = $ENV{'climo_rtm_1'};
  $climo_rtm_2       = $ENV{'climo_rtm_2'};
  $trends_first_yr_1 = $ENV{'trends_first_yr_1'};
  $trends_first_yr_2 = $ENV{'trends_first_yr_2'};
  $clim_first_yr_1   = $ENV{'clim_first_yr_1'};
  $clim_first_yr_2   = $ENV{'clim_first_yr_2'};
  $trends_num_yrs_1  = $ENV{'trends_num_yrs_1'};
  $trends_num_yrs_2  = $ENV{'trends_num_yrs_2'};
  $clim_num_yrs_1    = $ENV{'clim_num_yrs_1'};
  $clim_num_yrs_2    = $ENV{'clim_num_yrs_2'};
  $MSS_tarfile_1     = $ENV{'MSS_tarfile_1'};
  $MSS_tarfile_2     = $ENV{'MSS_tarfile_2'};
  $MSS_path_1        = $ENV{'MSS_path_1'};
  $MSS_path_2        = $ENV{'MSS_path_2'};
  $MSS_path_atm_1    = $ENV{'MSS_path_atm_1'};
  $MSS_path_atm_2    = $ENV{'MSS_path_atm_2'};
  $MSS_path_rtm_1    = $ENV{'MSS_path_rtm_1'};
  $MSS_path_rtm_2    = $ENV{'MSS_path_rtm_2'};
  $caseid_1          = $ENV{'caseid_1'};
  $caseid_2          = $ENV{'caseid_2'};
  $prefix_1          = $ENV{'prefix_1'};
  $prefix_2          = $ENV{'prefix_2'};
  $case_1_dir        = $ENV{'case_1_dir'};
  $case_2_dir        = $ENV{'case_2_dir'};
  $pref_1_dir        = $ENV{'prefix_1_dir'};
  $pref_2_dir        = $ENV{'prefix_2_dir'};
  $case_1_atm_dir    = $ENV{'case_1_atm_dir'};
  $case_2_atm_dir    = $ENV{'case_2_atm_dir'};
  $pref_1_atm_dir    = $ENV{'prefix_1_atm_dir'};
  $pref_2_atm_dir    = $ENV{'prefix_2_atm_dir'};
  $case_1_rtm_dir    = $ENV{'case_1_rtm_dir'};
  $case_2_rtm_dir    = $ENV{'case_2_rtm_dir'};
  $pref_1_rtm_dir    = $ENV{'prefix_1_rtm_dir'};
  $pref_2_rtm_dir    = $ENV{'prefix_2_rtm_dir'};
  $rmTrendFlag       = $ENV{'rmMonFilesTrend'};
  $rmClimoFlag       = $ENV{'rmMonFilesClimo'};
  $meansFlag         = $ENV{'meansFlag'};
  $ttest             = $ENV{'ttest'};
  $deleteProcDir     = $ENV{'deleteProcDir'};
  $camname1          = $ENV{'camname1'};
  $camname2          = $ENV{'camname2'};
  $set_1             = $ENV{'set_1'};
  $set_2             = $ENV{'set_2'};
  $set_3             = $ENV{'set_3'};
  $set_4             = $ENV{'set_4'};
  $set_5             = $ENV{'set_5'};
  $set_6             = $ENV{'set_6'};
  $set_7             = $ENV{'set_7'};
  $set_8             = $ENV{'set_8'};
  $set_9             = $ENV{'set_9'};
  $ncclimoDir        = $ENV{'ncclimo_dir'};
  $var_list_1        = $ENV{'var_list_1'};
  $var_list_2        = $ENV{'var_list_2'};
}

sub errorReport()
{
	local($err) = @_;

        die "\n\n$message\n";

}
