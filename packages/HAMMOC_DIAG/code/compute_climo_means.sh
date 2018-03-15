#!/bin/bash

#
# MICOM DIAGNOSTICS package: compute_climo_means.sh
# PURPOSE: computes averages from the climo file.
# Johan Liakka, NERSC, johan.liakka@nersc.no
# Last update Mar 2018

# Input arguments:
#  $casename  experiment name
#  $climofile climatology file
#  $climodir  climatology directory

casename=$1
climofile=$2
climodir=$3

echo " "
echo "---------------------------"
echo "compute_climo_means.sh"
echo "---------------------------"
echo "Input arguments:"
echo " casename  = $casname"
echo " climofile = $climofile"
echo " climodir  = $climodir"
echo " "

infile=$climodir/$climofile

# Check if pp and pddpo is included in the climatology file
$NCKS --quiet -d y,0 -d x,0 -sigma,0 -v pp,pddpo $infile >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # Compute columns integrated pp
    echo "Computing column-integrated pp (pp_tot)"
    tmpfile=$climodir/tmp123.nc
    $NCAP2 -O -s 'pp_z=pp*pddpo' $infile $infile
    $NCAP2 -O -s 'pp_tot=pp_z.total($sigma)*86400.0*365.0' $infile $infile
    $NCKS -O --no_tmp_fl -C -x -v sigma,pp,pddpo,pp_z $infile $tmpfile
    $NCATTED -O -a units,pp_tot,m,c,"mol C m-2 yr-1" $tmpfile
    mv $tmpfile $infile
    # Update vars_climo file
    sed -i "s/pp/pp_tot/g" $WKDIR/attributes/vars_climo_$casename
    if /usr/bin/grep -q ,pddpo $WKDIR/attributes/vars_climo_$casename
    then
        /usr/bin/sed -i "s/,pddpo//g" $WKDIR/attributes/vars_climo_$casename
    else
	/usr/bin/sed -i "s/pddpo,//g" $WKDIR/attributes/vars_climo_$casename
    fi
else
    echo "WARNING: Could not find variables pp and pddpo in $infile"
fi

