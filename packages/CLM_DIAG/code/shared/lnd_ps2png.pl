#!/usr/bin/perl

# written by Nan Rosenbloom
# July 2005
# Usage:  called by /code/lnd_driver.csh to dynamically generate
# html files for revised LMWG Diagnostics Package.

# program checks for successful completion of plots; variables not
# successfully plotted are not linked to the html.

# Updated by Johan Liakka, NERSC, Nov 2017

# --------------------------------
# get environment variables

  print "------------------------\n";
  print "Running lnd_ps2png .....\n";
  print "------------------------\n";

  $set_1  = $ENV{'set_1'};
  $set_2  = $ENV{'set_2'};
  $set_3  = $ENV{'set_3'};
  $set_4  = $ENV{'set_4'};
  $set_5  = $ENV{'set_5'};
  $set_6  = $ENV{'set_6'};
  $set_7  = $ENV{'set_7'};
  $set_8  = $ENV{'set_8'};
  $set_8_lnd  = $ENV{'set_8_lnd'};
  $set_9  = $ENV{'set_9'};

  # $density = 108;
  # $density  = $ENV{'density'};

  $wkdir     =    $ENV{'WKDIR'};
  $webdir    =    $ENV{'WEBDIR'};
  $runtype   =    $ENV{'RUNTYPE'};
  $plot_type =    $ENV{'PLOTTYPE'};
  $density   =    $ENV{'density'};

  if ($runtype eq "model1-model2") { $compareModels = 1; }
  else			           { $compareModels = 0; }

$convert = "/usr/bin/convert";
# $convert = "convert";
$flags = "-density $density -trim +repage";
$smflags = "-density $density -trim +repage";

if($set_8_lnd == 1) { $set_8 = 1; }

@setList = (1,2,3,4,5,6,7,8,9);
@status = ($set_1, $set_2, $set_3, $set_4, $set_5, $set_6, $set_7,$set_8,$set_9);

for $set (@setList)
{
    if( @status[$set-1]) { 
        $cset = "set".$set;
        print("Converting $cset ps to png ...");
	if ($set == 5) { system("cp $wkdir/set5_*.txt $webdir/set5/"); }
	else {
	   if ($set == 7) { system("cp $wkdir/set7_*.txt $webdir/set7/"); }
	   if ($set == 9) { system("cp $wkdir/set9_*.html $webdir/set9/"); }
	   $sfile = "'set".$set."*.ps'";
	   open(FIND,"find $wkdir -name $sfile -print|");
	   $|=1;
	   while ($file = <FIND>)
	   {
	    	chop($file);
        	$fin  = substr($file,length($wkdir));
		if ($plot_type eq "ps")
		{
        		$fn   = substr($fin,0,9);
        		$fn1  = substr($fin,0,13);
        		$f    = substr($fin,0,length($fin)-2);
			$fout = $webdir."/set".$set."/".$f."png";
			$fpng = $f."png";
			if($fn  eq "set3_reg_" || $fn eq "set6_reg_" || 
			    $fn eq "set7_ANN_" || $fn eq "set7_stat" || $fn  eq "set7_ocea" )
							 { print("Rotating image. $fn\n");  
							   $commandLine = "$convert $flags -rotate -90 $file $fout"; }
			else {
			     if($set == 2 && $compareModels) { $commandLine = "$convert $flags $file $fout"; }
			     else  { 
				if($set == 1) { $commandLine = "$convert $smflags $file $fout"; }
				else          { $commandLine = "$convert   $flags $file $fout"; }
			     }
			}
#			print "converting = $fin to $fpng\n";
		} elsif ($plot_type eq "png") {

			$outdir = $webdir."/set".$set;
			$commandLine = "mv $wkdir$fin $outdir/$fin";
			print "$commandLine\n";
		} else { die "Invalid plot type.\n"; }
		system($commandLine);
	    }
	}
     }
}
close(fp_in);
print "Done with ps2png conversion\n";
end
