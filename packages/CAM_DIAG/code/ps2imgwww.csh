#!/bin/csh -f
# file: ps2imgwww.csh
# converts postscript files in $WKDIR to GIF, JPG or PNG files in $WEBDIR
# written by Mark Stevens 
#
# For stand-alone use you must set the variable below 
# to the directory where your postscript files are.
# set WKDIR = /tmp/mstevens/work/
#
# This will work on both DATAPROC and CGD Suns or other 
# systems which have convert installed (part of ImageMagick)
# first command line argument is the set number
# second command line argument is the image type
#----------------------------------------------------------------
if (! ${?DENSITY}) then
  set DENSITY = 150    # default pixels/inch
endif

if (`which convert | wc -w` == 1) then
  set CONVERT_PATH = `which convert`
  set CONVERT = "${CONVERT_PATH} -density $DENSITY -trim -bordercolor white -border 5x5"
else
  echo "ERROR: CONVERT NOT FOUND"
  echo "***EXITING THE SCRIPT"
  exit 1
endif

if ($#argv != 2) then
  echo " "
  echo "ERROR: ps2imgwww accepts two arguments"
  echo "usage: ps2imgwww <set2,set3,set4,set4a,set5,set6,set7,set8,set9,set10,set11,set12,set13,set14,set15,set16,all,wset1> <gif,jpg,png>" 
  exit
else
  if ($1 != all && $1 != set2 && $1 != set3 && $1 != set4 && $1 != set4a && $1 != set5 \
      && $1 != set6 && $1 != set7 && $1 != set8 && $1 != set9 && \
      $1 != set10 && $1 != set11 && $1 != set12 && $1 != set13 && $1 != set14 && $1 != set15 && $1 != set16 && \
      $1 != wset1 && $1 != cset2 && $1 != cset3 && $1 != cset4 && $1 != cset5 && $1 != cset6 && $1 != cset7 && \
      $1 != tset1) then
    echo " "
    echo "ERROR: incorrect first argument"
    echo "usage: ps2imgwww <set2,set3,set4,set4a,set5,set6,set7,set8,set9,set10,set11,set12,set13,set14,set15,set16,all,wset1> <jpg,gif,png>" 
    exit
  endif
endif
if ($2 != gif && $2 != jpg && $2 != png) then
  echo " "
  echo "ERROR: incorrect second argument"
  echo "usage: ps2imgwww <set2,set3,set4,set4a,set5,set6,set7,set8,set9,set10,set11,set12,set13,set14,set15,set16,all,wset1> <jpg,gif,png>" 
  exit
endif

if ($1 == set2 || $1 == all) then
  echo CONVERTING SET2 PS FILES TO $2 
  foreach file ({$WKDIR}/set2*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set2/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set2*.ps
  endif
endif
if ($1 == set3 || $1 == all) then
  echo CONVERTING SET3 PS FILES TO $2 
  foreach file ({$WKDIR}/set3*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set3/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set3*.ps
  endif
endif
if ($1 == set4 || $1 == all) then
  echo CONVERTING SET4 PS FILES TO $2 
  foreach file ({$WKDIR}/set4_*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set4/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set4_*.ps
  endif
endif
if ($1 == set4a || $1 == all) then
  echo CONVERTING SET4a PS FILES TO $2 
  foreach file ({$WKDIR}/set4a*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set4a/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set4a*.ps
  endif
endif
if ($1 == set5 || $1 == all) then
  echo CONVERTING SET5 PS FILES TO $2 
  foreach file ({$WKDIR}/set5*.ps)
    set filename = $file:t
    if ($SIG_PLOT == True) then
      $CONVERT -rotate -90 $file ${WEBDIR}/set5_6/$filename:r.$2
    else
      $CONVERT $file ${WEBDIR}/set5_6/$filename:r.$2
    endif
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set5*.ps
  endif
endif
if ($1 == set6 || $1 == all) then
  echo CONVERTING SET6 PS FILES TO $2
  foreach file ({$WKDIR}/set6*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set5_6/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set6*.ps
  endif
endif
if ($1 == set7 || $1 == all) then
  echo CONVERTING SET7 PS FILES TO $2
  foreach file ({$WKDIR}/set7*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set7/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set7*.ps
  endif
endif
if ($1 == set8 || $1 == all) then
  echo CONVERTING SET8 PS FILES TO $2 
  foreach file ({$WKDIR}/set8*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set8/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set8*.ps
  endif
endif
if ($1 == set9 || $1 == all) then
  echo CONVERTING SET9 PS FILES TO $2
  foreach file ({$WKDIR}/set9*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set9/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set9*.ps
  endif
endif
if ($1 == set10 || $1 == all) then
  echo CONVERTING SET10 PS FILES TO $2
  foreach file ({$WKDIR}/set10*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set10/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set10*.ps
  endif
endif
if ($1 == set11 || $1 == all) then
  echo CONVERTING SET11 PS FILES TO $2 
  foreach file ({$WKDIR}/set11*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set11/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set11*.ps
  endif
endif
if ($1 == set12 || $1 == all) then
  echo CONVERTING SET12 PS FILES TO $2 
  foreach file ({$WKDIR}/set12*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set12/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set12*.ps
  endif
endif
if ($1 == set13 || $1 == all) then
  echo CONVERTING SET13 PS FILES TO $2 
  foreach file ({$WKDIR}/set13*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set13/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set13*.ps
  endif
endif

if ($1 == set14 || $1 == all) then
  echo CONVERTING SET14 EPS FILES TO $2 
  foreach file ({$WKDIR}/set14*.eps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set14/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set14*.eps
  endif
endif

if ($1 == set15 || $1 == all) then
  echo CONVERTING SET15 PS FILES TO $2 
  foreach file ({$WKDIR}/set15*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set15/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set15*.ps
  endif
endif

if ($1 == set16 || $1 == all) then
  echo CONVERTING SET16 PS FILES TO $2 
  foreach file ({$WKDIR}/set16*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/set16/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/set16*.ps
  endif
endif

if ($1 == tset1) then
  echo CONVERTING TSET1 PS FILES TO $2 
  foreach file ({$WKDIR}/tset1*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/tset1/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/tset1*.ps
  endif
endif

if ($1 == wset1 || $1 == all) then
  echo CONVERTING WSET1 PS FILES TO $2 
  foreach file ({$WKDIR}/wset1_*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/wset1/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/wset1_*.ps
  endif
endif

if ($1 == cset2 || $1 == all) then
  echo CONVERTING SET2 PS FILES TO $2 
  foreach file ({$WKDIR}/cset2*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/cset2/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/cset2*.ps
  endif
endif
if ($1 == cset3 || $1 == all) then
  echo CONVERTING SET3 PS FILES TO $2 
  foreach file ({$WKDIR}/cset3*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/cset3/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/cset3*.ps
  endif
endif
if ($1 == cset4 || $1 == all) then
  echo CONVERTING SET4 PS FILES TO $2 
  foreach file ({$WKDIR}/cset4_*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/cset4/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/cset4_*.ps
  endif
endif
if ($1 == cset5 || $1 == all) then
  echo CONVERTING SET5 PS FILES TO $2 
  foreach file ({$WKDIR}/cset5*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/cset5/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/cset5_*.ps
  endif
endif
if ($1 == cset6 || $1 == all) then
  echo CONVERTING CSET6 PS FILES TO $2 
  foreach file ({$WKDIR}/cset6*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/cset6/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/cset6_*.ps
  endif
endif
if ($1 == cset7 || $1 == all) then
  echo CONVERTING SET7 PS FILES TO $2 
  foreach file ({$WKDIR}/cset7*.ps)
    set filename = $file:t
    $CONVERT $file ${WEBDIR}/cset7/$filename:r.$2
  end 
  if ($DELETEPS == 0) then
    \rm ${WKDIR}/cset7_*.ps
  endif
endif
