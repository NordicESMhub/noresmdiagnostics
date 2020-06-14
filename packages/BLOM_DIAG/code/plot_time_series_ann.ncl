; NCL script (BLOM diagnostics package)
; plot_ann_time_series.ncl
; Johan Liakka, Dec 2017
; Yanchun He, Aug 2019
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

vars   = (/"temp","saln","mmflxd_max","mmflxd265","mmflxd45","mmflxd_maxext","mmflxd265ext","mmflxd45ext","sst","sss","tempga","salnga","sstga","sssga"/)
nvars  = dimsizes(vars)

do i = 0, nvars-1

   if (vars(i).eq."temp") then
      A = get_temp (inptr1)
   end if

   if (vars(i).eq."saln") then
      A = get_saln (inptr1)
   end if

   if (vars(i).eq."mmflxd_max") then
      A = get_mmflxd_max (inptr1)
   end if

   if (vars(i).eq."mmflxd265") then
      A = get_mmflxd265 (inptr1)
   end if

   if (vars(i).eq."mmflxd45") then
      A = get_mmflxd45 (inptr1)
   end if

   if (vars(i).eq."mmflxd_maxext") then
      A = get_mmflxd_maxext (inptr1)
   end if

   if (vars(i).eq."mmflxd265ext") then
      A = get_mmflxd265ext (inptr1)
   end if

   if (vars(i).eq."mmflxd45ext") then
      A = get_mmflxd45ext (inptr1)
   end if

   if (vars(i).eq."sst") then
      A = get_sst (inptr1)
   end if

   if (vars(i).eq."sss") then
      A = get_sss (inptr1)
   end if

   if (vars(i).eq."tempga") then
      A = get_tempga (inptr1)
   end if

   if (vars(i).eq."salnga") then
      A = get_salnga (inptr1)
   end if

   if (vars(i).eq."sstga") then
      A = get_sstga (inptr1)
   end if

   if (vars(i).eq."sssga") then
      A = get_sssga (inptr1)
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
      if (vars(i).eq."temp") then
         B = get_temp (inptr2)
      end if

      if (vars(i).eq."saln") then
         B = get_saln (inptr2)
      end if

      if (vars(i).eq."mmflxd_max") then
         B = get_mmflxd_max (inptr2)
      end if

      if (vars(i).eq."mmflxd265") then
         B = get_mmflxd265 (inptr2)
      end if

      if (vars(i).eq."mmflxd45") then
         B = get_mmflxd45 (inptr2)
      end if
      if (vars(i).eq."sst") then
         B = get_sst (inptr2)
      end if

      if (vars(i).eq."sss") then
         B = get_sss (inptr2)
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

