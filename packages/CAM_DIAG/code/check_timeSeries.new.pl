#!/usr/bin/perl

use IO::File;

$debug = 0;

$directory = $ARGV[0]; 
$prefix = $ARGV[1];
$test_start = $ARGV[2];
$test_end = $ARGV[3];
$climoDir = $ARGV[4];
$strip_var = $ARGV[5];
$diag_var_list = $ARGV[6];
$outfile = $ARGV[7];

# This scripts creates a text file that lists all of the time series files that 
# span the date range for that case.

$test_start = $test_start - 1;
$test_end = $test_end + 1;

opendir(D, $directory) || die "Can't opedir $directory: $!\n";
my @filelist = readdir(D);
closedir(D);

#go through the directory and get all timeseries files
$i=0;
$x=0;
my @dateList = ();
my @varList = ();
foreach my $f (@filelist) {
  if ($f =~ /$prefix/) {
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


    if ($debug) {
     print $f."\n";
     print $startYear."\n";
     print $startMonth."\n";
     print $endYear."\n";
     print $endMonth."\n";
     print "\n";
    }

    $added = 0;
   
    #add stamp to the list a stamps found
    @dateList[$i] = $startYear."-".$startMonth."_cat_".$endYear."-".$endMonth; 

    #create a variable list
    $pfLength = length($prefix);
    $varname = substr($f,$pfLength,($fileLength-($pfLength+22)-1));
    if (-e "$directory/$prefix$varname.@dateList[$i].nc"){
      @varList[$x] = $varname;
      $x+=1;
    }
    $i+=1;
  }
}

if ($debug) {
 print "Original: "."@dateList"."\n";
}

#Remove any duplicate time stamps in the list 
my %seen = ();
my @noDuplicate = ();
foreach my $a (@dateList) {
  unless ($seen{$a}) {
    push @noDuplicate, $a;
    $seen{$a} = 1;
  }
}

my %seenV = ();
my @noDuplicateV = ();
foreach my $a (@varList) {
  unless ($seenV{$a}) {
    push @noDuplicateV, $a;
    $seenV{$a} = 1;
  }
}

if ($strip_var == "0") {
  @diag_var_listA = split(/\,/,$diag_var_list); 
}
$varList_name = "$climoDir/var_list.txt";
$var_list = IO::File->new($varList_name,'w');
$found_var = 0;
foreach my $a (@noDuplicateV) {
  if ($strip_var == "0") {
    foreach my $b (@diag_var_listA) {
      if ($a eq $b) {
        print $var_list $a."\n";
        $found_var = 1;
      }
    }
  } else {
    print $var_list $a."\n";
    $found_var = 1;
  }
}
if ($found_var == "0"){
  print $var_list "null\n";
} 
close ($var_list);

# go through the list again and pick out the years we need

my @completeFileList = ();
my %seen2 = ();
$djf_name = "$climoDir/DJF.txt";
$djf = IO::File->new($djf_name,'w');
$year = $test_start;
$data_start; $data_end;
while ($year <= $test_end) {
  $found = 0;
  foreach my $stamp (@noDuplicate){
    $year1 = substr($stamp,0,4);
    $month1 = substr($stamp,5,2);
    $year2 = substr($stamp,12,4);
    $month2 = substr($stamp,17,2);
    if ($year >= $year1  && $year <= $year2) { #does the year fall within the time stamp boundaries of this file
      if ($found == 0) {
        $found = 1;
        $previousMonth = $month2;
      } else { #more than 1 file contains this time stamp
        if ($year == $year1){
            if ($previousMonth == ($month1 - 1)) {
              print "Split year -- looks okay \n";
            } else {
                print "Split year -- doesn't look contiguous. "."\n";
                exit 1;
            }
        } else {
          print "Found more than 1 file that contains year ".$year."\n";
          exit 1;
        }
      }
      if ($found == 1) { #  The year is needed, but make sure this needed file hasn't already been added by another matching year in the file
        print $year." is between ".$year1." and ".$year2."\n";
        if ($year == $test_start) {
          print $djf "PREV \n";
          $data_start = $test_start;
          $data_end = $test_end - 1;
        }
        if ($year == $test_end) {
          print $djf "NEXT \n";
          if ($data_start != $test_start) {
            $data_start = $test_start + 1;
            $data_end = $test_end;
          } 
        }
        unless($seen2{$stamp}){
          push @completeFileList,$stamp;
          $seen2{$stamp} = 1;
        }
      }
     }
  }
  if ($found == 0){
    if ($year == $test_start) {
      print "December from previous year not found \n";
    } 
    if ($year == $test_end){
      print "January/February from next year not found \n";
    }
    print "Cannot find file for year ".$year."\n";
    exit 1;
  }
  $year+=1;
}
if ($degug) {
 print "Final: "."@completeFileList"."\n";
}

# Go through the list and write out the files that will be used
$catList = " ";
$flistname = "$climoDir/$outfile";
$file_list = IO::File->new($flistname,'w');
if (@completeFileList >= 1) {
  $previousYear = 0;
  $previousMonth = 0;
  $first = 1;
  foreach my $stamp (@completeFileList){
    $year1 = substr($stamp,0,4);
    $month1 = substr($stamp,5,2);
    $year2 = substr($stamp,12,4);
    $month2 = substr($stamp,17,2);
    if ($first == 1){
      $catList .= $directory."/".$prefix.$stamp.".nc ";
      #print $file_list $directory.$prefix.$stamp.".nc,".$year1.",".$month1.",".$year2.",".$month2."\n";
      print $file_list $directory."/".$prefix.",".$year1.",".$month1.",".$year2.",".$month2."\n";
      $previousYear = $year2;
      $previousMonth = $month2;
      $firstStamp = $year1."-".$month1;
      $first = 0;
    } else {
       if (($previousYear == ($year1 - 1) && ($previousMonth == 12 && $month1 == 1)) || (($previousYear == $year1) && ($previousMonth == ($month1 - 1)))) {
         $catList .= $directory."/".$prefix.$stamp.".nc ";
         #print $file_list $directory.$prefix.$stamp.".nc,".$year1.",".$month1.",".$year2.",".$month2."\n";
         print $file_list $directory."/".$prefix.",".$year1.",".$month1.",".$year2.",".$month2."\n";
         $previousYear = $year2;
         $previousMonth = $month2;
         $lastStamp = $year2."-".$month2
       } else {
         print "There's a break in the year sequence -- date stamps do not appear contiguous. \n"; 
         exit 1;
       }
    }
  }
  if ($data_end == $previousYear) {
  if ($previousMonth != "12" || $previousMonth != "02") {
    print "Ending timeseries file does not end in December or February.  Exiting \n";
    exit 1;
  }
  }
}

close ($file_list);
close ($djf);

