#!/bin/csh -f
#
# MICOM DIAGNOSTICS package: check_vars_time_series.csh
# PURPOSE: checks if time series variables are present in history files.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last updated: Dec 2017

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the time series (four digits)
#  $pathdat   directory where the history files are located

set filetype = $1
set casename = $2
set first_yr = $3
set pathdat  = $4

echo " "
echo "-----------------------------"
echo "check_vars_time_series.csh"
echo "-----------------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " pathdat  = $pathdat"
echo " "

if (-e $WKDIR/attributes/vars_remaining) then
   rm -f $WKDIR/attributes/vars_remaining
endif

# Check which variables are present
set req_varsc = `cat $WKDIR/attributes/required_vars`
echo "Searching for $filetype variables: $req_varsc"
set req_vars  = `cat $WKDIR/attributes/required_vars | sed 's/,/ /g'`
set first_find = 1
set first_find_remaining = 1
set find_any = 0
set remaining_any = 0
set var_list = " "
set var_list_remaining = " "
if ($filetype == hy) then
   set fullpath_filename = $pathdat/${casename}.micom.hy.${first_yr}.nc
else
   set fullpath_filename = $pathdat/${casename}.micom.hm.${first_yr}-01.nc
endif

foreach var ($req_vars)
   /usr/local/bin/ncks --quiet -d y,0 -d x,0 -d sigma,0 -d depth,0 -d region,0 -d slenmax,0 -d section,0 -d lat,0 -v $var $fullpath_filename  >&! /dev/null
   set var_present = $status
   if ($var_present == 0) then
      set find_any = 1
      if ($first_find == 1) then
         set var_list = $var
         set first_find=0
      else
         set var_list = ${var_list},$var
      endif
   else
      set remaining_any = 1
      if ($first_find_remaining == 1) then
         set var_list_remaining = $var
         set first_find_remaining = 0
      else
         set var_list_remaining = ${var_list_remaining},$var
      endif         
   endif
end
echo "Variables in history files: $var_list"
if ($find_any == 1) then
   echo ${var_list} > $WKDIR/attributes/vars_${casename}_ts_${filetype}
endif
echo "Variables remaining: $var_list_remaining"
if ($remaining_any == 1) then
   echo ${var_list_remaining} > $WKDIR/attributes/vars_remaining
endif


