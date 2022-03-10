#!/bin/csh -f
#-------------------------------------------------------------------
# note: user modifies ONLY the "user modification" section 
#
#       COMPARE: model1 vs model2
#       MODELn : model name
#       DIR_M  : directory of model data
#       DIR_O  : directory of observed data
#       DIR_S  : directory of model surface data
#       DIR_SCRIPTS  : directory of run scripts
#       FILE1  : time_mean  climatology from CLM diagnostic package
#       FILE2  : 12-monthly climatology from CLM diagnostic package
#       FILE3  : 12-monthly climatology from ATM diagnostic package
#                leave it blank, if no ATM file:
#                set FILE3 =
#       FILE7  : fire      file generated with script in /clamp/time_series
#       FILE8  : ameriflux file generated with script in /clamp/time_series
#       GRID   : T31, T42, or 1.9
#       BGC    : cn or casa 
#       ENERGY : new or old (fields in model data)
#-------------------------------------------------------------------

#*******************************************************
# user modification-(1)

# directory name of model comparison
set Model_vs_Model = $MODEL_vs_MODEL
set COMPARE = ${prefix_1_dir}${Model_vs_Model}/

#*******************************************************
# user modification-(2)

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

# model1 
set MODEL1  = ${prefix_1} 
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

# observed data
set DIR_O  = $OBS_HOME/obs_data/clamp_data/observed/

# directory for scripts, templates and ncl files
set DIR_SCRIPTS = $DIAG_HOME/clamp/ 

#********************************************************

# add quote, to be usesd in INPUT_TEXT
set MODELQ = \"$MODEL1\"
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
set DIRCQ   = \"$DIR_SCRIPTS\"

set COMPAREQ = \"$COMPARE\"
set MODELN   = \"model1\"

setenv INPUT_TEXT "model_name=$MODELQ model_grid=$GRIDQ dirm=$DIRMQ film1=$F1 film2=$F2 film3=$F3 film4=$F4 film5=$F5 film6=$F6 film7=$F7 film8=$F8 BGC=$BGCQ ENERGY=$ENERGYQ dirs=$DIRSQ diro=$DIROQ dirscript=$DIRCQ modeln=$MODELN compare=$COMPAREQ"
echo $INPUT_TEXT

#mkdir $DIR_M/$MODEL1
#mkdir $DIR_M/$MODEL1/ameriflux
#mkdir $DIR_M/$MODEL1/beta
#mkdir $DIR_M/$MODEL1/biomass
#mkdir $DIR_M/$MODEL1/carbon_sink
#mkdir $DIR_M/$MODEL1/class
#mkdir $DIR_M/$MODEL1/co2
#mkdir $DIR_M/$MODEL1/energy
#mkdir $DIR_M/$MODEL1/fire
#mkdir $DIR_M/$MODEL1/fluxnet
#mkdir $DIR_M/$MODEL1/lai
#mkdir $DIR_M/$MODEL1/npp
#mkdir $DIR_M/$MODEL1/soil_carbon
#mkdir $DIR_M/$MODEL1/surface_data
#mkdir $DIR_M/$MODEL1/taylor
#mkdir $DIR_M/$MODEL1/time_series
#mkdir $DIR_M/$MODEL1/turnover
#cp $DIR_SCRIPTS/table.html $DIR_M/$MODEL1/
#cp $DIR_SCRIPTS/tablerows.html $DIR_M/$MODEL1/
#cp $DIR_SCRIPTS/index.html $DIR_M/$MODEL1/

# create model1 and model1_vs_model2 directory by copying templates
if ($FILE3 != "") then
   set TEMPLATE1 = template_1-model
   set TEMPLATE2 = template_2-model
else
   set TEMPLATE1 = template_1-model_noCO2
   set TEMPLATE2 = template_2-model_noCO2
endif
cp -r $DIR_SCRIPTS/$TEMPLATE1 $DIR_M/$MODEL1
cp -r $DIR_SCRIPTS/$TEMPLATE2 $COMPARE


set current = $PWD
cd $DIR_M/
echo "Running 00.initial.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/00.initial.ncl

if ($use_swift == 0) then

echo "Running 10.write_ameriflux_clm4.5BGC_RUN.ncl"
ncl $DIR_SCRIPTS/10.write_ameriflux_clm4.5BGC_RUN.ncl
echo "Running 20.write_fire_clm4.5BGC_RUN.ncl"
ncl $DIR_SCRIPTS/20.write_fire_clm4.5BGC_RUN.ncl
 
# CLAMP metric processing of model1
echo "Running 01.npp.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/01.npp.ncl
echo "Running 02.lai.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/02.lai.ncl

if ($FILE3 != "") then
echo "Running 03.co2.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/03.co2.ncl
endif

echo "Running 04.biomass.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/04.biomass.ncl
echo "Running 06.fluxnet.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/06.fluxnet.ncl
echo "Running 07.beta.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/07.beta.ncl
echo "Running 08.turnover.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/08.turnover.ncl

if ($MODEL1 != "casa") then
echo "Running 09.carbon_sink.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/09.carbon_sink.ncl
else
echo "Running /09x.carbon_sink.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/09x.carbon_sink.ncl
endif

if ($MODEL1 != "casa") then
echo "Running 10.fire.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/10.fire.ncl
endif

echo "Running 11.ameriflux.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/11.ameriflux.ncl
echo "Running 99.final.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/99.final.ncl

else # use_swift==1

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
echo "dirscript=$DIRCQ" >> $WKDIR/clamp_input_text_1.txt
echo "modeln=$MODELN" >> $WKDIR/clamp_input_text_1.txt
set Model_vs_ModelQ = \"$Model_vs_Model\"
echo  "compare=$Model_vs_ModelQ" >> $WKDIR/clamp_input_text_1.txt

echo $DIR_SCRIPTS/01.npp.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/02.lai.ncl >> $WKDIR/clamp_ncl_list.txt

if ($FILE3 != "") then
echo $DIR_SCRIPTS/03.co2.ncl >> $WKDIR/clamp_ncl_list.txt
endif

echo $DIR_SCRIPTS/04.biomass.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/06.fluxnet.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/07.beta.ncl >> $WKDIR/clamp_ncl_list.txt
echo $DIR_SCRIPTS/08.turnover.ncl >> $WKDIR/clamp_ncl_list.txt

if ($MODEL1 != "casa") then
echo $DIR_SCRIPTS/09.carbon_sink.ncl >> $WKDIR/clamp_ncl_list.txt
else
echo $DIR_SCRIPTS/09x.carbon_sink.ncl >> $WKDIR/clamp_ncl_list.txt
endif

if ($MODEL1 != "casa") then
echo $DIR_SCRIPTS/10.fire.ncl >> $WKDIR/clamp_ncl_list.txt
endif

echo $DIR_SCRIPTS/11.ameriflux.ncl >> $WKDIR/clamp_ncl_list.txt
endif
cd $current

#*******************************************************
# user modification-(3)

setenv first_yr $clim_first_yr_2
setenv nyear  $clim_num_yrs_2
setenv prefix $prefix_2
setenv prefix_dir $prefix_2_dir
setenv nlat $nlat_2
setenv nlon $nlon_2
setenv caseid $caseid_2
setenv case_dir $case_2_dir

@ lyr = $first_yr + $nyear - 1
setenv last_yr $lyr

# model2
set MODEL2  = ${prefix_2}
set DIR_M  = ${prefix_2_dir}
set FILE1  = ${prefix_2}_ANN_climo.nc
set FILE2  = ${prefix_2}_MONS_climo.nc
set FILE3  =
set FILE4  = ${prefix_2}_ANN_climo.nc
set FILE5  = ${prefix_2}_ANN_climo.nc
set FILE6  = ${prefix_2}_ANN_climo.nc
set FILE7  = ${prefix_2}_Fire_C_${first_yr}-${last_yr}_monthly.nc
set FILE8  = ${prefix_2}_ameriflux_${first_yr}-${last_yr}_monthly.nc
set GRID   = $GRID_2
set BGC    = cn
set ENERGY = ${MODEL_TYPE2}

#*******************************************************

# add quote, to be usesd in INPUT_TEXT
set MODELQ  = \"$MODEL2\"
set DIRMQ   = \"$DIR_M\"
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

set COMPAREQ = \"$COMPARE\"
set MODELN   = \"model2\"

setenv INPUT_TEXT "model_name=$MODELQ model_grid=$GRIDQ dirm=$DIRMQ film1=$F1 film2=$F2 film3=$F3 film4=$F4 film5=$F5 film6=$F6 film7=$F7 film8=$F8 BGC=$BGCQ ENERGY=$ENERGYQ dirs=$DIRSQ diro=$DIROQ dirscript=$DIRCQ modeln=$MODELN compare=$COMPAREQ"

#mkdir $DIR_M/$MODEL2
#mkdir $DIR_M/$MODEL2/ameriflux
#mkdir $DIR_M/$MODEL2/beta
#mkdir $DIR_M/$MODEL2/biomass
#mkdir $DIR_M/$MODEL2/carbon_sink
#mkdir $DIR_M/$MODEL2/class
#mkdir $DIR_M/$MODEL2/co2
#mkdir $DIR_M/$MODEL2/energy
#mkdir $DIR_M/$MODEL2/fire
#mkdir $DIR_M/$MODEL2/fluxnet
#mkdir $DIR_M/$MODEL2/lai
#mkdir $DIR_M/$MODEL2/npp
#mkdir $DIR_M/$MODEL2/soil_carbon
#mkdir $DIR_M/$MODEL2/surface_data
#mkdir $DIR_M/$MODEL2/taylor
#mkdir $DIR_M/$MODEL2/time_series
#mkdir $DIR_M/$MODEL2/turnover
#cp $DIR_SCRIPTS/table.html $DIR_M/$MODEL2/
#cp $DIR_SCRIPTS/tablerows.html $DIR_M/$MODEL2/
#cp $DIR_SCRIPTS/index.html $DIR_M/$MODEL2/

set DIR_M1  = ${prefix_1_dir}
# create model2 directory by copying templates
if ($FILE3 != "") then
   set TEMPLATE1 = template_1-model
else
   set TEMPLATE1 = template_1-model_noCO2
endif
cp -r $DIR_SCRIPTS/$TEMPLATE1 $DIR_M/$MODEL2


set current = $PWD
cd $DIR_M
echo "Running 00.initial.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/00.initial.ncl

if ($use_swift == 0) then

echo "Running 10.write_ameriflux_clm4.5BGC_RUN.ncl"
ncl $DIR_SCRIPTS/10.write_ameriflux_clm4.5BGC_RUN.ncl
echo "Running 20.write_fire_clm4.5BGC_RUN.ncl"
ncl $DIR_SCRIPTS/20.write_fire_clm4.5BGC_RUN.ncl

# CLAMP metric processing of model2
echo "Running 01.npp.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/01.npp.ncl
echo "Running 02.lai.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/02.lai.ncl

if ($FILE3 != "") then
echo "Running 03.co2.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/03.co2.ncl
endif

echo "Running 04.biomass.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/04.biomass.ncl
echo "Running 06.fluxnet.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/06.fluxnet.ncl
echo "Running 07.beta.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/07.beta.ncl
echo "Running 08.turnover.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/08.turnover.ncl

if ($MODEL2 != "casa") then
echo "Running 09.carbon_sink.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/09.carbon_sink.ncl
else
echo "Running 09x.carbon_sink.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/09x.carbon_sink.ncl
endif

if ($MODEL2 != "casa") then
echo "Running 10.fire.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/10.fire.ncl
endif

echo "Running 11.ameriflux.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/11.ameriflux.ncl
echo "Running 99.final.ncl"
ncl $INPUT_TEXT $DIR_SCRIPTS/99.final.ncl

mv $DIR_M/$MODEL2 $DIR_M1/
cd $DIR_M1
# create a tar file from the final output
tar cf - $MODEL1 $MODEL2 $Model_vs_Model > all.tar

else # use_swift == 1

echo $INPUT_TEXT >> $WKDIR/clamp_input_text_1_2.txt
echo "model_name=$MODELQ" >> $WKDIR/clamp_input_text_2.txt
echo "model_grid=$GRIDQ" >> $WKDIR/clamp_input_text_2.txt
echo "dirm=$DIRMQ" >> $WKDIR/clamp_input_text_2.txt
echo "film1=$F1" >> $WKDIR/clamp_input_text_2.txt
echo "film2=$F2" >> $WKDIR/clamp_input_text_2.txt
echo "film3=$F3" >> $WKDIR/clamp_input_text_2.txt
echo "film4=$F4" >> $WKDIR/clamp_input_text_2.txt
echo "film5=$F5" >> $WKDIR/clamp_input_text_2.txt
echo "film6=$F6" >> $WKDIR/clamp_input_text_2.txt
echo "film7=$F7" >> $WKDIR/clamp_input_text_2.txt
echo "film8=$F8" >> $WKDIR/clamp_input_text_2.txt
echo "BGC=$BGCQ" >> $WKDIR/clamp_input_text_2.txt
echo "ENERGY=$ENERGYQ" >> $WKDIR/clamp_input_text_2.txt
echo "dirs=$DIRSQ" >> $WKDIR/clamp_input_text_2.txt
echo "diro=$DIROQ" >> $WKDIR/clamp_input_text_2.txt
echo "dirscript=$DIRCQ" >> $WKDIR/clamp_input_text_2.txt
echo "modeln=$MODELN" >> $WKDIR/clamp_input_text_2.txt
set Model_vs_ModelQ = \"$Model_vs_Model\"
echo  "compare=$Model_vs_ModelQ" >> $WKDIR/clamp_input_text_2.txt

echo $DIR_SCRIPTS/01.npp.ncl >> $WKDIR/clamp_ncl_list_2.txt
echo $DIR_SCRIPTS/02.lai.ncl >> $WKDIR/clamp_ncl_list_2.txt

if ($FILE3 != "") then
echo $DIR_SCRIPTS/03.co2.ncl >> $WKDIR/clamp_ncl_list_2.txt
endif

echo $DIR_SCRIPTS/04.biomass.ncl >> $WKDIR/clamp_ncl_list_2.txt
echo $DIR_SCRIPTS/06.fluxnet.ncl >> $WKDIR/clamp_ncl_list_2.txt
echo $DIR_SCRIPTS/07.beta.ncl >> $WKDIR/clamp_ncl_list_2.txt
echo $DIR_SCRIPTS/08.turnover.ncl >> $WKDIR/clamp_ncl_list_2.txt

if ($MODEL2 != "casa") then
echo $DIR_SCRIPTS/09.carbon_sink.ncl >> $WKDIR/clamp_ncl_list_2.txt
else
echo $DIR_SCRIPTS/09x.carbon_sink.ncl >> $WKDIR/clamp_ncl_list_2.txt
endif

if ($MODEL2 != "casa") then
echo $DIR_SCRIPTS/10.fire.ncl >> $WKDIR/clamp_ncl_list_2.txt
endif

echo $DIR_SCRIPTS/11.ameriflux.ncl >> $WKDIR/clamp_ncl_list_2.txt
endif

cd $current

