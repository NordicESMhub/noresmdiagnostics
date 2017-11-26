#!/bin/csh
# Makes a html redirect file and copies the time series file
# Johan Liakka, NERSC, Nov 2017

if ($#argv != 7) then
  echo "usage: setup_plots.csh <tar_file> <publish_html_path> <full_url>"
  exit
endif

set tar_file  = $1
set html_path = $2
set full_url  = $3
set tset1     = $4
set casetype  = $5
set col_type  = $6
set image     = $7

cd $html_path

cat >${tar_file}.html << EOF
<html>
<head>
<meta http-equiv="refresh" content="0; url=http://${full_url}"/>
</head>
</html>
EOF

if ($tset1 == 0) then
   if ($casetype == OBS) then
      if ($col_type == COLOR) then
         set tset_file = tset1_FSNT-FLNT_obsc
      else
         set tset_file = tset1_FSNT-FLNT_obs
      endif
   else
      if ($col_type == COLOR) then
         set tset_file = tset1_FSNT-FLNT_c
      else
         set tset_file = tset1_FSNT-FLNT
      endif
   endif

   if (! -e $html_path/$tar_file/tset1/${tset_file}.${image}) then
      echo " WARNING: $html_path/tset1/$tset_file does not exist."
   else
      if ($casetype == OBS) then
         /usr/bin/cp $html_path/$tar_file/tset1/${tset_file}.$image $html_path/FSNT-FLNT_vs_yrs.$image
      else
         /usr/bin/cp $html_path/$tar_file/tset1/${tset_file}.$image $html_path/FSNT-FLNT_2models_vs_yrs.$image
      endif
   endif
endif


