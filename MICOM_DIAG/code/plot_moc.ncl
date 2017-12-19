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
rgb_file   = getenv("RGB_FILE")

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

con = new((/nreg1,16/),float)
dcon = new((/nreg1,14/),float)
con(0,:)=(/-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28/)
con(1,:)=(/-40,-35,-30,-25,-20,-15,-10,-5,5,10,15,20,25,30,35,40/)
con(2,:)=(/-40,-35,-30,-25,-20,-15,-10,-5,5,10,15,20,25,30,35,40/)

dcon(0,:)=(/-12,-10,-8,-6,-4,-2,-1,1,2,4,6,8,10,12/)
dcon(1,:)=(/-15,-12,-9,-6,-4,-2,-1,1,2,4,6,9,12,15/)
dcon(2,:)=(/-15,-12,-9,-6,-4,-2,-1,1,2,4,6,9,12,15/)


;**********************************************************************
; common resources for contour plots
;**********************************************************************
res                          = True        
res@gsnDraw                  = False      
res@gsnFrame                 = False
res@trXReverse               = False
res@trYReverse               = True
res@tiYAxisString            = "Depth (m)"
res@tiMainFont = "Helvetica"
res@tiMainFontHeightF = 0.025
res@txFontHeightF            = 0.02
res@cnLevelSelectionMode     = "ExplicitLevels" 
res@cnFillOn                 = True
res@cnLinesOn                = True
res@cnLineLabelsOn           = False
res@cnMissingValFillColor = "Background"
res@lbTitleOn                = True
res@lbLabelFontHeightF       = 0.018
res@lbTitleFontHeightF       = 0.018
res@lbLabelStride            = 1
res@lbOrientation            = "Vertical"
res@gsnYAxisIrregular2Linear = False
res@pmLabelBarWidthF = 0.1
cmap = RGBtoCmap(rgb_file)
;-------------------------------------------
; common resoureces for panel plot 
pan                     = True
pan@gsnMaximize         = True
pan@gsnPaperOrientation = "portrait"
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
      cnplot = new(1,"graphic")
      plotname = "set4_ann_mmflxd"+tostring(i)+"_1model"
   else
      cnplot = new(3,"graphic")
      plotname = "set4_ann_mmflxd"+tostring(i)+"_2models"
   end if

;  -----------------------
;  Make first plot (case1)
;  -----------------------
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname)
   gsn_define_colormap(wks,cmap)      
   res@cnLevels = con(i,:)

   min1 = min(A)
   max1 = max(A)

   res@lbTitleString = "MIN="+sprintf("%6.2f",min1)+ \
                       "~C~MAX="+sprintf("%6.2f",max1)
   res@tiMainString = case1+" (yrs "+yrs_ave1+")"
   res@gsnLeftString = region(i)
   res@gsnRightString = A@units

   cnplot(0) = gsn_csm_contour(wks,A,res)

   delete (res@lbTitleString)
   delete (res@tiMainString)
   delete (res@gsnLeftString)
   delete (res@gsnRightString)
   delete (min1)
   delete (max1)

;  -----------------------
;  Make case 2+difference plots
;  -----------------------
   if (compare.eq."USER") then
      min2 = min(B)
      max2 = max(B)
      res@lbTitleString = "MIN="+sprintf("%6.2f",min2)+ \
                          "~C~MAX="+sprintf("%6.2f",max2)
      res@tiMainString = case2+" (yrs "+yrs_ave2+")"
      res@gsnLeftString = region(i)
      res@gsnRightString = B@units
      cnplot(1) = gsn_csm_contour(wks,B,res)
      delete (res@lbTitleString)
      delete (res@tiMainString)
      delete (res@gsnLeftString)
      delete (res@gsnRightString)
      delete (res@cnLevels)
      delete (min2)
      delete (max2)
      C = A
      C = (/A - B/)
      min3 = min(C)
      max3 = max(C)
      res@cnLevels = dcon(i,:)
      res@lbTitleString = "MIN="+sprintf("%6.2f",min3)+ \
                          "~C~MAX="+sprintf("%6.2f",max3)
      res@tiMainString = case1+"-"+case2
      cnplot(2) = gsn_csm_contour(wks,C,res)
      delete(res@tiMainString)
      delete(res@lbTitleString)
   end if
 
   delete (res@cnLevels)

   if (compare.eq."OBS") then
      gsn_panel(wks,cnplot,(/1,1/),pan)
   else
      gsn_panel(wks,cnplot,(/2,2/),pan)
   end if
   frame (wks)
end do
exit
end
