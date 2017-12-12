#!/bin/bash

# MICOM DIAGNOSTICS package: add_attributes.sh
# PURPOSE: Add coordinate attributes to variables if necessary
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $ann_file  annual climo file
#  $climodir  climo directory

ann_file=$1
climodir=$2

echo " "
echo "-----------------------"
echo "add_attributes.sh"
echo "-----------------------"
echo "Input arguments:"
echo " ann_file = $ann_file"
echo " climodir = $climodir"
echo " "

coord_file=$DIAG_ETC/variable_horizontal_coordinates

while read var clon clat
do
   $NCKS --quiet -d depth,0 -d x,0 -d y,0 -v $var $climodir/$ann_file >/dev/null 2>&1
   if [ $? -eq 0 ]; then
       echo "Adding coordinate attributes to $var"
       $NCATTED -a coordinates,$var,c,c,"$clon $clat" $climodir/$ann_file
   else
       echo "Could not find variable $var in $climodir/$ann_file"
   fi
done<$coord_file
