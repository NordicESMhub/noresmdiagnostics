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


if ($#argv != 13) then
  echo "usage: compute_climo.csh "
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
set filetype = $12
set diagcode = $13

set non_time_var_list=`cat ${path_diag}/attributes/${casetype}_non_time_var_list`
set var_list=`cat ${path_diag}/attributes/${casetype}_var_list`

if ($filetype == "time_series") then
  cat ${path_climo}/${casetype}_file_list.txt
  set time_series_files = `cat ${path_climo}/${casetype}_file_list.txt`
endif

#------------------------------------------------------------------------

    # the monthly time weights
    # the ann time weights
    set ann_weights = (   0.08493150770664215 0.07671232521533966 0.08493150770664215 \
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
    ##if ($weight_months == 0) then
    if ($filetype == "monthly_history") then
        set filename = ${rootname}`printf "%04d" ${first_yr}`-01.nc
        ncks -C -O -v $non_time_var_list ${path_history}/${filename} ${path_climo}/unweighted.nc
    else
        set split_line = `echo $time_series_files[1]:q | sed 's/,/ /g'`
        set ts_file_temp = $split_line[1]
        set var_list_f = `cat ${path_climo}/"var_list.txt"`
        if ($var_list_f[1] == null) then
         set ts_file = ${ts_file_temp}${split_line[2]}-$split_line[3]_cat_$split_line[4]-$split_line[5].nc
        else
          set ts_file = ${ts_file_temp}${var_list_f[1]}.$split_line[2]-$split_line[3]_cat_$split_line[4]-$split_line[5].nc
        endif
        ncks -C -O -v $non_time_var_list ${ts_file} ${path_climo}/unweighted.nc
    endif
    
    #---------------------------------------------------------------------
    # We compute the monthly mean climos 
    # For Dec, we also compute a mean climo that includes the previous year to the climo period.
    # For Jan and Feb, we compute a mean climo including the "next" year to the climo period. 
    #
    echo COMPUTING MONTHLY CLIMOS FOR "$casetype"
    @ yr_end = $first_yr + $nyrs - 1 
    if ($nyrs == 1) then
        set ave_yrs = $first_yr
    else
        set ave_yrs = $first_yr-$yr_end
    endif
    foreach mth (01 02 03 04 05 06 07 08 09 10 11 12)
        echo ' CLIMO FOR MONTH =' $mth
        if ($filetype == "monthly_history") then
             # select the files we need to compute the climos 
             # create symbolic links for these files
             @ yri = $first_yr
             while ( $yri <= $yr_end )              ; 
                 set yr_prnt = ${rootname}`printf "%04d" ${yri}`-${mth}.nc
                 ln -s  ${path_history}/${yr_prnt} ${path_climo}/file_yr_${yri}_${mth}.nc
                 @ yri++
             end
             # compute climos
             set filename = ${casename}_${mth}_climo.nc
             #echo ${path_climo}/file_yr_*_${mth}.nc
             if ($strip_off_vars == 0) then
                 ls ${path_climo}/file_yr_*_${mth}.nc | ncra -O  ${path_climo}/temp.nc
                 ncks -O -v $var_list ${path_climo}/temp.nc ${path_climo}/${filename} 
                 rm -f  ${path_climo}/temp.nc
             else   
                 ls ${path_climo}/file_yr_*_${mth}.nc | ncra -O  ${path_climo}/${filename}                         
             endif
        else
             # Loop through the time series files to pull the needed monthly time slices and make an ave for each ts file
             foreach ts_file ($time_series_files)
               set split_line = `echo $ts_file:q | sed 's/,/ /g'`
               set ts_filename_temp = $split_line[1]
               set year1 = $split_line[2]
               set month1 = $split_line[3]
               set year2 = $split_line[4]
               set month2 = $split_line[5]
               
               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                 endif

                 ${diagcode}/compute_ts_ave.pl $ts_file $year1 $month1 $year2 $month2 $first_yr $yr_end \
                                   $mth $path_climo "null" $strip_off_vars $var_list \
                                   ${path_climo}/tmp_file_yr_${var}_${year1}_${year2}_${mth}.nc
               end 
               
               set var_files = `ls ${path_climo}/tmp_file_yr_*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/file_yr_${year1}_${year2}_${mth}.nc     
                 /bin/rm -f $vf
               end
             end
             # average the ts files that were created to create the monthly ave file
             set filename = ${casename}_${mth}_climo.nc
             ncra -O ${path_climo}/file_yr_*_${mth}.nc ${path_climo}/${filename}
        endif 
        # add attributes/variable
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc  ${path_climo}/${filename} 
        ncatted -O -a yrs_averaged,global,c,c,$ave_yrs  ${path_climo}/${filename} 
        # clean up 
        /bin/rm ${path_climo}/file_yr_*_${mth}.nc
    end 
    # compute climo for previous or next year for DJF calculation 
    if ($djf == PREV) then
        foreach mth (12)
        echo ' CLIMO FOR MONTH =' $mth '(PREVIOUS YEAR)'
        if ($filetype == "monthly_history") then
             # select the files we need to compute the climos 
             # create symbolic links for these files
             @ yri = $first_yr - 1
             while ( $yri <= $yr_end - 1 )              
                 set yr_prnt = ${rootname}`printf "%04d" ${yri}`-${mth}.nc
                 ln -s  ${path_history}/${yr_prnt} ${path_climo}/file_yr_${yri}_${mth}.nc
                 @ yri++
             end
             # compute climos
             set filename = ${casename}_${mth}_climo_prev.nc
             #echo ${path_climo}/file_yr_*_${mth}.nc
             if ($strip_off_vars == 0) then
                 ls ${path_climo}/file_yr_*_${mth}.nc | ncra -O  ${path_climo}/temp.nc
                 ncks -O -v $var_list ${path_climo}/temp.nc ${path_climo}/${filename} 
                 rm -f  ${path_climo}/temp.nc
             else   
                 ls ${path_climo}/file_yr_*_${mth}.nc | ncra -O  ${path_climo}/${filename}                         
             endif
        else
             # Loop through the time series files to pull the needed monthly time slices and make an ave for each ts file
             foreach ts_file ($time_series_files)
               set split_line = `echo $ts_file:q | sed 's/,/ /g'`
               set ts_filename_temp = $split_line[1]
               set year1 = $split_line[2]
               set month1 = $split_line[3]
               set year2 = $split_line[4]
               set month2 = $split_line[5]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                 endif

                 ${diagcode}/compute_ts_ave.pl $ts_file $year1 $month1 $year2 $month2 $first_yr $yr_end \
                                   $mth $path_climo "PREV" $strip_off_vars $var_list \
                                   ${path_climo}/tmp_file_yr_${var}_${year1}_${year2}_${mth}.nc
               end

               set var_files = `ls ${path_climo}/tmp_file_yr_*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/file_yr_${year1}_${year2}_${mth}.nc     
                 /bin/rm -f $vf
               end
             end
             # average the ts files that were created to create the monthly ave file
             set filename = ${casename}_${mth}_climo_prev.nc
             ncra -O ${path_climo}/file_yr_*_${mth}.nc ${path_climo}/${filename}
        endif
        # add attributes/variable
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc  ${path_climo}/${filename} 
        ncatted -O -a yrs_averaged,global,c,c,$ave_yrs  ${path_climo}/${filename} 
        # clean up 
        /bin/rm ${path_climo}/file_yr_*_${mth}.nc
        end 
    else
        foreach mth (01 02)
        echo ' CLIMO FOR MONTH =' $mth '(NEXT YEAR)'
        if ($filetype == "monthly_history") then
             # select the files we need to compute the climos 
             # create symbolic links for these files
             @ yri = $first_yr + 1
             while ( $yri <= $yr_end + 1 )              
                 set yr_prnt = ${rootname}`printf "%04d" ${yri}`-${mth}.nc
                 ln -s  ${path_history}/${yr_prnt} ${path_climo}/file_yr_${yri}_${mth}.nc
                 @ yri++
             end
             # compute climos
             set filename = ${casename}_${mth}_climo_next.nc
             #echo ${path_climo}/file_yr_*_${mth}.nc
             if ($strip_off_vars == 0) then
                 ls ${path_climo}/file_yr_*_${mth}.nc | ncra -O  ${path_climo}/temp.nc
                 ncks -O -v $var_list ${path_climo}/temp.nc ${path_climo}/${filename} 
                 rm -f  ${path_climo}/temp.nc
             else   
                 ls ${path_climo}/file_yr_*_${mth}.nc | ncra -O  ${path_climo}/${filename}                         
             endif 
        else
              # Loop through the time series files to pull the needed monthly time slices and make an ave for each ts file
             foreach ts_file ($time_series_files)
               set split_line = `echo $ts_file:q | sed 's/,/ /g'`
               set ts_filename_temp = $split_line[1]
               set year1 = $split_line[2]
               set month1 = $split_line[3]
               set year2 = $split_line[4]
               set month2 = $split_line[5]

               set var_list_f = `cat ${path_climo}/"var_list.txt"`
               foreach var ($var_list_f)
                 if ($var == null) then
                   set ts_file = ${ts_file_temp}${year1}-${month1}_cat_${year2}-${month2}.nc
                 else
                   set ts_file = ${ts_file_temp}${var}.${year1}-${month1}_cat_${year2}-${month2}.nc
                 endif

                 ${diagcode}/compute_ts_ave.pl $ts_file $year1 $month1 $year2 $month2 $first_yr $yr_end \
                                   $mth $path_climo "NEXT" $strip_off_vars $var_list \
                                   ${path_climo}/tmp_file_yr_${var}_${year1}_${year2}_${mth}.nc
               end

               set var_files = `ls ${path_climo}/tmp_file_yr_*.nc`
               foreach vf ($var_files)
                 ncks -A $vf ${path_climo}/file_yr_${year1}_${year2}_${mth}.nc     
                 /bin/rm -f $vf
               end
             end        
             # average the ts files that were created to create the monthly ave file
             set filename = ${casename}_${mth}_climo_next.nc
             ncra -O ${path_climo}/file_yr_*_${mth}.nc ${path_climo}/${filename}  
        endif
        # add attributes/variable
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc  ${path_climo}/${filename} 
        ncatted -O -a yrs_averaged,global,c,c,$ave_yrs  ${path_climo}/${filename} 
        # clean up 
        /bin/rm ${path_climo}/file_yr_*_${mth}.nc
        end 
    endif
    echo ' '

    #---------------------------------------------------------------------
    echo COMPUTING CASE ANNUAL AVERAGES FOR "$casetype"
    set files = `ls ${path_climo}/${casename}_01_climo.nc ${path_climo}/${casename}_02_climo.nc \
                    ${path_climo}/${casename}_03_climo.nc ${path_climo}/${casename}_04_climo.nc \
                    ${path_climo}/${casename}_05_climo.nc ${path_climo}/${casename}_06_climo.nc \
                    ${path_climo}/${casename}_07_climo.nc ${path_climo}/${casename}_08_climo.nc \
                    ${path_climo}/${casename}_09_climo.nc ${path_climo}/${casename}_10_climo.nc \
                    ${path_climo}/${casename}_11_climo.nc ${path_climo}/${casename}_12_climo.nc `

    #echo $files
    set out = ${path_climo}/${casename}
    #echo ${out}_ANN_climo.nc
    if ($weight_months == 0) then
        # apply the weights to the monthly files
        foreach m (1 2 3 4 5 6 7 8 9 10 11 12)
           set DATE=`date`;
           set month = `printf "%02d" ${m}` 
           if (-z $files[$m]) then
                 echo "ERROR - Empty file:"  $files[$m]
           else
           if ($strip_off_vars == 0) then
                 ncflint -O -c -v $var_list -w $ann_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           else    
                 ncflint -O -C -x -v $non_time_var_list -w $ann_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           endif  
           endif
        end
        # sum the weighted files to make the climo file
        ls ${path_climo}/wgt_month.*.nc > ${path_climo}/weighted_files
        set files = `cat ${path_climo}/weighted_files`
        ncea -O -y ttl $files ${path_climo}/${casename}_ANN_climo.nc 
        # append the needed non-time varying variables
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc ${path_climo}/${casename}_ANN_climo.nc
        rm -f ${path_climo}/wgt_month.*.nc ${path_climo}/weighted_files   
        echo ' WEIGHTED TIME AVERAGE'
    else
        ncea -O $files ${path_climo}/${casename}_ANN_climo.nc 
        echo ' TIME AVERAGE'
    endif
    ncatted -O -a yrs_averaged,global,c,c,$ave_yrs ${path_climo}/${casename}_ANN_climo.nc 
    echo ' '
    
    #---------------------------------------------------------------------
    echo COMPUTING CASE JJA AVERAGES FOR "$casetype"
    set files = `ls ${path_climo}/${casename}_06_climo.nc ${path_climo}/${casename}_07_climo.nc \
                    ${path_climo}/${casename}_08_climo.nc` 
    #echo $files
    if ($weight_months == 0) then
        # apply the weights to the monthly files
        foreach m (1 2 3)
           set DATE=`date`;
           set month = `printf "%02d" ${m}` 
           if (-z $files[$m]) then
                        echo "ERROR - Empty file:"  $files[$m]
           else
           if ($strip_off_vars == 0) then
                 ncflint -O -c -v $var_list -w $jja_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           else    
                 ncflint -O -C -x -v $non_time_var_list -w $jja_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           endif  
           endif
        end
        # sum the weighted files to make the climo file
        ls ${path_climo}/wgt_month.*.nc > ${path_climo}/weighted_files
        set files = `cat ${path_climo}/weighted_files`
        ncea -O -y ttl $files ${path_climo}/${casename}_JJA_climo.nc 
        # append the needed non-time varying variables
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc ${path_climo}/${casename}_JJA_climo.nc
        rm -f ${path_climo}/wgt_month.*.nc ${path_climo}/weighted_files   
        echo ' WEIGHTED TIME AVERAGE'
    else
        ncea -O $files ${path_climo}/${casename}_JJA_climo.nc 
        echo ' TIME AVERAGE'
    endif
    ncatted -O -a yrs_averaged,global,c,c,$ave_yrs ${path_climo}/${casename}_JJA_climo.nc 
    echo ' '

    #---------------------------------------------------------------------
    echo COMPUTING CASE MAM AVERAGES FOR "$casetype"
    set files = `ls ${path_climo}/${casename}_03_climo.nc ${path_climo}/${casename}_04_climo.nc \
                    ${path_climo}/${casename}_05_climo.nc` 
    #echo $files
    if ($weight_months == 0) then
        # apply the weights to the monthly files
        foreach m (1 2 3)
           set DATE=`date`;
           set month = `printf "%02d" ${m}` 
           if (-z $files[$m]) then
                        echo "ERROR - Empty file:"  $files[$m]
           else
           if ($strip_off_vars == 0) then
                 ncflint -O -c -v $var_list -w $mam_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           else    
                 ncflint -O -C -x -v $non_time_var_list -w $mam_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           endif  
           endif
        end
        # sum the weighted files to make the climo file
        ls ${path_climo}/wgt_month.*.nc > ${path_climo}/weighted_files
        set files = `cat ${path_climo}/weighted_files`
        ncea -O -y ttl $files ${path_climo}/${casename}_MAM_climo.nc 
        # append the needed non-time varying variables
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc ${path_climo}/${casename}_MAM_climo.nc
        rm -f ${path_climo}/wgt_month.*.nc ${path_climo}/weighted_files   
        echo ' WEIGHTED TIME AVERAGE'
    else
        ncea -O $files ${path_climo}/${casename}_MAM_climo.nc 
        echo ' TIME AVERAGE'
    endif
    ncatted -O -a yrs_averaged,global,c,c,$ave_yrs ${path_climo}/${casename}_MAM_climo.nc 
    echo ' '

    #---------------------------------------------------------------------
    echo COMPUTING CASE SON AVERAGES FOR "$casetype"
    set files = `ls ${path_climo}/${casename}_09_climo.nc ${path_climo}/${casename}_10_climo.nc \
                    ${path_climo}/${casename}_11_climo.nc` 
    #echo $files
    if ($weight_months == 0) then
        # apply the weights to the monthly files
        foreach m (1 2 3)
           set DATE=`date`;
           set month = `printf "%02d" ${m}` 
           if (-z $files[$m]) then
                        echo "ERROR - Empty file:"  $files[$m]
           else
           if ($strip_off_vars == 0) then
                 ncflint -O -c -v $var_list -w $son_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           else    
                 ncflint -O -C -x -v $non_time_var_list -w $son_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           endif  
           endif
        end
        # sum the weighted files to make the climo file
        ls ${path_climo}/wgt_month.*.nc > ${path_climo}/weighted_files
        set files = `cat ${path_climo}/weighted_files`
        ncea -O -y ttl $files ${path_climo}/${casename}_SON_climo.nc 
        # append the needed non-time varying variables
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc ${path_climo}/${casename}_SON_climo.nc
        rm -f ${path_climo}/wgt_month.*.nc ${path_climo}/weighted_files   
        echo ' WEIGHTED TIME AVERAGE'
    else
        ncea -O $files ${path_climo}/${casename}_SON_climo.nc 
        echo ' TIME AVERAGE'
    endif
    ncatted -O -a yrs_averaged,global,c,c,$ave_yrs ${path_climo}/${casename}_SON_climo.nc 
    echo ' '

    #---------------------------------------------------------------------
    echo COMPUTING CASE DJF AVERAGES FOR "$casetype"
  
    if ( $djf == "PREV") then
        set files[1] = `ls ${path_climo}/${casename}_12_climo_prev.nc` 
        set files[2] = `ls ${path_climo}/${casename}_01_climo.nc` 
        set files[3] = `ls ${path_climo}/${casename}_02_climo.nc` 
    else
        set files[1] = `ls ${path_climo}/${casename}_12_climo.nc` 
        set files[2] = `ls ${path_climo}/${casename}_01_climo_next.nc` 
        set files[3] = `ls ${path_climo}/${casename}_02_climo_next.nc` 
    endif
    ##echo $files
    if ($weight_months == 0) then
        # apply the weights to the monthly files
        foreach m (1 2 3)
           set DATE=`date`;
           set month = `printf "%02d" ${m}` 
           if (-z $files[$m]) then
                        echo "ERROR - Empty file:"  $files[$m]
           else
           if ($strip_off_vars == 0) then
                 ncflint -O -c -v $var_list -w $djf_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           else    
                 ncflint -O -C -x -v $non_time_var_list -w $djf_weights[$m],0.0 $files[$m] $files[$m] ${path_climo}/wgt_month.$month.nc
           endif  
           endif
        end
        # sum the weighted files to make the climo file
        ls ${path_climo}/wgt_month.*.nc > ${path_climo}/weighted_files
        set files = `cat ${path_climo}/weighted_files`
        ncea -O -y ttl $files ${path_climo}/${casename}_DJF_climo.nc 
        # append the needed non-time varying variables
        ncks -C -A -v $non_time_var_list ${path_climo}/unweighted.nc ${path_climo}/${casename}_DJF_climo.nc
        rm -f ${path_climo}/wgt_month.*.nc ${path_climo}/weighted_files   
        echo ' WEIGHTED TIME AVERAGE'
    else
        ##echo "=== CLIMO =======> " ncea -O $files ${path_climo}/${casename}_DJF_climo.nc 
        ncea -O $files ${path_climo}/${casename}_DJF_climo.nc 
        echo ' TIME AVERAGE'
    endif
    ncatted -O -a yrs_averaged,global,c,c,$ave_yrs ${path_climo}/${casename}_DJF_climo.nc 
    echo ' '
