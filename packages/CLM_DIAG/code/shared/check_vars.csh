#!/bin/csh -f
# Check which variables are available for trends
# Johan Liakka, NERSC, Nov 2017

set required_vars = (TSA RAIN SNOW TSOI FPSN ELAI ESAI TLAI TSAI LAISUN LAISHA \
                     BTRAN QINFL QOVER QRGWL QDRAI QINTR QSOIL QVEGT SOILLIQ \
		     SOILICE SOILPSI SNOWLIQ SNOWICE WA ZWT QCHARGE FCOV PCO2 \
		     landfrac area FSR PBOT SNOWDP FSDS FSA FLDS FIRE FIRA FSH \
		     FCTR FCEV FGEV FGR WT)

# Case 1
set fullpath_filename = $case_1_dir/$caseid_1.clm2.h0.`printf "%04d" ${trends_first_yr_1}`-01.nc
set first_find = 1
set var_list = " "
foreach var ($required_vars)
   $ncksbin/ncks --quiet  -d lat,0 -d lon,0 -v $var $fullpath_filename  >&! /dev/null
   set var_present = $status
   if ($var_present == 0) then
      if ($first_find == 1) then
	 set var_list = $var
	 set first_find=0
      else
         set var_list = ${var_list},$var
      endif
   endif
end
echo  ${var_list} > $PROCDIR1/var_list.txt

# Case 2
if ($RUNTYPE == "model1-model2") then
   set fullpath_filename = $case_2_dir/$caseid_2.clm2.h0.`printf "%04d" ${trends_first_yr_2}`-01.nc
   set first_find = 1
   set var_list = " "
   foreach var ($required_vars)
      $ncksbin/ncks --quiet  -d lat,0 -d lon,0 -v $var $fullpath_filename  >&! /dev/null
      set var_present = $status
      if ($var_present == 0) then
         if ($first_find == 1) then
            set var_list = $var
	    set first_find=0
         else
            set var_list = ${var_list},$var
         endif
      endif
   end
   echo  ${var_list} > $PROCDIR2/var_list.txt
endif
