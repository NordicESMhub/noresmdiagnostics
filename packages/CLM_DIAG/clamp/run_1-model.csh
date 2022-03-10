#!/bin/csh -f
#-------------------------------------------------------------------
# note: user modifies ONLY the "user modification" section 
#
#       MODEL : model name
#       DIR_M  : directory of model data
#       DIR_O  : directory of observed data
#       DIR_S  : directory of model surface data
#       DIR_SCRIPTS  : directory of run scripts
#       FILE1 : time_mean  climatology from CLM diagnostic package
#       FILE2 : 12-monthly climatology from CLM diagnostic package
#       FILE3 : 12-monthly climatology from ATM diagnostic package
#               leave it blank, if no ATM file:
#               set FILE3 =
#       FILE7  : fire      file generated with script in /clamp/time_series
#       FILE8  : ameriflux file generated with script in /clamp/time_series
#
#       GRID  : T31, T42, or 1.9
#       BGC   : cn or casa 
#       ENERGY: new or old (model data fields)
#********************************************************************
# user modification:

setenv first_yr $clim_first_yr_1
setenv nyear  $clim_num_yrs_1
setenv prefix $prefix_1
setenv prefix_dir $prefix_1_dir
setenv nlat $nlat_1
setenv nlon $nlon_1
setenv caseid $caseid_1
setenv case_dir $case_1_dir

@ lyr = $first_yr + $nyear - 1
setenv last_yr $lyr

# model data (no ATM file)
set MODEL  = ${prefix_1}
set DIR_M  = ${prefix_1_dir}
set FILE1  = ${prefix_1}_ANN_climo.nc
set FILE2  = ${prefix_1}_MONS_climo.nc
set FILE3  =
set FILE4  = ${prefix_1}_ANN_climo.nc
set FILE5  = ${prefix_1}_ANN_climo.nc
set FILE6  = ${prefix_1}_ANN_climo.nc
set FILE7  = ${prefix_1}_Fire_C_${first_yr}-${last_yr}_monthly.nc
set FILE8  = ${prefix_1}_ameriflux_${first_yr}-${last_yr}_monthly.nc
set GRID   = $GRID_1
set BGC    = cn
set ENERGY = ${MODEL_TYPE1}

# in the "CLAMP metric processing" section:
#  only 00.initial.ncl and 99.final.ncl are required,
#  user can comment out any one or more of the other ncl scripts,
#  e.g. 
#  #ncl $INPUT_TEXT $DIR_SCRIPTS/10.fire.ncl

# model surface data
 set DIR_S  = $OBS_HOME/obs_data/clamp_data/surface_model/

# # observed data
 set DIR_O  = $OBS_HOME/obs_data/clamp_data/observed/

# # directory for scripts, templates and ncl files
 set DIR_SCRIPTS = $DIAG_HOME/clamp/

# # set a null string to even out the number of args in INPUT_TEXT
set nullVar_s = "null"

#********************************************************************

# add quote, to be usesd in INPUT_TEXT
set MODELQ = \"$MODEL\"
set DIRMQ  = \"$DIR_M\"
set F1  = \"$FILE1\"
set F2  = \"$FILE2\"
set F3  = \"$FILE3\"
set F4  = \"$FILE4\"
set F5  = \"$FILE5\"
set F6  = \"$FILE6\"
set F7  = \"$FILE7\"
set F8  = \"$FILE8\"
set GRIDQ   = \"$GRID\"
set BGCQ    = \"$BGC\"
set ENERGYQ = \"$ENERGY\"
set DIRSQ   = \"$DIR_S\"
set DIROQ   = \"$DIR_O\"
set nullVar = \"$nullVar_s\"

setenv INPUT_TEXT  "model_name=$MODELQ model_grid=$GRIDQ dirm=$DIRMQ film1=$F1 film2=$F2 film3=$F3 film4=$F4 film5=$F5 film6=$F6 film7=$F7 film8=$F8 BGC=$BGCQ ENERGY=$ENERGYQ dirs=$DIRSQ diro=$DIROQ temp99=$nullVar temp98=$nullVar temp97=$nullVar"

#mkdir $DIR_M/$MODEL
#mkdir $DIR_M/$MODEL/ameriflux
#mkdir $DIR_M/$MODEL/beta
#mkdir $DIR_M/$MODEL/biomass
#mkdir $DIR_M/$MODEL/carbon_sink
#mkdir $DIR_M/$MODEL/class
#mkdir $DIR_M/$MODEL/co2
#mkdir $DIR_M/$MODEL/energy
#mkdir $DIR_M/$MODEL/fire
#mkdir $DIR_M/$MODEL/fluxnet
#mkdir $DIR_M/$MODEL/lai
#mkdir $DIR_M/$MODEL/npp
#mkdir $DIR_M/$MODEL/soil_carbon
#mkdir $DIR_M/$MODEL/surface_data
#mkdir $DIR_M/$MODEL/taylor
#mkdir $DIR_M/$MODEL/time_series
#mkdir $DIR_M/$MODEL/turnover
#cp $DIR_SCRIPTS/table.html $DIR_M/$MODEL/
#cp $DIR_SCRIPTS/tablerows.html $DIR_M/$MODEL/
#cp $DIR_SCRIPTS/index.html $DIR_M/$MODEL/

# create a directory for the model by copying from a template
if ($FILE3 != "") then
   set TEMPLATE = template_1-model
else
   set TEMPLATE = template_1-model_noCO2
endif
cp -r $DIR_SCRIPTS/$TEMPLATE $DIR_M/$MODEL


set current = $PWD
cd $DIR_M

ncl $INPUT_TEXT $DIR_SCRIPTS/00.initial.ncl

if ($use_swift == 0) then

ncl $DIR_SCRIPTS/10.write_ameriflux_clm4.5BGC_RUN.ncl
ncl $DIR_SCRIPTS/20.write_fire_clm4.5BGC_RUN.ncl

# CLAMP metric processing
ncl $INPUT_TEXT $DIR_SCRIPTS/01.npp.ncl
ncl $INPUT_TEXT $DIR_SCRIPTS/02.lai.ncl

if ($FILE3 != "") then
ncl $INPUT_TEXT $DIR_SCRIPTS/03.co2.ncl
endif

ncl $INPUT_TEXT $DIR_SCRIPTS/04.biomass.ncl
ncl $INPUT_TEXT $DIR_SCRIPTS/06.fluxnet.ncl
ncl $INPUT_TEXT $DIR_SCRIPTS/07.beta.ncl
ncl $INPUT_TEXT $DIR_SCRIPTS/08.turnover.ncl

if ($MODEL != "casa") then
ncl $INPUT_TEXT $DIR_SCRIPTS/09.carbon_sink.ncl
else
ncl $INPUT_TEXT $DIR_SCRIPTS/09x.carbon_sink.ncl
endif

if ($MODEL != "casa") then
ncl $INPUT_TEXT $DIR_SCRIPTS/10.fire.ncl
endif

ncl $INPUT_TEXT $DIR_SCRIPTS/11.ameriflux.ncl
ncl $INPUT_TEXT $DIR_SCRIPTS/99.final.ncl

# create a tar file from the final output 
tar cf $MODEL.tar $MODEL

else #use_swift == 1

echo $INPUT_TEXT >> $WKDIR/clamp_input_text_1_1.txt
echo "model_name=$MODELQ" >> $WKDIR/clamp_input_text_1.txt
echo "model_grid=$GRIDQ" >> $WKDIR/clamp_input_text_1.txt
echo "dirm=$DIRMQ" >> $WKDIR/clamp_input_text_1.txt
echo "film1=$F1" >> $WKDIR/clamp_input_text_1.txt
echo "film2=$F2" >> $WKDIR/clamp_input_text_1.txt
echo "film3=$F3" >> $WKDIR/clamp_input_text_1.txt
echo "film4=$F4" >> $WKDIR/clamp_input_text_1.txt
echo "film5=$F5" >> $WKDIR/clamp_input_text_1.txt
echo "film6=$F6" >> $WKDIR/clamp_input_text_1.txt
echo "film7=$F7" >> $WKDIR/clamp_input_text_1.txt
echo "film8=$F8" >> $WKDIR/clamp_input_text_1.txt
echo "BGC=$BGCQ" >> $WKDIR/clamp_input_text_1.txt
echo "ENERGY=$ENERGYQ" >> $WKDIR/clamp_input_text_1.txt 
echo "dirs=$DIRSQ" >> $WKDIR/clamp_input_text_1.txt
echo "diro=$DIROQ" >> $WKDIR/clamp_input_text_1.txt
echo "tmp99=$nullVar"  >> $WKDIR/clamp_input_text_1.txt
echo "tmp98=$nullVar"  >> $WKDIR/clamp_input_text_1.txt
echo "tmp97=$nullVar"  >> $WKDIR/clamp_input_text_1.txt

#CLAMP metric processing
echo $DIR_SCRIPTS/01.npp.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/02.lai.ncl >> $WKDIR/clamp_ncl_list.txt

if ($FILE3 != "") then
echo $DIR_SCRIPTS/03.co2.ncl >> $WKDIR/clamp_ncl_list.txt
endif

echo $DIR_SCRIPTS/04.biomass.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/06.fluxnet.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/07.beta.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/08.turnover.ncl >> $WKDIR/clamp_ncl_list.txt

if ($MODEL != "casa") then
echo $DIR_SCRIPTS/09.carbon_sink.ncl >> $WKDIR/clamp_ncl_list.txt
else
echo $DIR_SCRIPTS/09x.carbon_sink.ncl >> $WKDIR/clamp_ncl_list.txt
endif

if ($MODEL != "casa") then
echo $DIR_SCRIPTS/10.fire.ncl >> $WKDIR/clamp_ncl_list.txt
endif

echo $DIR_SCRIPTS/11.ameriflux.ncl >> $WKDIR/clamp_ncl_list.txt

endif
cd $current

