#!/bin/env bash
set -e

# this will download all individual files to the current folder

if [ -z $1 ]; then
    diagroot=".."
else
    if [ $1 == "-h" ] || [ $1 == "--help" ]; then
        echo "Usage: ./dloaddata.sh /root/path/to/the/tool"
        exit
    else
        diagroot=$1
    fi
fi

#if [ ! -d ../packages ]; then
    #echo "This script must be executed under the ROOT_OF_PACAKAGE/bin"
    #echo " *** EXIT ***"
    #exit 1
#fi

# check if symbolic links already exist
for subfolder in $(cat inputdata.txt |cut -d"/" -f1,2 |sort -u)
do
    if [ -L ${diagroot}/packages/$subfolder ]; then
        echo "../packages/$subfolder is already a symbolic link pointing to:"
        echo "$(stat -c %N ${diagroot}/packages/$subfolder)"
        echo " *** EXIT ***"
        exit
    fi
done

# download all observation and grid data
while read -r subfolder
do
    echo ${subfolder}
    wget --timestamping -nd -r -nH -np -R "index.html*"  --directory-prefix=${diagroot}/packages/${subfolder}/ \
        http://ns2345k.web.sigma2.no/diagnostics/inputdata/${subfolder}/
done <./inputdata.txt
