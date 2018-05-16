#!/bin/csh -f

unset echo verbose

#*****************************************************************
# Get the file from the MSS if they don t exist locally
#*****************************************************************

# This file reads in files from HPSS
# $path_history     The local directory for history files
# $path_climo       The local directory for climo files
# $path_diag        The local directory for diag files
# $first_yr       The first year of data
# $nyrs             The number of years of data 
# $casename         The casename  
# $rootname         The rootname  
# $weight_months    Flag for climo with weigh months 
# $strip_off_vars   Flag to strip variables 
# $casetype         test or cntl 
# $djf              PREV or NEXT 
# $significance     significance 

if ($#argv != 14) then
  echo "usage: compute_climo.csh: incorrect number of argument"
  exit
endif

set path_history  = $1
set path_climo = $2
set path_diag  = $3
@ first_yr = $4
@ nyrs = $5
set casename = $6
set rootname = $7
set weight_months = $8 
set strip_off_vars  = $9
set casetype = $10
set djf = $11
set significance = $12
set file_type = $13
set DIAG_CODE = $14

set non_time_var_list=`cat ${path_diag}/attributes/${casetype}_non_time_var_list`
set var_list=`cat ${path_diag}/attributes/${casetype}_var_list`

if ($file_type == "time_series") then
  cat ${path_climo}/${casetype}_file_list.txt
  set time_series_files = `cat ${path_climo}/${casetype}_file_list.txt`
endif

#------------------------------------------------------------------------

# the monthly time weights
# the ann time weights
set ann_weights = ( 0.08493150770664215 0.07671232521533966 0.08493150770664215 \
    0.08219178020954132 0.08493150770664215 0.08219178020954132 0.08493150770664215 \
    0.08493150770664215 0.08219178020954132 0.08493150770664215 0.08219178020954132 \
    0.08493150770664215)
# the djf time weights
set djf_weights = (0.3444444537162781 0.3444444537162781 0.3111111223697662)
# the mam time weights
set mam_weights = (0.3369565308094025 0.3260869681835175 0.3369565308094025)
# the jja time weights
set jja_weights = (0.3260869681835175 0.3369565308094025 0.3369565308094025)
# the son time weights
set son_weights = (0.32967033 0.34065934 0.32967033)

#------------------------------------------------------------------------
# save unweighted variables
#
if ($weight_months == 0) then
     if ($file_type == "monthly_history") then
        set filename = ${rootname}`printf "%04d" ${first_yr}`-01.nc
        ncks -C -O -v $non_time_var_list ${path_history}/${filename} ${path_climo}/unweighted.nc
     else
        set split_line = `echo $time_series_files[1]:q | sed 's/,/ /g'`
        set ts_file_temp = $split_line[1]
        set var_list_f = `cat ${path_climo}/"var_list.txt"`
        if ($var_list_f[1] == null) then
         set ts_file = ${ts_file_temp}${split_line[2]}-${split_line[3]}_cat_${split_line[4]}-${split_line[5]}.nc
        else
          set ts_file = ${ts_file_temp}${var_list_f[1]}.${split_line[2]}-${split_line[3]}_cat_${split_line[4]}-${split_line[5]}.nc
        endif
        ncks -C -O -v ${non_time_var_list} ${ts_file} ${path_climo}/unweighted.nc
     endif
endif

##------------------------------------------------------------------------
# Old terminology
set conv_test = $rootname
set test_out = ${path_climo}/${casename}
#------------------------------------------------------------------------

echo COMPUTING $casetype CASE ANNUAL AVERAGES
# average testcase files
set conv_test = $rootname
@ yr_cnt = $first_yr
@ yr_end = $first_yr + $nyrs - 1  
set ave_yrs = $yr_cnt-$yr_end
while ( $yr_cnt <= $yr_end )               # loop over years
  set yr_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
  if (-e {$test_out}_{$yr_prnt}_ANN.nc) then
    \rm -f {$test_out}_{$yr_prnt}_ANN.nc
  endif
  if ($file_type == "monthly_history") then
    ls {$path_history}/{$yr_prnt}*.nc > {$path_climo}/monthly_files   
    set files = `cat {$path_climo}/monthly_files`
  else
    set year_slice_file = ${path_climo}/year_slice.txt
    if (-e $year_slice_file) then
      /bin/rm $year_slice_file
    endif
    $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                          $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
    set files = `cat $year_slice_file`
  endif
  if ($weight_months == 0) then
# apply the weights to the monthly files
     foreach m (1 2 3 4 5 6 7 8 9 10 11 12)
     set DATE=`date`;
     set month = `printf "%02d" {$m}` 
        if (-z $files[$m]) then
           echo "ERROR - Empty file:"  $files[$m]
        else
           if ($strip_off_vars == 0) then 
             if ($file_type == "monthly_history") then
               ncflint -O -c -v $var_list -w $ann_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.${month}.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -c -v $var_list -w $ann_weights[$m],0.0 -F -d time,$i,$i,1 \
                     $ts_file $ts_file {$path_climo}/wgt_month.${month}.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -w $ann_weights[$m],0.0 -F -d time,$i,$i,1 \
                    $ts_file $ts_file {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.${month}.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.${month}.nc     
                 /bin/rm -f $vf
               end
             endif
          else
             if ($file_type == "monthly_history") then    
               ncflint -O -C -x -v $non_time_var_list -w $ann_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.${month}.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint  -O -C -x -v $non_time_var_list -w $ann_weights[$m],0.0 -F -d time,$i,$i,1 \
                   $ts_file $ts_file {$path_climo}/wgt_month.${month}.nc
                  else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint  -O -C -x -v $non_time_var_list -w $ann_weights[$m],0.0 -F -d time,$i,$i,1 \
                   $ts_file $ts_file {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.${month}.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.${month}.nc                 
                 /bin/rm -f $vf
               end
             endif
           endif  
        endif
     end
# sum the weighted files to make the climo file
    ls {$path_climo}/wgt_month.*.nc > {$path_climo}/weighted_files
    set files = `cat {$path_climo}/weighted_files`
    ncea -O -y ttl $files {$test_out}_{$yr_prnt}_ANN.nc 
# append the needed non-time varying variables
    ncks -C -A -v $non_time_var_list {$path_climo}/unweighted.nc {$test_out}_{$yr_prnt}_ANN.nc
    echo {$yr_prnt}' WEIGHTED TIME AVERAGE'
  else
    if ($file_type == "monthly_history") then
      ncea -O $files {$test_out}_{$yr_prnt}_ANN.nc 
    else
      foreach mth (01 02 03 04 05 06 07 08 09 10 11 12)
        set split_line = `echo $files[$mth]:q | sed 's/,/ /g'`
        set ts_file_temp = $split_line[1]
        set i = $split_line[2]
        set year1 = $split_line[3]
        set month1 = $split_line[4]
        set year2 = $split_line[5]
        set month2 = $split_line[6]
           
        set var_list_f = `cat ${path_climo}/"var_list.txt"`
        foreach var ($var_list_f)
          if ($var == null) then
            set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
            ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.nc 
          else
            set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
            ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.${var}.nc
          endif
        end
        set var_files = `ls ${path_climo}/temp_${mth}.*.nc`
        foreach vf ($var_files)
          ncks -A $vf ${path_climo}/temp_${mth}.nc
          /bin/rm -f $vf
         end
      end
      ls {$path_climo}/temp_*.nc | ncea -O  {$test_out}_{$yr_prnt}_ANN.nc
      rm -f {$path_climo}/temp_*.nc
    endif
    echo {$yr_prnt}' TIME AVERAGE'
  endif
@ yr_cnt++
end 
# clean up
if ($weight_months == 0) then
  \rm -f {$path_climo}/weighted_files
  \rm -f {$path_climo}/wgt_month.*.nc
endif
\rm -f {$path_climo}/monthly_files
echo ' '

#set DATE=`date`; echo 'ceh----------Date after: '$DATE

#--------------------------------------------------------
#   CALC TEST CASE ANNUAL CLIMATOLOGY 
#--------------------------------------------------------
echo COMPUTING $casetype CASE CLIMO ANNUAL MEAN 
if ($nyrs == 1) then
  /bin/mv {$test_out}_{$yr_prnt}_ANN.nc {$test_out}_ANN_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$first_yr {$test_out}_ANN_climo.nc
else
# use test case output files from previous step
  ls {$test_out}_*_ANN.nc > {$path_climo}/annual_files
  set files = `cat {$path_climo}/annual_files`
  ncea -O $files {$test_out}_ANN_climo.nc   
  ncatted -O -a yrs_averaged,global,c,c,$ave_yrs {$test_out}_ANN_climo.nc 
  if ($significance == 0) then
    ncrcat -O $files {$test_out}_ANN_means.nc
  endif 
  \rm -f {$test_out}*ANN.nc
  \rm -f {$path_climo}/annual_files
endif
set test_in = $test_out
echo ' '


#*********************************************************
# CALCULATE SEASONAL AVERAGES
#*********************************************************
# COMPUTE TEST CASE DJF AVERAGES
#--------------------------------------------------------

echo COMPUTING $casetype CASE DJF AVERAGES
@ yr_cnt = $first_yr
@ yr_end = $first_yr + $nyrs - 1 
set ave_yrs = $yr_cnt-$yr_end
while ( $yr_cnt <= $yr_end )
  set yr_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
  if ($yr_cnt >= 1) then
    if ($djf == PREV) then
      @ yr_cnt--
      if ($file_type == "monthly_history") then
        set yr_last_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
        set dec = {$path_history}/{$yr_last_prnt}-12.nc
        set jan = {$path_history}/{$yr_prnt}-01.nc
        set feb = {$path_history}/{$yr_prnt}-02.nc
        @ yr_cnt++
      else
        set year_slice_file = ${path_climo}/year_slice.txt
        if (-e $year_slice_file) then
          /bin/rm $year_slice_file
        endif
        $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
        set files1 = `cat $year_slice_file`
        
        @ yr_cnt++
        if (-e $year_slice_file) then
          /bin/rm $year_slice_file
        endif
        $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
        set files2 = `cat $year_slice_file` 
      endif 
    else
      @ yr_cnt++
      if ($file_type == "monthly_history") then
        set yr_next_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
        set dec = {$path_history}/{$yr_prnt}-12.nc
        set jan = {$path_history}/{$yr_next_prnt}-01.nc
        set feb = {$path_history}/{$yr_next_prnt}-02.nc
        @ yr_cnt--
      else
        set year_slice_file = ${path_climo}/year_slice.txt
        if (-e $year_slice_file) then
          /bin/rm $year_slice_file
        endif
        $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
        set files1 = `cat $year_slice_file`

        @ yr_cnt--
        if (-e $year_slice_file) then
          /bin/rm $year_slice_file
        endif
        $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
        set files2 = `cat $year_slice_file` 
      endif
    endif
    if (-e {$test_out}_{$yr_prnt}_DJF.nc) then
      \rm -f {$test_out}_{$yr_prnt}_DJF.nc
    endif
    if ($file_type == "monthly_history") then
      set files = ($dec $jan $feb)
    else
      set files = ($files1[12] $files2[1] $files2[2])
    endif
    if ($weight_months == 0) then
#   apply the weights to the monthly files
      foreach m (1 2 3)
        set month = `printf "%02d" {$m}`
        if (-z $files[$m]) then 
          echo "ERROR - Empty file:"  $files[$m]
        else
           if ($strip_off_vars == 0) then
             if ($file_type == "monthly_history") then
               ncflint -O -c -v $var_list -w $djf_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.$month.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                  if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -c -v $var_list -w $djf_weights[$m],0.0 -F -d time,$i,$i,1 \
                     $ts_file $ts_file {$path_climo}/wgt_month.${month}.nc
                  else
                    set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                    ncflint -O -w $djf_weights[$m],0.0 -F -d time,$i,$i,1 \
                       $ts_file $ts_file {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                  endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.$month.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.$month.nc
                 /bin/rm -f $vf
               end
             endif
          else 
             if ($file_type == "monthly_history") then   
               ncflint -O -C -x -v $non_time_var_list -w $djf_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.${month}.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $djf_weights[$m],0.0 -F -d time,$i,$i,1 \
                     $ts_file $ts_file  {$path_climo}/wgt_month.${month}.nc
                 else
                   set ts_file = $ts_file_temp$var.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $djf_weights[$m],0.0 -F -d time,$i,$i,1 \
                     $ts_file $ts_file  {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.${month}.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.${month}.nc
                 /bin/rm -f $vf
               end
             endif
           endif  
        endif
      end
#   sum the weighted files to make the climo file
      ls {$path_climo}/wgt_month.*.nc > {$path_climo}/weighted_files
      set files = `cat {$path_climo}/weighted_files`
      ncea -O -y ttl $files {$test_out}_{$yr_prnt}_DJF.nc 
#   append the needed non-time varying variables
      ncks -C -A -v $non_time_var_list {$path_climo}/unweighted.nc {$test_out}_{$yr_prnt}_DJF.nc
      echo {$yr_prnt}' WEIGHTED TIME AVERAGE'
    else
      if ($file_type == "monthly_history") then
        ncea -O $files {$test_out}_{$yr_prnt}_DJF.nc
      else
        foreach mth (01 02 03)
          set split_line = `echo $files[$mth]:q | sed 's/,/ /g'`
          set ts_file_temp = $split_line[1]
          set i = $split_line[2]
          set year1 = $split_line[3]
          set month1 = $split_line[4]
          set year2 = $split_line[5]
          set month2 = $split_line[6]
             
          set var_list_f = `cat ${path_climo}/"var_list.txt"`
          foreach var ($var_list_f)
            if ($var == null) then
              set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
              ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.nc
            else
              set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
              ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.${var}.nc
            endif
           end
           set var_files = `ls ${path_climo}/temp_${mth}.*.nc`
           foreach vf ($var_files)
             ncks -A $vf ${path_climo}/temp_${mth}.nc
             /bin/rm -f $vf
           end
        end
        ls {$path_climo}/temp_*.nc | ncea -O {$test_out}_{$yr_prnt}_DJF.nc
        rm -f {$path_climo}/temp_*.nc
      endif
      echo {$yr_prnt}' TIME AVERAGE'
    endif
  endif
  @ yr_cnt++               
end
# clean up
if ($weight_months == 0) then
  \rm -f {$path_climo}/weighted_files
  \rm -f {$path_climo}/wgt_month.*.nc
endif
echo ' '
#---------------------------------------------------------
#  COMPUTE TEST CASE DJF CLIMATOLOGY 
#---------------------------------------------------------
echo COMPUTING $casetype CASE DJF CLIMO MEAN 
if ($nyrs == 1) then
  /bin/mv {$test_out}_{$yr_prnt}_DJF.nc {$test_out}_DJF_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$first_yr {$test_out}_DJF_climo.nc
else
  ls {$test_out}_*_DJF.nc > {$path_climo}/seasonal_files
  set files = `cat {$path_climo}/seasonal_files`
  ncea -O $files {$test_out}_DJF_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$ave_yrs {$test_out}_DJF_climo.nc 
  if ($significance == 0) then
    ncrcat -O $files {$test_out}_DJF_means.nc
  endif 
  \rm -f {$test_out}*DJF.nc
  \rm -f {$path_climo}/seasonal_files
endif
set test_in = $test_out
echo ' '

#-----------------------------------------------------------
# COMPUTE TEST CASE MAM AVERAGES
#-----------------------------------------------------------

echo COMPUTING $casetype CASE MAM AVERAGES
@ yr_cnt = $first_yr
@ yr_end = $first_yr + $nyrs - 1
set ave_yrs = $yr_cnt-$yr_end
while ( $yr_cnt <= $yr_end )
  set yr_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
  if ($yr_cnt >= 1) then
  if ($file_type == "monthly_history") then
    set mar = {$path_history}/{$yr_prnt}-03.nc
    set apr = {$path_history}/{$yr_prnt}-04.nc
    set may = {$path_history}/{$yr_prnt}-05.nc
    set files = ($mar $apr $may)
  else
    set year_slice_file = ${path_climo}/year_slice.txt
    if (-e $year_slice_file) then
      /bin/rm $year_slice_file
    endif
    $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
    set all_files = `cat $year_slice_file`
    set files = ($all_files[3] $all_files[4] $all_files[5])
  endif
    if (-e {$test_out}_{$yr_prnt}_MAM.nc) then
      \rm -f {$test_out}_{$yr_prnt}_MAM.nc
    endif
    if ($weight_months == 0) then
#   apply the weights to the monthly files
      foreach m (1 2 3)
      set month = `printf "%02d" {$m}`
      if (-z $files[$m]) then
        echo "ERROR - Empty file:"  $files[$m]
      else
         if ($strip_off_vars == 0) then
             if ($file_type == "monthly_history") then
               ncflint -O -c -v $var_list -w $mam_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.${month}.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -c -v $var_list -w $mam_weights[$m],0.0 -F -d time,$i,$i,1 \
                      $ts_file $ts_file {$path_climo}/wgt_month.$month.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -w $mam_weights[$m],0.0 -F -d time,$i,$i,1 \
                      $ts_file $ts_file {$path_climo}/wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/wgt_month.${month}.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.${month}.nc
                 /bin/rm -f $vf
               end
             endif
         else   
             if ($file_type == "monthly_history") then 
               ncflint -O -C -x -v $non_time_var_list -w $mam_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.${month}.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $mam_weights[$m],0.0 -F -d time,$i,$i,1 \
                      ts_file $ts_file {$path_climo}/wgt_month.$month.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $mam_weights[$m],0.0 -F -d time,$i,$i,1 \
                      ts_file $ts_file {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.$month.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.$month.nc
                 /bin/rm -f $vf
               end
             endif
         endif
      endif
      end
#   sum the weighted files to make the climo file
      ls {$path_climo}/wgt_month.*.nc > {$path_climo}/weighted_files
      set files = `cat {$path_climo}/weighted_files`
      ncea -O -y ttl $files {$test_out}_{$yr_prnt}_MAM.nc
#   append the needed non-time varying variables
      ncks -C -A -v $non_time_var_list {$path_climo}/unweighted.nc {$test_out}_{$yr_prnt}_MAM.nc
      echo {$yr_prnt}' WEIGHTED TIME AVERAGE'
    else
      if ($file_type == "monthly_history") then
        ncea -O $files {$test_out}_{$yr_prnt}_MAM.nc
      else
         foreach mth (01 02 03)
           set split_line = `echo $files[$mth]:q | sed 's/,/ /g'`
           set ts_file = $split_line[1]
           set i = $split_line[2]
           set year1 = $split_line[3]
           set month1 = $split_line[4]
           set year2 = $split_line[5]
           set month2 = $split_line[6]
             
           set var_list_f = `cat ${path_climo}/"var_list.txt"`
           foreach var ($var_list_f)
             if ($var == null) then
               set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
               ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.nc
             else
               set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
               ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.${var}.nc
             endif
           end
           set var_files = `ls ${path_climo}/temp_$mth.*.nc`
           foreach vf ($var_files)
             ncks -A $vf ${path_climo}/temp_$mth.nc
             /bin/rm -f $vf
           end
         end
         ls {$path_climo}/temp_*.nc | ncea -O  {$test_out}_{$yr_prnt}_MAM.nc
         rm -f {$path_climo}/temp_*.nc
      endif
      echo {$yr_prnt}' TIME AVERAGE'
    endif
  endif
  @ yr_cnt++
end
# clean up
if ($weight_months == 0) then
  \rm -f {$path_climo}/weighted_files
  \rm -f {$path_climo}/wgt_month.*.nc
endif
echo ' '
#---------------------------------------------------------
#  COMPUTE TEST CASE MAM CLIMATOLOGY
#---------------------------------------------------------
echo COMPUTING $casetype CASE MAM CLIMO MEAN
if ($nyrs == 1) then
  /bin/mv {$test_out}_{$yr_prnt}_MAM.nc {$test_out}_MAM_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$first_yr {$test_out}_MAM_climo.nc
else 
  ls {$test_out}_*_MAM.nc > {$path_climo}/seasonal_files
  set files = `cat {$path_climo}/seasonal_files`
  ncea -O $files {$test_out}_MAM_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$ave_yrs {$test_out}_MAM_climo.nc
  if ($significance == 0) then
    ncrcat -O $files {$test_out}_MAM_means.nc
  endif
  \rm -f {$test_out}*MAM.nc
  \rm -f {$path_climo}/seasonal_files
endif
set test_in = $test_out
echo ' '
#-----------------------------------------------------------
# COMPUTE TEST CASE JJA AVERAGES
#-----------------------------------------------------------

echo COMPUTING $casetype CASE JJA AVERAGES
@ yr_cnt = $first_yr
@ yr_end = $first_yr + $nyrs - 1 
set ave_yrs = $yr_cnt-$yr_end
while ( $yr_cnt <= $yr_end )
  set yr_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
  if ($yr_cnt >= 1) then
  if ($file_type == "monthly_history") then
    set jun = {$path_history}/{$yr_prnt}-06.nc
    set jul = {$path_history}/{$yr_prnt}-07.nc
    set aug = {$path_history}/{$yr_prnt}-08.nc
    set files = ($jun $jul $aug)
  else
    set year_slice_file = ${path_climo}/year_slice.txt
    if (-e $year_slice_file) then
      /bin/rm $year_slice_file
    endif
    $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
    set all_files = `cat $year_slice_file`
    set files = ($all_files[6] $all_files[7] $all_files[8])
   endif
    if (-e {$test_out}_{$yr_prnt}_JJA.nc) then
      \rm -f {$test_out}_{$yr_prnt}_JJA.nc
    endif
    if ($weight_months == 0) then
#   apply the weights to the monthly files
      foreach m (1 2 3)
        set month = `printf "%02d" {$m}`
        if (-z $files[$m]) then
          echo "ERROR - Empty file:"  $files[$m]
        else
           if ($strip_off_vars == 0) then
             if ($file_type == "monthly_history") then
               ncflint -O -c -v $var_list -w $jja_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.$month.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -c -v $var_list -w $jja_weights[$m],0.0  -F -d time,$i,$i,1 \
                       $ts_file $ts_file {$path_climo}/wgt_month.$month.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -w $jja_weights[$m],0.0  -F -d time,$i,$i,1 \
                       $ts_file $ts_file {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.${month}.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.${month}.nc
                 /bin/rm -f $vf
               end
             endif
           else    
             if ($file_type == "monthly_history") then
               ncflint -O -C -x -v $non_time_var_list -w $jja_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.$month.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file_temp = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]
             
               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $jja_weights[$m],0.0  -F -d time,$i,$i,1 \
                     $ts_file $ts_file {$path_climo}/wgt_month.$month.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $jja_weights[$m],0.0  -F -d time,$i,$i,1 \
                     $ts_file $ts_file {$path_climo}/tmp_wgt_month.$month.$var.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.${month}.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.${month}.nc
                 /bin/rm -f $vf
               end
             endif
           endif
        endif
      end
#   sum the weighted files to make the climo file
      ls {$path_climo}/wgt_month.*.nc > {$path_climo}/weighted_files
      set files = `cat {$path_climo}/weighted_files`
      ncea -O -y ttl $files {$test_out}_{$yr_prnt}_JJA.nc 
#   append the needed non-time varying variables
      ncks -C -A -v $non_time_var_list {$path_climo}/unweighted.nc {$test_out}_{$yr_prnt}_JJA.nc
      echo {$yr_prnt}' WEIGHTED TIME AVERAGE'
    else
      if ($file_type == "monthly_history") then
        ncea -O $files {$test_out}_{$yr_prnt}_JJA.nc
      else
        foreach mth (01 02 03)
          set split_line = `echo $files[$mth]:q | sed 's/,/ /g'`
          set ts_file = $split_line[1]
          set i = $split_line[2]
          set year1 = $split_line[3]
          set month1 = $split_line[4]
          set year2 = $split_line[5]
          set month2 = $split_line[6]

           set var_list_f = `cat ${path_climo}/"var_list.txt"`
           foreach var ($var_list_f)
             if ($var == null) then
               set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
               ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_$mth.nc
             else
               set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
               ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.${var}.nc
             endif
           end
           set var_files = `ls ${path_climo}/temp_$mth.*.nc`
           foreach vf ($var_files)
             ncks -A $vf ${path_climo}/temp_$mth.nc
             /bin/rm -f $vf
           end
        end
        ls {$path_climo}/temp_*.nc | ncea -O {$test_out}_{$yr_prnt}_JJA.nc
        rm -f {$path_climo}/temp_*.nc
      endif
      echo {$yr_prnt}' TIME AVERAGE'
    endif
  endif
  @ yr_cnt++               
end
# clean up
if ($weight_months == 0) then
  \rm -f {$path_climo}/weighted_files
  \rm -f {$path_climo}/wgt_month.*.nc
endif
echo ' '
#---------------------------------------------------------
#  COMPUTE TEST CASE JJA CLIMATOLOGY 
#---------------------------------------------------------
echo COMPUTING $casetype CASE JJA CLIMO MEAN 
if ($nyrs == 1) then
  /bin/mv {$test_out}_{$yr_prnt}_JJA.nc {$test_out}_JJA_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$first_yr {$test_out}_JJA_climo.nc
else
  ls {$test_out}_*_JJA.nc > {$path_climo}/seasonal_files 
  set files = `cat {$path_climo}/seasonal_files`
  ncea -O $files {$test_out}_JJA_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$ave_yrs {$test_out}_JJA_climo.nc 
  if ($significance == 0) then
    ncrcat -O $files {$test_out}_JJA_means.nc
  endif 
  \rm -f {$test_out}*JJA.nc
  \rm -f {$path_climo}/seasonal_files
endif
set test_in = $test_out
echo ' '
#-----------------------------------------------------------
#-----------------------------------------------------------
# COMPUTE TEST CASE SON AVERAGES
#-----------------------------------------------------------

echo COMPUTING $casetype CASE SON AVERAGES
@ yr_cnt = $first_yr
@ yr_end = $first_yr + $nyrs - 1
set ave_yrs = $yr_cnt-$yr_end
while ( $yr_cnt <= $yr_end )
  set yr_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
  if ($yr_cnt >= 1) then
  if ($file_type == "monthly_history") then
    set sep = {$path_history}/{$yr_prnt}-09.nc
    set oct = {$path_history}/{$yr_prnt}-10.nc
    set nov = {$path_history}/{$yr_prnt}-11.nc
    set files = ($sep $oct $nov)
  else
    set year_slice_file = ${path_climo}/year_slice.txt
    if (-e $year_slice_file) then
      /bin/rm $year_slice_file
    endif
    $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
    set all_files = `cat $year_slice_file`
    set files = ($all_files[9] $all_files[10] $all_files[11])
  endif
    if (-e {$test_out}_{$yr_prnt}_SON.nc) then
      \rm -f {$test_out}_{$yr_prnt}_SON.nc
    endif
    if ($weight_months == 0) then
#   apply the weights to the monthly files
      foreach m (1 2 3)
        set month = `printf "%02d" {$m}`
        if (-z $files[$m]) then
          echo "ERROR - Empty file:"  $files[$m]
        else
           if ($strip_off_vars == 0) then
             if ($file_type == "monthly_history") then
               ncflint -O -c -v $var_list -w $son_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.$month.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]
             
               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -c -v $var_list -w $son_weights[$m],0.0 -F -d time,$i,$i,1 \
                     $ts_file $ts_file {$path_climo}/wgt_month.$month.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -w $son_weights[$m],0.0 -F -d time,$i,$i,1 \
                     $ts_file $ts_file {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.$month.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.$month.nc
                 /bin/rm -f $vf
               end
             endif
           else    
             if ($file_type == "monthly_history") then
               ncflint -O -C -x -v $non_time_var_list -w $son_weights[$m],0.0 \
               $files[$m] $files[$m] {$path_climo}/wgt_month.$month.nc
             else
               set split_line = `echo $files[$m]:q | sed 's/,/ /g'`
               set ts_file = $split_line[1]
               set i = $split_line[2]
               set year1 = $split_line[3]
               set month1 = $split_line[4]
               set year2 = $split_line[5]
               set month2 = $split_line[6]
             
               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $son_weights[$m],0.0 -F -d time,$i,$i,1 \
                      $ts_file $ts_file  {$path_climo}/wgt_month.$month.nc
                 else 
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                   ncflint -O -C -x -v $non_time_var_list -w $son_weights[$m],0.0 -F -d time,$i,$i,1 \
                      $ts_file $ts_file  {$path_climo}/tmp_wgt_month.${month}.${var}.nc
                 endif
               end
               set var_files = `ls ${path_climo}/tmp_wgt_month.$month.*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/wgt_month.$month.nc
                 /bin/rm -f $vf
               end
             endif
           endif
        endif
      end
#   sum the weighted files to make the climo file
      ls {$path_climo}/wgt_month.*.nc > {$path_climo}/weighted_files
      set files = `cat {$path_climo}/weighted_files`
      ncea -O -y ttl $files {$test_out}_{$yr_prnt}_SON.nc
#   append the needed non-time varying variables
      ncks -C -A -v $non_time_var_list {$path_climo}/unweighted.nc {$test_out}_{$yr_prnt}_SON.nc
      echo {$yr_prnt}' WEIGHTED TIME AVERAGE'
    else
      if ($file_type == "monthly_history") then
        ncea -O $files {$test_out}_{$yr_prnt}_SON.nc
      else
        foreach mth (01 02 03)
          set split_line = `echo $files[$mth]:q | sed 's/,/ /g'`
          set ts_file = $split_line[1]
          set i = $split_line[2]
          set year1 = $split_line[3]
          set month1 = $split_line[4]
          set year2 = $split_line[5]
          set month2 = $split_line[6]
             
          set var_list_f = `cat ${path_climo}/"var_list.txt"`
          foreach var ($var_list_f)
            if ($var == null) then
              set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
              ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_$mth.nc
            else
              set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
              ncks -O -F -d time,$i,$i,1 $ts_file {$path_climo}/temp_${mth}.${var}.nc
            endif
          end
          set var_files = `ls ${path_climo}/temp_$mth.*.nc`
          foreach vf ($var_files)
            ncks -A $vf ${path_climo}/temp_$mth.nc
            /bin/rm -f $vf
          end
        end
        ls {$path_climo}/temp_*.nc | ncea -O  {$test_out}_{$yr_prnt}_SON.nc
        rm -f {$path_climo}/temp_*.nc
      endif
      echo {$yr_prnt}' TIME AVERAGE'
    endif
  endif
  @ yr_cnt++
end
# clean up
if ($weight_months == 0) then
  \rm -f {$path_climo}/weighted_files
  \rm -f {$path_climo}/wgt_month.*.nc
endif

#---------------------------------------------------------
#  COMPUTE TEST CASE SON CLIMATOLOGY 
#---------------------------------------------------------
echo COMPUTING $casetype CASE SON CLIMO MEAN
if ($nyrs == 1) then
  /bin/mv {$test_out}_{$yr_prnt}_SON.nc {$test_out}_SON_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$first_yr {$test_out}_SON_climo.nc
else 
  ls {$test_out}_*_SON.nc > {$path_climo}/seasonal_files
  set files = `cat {$path_climo}/seasonal_files`
  ncea -O $files {$test_out}_SON_climo.nc
  ncatted -O -a yrs_averaged,global,c,c,$ave_yrs {$test_out}_SON_climo.nc
  if ($significance == 0) then
    ncrcat -O $files {$test_out}_SON_means.nc
  endif
  \rm -f {$test_out}*SON.nc
  \rm -f {$path_climo}/seasonal_files
endif
set test_in = $test_out
echo ' '



#*******************************************************************
#  CALC TEST CASE MONTHLY CLIMATOLOGY 
#*******************************************************************

set months = (01 02 03 04 05 06 07 08 09 10 11 12)

echo COMPUTING $casetype CASE CLIMO MONTHLY MEANS
if ($nyrs == 1) then
  set yr_prnt = {$conv_test}`printf "%04d" {$first_yr}`
  foreach x ($months)
    /bin/cp {$path_history}/{$yr_prnt}-{$x}.nc {$test_out}_{$x}_climo.nc 
    ncatted -O -a yrs_averaged,global,c,c,$first_yr {$test_out}_{$x}_climo.nc
  end
else
  @ yr_end = $first_yr + $nyrs - 1 
  set ave_yrs = $first_yr-$yr_end
  foreach month ($months)
    @ yr_cnt = $first_yr
    while ( $yr_cnt <= $yr_end )
      if ($file_type == "monthly_history") then
        set yr_prnt = {$conv_test}`printf "%04d" {$yr_cnt}`
        ls {$path_history}/{$yr_prnt}-{$month}.nc >> {$path_climo}/month_files 
      else
        set year_slice_file = ${path_climo}/year_slice.txt
        if (-e $year_slice_file) then
          /bin/rm $year_slice_file
        endif
        $DIAG_CODE/find_time_series_year.pl ${path_climo}/${casetype}_file_list.txt \
                                        $yr_cnt \
                                        $path_climo \
                                        "null" \
                                        $year_slice_file
        set all_files = `cat $year_slice_file`
        set file = $all_files[$month]
        set split_line = `echo $file:q | sed 's/,/ /g'`
        set ts_file_temp = $split_line[1]
        set i = $split_line[2]
        set year1 = $split_line[3]
        set month1 = $split_line[4]
        set year2 = $split_line[5]
        set month2 = $split_line[6]
             
        set var_list_f = `cat ${path_climo}/"var_list.txt"`
        foreach var ($var_list_f)
          if ($var == null) then
            set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
            ncks -O -F -d time,$i,$i,1 $ts_file ${path_climo}/temp_${yr_cnt}_${month}.nc
          else
            set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
            ncks -O -F -d time,$i,$i,1 $ts_file ${path_climo}/tmp_${yr_cnt}_${month}.${var}.nc
          endif
        end
        set var_files = `ls ${path_climo}/tmp_${yr_cnt}_${month}.*.nc`
        foreach vf ($var_files)
          ncks -A $vf ${path_climo}/temp_${yr_cnt}_${month}.nc
          /bin/rm -f $vf
        end
      endif 
      @ yr_cnt++
    end
    if ($file_type == "monthly_history") then
      set files = `cat {$path_climo}/month_files`
      ncea -O $files {$test_out}_{$month}_climo.nc
    else
      ls ${path_climo}/temp_*_${month}.nc | ncea -O {$test_out}_{$month}_climo.nc
      rm -f ${path_climo}/temp_*_${month}.nc
    endif
    ncatted -O -a yrs_averaged,global,c,c,$ave_yrs {$test_out}_{$month}_climo.nc
    \rm -f {$path_climo}/month_files 
  end 
endif
set test_in = $test_out
echo ' '
