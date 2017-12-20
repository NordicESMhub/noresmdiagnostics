#! /bin/sh

set -x

orig=$1
shift

new=new.html
delta=$(mktemp deltaXXXXXX)

cp $orig $new

for edited in $*; do

  # diff3 [OPTION]... MYFILE OLDFILE YOURFILE
  # Output unmerged changes from OLDFILE to YOURFILE into MYFILE.

  diff3 -m $new $orig $edited >$delta
  mv $delta $new

done
#cat $new
#rm $new
