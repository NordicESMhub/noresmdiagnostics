; NCL script
; plot_moc.ncl
; Johan Liakka, Dec 2017
;**************************************
;load "$DIAG_CODE/functions_moc.ncl"

begin

wkdir      = getenv("WKDIR")
compare    = getenv("COMPARE")
infile1    = getenv("INFILE1")
case1      = getenv("CASE1")
fyr1       = getenv("FYR1")
lyr1       = getenv("LYR1")
rgb_dir    = getenv("DIAG_RGB")

inptr1 = addfile(infile1,"r")
yrs_ave1 = fyr1+"-"+lyr1
tmp = inptr1->lat
if (typeof(tmp).eq."double") then
  lat1 = dble2flt(tmp)
else
  lat1 = tmp
end if
delete(tmp)
tmp = inptr1->region
region = chartostring(tmp)
delete(tmp)
nlat1=dimsizes(lat1)
nreg1=dimsizes(region)

; Define RGB files
rgb_file  = rgb_dir+"/blueyellowred2.rgb"
rgb_filed = rgb_dir+"/bluered2.rgb"

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyr2    = getenv("FYR2")
   lyr2    = getenv("LYR2")
   inptr2  = addfile(infile2,"r")
   yrs_ave2 = fyr2+"-"+lyr2
   tmp = inptr2->lat
   if (typeof(tmp).eq."double") then
     lat2 = dble2flt(tmp)
   else
     lat2 = tmp
   end if
   delete(tmp)
   tmp = inptr2->region
   region2 = chartostring(tmp)
   delete(tmp)
   nlat2=dimsizes(lat2)
   nreg2=dimsizes(region2)
   if (nlat1.ne.nlat2 .or. nreg1.ne.nreg2) then
      print("number of latitudes or regions are not the same in case1 and case2")
      status_exit(1)
   end if
end if

con = new((/nreg1,20/),float)
dcon = new((/nreg1,18/),float)
con(0,:)=(/-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32/)
con(1,:)=(/-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,5,10,15,20,25,30,35,40,45,50/)
con(2,:)=(/-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,5,10,15,20,25,30,35,40,45,50/)

dcon(0,:)=(/-17,-15,-13,-11,-9,-7,-5,-3,-1,1,3,5,7,9,11,13,15,17/)
dcon(1,:)=(/-17,-15,-13,-11,-9,-7,-5,-3,-1,1,3,5,7,9,11,13,15,17/)
dcon(2,:)=(/-17,-15,-13,-11,-9,-7,-5,-3,-1,1,3,5,7,9,11,13,15,17/)

if (compare.eq."OBS") then
   cnplot = new(2,"graphic")
else
   cnplot = new(6,"graphic")
end if

;**********************************************************************
; common resources for contour plots
;**********************************************************************
cres                          = True        
cres@gsnDraw                  = False      
cres@gsnFrame                 = False
cres@trXReverse               = False
cres@trYReverse               = True
cres@tiYAxisString            = "Depth (m)"
cres@tiMainFont               = "Helvetica"
cres@tiMainFontHeightF        = 0.025
cres@txFontHeightF            = 0.023
cres@cnLevelSelectionMode     = "ExplicitLevels" 
cres@cnFillOn                 = True
cres@cnLinesOn                = True
cres@cnLineLabelsOn           = False
cres@cnMissingValFillColor    = "gray75"
cres@lbTitleOn                = True
cres@lbLabelFontHeightF       = 0.018
cres@lbTitleFontHeightF       = 0.02
cres@lbLabelAutoStride        = False
cres@lbLabelStride            = 1
cres@lbOrientation            = "Vertical"
cres@pmLabelBarWidthF         = 0.05
cres@lbBoxMinorExtentF        = 0.18
cmap  = RGBtoCmap(rgb_file)
cmapd = RGBtoCmap(rgb_filed)
;-------------------------------------------
; common resoureces for panel plot 
pan                     = True
pan@gsnMaximize         = True
pan@gsnPaperOrientation = "portrait"
pan@txFontHeightF       = 0.018
pan@gsnFrame            = False
;***********************************************************

do i = 0,nreg1-1

   if (isfilevar(inptr1,"mmflxd")) then
      tmp = inptr1->mmflxd(0,i,:,:)
      if (typeof(tmp).eq."double") then
         A = dble2flt(tmp)
      else
         A = tmp
      end if
      delete(tmp)
      A = (/A*1.0e-9/)
      A@long_name = "Overturning streamfunction"
      A@units = "Sv"
   else
      print ("mmflxd not present in case1 input file.")
      status_exit(1)
   end if

   if (compare.eq."USER") then
      if (isfilevar(inptr2,"mmflxd")) then
         tmp = inptr2->mmflxd(0,i,:,:)
         if (typeof(tmp).eq."double") then
            B = dble2flt(tmp)
         else
            B = tmp
         end if
         delete(tmp)
         B = (/B*1.0e-9/)
         B@long_name = "Overturning streamfunction"
         B@units = "Sv"
      else
         print ("mmflxd not present in case2 input file.")
         status_exit(1)
      end if
   end if

   if (compare.eq."OBS") then
      plotname = "set4_ann_mmflxd"+tostring(i)+"_1model"
   else
      plotname = "set4_ann_mmflxd"+tostring(i)+"_2models"
   end if

;  -----------------------
;  Make first plot (case1)
;  -----------------------
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname)

   min1 = min(A)
   max1 = max(A)

   cres@cnLevels      = con(i,:)
   cres@cnFillPalette = cmap
   cres@lbTitleString = "MIN="+sprintf("%6.2f",min1)+ \
                       "~C~MAX="+sprintf("%6.2f",max1)
   cres@tiMainString = case1+" (yrs "+yrs_ave1+")"
   cres@gsnLeftString = region(i)
   cres@gsnRightString = "non-lin y "+A@units

   cres@gsnYAxisIrregular2Linear = False
   cnplot(0) = gsn_csm_contour(wks,A,cres)
   delete (cres@gsnYAxisIrregular2Linear)
   cres@gsnYAxisIrregular2Linear = True
   cres@gsnRightString = "linear y "+A@units
   cnplot(1) = gsn_csm_contour(wks,A,cres)
   delete (cres@gsnYAxisIrregular2Linear)

   delete (cres@cnFillPalette)
   delete (cres@lbTitleString)
   delete (cres@tiMainString)
   delete (cres@gsnLeftString)
   delete (cres@gsnRightString)
   delete (cres@cnLevels)
   delete (min1)
   delete (max1)

;  -----------------------
;  Make case 2+difference plots
;  -----------------------
   if (compare.eq."USER") then
      min2 = min(B)
      max2 = max(B)
      cres@cnLevels = con(i,:)
      cres@lbTitleString = "MIN="+sprintf("%6.2f",min2)+ \
                          "~C~MAX="+sprintf("%6.2f",max2)
      cres@tiMainString = case2+" (yrs "+yrs_ave2+")"
      cres@gsnLeftString = region(i)
      cres@gsnRightString = "non-lin y "+B@units
      cres@cnFillPalette  = cmap

      cres@gsnYAxisIrregular2Linear = False
      cnplot(2) = gsn_csm_contour(wks,B,cres)
      delete (cres@gsnYAxisIrregular2Linear)
      cres@gsnYAxisIrregular2Linear = True
      cres@gsnRightString = "linear y "+B@units
      cnplot(3) = gsn_csm_contour(wks,B,cres)
      delete (cres@gsnYAxisIrregular2Linear)

      delete (cres@cnFillPalette)

      delete (cres@lbTitleString)
      delete (cres@tiMainString)
      delete (cres@gsnLeftString)
      delete (cres@gsnRightString)
      delete (cres@cnLevels)
      delete (min2)
      delete (max2)
      C = A
      C = (/A - B/)
      min3 = min(C)
      max3 = max(C)
      cres@cnLevels = dcon(i,:)

      cres@cnFillPalette  = cmapd

      cres@lbTitleString = "MIN="+sprintf("%6.2f",min3)+ \
                          "~C~MAX="+sprintf("%6.2f",max3)
      cres@tiMainString = case1+"-"+case2
      cres@gsnLeftString = region(i)
      cres@gsnRightString = "non-lin y "+C@units

      cres@gsnYAxisIrregular2Linear = False
      cnplot(4) = gsn_csm_contour(wks,C,cres)
      delete (cres@gsnYAxisIrregular2Linear)
      cres@gsnYAxisIrregular2Linear = True
      cres@gsnRightString = "linear y "+C@units
      cnplot(5) = gsn_csm_contour(wks,C,cres)
      delete (cres@gsnYAxisIrregular2Linear)

      delete (cres@tiMainString)
      delete (cres@lbTitleString)
      delete (cres@cnFillPalette)
      delete (cres@gsnLeftString)
      delete (cres@gsnRightString)
      delete (cres@cnLevels)
      delete (min3)
      delete (max3)
      delete (B)
      delete (C)
   end if

   delete(A)

   if (compare.eq."OBS") then
      gsn_panel(wks,cnplot,(/1,2/),pan)
   else
      gsn_panel(wks,cnplot,(/3,2/),pan)
   end if
   frame (wks)
end do
exit
end
