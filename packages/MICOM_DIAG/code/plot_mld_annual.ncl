; NCL script
; plot_mld_annual.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Feb 2017: Update for MICOM
;********************************************************
load "$DIAG_CODE/functions_latlon.ncl"
;********************************************************
begin

compare = getenv("COMPARE")
rgb_dir = getenv("DIAG_RGB")
wkdir   = getenv("WKDIR")
infile1 = getenv("INFILE1")     ; case1 climo input filename
fyr1    = getenv("FYR1")
lyr1    = getenv("LYR1")
infile2 = getenv("INFILE2")     ; case2 climo input filename
case1   = getenv("CASE1")

;print("Computing annual-mean mld from monthly climatologies...")

; Define RGB files
rgb_file  = rgb_dir+"/blueyellowred2.rgb"
rgb_filed = rgb_dir+"/bluered2.rgb"

; CASE 1 Model
inptr1   = addfile(infile1,"r")
lat1     = inptr1->lat
lon1     = inptr1->lon
A        = inptr1->mld(0,:,:)
nlat1    = dimsizes(lat1)
nlon1    = dimsizes(lon1)
yrs_ave1 = fyr1+"-"+lyr1
gw1temp  = latRegWgt(lat1,"double",0)
gw1      = gw1temp
delete(gw1temp)
gw1!0    = "lat"
gw1&lat  = lat1
delete(inptr1)

; CASE 2 MODEL OR OBS
if (compare .eq. "OBS") then
  inptr2 = addfile(infile2,"r")
  case2  = "de Boyer Montegut et al. (2004)"
  lat2   = inptr2->lat
  lon2   = inptr2->lon
  B      = inptr2->mld(0,:,:)
  nlat2  = dimsizes(lat2)
  nlon2  = dimsizes(lon2)
  gw2    = latGauWgt(nlat2,"lat","gaussian weights","none")
else
  case2    = getenv("CASE2")
  fyr2     = getenv("FYR2")
  lyr2     = getenv("LYR2")
  inptr2   = addfile(infile2,"r")
  lat2     = inptr2->lat
  lon2     = inptr2->lon
  B        = inptr2->mld(0,:,:)
  nlat2    = dimsizes(lat2)
  nlon2    = dimsizes(lon2)
  yrs_ave2 = fyr2+"-"+lyr2
  gw2temp  = latRegWgt(lat2,"double",0)
  gw2      = gw2temp
  delete(gw2temp)
  gw2!0 = "lat"
  gw2&lat = lat2
  delete(inptr2)
end if
 
;************************************************
; define variables to plot
;************************************************
; contours definition (global)
cntrs_mld=(/10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200, 250, 300, 400, 500, 750/)
dcntrs_mld=(/-250,-200,-150,-100,-75,-50,-25,-10,-5,5,10,25,50,75,100,150,200,250/)

; define contour intervals
cntrs = (/cntrs_mld/)
dcntrs = (/dcntrs_mld/)

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

A@long_name = "Mixed layer depth"
A@units = "m"
B@long_name = "Mixed layer depth"
B@units = "m"

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

;--------------------- Open files for plots ------------------------------
if (compare .eq. "OBS") then
  wks = gsn_open_wks("ps",wkdir+"/set3_ann_mld_1model")
else
  wks = gsn_open_wks("ps",wkdir+"/set3_ann_mld_2models") 
end if

;------------------------- GLOBAL CE PLOTS ------------------------
min1 = min(A)
max1 = max(A)
min2 = min(B)
max2 = max(B)
res@lbLabelStride = 2
res@cnLevels = cntrs
res@cnFillPalette   = cmap
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

plot(0) = gsn_csm_contour_map_ce(wks,A,res)   ; plot model data
delete (res@lbTitleString)
delete (res@tiMainString)
delete (res@gsnCenterString)
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
delete (res@cnLevels)
delete (res@cnFillPalette)
delete (res@gsnLeftString)
delete (min1)
delete (max1)

;------------------------ DIFFERENCE PLOTS --------------------------
; Global CE plots
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
delete(plot)
  
txres = True
txres@txFontHeightF = 0.022
txres@txFont = "helvetica-bold"
gsn_text_ndc (wks,"ANN",0.76,0.97,txres)

frame(wks)

exit
end
