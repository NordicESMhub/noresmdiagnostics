; NCL script
; plot_meridional_fluxes.ncl
; Johan Liakka, Dec 2017
;**************************************
;load "$DIAG_CODE/functions_moc.ncl"

begin

wkdir      = getenv("WKDIR")
compare    = getenv("COMPARE")
infile1    = getenv("INFILE1")
case1      = getenv("CASE1")
fyr1       = getenv("FYR1")
lyr1       = getenv("LYR1")

inptr1 = addfile(infile1,"r")
yrs_ave1 = fyr1+"-"+lyr1
tmp = inptr1->lat
if (typeof(tmp).eq."double") then
  lat = dble2flt(tmp)
else
  lat = tmp
end if
delete(tmp)
tmp = inptr1->region
region = chartostring(tmp)
delete(tmp)
nlat=dimsizes(lat)
nreg=dimsizes(region)

if (compare.eq."USER") then
   infile2 = getenv("INFILE2")
   case2   = getenv("CASE2")
   fyr2    = getenv("FYR2")
   lyr2    = getenv("LYR2")
   inptr2  = addfile(infile2,"r")
   yrs_ave2 = fyr2+"-"+lyr2
   tmp = inptr2->lat
   if (typeof(tmp).eq."double") then
     lat2 = dble2flt(tmp)
   else
     lat2 = tmp
   end if
   delete(tmp)
   tmp = inptr2->region
   region2 = chartostring(tmp)
   delete(tmp)
   nlat2=dimsizes(lat2)
   nreg2=dimsizes(region2)
   if ( nreg .ne. nreg2 ) then
     print("Number of regions in file 1 is not the same as in file 2")
     status_exit(1)
   end if

   if ( nlat .ne. nlat2 ) then
     print("Number of latitudes in file 1 is not the same as in file 2")
     status_exit(1)
   end if
end if

vars = (/"mhflx","msflx"/)
nvars = dimsizes(vars)

;**********************************************************************
; common resources for contour plots
;**********************************************************************
res                          = True        
res@gsnDraw                  = False      
res@gsnFrame                 = False
res@trXReverse               = False
res@trYReverse               = False
res@tiMainFont               = "Helvetica"
res@tiMainFontHeightF        = 0.025
res@txFontHeightF            = 0.023
res@tiXAxisString            = "Latitude"
res@gsnYRefLine              = 0.0
gsnYRefLineThicknessF        = 0.5
if (compare.eq."OBS") then
  res@xyLineThicknesses = (/2/)
  res@xyDashPatterns    = (/0/)
  res@xyLineColors      = (/"blue"/)
else
  res@xyLineThicknesses = (/2,2/)
  res@xyDashPatterns    = (/0,0/)
  res@xyLineColors      = (/"blue","red"/)
end if

;-------------------------------------------
; common resoureces for panel plot 
pan                     = True
pan@gsnMaximize         = True
pan@gsnPaperOrientation = "portrait"
pan@txFontHeightF       = 0.018
pan@gsnFrame            = False
;***********************************************************


do i = 0,nvars-1

  if (vars(i) .eq. "mhflx") then
    if (isfilevar(inptr1,"mhflx")) then
       tmp = inptr1->mhflx(0,:,:)
       if (typeof(tmp).eq."double") then
          A = dble2flt(tmp)*1.0e-15
       else
          A = tmp*1.0e-15
       end if
       delete(tmp)
       A@long_name = "Northward heat flux"
       A@units = "PW"
     else
       print ("mhflx not present in case1 input file.")
       A = -999.
     end if
  end if

  if (vars(i) .eq. "msflx") then
    if (isfilevar(inptr1,"msflx")) then
       tmp = inptr1->msflx(0,:,:)
       if (typeof(tmp).eq."double") then
          A = dble2flt(tmp)*1.0e-6
       else
          A = tmp*1.0e-6
       end if
       delete(tmp)
       A@long_name = "Northward salinity flux"
       A@units = "Gg s-1"
     else
       print ("msflx not present in case1 input file.")
       A = -999.
     end if
  end if

  if (compare.eq."USER") then
    if (vars(i) .eq. "mhflx") then
      if (isfilevar(inptr2,"mhflx")) then
        tmp = inptr2->mhflx(0,:,:)
        if (typeof(tmp).eq."double") then
          B = dble2flt(tmp)*1.0e-15
        else
          B = tmp*1.0e-15
        end if
        delete(tmp)
        B@long_name = "Northward heat flux"
        B@units = "PW"
      else
        print ("mhflx not present in case2 input file.")
        B = -999.
      end if
    end if

    if (vars(i) .eq. "msflx") then
      if (isfilevar(inptr2,"msflx")) then
        tmp = inptr2->msflx(0,:,:)
        if (typeof(tmp).eq."double") then
          B = dble2flt(tmp)*1.0e-6
        else
          B = tmp*1.0e-6
        end if
        delete(tmp)
        B@long_name = "Northward salinity flux"
        B@units = "Gg s-1"
      else
        print ("msflx not present in case2 input file.")
        B = -999.
      end if
    end if
  end if

  if (compare.eq."OBS") then
    plotname = "set7_ann_"+vars(i)+"_1model"
    ncases = 1
  else
    plotname = "set7_ann_"+vars(i)+"_2models"
    ncases = 2
  end if

; -----------------------
; Make first plots
; -----------------------
  wks  = gsn_open_wks("ps",wkdir+"/"+plotname)
  plot = new(nreg,"graphic")
  data = new((/ncases,nlat/),float)

  res@tiYAxisString = A@long_name+" ["+A@units+"]"

;  if (vars(i).eq."mhflx") then
;    res@trYMinF             = -2.5
;    res@trYMaxF             = 2.5
;  else
;    res@trYMinF             = -75.0
;    res@trYMaxF             = 75.0
;  end if


  ; REGION 1
  res@gsnLeftString = region(0)
  data(0,:) = A(0,:)
  if (compare .eq. "USER") then
    data(1,:) = B(0,:)
  end if
  plot(0) = gsn_csm_xy(wks,lat,data,res)

  ; REGION 2
  res@gsnLeftString = region(1)
  data(0,:) = A(1,:)
  if (compare .eq. "USER") then
    data(1,:) = B(1,:)
  end if
  plot(1) = gsn_csm_xy(wks,lat,data,res)

  ; REGION 3
  res@gsnLeftString = region(2)
  data(0,:) = A(2,:)
  if (compare .eq. "USER") then
    data(1,:) = B(2,:)
  end if
  plot(2) = gsn_csm_xy(wks,lat,data,res)

  ; REGION 4
  res@gsnLeftString = region(3)
  data(0,:) = A(3,:)
  if (compare .eq. "USER") then
    data(1,:) = B(3,:)
  end if
  plot(3) = gsn_csm_xy(wks,lat,data,res)

  gsn_panel(wks,(/plot/),(/2,2/),pan)
  delete(data)
  delete(plot)

  ; Draw a text string at the bottom
  txres               = True
  txres@txFontHeightF = 0.012
  txres@txFontColor   = "blue"
  txres@txJust        = "centerright"
  case1text = case1+" ("+yrs_ave1+")"
  gsn_text_ndc(wks,case1text,0.7,0.03,txres)
  if (compare.eq."USER") then
    case2text = case2+" ("+yrs_ave2+")"
    txres@txFontColor   = "red"
    gsn_text_ndc(wks,case2text,0.7,0.01,txres)
  end if

  frame (wks)
  
end do
exit
end
