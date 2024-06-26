; NCL script
; plot_zonal_mean.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Dec 2017
; Yanchun He Jun 2018
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
region     = getenv("REGION")

woa13_temp_type  = getenv("WOA13_TEMP_TYPE")
if (.not.ismissing(woa13_temp_type) .and. woa13_temp_type .eq. "in-situ") then
  woa13tf="woa13_decav_t00_01_zm_"
  woa13tv="t_an"
  print("info: WOA13 in-situ temperature is used for model-obs comparision")
else
  woa13tf="woa13_decav_potmp00_01_zm_"
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
tmp = inptr1->depth          ; depth
if (typeof(tmp).eq."double") then
  depth1 = dble2flt(tmp)
else
  depth1 = tmp
end if
delete(tmp)
nz1 = dimsizes(depth1)       ; number vertical levels

; Define RGB files
rgb_file  = rgb_dir+"/blueyellowred2.rgb"
rgb_file3 = rgb_dir+"/blueyellowred3.rgb"
rgb_filed = rgb_dir+"/bluered2.rgb"

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  ptr_woa13t = addfile(infile2+"/WOA13/1deg/"+woa13tf+region+".nc","r")
  ptr_woa13s = addfile(infile2+"/WOA13/1deg/woa13_decav_s00_01_zm_"+region+".nc","r")
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
  tmp = inptr2->depth          ; depth
  if (typeof(tmp).eq."double") then
    depth2 = dble2flt(tmp)
  else
    depth2 = tmp
  end if
  delete(tmp)
  nz2 = dimsizes(depth2)       ; number vertical levels
end if
 
;************************************************
; define variables to plot
;************************************************
; contours definition (global)
cntrs_templvl=(/-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/)
dcntrs_templvl=(/-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0.25,0.5,1,1.5,2,2.5,3,3.5,4/)

cntrs_salnlvl=(/30.4,30.8,31.2,31.6,32,32.4,32.8,33.2,33.6,34,34.4,34.8,35.2,35.6,36,36.4,36.8,37.2,37.6,38/)
dcntrs_salnlvl=(/-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9/)

; model variables
vars = (/"templvl","salnlvl"/)

nvars = dimsizes(vars)

; model-to-obs comparisons 

if (compare .eq. "OBS") then

  woa13t_vars = (/"t_an"/)
  woa13s_vars = (/"s_an"/)

  ; observations: list of variables to plot
  obsvars = (/"t_an","s_an"/) 
end if
;-------------------------------------------------------------
; common resources for global contour plots 
 cnplot = new(6,"graphic")
 cres                        = True
 cres@gsnDraw                = False
 cres@gsnFrame               = False
 cres@trXReverse             = False
 cres@tiYAxisString          = "Depth (m)"
 cres@txFontHeightF = 0.023
 cres@cnLevelSelectionMode = "ExplicitLevels"
 cres@cnFillOn             = True
 cres@cnLinesOn            = False
 cres@cnLineLabelsOn       = False
 cres@lbLabelAutoStride = False
 cres@tiMainFont = "Helvetica"
 cres@tiMainFontHeightF = 0.025
 cres@lbTitleOn = True
 cres@lbLabelFontHeightF = 0.018
 cres@lbTitleFontHeightF = 0.02
 cres@cnMissingValFillColor = "gray75"
 cres@trYReverse = True
 cmap  = RGBtoCmap(rgb_file)
 cmap3 = RGBtoCmap(rgb_file3)
 cmapd = RGBtoCmap(rgb_filed)
;-------------------------------------------
; common resoureces for panel plot
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@txFontHeightF = 0.018
 pan@gsnFrame = False
;***********************************************************

do i = 0, nvars-1
  ;print("==================")
  ;print("====="+ vars(i))
;----------------------------
; Test case: CASE 1 MODEL
;----------------------------

  if (vars(i) .eq. "templvl") then
     if (isfilevar(inptr1,"templvl")) then
      tmp = inptr1->templvl
      if (typeof(tmp).eq."double") then
         A = dble2flt(tmp)
      else
         A = tmp
      end if
      A@long_name = "Temp"
      A@units = "degC"
      assignFillValue(A,A)
    else
      print("no templvl variable present in case 1")
      status_exit(1)
    end if
  end if

  if (vars(i) .eq. "salnlvl") then
     if (isfilevar(inptr1,"salnlvl")) then
      tmp = inptr1->salnlvl
      if (typeof(tmp).eq."double") then
         A = dble2flt(tmp)
      else
         A = tmp
      end if
      A@long_name = "Saln"
      A@units = "g/kg"
      assignFillValue(A,A)
    else
      print("no salnlvl variable present in case 1")
      status_exit(1)
    end if
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

;  get latitudes and depth
   lat2 = inptr2->lat
   nlat2 = dimsizes(lat2) 
   depth2 = inptr2->depth
   nz2 = dimsizes(depth2)

; get the variables

   if (vars(i) .eq. "templvl") then
     B = inptr2->$woa13tv$
     B@long_name = "Temp"
     B@units = "degC"
     assignFillValue(B,B)
   end if
    
   if (vars(i) .eq. "salnlvl") then
     B = inptr2->s_an
     B@long_name = "Saln"
     B@units = "g/kg"
     assignFillValue(B,B)
   end if
    
 ;-------------
 ; Control case (if model to model comparison)
 ;-------------

  else                               ; CASE 2 IS MODEL

   if (vars(i) .eq. "templvl") then
     if (isfilevar(inptr2,"templvl")) then
       tmp = inptr2->templvl
       if (typeof(tmp).eq."double") then
          B = dble2flt(tmp)
       else
          B = tmp
       end if
       B@long_name = "Temp"
       B@units = "degC"
       assignFillValue(B,B)
     else
       print("no templvl variable present in case 2")
       status_exit(1)
     end if
    end if

   if (vars(i) .eq. "salnlvl") then
     if (isfilevar(inptr2,"salnlvl")) then
       tmp = inptr2->salnlvl
       if (typeof(tmp).eq."double") then
          B = dble2flt(tmp)
       else
          B = tmp
       end if
       B@long_name = "Saln"
       B@units = "g/kg"
       assignFillValue(B,B)
     else
       print("no salnlvl variable present in case 2")
       status_exit(1)
     end if
   end if

  end if

; -------------
; Interpolation
; -------------

  if (nlat1.eq.nlat2 .and. nz1.lt.nz2) then            ; same latitudes, but model less levels than obs
    B_int= linint1_n_Wrap(depth2, B, False, depth1, 0, 1)
    delete(B)
    B = B_int
    delete(B_int)
  end if

  if (nlat1.eq.nlat2 .and. nz1.gt.nz2) then            ; same latitudes, but model more levels than obs
    A_int= linint1_n_Wrap(depth1, A, False, depth2, 0, 1)
    delete(A)
    A = A_int
    delete(A_int)
  end if

  if (nlat1.lt.nlat2 .and. nz1.eq.nz2) then            ; less lats in model, same levels
    B_int= linint1_n_Wrap(lat2, B, False, lat1, 0, 2)
    delete(B)
    B = B_int
    delete(B_int)
  end if

  if (nlat1.lt.nlat2 .and. nz1.lt.nz2) then            ; less lats and levels in model
    tmp_int= linint1_n_Wrap(lat2, B, False, lat1, 0, 2)
    delete(B)
    B_int= linint1_n_Wrap(depth2, tmp_int, False, depth1, 0, 1)
    delete(tmp_int)
    B = B_int
    delete(B_int)
  end if

  if (nlat1.gt.nlat2 .and. nz1.eq.nz2) then            ; more lats in model, same levels
    A_int= linint1_n_Wrap(lat1, A, False, lat2, 0, 2)
    delete(A)
    A = A_int
    delete(A_int)
  end if

  if (nlat1.gt.nlat2 .and. nz1.gt.nz2) then            ; more lats and levels in model
    tmp_int= linint1_n_Wrap(lat1, A, False, lat2, 0, 2)
    delete(A)
    A_int= linint1_n_Wrap(depth1, tmp_int, False, depth2, 0, 1)
    delete(tmp_int)
    A = A_int
    delete(A_int)
  end if

  data1 = A(0,:,:,0)
  data2 = B(0,:,:,0)
  delete(A)
  delete(B)
  data3 = data1
  data3 = (/data1 - data2/)



;--------------------- Open files for plots ------------------------------
  if (compare .eq. "OBS") then
    wks = gsn_open_wks("ps",wkdir+"/set5_ann_"+vars(i)+"_"+region+"_1model")
  else
    wks = gsn_open_wks("ps",wkdir+"/set5_ann_"+vars(i)+"_"+region+"_2models") 
  end if

  if (compare .eq. "OBS") then
    delete(lat2)
    delete(nlat2)
    delete(depth2)
    delete(nz2)
  end if

  min1 = min(data1)
  max1 = max(data1)
  min2 = min(data2)
  max2 = max(data2)

  if (region .eq. "glb") then
      cres@trXMinF  = -80.
      cres@trXMaxF  = 89.5
  else if (region .eq. "pac") then
      cres@trXMinF  = -40.
      cres@trXMaxF  = 70.
  else if (region .eq. "atl") then
      cres@trXMinF  = -40.
      cres@trXMaxF  = 70.
  else if (region .eq. "ind") then
      cres@trXMinF  = -40.
      cres@trXMaxF  = 30.
  else if (region .eq. "so") then
      cres@trXMinF  = -80.
      cres@trXMaxF  = -30.
  end if
  end if
  end if
  end if
  end if

  cres@lbLabelStride  = 2
  if (vars(i).eq."salnlvl") then
    cres@lbLabelStride  = 2
  end if
  cres@lbOrientation = "Vertical"
  if (vars(i).eq."templvl") then
    cres@cnLevels = cntrs_templvl
    cres@cnFillPalette  = cmap3
  else
    cres@cnLevels = cntrs_salnlvl
    cres@cnFillPalette  = cmap
  end if
  cres@trXReverse = False
  cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       "~C~MAX = "+sprintf("%6.2f",max1)

  cres@tiMainString = case1+" (yrs "+yrs_ave1+")"
  
  cres@gsnYAxisIrregular2Linear = False
  cres@gsnCenterString = "non-lin y"
  cnplot(0) = gsn_csm_contour(wks,data1,cres)
  delete (cres@gsnYAxisIrregular2Linear)
  cres@gsnYAxisIrregular2Linear = True
  cres@gsnCenterString = "linear y"
  cnplot(1) = gsn_csm_contour(wks,data1,cres)
  delete (cres@gsnYAxisIrregular2Linear)
  delete (cres@lbTitleString)
  delete (cres@tiMainString)

  if (isvar("yrs_ave2")) then
     cres@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else
     cres@tiMainString = case2
  end if
  cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       "~C~MAX = "+sprintf("%6.2f",max2)

  cres@gsnYAxisIrregular2Linear = False
  cres@gsnCenterString = "non-lin y"
  cnplot(2) = gsn_csm_contour(wks,data2,cres)
  delete (cres@gsnYAxisIrregular2Linear)
  cres@gsnYAxisIrregular2Linear = True
  cres@gsnCenterString = "linear y"
  cnplot(3) = gsn_csm_contour(wks,data2,cres)
  delete (cres@gsnYAxisIrregular2Linear)
  delete (cres@cnLevels)
  delete (cres@lbLabelStride)
  delete (cres@lbOrientation)
  delete (cres@lbTitleString)
  delete (cres@tiMainString)
  delete (cres@cnFillPalette)
  delete (min1)
  delete (max1)
  delete (min2)
  delete (max2)

; --- Difference plots

  mind = min(data3)
  maxd = max(data3)

  cres@tiMainString = case1+" - "+case2
  cres@lbLabelStride = 1
  cres@lbOrientation = "Vertical"
  cres@lbBoxMinorExtentF = 0.18
  if (vars(i).eq."templvl") then
    cres@cnLevels = dcntrs_templvl
  else
    cres@cnLevels = dcntrs_salnlvl
  end if
  cres@cnFillPalette  = cmapd
  cres@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                       "~C~MAX = "+sprintf("%6.2f",maxd)

  cres@gsnYAxisIrregular2Linear = False
  cres@gsnCenterString = "non-lin y"
  cnplot(4) = gsn_csm_contour(wks,data3,cres)
  delete (cres@gsnYAxisIrregular2Linear)
  cres@gsnYAxisIrregular2Linear = True
  cres@gsnCenterString = "linear y"
  cnplot(5) = gsn_csm_contour(wks,data3,cres)
  delete (cres@gsnYAxisIrregular2Linear)
  delete (cres@lbTitleString)
  delete (cres@lbOrientation)
  delete (cres@lbLabelStride)
  delete (cres@lbBoxMinorExtentF)
  delete (cres@cnLevels)
  delete (cres@cnFillPalette)

  gsn_panel(wks,cnplot,(/3,2/),pan)         ; panel plot

;  txres               = True
;  txres@txFontHeightF = 0.012

;  txres@txFont        = "Helvetica"
;  txres@txJust        = "CenterLeft"
;  gsn_text_ndc(wks,"Non linear y-axis",0.15,0.03,txres)
;  txres@txJust        = "CenterRight"
;  gsn_text_ndc(wks,"Linear y-axis",0.82,0.03,txres) 

  frame (wks)

  delete (data1)
  delete (data2)
  delete (data3)
  delete (mind)
  delete (maxd)
end do
exit
end
