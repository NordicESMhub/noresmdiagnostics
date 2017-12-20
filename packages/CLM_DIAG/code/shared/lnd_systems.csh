#!/bin/csh -f

#*********************************************
echo in lnd_systems.csh
# echo checking for $NCARG_ROOT, .hlruesfile, and \$WKDIR
#*********************************************
#unset noclobber
#if (! $?NCARG_ROOT) then
#  which ncl > ncl.txt
#  set ncl_version   = `cat $DIAG_RESOURCES/ncl.txt`
#  # set NCARG_ROOT elsewhere 
#  setenv NCARG_ROOT  $ncl_version	### BOGUS  Doesn't work.
#  echo $NCARG_ROOT is now set to....
#  echo ERROR: environment variable NCARG_ROOT is not set
#  echo Attempting to set for you....
#  echo You may wish to set in your .cshrc file (or whatever shell you use)
#else
#  set NCL = $NCARG_ROOT/bin/ncl        # works everywhere
#endif
#*********************************************
# check for .hluresfile in $HOME and copy one from
# the package to $HOME if necessary
#*********************************************
if (! -e $HOME/.hluresfile) then
  echo NO .hluresfile PRESENT IN YOUR $HOME DIRECTORY
  echo COPYING default .hluresfile to your $HOME
  cp $DIAG_SHARED/.hluresfile $HOME
endif
#*********************************************
# check if directories exist
#*********************************************
if (! -e ${PTMPDIR}) then
  echo \$PTMPDIR ${PTMPDIR} does not exist: Creating
  mkdir $PTMPDIR
endif
if (! -e ${case_1_dir}) then
  echo \${case_1_dir} ${case_1_dir} does not exist: Creating
  mkdir -m 774 ${case_1_dir}
endif
if (! -e {$prefix_1_dir}) then
  echo \$prefix_1_dir {$prefix_1_dir} does not exist: Creating
  mkdir $prefix_1_dir
endif
if (! -e {$WKDIR}) then
  echo \$WKDIR {$WKDIR} does not exist: Creating
  mkdir $WKDIR
endif
if (-e {$PROCDIR1}) then
  echo removing \$PROCDIR1 {$PROCDIR1} to avoid wildcard errors
  rm -r $PROCDIR1
endif
if (! -e {$PROCDIR1}) then
  echo \$PROCDIR1 {$PROCDIR1} does not exist: Creating
  mkdir $PROCDIR1
endif
if ($climo_atm_1 == 1 || $trends_atm_1 == 1 || $set_4 == 1 ) then
   if (! -e ${case_1_atm_dir}) then
     echo \${case_1_atm_dir} ${case_1_atm_dir} does not exist: Creating
     mkdir -m 774 ${case_1_atm_dir}
   endif
   if (! -e ${prefix_1_atm_dir}) then
     echo \${prefix_1_atm_dir} ${prefix_1_atm_dir} does not exist: Creating
     mkdir ${prefix_1_atm_dir}
   endif
   if (-e {$PROCDIR_ATM1}) then
     echo removing \$PROCDIR_ATM1 {$PROCDIR_ATM1} to avoid wildcard errors
     rm -r $PROCDIR_ATM1
   endif
   if (! -e {$PROCDIR_ATM1}) then
     echo \$PROCDIR_ATM1 {$PROCDIR_ATM1} does not exist: Creating
     mkdir $PROCDIR_ATM1
   endif
endif
if ($rtm_1 == 1 || $climo_rtm_1 == 1) then
   if (! -e ${case_1_rtm_dir}) then
     echo \${case_1_rtm_dir} ${case_1_rtm_dir} does not exist: Creating
     mkdir -m 774 ${case_1_rtm_dir}
   endif
   if (! -e ${prefix_1_rtm_dir}) then
     echo \${prefix_1_rtm_dir} ${prefix_1_rtm_dir} does not exist: Creating
     mkdir ${prefix_1_rtm_dir}
   endif
   if (! -e {$PROCDIR_RTM1}) then
     echo \$PROCDIR_RTM1 {$PROCDIR_RTM1} does not exist: Creating
     mkdir $PROCDIR_RTM1
   endif
endif 
#*********************************************
# check for type of run
#*********************************************
if ($RUNTYPE == "model1-model2") then
   if (! -e ${case_2_dir}) then
  	echo \${case_2_dir} ${case_2_dir} does not exist: Creating
  	mkdir -m 774 ${case_2_dir}
   endif
   if (! -e {$prefix_2_dir}) then
     echo \$prefix_2_dir {$prefix_2_dir} does not exist: Creating
     mkdir $prefix_2_dir
   endif
   if (-e {$PROCDIR2}) then
     echo removing \$PROCDIR2 {$PROCDIR2} to avoid wildcard errors
     rm -r $PROCDIR2
   endif
   if (! -e {$PROCDIR2}) then
     echo \$PROCDIR2 {$PROCDIR2} does not exist: Creating
     mkdir $PROCDIR2
   endif
   if ($climo_atm_2 == 1 || $trends_atm_2 == 1 || $set_4 == 1 ) then
       if (! -e ${case_2_atm_dir}) then
  	    echo \${case_2_atm_dir} ${case_2_atm_dir} does not exist: Creating
  	    mkdir -m 774 ${case_2_atm_dir}
       endif
       if (! -e {$prefix_2_atm_dir}) then
         echo \$prefix_2_atm_dir {$prefix_2_atm_dir} does not exist: Creating
         mkdir $prefix_2_atm_dir
       endif
       if (-e {$PROCDIR_ATM2}) then
         echo removing \$PROCDIR_ATM2 {$PROCDIR_ATM2} to avoid wildcard errors
         rm -r $PROCDIR_ATM2
       endif
       if (! -e {$PROCDIR_ATM2}) then
         echo \$PROCDIR_ATM2 {$PROCDIR_ATM2} does not exist: Creating
         mkdir $PROCDIR_ATM2
       endif
   endif
   if ($rtm_2 == 1 || $climo_rtm_2 == 1) then
      if (! -e ${case_2_rtm_dir}) then
        echo \${case_2_rtm_dir} ${case_2_rtm_dir} does not exist: Creating
        mkdir -m 774 ${case_2_rtm_dir}
      endif
      if (! -e ${prefix_2_rtm_dir}) then
        echo \${prefix_2_rtm_dir} ${prefix_2_rtm_dir} does not exist: Creating
        mkdir ${prefix_2_rtm_dir}
      endif
      if (! -e {$PROCDIR_RTM2}) then
        echo \$PROCDIR_RTM2 {$PROCDIR_RTM2} does not exist: Creating
        mkdir $PROCDIR_RTM2
      endif
   endif 
endif

echo 'finished lnd_systems.csh'
