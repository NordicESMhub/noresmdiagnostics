#!/usr/bin/perl

use IO::File;

$debug = 0;

$path_HPSS = $ARGV[0]; 
$path_local = $ARGV[1];
$first_year = $ARGV[2];
$nyrs = $ARGV[3];
$rootname = $ARGV[4];

$start = $first_year - 1;
$end = $first_year + $nyrs;

$hpss_list_file = "$path_local/hpss_list.out";
system("hsi -P ls -1 $path_HPSS > $hpss_list_file");

open(FILE2, $hpss_list_file);
#go through the directory and get all timeseries files within the start and end years
$i=0;
$x=0;
while (<FILE2>) {
  chomp;
  $f = $_;
  if ($f =~ /$rootname/) {
    $fileLength = length($f);
    # get index of the beginning of date stamp
    $dateStartIndex = $fileLength-22; 
    
    #parse the date string (yyyy-mm_cat_yyyy-mm)
    $smIndex = $dateStartIndex+5;
    $eyIndex = $dateStartIndex+12;
    $emIndex = $dateStartIndex+17;
    $startYear = substr($f,$dateStartIndex,4);
    $startMonth = substr($f,$smIndex,2);
    $endYear = substr($f,$eyIndex,4);
    $endMonth = substr($f,$emIndex,2);


    if (($startYear >= $start  && $startYear <= $end) || ($endYear >= $start && $endYear <= $end)){
      my @fn = split("/",$f);
      my $i = @fn;
      if (-e "$path_local/$fn[$i-1]") { 
        $found=1;
      } else {
      print "GETTING $f \n";
      system("hsi get $path_local/$fn[$i-1] : $f");
      }
    }

  }
}

system("rm -f $hpss_list_file");
$xx = 1;



