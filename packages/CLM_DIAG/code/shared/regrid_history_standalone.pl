#!/usr/bin/perl
#
use Cwd;

#$file_dir = location of original files 
#$file_prefix = original prefix
#$first_yr = first year to regrid
#$last_yr = number of years to regrid (code will also try to regrid first_yr-1 and last_yr+1 to account for prevoius or next DJF)
#$output_directory = where the new regridded files will be located
#$weight_dir = location of weight files
#$area_dir = location of area files
#$old_res = example "SE_NE30"
#$new_res = example "FV_192x288"
#$method = example "bilinear"
#$wgt_file = $old_res."_to_".$new_res.".".$method.".nc";
#$area_file = $new_res"_area."$method".nc"

$file_dir =  $ARGV[0]; 
$file_prefix =  $ARGV[1]; 
$first_yr =  $ARGV[2];
$last_yr =  $ARGV[3];
$output_directory =  $ARGV[4]; 
$weight_dir =  $ARGV[5]; 
$area_dir = $ARGV[6];
$old_res =  $ARGV[7];
$new_res =  $ARGV[8];
$method =  $ARGV[9];
$wgt_file = $old_res."_to_".$new_res.".".$method.".nc";
$area_file = $new_res."_area".".nc";

$use_swift = $ARGV[10];
$swift_sandbox = $ARGV[11];
$DIAG_SHARED = $ARGV[12];

my $current = cwd();
print $current;
if (-e $current."/fileList.out") {
  unlink $current."/fileList.out"
}

chdir($file_dir);

$ctr=0;
$yrct = $first_yr;
while ($yrct <= $last_yr) {
      $use_prnt = printYear($yrct);
      $ifile = $file_prefix.".clm2.h0.".$use_prnt;
      $commandLine = "ls ".$ifile."* >> ".$current."/fileList.out";
      $err = system($commandLine);
      $yrct++;
}

chdir($current);

my $sysmod = "mkdir -p $output_directory";
system($sysmod);

if ($use_swift == 1) {

  chdir($swift_sandbox);

  $commandLine =   "swift -config ".$current."/cf.properties -sites.file ".$current."/sites.xml -tc.file ".$current."/tc.data -cdm.file ".$current."/fs.data ".$current."/regrid_history.swift -file_dir=".$file_dir." -file_prefix=".$file_prefix." -first_yr=".$first_yr." -last_yr=".$last_yr." -output_directory=".$output_directory." -weight_dir=".$weight_dir." -old_res=".$old_res." -new_res=".$new_res." -method=".$method." -wgt_file=".$wgt_file." -area_dir=".$area_dir." -area_file=".$area_file." -script_dir=".$DIAG_SHARED." -fileList=".$current."/fileList.out";
  $err = system($commandLine);

  chdir($current);
} else {

  open FILE,"fileList.out" or die $!;
  my @lines = <FILE>;
  close FILE;


  foreach $file (@lines) {
    chomp($file);
    $commandLine = $DIAG_SHARED."/regrid_history_ncl_wrapper.csh ".$file_dir." ".$file." ".$method." ".$weight_dir." ".$wgt_file." ".$area_dir." ".$area_file." ".$DIAG_SHARED." ".$old_res." ".$new_res." ".$output_directory." "."progress.out";
    $err = system($commandLine); 
  }

}

sub printYear
{
  local($iyr) = @_;
  if    ($iyr <    10)                { $y = "000".$iyr; }
  elsif ($iyr >=   10 && $iyr <  100) { $y =  "00".$iyr; }
  elsif ($iyr >=  100 && $iyr < 1000) { $y =   "0".$iyr; }
  elsif ($iyr >= 1000)                { $y =       $iyr; }
  return($y);
}


