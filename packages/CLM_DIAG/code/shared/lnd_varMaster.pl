#!/usr/bin/perl

# written by Nan Rosenbloom
# February 2006
# Usage:  called by /code/lnd_driver.csh to dynamically generate
# variable_master_Use.ncl

# --------------------------------
# get environment variables

  $wkdir     = $ENV{'WKDIR'};
  $diag_res  = $ENV{'INPUT_FILES'};
  $prefix_1  = $ENV{'prefix_1'};
  $var_master_cn   = $ENV{'var_master_cn'};
  $var_master_casa = $ENV{'var_master_casa'};

# --------------------------------
# define files 
# --------------------------------

  # master variable list contains all variable definitions
  $cn   = $diag_res.$var_master_cn;
  $casa = $diag_res.$var_master_casa;
  $ofile = $wkdir."/variable_master.ncl";

  $flag = 0;

# --------------------------------
#  start main loop 
# --------------------------------

  	close(fp_cn);
  	open(fp_cn,"<"."$cn")     || die "lnd_varMaster.pl: varCan't open CN input file ($cn) \n";
  	close(fp_casa);
  	open(fp_casa,"<"."$casa") || die "lnd_varMaster.pl: Can't open CASA input file ($casa) \n";

  	close(fp_out);
  	open(fp_out,">"."$ofile") || die "lnd_varMaster.pl: Can't open main output file ($ofile) \n";

	while(<fp_cn>)
	{
		if (/info+(.*)/ && /False+(.*)/ && !/\@+(.*)/) { last; }
		else					       { printf( fp_out "$_"); }


	}
	while(<fp_casa>)
	{
		if (/info+(.*)/ && /True+(.*)/ && !/\@+(.*)/) { $_=<fp_casa>; $flag++; }
		if ($flag) { printf( fp_out "$_"); }
	}

	close(fp_out);
	close(fp_cn);
	close(fp_casa);
