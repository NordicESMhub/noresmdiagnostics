; NCL script
; plot_time_series.ncl
; Johan Liakka Nov 2017
; Yanchun He, Dec. 2022
load "$DIAG_CODE/functions_time_series.ncl"

begin

test_input = getenv("TEST_INPUT")
cntl_input = getenv("CNTL_INPUT")
case1      = getenv("CASE1")
compare    = getenv("COMPARE")
wkdir      = getenv("WKDIR")
syr1       = getenv("SYR1")
eyr1       = getenv("EYR1")
fyr1       = stringtointeger(syr1)
syr2       = getenv("SYR2")
eyr2       = getenv("EYR2")
fyr2       = stringtointeger(syr2)
season     = getenv("SEASON")
color_type = getenv("COLORTYPE")
time_stamp = getenv("TIMESTAMP")
version    = getenv("VERSION")
ts_offset  = getenv("TS_OFFSET")

inptr1 = addfile(test_input+"/"+"time_series_"+season+"_yrs"+syr1+"-"+eyr1+".nc","r")

if (compare .eq. "USER") then
   cntl_input = getenv("CNTL_INPUT")
   case2      = getenv("CASE2")
   inptr2     = addfile(cntl_input+"/"+"time_series_"+season+"_yrs"+syr2+"-"+eyr2+".nc","r")
   case       = case1+" and "+case2
   ncases     = 2
else
   case       = case1
   ncases     = 1
end if

fyr    = stringtointeger(syr1)

vars   = (/"Rnet","TREFHT","PRECT","CLDTOT","CLDLOW","CLDMED","CLDHGH","SWCF","LWCF"/)
nvars  = dimsizes(vars)

; Define min and max y range for the annual case
if (season.eq."ANN") then
   y_range_min = (/-3.,282.,2.6,60.,35.,25.,30.,-60.,20./)
   y_range_max = (/3.,292.,3.2,75.,50.,40.,50.,-40.,40./)
end if   

do i = 0, nvars-1

   if (vars(i).eq."Rnet") then
      A = get_Rnet (inptr1)
   end if

   if (vars(i).eq."TREFHT") then
      A = get_TREFHT (inptr1)
   end if

   if (vars(i).eq."PRECT") then
      A = get_PRECT (inptr1)
   end if

   if (vars(i).eq."CLDTOT") then
      A = get_CLDTOT (inptr1)
   end if

   if (vars(i).eq."CLDLOW") then
      A = get_CLDLOW (inptr1)
   end if

   if (vars(i).eq."CLDMED") then
      A = get_CLDMED (inptr1)
   end if

   if (vars(i).eq."CLDHGH") then
      A = get_CLDHGH (inptr1)
   end if

   if (vars(i).eq."SWCF") then
      A = get_SWCFTOA (inptr1)
   end if

   if (vars(i).eq."LWCF") then
      A = get_LWCFTOA (inptr1)
   end if

   if (all(A.eq.-999.)) then
      print (vars(i)+" not present in test case input file.")
      delete(A)
      continue       ; procede to next variable in do loop
   end if

   delete(eyr1)
   ndim = dimsizes(A)
   ntimes1 = ndim(0)
   eyr1 = fyr1+ntimes1-1
   pyrs1= fspan(fyr1,eyr1,ntimes1)

   if (compare .eq. "USER") then
      if (vars(i).eq."Rnet") then
         B = get_Rnet (inptr2)
      end if

      if (vars(i).eq."TREFHT") then
         B = get_TREFHT (inptr2)
      end if

      if (vars(i).eq."PRECT") then
         B = get_PRECT (inptr2)
      end if

      if (vars(i).eq."CLDTOT") then
         B = get_CLDTOT (inptr2)
      end if

      if (vars(i).eq."CLDLOW") then
         B = get_CLDLOW (inptr2)
      end if

      if (vars(i).eq."CLDMED") then
         B = get_CLDMED (inptr2)
      end if

      if (vars(i).eq."CLDHGH") then
         B = get_CLDHGH (inptr2)
      end if

      if (vars(i).eq."SWCF") then
         B = get_SWCFTOA (inptr2)
      end if

      if (vars(i).eq."LWCF") then
         B = get_LWCFTOA (inptr2)
      end if

      if (all(B.eq.-999.)) then
         print (vars(i)+" not present in cntl case input file.")
         delete(B)
         continue       ; procede to next variable in do loop
      end if

      delete(eyr2)
      ndim = dimsizes(B)
      ntimes2 = ndim(0)
      eyr2 = fyr2+ntimes2-1
      pyrs2= fspan(fyr2,eyr2,ntimes2)
      ntimes_tot = max((/ntimes1,ntimes2/))

      eyr1_tot = fyr1+ntimes_tot-1
      eyr2_tot = fyr2+ntimes_tot-1
      pyrs1_tot= fspan(fyr1,eyr1_tot,ntimes_tot)
      pyrs2_tot= fspan(fyr2,eyr2_tot,ntimes_tot)

      data = new((/ncases,ntimes_tot/),float)
      data(0,0:ntimes1-1) = A
      data(1,0:ntimes2-1) = B
   end if

   if (compare .eq. "OBS") then
      if (color_type .eq. "COLOR") then
         plotname = "tset1_"+season+"_"+vars(i)+"_obsc"
      else
         plotname = "tset1_"+season+"_"+vars(i)+"_obs"
      end if
   else
      if (color_type .eq. "COLOR") then
         plotname = "tset1_"+season+"_"+vars(i)+"_c"
      else
         plotname = "tset1_"+season+"_"+vars(i)
      end if
   end if
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
   plot = new(ncases,graphic)                        ; create a plot array

   res                      = True
   res@gsnDraw              = False            ; don't draw
   res@gsnFrame             = False            ; don't advance frame
;  res@pmLegendSide         = "Right"
;  res@pmLegendWidthF       = 0.15
;  res@pmLegendDisplayMode  = "Always"
;  res@lgPerimOn            = False
;  res@lgLabelFontHeightF   = 0.015
   res@trXReverse           = False
;  res@pmLegendHeightF      = 0.12
;  res@xyExplicitLegendLabels   = (/case1/)
   res@xyLineThicknessF     = 2.
;  res@pmLegendParallelPosF = 0.1
   if (color_type .eq. "COLOR") then
      res@xyLineColor       = "blue"
      res@xyDashPattern     = 0
   else
      res@xyMonoLineColor   = True
      res@xyLineColor       = "black"
      res@xyDashPatterns    = 0
   end if
   if (compare .eq."OBS") then
      plot = gsn_csm_xy(wks,pyrs1,A,res)
   else
;      res@pmLegendHeightF        = 0.12
;      res@xyExplicitLegendLabels = (/case1,case2/)
;      res@lgItemOrder  = (/ 1,0 /)
;      res@xyLineThicknesses      = (/2.,2./)
;      res@pmLegendParallelPosF   = 0.1
      res@gsnLeftString                 = case1
      res@gsnLeftStringFontColor        = "blue"
      res@gsnLeftStringFontHeightF      = 0.02
      res@gsnLeftStringOrthogonalPosF   = 0.07
      res@gsnRightString                = case2
      res@gsnRightStringFontColor       = "red"
      res@gsnRightStringFontHeightF     = 0.02
      res@gsnRightStringOrthogonalPosF  = 0.02
      res@tiYAxisString                 = "["+A@units+"]"
      res@tiXAxisString                 = "Years"
      res@tiMainString                  = A@long_name+" ("+season+")"
      res@tiXAxisFontHeightF            = 0.02
      res@tiYAxisFontHeightF            = 0.02
      res@tiMainFontHeightF             = 0.02
      res@txFontHeightF                 = 0.01
      res@gsnYRefLine                   = 0.0
      res@trYMinF                       = min((/min(A),min(B)/))
      res@trYMaxF                       = max((/max(A),max(B)/))
      if (season.eq."ANN") then
         res@trYMaxF                = y_range_max(i)
         res@trYMinF                = y_range_min(i)
      end if
      if (ts_offset.eq."0") then
         if (fyr1.ne.fyr2) then
            print("Warning: first yr in case2 time series is different from case1.")
            print("Shifting case2 time axis to that of case1.")
         end if
         res@trXMinF                    = fyr1
         res@trXMaxF                    = eyr1_tot
         res@tmXBMajorLineColor         = "blue"
         res@tmXBMinorLineColor         = "blue"
         res@tmXBLabelFontColor         = "blue"
         res@pmLegendOrthogonalPosF     = -0.9

         resB = res
         resB@trXMinF                   = fyr2
         resB@trXMaxF                   = eyr2_tot
         resB@xyLineColor               = "red"
         resB@tmYRLabelsOn              = False
         resB@tmXTLabelFontColor        = "red"
         resB@tmXTMajorLineColor        = "red"
         resB@tmXTMinorLineColor        = "red"

         resB@tiYAxisString             = ""
         resB@tiXAxisString             = ""
         resB@gsnLeftString             = ""
         resB@gsnRightString            = ""

         plot(0) = gsn_csm_x2y2(wks,pyrs1_tot,pyrs2_tot,data(0,:),data(1,:),res,resB)
         delete(data)
      else
         res@gsnDraw                    = False
         res@trXMinF                    = min((/min(fyr1),min(fyr2)/))
         res@trXMaxF                    = max((/max(eyr1),max(eyr2)/))
         res@xyDashPatterns             = (/0/)
         res@xyLineColors               = (/"blue"/)
         plot(0) = gsn_csm_xy(wks,pyrs1,A,res)
         res@xyLineColors               = (/"red"/)
         plot(1) = gsn_csm_xy(wks,pyrs2,B,res)
         overlay(plot(0),plot(1))
        if (time_stamp .eq. "True") then
            infoTimeStamp(wks,0.011,"DIAG Version: "+version)
        end if
      end if
      draw(plot(0))
   end if

;   pan = True
;   pan@gsnMaximize = True
;   pan@gsnPaperOrientation = "portrait"
;   pan@gsnFrame = False
;   pan@gsnPanelTop = 0.96
;   if (time_stamp .eq. "True") then
;      pan@gsnPanelBottom = 0.05
;      gsn_panel(wks,(/plot/),(/1,1/),pan)
;      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
;   else
;      gsn_panel(wks,(/plot/),(/1,1/),pan)
;   end if

   ;txres = True
   ;txres@txFontHeightF = 0.025
   ;gsn_text_ndc(wks,title,0.5,0.98,txres)

   frame (wks)
   delete (wks)
;   delete(res@xyExplicitLegendLabels)
;   delete(res@xyLineThicknesses)
;   delete(res@xyDashPatterns)
   ;delete (res@gsnLeftString)
;   if (color_type .eq. "COLOR") then
;      delete (res@xyLineColors)
;   end if
end do

exit
end
