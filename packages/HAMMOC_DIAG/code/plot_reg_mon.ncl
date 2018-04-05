; NCL script
; plot_reg_mon.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Johan Liakka Mar 2018: Update for HAMMOC
;********************************************************
load "$DIAG_CODE/functions_cycle.ncl"
;********************************************************
begin

compare    = getenv("COMPARE")
case1      = getenv("CASE1")
fyr1       = getenv("FYR1")
lyr1       = getenv("LYR1")
fyr_prnt1  = getenv("FYR_PRNT1")
lyr_prnt1  = getenv("LYR_PRNT1")
climodir1  = getenv("CLIMODIR1")
climodir2  = getenv("CLIMODIR2")

wkdir      = getenv("WKDIR")

if (compare.eq."USER") then
  case2      = getenv("CASE2")
  fyr2       = getenv("FYR2")
  lyr2       = getenv("LYR2")
  fyr_prnt2  = getenv("FYR_PRNT1")
  lyr_prnt2  = getenv("LYR_PRNT2")
end if

; model variables
vars = (/"pco2","co2fxn","pp_tot","po4lvl"/)
regions  = (/"ARC","NATL","NPAC","TATL","TPAC","IND","MSO","HSO"/)
reg_long = (/"Arctic","North Atlantic","North Pacific","Tropical Atlantic","Tropical Pacific","Indian ocean","Southern ocean (mid-lat)","Southern ocean (high-lat)"/)

nvars = dimsizes(vars)
nreg  = dimsizes(regions)

; model-to-obs comparisons 
if (compare .eq. "OBS") then

  eth_vars  = (/"spco2","fgco2"/)
  prod_vars = (/"pp"/)
  woa_vars  = (/"p_an"/)

  ; observations: list of variables to plot
  obsvars = (/"spco2","fgco2","pp","p_an"/)
end if

pmth = fspan(1,12,12)

res                     = True
res@gsnDraw             = False            ; don't draw
res@gsnFrame            = False            ; don't advance frame
res@tiMainFont          = "Helvetica"
res@tiMainFontHeightF   = 0.03
res@txFontHeightF       = 0.023
res@tiXAxisFontHeightF  = 0.02
res@tiYAxisFontHeightF  = 0.02
res@tiXAxisString       = "Month"
res@trXMinF             = 1
res@trXMaxF             = 12

;--------------------------------------------------------------
; common resources for panel plots
pan = True
pan@gsnMaximize = True
pan@gsnFrame = False
pan@gsnPaperOrientation = "portrait"
pan@gsnPanelYWhiteSpacePercent = 3
pan@gsnPanelXWhiteSpacePercent = 3

;--------------------------------------------------------------

do i = 0, nvars-1
;----------------------------
; Test case: CASE 1 MODEL
;----------------------------

  plot = new(nreg,"graphic")
  if (compare .eq. "OBS") then
    wks = gsn_open_wks("ps",wkdir+"/set4_"+vars(i)+"_1model")
  else
    wks = gsn_open_wks("ps",wkdir+"/set4_"+vars(i)+"_2models")
  end if

  plot_switch_A = 0
  do ireg = 0, nreg-1

    creg = regions(ireg)
    infile1 = climodir1+"/"+case1+"_MON_"+fyr_prnt1+"-"+lyr_prnt1+"_climo_remap_"+creg+".nc"
    inptr1  = addfile(infile1,"r")
    if (isvar("A")) then
       delete(A)
    end if
    
    if (vars(i) .eq. "pco2") then
      A = get_pco2 (inptr1)
    end if

    if (vars(i) .eq. "co2fxn") then
      A = get_co2fxn (inptr1)
    end if

    if (vars(i) .eq. "pp_tot") then
      A = get_pp (inptr1)
    end if

    if (vars(i) .eq. "po4lvl") then
      A = get_po4 (inptr1,(/0.0,100.0/),0.0)
    end if

    if (all(A.eq.-999.)) then
      print (vars(i)+" not present in case1 input file.")
      plot_switch_A=1
      delete(A)
      continue       ; procede to next variable in do loop
    else
      print (A@long_name+" ("+creg+")")

      if (isvar("B")) then
        delete(B)
      end if

      B = -999.
      plot_switch_B=0
      if (compare.eq."OBS") then    ; Compare to OBS

        if (vars(i).eq."pco2") then
          infile2 = climodir2+"/Landschuetzer_2015/spco2_ETH_MON_1982-2011_"+creg+".nc"
          inptr2  = addfile(infile2,"r")
          if (isfilevar(inptr2,"spco2")) then
	    delete(B)
            B = inptr2->spco2(:,0,0)
            assignFillValue(B,B)
	    case2="Landschuetzer et al. (2015)"
	  end if
        end if

        if (vars(i).eq."co2fxn") then
          infile2 = climodir2+"/Landschuetzer_2015/spco2_ETH_MON_1982-2011_"+creg+".nc"
          inptr2  = addfile(infile2,"r")
          if (isfilevar(inptr2,"fgco2")) then
	    delete(B)
            tmp     = inptr2->fgco2(:,0,0)
            B       = (/-tmp/)
	    delete(tmp)
	    case2="Landschuetzer et al. (2015)"
	  end if
	  assignFillValue(B,B)
        end if

        if (vars(i).eq."po4lvl") then
          infile2 = climodir2+"/WOA13/woa13_all_pMON_01_"+creg+".nc"
          inptr2  = addfile(infile2,"r")
	  if (isfilevar(inptr2,"p_an")) then
	    delete(B)
            B       = inptr2->p_an(:,0,0)
	    assignFillValue(B,B)
	    case2="WOA13"
	  end if
        end if

      else ; Compare to model

        if (isvar("B")) then
          delete(B)
        end if
      
        infile2 = climodir2+"/"+case2+"_MON_"+fyr_prnt2+"-"+lyr_prnt2+"_climo_remap_"+creg+".nc"
        inptr2  = addfile(infile2,"r")
    
        if (vars(i) .eq. "pco2") then
          B = get_pco2 (inptr2)
        end if

        if (vars(i) .eq. "co2fxn") then
          B = get_co2fxn (inptr2)
        end if

        if (vars(i) .eq. "pp_tot") then
          B = get_pp (inptr2)
        end if

        if (vars(i) .eq. "po4lvl") then
          B = get_po4 (inptr2,(/0.0,100.0/),0.0)
        end if
	
      end if

      if (all(B.eq.-999.)) then
        print (vars(i)+" not present in case2 input file.")
	plot_switch_B=1
;        delete(B)
;        continue       ; procede to next variable in do loop
      end if
      
    end if

    if (plot_switch_A.eq.0) then
      res@tiYAxisString       = A@long_name+" ["+A@units+"]"
      res@tiMainString        = reg_long(ireg)

      if (plot_switch_B.eq.1) then
        res@xyLineThicknesses = (/2/)
        res@xyDashPatterns    = (/0/)
        res@xyLineColors      = (/"blue"/)
        ncases = 1
      else
        res@xyLineThicknesses = (/2,2/)
        res@xyDashPatterns    = (/0,0/)
        res@xyLineColors      = (/"blue","red"/)
        ncases = 2
      end if

      data=new((/ncases,12/),float)
      data(0,0:11) = A
      if (plot_switch_B.eq.0) then
        data(1,0:11) = (/B/)
      end if
      plot(ireg) = gsn_csm_xy(wks,pmth,data,res)
      delete(data)
      delete(A)
      delete(B)
      delete(res@xyLineThicknesses)
      delete(res@xyDashPatterns)
      delete(res@xyLineColors)
    end if
  end do
  if (plot_switch_A.eq.0) then
    gsn_panel(wks,(/plot/),(/2,4/),pan)
    
    ; Draw a text string at the bottom
    txres               = True
    txres@txFontHeightF = 0.013
    txres@txFontColor   = "blue"
    txres@txJust        = "centerright"
    gsn_text_ndc(wks,case1,0.99,0.2,txres)
    if (plot_switch_B.eq.0) then
      txres@txFontColor   = "red"
      gsn_text_ndc(wks,case2,0.99,0.17,txres)
    end if
    frame(wks)
    delete (wks)
    
  end if
end do        ; variable 

exit
end
