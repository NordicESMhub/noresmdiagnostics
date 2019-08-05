; NCL script
; plot_latlon_monthly.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Dec 2017: Update for MICOM
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
cmonth     = getenv("CMONTH")
ncoutpath1 = getenv("NCOUTPATH1")

if (cmonth.eq."01") then
  smonth="Jan"
end if
if (cmonth.eq."02") then
  smonth="Feb"
end if
if (cmonth.eq."03") then
  smonth="Mar"
end if
if (cmonth.eq."04") then
  smonth="Apr"
end if
if (cmonth.eq."05") then
  smonth="May"
end if
if (cmonth.eq."06") then
  smonth="Jun"
end if
if (cmonth.eq."07") then
  smonth="Jul"
end if
if (cmonth.eq."08") then
  smonth="Aug"
end if
if (cmonth.eq."09") then
  smonth="Sep"
end if
if (cmonth.eq."10") then
  smonth="Oct"
end if
if (cmonth.eq."11") then
  smonth="Nov"
end if
if (cmonth.eq."12") then
  smonth="Dec"
end if

print("Computing mld from density profiles ("+smonth+")...")

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
; Calculate gw
gw1temp = latRegWgt(lat1,"double",0)
gw1 = gw1temp
delete(gw1temp)
gw1!0 = "lat"
gw1&lat = lat1
; time
tmp = inptr1->time
if (typeof(tmp).eq."double") then
  time1 = dble2flt(tmp)
else
  time1 = tmp
end if
delete(tmp)

; Define RGB files
rgb_file  = rgb_dir+"/blueyellowred2.rgb"
rgb_file3 = rgb_dir+"/blueyellowred3.rgb"
rgb_filed = rgb_dir+"/bluered2.rgb"

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  ptr_woce   = addfile(infile2,"r")
else
  inptr2     = addfile(infile2,"r")
  case2      = getenv("CASE2")
  fyr2       = getenv("FYR2")
  lyr2       = getenv("LYR2")
  ncoutpath2 = getenv("NCOUTPATH2")
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
  ; Calculate gw
  gw2temp = latRegWgt(lat2,"double",0)
  gw2 = gw2temp
  delete(gw2temp)
  gw2!0 = "lat"
  gw2&lat = lat2
  ; time
  tmp = inptr2->time
  if (typeof(tmp).eq."double") then
    time2 = dble2flt(tmp)
  else
    time2 = tmp
  end if
  delete(tmp)
end if
 
;************************************************
; define variables to plot
;************************************************
; contours definition (global)
cntrs_mld=(/10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200, 250, 300, 400, 500, 750/)
dcntrs_mld=(/-250,-200,-150,-100,-75,-50,-25,-10,-5,5,10,25,50,75,100,150,200,250/)

; model variables
vars = (/"mld"/)

; define contour intervals
cntrs = (/cntrs_mld/)

dcntrs = (/dcntrs_mld/)

nvars = dimsizes(vars)

; model-to-obs comparisons 

if (compare .eq. "OBS") then

  woce_vars = (/"mld"/)

  ; observations: list of variables to plot
  obsvars = (/"mld"/)
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

  if (vars(i) .eq. "mld") then
    A = get_mld (inptr1)
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

   if (any(obsvars(i) .eq. woce_vars)) then
     inptr2 = ptr_woce
     case2 = "de Boyer Montegut et al. (2004)"
   end if

;   get latitudes,longitudes, and weights
    lat2 = inptr2->lat
    nlat2 = dimsizes(lat2) 
    lon2 = inptr2->lon
    nlon2 = dimsizes(lon2)
    gw2 = latGauWgt(nlat2,"lat","gaussian weights","none") 

; get the variable

    B = -999.
    if (vars(i).eq."mld") then
      delete(B)    
      B = inptr2->mld(0,:,:)
      B@long_name = "Mixed layer depth"
      B@units = "m"
    end if

    if (all(B.eq.-999.)) then
      print (vars(i)+" not present in observations: plotting only model results")
    end if

 ;-------------
 ; Control case (if model to model comparison)
 ;-------------

  else                               ; CASE 2 IS MODEL

    if (vars(i) .eq. "mld") then
      B = get_mld (inptr2)
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

  Anew = new((/1,nlat1,nlon1/),float)
  Anew(0,:,:) = A
  Anew!0 = "time"

; Write out netcdf files of monthly means
  fout  = addfile (ncoutpath1, "c")
  setfileoption(fout,"DefineMode",True)
  fAtt               = True
  fAtt@creation_date = systemfunc ("date")
  fileattdef( fout, fAtt )
  dimNames = (/"time","lat", "lon"/)
  dimSizes = (/1, nlat1,  nlon1/)
  dimUnlim = (/True, False, False/)
  filedimdef(fout,dimNames,dimSizes,dimUnlim)
  filevardef(fout, "time" ,typeof(time1),getvardims(time1))
  filevardef(fout, "lat"  ,typeof(lat1),getvardims(lat1))
  filevardef(fout, "lon"  ,typeof(lon1),getvardims(lon1))
  filevardef(fout, "mld"  ,typeof(Anew)  ,getvardims(Anew))
  filevarattdef(fout,"mld",Anew)
  filevarattdef(fout,"time" ,time1)
  filevarattdef(fout,"lat"  ,lat1)
  filevarattdef(fout,"lon"  ,lon1)
  setfileoption(fout,"DefineMode",False)
  fout->time   = (/time1/)
  fout->lat    = (/lat1/)
  fout->lon    = (/lon1/)
  fout->mld    = (/Anew/)

  if (compare.eq."USER") then
    Bnew = new((/1,nlat2,nlon2/),float)
    Bnew(0,:,:) = B
    Bnew!0 = "time"
    fout  = addfile (ncoutpath2, "c")
    setfileoption(fout,"DefineMode",True)
    fAtt               = True
    fAtt@creation_date = systemfunc ("date")
    fileattdef( fout, fAtt )
    dimNames = (/"time", "lat", "lon"/)
    dimSizes = (/1, nlat2,  nlon2/)
    dimUnlim = (/True, False, False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)
    filevardef(fout, "time" ,typeof(time2),getvardims(time2))
    filevardef(fout, "lat"  ,typeof(lat2),getvardims(lat2))
    filevardef(fout, "lon"  ,typeof(lon2),getvardims(lon2))
    filevardef(fout, "mld"  ,typeof(Bnew)  ,getvardims(Bnew))
    filevarattdef(fout,"mld",Bnew)
    filevarattdef(fout,"time" ,time2)
    filevarattdef(fout,"lat"  ,lat2)
    filevarattdef(fout,"lon"  ,lon2)
    setfileoption(fout,"DefineMode",False)
    fout->time   = (/time2/)
    fout->lat    = (/lat2/)
    fout->lon    = (/lon2/)
    fout->mld    = (/Bnew/)
  end if

;--------------------- Open files for plots ------------------------------
  if (compare .eq. "OBS") then
    wks = gsn_open_wks("ps",wkdir+"/set3_"+cmonth+"_"+vars(i)+"_1model")
  else
    wks = gsn_open_wks("ps",wkdir+"/set3_"+cmonth+"_"+vars(i)+"_2models") 
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
  res@cnLevels      = cntrs
  res@cnFillPalette = cmap
  res@lbTitleString = "Min = "+sprintf("%6.2f",min1)+ \
                     " Max = "+sprintf("%6.2f",max1)

  if (isvar("yrs_ave1")) then
    res@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else  
    res@tiMainString = case1
  end if
  res@gsnLeftString = A@long_name
  res@gsnRightString = A@units
  res@gsnCenterString = "mean = "+sprintf("%6.2f",gblmean_A)
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
    res@gsnCenterString = "mean = "+sprintf("%6.2f",gblmean_B)
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
    res@cnLevels = dcntrs
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

  txres = True
  txres@txFontHeightF = 0.022
  txres@txFont = "helvetica-bold"
  gsn_text_ndc (wks,smonth,0.76,0.97,txres)

  frame(wks)

end do        ; variable 

exit
end
