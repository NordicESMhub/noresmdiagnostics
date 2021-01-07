; NCL script (CISM diagnostics package)
; plot_ann_time_series.ncl
; Johan Liakka, Dec 2017
; Yanchun He, Aug 2019
; Heiko Goelzer, Jan 2021
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

vars   = (/"vol","smbga","artmga","topgga","usurfga"/)
nvars  = dimsizes(vars)

do i = 0, nvars-1

   if (vars(i).eq."vol") then
      A = get_vol (inptr1)
   end if

   if (vars(i).eq."smbga") then
      A = get_smbga (inptr1)
   end if
   
   if (vars(i).eq."artmga") then
      A = get_artmga (inptr1)
   end if
   
   if (vars(i).eq."topgga") then
      A = get_topgga (inptr1)
   end if

   if (vars(i).eq."usurfga") then
      A = get_usurfga (inptr1)
   end if

   if (all(A.eq.-999.)) then
      print (vars(i)+" is not present in case1 input file.")
      delete(A)
      continue
   end if

   ndim = dimsizes(A)
   ntimes1 = ndim(0)
   ntimes_tot = ntimes1

   if (compare.eq."USER") then
      if (vars(i).eq."vol") then
         B = get_vol (inptr2)
      end if

      if (vars(i).eq."smbga") then
         B = get_smbga (inptr2)
      end if

      if (vars(i).eq."artmga") then
         B = get_artmga (inptr2)
      end if

      if (vars(i).eq."topgga") then
         B = get_topgga (inptr2)
      end if

      if (vars(i).eq."usurfga") then
         B = get_usurfga (inptr2)
      end if

      if (all(B.eq.-999.)) then
         print (vars(i)+" is not present in case2 input file.")
         delete(B)
         continue
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

   if (compare.eq."OBS") then
      plotname = "set1_ann_"+vars(i)+"_1model"
   else
      plotname = "set1_ann_"+vars(i)+"_2models"
   end if
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
   plot = new(1,graphic)                        ; create a plot array
   res                     = True
   res@gsnDraw             = False            ; don't draw
   res@gsnFrame            = False            ; don't advance frame
   res@tiYAxisString       = A@long_name+" ["+A@units+"]"
   res@tiXAxisString       = "Years"
   if (compare.eq."OBS") then
      res@tiMainString     = case1
      res@tiMainPosition   = "Center"
   else
      res@gsnLeftString = case1
      res@gsnLeftStringFontColor = "blue"
      res@gsnRightString = case2
      res@gsnRightStringFontColor = "red"
   end if

   res@tiXAxisFontHeightF  = 0.02
   res@tiYAxisFontHeightF  = 0.02
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
   data(0,0:ntimes1-1) = A
   if (compare .eq. "USER") then
      data(1,0:ntimes2-1) = (/B/)
   end if
   plot = gsn_csm_xy(wks,pyrs,data,res)

   pan = True
   pan@gsnMaximize = True
   pan@gsnPaperOrientation = "portrait"
   pan@gsnFrame = False
   gsn_panel(wks,(/plot/),(/1,1/),pan)

   frame(wks)
   delete (wks)
   delete (data)
   delete (A)
   if (isvar("B")) then
       delete (B)
   end if
end do

exit
end

