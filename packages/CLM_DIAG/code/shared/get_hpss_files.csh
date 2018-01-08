#!/bin/csh -fx

# written by Keith Oleson
# October 2013

# This script is intended to be run separately from the diagnostics package.
# If your history files are on the hpss, then you can run this script to get all
# of the history files you need and then run the diagnostics package.
# This script will create the casedir and subdirectories if needed.
# This script uses "listo" which is in this directory (code/shared).

# !!! WARNING !!!  Only one instance of this script can be run at a time.
# If you try to run more than one, you will exceed the maximum number of files
# download limit from the HPSS and you will get random download fails.

### START USER MODS

# Set the directory where the history files will be downloaded to
set casedir = /glade/scratch/oleson/ANALYSIS/clm45bgc_1deg4081_hist

# Set the caseid
set caseid = clm45bgc_1deg4081_hist

# Start year of files desired
set start_year = 1850

# Last year of files desired
set finish_year = 2010

# Set mode (clm2, rtm, or cam2)
set mode = clm2

# Set location of history files on hpss - must be consistent with mode, e.g.,
# path for mode = clm2 should be .../lnd/hist
# path for mode = rtm should be  .../rof/hist
# path for mode = atm should be  .../atm/hist
set MSS_path = /home/slevis/csm/clm45bgc_1deg4081_hist/lnd/hist

# Set to 1 if history files are tarred up by year (0 otherwise)
set MSS_tarfile = 0

### END USER MODS

mkdir -p $casedir
if ($mode == rtm) then
  mkdir -p ${casedir}/rof
endif
if ($mode == cam2) then
  mkdir -p ${casedir}/atm
endif

@ start_year = $start_year
@ finish_year = $finish_year
@ year = $start_year

set mydir = `pwd`
if ($mode == rtm) then
  cd ${casedir}/rof
endif
if ($mode == cam2) then
  cd ${casedir}/atm
endif
if ($mode == clm2) then
  cd $casedir
endif

if ($MSS_tarfile == 0) then
  while ($year <= $finish_year)
    hsi -P "cd ${MSS_path} ; ls -P ${caseid}.${mode}.h0.${year}-*.nc" >> ! raw.list
    @ year++
  end
  ~oleson/lnd_diag/run/listo raw.list | sort | awk '{print $4}' > ! list.tmp
  printf "get << EOF \n" >> tmp1
  printf "EOF" >> tmp2
  cat tmp1 list.tmp tmp2 >! list
  rm tmp1 tmp2 list.tmp
  hsi in list
  if ($status == 0) then
    rm raw.list
    rm list
  endif
else
  while ($year <= $finish_year)
    hsi -P "cd ${MSS_path} ; ls -P ${caseid}.${mode}.h0.${year}.tar" >> ! raw.list
    @ year++
  end
  ~oleson/bin/listo raw.list | sort | awk '{print $4}' > ! list.tmp
  printf "get << EOF \n" >> tmp1
  printf "EOF" >> tmp2
  cat tmp1 list.tmp tmp2 >! list
  rm tmp1 tmp2 list.tmp
  hsi in list
  if ($status == 0) then
    rm raw.list
    rm list
    @ year = $start_year
    while ($year <= $finish_year)
       tar -xvf ${caseid}.${mode}.h0.${year}.tar
       rm -f ${caseid}.${mode}.h0.${year}.tar
       @ year++
    end
  endif
endif

cd $mydir

wait

setenv email_address  ${LOGNAME}@ucar.edu
echo `date` > email_msg
echo MESSAGE FROM get_hpss_files.csh >> email_msg
echo YOUR HISTORY FILES ARE NOW READY! >> email_msg
mail -s 'get_hpss_files.csh is complete' $email_address < email_msg
echo E_MAIL SENT
'rm' email_msg
