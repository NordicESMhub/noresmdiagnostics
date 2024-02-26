; NCL script
; plot_latlon.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Dec 2017
; Yanchun He, Jul 2019: Add mlts
;********************************************************
load "$DIAG_CODE/functions_latlon.ncl"
;********************************************************
begin

compare    = getenv("COMPARE")
rgb_dir    = getenv("DIAG_RGB")
wkdir      = getenv("WKDIR")
infile1    = getenv("INFILE1")     ; case1 climo input filename
fyr1       = getenv("FYR1")
lyr1       = getenv("LYR1")
infile2    = getenv("INFILE2")     ; case2 climo input filename
case1      = getenv("CASE1")

woa13_temp_flag  = getenv("WOA13_TEMP_FLAG")
if (.not.ismissing(woa13_temp_flag) .and. woa13_temp_flag .eq. "IN-SITU") then
  woa13tf="woa13_decav_t00_01.nc"
  woa13tv="t_an"
  print("info: WOA13 in-situ temperature is used for model-obs comparision")
else
  woa13tf="woa13_decav_potmp00_01.nc"
  woa13tv="potmp"
  print("info: WOA13 calculated potential temperature is used for model-obs comparision")
end if

; CASE 1 Model
inptr1 = addfile(infile1,"r")
yrs_ave1 = fyr1+"-"+lyr1
tmp = inptr1->lat             ; latitudes
if (typeof(tmp).eq."double") then
  lat1 = dble2flt(tmp)
else
  lat1 = tmp
end if
delete(tmp)
nlat1 = dimsizes(lat1)       ; number of latitudes
tmp = inptr1->lon            ; longitudes
if (typeof(tmp).eq."double") then
  lon1 = dble2flt(tmp)
else
  lon1 = tmp
end if
delete(tmp)
nlon1 = dimsizes(lon1)       ; number of longitudes
tmp = inptr1->depth          ; depth
if (typeof(tmp).eq."double") then
  depth1 = dble2flt(tmp)
else
  depth1 = tmp
end if
delete(tmp)
nz1 = dimsizes(depth1)       ; number vertical levels
; Calculate gw
gw1temp = latRegWgt(lat1,"double",0)
gw1 = gw1temp
delete(gw1temp)
gw1!0 = "lat"
gw1&lat = lat1

; Define RGB files
rgb_file  = rgb_dir+"/blueyellowred2.rgb"
rgb_file3 = rgb_dir+"/blueyellowred3.rgb"
rgb_filed = rgb_dir+"/bluered2.rgb"

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  ptr_woa13t = addfile(infile2+"/WOA13/1deg/"+woa13tf,"r")
  ptr_woa13s = addfile(infile2+"/WOA13/1deg/woa13_decav_s00_01.nc","r")
  ptr_woce   = addfile(infile2+"/MLD/mld_clim_WOCE_ANN.nc","r")
  ptr_maxi   = addfile(infile2+"/SSH/MDOT110107.nc","r")
else
  inptr2   = addfile(infile2,"r")
  case2    = getenv("CASE2")
  fyr2     = getenv("FYR2")
  lyr2     = getenv("LYR2")
  yrs_ave2 = fyr2+"-"+lyr2
  tmp = inptr2->lat
  if (typeof(tmp).eq."double") then
    lat2 = dble2flt(tmp)
  else
    lat2 = tmp
  end if
  delete(tmp)
  nlat2 = dimsizes(lat2)       ; number of latitudes
  tmp = inptr2->lon            ; longitudes
  if (typeof(tmp).eq."double") then
    lon2 = dble2flt(tmp)
  else
    lon2 = tmp
  end if
  delete(tmp)
  nlon2 = dimsizes(lon2)       ; number of longitudes
  tmp = inptr2->depth          ; depth
  if (typeof(tmp).eq."double") then
    depth2 = dble2flt(tmp)
  else
    depth2 = tmp
  end if
  delete(tmp)
  nz2 = dimsizes(depth2)       ; number vertical levels
  ; Calculate gw
  gw2temp = latRegWgt(lat2,"double",0)
  gw2 = gw2temp
  delete(gw2temp)
  gw2!0 = "lat"
  gw2&lat = lat2
end if
 
;************************************************
; define variables to plot
;************************************************
; contours definition (global)
cntrs_templvl_top=(/-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/)
cntrs_dummy=(/-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36/)
dcntrs_templvl_top=(/-3.5,-3,-2.5,-2,-1.5,-1,-0.5,-0.3,-0.1,0.1,0.3,0.5,1,1.5,2,2.5,3,3.5/)
cntrs_templvl_bot=(/-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5/)
dcntrs_templvl_bot=(/-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7/)

cntrs_salnlvl_top=(/28.5,29,29.5,30,30.5,31,31.5,32,32.5,33,33.5,34,34.5,35,35.5,36,36.5,37,37.5,38/)
dcntrs_salnlvl_top=(/-3.4,-3,-2.6,-2.2,-1.8,-1.4,-1,-0.6,-0.2,0.2,0.6,1,1.4,1.8,2.2,2.6,3,3.4/)
cntrs_salnlvl_bot=(/33.2,33.4,33.6,33.8,34,34.2,34.4,34.6,34.8,35,35.2,35.4,35.6,35.8,36,36.2,36.4,36.6,36.8,37/)
dcntrs_salnlvl_bot=(/-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9/)

cntrs_mlts=(/10,20,30,40,50,60,70,80,90,100,110,125,150,175,200,250,300,400,500,750/)
dcntrs_mlts=(/-250,-200,-150,-100,-75,-50,-25,-10,-5,5,10,25,50,75,100,150,200,250/)

cntrs_sealv=(/-1.9,-1.7,-1.5,-1.3,-1.1,-0.9,-0.7,-0.5,-0.3,-0.1,0.1,0.3,0.5,0.7,0.9,1.1,1.3,1.5,1.7,1.9/)
dcntrs_sealv=(/-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9/)

; model variables
vars = (/"templvl0","templvl50","templvl100","templvl250","templvl500",\
         "templvl1000","templvl2000","templvl3000","templvl4000",\
         "salnlvl0","salnlvl50","salnlvl100","salnlvl250","salnlvl500",\
         "salnlvl1000","salnlvl2000","salnlvl3000","salnlvl4000","mlts","sealv"/)

; define contour intervals
cntrs = (/cntrs_dummy,cntrs_dummy,cntrs_dummy,cntrs_dummy,cntrs_dummy,\
          cntrs_dummy,cntrs_templvl_bot,cntrs_templvl_bot,cntrs_templvl_bot,\
          cntrs_salnlvl_top,cntrs_salnlvl_top,cntrs_salnlvl_top,cntrs_salnlvl_top,cntrs_salnlvl_top,\
          cntrs_salnlvl_bot,cntrs_salnlvl_bot,cntrs_salnlvl_bot,cntrs_salnlvl_bot,cntrs_mlts,cntrs_sealv/)

dcntrs = (/dcntrs_templvl_top,dcntrs_templvl_top,dcntrs_templvl_top,dcntrs_templvl_top,dcntrs_templvl_top,\
           dcntrs_templvl_top,dcntrs_templvl_bot,dcntrs_templvl_bot,dcntrs_templvl_bot,\
           dcntrs_salnlvl_top,dcntrs_salnlvl_top,dcntrs_salnlvl_top,dcntrs_salnlvl_top,dcntrs_salnlvl_top,\
           dcntrs_salnlvl_bot,dcntrs_salnlvl_bot,dcntrs_salnlvl_bot,dcntrs_salnlvl_bot,dcntrs_mlts,dcntrs_sealv/)

nvars = dimsizes(vars)

; model-to-obs comparisons 

if (compare .eq. "OBS") then

  woa13t_vars = (/"t_an0","t_an50","t_an100","t_an250","t_an500","t_an1000","t_an2000","t_an3000","t_an4000"/)
  woa13s_vars = (/"s_an0","s_an50","s_an100","s_an250","s_an500","s_an1000","s_an2000","s_an3000","s_an4000"/)
  woce_vars = (/"mld"/)
  maxi_vars = (/"mdot"/)

  ; observations: list of variables to plot
  obsvars = (/"t_an0","t_an50","t_an100","t_an250","t_an500",\
              "t_an1000","t_an2000","t_an3000","t_an4000",\
              "s_an0","s_an50","s_an100","s_an250","s_an500",\
              "s_an1000","s_an2000","s_an3000","s_an4000","mld","mdot"/) 
end if
;-------------------------------------------------------------
; common resources for global contour plots 

res = True      
res@mpCenterLonF = 0 
;res@mpCenterLonF = 270 
res@mpGeophysicalLineThicknessF = 1.0
res@gsnDraw = False           ; Do not draw plot
res@gsnFrame = False          ; Do not advance frame
res@gsnTickMarksOn = False
res@tiMainFont = "Helvetica"
res@vpXF = 0.05
res@vpWidthF = 1.00
res@vpHeightF = 0.70
res@mpPerimOn = True
res@mpPerimDrawOrder = "PostDraw"
res@mpFillOn = False
res@lbLabelBarOn = True
res@lbTitleOn = True
res@lbBoxMinorExtentF = 0.15
res@txFontHeightF = 0.020
res@tiMainFontHeightF = 0.025
res@lbLabelAutoStride = False
res@lbOrientation = "Vertical"
res@lbLabelFontHeightF = 0.015
res@lbTitleFontHeightF = 0.018
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnFillOn = True
res@cnLinesOn = False
res@cnMissingValFillColor = "gray75"
res@cnLineLabelsOn = False
cmap  = RGBtoCmap(rgb_file)
cmap3 = RGBtoCmap(rgb_file3)
cmapd = RGBtoCmap(rgb_filed)

;--------------------------------------------------------------
; common resources for panel plots
pan = True
pan@gsnMaximize = True
pan@gsnFrame = False
pan@gsnPaperOrientation = "portrait"
pan@gsnPanelYWhiteSpacePercent = 2

;--------------------------------------------------------------

do i = 0, nvars-1
  ;print("==================")
  ;print("====="+ vars(i))
;----------------------------
; Test case: CASE 1 MODEL
;----------------------------

  if (vars(i) .eq. "mlts") then
    A = get_mlts (inptr1)
  end if

  if (vars(i) .eq. "templvl0") then
    A = get_templvl (inptr1,depth1,0.0)
  end if

  if (vars(i) .eq. "templvl50") then
    A = get_templvl (inptr1,depth1,50.0)
  end if

  if (vars(i) .eq. "templvl100") then
    A = get_templvl (inptr1,depth1,100.0)
  end if

  if (vars(i) .eq. "templvl250") then
    A = get_templvl (inptr1,depth1,250.0)
  end if

  if (vars(i) .eq. "templvl500") then
    A = get_templvl (inptr1,depth1,500.0)
  end if

  if (vars(i) .eq. "templvl1000") then
    A = get_templvl (inptr1,depth1,1000.0)
  end if

  if (vars(i) .eq. "templvl1500") then
    A = get_templvl (inptr1,depth1,1500.0)
  end if

  if (vars(i) .eq. "templvl2000") then
    A = get_templvl (inptr1,depth1,2000.0)
  end if

  if (vars(i) .eq. "templvl2500") then
    A = get_templvl (inptr1,depth1,2500.0)
  end if

  if (vars(i) .eq. "templvl3000") then
    A = get_templvl (inptr1,depth1,3000.0)
  end if

  if (vars(i) .eq. "templvl4000") then
    A = get_templvl (inptr1,depth1,4000.0)
  end if

  if (vars(i) .eq. "templvl5000") then
    A = get_templvl (inptr1,depth1,5000.0)
  end if

  if (vars(i) .eq. "salnlvl0") then
    A = get_salnlvl (inptr1,depth1,0.0)
  end if

  if (vars(i) .eq. "salnlvl50") then
    A = get_salnlvl (inptr1,depth1,50.0)
  end if

  if (vars(i) .eq. "salnlvl100") then
    A = get_salnlvl (inptr1,depth1,100.0)
  end if

  if (vars(i) .eq. "salnlvl250") then
    A = get_salnlvl (inptr1,depth1,250.0)
  end if

  if (vars(i) .eq. "salnlvl500") then
    A = get_salnlvl (inptr1,depth1,500.0)
  end if

  if (vars(i) .eq. "salnlvl1000") then
    A = get_salnlvl (inptr1,depth1,1000.0)
  end if

  if (vars(i) .eq. "salnlvl1500") then
    A = get_salnlvl (inptr1,depth1,1500.0)
  end if

  if (vars(i) .eq. "salnlvl2000") then
    A = get_salnlvl (inptr1,depth1,2000.0)
  end if

  if (vars(i) .eq. "salnlvl2500") then
    A = get_salnlvl (inptr1,depth1,2500.0)
  end if

  if (vars(i) .eq. "salnlvl3000") then
    A = get_salnlvl (inptr1,depth1,3000.0)
  end if

  if (vars(i) .eq. "salnlvl4000") then
    A = get_salnlvl (inptr1,depth1,4000.0)
  end if

  if (vars(i) .eq. "salnlvl5000") then
    A = get_salnlvl (inptr1,depth1,5000.0)
  end if

  if (vars(i) .eq. "sealv") then
    A = get_sealv (inptr1)
  end if

  if (all(A.eq.-999.)) then
    print (vars(i)+" not present in case1 input file.")
    delete(A)
    continue       ; procede to next variable in do loop
  end if

;----------------------------
; Control case (if model to model comparison)
; or observation (if model to obs comparison)
;----------------------------
 ;-------------
 ; Observation (if model to obs comparison)
 ;-------------
  if (compare .eq. "OBS") then            ; CASE 2 IS OBS DATA
   
   ;print("====="+ obsvars(i))   

   if (any(obsvars(i) .eq. woa13t_vars)) then
     inptr2 = ptr_woa13t
     case2 = "WOA13"
   end if

   if (any(obsvars(i) .eq. woa13s_vars)) then
     inptr2 = ptr_woa13s
     case2 = "WOA13"
   end if

   if (any(obsvars(i) .eq. woce_vars)) then
     inptr2 = ptr_woce
     case2 = "de Boyer Montegut et al. (2004)"
   end if

   if (any(obsvars(i) .eq. maxi_vars)) then
     inptr2 = ptr_maxi
     case2 = "Maximenko et al. (2009)"
   end if
   
;   get latitudes,longitudes, and weights
    lat2 = inptr2->lat
    nlat2 = dimsizes(lat2) 
    lon2 = inptr2->lon
    nlon2 = dimsizes(lon2)
    gw2 = latGauWgt(nlat2,"lat","gaussian weights","none") 

; get the variable

    B = -999.
    if (vars(i) .eq. "templvl0") then
      delete(B)
      B = inptr2->$woa13tv$(0,{0},:,:)
      B@long_name = "Temperature z=0m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl50") then
      delete(B)
      B = inptr2->$woa13tv$(0,{50},:,:)
      B@long_name = "Temperature z=50m"
      B@units = "degC"
    end if

    if (vars(i) .eq. "templvl100") then
      delete(B)
      B = inptr2->$woa13tv$(0,{100},:,:)
      B@long_name = "Temperature z=100m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl250") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{250},:,:)
      B@long_name = "Temperature z=250m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl500") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{500},:,:)
      B@long_name = "Temperature z=500m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl1000") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{1000},:,:)
      B@long_name = "Temperature z=1000m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl1500") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{1500},:,:)
      B@long_name = "Temperature z=1500m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl2000") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{2000},:,:)
      B@long_name = "Temperature z=2000m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl2500") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{2500},:,:)
      B@long_name = "Temperature z=2500m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl3000") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{3000},:,:)
      B@long_name = "Temperature z=3000m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl4000") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{4000},:,:)
      B@long_name = "Temperature z=4000m"
      B@units = "degC"      
    end if

    if (vars(i) .eq. "templvl5000") then
      delete(B)    
      B = inptr2->$woa13tv$(0,{5000},:,:)
      B@long_name = "Temperature z=5000m"
      B@units = "degC"
    end if

    if (vars(i) .eq. "salnlvl0") then
      delete(B)    
      B = inptr2->s_an(0,{0},:,:)
      B@long_name = "Salinity z=0m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl50") then
      delete(B)    
      B = inptr2->s_an(0,{50},:,:)
      B@long_name = "Salinity z=50m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl100") then
      delete(B)    
      B = inptr2->s_an(0,{100},:,:)
      B@long_name = "Salinity z=100m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl250") then
      delete(B)    
      B = inptr2->s_an(0,{250},:,:)
      B@long_name = "Salinity z=250m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl500") then
      delete(B)    
      B = inptr2->s_an(0,{500},:,:)
      B@long_name = "Salinity z=500m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl1000") then
      delete(B)    
      B = inptr2->s_an(0,{1000},:,:)
      B@long_name = "Salinity z=1000m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl1500") then
      delete(B)    
      B = inptr2->s_an(0,{1500},:,:)
      B@long_name = "Salinity z=1500m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl2000") then
      delete(B)    
      B = inptr2->s_an(0,{2000},:,:)
      B@long_name = "Salinity z=2000m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl2500") then
      delete(B)    
      B = inptr2->s_an(0,{2500},:,:)
      B@long_name = "Salinity z=2500m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl3000") then
      delete(B)    
      B = inptr2->s_an(0,{3000},:,:)
      B@long_name = "Salinity z=3000m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl4000") then
      delete(B)    
      B = inptr2->s_an(0,{4000},:,:)
      B@long_name = "Salinity z=4000m"
      B@units = "g/kg"      
    end if

    if (vars(i) .eq. "salnlvl5000") then
      delete(B)    
      B = inptr2->s_an(0,{5000},:,:)
      B@long_name = "Salinity z=5000m"
      B@units = "g/kg"      
    end if

    if (vars(i).eq."mld" .or. vars(i).eq."mlts") then
      delete(B)    
      B = inptr2->mld(0,:,:)
      B@long_name = "Mixed layer depth"
      B@units = "m"      
    end if

    if (vars(i).eq."sealv") then
      delete(B)    
      B = inptr2->mdot(:,:)
      B@long_name = "SSH"
      B@units = "m"      
    end if

    if (all(B.eq.-999.)) then
      print (vars(i)+" not present in observations: plotting only model results")
    end if

 ;-------------
 ; Control case (if model to model comparison)
 ;-------------

  else                               ; CASE 2 IS MODEL

    if (vars(i) .eq. "mlts") then
      B = get_mlts (inptr2)
    end if

    if (vars(i) .eq. "templvl0") then
      B = get_templvl (inptr2,depth2,0.0)
    end if

    if (vars(i) .eq. "templvl50") then
      B = get_templvl (inptr2,depth2,50.0)
    end if

    if (vars(i) .eq. "templvl100") then
      B = get_templvl (inptr2,depth2,100.0)
    end if

    if (vars(i) .eq. "templvl250") then
      B = get_templvl (inptr2,depth2,250.0)
    end if

    if (vars(i) .eq. "templvl500") then
      B = get_templvl (inptr2,depth2,500.0)
    end if

    if (vars(i) .eq. "templvl1000") then
      B = get_templvl (inptr2,depth2,1000.0)
    end if

    if (vars(i) .eq. "templvl1500") then
      B = get_templvl (inptr2,depth2,1500.0)
    end if

    if (vars(i) .eq. "templvl2000") then
      B = get_templvl (inptr2,depth2,2000.0)
    end if

    if (vars(i) .eq. "templvl2500") then
      B = get_templvl (inptr2,depth2,2500.0)
    end if

    if (vars(i) .eq. "templvl3000") then
      B = get_templvl (inptr2,depth2,3000.0)
    end if

    if (vars(i) .eq. "templvl4000") then
      B = get_templvl (inptr2,depth2,4000.0)
    end if

    if (vars(i) .eq. "templvl5000") then
      B = get_templvl (inptr2,depth2,5000.0)
    end if

    if (vars(i) .eq. "salnlvl0") then
      B = get_salnlvl (inptr2,depth2,0.0)
    end if

    if (vars(i) .eq. "salnlvl50") then
      B = get_salnlvl (inptr2,depth2,50.0)
    end if

    if (vars(i) .eq. "salnlvl100") then
      B = get_salnlvl (inptr2,depth2,100.0)
    end if

    if (vars(i) .eq. "salnlvl250") then
      B = get_salnlvl (inptr2,depth2,250.0)
    end if

    if (vars(i) .eq. "salnlvl500") then
      B = get_salnlvl (inptr2,depth2,500.0)
    end if

    if (vars(i) .eq. "salnlvl1000") then
      B = get_salnlvl (inptr2,depth2,1000.0)
    end if

    if (vars(i) .eq. "salnlvl1500") then
      B = get_salnlvl (inptr2,depth2,1500.0)
    end if

    if (vars(i) .eq. "salnlvl2000") then
      B = get_salnlvl (inptr2,depth2,2000.0)
    end if

    if (vars(i) .eq. "salnlvl2500") then
      B = get_salnlvl (inptr2,depth2,2500.0)
    end if

    if (vars(i) .eq. "salnlvl3000") then
      B = get_salnlvl (inptr2,depth2,3000.0)
    end if

    if (vars(i) .eq. "salnlvl4000") then
      B = get_salnlvl (inptr2,depth2,4000.0)
    end if

    if (vars(i) .eq. "salnlvl5000") then
      B = get_salnlvl (inptr2,depth2,5000.0)
    end if

    if (vars(i) .eq. "sealv") then
       B = get_sealv (inptr2)
    end if

    if (all(B.eq.-999.)) then
      print (vars(i)+" not present in case2 file.")
      delete(A)
      delete(B)
      continue       ; procede to next variable in do loop
    end if
  end if

; compute area weighted mean of the fields
; after masking higher res data with lower res grid.
; compute RMSE of the two fields after interpolating to the
; same grid iff needed, and the mean of the difference of the
; interpolated fields

  if (all(B.ne.-999.)) then
    if (nlat1 .eq. nlat2) then            ; same grids
      gblmean_A = wgt_areaave (A,gw1,1.0,0)
      gblmean_B = wgt_areaave (B,gw2,1.0,0)

      gblrmse = wgt_arearmse(A,B,gw1,1.0,0)

      C = A
      C = (/A - B/)
      gblmean_C = wgt_areaave(C,gw1,1.0,0)
    else                                   ; different grids
      if (nlat1 .gt. nlat2) then           ; interp A to nlat2

        tmp = B
        tmp = linint2(lon1,lat1,A,True,lon2,lat2,0)

        Amask = B             ; *RBN - The following lines are a cheat to make sure the printed
        Amask = (/B+tmp-B/)   ; means on the plots are consistant with the masking 
        Bmask = B             ; used in the difference of means, C. whenever
        Bmask = (/B-tmp+tmp/) ; there is anyy land/ice masking in the plots

        gblmean_A = wgt_areaave (Amask,gw2,1.0,0)
        gblmean_B = wgt_areaave (Bmask,gw2,1.0,0)

      
        gblrmse = wgt_arearmse(Amask,Bmask,gw2,1.0,0)
        C = B
        C = (/tmp - B/)
        gblmean_C = wgt_areaave(C,gw2,1.0,0)
      
      else                                ; interp B to nlat1       
      
        tmp = A
        tmp = linint2(lon2,lat2,B,True,lon1,lat1,0)

        Bmask = A             ; *RBN - The following lines are a cheat to make sure the printed
        Bmask = (/A+tmp-A/)   ; means on the plots are consistant with the masking 
        Amask = A             ; used in the difference of means, C  whenever
        Amask = (/A-tmp+tmp/) ; there is anyy land/ice masking in the plots

        gblmean_A = wgt_areaave (Amask,gw1,1.0,0)
        gblmean_B = wgt_areaave (Bmask,gw1,1.0,0)

        gblrmse = wgt_arearmse(Amask,Bmask,gw1,1.0,0)
        C = A
        C = (/A - tmp/)
        gblmean_C = wgt_areaave(C,gw1,1.0,0)
      end if
      delete (tmp)
      delete(Bmask)
      delete(Amask)
    end if
    plot = new((/3/),"graphic")      ; global plots
  else
    gblmean_A = wgt_areaave (A,gw1,1.0,0)
    if (compare.eq."OBS") then
       plot = new(1,"graphic")      ; global plots
    else
       plot = new((/3/),"graphic")      ; global plots
    end if
  end if

;--------------------- Open files for plots ------------------------------
  if (compare .eq. "OBS") then
    wks = gsn_open_wks("ps",wkdir+"/set3_ann_"+vars(i)+"_1model")
  else
    wks = gsn_open_wks("ps",wkdir+"/set3_ann_"+vars(i)+"_2models") 
  end if

  if (compare .eq. "OBS") then
    delete(gw2)
    delete(lat2)
    delete(nlat2)
    delete(lon2)
    delete(nlon2)
  end if
;------------------------- GLOBAL CE PLOTS ------------------------
  min1 = min(A)
  max1 = max(A)
  if (all(B.ne.-999.)) then
    min2 = min(B)
    max2 = max(B)
  end if
  res@lbLabelStride = 2
  if (vars(i).eq."templvl0" .or. vars(i).eq."templvl50" .or. vars(i).eq."templvl100" .or. \
      vars(i).eq."templvl250" .or. vars(i).eq."templvl500" .or. vars(i).eq."templvl1000") then
     res@cnLevels = cntrs_templvl_top
     res@cnFillPalette   = cmap3
  else
     res@cnLevels = cntrs(i,:)
     res@cnFillPalette   = cmap
  end if
  res@lbTitleString = "Min = "+sprintf("%6.2f",min1)+ \
                     " Max = "+sprintf("%6.2f",max1)

  if (isvar("yrs_ave1")) then
    res@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else  
    res@tiMainString = case1
  end if
  res@gsnLeftString = A@long_name
  res@gsnRightString = A@units
  res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean_A)
;  gsn_define_colormap (wks,cmap)

  if (all(B.eq.-999.)) then
    plot = gsn_csm_contour_map_ce(wks,A,res)   ; plot model data
  else
    plot(0) = gsn_csm_contour_map_ce(wks,A,res)   ; plot model data
  end if
  delete (res@lbTitleString)
  delete (res@tiMainString)
  delete (res@gsnCenterString)
  if (all(B.ne.-999.)) then
    if (isvar("yrs_ave2")) then
      res@tiMainString = case2+" (yrs "+yrs_ave2+")"
    else  
      res@tiMainString = case2
    end if
    res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean_B)
    res@lbTitleString = "Min = "+sprintf("%6.2f",min2)+ \
                        " Max = "+sprintf("%6.2f",max2)


    plot(1) = gsn_csm_contour_map_ce(wks,B,res)   ; plot model or obs
    delete (res@lbTitleString)
    delete (res@tiMainString)
    delete (res@gsnCenterString)
    delete (min2)
    delete (max2)
  end if
  delete (res@cnLevels)
  delete (res@cnFillPalette)
  delete (res@gsnLeftString)
  delete (min1)
  delete (max1)

;------------------------ DIFFERENCE PLOTS --------------------------
; Global CE plots
  if (all(B.eq.-999.)) then
    gsn_panel(wks,plot,(/1,1/),pan)
    delete(A)
    delete(B)
  else
    mind = min(C)
    maxd = max(C)
    res@cnFillPalette   = cmapd
    res@lbLabelStride = 1
    res@tiMainString = case1+" - "+case2
    res@gsnLeftString = "mean = "+sprintf("%6.2f",gblmean_C)
    res@gsnCenterString = "rmse = "+sprintf("%6.2f",gblrmse)

    res@lbTitleString = "Min = "+sprintf("%6.2f",mind)+ \
                       " Max = "+sprintf("%6.2f",maxd)
    res@cnLevels = dcntrs(i,:) 
    plot(2) = gsn_csm_contour_map_ce(wks,C,res)   ; plot differences 
    delete (res@cnLevels)
    delete (res@tiMainString)
    delete (res@gsnLeftString)
    delete (res@gsnRightString)
    delete (res@gsnCenterString)
    delete (res@cnFillPalette)
    delete (mind)
    delete (maxd)
    delete (C)
    delete (A)
    delete (B)
    gsn_panel(wks,plot,(/3,1/),pan)
  end if

  delete(plot)
  frame(wks)

end do        ; variable 

exit
end
