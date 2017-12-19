; NCL script (MICOM diagnostics package)
; plot_ann_time_series.ncl
; Johan Liakka, Dec 2017
load "$DIAG_CODE/functions_time_series.ncl"

begin

wkdir      = getenv("WKDIR")
compare    = getenv("COMPARE")
infile1    = getenv("INFILE1")
case1      = getenv("CASE1")
fyr1       = getenv("FYR1")

inptr1 = addfile(infile1,"r")
ncases = 1
fyr    = stringtointeger(fyr1)

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
ntimes_tot = ntimes1

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyr2    = getenv("FYR2")
   inptr2  = addfile(infile2,"r")
   ncases  = 2
   voltr2 = get_voltr(inptr2)
   if (all(voltr2.eq.-999.)) then
      print ("voltr not present in case2 input file.")
      delete(voltr2)
      exit()
   end if
   ndim = dimsizes(voltr2)
   ntimes2 = ndim(0)
   ntimes_tot = max((/ntimes1,ntimes2/))
   if (fyr1.ne.fyr2) then
      print("Warning: first yr in case2 time series is different from case1.")
      print("Shifting case2 time axis to that of case1.")
   end if
end if

eyr  = fyr+ntimes_tot-1
pyrs = fspan(fyr,eyr,ntimes_tot)

do i=0, dimsizes(section)-1
   is=tostring(i)
   if (compare.eq."OBS") then
      plotname = "set1_ann_voltr"+is+"_1model"
   else
      plotname = "set1_ann_voltr"+is+"_2models"
   end if
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
   plot = new(1,graphic)                       ; create a plot array
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
   res@trXMinF             = min(pyrs)
   res@trXMaxF             = max(pyrs)
   if (compare.eq."OBS") then
      res@xyLineThicknesses = (/2/)
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)
   else
      res@xyLineThicknesses = (/2,2/)
      res@xyDashPatterns    = (/0,0/)
      res@xyLineColors      = (/"blue","red"/)
   end if

   data = new((/ncases,ntimes_tot/),float)
   data(0,0:ntimes1-1) = voltr1(:,i)
   if (compare .eq. "USER") then
      data(1,0:ntimes2-1) = voltr2(:,i)
   end if
   plot = gsn_csm_xy(wks,pyrs,data,res)

   pan = True
   pan@gsnMaximize = True
   pan@gsnPaperOrientation = "portrait"
   pan@gsnFrame = False
   if (compare.eq."OBS") then
      pan@gsnPanelBottom = 0.0
   else
      pan@gsnPanelBottom = 0.02
   end if
   gsn_panel(wks,(/plot/),(/1,1/),pan)

   ; Draw a text string at the bottom
   txres               = True
   txres@txFontHeightF = 0.02
   txres@txFontColor   = "blue"
   txres@txJust        = "centerright"
   gsn_text_ndc(wks,case1,0.83,0.05,txres)
   if (compare.eq."USER") then
      txres@txFontColor   = "red"
      gsn_text_ndc(wks,case2,0.83,0.01,txres)
   end if
   frame(wks)
   delete (wks)
   delete (data)
end do

exit
end

