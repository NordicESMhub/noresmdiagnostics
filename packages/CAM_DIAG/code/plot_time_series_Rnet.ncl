; NCL script
; plot_time_series_Rnet.ncl
; Johan Liakka Nov 2017
load "$DIAG_CODE/functions_time_series.ncl"

begin

test_input = getenv("TEST_INPUT")
cntl_input = getenv("CNTL_INPUT")
case1      = getenv("CASE1")
compare    = getenv("COMPARE")
wkdir      = getenv("WKDIR")
syr1       = getenv("SYR1")
eyr1       = getenv("EYR1")
syr2       = getenv("SYR2")
eyr2       = getenv("EYR2")
season     = getenv("SEASON")
color_type = getenv("COLORTYPE")
time_stamp = getenv("TIMESTAMP")
version    = getenv("VERSION")

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

vars = "Rnet"
;y_range_max = 3.
;y_range_min = -3.

A = get_Rnet (inptr1)
ndim = dimsizes(A)
ntimes1 = ndim(0)
ntimes_tot = ntimes1

;y_range_max = max(fabs(A))

if (compare .eq. "USER") then
   B = get_Rnet (inptr2)
   ndim = dimsizes(B)
   ntimes2 = ndim(0)
   ntimes_tot = max((/ntimes1,ntimes2/))

;   y_range_max = max((/fabs(A),fabs(B)/))
end if

if (compare .eq. "OBS") then
   if (color_type .eq. "COLOR") then
      plotname = "tset1_"+season+"_"+vars+"_obsc"
   else
      plotname = "tset1_"+season+"_"+vars+"_obs"
   end if
else
   if (color_type .eq. "COLOR") then
      plotname = "tset1_"+season+"_"+vars+"_c"
   else
      plotname = "tset1_"+season+"_"+vars
   end if
end if

;  plot resources
   res                        = True
   res@gsnFrame               = False
   res@gsnDraw                = False
   res@pmLegendSide           = "Right"
   res@pmLegendWidthF         = 0.15
   res@pmLegendDisplayMode    = "Always"
   res@lgPerimOn              = False
   res@lgLabelFontHeightF     = 0.015
   res@trXReverse             = False
   if (compare .eq."OBS") then
      res@pmLegendHeightF        = 0.12
      res@xyExplicitLegendLabels = (/case1/)
      res@xyLineThicknesses      = (/2/)
      res@pmLegendParallelPosF   = 0.1
      if (color_type .eq. "COLOR") then
         res@xyLineColors           = (/"blue"/)
         res@xyDashPatterns         = (/0/)
      else
         res@xyMonoLineColor      = True
         res@xyLineColor          = "black"
         res@xyDashPatterns       = (/0/)
      end if
   else
      res@pmLegendHeightF        = 0.12
      res@xyExplicitLegendLabels = (/case1,case2/)
      res@lgItemOrder  = (/ 1,0 /)
      res@xyLineThicknesses      = (/2.,2./)
      res@pmLegendParallelPosF   = 0.1
      if (color_type .eq. "COLOR") then
         res@xyLineColors           = (/"blue","red"/)
         res@xyDashPatterns         = (/0,0/)
      else
         res@xyMonoLineColor      = True
         res@xyLineColor          = "black"
         res@xyDashPatterns       = (/0,1/)
      end if
   end if
   res@tiYAxisString          = "["+A@units+"]"
   res@tiXAxisString          = "Years"
   res@tiMainString           = A@long_name+" ("+season+")"
   res@tiXAxisFontHeightF     = 0.02
   res@tiYAxisFontHeightF     = 0.02
   res@tiMainFontHeightF      = 0.02
   res@txFontHeightF          = 0.01
   res@gsnYRefLine            = 0.0
;   if (season.eq."ANN") then
;      res@trYMaxF                = y_range_max
;      res@trYMinF                = y_range_min
;      res@trYMinF                = -y_range_max
;   end if

   pyrs = fspan(1,ntimes_tot,ntimes_tot)
   wks = gsn_open_wks("ps",wkdir+"/"+plotname)
   plotO = new(1,"graphic")
   res@pmLegendOrthogonalPosF = -0.9

   
   data = new((/ncases,ntimes_tot/),float)
   data(0,0:ntimes1-1) = (/A/)
   if (compare .eq. "USER") then
      data(1,0:ntimes2-1) = (/B/)
   end if
   plotO = gsn_csm_xy(wks,pyrs,data,res)

   pan = True
   pan@gsnMaximize = True
   pan@gsnPaperOrientation = "portrait"
   pan@gsnFrame = False
   pan@gsnPanelTop = 0.96
   if (time_stamp .eq. "True") then
      pan@gsnPanelBottom = 0.05
      gsn_panel(wks,(/plotO/),(/1,1/),pan)
      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
   else
      gsn_panel(wks,(/plotO/),(/1,1/),pan)
   end if

   ;txres = True
   ;txres@txFontHeightF = 0.025
   ;gsn_text_ndc(wks,title,0.5,0.98,txres)

   frame (wks)
   delete (wks)
   delete (data)
   delete (pyrs)
   delete(res@xyExplicitLegendLabels)
   delete(res@xyLineThicknesses)
   delete(res@xyDashPatterns)
   ;delete (res@gsnLeftString)
   if (color_type .eq. "COLOR") then
      delete (res@xyLineColors)
   end if

exit
end
