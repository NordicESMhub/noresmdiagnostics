#!/bin/csh -f
#
# MICOM DIAGNOSTICS package: check_history_climo.csh
# PURPOSE: checks if all history files exist, and which variables are present.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last updated: Dec 2017

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located

set filetype = $1
set casename = $2
set first_yr = $3
set last_yr  = $4
set pathdat  = $5

echo " "
echo "-----------------------"
echo "check_history_climo.csh"
echo "-----------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " "

if (-e $WKDIR/attributes/vars_remaining) then
   rm -r $WKDIR/attributes/vars_remaining
endif

# Check if all history files are present
set check_vars = 1
if ($filetype == hy) then
   echo "Searching for annual history files..."
   @ iyr = $first_yr
   while ($iyr <= $last_yr)
      set fullpath_filename = $pathdat/$casename.micom.$filetype.`printf "%04d" ${iyr}`.nc
      if (! -e $fullpath_filename) then
         echo "$fullpath_filename does not exist."
         set check_vars = 0
	 break
      endif
      @ iyr++
   end
else if ($filetype == hm) then
   echo "Searching for monthly history files..."
   @ iyr = $first_yr
   while ($iyr <= $last_yr)
      foreach mon (01 02 03 04 05 06 07 08 09 10 11 12)
         set fullpath_filename = $pathdat/$casename.micom.$filetype.`printf "%04d" ${iyr}`-${mon}.nc
         if (! -e $fullpath_filename) then
            echo "$fullpath_filename does not exist."
	    set check_vars = 0
	    break; break
	 endif
      end
      @ iyr++
   end
   echo "FOUND all monthly history files."
else
   echo "ERROR (check_history_climo.csh): filetype must be set to hy or hm"
   exit
endif
echo "FOUND all $filetype history files."

# Check which variables are present
if ($check_vars == 1) then
   set req_varsc = `cat $WKDIR/attributes/required_vars`
   echo "Searching for $filetype variables: $req_varsc"
   set req_vars  = `cat $WKDIR/attributes/required_vars | sed 's/,/ /g'`
   set first_find = 1
   set find_any = 0
   set remaining_any = 0
   set first_find_remaining = 1
   set var_list = " "
   set var_list_remaining = " "
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
      echo ${var_list} > $WKDIR/attributes/vars_${casename}_climo_${filetype}
   endif
   echo "Variables remaining: $var_list_remaining"
   if ($remaining_any == 1) then
      echo ${var_list_remaining} > $WKDIR/attributes/vars_remaining
   endif
endif

