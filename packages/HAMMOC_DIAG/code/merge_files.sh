#!/bin/bash

# HAMOCC DIAGNOSTICS package: merge_files.sh
# PURPOSE: Merge two netcdf files from the same directory.
# If only one of the files exist, it will be renamed to the target file
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $filedir   directory where the files are located
#  $file1     file1 to merge (will be deleted)
#  $file2     file2 to merge (will be deleted)
#  $fileout   name of merged file (will be created)

filedir=$1
file1=$2
file2=$3
fileout=$4

echo " "
echo "-----------------------"
echo "merge_files.sh"
echo "-----------------------"
echo "Input arguments:"
echo " filedir  = $filedir"
echo " file1    = $file1"
echo " file2    = $file2"
echo " fileout  = $fileout"
echo " "

if [ -f $filedir/$file1 ]; then
   mv $filedir/$file1 $filedir/$fileout
   if [ -f $filedir/$file2 ]; then
      echo "Merging $file1 and $file2 to $fileout"
      $NCKS -A -o $filedir/$fileout $filedir/$file2
      rm -f $filedir/$file2
   else
       echo "Renaming $file1 -> $fileout"
   fi
else
   if [ -f $filedir/$file2 ]; then
      echo "Renaming $file2 -> $fileout"
      mv $filedir/$file2 $filedir/$fileout
   else
      echo "ERROR: $filedir/$file1 and $filedir/$file2 do not exist."
      echo "*** EXITING THE SCRIPT ***"
      exit 1
   fi
fi
