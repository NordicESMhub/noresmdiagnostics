#!/bin/csh -f

# This file creates a list of netCDF files and averages these to get
# seasonal and annual means.  Input data is:
#
# $date_format  form of date in history file name (eg. yyyy-mm), input
# $PATHDAT  directory on dataproc where data is 
# $FILE_HEADER  beginning of filename
# $first_year first year to be averaged
# $last_year last year to be averaged
# $SEAS_MEAN seasonal mean

if ($#argv != 4) then
  echo "usage: avg_netcdf.csh $FIRST_YEAR $LAST_YEAR $VAR_NAME_TYPE $djf"
  exit
endif

@ first_yr = $1
@ last_yr = $2
set var_name_type = $3
set djf = $4

if ($var_name_type == OLD) then
   set modelname = cism
else
   set modelname = cice
endif
set djf_md = scd
if ( $djf == SDD ) then
   set djf_md = sdd
endif

# amj_avg_0011-0050.nc  ASPeCt_monthly_1x1.nc  jas_avg_0011-0050.nc  on_avg_0011-0050.nc   SSMI.ifrac.1979-2000monthlymean.gx1v5.nc
# ann_avg_0011-0050.nc  fm_avg_0011-0050.nc    jfm_avg_0011-0050.nc  ond_avg_0011-0050.nc

set first_yr_prnt = `printf "%04d" ${first_yr}`
set last_yr_prnt = `printf "%04d" ${last_yr}`

# Determine grid type

set nj = `$ncksbin/ncks --trd -m -M ${PATHDAT}/${CASE_READ}.cice.h.${first_yr_prnt}-01.nc | grep -E -i ": nj, size =" | cut -f 7 -d ' ' | uniq |tr -d ','`
set ni = `$ncksbin/ncks --trd -m -M ${PATHDAT}/${CASE_READ}.cice.h.${first_yr_prnt}-01.nc | grep -E -i ": ni, size =" | cut -f 7 -d ' ' | uniq |tr -d ','`
@ gp = $nj * $ni
if ( $gp > 1000000 ) then
    set njobs = 1
else
    set njobs = 12
endif

$ncclimo_dir/ncclimo --job_nbr=$njobs --no_stdin -m $modelname --clm_md=mth --seasons=amj,ann,fm,jas,jfm,on,ond --no_amwg_links -a $djf_md -h h -c $CASE_READ -s $first_yr -e $last_yr -i $PATHDAT -o $PATHJLS
if ($status == 0) then
   mv ${PATHJLS}/${CASE_READ}_AMJ_*_climo.nc ${PATHJLS}/amj_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   mv ${PATHJLS}/${CASE_READ}_ANN_*_climo.nc ${PATHJLS}/ann_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   mv ${PATHJLS}/${CASE_READ}_FM_*_climo.nc ${PATHJLS}/fm_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   mv ${PATHJLS}/${CASE_READ}_JAS_*_climo.nc ${PATHJLS}/jas_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   mv ${PATHJLS}/${CASE_READ}_JFM_*_climo.nc ${PATHJLS}/jfm_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   mv ${PATHJLS}/${CASE_READ}_ON_*_climo.nc ${PATHJLS}/on_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   mv ${PATHJLS}/${CASE_READ}_OND_*_climo.nc ${PATHJLS}/ond_avg_${first_yr_prnt}-${last_yr_prnt}.nc
   foreach mth (01 02 03 04 05 06 07 08 09 10 11 12)
      rm ${PATHJLS}/${CASE_READ}_${mth}_*_climo.nc
   end
   foreach ses (amj ann fm jas jfm on ond)
      set file = ${PATHJLS}/${ses}_avg_${first_yr_prnt}-${last_yr_prnt}.nc
      if ( ` ncdump -h $file | grep ' uvel(' | wc -l ` == 0 ) then
        echo "Renames siu,siv to uvel,vvel in $file"
        $ncclimo_dir/ncrename -v .siu,uvel -v .siv,vvel -O $file
      endif
   end
endif

  
