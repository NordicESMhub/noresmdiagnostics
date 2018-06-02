; NCL script
; plot_latlon.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Dec 2017: Update for HAMOCC
;********************************************************
load "$DIAG_CODE/functions_latlon.ncl"
;********************************************************
begin

compare    = getenv("COMPARE")
wkdir      = getenv("WKDIR")
infile1    = getenv("INFILE1")     ; case1 climo input filename
fyr1       = getenv("FYR1")
lyr1       = getenv("LYR1")
infile2    = getenv("INFILE2")     ; case2 climo input filename
case1      = getenv("CASE1")
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
; rgb_file  = rgb_dir+"/blueyellowred2.rgb"
; rgb_filed = rgb_dir+"/bluered2.rgb"

; Define depths to plot
depth_plot = (/0.0,100.0,500.0,1000.0,2000.0,3000.0,4000.0/)
nz_plot = dimsizes(depth_plot)

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  ptr_woa13i  = addfile(infile2+"/WOA13/woa13_all_i00_01.nc","r")
  ptr_woa13n  = addfile(infile2+"/WOA13/woa13_all_n00_01.nc","r")
  ptr_woa13o  = addfile(infile2+"/WOA13/woa13_all_o00_01.nc","r")
  ptr_woa13p  = addfile(infile2+"/WOA13/woa13_all_p00_01.nc","r")
  ptr_glodap  = addfile(infile2+"/GLODAPv2/GLODAPv2.2016b.TCO2_reordered.nc","r")
  ptr_glodap2 = addfile(infile2+"/GLODAPv2/GLODAPv2.2016b.TAlk_reordered.nc","r")
  ptr_d13c    = addfile(infile2+"/EideM-etal_2017/C13_Climatology.nc","r")
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
cntrs_o2lvl=(/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500/)
dcntrs_o2lvl=(/-170,-150,-130,-110,-90,-70,-50,-30,-10,10,30,50,70,90,110,130,150,170/)

cntrs_silvl=(/10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200/)
dcntrs_silvl=(/-45,-40,-35,-30,-25,-20,-15,-10,-5,5,10,15,20,25,30,35,40,45/)

cntrs_po4lvl=(/0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0/)
dcntrs_po4lvl=(/-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,-0.05,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8/)

cntrs_no3lvl=(/2.5,5.0,7.5,10.0,12.5,15.0,17.5,20.0,22.5,25.0,27.5,30.0,32.5,35.0,37.5,40.0,42.5,45.0,47.5,50.0/)
dcntrs_no3lvl=(/-17,-15,-13,-11,-9,-7,-5,-3,-1,1,3,5,7,9,11,13,15,17/)

cntrs_dissiclvl=(/1.6,1.65,1.7,1.75,1.8,1.85,1.9,1.95,2,2.05,2.1,2.15,2.2,2.25,2.3,2.35,2.4,2.45,2.5,2.55/)
dcntrs_dissiclvl=(/-0.17,-0.15,-0.13,-0.11,-0.09,-0.07,-0.05,-0.03,-0.01,0.01,0.03,0.05,0.07,0.09,0.11,0.13,0.15,0.17/)

cntrs_talklvl=(/1.8,1.85,1.9,1.95,2,2.05,2.1,2.15,2.2,2.25,2.3,2.35,2.4,2.45,2.5,2.55,2.6,2.65,2.7,2.75/)
dcntrs_talklvl=(/-0.17,-0.15,-0.13,-0.11,-0.09,-0.07,-0.05,-0.03,-0.01,0.01,0.03,0.05,0.07,0.09,0.11,0.13,0.15,0.17/)

cntrs_d13clvl=(/0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0/)
dcntrs_d13clvl=(/-0.85,-0.75,-0.65,-0.55,-0.45,-0.35,-0.25,-0.15,-0.05,0.05,0.15,0.25,0.35,0.45,0.55,0.65,0.75,0.85/)

; model variables
vars = (/"o2lvl","silvl","po4lvl","no3lvl","dissiclvl","talklvl","delta13clvl"/)

; define contour intervals
cntrs = (/cntrs_o2lvl,cntrs_silvl,cntrs_po4lvl,cntrs_no3lvl,cntrs_dissiclvl,cntrs_talklvl,cntrs_d13clvl/)
dcntrs = (/dcntrs_o2lvl,dcntrs_silvl,dcntrs_po4lvl,dcntrs_no3lvl,dcntrs_dissiclvl,dcntrs_talklvl,dcntrs_d13clvl/)

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
  obsvars = (/"o_an","i_an","p_an","n_an","TCO2","TAlk","c13_pi"/)
  
end if
;-------------------------------------------------------------
; common resources for global contour plots 

res = True      
res@mpCenterLonF = 0 
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
;res@cnLevelSelectionMode = "AutomaticLevels"
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnFillOn = True
res@cnLinesOn = False
res@cnMissingValFillColor = "gray75"
res@cnLineLabelsOn = False
cmap  = RGBtoCmap(rgb_file)
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
  do iz = 0, nz_plot-1
  
    if (vars(i) .eq. "o2lvl") then
      A = get_o2 (inptr1,depth1,depth_plot(iz))
    end if

    if (vars(i) .eq. "silvl") then
      A = get_si (inptr1,depth1,depth_plot(iz))
    end if

    if (vars(i) .eq. "po4lvl") then
      A = get_po4 (inptr1,depth1,depth_plot(iz))
    end if

    if (vars(i) .eq. "no3lvl") then
      A = get_no3 (inptr1,depth1,depth_plot(iz))
    end if

    if (vars(i) .eq. "dissiclvl") then
      A = get_dissic (inptr1,depth1,depth_plot(iz))
    end if

    if (vars(i) .eq. "talklvl") then
      A = get_talk (inptr1,depth1,depth_plot(iz))
    end if

    if (vars(i) .eq. "delta13clvl") then
      A = get_delta13c (inptr1,depth1,depth_plot(iz))
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
        case2 = "d13C"
      end if

;     get latitudes,longitudes, and weights
      lat2 = inptr2->lat
      nlat2 = dimsizes(lat2) 
      lon2 = inptr2->lon
      nlon2 = dimsizes(lon2)
      gw2 = latGauWgt(nlat2,"lat","gaussian weights","none") 

;     get the variable

      B = -999.
      if (vars(i) .eq. "o2lvl") then
        delete(B)
        B = inptr2->o_an(0,{depth_plot(iz)},:,:)
        B = (/B*44.661/)
        B@long_name = "Oxygen z"+flt2string(depth_plot(iz))+"m"
        B@units = "mmol m-3"
      end if

      if (vars(i) .eq. "silvl") then
        delete(B)
        B = inptr2->i_an(0,{depth_plot(iz)},:,:)
        B@long_name = "Silicate z"+flt2string(depth_plot(iz))+"m"
        B@units = "mmol m-3"
      end if

      if (vars(i) .eq. "po4lvl") then
        delete(B)
        B = inptr2->p_an(0,{depth_plot(iz)},:,:)
        B@long_name = "Phosphate z"+flt2string(depth_plot(iz))+"m"
        B@units = "mmol m-3"
      end if

      if (vars(i) .eq. "no3lvl") then
        delete(B)
        B = inptr2->n_an(0,{depth_plot(iz)},:,:)
        B@long_name = "Nitrate z"+flt2string(depth_plot(iz))+"m"
        B@units = "mmol m-3"
      end if

      if (vars(i) .eq. "dissiclvl") then
        delete(B)
        B = inptr2->TCO2({depth_plot(iz)},:,:)
        B = (/B*0.001025/)
        B@long_name = "DIC z"+flt2string(depth_plot(iz))+"m"
        B@units = "mol m-3"
      end if

      if (vars(i) .eq. "talklvl") then
        delete(B)
        B = inptr2->TAlk({depth_plot(iz)},:,:)
        B = (/B*0.001025/)
        B@long_name = "Alkalinity z"+flt2string(depth_plot(iz))+"m"
        B@units = "mol m-3"
      end if

      if (vars(i) .eq. "delta13clvl") then
        delete(B)
        tmp = inptr2->c13_pi({depth_plot(iz)},:,:)
        B   = tofloat(tmp)
        copy_VarCoords(tmp,B)
        B@long_name = "delta13C z"+flt2string(depth_plot(iz))+"m"
        B@units = "per mil"
        delete(tmp)
      end if

      if (all(B.eq.-999.)) then
        print (vars(i)+" not present in observations: plotting only model results")
      end if

    ;-------------
    ; Control case (if model to model comparison)
    ;-------------

    else                               ; CASE 2 IS MODEL

      if (vars(i) .eq. "o2lvl") then
        B = get_o2 (inptr2,depth2,depth_plot(iz))
      end if
      
      if (vars(i) .eq. "silvl") then
        B = get_si (inptr2,depth2,depth_plot(iz))
      end if

      if (vars(i) .eq. "po4lvl") then
        B = get_po4 (inptr2,depth2,depth_plot(iz))
      end if

      if (vars(i) .eq. "no3lvl") then
        B = get_no3 (inptr2,depth2,depth_plot(iz))
      end if

      if (vars(i) .eq. "dissiclvl") then
        B = get_dissic (inptr2,depth2,depth_plot(iz))
      end if

      if (vars(i) .eq. "talklvl") then
        B = get_talk (inptr2,depth2,depth_plot(iz))
      end if

      if (vars(i) .eq. "delta13clvl") then
        B = get_delta13c (inptr2,depth2,depth_plot(iz))
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
      wks = gsn_open_wks("ps",wkdir+"/set2_ann_"+vars(i)+"_"+flt2string(depth_plot(iz))+"_1model")
    else
      wks = gsn_open_wks("ps",wkdir+"/set2_ann_"+vars(i)+"_"+flt2string(depth_plot(iz))+"_2models")
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
    res@cnLevels = cntrs(i,:)
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
    res@cnFillPalette   = cmap

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
  end do
end do        ; variable 

exit
end
