#!/bin/csh -f

#*********************************
# Check if climo files are present
#*********************************
# Johan Liakka 17/9/17
# johan.liakka@nersc.no
#
# simulation      "test" or "cntl"
# $casename       simulation name
# $path_climo     The directory for climatology files
# $path_diag      Diagnostics directory
# $signi          (0=ON, 1=OFF)
#
#-----------------------------------------------------------
# Check arguments and set input variables

if ($#argv != 5) then
  echo $#argv
  echo "usage: check_climo_present.csh simulation casename path_climo path_diag signi"
  exit
endif

set simulation = $1
set casename   = $2
set path_climo = $3
set path_diag  = $4
set signi      = $5

set climo_months    = (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF JJA MAM SON)
set climo_seasons   = (ANN DJF JJA MAM SON)
set iflag           = 1

if (! -e ${path_diag}/attributes) then
    mkdir ${path_diag}/attributes
endif

foreach mth ($climo_months)
   set file = ${path_climo}/${casename}_${mth}_climo.nc
   if ( ! -f $file ) then
      set iflag = 0
   endif
end

if ( $signi == 0 ) then
   foreach mth ($climo_seasons)
      set file = ${path_climo}/${casename}_${mth}_means.nc
      if ( ! -f $file ) then
         set iflag = 0
      endif
   end
endif

if ( $iflag == 1 ) then
   echo "ALL ${simulation} climo FILES ARE PRESENT. NO NEW CLIMATOLOGY WILL BE COMPUTED"
   echo "---> PLEASE USE clean_climo.csh IF YOU WISH TO DELETE THE PRESENT CLIMATOLOGY"
else
   echo "NOT ALL ${simulation} climo FILES ARE PRESENT. NEW CLIMATOLOGY WILL BE COMPUTED"
endif
echo " "

echo $iflag > $path_diag/attributes/${simulation}_compute_climo
