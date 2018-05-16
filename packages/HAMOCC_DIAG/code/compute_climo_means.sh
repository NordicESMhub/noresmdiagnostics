#!/bin/bash

#
# HAMOCC DIAGNOSTICS package: compute_climo_means.sh
# PURPOSE: computes averages from the mon climo files.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  experiment name
#  $first_yr  first yr of climatology
#  $first_yr  last yr of climatology
#  $climodir  climatology directory

casename=$1
first_yr=$2
last_yr=$3
climodir=$4

echo " "
echo "---------------------------"
echo "compute_climo_means.sh"
echo "---------------------------"
echo "Input arguments:"
echo " casename = $casname"
echo " first_yr = $first_yr"
echo " last_yr  = $last_yr"
echo " climodir = $climodir"
echo " "

first_yr_prnt=`printf "%04d" ${first_yr}`
last_yr_prnt=`printf "%04d" ${last_yr}`

# Check available variables
infile=$climodir/${casename}_01_${first_yr_prnt}-${last_yr_prnt}_climo.nc

pp_avail=0
pddpo_avail=0
po4_avail=0
$NCKS --quiet -d y,0 -d x,0 -sigma,0 -v pp,pddpo $infile >/dev/null 2>&1
if [ $? -eq 0 ]; then
    pp_avail=1
fi

if [ $pp_avail -eq 1 ]; then
    echo "Computing column-integrated pp (pp_tot)"
    pid=()
    for mon in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        infile=$climodir/${casename}_${mon}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
        $NCAP2 -O -s 'pp_z=pp*pddpo' $infile $infile &
        pid+=($!)
    done
    for ((m=0;m<=11;m++))
    do
        wait ${pid[$m]}
        if [ $? -ne 0 ]; then
            echo "ERROR in calculating pp_z: $NCAP2 -O -s 'pp_z=pp*pddpo' $infile $infile"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    done
    wait
    pid=()
    for mon in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        infile=$climodir/${casename}_${mon}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
        $NCAP2 -O -s 'pp_tot=pp_z.total($sigma)*86400.0*365.0' $infile $infile &
        pid+=($!)
    done
    for ((m=0;m<=11;m++))
    do
        wait ${pid[$m]}
        if [ $? -ne 0 ]; then
            echo "ERROR in calculating pp_tot: $NCAP2 -O -s 'pp_tot=pp_z.total($sigma)*86400.0*365.0' $infile $infile"
            echo "*** EXITING THE SCRIPT ***"
            exit 1
        fi
    done
    wait
    tmpfile=$climodir/tmp123.nc
    for mon in 01 02 03 04 05 06 07 08 09 10 11 12
    do
        infile=$climodir/${casename}_${mon}_${first_yr_prnt}-${last_yr_prnt}_climo.nc
        $NCATTED -O -a units,pp_tot,m,c,"mol C m-2 yr-1" $infile
        $NCKS -O --no_tmp_fl -C -x -v sigma,pp,pddpo,pp_z $infile $tmpfile
        mv $tmpfile $infile
    done
    sed -i "s/pp/pp_tot/g" $WKDIR/attributes/vars_climo_mon_$casename
    if grep -q ,pddpo $WKDIR/attributes/vars_climo_mon_$casename
    then
        sed -i "s/,pddpo//g" $WKDIR/attributes/vars_climo_mon_$casename
    else
        sed -i "s/pddpo,//g" $WKDIR/attributes/vars_climo_mon_$casename
    fi
else
    echo "WARNING: Could not find pp and/or pddpo in $infile"
fi
