#!/bin/csh
# USAGE:  setup_plots.csh <tarfile>
# 
# Modified by Johan Liakka, Oct 2017

if ($#argv != 2) then
  echo "usage: setup_plots.csh <tar_file> <to_diff>"
  exit
endif

set tar_file = $1
set to_diff  = $2

cd $WKDIR

## Copy html
if ($to_diff == 1) then
   cp -f ${DIAG_HOME}/web/index_diff_temp.html index_temp.html
   cp -f ${DIAG_HOME}/web/contour_diff.html contour.html
   cp -f ${DIAG_HOME}/web/timeseries_diff.html timeseries.html
   cp -f ${DIAG_HOME}/web/regional_diff.html regional.html
   cp -f ${DIAG_HOME}/web/vector_diff.html vector.html
   set html_title = ${CASE_TO_CONT}-${CASE_TO_DIFF}
else
   cp -f ${DIAG_HOME}/web/index_temp.html index_temp.html
   cp -f ${DIAG_HOME}/web/contour.html contour.html
   cp -f ${DIAG_HOME}/web/timeseries.html timeseries.html
   cp -f ${DIAG_HOME}/web/regional.html regional.html
   cp -f ${DIAG_HOME}/web/vector.html vector.html
   set html_title = ${CASE_TO_CONT}
endif
     
cat >! ./obs/ICESat.txt << EOF1
Documentation of the satellite based (ICESat) derived sea ice thickness is found in:

Kwok, R., G. F. Cunningham, M. Wensnahan, I. Rigor, H. J. Zwally,
and D. Yi, 2009: Thinning and volume loss of the Arctic Ocean
sea ice cover: 2003–2008. J. Geophys. Res., 114, C07005,
doi:10.1029/2009JC005312.
EOF1

cat >! ./obs/ASPeCt.txt << EOF
The ship-based sea ice and snow thickness data were provided by the SCAR 
Antarctic Sea Ice Processes and Climate (ASPeCt) program (www.aspect.aq).
A full description of the data quality control and processing can be found in 
Worby et al (2008).

Worby, A. P., C. Geiger, M. J. Paget, M. van Woert, S. F Ackley, T. DeLiberty, 
(2008). Thickness distribution of Antarctic sea ice. J. Geophys. Res., 113, 
C05S92, doi:10.1029/2007JC004254.
EOF

cat >! ./sed.in << EOF
s#CASENAME#${html_title}#
EOF

sed -f sed.in index_temp.html >! index.html
sed -i -f sed.in contour.html
sed -i -f sed.in vector.html
sed -i -f sed.in timeseries.html
sed -i -f sed.in regional.html
rm -f sed.in
rm -f index_temp.html




