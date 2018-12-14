; NCL script
; plot_zonal_mean.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Mar 2018: Update for HAMOCC
;********************************************************
load "$DIAG_CODE/functions_zonal.ncl"
begin

compare    = getenv("COMPARE")
wkdir      = getenv("WKDIR")
infile1    = getenv("INFILE1")     ; case1 climo input filename
fyr1       = getenv("FYR1")
lyr1       = getenv("LYR1")
infile2    = getenv("INFILE2")     ; case2 climo input filename
case1      = getenv("CASE1")
region     = getenv("REGION")
rgb_file   = getenv("RGB_FILE")
rgb_filed  = getenv("RGB_FILE_DIFF")

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
; rgb_file  = rgb_dir+"/blueyellowred2.rgb"
; rgb_file3 = rgb_dir+"/blueyellowred3.rgb"
; rgb_filed = rgb_dir+"/bluered2.rgb"

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  ptr_woa13o  = addfile(infile2+"/WOA13/woa13_all_o00_01_zm_"+region+".nc","r")
  ptr_woa13i  = addfile(infile2+"/WOA13/woa13_all_i00_01_zm_"+region+".nc","r")
  ptr_woa13p  = addfile(infile2+"/WOA13/woa13_all_p00_01_zm_"+region+".nc","r")
  ptr_woa13n  = addfile(infile2+"/WOA13/woa13_all_n00_01_zm_"+region+".nc","r")
  ptr_glodap  = addfile(infile2+"/GLODAPv2/GLODAPv2.2016b.TCO2_reordered_zm_"+region+".nc","r")
  ptr_glodap2 = addfile(infile2+"/GLODAPv2/GLODAPv2.2016b.TAlk_reordered_zm_"+region+".nc","r")
  ptr_d13c    = addfile(infile2+"/EideM-etal_2017/C13_Climatology_zm_"+region+".nc","r")
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
cntrs_o2=(/20,40,60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380,400/)
dcntrs_o2=(/-45,-40,-35,-30,-25,-20,-15,-10,-5,5,10,15,20,25,30,35,40,45/)

cntrs_aou=(/-300,-280,-260,-240,-220,-200,-180,-160,-140,-120,-100,-80,-60,-40,-20,0,20,40,60,80/)
dcntrs_aou=(/-170,-150,-130,-110,-90,-70,-50,-30,-10,10,30,50,70,90,110,130,150,170/)

cntrs_si=(/12.5,25,37.5,50,62.5,75,87.5,100,112.5,125,137.5,150,162.5,175,187.5,200,212.5,225,237.5,250/)
dcntrs_si=(/-27,-24,-21,-18,-15,-12,-9,-6,-3,3,6,9,12,15,18,21,24,27/)

cntrs_po4=(/0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8,2,2.2,2.4,2.6,2.8,3,3.2,3.4,3.6,3.8,4/)
dcntrs_po4=(/-0.85,-0.75,-0.65,-0.55,-0.45,-0.35,-0.25,-0.15,-0.05,0.05,0.15,0.25,0.35,0.45,0.55,0.65,0.75,0.85/)

cntrs_no3=(/2.5,5,7.5,10,12.5,15,17.5,20,22.5,25,27.5,30,32.5,35,37.5,40,42.5,45,47.5,50/)
dcntrs_no3=(/-4.5,-4.0,-3.5,-3.0,-2.5,-2.0,-1.5,-1.0,-0.5,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5/)

cntrs_dissic=(/1.86,1.9,1.94,1.98,2.02,2.06,2.1,2.14,2.18,2.22,2.26,2.3,2.34,2.38,2.42,2.46,2.5,2.54,2.58,2.62/)
dcntrs_dissic=(/-0.09,-0.08,-0.07,-0.06,-0.05,-0.04,-0.03,-0.02,-0.01,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09/)

cntrs_talklvl=(/2.2,2.22,2.24,2.26,2.28,2.3,2.32,2.34,2.36,2.38,2.4,2.42,2.44,2.46,2.48,2.5,2.52,2.54,2.56,2.58/)
dcntrs_talklvl=(/-0.09,-0.08,-0.07,-0.06,-0.05,-0.04,-0.03,-0.02,-0.01,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09/)

cntrs_d13clvl=(/0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0/)
dcntrs_d13clvl=(/-0.85,-0.75,-0.65,-0.55,-0.45,-0.35,-0.25,-0.15,-0.05,0.05,0.15,0.25,0.35,0.45,0.55,0.65,0.75,0.85/)

; model variables
vars = (/"o2lvl","aoulvl","silvl","po4lvl","no3lvl","dissiclvl","talklvl","delta13clvl"/)

; define contour intervals
cntrs = (/cntrs_o2,cntrs_aou,cntrs_si,cntrs_po4,cntrs_no3,cntrs_dissic,cntrs_talklvl,cntrs_d13clvl/)
dcntrs = (/dcntrs_o2,dcntrs_aou,dcntrs_si,dcntrs_po4,dcntrs_no3,dcntrs_dissic,dcntrs_talklvl,dcntrs_d13clvl/)

nvars = dimsizes(vars)

; model-to-obs comparisons

if (compare .eq. "OBS") then

  woa13o_vars  = (/"o_an"/)
  woa13i_vars  = (/"i_an"/)
  woa13p_vars  = (/"p_an"/)
  woa13n_vars  = (/"n_an"/)
  glodap_vars  = (/"TCO2"/)
  glodap_vars2 = (/"TAlk"/)
  d13c_vars    = (/"c13_pi"/)

  ; observations: list of variables to plot
  obsvars = (/"o_an","o_an","i_an","p_an","n_an","TCO2","TAlk","c13_pi"/)
  
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

  if (vars(i).eq."o2lvl") then
    A = get_o2(inptr1)
  end if

  if (vars(i).eq."aoulvl") then
    A = get_aou(inptr1)
  end if

  if (vars(i).eq."silvl") then
    A = get_si(inptr1)
  end if

  if (vars(i).eq."po4lvl") then
    A = get_po4(inptr1)
  end if

  if (vars(i).eq."no3lvl") then
    A = get_no3(inptr1)
  end if

  if (vars(i).eq."dissiclvl") then
    A = get_dissic(inptr1)
  end if

  if (vars(i) .eq. "talklvl") then
    A = get_talk (inptr1)
  end if

  if (vars(i) .eq. "delta13clvl") then
    A = get_delta13c (inptr1)
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
   
   if (any(obsvars(i) .eq. woa13o_vars)) then
     inptr2 = ptr_woa13o
     case2 = "WOA13"
   end if

   if (any(obsvars(i) .eq. woa13i_vars)) then
     inptr2 = ptr_woa13i
     case2 = "WOA13"
   end if

   if (any(obsvars(i) .eq. woa13p_vars)) then
     inptr2 = ptr_woa13p
     case2 = "WOA13"
   end if

   if (any(obsvars(i) .eq. woa13n_vars)) then
     inptr2 = ptr_woa13n
     case2 = "WOA13"
   end if

   if (any(obsvars(i) .eq. glodap_vars)) then
     inptr2 = ptr_glodap
     case2 = "GLODAPv2"
   end if

   if (any(obsvars(i) .eq. glodap_vars2)) then
     inptr2 = ptr_glodap2
     case2 = "GLODAPv2"
   end if

   if (any(obsvars(i) .eq. d13c_vars)) then
     inptr2 = ptr_d13c
     case2 = "EideM-etal_2017"
   end if

;  get latitudes and depth
   lat2 = inptr2->lat
   nlat2 = dimsizes(lat2)
   depth2 = inptr2->depth
   nz2 = dimsizes(depth2)

; get the variables

   if (vars(i) .eq. "o2lvl") then
     if (isfilevar(inptr2,"o_an")) then
       B = inptr2->o_an
       B = (/B*44.661/)
       B@long_name = "Oxygen"
       B@units = "mmol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "aoulvl") then
     if (isfilevar(inptr2,"o_an")) then
       B = inptr2->o_an
       B = (/B*44.661/)
       B@long_name = "Oxygen"
       B@units = "mmol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "silvl") then
     if (isfilevar(inptr2,"i_an")) then
       B = inptr2->i_an
       B@long_name = "Silicate"
       B@units = "mmol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "po4lvl") then
     if (isfilevar(inptr2,"p_an")) then
       B = inptr2->p_an
       B@long_name = "Phosphate"
       B@units = "mmol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "no3lvl") then
     if (isfilevar(inptr2,"n_an")) then
       B = inptr2->n_an
       B@long_name = "Nitrate"
       B@units = "mmol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "dissiclvl") then
     if (isfilevar(inptr2,"TCO2")) then
       B = inptr2->TCO2
       B = (/B*0.001025/)
       B@long_name = "DIC"
       B@units = "mol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "talklvl") then
     if (isfilevar(inptr2,"TAlk")) then
       B = inptr2->TAlk
       B = (/B*0.001025/)
       B@long_name = "Alkalinity"
       B@units = "mol m-3"
       assignFillValue(B,B)
     else
       B = -999.
     end if
   end if

   if (vars(i) .eq. "delta13clvl") then
     if (isfilevar(inptr2,"c13_pi")) then
       tmp = inptr2->c13_pi
       B   = tofloat(tmp)
       copy_VarCoords(tmp,B)
;       B = (/B*0.001025/)
       B@long_name = "delta13C"
       B@units = "per mil"
       assignFillValue(B,B)
       delete(tmp)
     else
       B = -999.
     end if
   end if


 ;-------------
 ; Control case (if model to model comparison)
 ;-------------

  else                               ; CASE 2 IS MODEL

    if (vars(i).eq."o2lvl") then
      B = get_o2(inptr2)
    end if

    if (vars(i).eq."aoulvl") then
      B = get_aou(inptr2)
    end if

    if (vars(i).eq."silvl") then
      B = get_si(inptr2)
    end if

    if (vars(i).eq."po4lvl") then
      B = get_po4(inptr2)
    end if

    if (vars(i).eq."no3lvl") then
      B = get_no3(inptr2)
    end if

    if (vars(i).eq."dissiclvl") then
      B = get_dissic(inptr2)
    end if

    if (vars(i) .eq. "talklvl") then
      B = get_talk (inptr2)
    end if

    if (vars(i) .eq. "delta13clvl") then
      B = get_delta13c (inptr2)
    end if

  end if

  if (all(B.eq.-999.)) then
    print (vars(i)+" not present in case2 file.")
    delete(A)
    delete(B)
    continue       ; procede to next variable in do loop
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

;  printVarSummary(A)
;  print(dimsizes(B))
;  print(dimsizes(data2))

  data1 = A(0,:,:,0)
  if ( (vars(i).eq."dissiclvl" .or. vars(i).eq."talklvl" .or. vars(i).eq."delta13clvl") .and. compare.eq."OBS") then
    data2 = B(:,:,0)
  else
;    if (vars(i).eq."talklvl" .and. compare.eq."OBS") then
;      data2 = B(:,:,0)
;    else
;        printVarSummary(B)
      data2 = B(0,:,:,0)
;    end if
  end if
  delete(A)
  delete(B)
  data3 = data1
  data3 = (/data1 - data2/)



;--------------------- Open files for plots ------------------------------
  if (compare .eq. "OBS") then
    wks = gsn_open_wks("ps",wkdir+"/set3_ann_"+vars(i)+"_"+region+"_1model")
  else
    wks = gsn_open_wks("ps",wkdir+"/set3_ann_"+vars(i)+"_"+region+"_2models") 
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
  cres@lbOrientation = "Vertical"
  cres@cnLevels = cntrs(i,:)
  cres@cnFillPalette  = cmap
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
  cres@cnLevels = dcntrs(i,:)
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
