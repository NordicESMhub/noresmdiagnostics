;********************************************************
; hardwired: co2_i = 283.1878
;            co2_f = 364.1252
;
;            beta_4_ob = 0.6
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

;-------------------------------------------------------
; edit table.html for current model

 html_name = model_name+"/table.html"  
 html_new  = html_name +".new"

;-------------------------------------------------------
; read model data

;###############################################################
; hardwired for model data 

; these values correspond to the start and the end of model data
 co2_i = 283.1878
 co2_f = 364.1252

 film_i = film6
 film_f = film5
;###############################################################

 fm_i   = addfile (dirm+film_i,"r")
 fm_f   = addfile (dirm+film_f,"r")
  
 xm     = fm_f->lon  
 ym     = fm_f->lat

 npp_i  = fm_i->NPP
 npp_f  = fm_f->NPP

 delete (fm_i)
 delete (fm_f)

;Units for these variables are:
;npp_i: g C/m^2/s

 nsec_per_year = 60*60*24*365
  
 npp_i = npp_i *  nsec_per_year
 npp_f = npp_f *  nsec_per_year

 unit = "gC/m2/year"

;------------------------------
; get landfrac data

 film_l   = "lnd_" + model_grid + ".nc"
 fm_l     = addfile (dirs+film_l,"r")  
 landfrac = fm_l->landfrac

 npp_i(0,:,:) = npp_i(0,:,:) * landfrac(:,:)
 npp_f(0,:,:) = npp_f(0,:,:) * landfrac(:,:)

 delete (fm_l)
 delete (landfrac) 

;-----------------------------
; read biome data: model

  biome_name_mod = "Model PFT Class"

  film_c   = "class_pft_"+model_grid+".nc"
  fm_c     = addfile (dirs+film_c,"r") 
  classmod = fm_c->CLASS_PFT               

  delete (fm_c)

; model data has 17 land-type classes
  nclass_mod = 17
   
;---------------------------------------------------
; read data: observed at stations

 station = (/"DukeFACE" \
            ,"AspenFACE" \
            ,"ORNL-FACE" \
            ,"POP-EUROFACE" \
            /)

 lat_ob  = (/ 35.58,  45.40,  35.54, 42.22/)
 lon_ob  = (/-79.05, -89.37, -84.20, 11.48/)
 lon_obx = where(lon_ob.lt.0.,lon_ob+360.,lon_ob)

 n_sta  = dimsizes(station)
 beta_4_ob = new((/n_sta/),float)

;###################################################
; this is a hardwired value
 beta_4_ob = 0.60
;###################################################
;---------------------------------------------------
; get model data at station 

 npp_i_4  =linint2_points(xm,ym,npp_i,True,lon_obx,lat_ob,0)

 npp_f_4  =linint2_points(xm,ym,npp_f,True,lon_obx,lat_ob,0)

;---------------------------------------------------
;compute beta_4

 score_max = 3.

 beta_4 = new((/n_sta/),float)

 beta_4 = ((npp_f_4/npp_i_4) - 1.)/log(co2_f/co2_i)

 beta_4_avg = avg(beta_4)

 bias   = sum(abs(beta_4-beta_4_ob)/(abs(beta_4)+abs(beta_4_ob))) 
 Mbeta  = (1. - (bias/n_sta))*score_max
 M_beta = sprintf("%.2f", Mbeta)

;=========================
; for html table - station
;=========================

  output_html = "table_station.html"

; column (not including header column)

  col_head = (/"Latitude","Longitude","CO2_i","CO2_f","NPP_i","NPP_f","Beta_model","Beta_ob"/)

  ncol = dimsizes(col_head)

; row (not including header row)
  row_head = (/"DukeFACE" \
              ,"AspenFACE" \
              ,"ORNL-FACE" \
              ,"POP-EUROFACE" \
              ,"All Station" \                
              /)  
  nrow = dimsizes(row_head)                  

; arrays to be passed to table. 
  text = new ((/nrow, ncol/),string )

 do i=0,nrow-2
  text(i,0) = sprintf("%.1f",lat_ob(i))
  text(i,1) = sprintf("%.1f",lon_ob(i))
  text(i,2) = sprintf("%.1f",co2_i)
  text(i,3) = sprintf("%.1f",co2_f)
  text(i,4) = sprintf("%.1f",npp_i_4(0,i))
  text(i,5) = sprintf("%.1f",npp_f_4(0,i))
  text(i,6) = sprintf("%.2f",beta_4(i))
  text(i,7) = "-"
 end do
  text(nrow-1,0) = "-"
  text(nrow-1,1) = "-"
  text(nrow-1,2) = "-"
  text(nrow-1,3) = "-"
  text(nrow-1,4) = "-"
  text(nrow-1,5) = "-"
  text(nrow-1,6) = sprintf("%.2f",beta_4_avg)
  text(nrow-1,7) = sprintf("%.2f",avg(beta_4_ob))

;-----------
; html table
;-----------

  header_text = "<H1>Beta Factor: Model "+model_name+"</H1>" 

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,header_text \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=80%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Station</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(0)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(1)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(2)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(3)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(4)+"<br>("+unit+")</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(5)+"<br>("+unit+")</th>" \
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
;-----------------------------------------------
;row of table

  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1 = row_head(n)
     txt2 = text(n,0)
     txt3 = text(n,1)
     txt4 = text(n,2)
     txt5 = text(n,3)
     txt6 = text(n,4)
     txt7 = text(n,5)
     txt8 = text(n,6)
     txt9 = text(n,7)

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
  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

  delete (col_head)
  delete (row_head)
  delete (text)
  delete (table_header)
  delete (idx)

;********************************************************************
; use land-type class to bin the data in equally spaced ranges
;********************************************************************

; using model biome class
  nclass = nclass_mod

  range  = fspan(0,nclass,nclass+1)

; Use this range information to grab all the values in a
; particular range, and then take an average.

  nx = dimsizes(range) - 1

;==============================
; put data into bins
;==============================

; for model data and observed
  data_n = 2

; using model biome class

  base = ndtooned(classmod)

; output

  yvalues = new((/data_n,nx/),float)
  count   = new((/data_n,nx/),float)

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
           data = ndtooned(npp_i)
        end if

        if (n .eq. 1) then
           data = ndtooned(npp_f)
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

  delete (base)
  delete (npp_i)
  delete (npp_f)

;============================
;compute beta
;============================

 u       = yvalues(0,:)
 v       = yvalues(1,:)
 u_count = count(0,:)
 v_count = count(1,:)

 good = ind(.not.ismissing(u) .and. .not.ismissing(v))

 uu       = u(good)
 vv       = v(good)
 uu_count = u_count(good)
 vv_count = v_count(good) 

 n_biome = dimsizes(uu)
 beta_biome = new((/n_biome/),float)

 beta_biome = ((vv/uu) - 1.)/log(co2_f/co2_i)

 beta_biome_avg = (sum(vv*vv_count)/sum(uu*uu_count) - 1.)/log(co2_f/co2_i)

;===========================
; for html table - biome
;===========================

  output_html = "table_biome.html"

; column (not including header column)

  col_head = (/"CO2_i","CO2_f","NPP_i","NPP_f","Beta_model"/)

  ncol = dimsizes(col_head)

; row (not including header row)

;----------------------------------------------------
; using model biome class:
;  
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
  text(i,0) = sprintf("%.1f",co2_i)
  text(i,1) = sprintf("%.1f",co2_f)
  text(i,2) = sprintf("%.1f",uu(i))
  text(i,3) = sprintf("%.1f",vv(i))
  text(i,4) = sprintf("%.2f",beta_biome(i))
 end do
  text(nrow-1,0) = "-"
  text(nrow-1,1) = "-"
  text(nrow-1,2) = "-"
  text(nrow-1,3) = "-"
  text(nrow-1,4) = sprintf("%.2f",beta_biome_avg)

;**************************************************
; html table
;**************************************************

  header_text = "<H1>Beta Factor: Model "+model_name+"</H1>" 

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,header_text \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=80%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Biome Class</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(0)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(1)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(2)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(3)+"</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(4)+"</th>" \
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

; Now write to an HTML file

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
  if (isvar("compare")) then
     system("sed -e '1,/M_beta/s/M_beta/"+M_beta+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_beta#"+M_beta+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)

;***************************************************************************
; get total score and write to file
;***************************************************************************
  M_total = Mbeta

  asciiwrite("M_save.beta", M_total)

  delete (M_total)

;***************************************************************************
; output plot and html
;***************************************************************************
  output_dir = model_name+"/beta"

  system("mv *.html " + dirm + output_dir) 
;***************************************************************************
exit
end

