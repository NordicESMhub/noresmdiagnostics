; NCL script
; plot_hovmoeller.ncl
; Johan Liakka, Dec 2017
;**************************************
load "$DIAG_CODE/functions_time_series.ncl"

begin

wkdir      = getenv("WKDIR")
compare    = getenv("COMPARE")
infile1    = getenv("INFILE1")
case1      = getenv("CASE1")
fyrs1      = getenv("FYR1")
rgb_file   = getenv("RGB_FILE")

ncases = 1
inptr1 = addfile(infile1,"r")
fyr1   = stringtointeger(fyrs1)

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyrs2   = getenv("FYR2")
   inptr2  = addfile(infile2,"r")
   ncases  = 2
   fyr2    = stringtointeger(fyrs2)
end if

vars   = (/"templvl","salnlvl"/)
nvars  = dimsizes(vars)

con = new((/2,20/),float)
con(0,:)=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20/)   ; temp
con(1,:)=(/34.25,34.3,34.35,34.4,34.45,34.5,34.55,34.6,34.65,34.7,34.75,34.8,34.85,34.9,34.95,35.0,35.05,35.10,35.15,35.2/) ; saln

;**********************************************************************
; common resources for contour plots
;**********************************************************************
res                          = True        
res@gsnDraw                  = False      
res@gsnFrame                 = False
res@trXReverse               = False
res@trYReverse               = True
res@tiYAxisString            = "Depth (m)"
res@tiXAxisString            = "Years"
res@tiMainFont               = "Helvetica"
res@tiMainFontHeightF        = 0.025
res@txFontHeightF            = 0.02
res@cnLevelSelectionMode     = "ExplicitLevels" 
res@cnFillOn                 = True
res@cnLinesOn                = False
res@cnLineLabelsOn           = False
res@lbTitleOn                = True
res@lbLabelFontHeightF       = 0.018
res@lbTitleFontHeightF       = 0.018
res@lbLabelStride            = 2
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

do i = 0,nvars-1
   if (vars(i) .eq. "templvl") then
      data1 = get_templvl (inptr1)
   end if
   if (vars(i) .eq. "salnlvl") then
      data1 = get_salnlvl (inptr1)
   end if
  
   if (all(data1.eq.-999.)) then
      print (vars(i)+" not present in case1 input file.")
      delete (data1)
      continue
   end if

   ndim = dimsizes(data1)
   ntimes1 = ndim(0)
   eyr1 = fyr1+ntimes1-1
   time_new1 = fspan(fyr1,eyr1,ntimes1)

   if (compare.eq."USER") then
      if (vars(i) .eq. "templvl") then
         data2 = get_templvl (inptr2)
      end if
      if (vars(i) .eq. "salnlvl") then
         data2 = get_salnlvl (inptr2)
      end if
  
      if (all(data2.eq.-999.)) then
         print (vars(i)+" not present in case2 input file.")
	 delete (data1)
         delete (data2)
         continue
      end if

      ndim = dimsizes(data2)
      ntimes2 = ndim(0)
      eyr2 = fyr2+ntimes2-1
      time_new2 = fspan(fyr2,eyr2,ntimes2)
   end if

   if (compare.eq."OBS") then
      cnplot = new(1,"graphic")
      plotname = "set1_ann_"+vars(i)+"_1model"
   else
      cnplot = new(2,"graphic")
      plotname = "set1_ann_"+vars(i)+"_2models"
   end if
   
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname)
   gsn_define_colormap(wks,cmap)      
   res@cnLevels = con(i,:)

   min1 = min(data1)
   max1 = max(data1)

   res@lbTitleString = "MIN="+sprintf("%6.2f",min1)+ \
                       "~C~MAX="+sprintf("%6.2f",max1)
   res@sfXArray := time_new1
   res@tiMainString = case1
   cnplot(0) = gsn_csm_hov(wks,transpose(data1),res)

   delete (res@lbTitleString)
   delete (res@tiMainString)
   delete (res@sfXArray)
   delete (min1)
   delete (max1)
   delete (data1)

   if (compare.eq."USER") then
      min2 = min(data2)
      max2 = max(data2)
      res@lbTitleString = "MIN="+sprintf("%6.2f",min2)+ \
                          "~C~MAX="+sprintf("%6.2f",max2)
      res@sfXArray := time_new2
      res@tiMainString = case2
      cnplot(1) = gsn_csm_hov(wks,transpose(data2),res)
      delete (res@lbTitleString)
      delete (res@tiMainString)
      delete (res@sfXArray)
      delete (min2)
      delete (max2)
      delete (data2)
   end if
   
   delete (res@cnLevels)

   if (compare.eq."OBS") then
      gsn_panel(wks,cnplot,(/1,1/),pan)
   else
      gsn_panel(wks,cnplot,(/2,1/),pan)
   end if
   frame (wks)
end do
exit
end
