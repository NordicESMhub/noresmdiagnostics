; ****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin

 plot_type     = "ps"
 plot_type_new = "png"

;------------------------------------------------------
; edit table.html of current model for movel1_vs_model2

 if (isvar("compare")) then
    html_name2 = compare+"/table.html"  
    html_new2  = html_name2 +".new"
 end if

;------------------------------------------------------
; edit table.html for current model

 html_name = model_name+"/table.html"  
 html_new  = html_name +".new"

;---------------------------------
; get model data: landfrac and area

  film_l   = "lnd_"+ model_grid + ".nc"
  fm_l     = addfile (dirs+film_l,"r")  
  
  landfrac = fm_l->landfrac
  area0    = fm_l->area

  delete (fm_l)

; change area from km**2 to m**2
  area0 = area0 * 1.e6
             
;-----------------------------
; take into account landfrac

  area0     = area0 * landfrac

;--------------------------------------------
; read model data

 fm   = addfile (dirm+film1,"r")

 if (BGC .eq. "cn") then 
    data1  = fm->LIVESTEMC
    data2  = fm->DEADSTEMC
    data3  = fm->LEAFC
    datamod0 = data1(0,:,:)
    datamod0 = data1(0,:,:) + data2(0,:,:) + data3(0,:,:)
 end if

 if (BGC .eq. "casa") then
    factor_WOODC = 0.7  
    data1  = fm->WOODC
    data2  = fm->LEAFC
    datamod0 = data1(0,:,:)
    datamod0 = data1(0,:,:)*factor_WOODC + data2(0,:,:)
 end if

; unit: gC/m2

 xm       = fm->lon  
 ym       = fm->lat

 delete (fm)

;------------------------------------------------
; read amazon mask data

  dir_m = diro + "biomass/"
  fil_m = "amazon_mask_"+ model_grid + ".nc"
  fm    = addfile (dir_m+fil_m,"r")

  mask_amazon0 = fm->mask_amazon

  delete (fm)

;------------------------------------------------
; read ob data

 ob_name = "LC15_Amazon_Biomass"

 dir_b = diro + "biomass/"
 fil_b = "amazon_biomass_"+model_grid+".nc"
 fo   = addfile (dir_b+fil_b,"r")
 
 dataob   = fo->BIOMASS
 xo       = fo->lon  
 yo       = fo->lat

 delete (fo)

;************************************************
; Units for these variables are:
; dataob   : MgC/ha
; datamod0 : gC/m2
; We want to convert these to KgC/m2
; ha = 100m*100m = 10,000 m2
; MgC/ha*1000/10,000 = KgC/m2

  factor_aboveground = 0.5
  factor_unit_ob     = 0.1
  factor_unit_mod    = 0.001         

  dataob   = dataob * factor_aboveground * factor_unit_ob
  datamod0 = datamod0 * factor_unit_mod 

  dataob@units      = "KgC/m2"
  datamod0@units    = "KgC/m2"

  dataob@long_name      = "Amazon Biomass"
  datamod0@long_name    = "Amazon Biomass"
;********************************************************
; get subset of datamod0 that match dataob
  
  nlon = dimsizes(xo)
  nlat = dimsizes(yo)

  ind_lonL = ind(xm .eq. xo(0))
  ind_lonR = ind(xm .eq. xo(nlon-1))
  ind_latS = ind(ym .eq. yo(0))
  ind_latN = ind(ym .eq. yo(nlat-1))

  datamod  = dataob
  datamod(:,:) = datamod0(ind_latS:ind_latN,ind_lonL:ind_lonR)

  area  = dataob
  area(:,:) = area0(ind_latS:ind_latN,ind_lonL:ind_lonR)

  mask_amazon  = dataob
  mask_amazon(:,:) = mask_amazon0(ind_latS:ind_latN,ind_lonL:ind_lonR)

  mask_amazon@units = ""
;********************************************************
; sum over amazom_mask area:

; Peta g = 1.e15 g = 1.e12 Kg
  factor_unit = 1.e-12

; mask_amazon = where(mask_amazon .ge. 0.5, mask_amazon ,0.)

  Sum_area = sum(area*mask_amazon)*factor_unit

  Sum_ob  = sum(dataob*area*mask_amazon)*factor_unit
  Sum_mod = sum(datamod*area*mask_amazon)*factor_unit

  avg_ob  = Sum_ob /Sum_area
  avg_mod = Sum_mod/Sum_area

  Sum_biomass_ob  = sprintf("%.2f",Sum_ob )
  Sum_biomass_mod = sprintf("%.2f",Sum_mod) 
    
;---------------------------------------------------------------------- 
; contour plot res

  resg                     = True             ; Use plot options
  resg@cnFillOn            = True             ; Turn on color fill
  resg@gsnSpreadColors     = True             ; use full colormap
  resg@cnLinesOn           = False            ; Turn off contourn lines
  resg@mpFillOn            = False            ; Turn off map fill
  resg@gsnAddCyclic        = False

  resg@gsnSpreadColors      = True            ; use full colormap
  resg@cnLevelSelectionMode = "ManualLevels"  ; Manual contour invtervals

  resg@mpMinLatF            = -21.1      ; range to zoom in on
  resg@mpMaxLatF            =  13.8
  resg@mpMinLonF            =  277.28
  resg@mpMaxLonF            =  326.43
  resg@mpCenterLonF         =  301.855
;------------------------------------------------------------------------
; mask plot

  plot_name = "mask_ob"

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

;-----------------------------------------
; plot area sum

  gRes  = True
  gRes@txFontHeightF = 0.02
; gRes@txAngleF = 90

  area_sum_text = "(mask area = "+sprintf("%.2f", Sum_area)+"e12 m2)"

  gsn_text_ndc(wks,area_sum_text,0.50,0.80,gRes)
;-----------------------------------------

  resg@cnMinLevelValF      = 0.              ; Min level
  resg@cnMaxLevelValF      = 1.              ; Max level
  resg@cnLevelSpacingF     = 0.1             ; interval

  resg@tiMainString        = "Amazon Mask: grid = "+ model_grid
  
  plot = gsn_csm_contour_map_ce(wks,mask_amazon,resg)   

  delete (wks)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;------------------------------------------------------------------------
; contour ob

  resg@cnMinLevelValF       = 0.              ; Min level
  resg@cnMaxLevelValF       = 30.             ; Max level
  resg@cnLevelSpacingF      = 2.              ; interval
  
  plot_name = "global_ob"
  title     = ob_name+" "+ model_grid
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,dataob,resg)   

  delete (wks)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;------------------------------------------------------------------------
; contour model

  resg@cnMinLevelValF       = 0.              ; Min level
  resg@cnMaxLevelValF       = 30.             ; Max level
  resg@cnLevelSpacingF      = 2.              ; interval

  plot_name = "global_model"
  title     = "Model "+ model_name 
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,datamod,resg)   

  delete (wks)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;------------------------------------------------------------------------
; contour model vs ob

  plot_name = "global_model_vs_ob"

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  delete (plot)
  plot=new(3,graphic)                        ; create graphic array

  resg@gsnFrame             = False          ; Do not draw plot 
  resg@gsnDraw              = False          ; Do not advance frame

;(d) compute correlation coef and M score

  uu = ndtooned(datamod)
  vv = ndtooned(dataob)
 
  good = ind(.not.ismissing(uu) .and. .not.ismissing(vv))

  ug = uu(good)
  vg = vv(good)

  ccrG = esccr(ug,vg,0)

  score_max = 5.0

; Miomass = (ccrG*ccrG)* score_max
; new eq
  bias = sum(abs(ug-vg)/(abs(ug)+abs(vg)+1e-20))
  Mbiomass  = (1. - (bias/dimsizes(ug)))*score_max
  M_biomass = sprintf("%.2f", Mbiomass)

  if (isvar("compare")) then
     system("sed -e '1,/M_biomass/s/M_biomass/"+M_biomass+"/' "+html_name2+" > "+html_new2+";"+ \ 
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_biomass#"+M_biomass+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)

; plot correlation coef

  gRes  = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF = 90

  correlation_text = "(correlation coef = "+sprintf("%5.2f", ccrG)+")"

  gsn_text_ndc(wks,correlation_text,0.20,0.50,gRes)
;--------------------------------------------------------------------
  
;(a) ob

  title     = ob_name+" "+ model_grid
  resg@tiMainString  = title

  plot(0) = gsn_csm_contour_map_ce(wks,dataob,resg)       

;(b) model

  title     = "Model "+ model_name
  resg@tiMainString  = title

  plot(1) = gsn_csm_contour_map_ce(wks,datamod,resg) 

;(c) model-ob

  zz = datamod
  zz = datamod - dataob
  title = "Model_"+model_name+" - Observed"

  resg@cnMinLevelValF  = -10.          ; Min level
  resg@cnMaxLevelValF  =  10.          ; Max level
  resg@cnLevelSpacingF =  2.           ; interval
  resg@tiMainString    = title

  plot(2) = gsn_csm_contour_map_ce(wks,zz,resg) 

  pres                            = True        ; panel plot mods desired
; pres@gsnPanelYWhiteSpacePercent = 5           ; increase white space around
                                                ; indiv. plots in panel
  pres@gsnMaximize                = True        ; fill the page

  gsn_panel(wks,plot,(/3,1/),pres)              ; create panel plot

  delete (wks)
  delete (plot)
  delete (zz)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

  resg@gsnFrame             = True            ; draw plot 
  resg@gsnDraw              = True            ; advance frame
;------------------------------------------------------------------------
; contour ob : masked
 
  resg@cnMinLevelValF       = 0.              ; Min level
  resg@cnMaxLevelValF       = 30.             ; Max level
  resg@cnLevelSpacingF      = 2.              ; interval
  
  plot_name = "global_mask_ob"
  title     = ob_name+" "+ model_grid
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap
;-----------------------------------------
; plot average over mask region

  gRes  = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF = 0

  area_avg_text = "(average over mask area = "+sprintf("%.2f", avg_ob)+" Kg C/m2)"

  gsn_text_ndc(wks,area_avg_text,0.50,0.81,gRes)
;-----------------------------------------
  zo = dataob
  zo = dataob*mask_amazon
  zo = where((mask_amazon .le. 0.01), zo@_FillValue, zo)  
  plot = gsn_csm_contour_map_ce(wks,zo,resg)   

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;------------------------------------------------------------------------
; contour model: masked

  resg@cnMinLevelValF       = 0.              ; Min level
  resg@cnMaxLevelValF       = 30.             ; Max level
  resg@cnLevelSpacingF      = 2.              ; interval

  plot_name = "global_mask_model"
  title     = "Model "+ model_name 
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap
;-----------------------------------------
; plot average over mask region

  gRes  = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF = 0

  area_avg_text = "(average over mask area = "+sprintf("%.2f", avg_mod)+" Kg C/m2)"

  gsn_text_ndc(wks,area_avg_text,0.50,0.81,gRes)
;-----------------------------------------
  zm = datamod
  zm = datamod*mask_amazon
  zm = where((mask_amazon .le. 0.01), zm@_FillValue, zm)  
  plot = gsn_csm_contour_map_ce(wks,zm,resg)     

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;------------------------------------------------------------------------
; contour model vs ob: masked 

  plot_name = "global_mask_vs_ob"

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot=new(3,graphic)                        ; create graphic array

  resg@gsnFrame             = False          ; Do not draw plot 
  resg@gsnDraw              = False          ; Do not advance frame

;(d) compute correlation coef and M score

  delete (good)
  delete (uu)
  delete (vv)
  delete (ug)
  delete (vg)  

  score_max = 5.

  uu = ndtooned(zm)
  vv = ndtooned(zo)

  good = ind((uu .gt. 0.) .and. (vv .gt. 0.))

  ug = uu(good)
  vg = vv(good)

  ccrG = esccr(ug,vg,0)

; Miomass = (ccrG*ccrG)*score_max 
; new eq
  bias = sum(abs(ug-vg)/(abs(ug)+abs(vg)))
  Mbiomass2  = (1. - (bias/dimsizes(ug)))*score_max
  M_biomask = sprintf("%.2f", Mbiomass2)

  if (isvar("compare")) then
     system("sed -e '1,/M_biomask/s/M_biomask/"+M_biomask+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
     system("sed -e '1,/Sum_biomass_ob/s/Sum_biomass_ob/"+Sum_biomass_ob+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
     system("sed -e '1,/Sum_biomass_mod/s/Sum_biomass_mod/"+Sum_biomass_mod+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_biomask#"+M_biomask+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)
  system("sed s#Sum_biomass_ob#"+Sum_biomass_ob+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)
  system("sed s#Sum_biomass_mod#"+Sum_biomass_mod+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)
;--------------------------------------------------------------------
; plot correlation coef

  gRes  = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF = 90

  correlation_text = "(correlation coef = "+sprintf("%.2f", ccrG)+")"

  gsn_text_ndc(wks,correlation_text,0.20,0.50,gRes)
;--------------------------------------------------------------------
  
;(a) ob

  title     = ob_name+" "+ model_grid
  resg@tiMainString  = title

  plot(0) = gsn_csm_contour_map_ce(wks,zo,resg)       

;(b) model

  title     = "Model "+ model_name
  resg@tiMainString  = title

  plot(1) = gsn_csm_contour_map_ce(wks,zm,resg) 

;(c) model-ob

  zz = zo
  zz = zm - zo
  title = "Model_"+model_name+" - Observed"

  resg@cnMinLevelValF  = -10.          ; Min level
  resg@cnMaxLevelValF  =  10.          ; Max level
  resg@cnLevelSpacingF =  2.           ; interval
  resg@tiMainString    = title

  plot(2) = gsn_csm_contour_map_ce(wks,zz,resg) 

  pres                            = True        ; panel plot mods desired
; pres@gsnPanelYWhiteSpacePercent = 5           ; increase white space around
                                                ; indiv. plots in panel
  pres@gsnMaximize                = True        ; fill the page

  gsn_panel(wks,plot,(/3,1/),pres)              ; create panel plot

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;***************************************************************************
; add total score and write to file
;***************************************************************************
  M_total = Mbiomass + Mbiomass2

  asciiwrite("M_save.biomass", M_total)

;***************************************************************************
; output plots
;***************************************************************************
  output_dir = model_name+"/biomass"

  system("mv *.png " + dirm + output_dir) 
;***************************************************************************
exit
end
