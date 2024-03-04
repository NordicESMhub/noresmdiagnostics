; NCL script
; plot_hovmoeller2.ncl
; use WOA13 climatology as starting state
; Johan Liakka, Dec 2017
; Yanchun He, Jun 2020
;**************************************
load "$DIAG_CODE/functions_time_series.ncl"

begin

wkdir      = getenv("WKDIR")
compare    = getenv("COMPARE")
infile1    = getenv("INFILE1")
case1      = getenv("CASE1")
fyrs1      = getenv("FYR1")
rgb_dir    = getenv("DIAG_RGB")
obs_dir    = getenv("DIAG_OBS")

woa13_temp_type  = getenv("WOA13_TEMP_TYPE")
if (.not.ismissing(woa13_temp_type) .and. woa13_temp_type .eq. "in-situ") then
  woa13tf="woa13_decav_t00_01_gm.nc"
  woa13tv="t_an"
  print("info: WOA13 in-situ temperature is used for model-obs comparision")
else
  woa13tf="woa13_decav_potmp00_01_gm.nc"
  woa13tv="potmp"
  print("info: WOA13 calculated potential temperature is used for model-obs comparision")
end if

ncases = 1
inptr1 = addfile(infile1,"r")
fyr1   = stringtointeger(fyrs1)
z1 = inptr1->depth
nz1 = dimsizes(z1)

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyrs2   = getenv("FYR2")
   inptr2  = addfile(infile2,"r")
   ncases  = 2
   fyr2    = stringtointeger(fyrs2)
   z2 = inptr2->depth
   nz2 = dimsizes(z2)
end if

vars   = (/"templvl","salnlvl"/)
nvars  = dimsizes(vars)

rgb_file  = rgb_dir+"/bluered2.rgb"

con = new((/2,24/),float)
con(0,:)=(/-2.3,-2.1,-1.9,-1.7,-1.5,-1.3,-1.1,-0.9,-0.7,-0.5,-0.3,-0.1,0.1,0.3,0.5,0.7,0.9,1.1,1.3,1.5,1.7,1.9,2.1,2.3/)   ; temp
con(1,:)=(/-0.36 ,-0.33 ,-0.3 ,-0.27 ,-0.24 ,-0.21 ,-0.18 ,-0.15 ,-0.12 ,-0.09 ,-0.06 ,-0.03 ,0.03 ,0.06 ,0.09 ,0.12 ,0.15 ,0.18 ,0.21 ,0.24 ,0.27 ,0.3 ,0.33 ,0.36/)   ;saln
;print(con)

; Read WOA13 data
inptr_WOAt = addfile(obs_dir+"/WOA13/1deg/"+woa13tf,"r")
inptr_WOAs = addfile(obs_dir+"/WOA13/1deg/woa13_decav_s00_01_gm.nc","r")

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
res@lbLabelAutoStride        = False
res@lbLabelStride            = 1
res@lbOrientation            = "Vertical"
res@pmLabelBarWidthF = 0.1
cmap = RGBtoCmap(rgb_file)
res@cnFillPalette  = cmap
;-------------------------------------------
; common resoureces for panel plot 
pan                     = True
pan@gsnMaximize         = True
pan@gsnPaperOrientation = "portrait"
pan@txFontHeightF       = 0.018
pan@gsnFrame            = False
;***********************************************************

do i = 0,nvars-1

   if (vars(i) .eq. "templvl") then
      A = get_templvl (inptr1)
      xobs=inptr_WOAt->$woa13tv$
      zobs=inptr_WOAt->depth
      nzobs = dimsizes(zobs)
   end if
   if (vars(i) .eq. "salnlvl") then
      A = get_salnlvl (inptr1)
      xobs=inptr_WOAs->s_an
      zobs=inptr_WOAs->depth
      nzobs = dimsizes(zobs)
   end if

   if (all(A.eq.-999.)) then
      print (vars(i)+" not present in case1 input file.")
      delete (A)
      continue
   end if

   ndim = dimsizes(A)
   ntimes1 = ndim(0)
   eyr1 = fyr1+ntimes1-1
   time_new1 = fspan(fyr1,eyr1,ntimes1)

   if (nz1.lt.nzobs) then            ; model less levels than obs
     xobs_int= linint1_n_Wrap(zobs, xobs, False, z1, 0, 1)
     delete(xobs)
     xobs = xobs_int
     delete(xobs_int)
     delete(zobs)
     delete(nzobs)
     zobs = z1
     nzobs = dimsizes(zobs)
   end if

   if (nz1.gt.nzobs) then            ; model more levels than obs
     A_int= linint1_n_Wrap(z1, A, False, zobs, 0, 1)
     delete(A)
     A = A_int
     delete(A_int)
   end if

   data1 = A

;  Subtract starting values
   do it = 0, ntimes1-1
     data1(it,:) = A(it,:)-xobs(0,:)
   end do
   delete(A)

   if (compare.eq."USER") then
      if (vars(i) .eq. "templvl") then
         B = get_templvl (inptr2)
      end if
      if (vars(i) .eq. "salnlvl") then
         B = get_salnlvl (inptr2)
      end if
  
      if (all(B.eq.-999.)) then
         print (vars(i)+" not present in case2 input file.")
         delete (B)
         continue
      end if

      ndim = dimsizes(B)
      ntimes2 = ndim(0)
      eyr2 = fyr2+ntimes2-1
      time_new2 = fspan(fyr2,eyr2,ntimes2)

      if (nz2.lt.nzobs) then            ; model less levels than obs
        xobs_int= linint1_n_Wrap(zobs, xobs, False, z2, 0, 1)
        delete(xobs)
        xobs = xobs_int
        delete(xobs_int)
      end if

      if (nz2.gt.nzobs) then            ; model more levels than obs
        B_int= linint1_n_Wrap(z2, B, False, zobs, 0, 1)
        delete(B)
        B = B_int
        delete(B_int)
      end if

      data2 = B

;     Subtract starting values
      do it = 0, ntimes2-1
         data2(it,:) = B(it,:)-xobs(0,:)
      end do

   end if

   delete(xobs)
   delete(zobs)
   delete(nzobs)

   if (compare.eq."OBS") then
      cnplot = new(2,"graphic")
      plotname = "set1_ann_"+vars(i)+"2_1model"
   else
      cnplot = new(4,"graphic")
      plotname = "set1_ann_"+vars(i)+"2_2models"
   end if
   
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname)
   res@cnLevels = con(i,:)

   min1 = min(data1)
   max1 = max(data1)

   res@lbTitleString = "MIN="+sprintf("%6.2f",min1)+ \
                       "~C~MAX="+sprintf("%6.2f",max1)
   res@sfXArray := time_new1
   res@tiMainString = case1
   res@gsnYAxisIrregular2Linear = False
   res@gsnCenterString = "non-lin y"
   cnplot(0) = gsn_csm_contour(wks,transpose(data1),res)
   delete (res@gsnYAxisIrregular2Linear)
   res@gsnYAxisIrregular2Linear = True
   res@gsnCenterString = "linear y"
   cnplot(1) = gsn_csm_contour(wks,transpose(data1),res)
   delete (res@gsnYAxisIrregular2Linear)

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
      res@gsnYAxisIrregular2Linear = False
      res@gsnCenterString = "non-lin y"
      cnplot(2) = gsn_csm_contour(wks,transpose(data2),res)
      delete (res@gsnYAxisIrregular2Linear)
      res@gsnYAxisIrregular2Linear = True
      res@gsnCenterString = "linear y"
      cnplot(3) = gsn_csm_contour(wks,transpose(data2),res)
      delete (res@gsnYAxisIrregular2Linear)
      delete (res@lbTitleString)
      delete (res@tiMainString)
      delete (res@sfXArray)
      delete (min2)
      delete (max2)
      delete (data2)
   end if
   
   delete (res@cnLevels)

   if (compare.eq."OBS") then
      gsn_panel(wks,cnplot,(/1,2/),pan)
   else
      gsn_panel(wks,cnplot,(/2,2/),pan)
   end if
   frame (wks)
end do
exit
end
