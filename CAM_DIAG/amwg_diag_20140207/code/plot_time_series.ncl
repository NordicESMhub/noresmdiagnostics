; NCL script
; plot_time_series.ncl
; Johan Liakka Nov 2017
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
color_type = getenv("COLORTYPE")
time_stamp = getenv("TIMESTAMP")
version    = getenv("VERSION")

vars = (/"netTOA","TREFHT","CLDTOT","CLDLOW","CLDMED","CLDHGH","SST","SWCF","LWCF"/)

f1 = addfile(test_input+"/"+"time_series_ANN_yrs"+syr1+"-"+eyr1+".nc","r")

if (compare .eq. "USER") then
   cntl_input = getenv("CNTL_INPUT")
   case2      = getenv("CASE2")
   f2 = addfile(cntl_input+"/"+"time_series_ANN_yrs"+syr2+"-"+eyr2+".nc","r")
   case = case1+" and "+case2
   ncases = 2
else
   case = case1
   ncases = 1
end if

fsnt_1 = f1->FSNT
flnt_1 = f1->FLNT

ndim = dimsizes(fsnt_1)
ntimes1 = ndim(0)
ntimes_tot = ntimes1

if (ncases .gt. 1) then
   fsnt_2 = f2->FSNT
   flnt_2 = f2->FLNT

   ndim = dimsizes(fsnt_2)
   ntimes2 = ndim(0)

   ntimes_tot = max((/ntimes1,ntimes2/))
end if

if (compare .eq. "OBS") then
   if (color_type .eq. "COLOR") then
      plotname = "tset1_FSNT-FLNT_obsc"
   else
      plotname = "tset1_FSNT-FLNT_obs"
   end if
else
   if (color_type .eq. "COLOR") then
      plotname = "tset1_FSNT-FLNT_c"
   else
      plotname = "tset1_FSNT-FLNT"
   end if
end if
title = "net TOA raditation flux"

; plot resources
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
  res@pmLegendHeightF        = 0.08
  res@xyExplicitLegendLabels = (/case1/)
  res@xyLineThicknesses      = (/2./)
  res@pmLegendParallelPosF   = 0.95
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"blue"/)
    res@xyDashPatterns         = (/0/)
  else
    res@xyMonoLineColor      = True
    res@xyLineColor          = "black"
    res@xyDashPatterns       = (/0/)
  end if
else
  res@pmLegendHeightF        = 0.10
  res@xyExplicitLegendLabels = (/case1,case2/)
  res@lgItemOrder  = (/ 1,0 /)
  res@xyLineThicknesses      = (/2.,2./)
  res@pmLegendParallelPosF   = 0.9
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"blue","red"/)
    res@xyDashPatterns         = (/0,0/)
  else
    res@xyMonoLineColor      = True
    res@xyLineColor          = "black"
    res@xyDashPatterns       = (/0,1/)
  end if
end if
res@tiYAxisString          = "FSNT-FLNT [W m~S~-2~N~]"
res@tiXAxisString          = "Years"
res@tiMainString           = title
res@tiXAxisFontHeightF     = 0.02
res@tiYAxisFontHeightF     = 0.02
res@tiMainFontHeightF      = 0.02
res@txFontHeightF          = 0.01
res@gsnYRefLine            = 0.0

data = new((/ncases,ntimes_tot/),float)        ; data to plot
pyrs = fspan(1,ntimes_tot,ntimes_tot)

wks = gsn_open_wks("ps",wkdir+"/"+plotname)

plotO = new(1,"graphic")

res@pmLegendOrthogonalPosF = -0.7

data(0,0:ntimes1-1) = (/fsnt_1 - flnt_1/)
if (compare .eq. "USER") then
   data(1,0:ntimes2-1) = (/fsnt_2 - flnt_2/)
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
