#!/bin/bash

#****************************************************
# Creates script for removing the present climatology
# in $diag_out/climo
#****************************************************
# Johan Liakka 18/9/17
# johan.liakka@nersc.no
#
# $diag_out       Diagnostics output directory
# $rundir         Directory of your amwg script
#
#----------------------------------------------------
# Check arguments and set input variables

if [ "$#" -ne 2 ]; then
  echo "$#"
  echo "usage: create_clean_climo.sh diag_out rundir"
  exit
fi

cat             >$2/clean_climo.csh <<EOT
#!/bin/csh -f
# Automatically generated script for removing the present climatology data
# `date`
EOT

sed "s#\$1#$1#" >>$2/clean_climo.csh <<'EOF'
set dir_list = `ls $1/climo`
if ( "$dir_list" == "" ) then
   echo "THE CLIMATOLOGY (IN $1/climo) HAS ALREADY BEEN DELETED"
else
   cd $1/climo
   foreach sub_dir ($dir_list)
      echo "DELETING $1/climo/$sub_dir ..."
      rm -r $sub_dir
   end
endif
echo ' '
echo "NORMAL EXIT FROM SCRIPT"
date
EOF

/usr/bin/chmod 755 $2/clean_climo.csh
