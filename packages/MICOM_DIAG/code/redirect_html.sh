#!/bin/bash

# MICOM DIAGNOSTICS package: redirect_html.sh
# PURPOSE: creates a file with redirects to index.html directly from $publish_html_path
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017                                                                                                                                                                                     

# Input arguments:
#  $webfold     folder name of html data
#  $html_path   path to the html
#  $full_url    URL to view the results

webfold=$1
html_path=$2
full_url=$3

echo " "
echo "-----------------------"
echo "redirect_html.sh"
echo "-----------------------"
echo "Input arguments:"
echo " webfold   = $webfold"
echo " html_path = $html_path"
echo " full_url  = $full_url"
echo " "

echo "Creating a redirect file to $full_url"
echo "from $html_path"

cd $html_path
cat >${webfold}.html << EOF
<html>
<head>
<meta http-equiv="refresh" content="0"; url="${full_url}"/>
</head>
</html>
EOF

