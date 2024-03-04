#!/bin/env bash
set -e

# this will download all individual files to the current folder

dfolders=(CAM_DIAG/cam_data)
dfolders+=(CAM_DIAG/map_files)
dfolders+=(CAM_DIAG/obs_data)
dfolders+=(CICE_DIAG/data)
dfolders+=(CICE_DIAG/grids)
dfolders+=(CLM_DIAG/obs_data)
dfolders+=(CLM_DIAG/regriddingFiles)
dfolders+=(HAMOCC_DIAG/grid_files)
dfolders+=(HAMOCC_DIAG/obs_data)
dfolders+=(BLOM_DIAG/grid_files)
dfolders+=(BLOM_DIAG/obs_data)

cwd=$(pwd)
rm -f ./input_dirs.txt

if [ -d /trd-project1 ];then
    cd /trd-project1/NS2345K/www/diagnostics/inputdata
elif [ -d /projects ]; then
    cd /projects/NS2345K/www/diagnostics/inputdata
else
    echo "** ERROR: determing the inputdata path **" 
    exit 1
fi

for folder in ${dfolders[*]}
do
    find $folder/ -type d -print >>/tmp/input_dirs.txt
done
sort /tmp/input_dirs.txt >${cwd}/input_dirs.txt
rm -f /tmp/input_dirs.txt
echo "Updated inputdata direcotry tree:"
echo "${cwd}/input_dirs.txt"
#
tree -D --timefmt "%F %H:%M" $folder >${cwd}/input_files.txt
echo "Updated inputdata file tree:"
echo "${cwd}/input_files.txt"
