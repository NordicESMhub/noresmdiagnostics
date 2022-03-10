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

;------------------------------------------------------ 
; get biome data: model

  biome_name_mod = "Model PFT Class"

  film_c   = "class_pft_"+ model_grid +".nc"
  fm_c     = addfile (dirs+film_c,"r") 
  classmod = fm_c->CLASS_PFT

  delete (fm_c)

; model data has 17 land-type classes
  nclass_mod = 17

;--------------------------------
; get model data: landmask, landfrac and area
 
  film_l   = "lnd_"+ model_grid +".nc"
  fm_l     = addfile (dirs+film_l,"r")  
  landmask = fm_l->landmask
  landfrac = fm_l->landfrac
  area     = fm_l->area

  delete (fm_l)

; change area from km**2 to m**2
  area = area * 1.e6
             
; take into account landfrac
  area     = area * landfrac

;--------------------------------
; read data: time series, model

 fm   = addfile (dirm+film7,"r")

 tmp = fm->COL_FIRE_CLOSS(:,:,:,:)
 dsizes = dimsizes(tmp)
 nyear  = dsizes(0)
 date = fm->date(:,0)   ; (year,month)
 tmp&year = (/date/)
 if ( (date(0) .le. 199701) .and. (date(nyear-1) .ge. 200501) )
   data_mod = tmp({199701:200501},:,:,:)
 else
   print((/"Model years chosen do not overlap fire data of 1997-2005"/))
   print((/"EXIT 10.fire.ncl"/))
   exit
 end if
 delete(dsizes)
 delete(nyear)
 delete(date)
 delete(tmp)

 delete (fm)

; Units for these variables are:
; g C/m^2/s

; change unit to g C/m^2/month

  nsec_per_month = 60*60*24*30
 
  data_mod = data_mod * nsec_per_month 

  data_mod@unit = "gC/m2/month"

;----------------------------------------------------
; read data: time series, observed

 dir_f   = diro + "fire/"
 fil_f   = "Fire_C_1997-2006_monthly_"+ model_grid+".nc"
 fm      = addfile (dir_f+fil_f,"r")
 data_ob = fm->FIRE_C(0:8,:,:,:)

 delete (fm)

 ob_name = "GFEDv2"

; Units for these variables are:
; g C/m^2/month

;-------------------------------------------------------------
; html table1 data

; column (not including header column)

  col_head  = (/"Observed Fire_Flux (PgC/yr)" \
               ,"Model Fire_Flux (PgC/yr)" \
               ,"Correlation Coefficient" \
               ,"Ratio model/observed" \
               ,"M_score" \
               ,"Timeseries plot" \
               /)

  ncol = dimsizes(col_head)

; row (not including header row)                   

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
               ,"All Biome" \                
               /)  
  nrow = dimsizes(row_head)                  

; arrays to be passed to table. 
  text = new ((/nrow, ncol/),string ) 

;*****************************************************************
; (A) get time-mean
;*****************************************************************
  
  x          = dim_avg_Wrap(data_mod(lat|:,lon|:,month|:,year|:))
  data_mod_m = dim_avg_Wrap(       x(lat|:,lon|:,month|:))
  delete (x)

  x          = dim_avg_Wrap( data_ob(lat|:,lon|:,month|:,year|:))
  data_ob_m  = dim_avg_Wrap(       x(lat|:,lon|:,month|:))
  delete (x)

;----------------------------------------------------
; compute correlation coef: space

  landmask_1d = ndtooned(landmask)
  data_mod_1d = ndtooned(data_mod_m)
  data_ob_1d  = ndtooned(data_ob_m )
  area_1d     = ndtooned(area)
  landfrac_1d = ndtooned(landfrac)

  good = ind(landmask_1d .gt. 0.)

  global_mod = sum(data_mod_1d(good)*area_1d(good)) * 1.e-15 * 12.
  global_ob  = sum(data_ob_1d(good) *area_1d(good)) * 1.e-15 * 12.
; print (global_mod)
; print (global_ob)  

  global_area= sum(area_1d)
  global_land= sum(area_1d(good))
; print (global_area)
; print (global_land)

  cc_space = esccr(data_mod_1d(good)*landfrac_1d(good),data_ob_1d(good)*landfrac_1d(good),0)

  delete (landmask_1d)
  delete (landfrac_1d)
; delete (area_1d)
  delete (data_mod_1d)
  delete (data_ob_1d)
  delete (good)

;----------------------------------------------------
; compute M_global

  score_max = 1.

  Mscore1 = cc_space * cc_space * score_max

  M_global = sprintf("%.2f", Mscore1)
 
;----------------------------------------------------
; global res

  resg                      = True             ; Use plot options
  resg@cnFillOn             = True             ; Turn on color fill
  resg@gsnSpreadColors      = True             ; use full colormap
  resg@cnLinesOn            = False            ; Turn off contourn lines
  resg@mpFillOn             = False            ; Turn off map fill
  resg@cnLevelSelectionMode = "ManualLevels"   ; Manual contour invtervals
      
;----------------------------------------------------
; global contour: model vs ob

  plot_name = "global_model_vs_ob"

  wks = gsn_open_wks (plot_type,plot_name)   
  gsn_define_colormap(wks,"gui_default")     

  plot=new(3,graphic)                        ; create graphic array

  resg@gsnFrame             = False          ; Do not draw plot 
  resg@gsnDraw              = False          ; Do not advance frame

;----------------------
; plot correlation coef

  gRes               = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF      = 90

  correlation_text = "(correlation coef = "+sprintf("%.2f", cc_space)+")"

  gsn_text_ndc(wks,correlation_text,0.20,0.50,gRes)

;-----------------------  
; plot ob

  data_ob_m = where(landmask .gt. 0., data_ob_m, data_ob_m@_FillValue)

  title     = ob_name
  resg@tiMainString  = title

  resg@cnMinLevelValF       = 1.             
  resg@cnMaxLevelValF       = 10.             
  resg@cnLevelSpacingF      = 1.

  plot(0) = gsn_csm_contour_map_ce(wks,data_ob_m,resg)       

;-----------------------
; plot model

  data_mod_m = where(landmask .gt. 0., data_mod_m, data_mod_m@_FillValue)

  title     = "Model "+ model_name
  resg@tiMainString  = title

  resg@cnMinLevelValF       = 1.             
  resg@cnMaxLevelValF       = 10.             
  resg@cnLevelSpacingF      = 1.

  plot(1) = gsn_csm_contour_map_ce(wks,data_mod_m,resg) 

;-----------------------
; plot model-ob

  resg@cnMinLevelValF  = -8.           
  resg@cnMaxLevelValF  =  2.            
  resg@cnLevelSpacingF =  1.

  zz = data_ob_m
  zz = data_mod_m - data_ob_m
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

  delete (data_ob_m)
  delete (data_mod_m)
  delete (zz)

  resg@gsnFrame             = True          ; Do advance frame 
  resg@gsnDraw              = True          ; Do draw plot

;*******************************************************************
; (B) Time series : per biome
;*******************************************************************

 data_n = 2

 dsizes = dimsizes(data_mod)
 nyear  = dsizes(0)
 nmonth = dsizes(1)
 ntime  = nyear * nmonth

 year_start = 1997
 year_end   = 2004
                
;-------------------------------------------
; Calculate "nice" bins for binning the data

; using model biome class
  nclass = nclass_mod

  range  = fspan(0,nclass,nclass+1)

; Use this range information to grab all the values in a
; particular range, and then take an average.

  nx = dimsizes(range) - 1

;-------------------------------------------
; put data into bins

; using observed biome class
; base  = ndtooned(classob)
; using model biome class
  base  = ndtooned(classmod)

; output

  area_bin = new((/nx/),float)
  yvalues  = new((/ntime,data_n,nx/),float)

; Loop through each range, using base.

  do i=0,nx-1

     if (i.ne.(nx-1)) then
        idx = ind((base.ge.range(i)).and.(base.lt.range(i+1)))
     else
        idx = ind(base.ge.range(i))
     end if
;---------------------
;    for area  

     if (.not.any(ismissing(idx))) then 
        area_bin(i) = sum(area_1d(idx))
     else
        area_bin(i) = area_bin@_FillValue
     end if

;#############################################################
; using model biome class:
;     set the following 4 classes to _FillValue:
;     (3)Needleleaf Deciduous Boreal Tree,
;     (8)Broadleaf Deciduous Boreal Tree,
;     (9)Broadleaf Evergreen Shrub,
;     (16)Wheat

     if (i.eq.3 .or. i.eq.8 .or. i.eq.9 .or. i.eq.16) then
        area_bin(i) = area_bin@_FillValue
     end if
;#############################################################  

;---------------------
; for data_mod and data_ob

  do n = 0,data_n-1

     t = -1
     do m = 0,nyear-1
     do k = 0,nmonth-1
    
        t = t + 1 

        if (n.eq.0) then
           data = ndtooned(data_ob(m,k,:,:))
        end if

        if (n.eq.1) then
           data = ndtooned(data_mod(m,k,:,:))
        end if

;       Calculate average
 
        if (.not.any(ismissing(idx))) then 
           yvalues(t,n,i) = sum(data(idx)*area_1d(idx))
        else
           yvalues(t,n,i) = yvalues@_FillValue
        end if

;#############################################################
; using model biome class:
;     set the following 4 classes to _FillValue:
;     (3)Needleleaf Deciduous Boreal Tree,
;     (8)Broadleaf Deciduous Boreal Tree,
;     (9)Broadleaf Evergreen Shrub,
;     (16)Wheat

        if (i.eq.3 .or. i.eq.8 .or. i.eq.9 .or. i.eq.16) then
           yvalues(t,n,i) = yvalues@_FillValue
        end if
;#############################################################  

     end do
     end do

     delete(data)
  end do 

    delete(idx)
  end do

  delete (base)
  delete (data_mod)
  delete (data_ob)

  global_bin = sum(area_bin)
; print (global_bin)

;----------------------------------------------------------------
; get area_good

  good = ind(.not.ismissing(area_bin))

  area_g = area_bin(good)  

  n_biome = dimsizes(good)

  global_good = sum(area_g)
; print (global_good)

;----------------------------------------------------------------
; data for tseries plot

  yvalues_g = new((/ntime,data_n,n_biome/),float)

  yvalues_g@units = "TgC/month"

; change unit to Tg C/month
; change unit from g to Tg (Tera gram)
  factor_unit = 1.e-12

  yvalues_g = yvalues(:,:,good) * factor_unit

  delete (good)

;-------------------------------------------------------------------
; general settings for line plot

  res                   = True               
  res@xyDashPatterns    = (/0,0/)          ; make lines solid
  res@xyLineThicknesses = (/2.0,2.0/)      ; make lines thicker
  res@xyLineColors      = (/"blue","red"/) ; line color

  res@trXMinF   = year_start
  res@trXMaxF   = year_end + 1

  res@vpHeightF = 0.4                 ; change aspect ratio of plot
; res@vpWidthF  = 0.8
  res@vpWidthF  = 0.75   

  res@tiMainFontHeightF = 0.025       ; size of title 

  res@tmXBFormat  = "f"               ; not to add trailing zeros

; res@gsnMaximize = True

;----------------------------------------------
; Add a boxed legend using the simple method

  res@pmLegendDisplayMode    = "Always"
; res@pmLegendWidthF         = 0.1
  res@pmLegendWidthF         = 0.08
  res@pmLegendHeightF        = 0.06
  res@pmLegendOrthogonalPosF = -1.17
; res@pmLegendOrthogonalPosF = -1.00  ;(downward)
; res@pmLegendOrthogonalPosF = -0.30  ;(downward)

; res@pmLegendParallelPosF   =  0.18
  res@pmLegendParallelPosF   =  0.23  ;(rightward)
  res@pmLegendParallelPosF   =  0.73  ;(rightward)
  res@pmLegendParallelPosF   =  0.83  ;(rightward)

; res@lgPerimOn             = False
  res@lgLabelFontHeightF     = 0.015
  res@xyExplicitLegendLabels = (/"observed",model_name/)

;*******************************************************************
; (A) time series plot: monthly ( 2 lines per plot)
;*******************************************************************

; x-axis in time series plot

  timeI = new((/ntime/),integer)
  timeF = new((/ntime/),float)
  timeI = ispan(1,ntime,1)
  timeF = year_start + (timeI-1)/12.
  timeF@long_name = "year" 

  plot_data = new((/2,ntime/),float)
  plot_data@long_name = "TgC/month"

;----------------------------------------------
; time series plot : per biome
 
  do m = 0, n_biome-1

     plot_name = "monthly_biome_"+ m

     wks = gsn_open_wks (plot_type,plot_name)   

     title = "Fire : "+ row_head(m)
     res@tiMainString = title

     plot_data(0,:) = yvalues_g(:,0,m)
     plot_data(1,:) = yvalues_g(:,1,m)
                                  
     plot = gsn_csm_xy(wks,timeF,plot_data,res)

     delete (wks)
     delete (plot)

     system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
            "rm "+plot_name+"."+plot_type)
  end do

;------------------------------------------
; data for table : per biome

; unit change from TgC/month to PgC/month
  unit_factor = 1.e-3

  score_max = 1.

  tmp_ob    = new((/ntime/),float)
  tmp_mod   = new((/ntime/),float)

  total_ob  = new((/n_biome/),float)
  total_mod = new((/n_biome/),float)
  Mscore2   = new((/n_biome/),float)

  do m = 0, n_biome-1

     tmp_ob  = yvalues_g(:,0,m) 
     tmp_mod = yvalues_g(:,1,m) 

     total_ob(m)  = avg(month_to_annual(tmp_ob, 0)) * unit_factor 
     total_mod(m) = avg(month_to_annual(tmp_mod,0)) * unit_factor
     
     cc_time = esccr(tmp_mod,tmp_ob,0)

     ratio = total_mod(m)/total_ob(m)

     good = ind(tmp_ob .ne. 0. .and. tmp_mod .ne. 0.)

     bias = sum( abs( tmp_mod(good)-tmp_ob(good) )/( abs(tmp_mod(good))+abs(tmp_ob(good)) ) )
     Mscore2(m) = (1.- (bias/dimsizes(good)))*score_max

     delete (good)
     
     text(m,0) = sprintf("%.2f",total_ob(m))
     text(m,1) = sprintf("%.2f",total_mod(m))
     text(m,2) = sprintf("%.2f",cc_time)
     text(m,3) = sprintf("%.2f",ratio)
     text(m,4) = sprintf("%.2f",Mscore2(m))
     text(m,5) = "<a href=./monthly_biome_"+m+".png>model_vs_ob</a>" 
  end do
 
  delete (tmp_ob)
  delete (tmp_mod)

;--------------------------------------------
; time series plot: all biome

     plot_name = "monthly_global"

     wks = gsn_open_wks (plot_type,plot_name)   

     title = "Fire : "+ row_head(n_biome)
     res@tiMainString = title

     do k = 0,ntime-1
        plot_data(0,k) = sum(yvalues_g(k,0,:))
        plot_data(1,k) = sum(yvalues_g(k,1,:))
     end do
                                  
     plot = gsn_csm_xy(wks,timeF,plot_data,res)

     delete (wks)
     delete (plot)

     system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
            "rm "+plot_name+"."+plot_type)

;------------------------------------------
; data for table : global

  score_max = 1.

  tmp_ob  = ndtooned(yvalues_g(:,0,:))
  tmp_mod = ndtooned(yvalues_g(:,1,:))

  cc_time = esccr(tmp_mod,tmp_ob,0)

  ratio = sum(total_mod)/sum(total_ob) 

  good = ind(tmp_ob .ne. 0. .and. tmp_mod .ne. 0.)

  bias = sum( abs( tmp_mod(good)-tmp_ob(good) )/( abs(tmp_mod(good))+abs(tmp_ob(good)) ) )
  Mscore3 = (1.- (bias/dimsizes(good)))*score_max

; print (Mscore3)

  delete (good) 

  text(nrow-1,0) = sprintf("%.2f",sum(total_ob))
  text(nrow-1,1) = sprintf("%.2f",sum(total_mod))
  text(nrow-1,2) = sprintf("%.2f",cc_time)
  text(nrow-1,3) = sprintf("%.2f",ratio)
; text(nrow-1,4) = sprintf("%.2f",avg(Mscore2))
  text(nrow-1,4) = sprintf("%.2f",    Mscore3)
  text(nrow-1,5) = "<a href=./monthly_global.png>model_vs_ob</a>"

;**************************************************
; create html table
;**************************************************

  header_text = "<H1>Fire Emission (1997-2004):  Model "+model_name+"</H1>" 

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,header_text \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=60%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Biome Type</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(0)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(1)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(2)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(3)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(4)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(5)+"</th>" \
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

     txt0  = row_head(n)
     txt1  = text(n,0)
     txt2  = text(n,1)
     txt3  = text(n,2)
     txt4  = text(n,3)
     txt5  = text(n,4)
     txt6  = text(n,5)

     set_line(lines,nline,"<th>"+txt0+"</th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")

     set_line(lines,nline,row_footer)
  end do
;-----------------------------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file.

  output_html = "table_fire.html"

  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

  delete (idx)

;**************************************************************************************
; update score
;**************************************************************************************

  M_all  = Mscore1 + Mscore3
  M_fire = sprintf("%.2f", M_all) 

  if (isvar("compare")) then
     system("sed -e '1,/M_fire/s/M_fire/"+M_fire+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_fire#"+M_fire+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)

;***************************************************************************
; get total score and write to file
;***************************************************************************

  asciiwrite("M_save.fire", M_fire)

  delete (M_fire)

;***************************************************************************
; output plot and html
;***************************************************************************
  output_dir = model_name+"/fire"

  system("mv *.png *.html " + dirm + output_dir) 
;***************************************************************************

exit
end

