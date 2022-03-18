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
rm -f ./inputdata.txt

cd /trd-project1/NS2345K/www/diagnostics/inputdata

for folder in ${dfolders[*]}
do
    find $folder/ -type d -print >>${cwd}/inputdata.txt
done
echo "Updated inputdata direcotry tree:"
echo "${cwd}/inputdata.txt"
