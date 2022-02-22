#!/bin/bash

# CISM DIAGNOSTICS package: determine_ts_yrs.sh
# PURPOSE: determine first and last years of time series (only if TRENDS_ALL=1)
# Heiko Goelzer, NORCE; Jan 2021
# Based on BLOM package

# Input arguments:
#  $casename  simulation name
#  $pathdat   history file directory

casename=$1
pathdat=$2

echo " "
echo "-----------------------"
echo "determine_ts_yrs.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " pathdat  = $pathdat"
echo " "
echo "Searching for annual history files..."

# Determine file tag
ls $pathdat/${casename}.cism.*.${first_yr_prnt}*.nc >/dev/null 2>&1
[ $? -eq 0 ] && filetag=cism 

file_head=$casename.$filetag.h.
file_prefix=$pathdat/$file_head
first_file=`ls ${file_prefix}* | head -n 1`
last_file=`ls ${file_prefix}* | tail -n 1`

if [ -z $first_file ]; then
    echo "Found no history files in $pathdat"
    echo "*** EXITING THE SCRIPT ***"
    exit 1
else
    fyr_prnt_ts=`echo $first_file | rev | cut -c 16-19 | rev`
    first_yr_ts=`echo $fyr_prnt_ts | sed 's/^0*//'`
    lyr_prnt_ts=`echo $last_file | rev | cut -c 16-19 | rev`
    last_yr_ts=`echo $lyr_prnt_ts | sed 's/^0*//'`
    if [ $first_yr_ts -eq $last_yr_ts ]; then
        echo "ERROR: first and last year in $casename are identical: cannot compute trends"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
fi
echo $first_yr_ts > $WKDIR/attributes/ts_yrs_${casename}
echo $last_yr_ts >> $WKDIR/attributes/ts_yrs_${casename}

