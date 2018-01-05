#!/bin/bash

# HAMMOC DIAGNOSTICS package: concancate_files.sh
# PURPOSE: Merge two climo or ts files (hbgcy and hbgcm)
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Jan 2018

# Input arguments:
#  $casename  name of experiment
#  $first_yr  first year of the average (four digits)
#  $last_yr   last year of the average (four digits)
#  $filedir   directory where the files are located
#  $mode      climo or ts_ann

casename=$1
first_yr=$2
last_yr=$3
filedir=$4
mode=$5

echo " "
echo "-----------------------"
echo "concancate_files.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " filedir  = $filedir"
echo " mode     = $mode"
echo " "

if [ $mode == climo ]; then
    ann_file_hy=${casename}_ANN_${first_yr}-${last_yr}_climo_hbgcy.nc
    ann_file_hm=${casename}_ANN_${first_yr}-${last_yr}_climo_hbgcm.nc
    ann_file=${casename}_ANN_${first_yr}-${last_yr}_climo.nc
elif [ $mode == ts_ann ]; then
    ann_file_hy=${casename}_ANN_${first_yr}-${last_yr}_ts_hbgcy.nc
    ann_file_hm=${casename}_ANN_${first_yr}-${last_yr}_ts_hbgcm.nc
    ann_file=${casename}_ANN_${first_yr}-${last_yr}_ts.nc
else
    echo "ERROR: mode must be climo or ts_ann."
    exit 1
fi
    
if [ -f $filedir/$ann_file_hy ]; then
   mv $filedir/$ann_file_hy $filedir/$ann_file
   if [ -f $filedir/$ann_file_hm ]; then
      echo "Merging $ann_file_hy and $ann_file_hm to $ann_file"
      $NCKS -A -o $filedir/$ann_file $filedir/$ann_file_hm
      rm -f $filedir/$ann_file_hm
   else
      echo "Renaming $ann_file_hy -> $ann_file"
   fi
else
   if [ -f $filedir/$ann_file_hm ]; then
      echo "Renaming $ann_file_hm -> $ann_file"
      mv $filedir/$ann_file_hm $filedir/$ann_file
   else
      echo "ERROR: $filedir/$ann_file_hy does not exist."
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   fi
fi
