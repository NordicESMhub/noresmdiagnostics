#!/bin/csh -f

# MICOM DIAGNOSTICS package: add_attributes.csh
# PURPOSE: Add coordinate attributes to variables if necessary
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# Input arguments:
#  $ann_file  annual climo file
#  $climodir  climo directory

set ann_file = $1
set climodir = $2

echo " "
echo "-----------------------"
echo "add_attributes.csh"
echo "-----------------------"
echo "Input arguments:"
echo " ann_file = $ann_file"
echo " climodir = $climodir"
echo " "

set coord_file = $DIAG_ETC/variable_horizontal_coordinates

foreach line ("`cat $coord_file`")
   set var  = `echo $line | awk '{print $1}'`
   set clon = `echo $line | awk '{print $2}'`
   set clat = `echo $line | awk '{print $3}'`
   /usr/local/bin/ncks --quiet -d depth,0 -d x,0 -d y,0 -v $var $climodir/$ann_file >&! /dev/null
   if ($status == 0) then
      echo "Adding coordinates attribute to $var if necessary."
      /usr/local/bin/ncatted -a coordinates,$var,c,c,"$clon $clat" $climodir/$ann_file
   endif
end
