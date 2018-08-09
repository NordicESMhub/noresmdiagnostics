#!/bin/csh
# Makes a html redirect file and copies the time series file
# Johan Liakka, NERSC, Nov 2017

if ($#argv != 3) then
  echo "usage: setup_plots.csh <tar_file> <publish_html_path> <full_url>"
  exit
endif

set tar_file  = $1
set html_path = $2
set full_url  = $3

cd $html_path

/usr/bin/cat >${tar_file}.html << EOF
<html>
<head>
<meta http-equiv="refresh" content="0; url=http://${full_url}"/>
</head>
</html>
EOF



