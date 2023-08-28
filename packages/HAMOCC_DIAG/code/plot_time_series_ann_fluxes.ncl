; NCL script (HAMOCC diagnostics package)
; plot_ann_time_series.ncl
; Johan Liakka, Dec 2017
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

if (compare.eq."USER") then
  infile2 = getenv("INFILE2")
  case2   = getenv("CASE2")
  fyr2    = stringtointeger(getenv("FYR2"))
  inptr2  = addfile(infile2,"r")
  ncases  = 2
end if

vars   = (/"co2fxn","pp","epc100","epcalc100","dmsflux"/)
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
res@tiMainFontHeightF   = 0.03
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
        print("use pp_tot instead")
        A = get_pp(inptr1)     ; otherwise try pp_tot
      end if
   end if

   if (vars(i).eq."epc100") then
      A = get_epc(inptr1)
   end if

   if (vars(i).eq."epcalc100") then
      A = get_epcalc(inptr1)
   end if
   
   if (vars(i).eq."dmsflux") then
      A = get_dmsflux(inptr1)
   end if

   if (isvar("A") .and. all(A.eq.-999.)) then
      print (vars(i)+" is not present in case1 input file.")
      delete(A)
      continue
   else
      ndim = dimsizes(A)
      ntimes1 = ndim(0)
      eyr1 = fyr1+ntimes1-1
      pyrs1= fspan(fyr1,eyr1,ntimes1)
   end if

   if (compare.eq."USER") then

      if (vars(i).eq."co2fxn") then
         B = get_co2fxn (inptr2)
      end if

      if (vars(i).eq."pp") then
         B = get_ppint(inptr2)    ; firstly try ppint
         if (all(B.eq.-999.)) then
           delete(B)
           print("use pp_tot instead")
           B = get_pp(inptr2)     ; otherwise try pp_tot
         end if
      end if

      if (vars(i).eq."epc100") then
         B = get_epc (inptr2)
      end if

      if (vars(i).eq."epcalc100") then
         B = get_epcalc (inptr2)
      end if
   
      if (vars(i).eq."dmsflux") then
         B = get_dmsflux (inptr2)
      end if
   
      if (all(B.eq.-999.)) then
         print (vars(i)+" is not present in case2 input file.")
         delete(B)
         continue
      else
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
   end if

   if (.not. all(A.eq.-999.)) then
       res@tiYAxisString       = A@units
       res@tiMainString        = A@long_name
   else
       res@tiYAxisString       = "(missing)"
       res@tiMainString        = vars(i)+" (missing)"
   end if
   res@tiMainFontHeightF   = 0.025
;  res@tiMainFontHeightF   = 0.02
   res@xyLineThicknessF = 1.
   res@xyDashPattern    = 0
   res@xyLineColor      = "blue"
   if (compare.eq."OBS") then
      res@trXMinF           = fyr1
      res@trXMaxF           = eyr1
      plot(i) = gsn_csm_xy(wks,pyrs1,A,res)
   else
      res@trYMinF           = min((/min(A),min(B)/))
      res@trYMaxF           = max((/max(A),max(B)/))
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

         plot(i) = gsn_csm_x2y2(wks,pyrs1_tot,pyrs2_tot,data(0,:),data(1,:),res,resB)
         delete (data)
      else
         plot2=new(1,graphic)
         res@gsnDraw                    = False
         res@trXMinF                    = min((/min(fyr1),min(fyr2)/))
         res@trXMaxF                    = max((/max(eyr1),max(eyr2)/))
         res@xyDashPatterns             = (/0/)
         res@xyLineColors               = (/"blue"/)
         plot(i) = gsn_csm_xy(wks,pyrs1,A,res)
         res@xyLineColors               = (/"red"/)
         plot2   = gsn_csm_xy(wks,pyrs2,B,res)
         overlay(plot(i),plot2  )
      end if
   end if

   delete (A)
   if (isvar("B")) then
       delete (B)
   end if
end do

pan = True
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
pan@gsnFrame = False
pan@gsnPanelXWhiteSpacePercent = 3
pan@gsnPanelBottom     = 0.08
pan@gsnPanelCenter  = False
gsn_panel(wks,(/plot/),(/2,3/),pan)

; Draw a text string at the bottom
txres               = True
txres@txFontHeightF = 0.015
txres@txFontColor   = "blue"
txres@txJust        = "centerright"
gsn_text_ndc(wks,case1,1.,0.3,txres)
if (compare.eq."USER") then
   txres@txFontColor   = "red"
   gsn_text_ndc(wks,case2,1.,0.25,txres)
end if


frame(wks)
delete (wks)

exit
end

