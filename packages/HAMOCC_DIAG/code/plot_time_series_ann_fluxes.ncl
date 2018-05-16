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

if (compare.eq."USER") then
  infile2 = getenv("INFILE2")
  case2   = getenv("CASE2")
  fyr2    = getenv("FYR2")
  inptr2  = addfile(infile2,"r")
  ncases  = 2
end if

vars   = (/"co2fxn","pp","epc100","epcalc100"/)
nvars  = dimsizes(vars)

if (compare.eq."OBS") then
  plotname = "set1_ann_flx_1model"
else
  plotname = "set1_ann_flx_2models"
end if
wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
plot = new(nvars,graphic)                        ; create a plot array

res                     = True
res@gsnDraw             = False            ; don't draw
res@gsnFrame            = False            ; don't advance frame
res@tiMainFont          = "Helvetica"
res@txFontHeightF       = 0.023
res@tiXAxisFontHeightF  = 0.02
res@tiYAxisFontHeightF  = 0.02
res@tiXAxisString       = "Years"

do i = 0, nvars-1

   if (vars(i).eq."co2fxn") then
      A = get_co2fxn (inptr1)
   end if

   if (vars(i).eq."pp") then
      A = get_ppint(inptr1)    ; firstly try ppint
      if (all(A.eq.-999.)) then
        delete(A)
        A = get_pp(inptr1)     ; otherwise try pp_tot
      end if
   end if

   if (vars(i).eq."epc100") then
      A = get_epc(inptr1)
   end if

   if (vars(i).eq."epcalc100") then
      A = get_epcalc(inptr1)
   end if
   
   if (isvar("A") .and. all(A.eq.-999.)) then
      print (vars(i)+" is not present in case1 input file.")
      delete(A)
      continue
   else
      print(vars(i))
      ndim = dimsizes(A)
      ntimes1 = ndim(0)
      ntimes_tot = ntimes1
   end if

   if (compare.eq."USER") then

      if (vars(i).eq."co2fxn") then
         B = get_co2fxn (inptr2)
      end if

      if (vars(i).eq."pp") then
         B = get_pp (inptr2)
      end if

      if (vars(i).eq."epc100") then
         B = get_epc (inptr2)
      end if

      if (vars(i).eq."epcalc100") then
         B = get_epcalc (inptr2)
      end if
   
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

   eyr  = fyr+ntimes_tot-1
   pyrs = fspan(fyr,eyr,ntimes_tot)

   if (isvar("A")) then
       res@tiYAxisString       = A@units
       res@tiMainString        = A@long_name
   end if
   res@tiMainFontHeightF   = 0.025

;   res@tiMainFontHeightF   = 0.02
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
   if (isvar("A")) then
       data(0,0:ntimes1-1) = A
       if (compare .eq. "USER") then
          data(1,0:ntimes2-1) = B
       end if
       plot(i) = gsn_csm_xy(wks,pyrs,data,res)
   end if

   delete (data)
end do

pan = True
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
pan@gsnFrame = False
pan@gsnPanelXWhiteSpacePercent = 3
pan@gsnPanelBottom     = 0.08
gsn_panel(wks,(/plot/),(/2,2/),pan)

; Draw a text string at the bottom
txres               = True
txres@txFontHeightF = 0.018
txres@txFontColor   = "blue"
txres@txJust        = "centerright"
gsn_text_ndc(wks,case1,0.99,0.06,txres)
if (compare.eq."USER") then
   txres@txFontColor   = "red"
   gsn_text_ndc(wks,case2,0.99,0.02,txres)
end if


frame(wks)
delete (wks)

exit
end

