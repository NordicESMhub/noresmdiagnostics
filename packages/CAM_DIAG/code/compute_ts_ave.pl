#!/usr/bin/perl

use IO::File;

$debug = 0;

$filename = $ARGV[0]; 
$year1 = $ARGV[1];
$month1 = $ARGV[2];
$year2 = $ARGV[3];
$month2 = $ARGV[4];
$begin = $ARGV[5];
$end = $ARGV[6];
$month = $ARGV[7];
$climoDir = $ARGV[8];
$djf = $ARGV[9];
$strip_off_vars = $ARGV[10];
$var_list = $ARGV[11];
$outfile = $ARGV[12];

$slab;

$startIndex;
$endIndex;

#set the correct start year 
if ($djf eq "PREV") {
  $begin = $begin - 1;
  $end = $end - 1;
}
if ($djf eq "NEXT") {
  $begin = $begin + 1;
  $end = $end + 1;
}

#find the begining file index
if ($begin >= $year1 && $begin <= $year2) { #the first year is in this file, find index accordingly
 if ($month1 == 1) {
    $startIndex = (($begin - $year1)*12)+$month; 
  } else {
    if ($month < $month1) {
      $startIndex = (($begin - $year1)*12)+(12-$month1+1)+$month;
    } else {
      $startIndex = (($begin - $year1)*12)+($month - $month1) + 1;
    }
  }
  if ($end >= $year1 && $end <= $year2) { 
    $endIndex = $startIndex + (($end - $begin)*12);
  } 
} else { #this is a middle (or end file), find index accordingly
  if ($month < $month1) {
    $startIndex = (12-$month1+1)+$month;
  } else {
    $startIndex = ($month - $month1) + 1;
  }
}


#find the end of the file
if ($end >= $year1 && $end <= $year2) { # the last year is found in this file, set index accordingly
  if ($begin <= $year1 || $begin >= $year2) {
    $endIndex = $startIndex + (($end - $year1)*12);
  }
}
if ($end > $year2) {
  $slab = "time,$startIndex,,12"; # last year not found in this file, use the start index until the eof
} else {
  $slab = "time,$startIndex,$endIndex,12";  # last year found in this file, use end index
}

# call ncra to create an average using the slices found only in this file.  Later on average all of the file averages together. 
  system("ncra -O  -F -d time,$startIndex,$endIndex,12 $filename $outfile");

