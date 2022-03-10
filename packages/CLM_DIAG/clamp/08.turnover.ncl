;********************************************************  
; hardwire: flux = flux/1200. (for casa only)
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

;---------------------------------------------------------------
;components

 component = (/"Leaf","Wood","Fine_Root","Litter","Coarse_Woody_Debris","Soil"/)
 n_comp = dimsizes(component)

 field_pool = (/"LEAFC","WOODC","FROOTC","LITTERC","CWDC","SOILC"/)
 field_flux = (/"LEAFC_ALLOC","WOODC_ALLOC","FROOTC_ALLOC","LITTERC_LOSS","CWDC_LOSS","SOILC_HR"/)

; read model data (alternate to Jeff's):

;fm = addfile (dirm+film4,"r")

;temp = fm->LEAFC
;n_temp = dimsizes(temp)

;field_pool = new((/n_comp,n_temp(0),n_temp(1),n_temp(2)/),float)
;field_flux = new((/n_comp,n_temp(0),n_temp(1),n_temp(2)/),float)

;field_pool(0,:,:,:) = fm->LEAFC
;field_flux0a = fm->CPOOL_TO_LEAFC
;field_flux0b = fm->LEAFC_XFER_TO_LEAFC
;field_flux(0,:,:,:) = field_flux0a + field_flux0b
;field_flux(0,:,:,:) = 1

;field_pool1a = fm->LIVESTEMC
;field_pool1b = fm->DEADSTEMC
;field_pool1c = fm->LIVECROOTC
;field_pool1d = fm->DEADCROOTC
;field_pool(1,:,:,:) = field_pool1a + field_pool1b + field_pool1c + field_pool1d
;field_flux1a = fm->CPOOL_TO_LIVESTEMC
;field_flux1b = fm->CPOOL_TO_DEADSTEMC
;field_flux1c = fm->CPOOL_TO_LIVECROOTC
;field_flux1d = fm->CPOOL_TO_DEADCROOTC
;field_flux1e = fm->LIVESTEMC_XFER_TO_LIVESTEMC
;field_flux1f = fm->DEADSTEMC_XFER_TO_DEADSTEMC
;field_flux1g = fm->LIVECROOTC_XFER_TO_LIVECROOTC
;field_flux1h = fm->DEADCROOTC_XFER_TO_DEADCROOTC
;field_flux(1,:,:,:) = field_flux1a + field_flux1b + field_flux1c + field_flux1d + field_flux1e + field_flux1f + field_flux1g + field_flux1h
;field_flux(1,:,:,:) = 1

;field_pool(2,:,:,:) = fm->FROOTC
;field_flux2a = fm->CPOOL_TO_LIVECROOTC
;field_flux2b = fm->CPOOL_TO_DEADCROOTC
;field_flux2c = fm->LIVECROOTC_XFER_TO_LIVECROOTC
;field_flux2d = fm->DEADCROOTC_XFER_TO_DEADCROOTC
;field_flux(2,:,:,:) = field_flux2a + field_flux2b + field_flux2c + field_flux2d
;field_flux(2,:,:,:) = 1

;field_pool3a = fm->LITR1C
;field_pool3b = fm->LITR2C
;field_pool3c = fm->LITR3C
;field_pool(3,:,:,:) = field_pool3a + field_pool3b + field_pool3c
;field_flux(3,:,:,:) = 1

;field_pool(4,:,:,:) = fm->CWDC
;field_flux(4,:,:,:) = 1

;field_pool5a = fm->SOIL1C
;field_pool5b = fm->SOIL2C
;field_pool5c = fm->SOIL3C
;field_pool5d = fm->SOIL4C
;field_pool(5,:,:,:) = field_pool5a + field_pool5b + field_pool5c + field_pool5d
;field_flux(5,:,:,:) = fm->SOMHR
;--------------------------------------------------
; get landfrac data
 
 film_l   = "lnd_"+ model_grid +".nc"
 fm_l     = addfile (dirs+film_l,"r")  
 landfrac = fm_l->landfrac

 delete (fm_l)
;---------------------------------------------------
; read biome data: model

  biome_name_mod = "Model PFT Class"

  film_c   = "class_pft_"+ model_grid +".nc"
  fm_c     = addfile (dirs+film_c,"r") 
  classmod = fm_c->CLASS_PFT

  delete (fm_c)

; model data has 17 land-type classes
  nclass_mod = 17

;********************************************************************
; use land-type class to bin the data in equally spaced ranges
;********************************************************************

; using model biome class
  nclass = nclass_mod

  range  = fspan(0,nclass,nclass+1)

; Use this range information to grab all the values in a
; particular range, and then take an average.

  nx = dimsizes(range) - 1

; for 2 data: pool and flux
  data_n = 2

; using model biome class

  base = ndtooned(classmod)

; output

  yvalues = new((/data_n,nx/),float)
  count   = new((/data_n,nx/),float)

;--------------------------------------------------
; read model data, each component:      

 fm = addfile (dirm+film4,"r")

 do k = 0,n_comp-1

    pool  = fm->$field_pool(k)$
    flux  = fm->$field_flux(k)$
;   pool  = field_pool(k,:,:,:)
;   flux  = field_flux(k,:,:,:)

;   Units for these variables are:
;   pool: g C/m^2
;   flux: g C/m^2/s

    nsec_per_year = 60*60*24*365
  
    flux = flux *  nsec_per_year 

    unit_p = "gC/m2"
    unit_f = "gC/m2/year"
    unit_t = "year"

;#############################################################
;   casa only
;   all the plant pools (leaf, wood, and fine root) and
;   coarse woody debris (cwd) and litter pools for
;   CASA need to be divided by 1200.  The soil flux
;   and turnover time are fine and do not need to be adjusted.

    if (model_name .eq. "casa") then   
       if (k .ne. n_comp-1) then
          flux = flux/1200.
       end if    
    end if
;##############################################################

;   take into account landfrac

    pool = pool * conform(pool,landfrac,(/1,2/))
    flux = flux * conform(flux,landfrac,(/1,2/))

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
           data = ndtooned(pool)
        end if

        if (n .eq. 1) then
           data = ndtooned(flux)
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

  delete (pool)
  delete (flux)

;============================
;compute turnover time
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
 t_biome = new((/n_biome/),float)

 t_biome = uu/vv

 t_biome_avg = sum(uu*uu_count)/sum(vv*vv_count)

;===========================
; for html table - biome
;===========================

  output_html = "table_"+component(k)+".html"

; column (not including header column)

  col_head = (/component(k)+" Flux",component(k)+" Pool",component(k)+" Turnover Time"/)

  ncol = dimsizes(col_head)

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
               ,"All Biome" \                
               /)  
  nrow = dimsizes(row_head)                  

; arrays to be passed to table. 
  text = new ((/nrow, ncol/),string )
 
 do i=0,nrow-2
  text(i,0) = sprintf("%.1f",vv(i))
  text(i,1) = sprintf("%.1f",uu(i))
  text(i,2) = sprintf("%.2f",t_biome(i))
 end do
  text(nrow-1,0) = "-"
  text(nrow-1,1) = "-"
  text(nrow-1,2) = sprintf("%.2f",t_biome_avg)

;**************************************************
; html table
;**************************************************

  header_text = "<H1>"+component(k)+" Turnover Time:  Model "+model_name+"</H1>" 

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
       ,"   <th bgcolor=DDDDDD >Biome Class</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(0)+"<br>("+unit_f+")</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(1)+"<br>("+unit_p+")</th>" \
       ,"   <th bgcolor=DDDDDD >"+col_head(2)+"<br>("+unit_t+")</th>" \
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
; row of table

  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1  = row_head(n)
     txt2  = text(n,0)
     txt3  = text(n,1)
     txt4  = text(n,2)

     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")

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

  delete (good)
  delete (t_biome)
  delete (text)

 end do          ; k-loop

 delete (fm)

;***************************************************************************
; output plot and html
;***************************************************************************
  output_dir = model_name+"/turnover"

  system("mv *.html " + dirm + output_dir) 
;******************************

exit
end

