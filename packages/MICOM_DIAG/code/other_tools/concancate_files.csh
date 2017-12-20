#!/bin/csh -f

# MICOM DIAGNOSTICS package: concancate_climo.csh
# PURPOSE: Merge the two climo or ts files (hy and hm)
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average (four digits)
#  $last_yr   last year of the average (four digits)
#  $filedir   directory where the files are located
#  $mode      climo or ts

set casename = $1
set first_yr = $2
set last_yr  = $3
set filedir  = $4
set mode     = $5

echo " "
echo "-----------------------"
echo "concancate_climo.csh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " filedir  = $filedir"
echo " mode     = $mode"
echo " "

set ann_file_hy = ${casename}_ANN_${first_yr}-${last_yr}_${mode}_hy.nc
set ann_file_hm = ${casename}_ANN_${first_yr}-${last_yr}_${mode}_hm.nc
set ann_file    = ${casename}_ANN_${first_yr}-${last_yr}_${mode}.nc

if (-e $filedir/$ann_file_hy) then
   mv $filedir/$ann_file_hy $filedir/$ann_file
   if (-e $filedir/$ann_file_hm) then
      echo "Merging $ann_file_hy and $ann_file_hm to $ann_file"
      /usr/local/bin/ncks -A -o $filedir/$ann_file $filedir/$ann_file_hm
      rm -f $filedir/$ann_file_hm
   else
      echo "Renaming $ann_file_hy -> $ann_file"
   endif
else
   if (-e $filedir/$ann_file_hm) then
      echo "Renaming $ann_file_hm -> $ann_file"
      mv $filedir/$ann_file_hm $filedir/$ann_file
   else
      echo "ERROR: $filedir/$ann_file_hy does not exist."
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   endif
endif
