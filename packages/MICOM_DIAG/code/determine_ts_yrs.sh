#!/bin/bash

# MICOM DIAGNOSTICS package: determine_ts_yrs.sh
# PURPOSE: determine first and last years of time series (only if TRENDS_ALL=1)
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

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
file_head=$casename.micom.hy.
file_prefix=$pathdat/$file_head
first_file=`ls ${file_prefix}* | head -n 1`
last_file=`ls ${file_prefix}* | tail -n 1`
if [ -z $first_file ]; then
    echo "Found no annual history files in $pathdat"
    echo "Searcing for monthly history files"
    file_head=$casename.micom.hm.
    file_prefix=$pathdat/$file_head
    first_file=`ls ${file_prefix}* | head -n 1`
    last_file=`ls ${file_prefix}* | tail -n 1`
    if [ -z $first_file ]; then
        echo "ERROR: found no monthly history files in $pathdat"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    else
        fyr_prnt_ts=`echo $first_file | rev | cut -c 7-10 | rev`
        first_yr_ts=`echo $fyr_prnt_ts | sed 's/^0*//'`
        lyr_prnt_ts=`echo $last_file | rev | cut -c 7-10 | rev`
        last_yr_ts=`echo $lyr_prnt_ts | sed 's/^0*//'`
        # Check that last file is a december file (for a full year)
        if [ ! -f $pathdat/${file_head}${lyr_prnt_ts}-12.nc ]; then
            let "last_yr_ts = $last_yr_ts - 1"
            lyr_prnt_ts=`printf "%04d" ${last_yr_ts}`
        fi
        if [ $first_yr_ts -eq $last_yr_ts ]; then
            echo "ERROR: first and last year in $casename are identical: cannot compute trends"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    fi
else
    fyr_prnt_ts=`echo $first_file | rev | cut -c 4-7 | rev`
    first_yr_ts=`echo $fyr_prnt_ts | sed 's/^0*//'`
    lyr_prnt_ts=`echo $last_file | rev | cut -c 4-7 | rev`
    last_yr_ts=`echo $lyr_prnt_ts | sed 's/^0*//'`
    if [ $first_yr_ts -eq $last_yr_ts ]; then
        echo "ERROR: first and last year in $casename are identical: cannot compute trends"
        echo "*** EXITING THE SCRIPT ***"
        exit 1
    fi
fi
echo $first_yr_ts > $WKDIR/attributes/ts_yrs_${casename}
echo $last_yr_ts >> $WKDIR/attributes/ts_yrs_${casename}

