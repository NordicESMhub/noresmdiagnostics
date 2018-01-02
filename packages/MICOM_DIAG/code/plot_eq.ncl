; NCL script
; plot_eq.ncl
; Johan Liakka Dec 2017
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
nlon1 = dimsizes(lon1)       ; number of longitude
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
rgb_filed = rgb_dir+"/bluered2.rgb"

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  ptr_woa13t = addfile(infile2+"/WOA13/1deg/woa13_decav_t00_01.nc","r")
  ptr_woa13s = addfile(infile2+"/WOA13/1deg/woa13_decav_s00_01.nc","r")
else
  inptr2   = addfile(infile2,"r")
  case2    = getenv("CASE2")
  fyr2     = getenv("FYR2")
  lyr2     = getenv("LYR2")
  yrs_ave2 = fyr2+"-"+lyr2
  tmp = inptr2->lat            ; Latitudes
  if (typeof(tmp).eq."double") then
    lat2 = dble2flt(tmp)
  else
    lat2 = tmp
  end if
  delete(tmp)
  nlat2 = dimsizes(lat2)       ; number of latitudes
  tmp = inptr2->lon            ; Latitudes
  if (typeof(tmp).eq."double") then
    lon2 = dble2flt(tmp)
  else
    lon2 = tmp
  end if
  delete(tmp)
  nlon2 = dimsizes(lon2)       ; number of latitudes
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
cntrs_templvl=(/-4,-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34/)
dcntrs_templvl=(/-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9/)
cntrs_salnlvl=(/30.4,30.8,31.2,31.6,32,32.4,32.8,33.2,33.6,34,34.4,34.8,35.2,35.6,36,36.4,36.8,37.2,37.6,38/)
dcntrs_salnlvl=(/-1.8,-1.6,-1.4,-1.2,-1,-0.8,-0.6,-0.4,-0.2,0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8/)

; model variables
vars = (/"templvl","salnlvl"/)

; define contour intervals
cntrs = (/cntrs_templvl,cntrs_salnlvl/)

dcntrs = (/dcntrs_templvl,dcntrs_salnlvl/)

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
 cnplot = new(3,"graphic")
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
 cres@trYLog = False
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

  if (vars(i) .eq. "templvl") then
     if (isfilevar(inptr1,"templvl")) then
      tmp = inptr1->templvl
      if (typeof(tmp).eq."double") then
         A = dble2flt(tmp)
      else
         A = tmp
      end if
      A@long_name = "Temperature"
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
      A@long_name = "Salinity"
      A@units = "g/kg"
      assignFillValue(A,A)
    else
      print("no salnlvl variable present in case 1")
      status_exit(1)
    end if
  end if

  A_eq_tot = A(:,:,{-5:5},:)
  delete(A)
  A_eq = dim_avg_n_Wrap(A_eq_tot,2)
  delete(A_eq_tot)

; --------------------------------------------
; Reorder longitudes if necessary (start at 0)
; --------------------------------------------

  if (min(lon1).lt.0.0) then
    A_eq_tmp = lonFlip(A_eq)
    A_eq = A_eq_tmp
    delete(A_eq_tmp)
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
   lon2 = inptr2->lon
   nlon2 = dimsizes(lon2) 
   depth2 = inptr2->depth
   nz2 = dimsizes(depth2)

; get the variables

   if (vars(i) .eq. "templvl") then
     B = inptr2->t_an
     B@long_name = "Temperature"
     B@units = "degC"
     assignFillValue(B,B)
   end if
    
   if (vars(i) .eq. "salnlvl") then
     B = inptr2->s_an
     B@long_name = "Salinity"
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
       B@long_name = "Temperature"
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
       B@long_name = "Salinity"
       B@units = "g/kg"
       assignFillValue(B,B)
     else
       print("no salnlvl variable present in case 2")
       status_exit(1)
     end if
   end if

  end if

  B_eq_tot = B(:,:,{-5:5},:)
  delete(B)
  B_eq = dim_avg_n_Wrap(B_eq_tot,2)
  delete(B_eq_tot)

; --------------------------------------------
; Reorder longitudes if necessary (start at 0)
; --------------------------------------------

  if (min(lon2).lt.0.0) then
    B_eq_tmp = lonFlip(B_eq)
    B_eq = B_eq_tmp
    delete(B_eq_tmp)
  end if

; -------------
; Interpolation
; -------------

  if (nlon1.eq.nlon2 .and. nz1.lt.nz2) then            ; same longitudes, but model less levels than obs
    B_int= linint1_n_Wrap(depth2, B_eq, False, depth1, 0, 1)
    delete(B_eq)
    B_eq = B_int
    delete(B_int)
  end if

  if (nlon1.eq.nlon2 .and. nz1.gt.nz2) then            ; same longitudes, but model more levels than obs
    A_int= linint1_n_Wrap(depth1, A_eq, False, depth2, 0, 1)
    delete(A_eq)
    A_eq = A_int
    delete(A_int)
  end if

  if (nlon1.lt.nlon2 .and. nz1.eq.nz2) then            ; less lons in model, same levels
    B_int= linint1_n_Wrap(lon2, B_eq, True, lon1, 0, 2)
    delete(B_eq)
    B_eq = B_int
    delete(B_int)
  end if

  if (nlon1.lt.nlon2 .and. nz1.lt.nz2) then            ; less lons and levels in model
    tmp_int= linint1_n_Wrap(lon2, B_eq, True, lon1, 0, 2)
    delete(B_eq)
    B_int= linint1_n_Wrap(depth2, tmp_int, False, depth1, 0, 1)
    delete(tmp_int)
    B_eq = B_int
    delete(B_int)
  end if

  if (nlon1.gt.nlon2 .and. nz1.eq.nz2) then            ; more lons in model, same levels
    A_int= linint1_n_Wrap(lon1, A_eq, True, lon2, 0, 2)
    delete(A_eq)
    A_eq = A_int
    delete(A_int)
  end if

  if (nlon1.gt.nlon2 .and. nz1.gt.nz2) then            ; more lons and levels in model
    tmp_int= linint1_n_Wrap(lon1, A_eq, True, lon2, 0, 2)
    delete(A_eq)
    A_int= linint1_n_Wrap(depth1, tmp_int, False, depth2, 0, 1)
    delete(tmp_int)
    A_eq = A_int
    delete(A_int)
  end if

  data1 = A_eq(0,{0:500},:)
  data2 = B_eq(0,{0:500},:)
  delete(A_eq)
  delete(B_eq)
  data3 = data1
  data3 = (/data1 - data2/)



;--------------------- Open files for plots ------------------------------
  if (compare .eq. "OBS") then
    wks = gsn_open_wks("ps",wkdir+"/set6_ann_"+vars(i)+"_1model")
  else
    wks = gsn_open_wks("ps",wkdir+"/set6_ann_"+vars(i)+"_2models") 
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

  cres@cnFillPalette  = cmap
  cres@lbLabelStride  = 2
  if (vars(i).eq."salnlvl") then
    cres@lbLabelStride  = 4
  end if
  cres@lbOrientation = "Horizontal"
  cres@cnLevels = cntrs(i,:)
  cres@trXReverse = False
  cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                     "  MAX = "+sprintf("%6.2f",max1)

  cres@tiMainString = case1+" (yrs "+yrs_ave1+")"
  
  cnplot(0) = gsn_csm_contour(wks,data1,cres)
  delete (cres@lbTitleString)
  delete (cres@tiMainString)

  if (isvar("yrs_ave2")) then
     cres@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else
     cres@tiMainString = case2
  end if
  cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                     "  MAX = "+sprintf("%6.2f",max2)

  cnplot(1) = gsn_csm_contour(wks,data2,cres)
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

  cnplot(2) = gsn_csm_contour(wks,data3,cres)    ; contour plot
  delete (cres@lbTitleString)
  delete (cres@lbOrientation)
  delete (cres@lbLabelStride)
  delete (cres@lbBoxMinorExtentF)
  delete (cres@cnLevels)
  delete (cres@cnFillPalette)

  gsn_panel(wks,cnplot,(/2,2/),pan)         ; panel plot
  frame (wks)

  delete (data1)
  delete (data2)
  delete (data3)
  delete (mind)
  delete (maxd)
end do
exit
end
