;----------------------------------------------------------------------
; plot_nino.ncl
;   - Computing the Oceanic Nino Index
;   - Drawing a time series plot
; Johan Liakka, Dec 2017
; based on the NCL templates in:
; https://www.ncl.ucar.edu/Applications/indices.shtml
;---------------------------------------------------------------------------
; NOAA's operational definitions of El NiÃ±o and La NiÃ±a conditions are based
; upon the Oceanic NiÃ±o Index [ONI]. The ONI is defined as the 3-month running
; means of SST anomalies in the NiÃ±o 3.4 region [5N-5S, 120-170W]. The anomalies
; are derived from the 1971-2000 SST climatology.
;
; The NiÃ±o 3.4 anomalies may be thought of as representing the average equatorial
; SSTs across the Pacific from about the dateline to the South American coast.
; To be classified as a full-fledged El NiÃ±o and La NiÃ±a episode the ONI must excee
; d +0.5 [El NiÃ±o] or -0.5 [La NiÃ±a] for at least five consecutive months. 
;---------------------------------------------------------------------------
;                         User input
;---------------------------------------------------------------------------
load "$DIAG_CODE/functions_time_series.ncl"
begin

; Get environmental variables from main script and add file
  wkdir      = getenv("WKDIR")
  compare    = getenv("COMPARE")
  case1      = getenv("CASE1")
  fyrs1      = getenv("FYR_TS1")
  lyrs1      = getenv("LYR_TS1")
  fyr1 = stringtointeger(fyrs1)
  lyr1 = stringtointeger(lyrs1)
  fyrcs1      = getenv("FYR_CLIMO1")
  lyrcs1      = getenv("LYR_CLIMO1")
  fyrc1 = stringtointeger(fyrcs1)
  lyrc1 = stringtointeger(lyrcs1)
  datadir1   = getenv("DATADIR1")

  if (compare.eq."USER") then
    case2    = getenv("CASE2")
    fyrs2    = getenv("FYR_TS2")
    lyrs2    = getenv("LYR_TS2")
    fyr2 = stringtointeger(fyrs2)
    lyr2 = stringtointeger(lyrs2)
    fyrcs2    = getenv("FYR_CLIMO2")
    lyrcs2    = getenv("LYR_CLIMO2")
    fyrc2 = stringtointeger(fyrcs2)
    lyrc2 = stringtointeger(lyrcs2)
    datadir2 = getenv("DATADIR2")
  end if

  nrun = 5             ; length of running average

  vars = (/"sst3","sst34"/)
  nvars = dimsizes(vars)

  do i = 0,nvars-1
    infile1=datadir1+"/"+case1+"_MON_"+fyrs1+"-"+lyrs1+"_"+vars(i)+"_ts.nc"
    inptr1 = addfile(infile1,"r")

    if (vars(i).eq."sst3") then
       sst1=get_sst3(inptr1)
       keyword="NINO3"
       obsstr="Obs = 0.852"
    end if

    if (vars(i).eq."sst34") then
       sst1=get_sst34(inptr1)
       keyword="NINO3.4"
       obsstr="Obs = 0.824"
    end if

    if (all(sst1.eq.-999.)) then
       print("sst variable not found in case1.")
       continue
    end if
    sst1!0 = "time"

;   -------------------
;   Compute climatology
;   -------------------
    nyrsc1 = lyrc1-fyrc1+1
    isc = 12*(fyrc1-fyr1)
    sstClim1 = new(12,float)
    sstClim1(:) = 0.0
    do im = 0,11
       do iy = 1,nyrsc1
          sstClim1(im) = sstClim1(im) + sst1(isc+12*(iy-1)+im)/tofloat(nyrsc1)
       end do
    end do   
    delete(isc)

    if (compare.eq."USER") then
      infile2=datadir2+"/"+case2+"_MON_"+fyrs2+"-"+lyrs2+"_"+vars(i)+"_ts.nc"
      inptr2 = addfile(infile2,"r")

      if (vars(i).eq."sst3") then
         sst2=get_sst3(inptr2)
      end if

      if (vars(i).eq."sst34") then
        sst2=get_sst34(inptr2)
      end if

      if (all(sst2.eq.-999.)) then
        print("sst variable not found in case2.")
        continue
      end if
      sst2!0 = "time"

;     -------------------
;     Compute climatology
;     -------------------
      nyrsc2 = lyrc2-fyrc2+1
      isc = 12*(fyrc2-fyr2)
      sstClim2 = new(12,float)
      sstClim2(:) = 0.0
      do im = 0,11
         do iy = 1,nyrsc2
            sstClim2(im) = sstClim2(im) + sst2(isc+12*(iy-1)+im)/tofloat(nyrsc2)
         end do
      end do   
      delete(isc)

    end if

;   --------------------------------------------
;   Calculate SST anomalies and define time axis
;   --------------------------------------------
    ndim     = dimsizes(sst1)
    ntimes1  = ndim(0)
    nyrs1    = ntimes1/12
    sstAnom1 = sst1
    ic = 0
    do iy = 1,nyrs1
      do im = 0,11
        sstAnom1(ic)=sst1(ic)-sstClim1(im)
        ic = ic + 1
      end do
    end do
    delete(ic)
    sstAnom1@long_name = keyword+" SST anom"
    yrfrac1   = fspan(fyr1,lyr1,ntimes1)
    if (compare.eq."OBS")
      plot      = new(1,"graphic")
      plot_name = "set2_mon_"+vars(i)+"_1model"
    else
      delete(ndim)
      ndim     = dimsizes(sst2)
      ntimes2  = ndim(0)
      nyrs2    = ntimes2/12
      sstAnom2 = sst2
      ic = 0
      do iy = 1,nyrs2
        do im = 0,11
          sstAnom2(ic)=sst2(ic)-sstClim2(im)
          ic = ic + 1
        end do
      end do
      delete(ic)
      sstAnom2@long_name = keyword+" SST anom"
      yrfrac2   = fspan(fyr2,lyr2,ntimes2)
      plot      = new(2,"graphic")
      plot_name = "set2_mon_"+vars(i)+"_2models"
    end if

;   -----------------------------------------
;   Perform a running average defined by nrun
;   -----------------------------------------
    sstAnom1 = runave_n_Wrap (sstAnom1, nrun, 1, 0)
    if (compare.eq."USER") then
      sstAnom2 = runave_n_Wrap (sstAnom2, nrun, 1, 0)
    end if

;   -----------------
;   Calculate Std dev
;   -----------------
    sstAnom1sd = sqrt(variance(sstAnom1))
    if (compare.eq."USER") then
       sstAnom2sd = sqrt(variance(sstAnom2))
    end if

;   ----------
;   Plot graph
;   ----------
    wks = gsn_open_wks("ps",wkdir+"/"+plot_name)

    res                  = True
    res@gsnDraw          = False            ; don't draw
    res@gsnFrame         = False            ; don't advance frame
    res@gsnYRefLine      = 0.0            ; create a reference line 
    res@gsnAboveYRefLineColor = "red"              ; above ref line fill red
    res@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue
    res@vpHeightF        = 0.4            ; change aspect ratio of plot
    res@vpWidthF         = 0.8            
    res@vpXF             = 0.1            ; start plot at x ndc coord 
    res@trYMinF          = -5.0           ; min value on y-axis
    res@trYMaxF          =  5.0           ; max value on y-axis
    res@tiXAxisString    = "Years"
    res@tiMainFont = "Helvetica"
    res@tiMainFontHeightF   = 0.025
    res@gsnStringFontHeightF = 0.016
    res@tiXAxisFontHeightF = 0.02
    res@tiYAxisFontHeightF = 0.02

    pan                     = True
    pan@gsnMaximize         = True
    pan@gsnPaperOrientation = "portrait"
    pan@gsnFrame            = False

    res@tiMainString   = case1
    res@tiYAxisString  = sstAnom1@long_name+" ["+sstAnom1@units+"]"
    res@gsnLeftString  = "Std dev = "+sprintf("%5.3f",sstAnom1sd)
    res@gsnRightString = obsstr

    plot(0) = gsn_csm_xy (wks,yrfrac1,sstAnom1,res)

    delete(res@tiMainString)
    delete(res@tiYAxisString)
    delete(res@gsnLeftString)
    delete(res@gsnRightString)
    if (compare.eq."USER") then
       res@tiMainString   = case2
       res@tiYAxisString  = sstAnom2@long_name+" ["+sstAnom2@units+"]"
       res@gsnLeftString  = "Std dev = "+sprintf("%5.3f",sstAnom2sd)
       res@gsnRightString = obsstr
       plot(1) = gsn_csm_xy (wks,yrfrac2,sstAnom2,res)
       delete(res@tiMainString)
       delete(res@tiYAxisString)
       delete(res@gsnLeftString)
       delete(res@gsnRightString)
    end if

;   Add text about base years
    txres               = True
    txres@txFontHeightF = 0.016
    txres@txJust        = "BottomRight"
    xpos                = int2flt(lyr1)-nyrs1*0.01
    ypos                = -4.8
    dum1=gsn_add_text(wks,plot(0),"base: "+fyrcs1+"-"+lyrcs1,xpos,ypos,txres)
    if (compare.eq."USER") then
      xpos                = int2flt(lyr2)-nyrs2*0.01
      dum2=gsn_add_text(wks,plot(1),"base: "+fyrcs2+"-"+lyrcs2,xpos,ypos,txres)
    end if

    if (compare.eq."OBS") then
       gsn_panel(wks,plot,(/1,1/),pan)
    else
       gsn_panel(wks,plot,(/2,1/),pan)
    end if
    frame (wks)
    delete(wks)
  end do
exit
end


