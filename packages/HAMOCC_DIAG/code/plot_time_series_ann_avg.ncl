; NCL script (HAMOCC diagnostics package)
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

time    = inptr1->time
ntimes01  = dimsizes(time)
delete(time)

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyr2    = getenv("FYR2")
   inptr2  = addfile(infile2,"r")
   ncases  = 2
end if

vars   = (/"o2","si","po4","no3","dissic"/)
nvars  = dimsizes(vars)

if (compare.eq."OBS") then
  plotname = "set1_ann_avg_1model"
else
  plotname = "set1_ann_avg_2models"
end if
wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
plot = new(nvars,graphic)                        ; create a plot array

res                     = True
res@gsnDraw             = False            ; don't draw
res@gsnFrame            = False            ; don't advance frame
res@tiMainFont          = "Helvetica"
res@tiMainFontHeightF   = 0.03
res@txFontHeightF       = 0.023
res@tiXAxisFontHeightF  = 0.02
res@tiYAxisFontHeightF  = 0.02
res@tiXAxisString       = "Years"

do i = 0, nvars-1

   if (vars(i).eq."o2") then
      A = get_o2 (inptr1)
   end if

   if (vars(i).eq."si") then
      A = get_si (inptr1)
   end if

   if (vars(i).eq."po4") then
      A = get_po4 (inptr1)
   end if
   
   if (vars(i).eq."no3") then
      A = get_no3 (inptr1)
   end if

   if (vars(i).eq."dissic") then
      A = get_dissic (inptr1)
   end if

;   if (vars(i).eq."co2fxd") then
;      A = get_co2fxd (inptr1)
;   end if

;   if (vars(i).eq."co2fxu") then
;      A = get_co2fxu (inptr1)
;   end if

;   if (vars(i).eq."co2fxn") then
;      A = get_co2fxn (inptr1)
;   end if

;   if (vars(i).eq."pp") then
;      A = get_pp (inptr1)
;   end if
   
   if (all(A.eq.-999.)) then
      print (vars(i)+" is not present in case1 input file.")
;      delete(A)
   end if

   ndim = dimsizes(A)
   ntimes1 = ndim(0)
   ntimes_tot = ntimes1

   if (compare.eq."USER") then

      if (vars(i).eq."o2") then
         B = get_o2 (inptr2)
      end if

      if (vars(i).eq."si") then
         B = get_si (inptr2)
      end if

      if (vars(i).eq."po4") then
         B = get_po4 (inptr2)
      end if
   
      if (vars(i).eq."no3") then
         B = get_no3 (inptr2)
      end if

      if (vars(i).eq."dissic") then
         B = get_dissic (inptr2)
      end if

;      if (vars(i).eq."co2fxd") then
;         B = get_co2fxd (inptr2)
;      end if

;      if (vars(i).eq."co2fxu") then
;         B = get_co2fxu (inptr2)
;      end if

      if (vars(i).eq."co2fxn") then
         B = get_co2fxn (inptr2)
      end if

;      if (vars(i).eq."pp") then
;         B = get_pp (inptr2)
;      end if
   
      if (all(B.eq.-999.)) then
         print (vars(i)+" is not present in case2 input file.")
         delete(B)
      end if
      
      ndim = dimsizes(B)
      ntimes2 = ndim(0)
      ntimes_tot = max((/ntimes1,ntimes2/))
      if (fyr1.ne.fyr2) then
         print("Warning: first yr in case2 time series is different from case1.")
         print("Shifting case2 time axis to that of case1.")
      end if
   end if

   if (ntimes_tot .eq. 1) then
       ntimes_tot = max((/ntimes01,2/))
   end if

   eyr  = fyr+ntimes_tot-1
   pyrs = fspan(fyr,eyr,ntimes_tot)

   if (.not. all(A.eq.-999.)) then
       res@tiYAxisString       = A@units
       res@tiMainString        = A@long_name
   else
       res@tiYAxisString       = "(missing)"
       res@tiMainString        = vars(i)+" (missing)"
   end if
   
;  res@tiMainFontHeightF   = 0.02
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
   data(0,0:ntimes1-1) = A
   if (compare .eq. "USER") then
      data(1,0:ntimes2-1) = B
   end if
   plot(i) = gsn_csm_xy(wks,pyrs,data,res)

   delete (data)
   delete (A)
   if (compare .eq. "USER") then
       delete(B)
   end if
end do

pan = True
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
pan@gsnFrame = False
pan@gsnPanelXWhiteSpacePercent = 3
gsn_panel(wks,(/plot/),(/2,3/),pan)

; Draw a text string at the bottom
txres               = True
txres@txFontHeightF = 0.018
txres@txFontColor   = "blue"
txres@txJust        = "centerright"
gsn_text_ndc(wks,case1,0.99,0.14,txres)
if (compare.eq."USER") then
   txres@txFontColor   = "red"
   gsn_text_ndc(wks,case2,0.99,0.1,txres)
end if


frame(wks)
delete (wks)

exit
end

