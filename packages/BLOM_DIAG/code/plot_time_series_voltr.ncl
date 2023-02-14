; NCL script (BLOM diagnostics package)
; plot_ann_time_series.ncl
; Johan Liakka, Dec 2017
; Yanchun He, Dec. 2022
load "$DIAG_CODE/functions_time_series.ncl"

begin

wkdir      = getenv("WKDIR")
compare    = getenv("COMPARE")
infile1    = getenv("INFILE1")
case1      = getenv("CASE1")
fyr1       = stringtointeger(getenv("FYR1"))
ts_offset  = getenv("TS_OFFSET")

inptr1 = addfile(infile1,"r")
ncases = 1

voltr1 = get_voltr(inptr1)
if (all(voltr1.eq.-999.)) then
   print ("voltr not present in case1 input file.")
   delete(voltr1)
   exit()
end if

section = get_section(inptr1)
if (all(section.eq."dummy")) then
   print ("section not present in case1 input file.")
   delete(section)
   exit()
end if

ndim = dimsizes(voltr1)
ntimes1 = ndim(0)
eyr1 = fyr1+ntimes1-1
pyrs1= fspan(fyr1,eyr1,ntimes1)

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyr2    = stringtointeger(getenv("FYR2"))
   inptr2  = addfile(infile2,"r")
   ncases  = 2
   voltr2  = get_voltr(inptr2)
   if (all(voltr2.eq.-999.)) then
      print ("voltr not present in case2 input file.")
      delete(voltr2)
      exit()
   end if
   ndim    = dimsizes(voltr2)
   ntimes2 = ndim(0)
   eyr2    = fyr2+ntimes2-1
   pyrs2   = fspan(fyr2,eyr2,ntimes2)
   ntimes_tot = max((/ntimes1,ntimes2/))

   eyr1_tot   = fyr1+ntimes_tot-1
   eyr2_tot   = fyr2+ntimes_tot-1
   pyrs1_tot  = fspan(fyr1,eyr1_tot,ntimes_tot)
   pyrs2_tot  = fspan(fyr2,eyr2_tot,ntimes_tot)
end if

do i=0, dimsizes(section)-1
   is=tostring(i)
   if (compare.eq."OBS") then
      plotname = "set1_ann_voltr"+is+"_1model"
   else
      plotname = "set1_ann_voltr"+is+"_2models"
   end if
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
   plot = new(ncases,graphic)                        ; create a plot array

   res                     = True
   res@gsnDraw             = False            ; don't draw
   res@gsnFrame            = False            ; don't advance frame
   res@tiYAxisString       = voltr1@long_name+" ["+voltr1@units+"]"
   res@tiXAxisString       = "Years"
   res@tiMainString        = section(i)
   res@tiMainJust          = "CenterLeft"
   res@tiMainPosition      = "Left"
   res@tiXAxisFontHeightF  = 0.02
   res@tiYAxisFontHeightF  = 0.02
   res@tiMainFontHeightF   = 0.02
   res@xyLineThicknesses   = 1
   res@xyDashPatterns      = 0
   res@xyLineColor         = "blue"
   if (compare .eq. "OBS") then
       res@trXMinF         = fyr1
       res@trXMaxF         = eyr1
       plot = gsn_csm_xy(wks,pyrs1,voltr1(:,i),res)
   else
       data = new((/ncases,ntimes_tot/),float)
       data(0,0:ntimes1-1) = voltr1(:,i)
       data(1,0:ntimes2-1) = voltr2(:,i)
       if (ts_offset.eq."0") then
           if (fyr1.ne.fyr2) then
             print("Warning: first yr in case2 time series is different from case1.")
             print("Shifting case2 time axis to that of case1.")
           end if
           res@trXMinF                  = fyr1
           res@trXMaxF                  = eyr1_tot
           res@tmXBMajorLineColor       = "blue"
           res@tmXBMinorLineColor       = "blue"
    ;      res@tmXBMinorOn              = False
           res@tmXBLabelFontColor       = "blue"

           resB = res
           resB@tiXAxisString           = ""
           resB@tiYAxisString           = ""
           resB@trXMinF                 = fyr2
           resB@trXMaxF                 = eyr2_tot
           resB@xyLineColor             = "red"
           resB@tmYRLabelsOn            = False
           resB@tmXTLabelFontColor      = "red"
           resB@tmXTMajorLineColor      = "red"
           resB@tmXTMinorLineColor      = "red"
    ;      resB@tmXBMinorOn             = False

           plot(0) = gsn_csm_x2y2(wks,pyrs1_tot,pyrs2_tot,data(0,:),data(1,:),res,resB)
           delete (data)
       else
           res@trXMinF          = min((/min(fyr1),min(fyr2)/))
           res@trXMaxF          = max((/max(eyr1),max(eyr2)/))
           res@xyLineThicknesses= 1
           res@xyDashPattern    = 0
           res@xyLineColor      = "blue"
;         res@tmXBMinorOn       = False
           plot(0) = gsn_csm_xy(wks,pyrs1,voltr1(:,i),res)
           res@xyLineColor      = "red"
           plot(1) = gsn_csm_xy(wks,pyrs2,voltr2(:,i),res)
           overlay(plot(0),plot(1))
       end if
   end if
   draw(plot(0))

   ; Draw a text string at the bottom
   txres               = True
   txres@txFontHeightF = 0.02
   txres@txFontColor   = "blue"
   txres@txJust        = "centerright"
   gsn_text_ndc(wks,case1,0.83,0.07,txres)
   if (compare.eq."USER") then
      txres@txFontColor = "red"
      gsn_text_ndc(wks,case2,0.83,0.03,txres)
   end if
   frame(wks)
   delete (wks)
end do

exit
end

