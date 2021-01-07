#!/bin/bash
script_start=`date +%s`
#
# CISM DIAGNOSTICS package: compute_ann_time_series.sh
# PURPOSE: computes annual time series from annual files
# Heiko Goelzer, NORCE Jan 2021 (heig@horceresearch.no)
# Based on BLOM version

# Input arguments:
#  $filetype  h
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $tsdir     directory where the climatology files are located

filetype=$1
casename=$2
first_yr=$3
last_yr=$4
pathdat=$5
tsdir=$6

echo " "
echo "---------------------------"
echo "compute_ann_time_series.sh"
echo "---------------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " tsdir    = $tsdir"
echo " "

first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`
ann_ts_file=${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts.nc

#var_list=$(cat $WKDIR/attributes/vars_ts_ann_${casename}_${filetype})
var_list=thk,smb,artm,usurf,topg

# COMPUTE ANNUAL TIME SERIES FROM HISTORY FILES
YR=$first_yr
outfilenames=()
while [ $YR -le $last_yr ]
do
    yr_prnt=`printf "%04d" ${YR}`
    filename=$(ls -1 ${pathdat}/${casename}.cism.h.${yr_prnt}-01-01-00000.nc 2>/dev/null |tail -1)
    outname=$WKDIR/${casename}_ANN_${yr_prnt}.nc
    outfilenames+=($outname)
    let YR++
    echo $filename
#    for var in $(echo $var_list | sed "s/,/ /g"); do
#	echo $var
#    done
    # Average variables; should be weighted by area!
    $NCWA -O -v $var_list -a x1,y1 --no_tmp_fl $filename $outname
done

# join annual files into one time series
$NCRCAT -O ${outfilenames[*]} ${tsdir}/$ann_ts_file

# Integrate thickness
YR=$first_yr
outfilenames=()
while [ $YR -le $last_yr ]
do
    yr_prnt=`printf "%04d" ${YR}`
    filename=$(ls -1 ${pathdat}/${casename}.cism.h.${yr_prnt}-01-01-00000.nc 2>/dev/null |tail -1)
    outname=$WKDIR/${casename}_ANN_vol_${yr_prnt}.nc
    outfilenames+=($outname)
    let YR++
    echo $filename
    # Integrate volume; should be weighted by area!
    $NCWA -O -N -v thk -a x1,y1 --no_tmp_fl $filename $outname
done

# join annual files into one time series
$NCRCAT -O ${outfilenames[*]} ${tsdir}/thk_tmp.nc

# Scale with area and append to output
$NCAP2 -O -s "thk=thk*4000*4000" ${tsdir}/thk_tmp.nc ${tsdir}/thk_tmp.nc
$NCKS -A ${tsdir}/thk_tmp.nc ${tsdir}/$ann_ts_file

# Rename integrated variables
ncrename -v thk,vol ${tsdir}/$ann_ts_file
ncrename -v smb,smbga ${tsdir}/$ann_ts_file
ncrename -v artm,artmga ${tsdir}/$ann_ts_file
ncrename -v usurf,usurfga ${tsdir}/$ann_ts_file
ncrename -v topg,topgga ${tsdir}/$ann_ts_file

echo $ann_ts_file

#YR=$last_yr
#yr_prnt=`printf "%04d" ${YR}`
#ls -1 ${pathdat}/${casename}.cism.h.${yr_prnt}-01-01-00000.nc
#filename=$(ls -1 ${pathdat}/${casename}.cism.h.${yr_prnt}-01-01-00000.nc 2>/dev/null |tail -1)
	   
script_end=`date +%s`
runtime_s=`expr ${script_end} - ${script_start}`
runtime_script_m=`expr ${runtime_s} / 60`
min_in_secs=`expr ${runtime_script_m} \* 60`
runtime_script_s=`expr ${runtime_s} - ${min_in_secs}`
echo "ANNUAL TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"

