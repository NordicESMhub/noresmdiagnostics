; NCL script
; plot_time_series_vs_obs.ncl
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
   ncases     = 3
else
   case       = case1
   ncases     = 2
end if

if ((season.eq."ANN").or.(season.eq."DJF").or.(season.eq."JJA")) then
   inptr_leg = addfile(test_input+"/LEGATES_"+season+"_gm.nc","r")
   inptr_cld = addfile(test_input+"/CLOUDSAT_"+season+"_gm.nc","r")
   inptr_erb = addfile(test_input+"/ERBE_"+season+"_gm.nc","r")
end if

vars       = (/"TREFHT","PRECT","CLDTOT","CLDLOW","CLDMED","CLDHGH","SWCF","LWCF"/)
obs_source = (/"LEGATES","LEGATES","CLOUDSAT","CLOUDSAT","CLOUDSAT","CLOUDSAT","ERBE","ERBE"/)
legend_ent = (/"Legates & Willmott (1920-80)","Legates & Willmott (1920-80)",\
              "CLOUDSAT (sep2006-dec2010)","CLOUDSAT (sep2006-dec2010)","CLOUDSAT (sep2006-dec2010)","CLOUDSAT (sep2006-dec2010)",\
	      "ERBE (feb1985-apr1989)","ERBE (feb1985-apr1989)"/)
nvars  = dimsizes(vars)

do i = 0, nvars-1

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

   ndim = dimsizes(A)
   ntimes1 = ndim(0)
   ntimes_tot = ntimes1

   if (compare .eq. "USER") then

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

      ndim = dimsizes(B)
      ntimes2 = ndim(0)
      ntimes_tot = max((/ntimes1,ntimes2/))
   end if

   if (vars(i).eq."TREFHT") then
      A_obs = get_TREFHT_obs (inptr_leg,ntimes_tot)
   end if

   if (vars(i).eq."PRECT") then
      A_obs = get_PRECT_obs (inptr_leg,ntimes_tot)
   end if

   if (vars(i).eq."CLDTOT") then
      A_obs = get_CLDTOT_obs (inptr_cld,ntimes_tot)
   end if

   if (vars(i).eq."CLDLOW") then
      A_obs = get_CLDLOW_obs (inptr_cld,ntimes_tot)
   end if

   if (vars(i).eq."CLDMED") then
      A_obs = get_CLDMED_obs (inptr_cld,ntimes_tot)
   end if

   if (vars(i).eq."CLDHGH") then
      A_obs = get_CLDHGH_obs (inptr_cld,ntimes_tot)
   end if

   if (vars(i).eq."SWCF") then
      A_obs = get_SWCFTOA_obs (inptr_erb,ntimes_tot)
   end if

   if (vars(i).eq."LWCF") then
      A_obs = get_LWCFTOA_obs (inptr_erb,ntimes_tot)
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
      res@xyExplicitLegendLabels = (/legend_ent(i),case1/)
      res@lgItemOrder  = (/ 1,0 /)
      res@xyLineThicknesses      = (/2.,2./)
      res@pmLegendParallelPosF   = 0.1
      if (color_type .eq. "COLOR") then
         res@xyLineColors           = (/"black","blue"/)
         res@xyDashPatterns         = (/1,0/)
      else
         res@xyMonoLineColor      = True
         res@xyLineColor          = "black"
         res@xyDashPatterns       = (/1,0/)
      end if
   else
      res@pmLegendHeightF        = 0.12
      res@xyExplicitLegendLabels = (/legend_ent(i),case1,case2/)
      res@lgItemOrder  = (/ 2,1,0 /)
      res@xyLineThicknesses      = (/2.,2.,2./)
      res@pmLegendParallelPosF   = 0.1
      if (color_type .eq. "COLOR") then
         res@xyLineColors           = (/"black","blue","red"/)
         res@xyDashPatterns         = (/1,0,0/)
      else
         res@xyMonoLineColor      = True
         res@xyLineColor          = "black"
         res@xyDashPatterns       = (/1,0,2/)
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

   pyrs = fspan(1,ntimes_tot,ntimes_tot)
   wks = gsn_open_wks("ps",wkdir+"/"+plotname)
   plotO = new(1,"graphic")
   res@pmLegendOrthogonalPosF = 0

   
   data = new((/ncases,ntimes_tot/),float)
   data(0,0:ntimes_tot-1) = (/A_obs/)
   data(1,0:ntimes1-1) = (/A/)
   if (compare .eq. "USER") then
      data(2,0:ntimes2-1) = (/B/)
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
end do

exit
end
