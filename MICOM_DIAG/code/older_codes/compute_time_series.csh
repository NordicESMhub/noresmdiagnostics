#!/bin/csh -f

set script_start = `date +%s`
#
# MICOM DIAGNOSTICS package: compute_time_series.csh
# PURPOSE: computes annual time series from annual or monthly history files
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Dec 2017

# STRATEGY: Split the data into chucks of 10 years each.
# Run each chunk serially and the 10 chunk year in parallel.

# Input arguments:
#  $filetype  hm or hy
#  $casename  name of experiment
#  $first_yr  first year of the average
#  $last_yr   last year of the average
#  $pathdat   directory where the history files are located
#  $tsdir     directory where the climatology files are located

set filetype = $1
set casename = $2
set first_yr = $3
set last_yr  = $4
set pathdat  = $5
set tsdir    = $6

echo " "
echo "-----------------------"
echo "compute_time_series.csh"
echo "-----------------------"
echo "Input arguments:"
echo " filetype = $filetype"
echo " casename = $casename"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " pathdat  = $pathdat"
echo " tsdir    = $tsdir"
echo " "

set var_list      = `cat $WKDIR/attributes/vars_${casename}_ts_${filetype}`
set first_yr_prnt = `printf "%04d" ${first_yr}`
set last_yr_prnt  = `printf "%04d" ${last_yr}`
set ann_ts_file   = ${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}_ts_${filetype}.nc

# Calculate number of chunks and the residual
@ nproc = 10
@ nyrs = $last_yr - $first_yr + 1
@ nchunks  = $nyrs / $nproc
@ residual = $nyrs % $nproc

set grid_file = $DIAG_GRID/`cat $WKDIR/attributes/grid_${casename}`/grid.nc

if ($residual > 0) then
   @ nchunkp = $nchunks + 1
else
   @ nchunkp = $nchunks
endif
@ ichunk = 1
while ($ichunk <= $nchunkp)
   if ($residual > 0) then
      if ($ichunk < $nchunkp) then
         @ nyrs = $nproc
      else
         @ nyrs = $residual
      endif
   else
      @ nyrs = $nproc
   endif
   set pid = ()
   @ iproc = 1
   @ YR_start = ($ichunk - 1) * $nproc + $first_yr
   @ YR_end = ($ichunk - 1) * $nproc + $nyrs + $first_yr - 1
   if ($filetype == hy) then
      # Extract variables from annual file if in hy mode
      echo "Extracting time-series variables from annual history files (yrs ${YR_start}-${YR_end})"
      while ($iproc <= $nyrs)
         @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
         set yr_prnt = `printf "%04d" ${YR}`
         set filename = ${casename}.micom.hy.${yr_prnt}.nc
         /usr/local/bin/ncks -O -v $var_list --no_tmp_fl $pathdat/$filename $WKDIR/${casename}_ANN_${yr_prnt}.nc &
         set pid = ($pid $!)
         @ iproc++
      end
      @ m = 1
      while ($m <= $nyrs)
         if (`ps -p "$pid[$m]" | wc -l` < 2) then
            echo "ERROR in extracting variables from annual history file: /usr/local/bin/ncks -O -v $var_list --no_tmp_fl $pathdat/$filename $WKDIR/${casename}_ANN_${yr_prnt}.nc"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
         endif
         @ m++
      end
      wait
   else 
      # Compute annual means if in hm mode
      echo "Computing annual mean from monthly history files (yrs ${YR_start}-${YR_end})"
      set pid = ()
      @ iproc = 1
      while ($iproc <= $nyrs)
         @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
         set yr_prnt = `printf "%04d" ${YR}`
	 set filenames = ()
	 foreach mon (01 02 03 04 05 06 07 08 09 10 11 12)
            set filename = ${casename}.micom.hm.${yr_prnt}-${mon}.nc
	    set filenames = ($filenames $filename)
	 end
	 /usr/local/bin/ncra -O --no_tmp_fl --hdr_pad=10000 -w 31,28,31,30,31,30,31,31,30,31,30,31 -v $var_list -p $pathdat $filenames $WKDIR/${casename}_ANN_${yr_prnt}.nc &
         set pid = ($pid $!)
         @ iproc++
      end
      @ m = 1
      while ($m <= $nyrs)
         if (`ps -p "$pid[$m]" | wc -l` < 2) then
            echo "ERROR in extracting variables from annual history file: /usr/local/bin/ncks -O -v $var_list --no_tmp_fl $pathdat/$filename $WKDIR/${casename}_ANN_${yr_prnt}.nc"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
         endif
         @ m++
      end
      wait
   endif
   # Append grid files and add mass weights
   @ iproc = 1
   echo "Appending coordinates to annual files (yrs ${YR_start}-${YR_end})"
   while ($iproc <= $nyrs)
      @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
      set yr_prnt = `printf "%04d" ${YR}`
      set filename = ${casename}_ANN_${yr_prnt}.nc
      /usr/local/bin/ncks --quiet -d depth,0 -d x,0 -d y,0 -v plon $WKDIR/$filename >&! /dev/null
      if ($status > 0) then
         /usr/local/bin/ncks -A -v plon,plat,parea -o $WKDIR/$filename $grid_file
      endif
      @ iproc++
   end
   # Loop over variables and do some averaging...
   foreach var (`echo $var_list | sed 's/,/ /g'`)
      # Mass weighted 3D averaging of temp and saln
      if ($var == temp || $var == saln) then
         echo "Mass weighted global average of $var for yrs ${YR_start}-${YR_end}"
         set pid = ()
         @ iproc = 1
         while ($iproc <= $nyrs)
            @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
            set yr_prnt = `printf "%04d" ${YR}`
            set infile  = ${casename}_ANN_${yr_prnt}.nc
            set outfile = ${var}_${casename}_ANN_${yr_prnt}.nc
            /usr/bin/ncwa --no_tmp_fl -O -v $var -w dp -a sigma,y,x $WKDIR/$infile $WKDIR/$outfile &
            set pid = ($pid $!)
            @ iproc++
         end
         @ m = 1
         while ($m <= $nyrs)
            if (`ps -p "$pid[$m]" | wc -l` < 2) then
               echo "ERROR in calculating mass weighted global average: /usr/bin/ncwa --no_tmp_fl -O -v $var -w dp -a x,y,sigma $WKDIR/$infile $WKDIR/$outfile"
               echo "*** EXITING THE SCRIPT ***"
               exit 1
            endif
            @ m++
         end
         wait
      endif
      # Area weighted horizontal global average of templvl and salnlvl
      if ($var == templvl || $var == salnlvl) then
         echo "Area weighted global average of $var for yrs ${YR_start}-${YR_end}"
         set pid = ()
         @ iproc = 1
         while ($iproc <= $nyrs)
            @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
            set yr_prnt = `printf "%04d" ${YR}`
            set infile  = ${casename}_ANN_${yr_prnt}.nc
            set outfile = ${var}_${casename}_ANN_${yr_prnt}.nc
            /usr/bin/ncwa --no_tmp_fl -O -v $var -w parea -a x,y $WKDIR/$infile $WKDIR/$outfile &
            set pid = ($pid $!)
	    @ iproc++
	 end
	 @ m = 1
         while ($m <= $nyrs)
           if (`ps -p "$pid[$m]" | wc -l` < 2) then
               echo "ERROR in calculating area weighted global average: /usr/bin/ncwa --no_tmp_fl -O -v $var -w parea -a x,y $WKDIR/$infile $WKDIR/$outfile"
               echo "*** EXITING THE SCRIPT ***"
               exit 1
            endif
            @ m++
         end
         wait
      endif
      # Area weighted global average of sst
      if ($var == sst) then
         echo "Area weighted global average of $var for yrs ${YR_start}-${YR_end}"
         set pid = ()
         @ iproc = 1
         while ($iproc <= $nyrs)
            @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
            set yr_prnt = `printf "%04d" ${YR}`
            set infile  = ${casename}_ANN_${yr_prnt}.nc
            set outfile = ${var}_${casename}_ANN_${yr_prnt}.nc
            /usr/bin/ncwa --no_tmp_fl -O -v $var -w parea -a x,y $WKDIR/$infile $WKDIR/$outfile &
            set pid = ($pid $!)
	    @ iproc++
	 end
#	 @ m = 1
#         while ($m <= $nyrs)
#           if (`ps -p "$pid[$m]" | wc -l` < 2) then
#               echo "ERROR in calculating area weighted global average: /usr/bin/ncwa --no_tmp_fl -O -v $var -w parea -a x,y $WKDIR/$infile $WKDIR/$outfile"
#               echo "*** EXITING THE SCRIPT ***"
#               exit 1
#            endif
#            @ m++
#         end
         wait
      endif
      # Max AMOC between 20-60N
      if ($var == mmflxd) then
	 echo "Max AMOC between 20-60N for yrs ${YR_start}-${YR_end}"
         @ iproc = 1
         while ($iproc <= $nyrs)
            @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
            set yr_prnt = `printf "%04d" ${YR}`
            set infile      = ${casename}_ANN_${yr_prnt}.nc
	    set outfile_tmp = ${var}_${casename}_ANN_${yr_prnt}_tmp.nc
     	    set outfile     = ${var}_${casename}_ANN_${yr_prnt}.nc
            /usr/local/bin/ncks -F --no_tmp_fl -O -v $var -d lat,20.0,60.0 -d region,1 $WKDIR/$infile $WKDIR/$outfile_tmp
	    /usr/bin/ncap2 -O -s 'mmflxd_max=mmflxd.max($lat,$depth)' $WKDIR/$outfile_tmp $WKDIR/$outfile_tmp
            /usr/local/bin/ncks --no_tmp_fl -O -v mmflxd_max,region $WKDIR/$outfile_tmp $WKDIR/$outfile
	    rm -f $WKDIR/$outfile_tmp
	    @ iproc++
	 end
      endif
      # Section transports
      if ($var == voltr) then
         echo "Section transports for yrs ${YR_start}-${YR_end}"
         @ iproc = 1
         while ($iproc <= $nyrs)
            @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
            set yr_prnt = `printf "%04d" ${YR}`
            set infile      = ${casename}_ANN_${yr_prnt}.nc
     	    set outfile     = ${var}_${casename}_ANN_${yr_prnt}.nc
            /usr/local/bin/ncks --no_tmp_fl -O -v voltr,section $WKDIR/$infile $WKDIR/$outfile
	    @ iproc++
	 end
      endif
   end
   # clean up
   @ iproc = 1
   while ($iproc <= $nyrs)
      @ YR = ($ichunk - 1) * $nproc + $iproc + $first_yr - 1
      set yr_prnt  = `printf "%04d" ${YR}`
      set filename = ${casename}_ANN_${yr_prnt}.nc
      rm -f $WKDIR/$filename
      @ iproc++
   end      
   @ ichunk++
end

# Concancate files
set first_var = 1
foreach var (`echo $var_list | sed 's/,/ /g'`)
   set first_file = ${var}_${casename}_ANN_${first_yr_prnt}.nc
   if (-e $WKDIR/$first_file) then
      echo "Merging all $var time series files..."
      /usr/local/bin/ncrcat -O $WKDIR/${var}_${casename}_ANN_????.nc $WKDIR/${var}_${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}.nc
      if ($status == 0) then
         if ($first_var == 1) then
            set first_var = 0
  	    mv $WKDIR/${var}_${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}.nc $tsdir/$ann_ts_file
	 else
	    /usr/local/bin/ncks -A -o $tsdir/$ann_ts_file $WKDIR/${var}_${casename}_ANN_${first_yr_prnt}-${last_yr_prnt}.nc
	 endif
      endif
      rm -f $WKDIR/${var}_${casename}_ANN_*.nc
   endif
end

set script_end       = `date +%s`
set runtime_s        = `expr ${script_end} - ${script_start}`
set runtime_script_m = `expr ${runtime_s} / 60`
set min_in_secs      = `expr ${runtime_script_m} \* 60`
set runtime_script_s = `expr ${runtime_s} - ${min_in_secs}`
echo "TIME SERIES RUNTIME: ${runtime_script_m}m${runtime_script_s}s"
