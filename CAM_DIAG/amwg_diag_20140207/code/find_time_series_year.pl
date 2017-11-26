#!/usr/bin/perl

use IO::File;

$debug = 0;

$tsList  = $ARGV[0]; 
$year = $ARGV[1];
$climoDir = $ARGV[2];
$swift_outfile = $ARGV[3];
$outfile = $ARGV[4];

# This script will loop over the the time series files
# to find the which time series file(s) contain $year.
# It will output in the format $file,$monthIndex for each
# month in the year.

$year_slice = IO::File->new($outfile,'w');
open(FILE1, $tsList);
while (<FILE1>) {
  $found = 0;
  $startMonth = 1;
  $endMonth = 12;
  chomp;
  ($filename, $year1, $month1, $year2, $month2) = split(",");
   
  if ($year > $year1 && $year < $year2) {
    $found = 1;
  } elsif ($year == $year1) {
    if ($month1 == 1) {
      $found = 1;
    } else {
      $found = 1;
      $startMonth = $month1;
    }    
  } elsif ($year == $year2) {
    if ($month2 == 12) {
      $found = 1;
    } else {
      $found = 1;
      $endMonth = $month2;
    }
  }
  if ($found == 1) {
    @m = ($startMonth..$endMonth);
    foreach $month (@m) {
      if ($month1 == 1) {
        $startIndex = (($year - $year1)*12)+$month; 
      } else {
        if ($month < $month1) {
          $startIndex = (($year - $year1)*12)+(12-$month1+1)+$month;
        } else {
          $startIndex = (($year - $year1)*12)+($month - $month1) + 1;
        }
      }
      print $year_slice "$filename,$startIndex,$year1,$month1,$year2,$month2\n";
    } 
  }
}

 
