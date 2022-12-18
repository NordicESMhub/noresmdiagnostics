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
no_align   = getenv("NO_ALIGN")

inptr1 = addfile(infile1,"r")
ncases = 1

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyr2    = stringtointeger(getenv("FYR2"))
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
   eyr1 = fyr1+ntimes1-1
   pyrs1= fspan(fyr1,eyr1,ntimes1)

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
      if (vars(i).eq."mmflxd_maxext") then
         B = get_mmflxd_maxext (inptr2)
      end if

      if (vars(i).eq."mmflxd265ext") then
         B = get_mmflxd265ext (inptr2)
      end if

      if (vars(i).eq."mmflxd45ext") then
         B = get_mmflxd45ext (inptr2)
      end if
      if (vars(i).eq."sst") then
         B = get_sst (inptr2)
      end if

      if (vars(i).eq."sss") then
         B = get_sss (inptr2)
      end if

      if (vars(i).eq."tempga") then
         B = get_tempga (inptr2)
      end if

      if (vars(i).eq."salnga") then
         B = get_salnga (inptr2)
      end if

      if (vars(i).eq."sstga") then
         B = get_sstga (inptr2)
      end if

      if (vars(i).eq."sssga") then
         B = get_sssga (inptr2)
      end if
      if (all(B.eq.-999.)) then
         print (vars(i)+" is not present in case2 input file.")
         delete(B)
         continue
      end if
      
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


   if (compare.eq."OBS") then
      plotname = "set1_ann_"+vars(i)+"_1model"
   else
      plotname = "set1_ann_"+vars(i)+"_2models"
   end if
   wks  = gsn_open_wks("ps",wkdir+"/"+plotname) ; send graphics to PS file
   plot = new(ncases,graphic)                        ; create a plot array

   res                     = True
;   res@gsnDraw            = False            ; don't draw
   res@gsnFrame            = False            ; don't advance frame
   res@tiYAxisString       = A@long_name+" ["+A@units+"]"
   res@tiXAxisString       = "Years"
   res@xyLineColor         = "blue"

   res@tiXAxisFontHeightF  = 0.02
   res@tiYAxisFontHeightF  = 0.02
   res@tiMainFontHeightF   = 0.02
   if (compare.eq."OBS") then
      res@tiMainString     = case1
      res@tiMainPosition   = "Center"
      res@trXMinF          = fyr1
      res@trXMaxF          = eyr1
      plot = gsn_csm_xy(wks,pyrs1,A,res)
   else
      res@gsnLeftString                 = case1
      res@gsnLeftStringFontColor        = "blue"
      res@gsnLeftStringFontHeightF      = 0.02
      res@gsnLeftStringOrthogonalPosF   = 0.07
      res@gsnRightString                = case2
      res@gsnRightStringFontColor       = "red"
      res@gsnRightStringFontHeightF     = 0.02
      res@gsnRightStringOrthogonalPosF  = 0.02
      if (no_align.eq."0") then
         if (fyr1.ne.fyr2) then
            print("Warning: first yr in case2 time series is different from case1.")
            print("Shifting case2 time axis to that of case1.")
         end if
         res@trXMinF                    = fyr1
         res@trXMaxF                    = eyr1_tot
         res@trYMinF                    = min((/min(A),min(B)/))
         res@trYMaxF                    = max((/max(A),max(B)/))

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

         plot(0) = gsn_csm_x2y2(wks,pyrs1_tot,pyrs2_tot,data(0,:),data(1,:),res,resB)
         delete(data)
      else
         res@gsnDraw                    = False
         res@trXMinF                    = min((/min(fyr1),min(fyr2)/))
         res@trXMaxF                    = max((/max(eyr1),max(eyr2)/))
         res@xyDashPatterns             = (/0/)
         res@xyLineColors               = (/"blue"/)
         plot(0) = gsn_csm_xy(wks,pyrs1,A,res)
         res@xyLineColors               = (/"red"/)
         plot(1) = gsn_csm_xy(wks,pyrs2,B,res)
         overlay(plot(0),plot(1))
         draw(plot(0))
      end if
   end if

   frame(wks)
   delete (wks)
   delete (A)
   if (isvar("B")) then
       delete (B)
   end if
end do

exit
end

