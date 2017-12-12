#!/bin/csh -f

# MICOM DIAGNOSTICS package: concancate_climo.csh
# PURPOSE: Merge the two climo files (hy and hm), otherwise change name
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average (four digits)
#  $last_yr   last year of the average (four digits)
#  $climodir  directory where the climatology files are located

set casename = $1
set first_yr = $2
set last_yr  = $3
set climodir = $4

echo " "
echo "-----------------------"
echo "concancate_climo.csh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " climodir = $climodir"
echo " "

set ann_file_hy = ${casename}_ANN_${first_yr}-${last_yr}_climo_hy.nc
set ann_file_hm = ${casename}_ANN_${first_yr}-${last_yr}_climo_hm.nc
set ann_file    = ${casename}_ANN_${first_yr}-${last_yr}_climo.nc

if (-e $climodir/$ann_file_hy) then
   mv $climodir/$ann_file_hy $climodir/$ann_file
   if (-e $climodir/$ann_file_hm) then
      echo "Merging $ann_file_hy and $ann_file_hm to $ann_file"
      /usr/local/bin/ncks -A -o $climodir/$ann_file $climodir/$ann_file_hm
      rm -f $climodir/$ann_file_hm
   else
      echo "Renaming $ann_file_hy -> $ann_file"
   endif
else
   if (-e $climodir/$ann_file_hm) then
      echo "Renaming $ann_file_hm -> $ann_file"
      mv $climodir/$ann_file_hm $climodir/$ann_file
   else
      echo "ERROR: $climodir/$ann_file_hy does not exist."
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
endif
