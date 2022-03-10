;**************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************************************
procedure set_line(lines:string,nline:integer,newlines:string) 
begin
; add line to ascci/html file
    
  nnewlines = dimsizes(newlines)
  if(nline+nnewlines-1.ge.dimsizes(lines))
    print("set_line: bad index, not setting anything.") 
    return
  end if 
  lines(nline:nline+nnewlines-1) = newlines
;  print ("lines = " + lines(nline:nline+nnewlines-1))
  nline = nline + nnewlines
  return 
end
;**************************************************************
; Main code.
begin
 
  plot_type     = "ps"
  plot_type_new = "png"

;-----------------------------------------------------
; edit table.html of current model for movel1_vs_model2

  if (isvar("compare")) then
     html_name2 = compare+"/table.html"  
     html_new2  = html_name2 +".new"
  end if

;------------------------------------------------------
; edit table.html for current model

  html_name = model_name+"/table.html"  
  html_new  = html_name +".new"

;------------------------------------------------------
; read data: model       

  fm = addfile(dirm+film2,"r")      
  laimod = fm->TLAI

  delete (fm)

  dsizes = dimsizes(laimod)
  ntime  = dsizes(0)
  nlat   = dsizes(1)
  nlon   = dsizes(2)

;-----------------------------------
; get landfrac data

 film_l   = "lnd_"+ model_grid + ".nc"
 fm_l     = addfile (dirs+film_l,"r")  
 landfrac = fm_l->landfrac

 delete (fm_l)
;----------------------------------
; read biome data: model

  biome_name_mod = "Model PFT Class"

  film_c   = "class_pft_"+model_grid+".nc"
  fm_c     = addfile(dirs+film_c,"r") 
  classmod = fm_c->CLASS_PFT               

  delete (fm_c)

; model data has 17 land-type classes
  nclass_mod = 17

;----------------------------------------------------------
; read data: ob       

;----------------------------------
; read biome data: observed

  biome_name_ob = "MODIS LandCover"

  dir_c = diro + "lai/"
  filo_c = "land_class_"+model_grid+".nc"
  fo = addfile(dir_c+filo_c,"r")
  classob = tofloat(fo->LAND_CLASS)               

  delete (fo)

; input observed data has 20 land-type classes
  nclass_ob = 20

;---------------------------------
; read lai data: observed

  ob_name = "MODIS MOD 15A2 2000-2005"

  dir_l = diro + "lai/"
  filo = "LAI_2000-2005_MONS_"+model_grid+".nc"
  fo = addfile(dir_l+filo,"r")                
  laiob = fo->LAI

  delete (fo)

;-------------------------------------------------
; take into account landfrac

  laimod = laimod * conform(laimod,landfrac,(/1,2/))
  laiob  = laiob  * conform(laiob ,landfrac,(/1,2/))

  delete (landfrac)

;************************************************
; global res
;************************************************
  resg                      = True             ; Use plot options
  resg@cnFillOn             = True             ; Turn on color fill
  resg@gsnSpreadColors      = True             ; use full colormap
  resg@cnLinesOn            = False            ; Turn off contourn lines
  resg@mpFillOn             = False            ; Turn off map fill
  resg@cnLevelSelectionMode = "ManualLevels"   ; Manual contour invtervals
      
;************************************************
; plot global biome class: (1) observed
;************************************************

  resg@cnMinLevelValF       = 1.              ; Min level
  resg@cnMaxLevelValF       = 19.             ; Max level
  resg@cnLevelSpacingF      = 1.              ; interval

  classob@_FillValue = 1.e+36
  classob = where(classob.eq.0,classob@_FillValue,classob)
  copy_VarCoords(laiob(0,:,:),classob)
  
  plot_name = "global_class_ob"
  title     = biome_name_ob
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,classob,resg)   

  delete (wks)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)
 
;************************************************
; plot global biome class: (2) model
;************************************************

  resg@cnMinLevelValF       = 0.              ; Min level
  resg@cnMaxLevelValF       = 16.             ; Max level
  resg@cnLevelSpacingF      = 1.              ; interval
  
  plot_name = "global_class_model"
  title     = biome_name_mod
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,classmod,resg)   

  delete (wks)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)
 
;*******************************************************************
; for html table : all 3 components (Mean, Max, Phase)
;*******************************************************************

; column (not including header column)

  component = (/"Mean","Max","Phase"/)

  col_head  = (/"observed",model_name,"M_score" \
               ,"observed",model_name,"M_score" \
               ,"observed",model_name,"M_score" \
               /)
  
  n_comp = dimsizes(component) 
  ncol   = dimsizes(col_head )

; row (not including header row)

;----------------------------------------------------
; using model biome class:  
  row_head  = (/"Not Vegetated" \
               ,"Needleleaf Evergreen Temperate Tree" \
               ,"Needleleaf Evergreen Boreal Tree" \
;              ,"Needleleaf Deciduous Boreal Tree" \
               ,"Broadleaf Evergreen Tropical Tree" \
               ,"Broadleaf Evergreen Temperate Tree" \
               ,"Broadleaf Deciduous Tropical Tree" \
               ,"Broadleaf Deciduous Temperate Tree" \
;              ,"Broadleaf Deciduous Boreal Tree" \
;              ,"Broadleaf Evergreen Shrub" \
               ,"Broadleaf Deciduous Temperate Shrub" \
               ,"Broadleaf Deciduous Boreal Shrub" \
               ,"C3 Arctic Grass" \
               ,"C3 Non-Arctic Grass" \
               ,"C4 Grass" \
               ,"Corn" \
;              ,"Wheat" \                      
               ,"All Biomes" \                
               /)  
  
  nrow = dimsizes(row_head)                  

; arrays to be passed to table. 
  text = new ((/nrow, ncol/),string ) 

; total M_score
  M_total = 0.

;********************************************************************
; use land-type class to bin the data in equally spaced ranges
;********************************************************************

; using model biome class
  nclass = nclass_mod

  range  = fspan(0,nclass,nclass+1)

; Use this range information to grab all the values in a
; particular range, and then take an average.

  nx = dimsizes(range) - 1

; for 2 data: model and observed
  data_n = 2

; using model biome class

  base = ndtooned(classmod)

; output

  yvalues = new((/data_n,nx/),float)
  count   = new((/data_n,nx/),float)

;************************************************************************
; go through all components
;************************************************************************

 do m = 0,n_comp-1

;===================
; get data:
;===================
; (A) Mean
 
  if (m .eq. 0) then
     data_ob  = dim_avg_Wrap(laiob (lat|:,lon|:,time|:))
     data_mod = dim_avg_Wrap(laimod(lat|:,lon|:,time|:))
  end if

; (B) Max

  if (m .eq. 1) then

;    observed  
     data_ob = laiob(0,:,:)
     data_ob@long_name = "Leaf Area Index Max"
  
     do j = 0,nlat-1
     do i = 0,nlon-1
        data_ob(j,i) = max(laiob(:,j,i))
     end do
     end do          

;    model  
     data_mod = laimod(0,:,:)
     data_mod@long_name = "Leaf Area Index Max"
  
     do j = 0,nlat-1
     do i = 0,nlon-1
        data_mod(j,i) = max(laimod(:,j,i))
     end do
     end do
          
  end if

; (C) phase

  if (m .eq. 2) then  

;    observed
     data_ob = laiob(0,:,:)
     data_ob@long_name = "Leaf Area Index Max Month"
  
     do j = 0,nlat-1
     do i = 0,nlon-1 
        data_ob(j,i) = maxind(laiob(:,j,i)) + 1
     end do
     end do          

;    model
     data_mod = laimod(0,:,:)
     data_mod@long_name = "Leaf Area Index Max Month"
  
     do j = 0,nlat-1
     do i = 0,nlon-1 
        data_mod(j,i) = maxind(laimod(:,j,i)) + 1
     end do
     end do
        
  end if

;==============================
; put data into bins
;==============================

; Loop through each range, using base

  do i=0,nx-1

     if (i.ne.(nx-1)) then
        idx = ind((base.ge.range(i)).and.(base.lt.range(i+1)))
     else
        idx = ind(base.ge.range(i))
     end if

;    loop through each dataset
 
     do n = 0,data_n-1

        if (n .eq. 0) then
           data = ndtooned(data_ob)
        end if

        if (n .eq. 1) then
           data = ndtooned(data_mod)
        end if

;       Calculate average 

        if (.not.any(ismissing(idx))) then
           yvalues(n,i) = avg(data(idx))
           count(n,i)   = dimsizes(idx)
        else
           yvalues(n,i) = yvalues@_FillValue
           count(n,i)   = 0
        end if

;#############################################################
; using model biome class:
;
;     set the following 4 classes to _FillValue:
;     (3)Needleleaf Deciduous Boreal Tree,
;     (8)Broadleaf Deciduous Boreal Tree,
;     (9)Broadleaf Evergreen Shrub,
;     (16)Wheat

      if (i.eq.3 .or. i.eq.8 .or. i.eq.9 .or. i.eq.16) then
         yvalues(n,i) = yvalues@_FillValue
         count(n,i)   = 0
      end if
;############################################################# 

      delete(data)
    end do                 ; n-loop

    delete(idx)
  end do                   ; i-loop

;=====================================
; compute correlation coef and M score 
;=====================================

  score_max = 5.0

  u       = yvalues(0,:)
  v       = yvalues(1,:)
  u_count = count(0,:)
  v_count = count(1,:)

  good = ind(.not.ismissing(u) .and. .not.ismissing(v))
 
  uu = u(good)
  vv = v(good)
  uu_count = u_count(good)
  vv_count = v_count(good)

; compute correlation coef
  cc = esccr(uu,vv,0)

  if (n .eq. 2) then
     bias   = avg(abs(vv-uu))
     bias   = where((bias.gt. 6.),12.-bias,bias)
     Mscore = ((6. - bias)/6.)*score_max
  else
     bias  = sum(abs(vv-uu)/abs(vv+uu))
     Mscore = (1.- (bias/dimsizes(uu)))*score_max
  end if

  M_score = sprintf("%.2f", Mscore)

; compute M_total
  
  M_total = M_total + Mscore

;================================
; output M_score to score sheet
;===============================

  if (isvar("compare")) then
     system("sed -e '1,/M_lai_"+component(m)+"/s/M_lai_"+component(m)+"/"+M_score+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_lai_"+component(m)+"#"+M_score+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)

;==============================
; output M_score to html table
;==============================

  n = m*3

  do i=0,nrow-2
     text(i,n)   = sprintf("%.1f",uu(i))
     text(i,n+1) = sprintf("%.1f",vv(i))
     text(i,n+2) = "-"
  end do
  text(nrow-1,n)   = sprintf("%.1f",sum(uu*uu_count)/sum(uu_count))
  text(nrow-1,n+1) = sprintf("%.1f",sum(vv*vv_count)/sum(vv_count))
  text(nrow-1,n+2) = M_score

  delete (u)
  delete (v)
  delete (uu)
  delete (vv)
  delete (u_count)
  delete (v_count)
  delete (uu_count)
  delete (vv_count)
  delete (good)

;======================================== 
; global res changes for each component
;========================================
  delta = 0.00001  

  if (m .eq. 0) then
     resg@cnMinLevelValF       = 0.             
     resg@cnMaxLevelValF       = 10.             
     resg@cnLevelSpacingF      = 1.

     data_ob = where(ismissing(data_ob).and.(ismissing(data_mod).or.(data_mod.lt.delta)),0.,data_ob)
  end if

  if (m .eq. 1) then
     resg@cnMinLevelValF       = 0.             
     resg@cnMaxLevelValF       = 10.             
     resg@cnLevelSpacingF      = 1.

     data_ob = where(ismissing(data_ob).and.(ismissing(data_mod).or.(data_mod.lt.delta)),0.,data_ob)
  end if

  if (m .eq. 2) then
     resg@cnMinLevelValF       = 1.             
     resg@cnMaxLevelValF       = 12.             
     resg@cnLevelSpacingF      = 1.

     data_ob = where(ismissing(data_ob).and.(ismissing(data_mod).or.(data_mod.lt.delta)),0.,data_ob)
  end if

;=========================
; global contour : ob
;=========================
  
  plot_name = "global_"+component(m)+"_ob"
  title     = ob_name
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,data_ob,resg)   

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;============================
; global contour : model
;============================

  plot_name = "global_"+component(m)+"_model"  
  title     = "Model " + model_name
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)
  gsn_define_colormap(wks,"gui_default")     

  plot = gsn_csm_contour_map_ce(wks,data_mod,resg)   

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

;================================
; global contour: model vs ob
;================================

  plot_name = "global_"+component(m)+"_model_vs_ob"

  wks = gsn_open_wks (plot_type,plot_name)   
  gsn_define_colormap(wks,"gui_default")     

  plot=new(3,graphic)                        ; create graphic array

  resg@gsnFrame             = False          ; Do not draw plot 
  resg@gsnDraw              = False          ; Do not advance frame

; plot correlation coef

  gRes               = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF      = 90

  correlation_text = "(correlation coef = "+sprintf("%.2f", cc)+")"

  gsn_text_ndc(wks,correlation_text,0.20,0.50,gRes)
  
; plot ob

  title     = ob_name
  resg@tiMainString  = title

  plot(0) = gsn_csm_contour_map_ce(wks,data_ob,resg)       

; plot model

  title     = "Model "+ model_name
  resg@tiMainString  = title

  plot(1) = gsn_csm_contour_map_ce(wks,data_mod,resg) 

; plot model-ob

  if (m .eq. 0) then
     resg@cnMinLevelValF  = -2.           
     resg@cnMaxLevelValF  =  2.            
     resg@cnLevelSpacingF =  0.4
  end if

  if (m .eq. 1) then
     resg@cnMinLevelValF  = -6.           
     resg@cnMaxLevelValF  =  6.            
     resg@cnLevelSpacingF =  1.
  end if

  if (m .eq. 2) then
     resg@cnMinLevelValF  = -6.           
     resg@cnMaxLevelValF  =  6.            
     resg@cnLevelSpacingF =  1.
  end if

  zz = data_mod
  zz = data_mod - data_ob
  title = "Model_"+model_name+" - Observed"
  resg@tiMainString    = title

  plot(2) = gsn_csm_contour_map_ce(wks,zz,resg) 

; plot panel

  pres                            = True        ; panel plot mods desired
  pres@gsnMaximize                = True        ; fill the page

  gsn_panel(wks,plot,(/3,1/),pres)              ; create panel plot

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

  delete (data_ob)
  delete (data_mod)

  resg@gsnFrame             = True          ; Do advance frame 
  resg@gsnDraw              = True          ; Do draw plot

 end do    ; m-loop

;**************************************************
; html table
;**************************************************
  output_html = "table_model_vs_ob.html"

  header_text = "<H1>LAI: Model "+model_name+" vs. MODIS observations</H1>" 

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,header_text \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=100%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Biome Class</th>" \
       ,"   <th bgcolor=DDDDDD colspan=3>"+component(0)+"</th>" \
       ,"   <th bgcolor=DDDDDD colspan=3>"+component(1)+"</th>" \
       ,"   <th bgcolor=DDDDDD colspan=3>"+component(2)+"</th>" \
       ,"</tr>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,"   <th bgcolor=DDDDDD >"+model_name+"</th>" \
       ,"   <th bgcolor=DDDDDD >M_score</th>" \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,"   <th bgcolor=DDDDDD >"+model_name+"</th>" \
       ,"   <th bgcolor=DDDDDD >M_score</th>" \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,"   <th bgcolor=DDDDDD >"+model_name+"</th>" \
       ,"   <th bgcolor=DDDDDD >M_score</th>" \
       ,"</tr>" \
       /)
  table_footer = "</table>"
  row_header = "<tr>"
  row_footer = "</tr>"

  lines = new(50000,string)
  nline = 0

  set_line(lines,nline,header)
  set_line(lines,nline,table_header)
;-----------------------------------------------
;row of table

  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1  = row_head(n)
     txt2  = text(n,0)
     txt3  = text(n,1)
     txt4  = text(n,2)
     txt5  = text(n,3)
     txt6  = text(n,4)
     txt7  = text(n,5)
     txt8  = text(n,6)
     txt9  = text(n,7)
     txt10 = text(n,8) 

     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")
     set_line(lines,nline,"<th>"+txt7+"</th>")
     set_line(lines,nline,"<th>"+txt8+"</th>")
     set_line(lines,nline,"<th>"+txt9+"</th>")
     set_line(lines,nline,"<th>"+txt10+"</th>")

     set_line(lines,nline,row_footer)
  end do
;-----------------------------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file

  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

;***************************************************************************
; write total score to file
;***************************************************************************

  asciiwrite("M_save.lai", M_total)

;***************************************************************************
; output plots
;***************************************************************************
  output_dir = model_name+"/lai"

  system("mv *.png *.html " + dirm + output_dir) 
;***************************************************************************
exit
end

