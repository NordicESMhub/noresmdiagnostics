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

;----------------------------------------------------------
; edit current model for movel1_vs_model2

 if (isvar("compare")) then
    html_name2 = compare+"/table.html"  
    html_new2  = html_name2 +".new"
 end if

;----------------------------------------------------------
; edit table.html for current model

 html_name = model_name+"/table.html"  
 html_new  = html_name +".new"

;----------------------------------------------------------
; get biome data: model
  
  biome_name_mod = "Model PFT Class"

  film_c   = "class_pft_"+ model_grid +".nc"
  fm_c     = addfile (dirs+film_c,"r") 
  classmod = fm_c->CLASS_PFT

  delete (fm_c)

; model data has 17 land-type classes
  nclass_mod = 17

;------------------------------------
; get model landfrac and area
 
 film_l   = "lnd_"+ model_grid +".nc"
 fm_l     = addfile (dirs+film_l,"r")  
 landfrac = fm_l->landfrac
 area     = fm_l->area

 delete (fm_l)

; change area from km**2 to m**2
 area = area * 1.e6             

;-------------------------------------
; take into account landfrac

; area = area * landfrac

; delete (landfrac)

;---------------------------------------------------
; read data: model, group 1

 fm      = addfile (dirm+film4,"r")
 
 NPP1    = fm->NPP

 leafc   = fm->LEAFC
 woodc   = fm->WOODC
 frootc  = fm->FROOTC
 VegC    = leafc
 VegC    = leafc + woodc + frootc

 litterc = fm->LITTERC
 cwdc    = fm->CWDC
 LiCwC   = litterc
 LiCwC   = litterc + cwdc

 SoilC   = fm->SOILC

 delete (fm)
;--------------------------------------------------- 
; read data: model, group 2

 fm     = addfile (dirm+film5,"r")

 NPP2   = fm->NPP 
 NEE2   = fm->NEE
 GPP2   = fm->GPP 

 delete (fm)
;---------------------------------------------------
; Units for these variables are:

;NPP1: g C/m^2/s
;NPP2: g C/m^2/s
;NEE2: g C/m^2/s
;GPP2: g C/m^2/s

;VegC:  g C/m^2
;LiCwC: g C/m^2
;SoilC: g C/m^2

 nsec_per_year = 60*60*24*365

; change unit to g C/m^2/year

 NPP1 = NPP1 *  nsec_per_year * conform(NPP1,landfrac,(/1,2/))
 NPP2 = NPP2 *  nsec_per_year * conform(NPP2,landfrac,(/1,2/))
 NEE2 = NEE2 *  nsec_per_year * conform(NEE2,landfrac,(/1,2/))
 GPP2 = GPP2 *  nsec_per_year * conform(GPP2,landfrac,(/1,2/))

 VegC  = VegC  * conform(VegC,landfrac,(/1,2/))
 LiCwC = LiCwC * conform(LiCwC,landfrac,(/1,2/))
 SoilC = SoilC * conform(SoilC,landfrac,(/1,2/))

 data_n = 8
                
;*******************************************************************
; Calculate "nice" bins for binning the data in equally spaced ranges
;********************************************************************

; using model biome class
  nclass = nclass_mod

  range  = fspan(0,nclass,nclass+1)

; print (range)
; Use this range information to grab all the values in a
; particular range, and then take an average.

  nx     = dimsizes(range) - 1

;==============================
; put data into bins
;==============================

; using observed biome class
; base  = ndtooned(classob)
; using model biome class
  base  = ndtooned(classmod)

  area_1d = ndtooned(area)

; output

  yvalues   = new((/data_n,nx/),float) ; (per m2)
  yvalues_t = new((/data_n,nx/),float) ; (per biome)

; Loop through each range, using base.

  do i=0,nx-1

     if (i.ne.(nx-1)) then
        idx = ind((base.ge.range(i)).and.(base.lt.range(i+1)))        
     else
        idx = ind(base.ge.range(i))
     end if

  do n = 0,data_n-1

     if (n.eq.0) then
        data = ndtooned(area)
     end if

     if (n.eq.1) then
        data = ndtooned(NPP1)
     end if

     if (n.eq.2) then
        data = ndtooned(VegC)
     end if

     if (n.eq.3) then
        data = ndtooned(LiCwC)
     end if

     if (n.eq.4) then
        data = ndtooned(SoilC)
     end if

     if (n.eq.5) then
        data = ndtooned(NPP2)
     end if

     if (n.eq.6) then
        data = ndtooned(NEE2)
     end if

     if (n.eq.7) then
        data = ndtooned(GPP2)
     end if

;    Calculate sum and average
 
     if (.not.any(ismissing(idx))) then
        if (n.eq.0) then 
           yvalues(n,i)   = sum(data(idx))
           yvalues_t(n,i) = sum(data(idx))   
        else 
           yvalues(n,i)   = avg(data(idx))
           yvalues_t(n,i) = sum(data(idx)*area_1d(idx))
        end if
     else
        yvalues(n,i)   = yvalues@_FillValue
        yvalues_t(n,i) = yvalues@_FillValue
     end if

;#############################################################
; using model biome class:
;     set the following 4 classes to _FillValue:
;     (3)Needleleaf Deciduous Boreal Tree,
;     (8)Broadleaf Deciduous Boreal Tree,
;     (9)Broadleaf Evergreen Shrub,
;     (16)Wheat

      if (i.eq.3 .or. i.eq.8 .or. i.eq.9 .or. i.eq.16) then
         yvalues(n,i)   = yvalues@_FillValue
         yvalues_t(n,i) = yvalues@_FillValue
      end if
;#############################################################  

     delete (data)
  end do 

  delete (idx)
  end do

  delete (base)
  delete (area)
  delete (NPP1)
  delete (VegC)
  delete (LiCwC)
  delete (SoilC)
  delete (NPP2)
  delete (NEE2)
  delete (GPP2)

;----------------------------------------------------------------
; data for table1

 good = ind(.not.ismissing(yvalues(5,:)) .and. .not.ismissing(yvalues(1,:)))
;print (good)

 area_g  = yvalues(0,good)
 NPP1_g  = yvalues(1,good)
 VegC_g  = yvalues(2,good)
 LiCwC_g = yvalues(3,good)
 SoilC_g = yvalues(4,good)
 NPP2_g  = yvalues(5,good)
 NEE2_g  = yvalues(6,good)
 GPP2_g  = yvalues(7,good)

 NPP_ratio = NPP2_g/NPP1_g

 n_biome = dimsizes(NPP1_g)

;-----------------------------------------------------------------
; data for table2

; change unit from g to Pg (Peta gram)
 factor_unit = 1.e-15

 NPP1_t  = yvalues_t(1,good) * factor_unit
 VegC_t  = yvalues_t(2,good) * factor_unit
 LiCwC_t = yvalues_t(3,good) * factor_unit 
 SoilC_t = yvalues_t(4,good) * factor_unit
 NEE2_t  = yvalues_t(6,good) * factor_unit
 GPP2_t  = yvalues_t(7,good) * factor_unit

 delete (yvalues)
 delete (yvalues_t)
 
;-------------------------------------------------------------
; html table1 data

; column (not including header column)

  col_head  = (/"Area (1.e12m2)" \
               ,"NPP (gC/m2/yr)" \
               ,"VegC (gC/m2)" \
               ,"Litter+CWD (gC/m2)" \
               ,"SoilC (gC/m2)" \
               ,"NPP_ratio" \
               ,"NEE (gC/m2/yr)" \
               ,"GPP (gC/m2/yr)" \
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
 
 do i=0,nrow-2
  text(i,0) = sprintf("%.1f",area_g(i)*1.e-12)
  text(i,1) = sprintf("%.1f",NPP1_g(i))
  text(i,2) = sprintf("%.1f",VegC_g(i))
  text(i,3) = sprintf("%.1f",LiCwC_g(i))
  text(i,4) = sprintf("%.1f",SoilC_g(i))
  text(i,5) = sprintf("%.2f",NPP_ratio(i))
  text(i,6) = sprintf("%.1f",NEE2_g(i))
  text(i,7) = sprintf("%.1f",GPP2_g(i))
 end do

;-------------------------------------------------------
; create html table1

  header_text = "<H1>NEE and Carbon Stocks and Fluxes:  Model "+model_name+"</H1>" 

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
       ,"   <th bgcolor=DDDDDD >"+col_head(6)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(7)+"</th>" \
       ,"</tr>" \
       /)
  table_footer = "</table>"
  row_header = "<tr>"
  row_footer = "</tr>"

  lines = new(50000,string)
  nline = 0

  set_line(lines,nline,header)
  set_line(lines,nline,table_header)

;----------------------------
;row of table

  do n = 0,nrow-2
     set_line(lines,nline,row_header)

     txt0  = row_head(n)
     txt1  = text(n,0)
     txt2  = text(n,1)
     txt3  = text(n,2)
     txt4  = text(n,3)
     txt5  = text(n,4)
     txt6  = text(n,5)
     txt7  = text(n,6)
     txt8  = text(n,7)

     set_line(lines,nline,"<th>"+txt0+"</th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")
     set_line(lines,nline,"<th>"+txt7+"</th>")
     set_line(lines,nline,"<th>"+txt8+"</th>")

     set_line(lines,nline,row_footer)
  end do
;----------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file.

  output_html = "table_per_m2.html"

  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

  delete (idx)

  delete (col_head)
  delete (row_head)
  delete (text)
  delete (table_header)

;-----------------------------------------------------------------
; html table2 data

; column (not including header column)

  col_head  = (/"NPP (PgC/yr)" \
               ,"VegC (PgC)" \
               ,"Litter+CWD (PgC)" \
               ,"SoilC (PgC)" \
               ,"NEE (PgC/yr)" \
               ,"GPP (PgC/yr)" \
               ,"NPP timeseries" \
               ,"NEE timeseries" \
               ,"Fire timeseries" \
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
 
 do i=0,nrow-2
  text(i,0) = sprintf("%.1f",NPP1_t(i))
  text(i,1) = sprintf("%.1f",VegC_t(i))
  text(i,2) = sprintf("%.1f",LiCwC_t(i))
  text(i,3) = sprintf("%.1f",SoilC_t(i))
  text(i,4) = sprintf("%.1f",NEE2_t(i))
  text(i,5) = sprintf("%.1f",GPP2_t(i))
  text(i,6) = "<a href=./NPP_monthly_biome_"+i+".png>monthly_plot</a> <br> <a href=./NPP_annual_biome_"+i+".png>annual_plot</a>"
  text(i,7) = "<a href=./NEE_monthly_biome_"+i+".png>monthly_plot</a> <br> <a href=./NEE_annual_biome_"+i+".png>annual_plot</a>"
  text(i,8) = "--"
 end do

  text(nrow-1,0) = sprintf("%.1f",sum(NPP1_t))
  text(nrow-1,1) = sprintf("%.1f",sum(VegC_t))
  text(nrow-1,2) = sprintf("%.1f",sum(LiCwC_t))
  text(nrow-1,3) = sprintf("%.1f",sum(SoilC_t))
  text(nrow-1,4) = sprintf("%.1f",sum(NEE2_t))
  text(nrow-1,5) = sprintf("%.1f",sum(GPP2_t))
  text(nrow-1,6) = "<a href=./NPP_monthly_global.png>monthly_plot</a> <br> <a href=./NPP_annual_global.png>annual_plot</a>"
  text(nrow-1,7) = "<a href=./NEE_monthly_global.png>monthly_plot</a> <br> <a href=./NEE_annual_global.png>annual_plot</a>"
  text(nrow-1,8) = "--"

;**************************************************
; create html table2
;**************************************************

  header_text = "<H1>NEE and Carbon Stocks and Fluxes (per biome):  Model "+model_name+"</H1>" 

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
       ,"   <th bgcolor=DDDDDD >"+col_head(6)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(7)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(8)+"</th>" \
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
     txt7  = text(n,6)
     txt8  = text(n,7)
     txt9  = text(n,8)

     set_line(lines,nline,"<th>"+txt0+"</th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")
     set_line(lines,nline,"<th>"+txt7+"</th>")
     set_line(lines,nline,"<th>"+txt8+"</th>")
     set_line(lines,nline,"<th>"+txt9+"</th>")

     set_line(lines,nline,row_footer)
  end do
;-----------------------------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file.

  output_html = "table_per_biome.html"

  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

  delete (idx)

;---------------------------------------------------
; read model data, time series:

 fm   = addfile (dirm+film7,"r")

 NPP3 = fm->NPP 
 NEE3 = fm->NEE 
;Fire = fm->COL_FIRE_CLOSS

 delete (fm)

; Units for these variables are:

;NPP3: g C/m^2/s
;NEE3: g C/m^2/s
;Fire: g C/m^2/s

 nsec_per_month = 60*60*24*30

; change unit to g C/m^2/month
  
 NPP3 = NPP3 * nsec_per_month * conform(NPP3,landfrac,(/2,3/))
 NEE3 = NEE3 * nsec_per_month * conform(NEE3,landfrac,(/2,3/))
;Fire = Fire * nsec_per_month * conform(Fire,landfrac,(/2,3/))

;data_n = 3
 data_n = 2

 dsizes = dimsizes(NPP3)
 nyear  = dsizes(0)
 nmonth = dsizes(1)
 ntime  = nyear * nmonth

 year_start = 1979
 year_end   = 2004
                
;*******************************************************************
; Calculate "nice" bins for binning the data in equally spaced ranges
;********************************************************************

; using model biome class
  nclass = nclass_mod

  range  = fspan(0,nclass,nclass+1)

; print (range)
; Use this range information to grab all the values in a
; particular range, and then take an average.

  nx = dimsizes(range) - 1

;==============================
; put data into bins
;==============================

; using observed biome class
; base  = ndtooned(classob)
; using model biome class
  base  = ndtooned(classmod)

; output

  yvalues = new((/ntime,data_n,nx/),float)

; Loop through each range, using base.

  do i=0,nx-1

     if (i.ne.(nx-1)) then
        idx = ind((base.ge.range(i)).and.(base.lt.range(i+1)))
     else
        idx = ind(base.ge.range(i))
     end if

  do n = 0,data_n-1

     t = -1
     do m = 0,nyear-1
     do k = 0,nmonth-1
    
        t = t + 1 

        if (n.eq.0) then
           data = ndtooned(NPP3(m,k,:,:))
        end if

        if (n.eq.1) then
           data = ndtooned(NEE3(m,k,:,:))
        end if

;       if (n.eq.2) then
;          data = ndtooned(Fire(m,k,:,:))
;       end if

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
  delete (NPP3)
  delete (NEE3)
; delete (Fire)

;----------------------------------------------------------------
; data for tseries plot

  yvalues_g = new((/ntime,data_n,n_biome/),float)

  yvalues_g@units = "TgC/month"

; change unit to Tg C/month
; change unit from g to Tg (Tera gram)
  factor_unit = 1.e-12

  yvalues_g = yvalues(:,:,good) * factor_unit

;*******************************************************************
; general settings for line plot
;*******************************************************************

; res
  res                   = True               
  res@xyDashPatterns    = (/0/)                ; make lines solid
  res@xyLineThicknesses = (/2.0/)          ; make lines thicker
  res@xyLineColors      = (/"blue"/) ; line color

  res@trXMinF   = year_start
  res@trXMaxF   = year_end + 1

  res@vpHeightF = 0.4                 ; change aspect ratio of plot
; res@vpWidthF  = 0.8
  res@vpWidthF  = 0.75   

; res@gsnMaximize = True

;*******************************************************************
; (A) 1 component in each biome: monthly
;*******************************************************************

; component = (/"NPP","NEE","Fire"/)
  component = (/"NPP","NEE"/)

; for x-axis in xyplot

  timeI = new((/ntime/),integer)
  timeF = new((/ntime/),float)
  timeI = ispan(1,ntime,1)
  timeF = year_start + (timeI-1)/12.
  timeF@long_name = "year" 

  plot_data = new((/ntime/),float)
  plot_data@long_name = "TgC/month"
 
  do n = 0, data_n-1
  do m = 0, n_biome-1

     plot_name = component(n)+"_monthly_biome_"+ m

     wks = gsn_open_wks (plot_type,plot_name)   

     title = component(n)+ ": "+ row_head(m)
     res@tiMainString = title
     res@tiMainFontHeightF = 0.025

     plot_data(:) = yvalues_g(:,n,m)
                                 
     plot=gsn_csm_xy(wks,timeF,plot_data,res)

     delete (wks)  
     delete (plot)
 
    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)  
  end do
  end do

  do n = 0, data_n-1

     plot_name = component(n)+"_monthly_global"

     wks = gsn_open_wks (plot_type,plot_name)   

     title = component(n)+ ": Global"
     res@tiMainString = title
     res@tiMainFontHeightF = 0.025
 
     do k = 0,ntime-1
        plot_data(k) = sum(yvalues_g(k,n,:))
     end do
                                 
     plot=gsn_csm_xy(wks,timeF,plot_data,res)

     delete (wks)  
     delete (plot)
 
    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)   
  end do

  delete (plot_data)
  delete (timeI)
  delete (timeF)

;*******************************************************************
; (B) 1 component in each biome: annually
;*******************************************************************

  yvalues_a = new((/nyear,data_n,n_biome/),float)
  yvalues_g!0 = "time"
  yvalues_g!1 = "case"
  yvalues_g!2 = "record"

  yvalues_a = month_to_annual(yvalues_g,0)

  delete (yvalues_g) 

; for x-axis in xyplot

  timeI = new((/nyear/),integer)
  timeF = new((/nyear/),float)
  timeI = ispan(1,nyear,1)
  timeF = year_start + (timeI-1)
  timeF@long_name = "year" 

  plot_data = new((/nyear/),float)
  plot_data@long_name = "TgC/year"
 
  do n = 0, data_n-1
  do m = 0, n_biome-1

     plot_name = component(n)+"_annual_biome_"+ m

     wks = gsn_open_wks (plot_type,plot_name)   

     title = component(n)+ ": "+ row_head(m)
     res@tiMainString = title
     res@tiMainFontHeightF = 0.025

     plot_data(:) = yvalues_a(:,n,m)
                                 
     plot=gsn_csm_xy(wks,timeF,plot_data,res)

     delete (wks)  
     delete (plot)
 
    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)   
  end do
  end do

  do n = 0, data_n-1

     plot_name = component(n)+"_annual_global"

     wks = gsn_open_wks (plot_type,plot_name)   

     title = component(n)+ ": Global"
     res@tiMainString = title
     res@tiMainFontHeightF = 0.025
 
     do k = 0,nyear-1
        plot_data(k) = sum(yvalues_a(k,n,:))
     end do
                                 
     plot=gsn_csm_xy(wks,timeF,plot_data,res)

     delete (wks)  
     delete (plot)
 
    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)   
  end do

;****************************************
; output plot and html
;****************************************
  output_dir = model_name+"/carbon_sink"

  system("mv *.png *.html " + dirm + output_dir) 
;****************************************

exit
end

