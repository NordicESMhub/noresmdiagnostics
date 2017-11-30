#!/bin/csh -f
# Check which variables are present in history files
# Johan Liakka, NERSC, Nov 2017

set filetype      = $1
set first_year    = $2
set casename      = $3
set pathdat       = $4
set diag_dir      = $5

set required_vars = (sst templvl salnlvl)
set yr_prnt       = `printf "%04d" ${first_year}`

# Case 1
if ($filetype == hy) then
   set fullpath_filename = $pathdat/$casename.micom.$filetype.`printf "%04d" ${first_year}`.nc
else
   set fullpath_filename = $pathdat/$casename.micom.$filetype.`printf "%04d" ${first_year}`-01.nc
endif
set first_find = 1
set var_list = " "
foreach var ($required_vars)
   /usr/local/bin/ncks --quiet -d y,0 -d x,0 -d sigma,0 -d depth,0 -d region,0 -d slenmax,0 -d section,0 -d lat,0 -v $var $fullpath_filename  >&! /dev/null
   set var_present = $status
   if ($var_present == 0) then
      if ($first_find == 1) then
	 set var_list = $var
	 set first_find=0
      else
         set var_list = ${var_list},$var
      endif
   endif
end
echo  ${var_list} > $diag_dir/attributes/var_list_climo

# Case 2
#if ($RUNTYPE == "model1-model2") then
#   set fullpath_filename = $case_2_dir/$caseid_2.clm2.h0.`printf "%04d" ${trends_first_yr_2}`-01.nc
#   set first_find = 1
#   set var_list = " "
#   foreach var ($required_vars)
#      /usr/local/bin/ncks --quiet  -d lat,0 -d lon,0 -v $var $fullpath_filename  >&! /dev/null
#      set var_present = $status
#      if ($var_present == 0) then
#         if ($first_find == 1) then
#            set var_list = $var
#	    set first_find=0
#         else
#            set var_list = ${var_list},$var
#         endif
#      endif
#   end
#   echo  ${var_list} > $PROCDIR2/var_list.txt
#endif
