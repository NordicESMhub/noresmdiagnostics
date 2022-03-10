;************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************************
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
;*************************************************************
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

  nmonth = 12

; for nee, gpp, and ar
; observed unit is gC/m2/day
; model    unit is gC/m2/s
; to change to observed unit,

  factor_flux = 86400.
  
; for incident solar radiation,
; observed Rg_f unit is MJ/m2/day
; model (FSDS)  unit is  W/m2
; to change to model unit,

  factor_rad = 1.e6/86400.

;************************************************
; observed data info
;************************************************

 station = (/"ARM_Oklahoma" \
            ,"ARM_Oklahoma_burn" \
            ,"ARM_Oklahoma_control" \
            ,"Atqasuk" \
            ,"Audubon" \
            ,"AustinCary" \
            ,"Bartlett" \
            ,"Bondville" \
            ,"Brookings" \
            ,"Donaldson" \
            ,"Duke_Forest_Hardwoods" \
            ,"Duke_Forest_Open_Field" \
            ,"Duke_Forest_Pine" \
            ,"Fermi_Ag" \
            ,"Fermi_Prairie" \
            ,"Flagstaff_Managed" \
            ,"Flagstaff_Unmanaged" \
            ,"Flagstaff_Wildfire" \
            ,"FortPeck" \
            ,"FreemanRanch_mesquite" \
            ,"Goodwin_Creek" \
            ,"HarvardForest" \
            ,"HarvardForestHemlock" \
            ,"HowlandForestMain" \
            ,"HowlandForestWest" \
            ,"Ivotuk" \
            ,"KendallGrasslands" \
            ,"KennedySpaceCenterPine" \
            ,"KennedySpaceCenterScrub" \
            ,"LittleProspect" \
            ,"LostCreek" \
            ,"Mead-irrigated" \
            ,"Mead-irrigated-rotation" \
            ,"Mead-rainfed" \
            ,"Metolius_2nd_YoungPonderosaPine" \
            ,"MetoliusEyerly" \
            ,"MetoliusIntermediatePine" \
            ,"MetoliusOldPonderosaPine" \
            ,"MissouriOzark" \
            ,"Mize" \
            ,"MorganMonroe" \
            ,"NiwotRidge" \
            ,"NorthCarolina_cc" \
            ,"NorthCarolina_lp" \
            ,"ParkFalls" \
            ,"Rayonier" \
            ,"SantaRita" \
            ,"SkyOaks_Old" \
            ,"SkyOaks_PostFire" \
            ,"SkyOaks_Young" \
            ,"SylvaniaWilderness" \
            ,"Toledo" \
            ,"Tonzi" \
            ,"UCI_1850" \
            ,"UCI_1930" \
            ,"UCI_1964" \
            ,"UCI_1964wet" \
            ,"UCI_1981" \
            ,"UCI_1989" \
            ,"UCI_1998" \
            ,"UMBS" \
            ,"Vaira" \
            ,"WalkerBranch" \
            ,"WillowCreek" \
            ,"WindRiver" \
            ,"Wisconsin_ihw" \
            ,"Wisconsin_irp" \
            ,"Wisconsin_mrp" \
            ,"Wisconsin_myjp" \
            ,"Wisconsin_pb" \
            ,"Wisconsin_rpcc" \
            ,"Wisconsin_yhw" \
            ,"Wisconsin_yjp" \
            ,"Wisconsin_yrp" \
            /)

 field   = (/"NEE Flux" \
            ,"Shortwave Incoming" \
            ,"Latent Heat" \
            ,"Sensible Heat" \
            ,"GPP Flux" \
            ,"Respiration" \
            /)

 field_unit = (/"gC/m2/day" \
               ,"W/m2" \
               ,"W/m2" \
               ,"W/m2" \
               ,"gC/m2/day" \
               ,"gC/m2/day" \
               /)

 nstation = dimsizes(station)
 nfield   = dimsizes(field)

;========================================================================
; get observed info: number of year, first/last year, lat, lon
; and annual data

 dir_root = diro + "ameriflux/"

 year_station = new ((/nstation/),integer) ; number of year
 year_ob      = new ((/nstation/),string)  ; observed year
 year_ob_i    = new ((/nstation/),integer) ; first year
 year_ob_f    = new ((/nstation/),integer) ; last year
 lat_ob       = new ((/nstation/),float)   ; latitude
 lon_ob       = new ((/nstation/),float)   ; longitude 

 data_ob_ann  = new ((/nfield, nmonth, nstation/),float)

 do n = 0, nstation-1

    dir_f = dir_root + station(n)+"/"
    fil_f = "timeseries_L4_m.nc"
    print ("Station: " + station(n))
    fo   = addfile (dir_f+fil_f,"r")
 
    lat_ob(n) = fo->lat
    lon_ob(n) = fo->lon

    year      = fo->year

    year_station(n) = dimsizes(year)
    year_ob_i(n)    = year(0)
    year_ob_f(n)    = year(year_station(n)-1)
    year_ob(n)      = year_ob_i(n) + "-" + year_ob_f(n)
 
    delete (year)
 
    data = fo->NEE_or_fMDS
    data_ob_ann(0,:,n) = dim_avg(data(month|:,year|:))

    data = fo->Rg_f
    data_ob_ann(1,:,n) = dim_avg(data(month|:,year|:)) * factor_rad

    data = fo->LE_f
    data_ob_ann(2,:,n) = dim_avg(data(month|:,year|:))

    data = fo->H_f
    data_ob_ann(3,:,n) = dim_avg(data(month|:,year|:))

    data = fo->GPP_or_MDS
    data_ob_ann(4,:,n) = dim_avg(data(month|:,year|:))

    data = fo->Reco_or
    data_ob_ann(5,:,n) = dim_avg(data(month|:,year|:))

    delete (data) 
    delete (fo)   
 end do

;--------------------------------------------------------------
; find (# of year observed) >=4 and year_ob_i <= 2001

 i_long_ob = ind(year_station .ge. 4 .and. year_ob_i .le. 2001)
 
 station_long      = station(i_long_ob)
 lat_ob_long       = lat_ob(i_long_ob)
 lon_ob_long       = lat_ob(i_long_ob)
 year_ob_long      = year_ob(i_long_ob)
 year_ob_i_long    = year_ob_i(i_long_ob)
 year_ob_f_long    = year_ob_f(i_long_ob)
 year_station_long = year_station(i_long_ob)

 nstation_long     = dimsizes(station_long)

;=========================================================
;   get model data at observed lat-lon

    fm   = addfile (dirm+film8,"r")

    xm   = fm->lon
    ym   = fm->lat 
    date = fm->date

    date_dim = dimsizes(date)
    nyear  = date_dim(0)

    data_mod      = new ((/nfield,nyear,nmonth,nstation/),float)
    data_mod_ann  = new ((/nfield,nmonth,nstation/),float)
    data_mod_long = new ((/nfield,nyear,nmonth,nstation_long/),float)

;   change to unit of observed (u mol/m2/s)
;   Model_units [=] gC/m2/s
;   12. = molecular weight of C
;   u mol = 1e-6 mol

    factor = 1.e6 /12.

;------------------------------------------------------------
;   interpolate model data into observed station
;   note: model is 0-360E, 90S-90N

;   to be able to handle observation at (-89.98,-24.80)
    ym(0) = -90.
;------------------------------------------------------------  

if (ENERGY .eq. "old") then

  data = fm->NEE
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(0,:,:)= dim_avg(yy(month|:,pts|:,year|:)) * factor_flux
  data_mod(0,:,:,:) = yy(:,:,:) * factor_flux

;;data  = fm->NETRAD
; data  = fm->FSA
; data1 = fm->FIRA
; data  = data - data1
; delete (data1)

  data  = fm->FSDS
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(1,:,:)= dim_avg(yy(month|:,pts|:,year|:))
  data_mod(1,:,:,:) = yy(:,:,:)  


; data  = fm->LATENT
  data  = fm->FCEV
  data1 = fm->FCTR
  data2 = fm->FGEV
  data  = data + data1 + data2
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(2,:,:)= dim_avg(yy(month|:,pts|:,year|:))
  data_mod(2,:,:,:) = yy(:,:,:) 
  delete (data1)
  delete (data2)
 
; data = fm->SENSIBLE
  data  = fm->FSH
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(3,:,:)= dim_avg(yy(month|:,pts|:,year|:)) 
  data_mod(3,:,:,:) = yy(:,:,:)  

else

  data = fm->NEE
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(0,:,:)= dim_avg(yy(month|:,pts|:,year|:)) * factor_flux
  data_mod(0,:,:,:) = yy(:,:,:) * factor_flux

; data = fm->NETRAD
  data = fm->FSDS
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(1,:,:)= dim_avg(yy(month|:,pts|:,year|:)) 
  data_mod(1,:,:,:) = yy(:,:,:) 

  data = fm->LATENT
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(2,:,:)= dim_avg(yy(month|:,pts|:,year|:)) 
  data_mod(2,:,:,:) = yy(:,:,:) 

; data = fm->SENSIBLE
  data = fm->FSH
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(3,:,:)= dim_avg(yy(month|:,pts|:,year|:)) 
  data_mod(3,:,:,:) = yy(:,:,:) 

end if

  data = fm->GPP
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(4,:,:)= dim_avg(yy(month|:,pts|:,year|:)) * factor_flux
  data_mod(4,:,:,:) = yy(:,:,:) * factor_flux 

  data = fm->ER
  yy = linint2_points_Wrap(xm,ym,data,True,lon_ob,lat_ob,0)
  data_mod_ann(5,:,:)= dim_avg(yy(month|:,pts|:,year|:)) * factor_flux
  data_mod(5,:,:,:) = yy(:,:,:) * factor_flux

  data_mod_long(:,:,:,:) = data_mod(:,:,:,i_long_ob)

  delete (data_mod)
  delete (fm) 
  delete (data)
  delete (yy)

;*******************************************************************
; for station line plot
;*******************************************************************

; for x-axis in xyplot
  mon = ispan(1,12,1)
  mon@long_name = "month"

  res                   = True               ; plot mods desired
  res@xyLineThicknesses = (/2.0,2.0/)        ; make 2nd lines thicker
  res@xyLineColors      = (/"blue","red"/)   ; line color (ob,model)

  res@tmXBFormat  = "f"                      ; not to add trailing zeros

;-------------------------------------------------------------------------
; Add a boxed legend using the more simple method

  res@pmLegendDisplayMode    = "Always"
; res@pmLegendWidthF         = 0.1
  res@pmLegendWidthF         = 0.08
  res@pmLegendHeightF        = 0.06
; res@pmLegendOrthogonalPosF = -1.17
; res@pmLegendOrthogonalPosF = -1.00  ;(downward)
  res@pmLegendOrthogonalPosF = -0.30  ;(downward)

; res@pmLegendParallelPosF   =  0.18
  res@pmLegendParallelPosF   =  0.23  ;(rightward)

; res@lgPerimOn             = False
  res@lgLabelFontHeightF     = 0.015
  res@xyExplicitLegendLabels = (/"observed",model_name/)
;-------------------------------------------------------------------
; for panel plot
  res@gsnFrame     = False                   ; Do not draw plot 
  res@gsnDraw      = False                   ; Do not advance frame

  pres                            = True     ; panel plot mods desired
  pres@gsnPanelYWhiteSpacePercent = 5        ; increase white space around
                                             ; indiv. plots in panel
  pres@gsnMaximize                = True     ; fill the page
;-------------------------------------------------------------------

;==============================================================
; get ob data at each site with long observation

  do n = 0,nstation_long-1

;##################################################################
; hardwired: model    up to year 2004
;            observed up to year 2006

    year_setback = 0

    nyear = year_station_long(n)

    if (year_ob_f_long(n).eq. 2006) then
       year_setback = 2006 -2004
    end if
    if (year_ob_f_long(n).eq. 2005) then
       year_setback = 2005 -2004
    end if
;##################################################################
    
    ntime = (nyear - year_setback) * nmonth

    data_ob   = new ((/nfield, nyear, nmonth/),float)

    dir_f = dir_root + station_long(n)+"/"
    fil_f = "timeseries_L4_m.nc"
    fo    = addfile (dir_f+fil_f,"r")

    data_ob(0,:,:) = fo->NEE_or_fMDS
    data_ob(1,:,:) = fo->Rg_f
    data_ob(2,:,:) = fo->LE_f
    data_ob(3,:,:) = fo->H_f
    data_ob(4,:,:) = fo->GPP_or_MDS
    data_ob(5,:,:) = fo->Reco_or

    data_ob(1,:,:) = data_ob(1,:,:) * factor_rad

    delete (fo)

    timeI = new((/ntime/),integer)
    timeF = new((/ntime/),float)
    timeI = ispan(1,ntime,1)
    timeF = year_ob_i_long(n) + (timeI-1)/12.
    timeF@long_name = "year" 

    plot_data = new((/2,ntime/),float)
 
;----------------------------
; for model_vs_ob

    plot_name = station_long(n)+"_tseries_vs_ob"
    title = station_long(n)+"("+sprintf("%5.2f",lat_ob_long(n))+","+sprintf("%5.2f",lon_ob_long(n))+")"    
    res@tiMainString = title

    wks = gsn_open_wks (plot_type,plot_name)
    plot=new(nfield,graphic)                         ; create graphic array   

    i_year_mod_i = year_ob_i_long(n) - 1990 
    i_year_mod_f = i_year_mod_i + nyear - 1 - year_setback

    i_year_ob_f =  nyear - year_setback - 1 

;   print (nyear)
;   print (i_year_ob_f)
;   print (i_year_mod_i)
;   print (i_year_mod_f)

    do i = 0,nfield-1                           
       plot_data(0,:) = ndtooned(data_ob (i,0:i_year_ob_f,:))
       plot_data(1,:) = ndtooned(data_mod_long(i,i_year_mod_i:i_year_mod_f,:,n))
       plot_data@long_name = field(i)+" ("+field_unit(i)+")"   
       plot(i)=gsn_csm_xy(wks,timeF,plot_data,res)            ; create plot 
    end do
   
    gsn_panel(wks,plot,(/3,2/),pres)                    ; create panel plot

    delete (wks)  
    delete (plot)

    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)

    delete (data_ob)
    delete (timeI)    
    delete (timeF)
    delete (plot_data)

 end do

;###################################################################
; for the following tables,
; sort by latitude in decending order (N->S)

  isort = dim_pqsort(lat_ob_long,-1)

  station_sort = station_long(isort)
  year_ob_sort = year_ob_long(isort)
  lat_ob_sort  = lat_ob_long(isort)
  lon_ob_sort  = lon_ob_long(isort)
 
; print(isort)
; print(lat_ob_sort)

;*******************************************************************
; html table of site: observed
;*******************************************************************
  output_html = "tseries_vs_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>Timeseries at Site: "+model_name+" vs Observation</H1>" \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=60%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Site Name</th>" \
       ,"   <th bgcolor=DDDDDD >Latitude</th>" \
       ,"   <th bgcolor=DDDDDD >Longitude</th>" \
       ,"   <th bgcolor=DDDDDD >Observed</th>" \ 
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
  
  do n = 0,nstation_long-1

     set_line(lines,nline,row_header)

     txt0 = station_sort(n)
     txt1 = sprintf("%5.2f", lat_ob_sort(n))
     txt2 = sprintf("%5.2f", lon_ob_sort(n))
     txt3 = year_ob_sort(n)

     set_line(lines,nline,"<th><a href="+txt0+"_tseries_vs_ob.png>"+txt0+"</a></th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")

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
  delete (idx)

  delete (isort)
  delete (station_sort)
  delete (year_ob_sort)
  delete (lat_ob_sort)
  delete (lon_ob_sort)

;************************************************************
; compute annual cycle correlation coef and M score
;************************************************************

 score_max = 1.

 ccr     = new ((/nstation, nfield/),float)
 M_score = new ((/nstation, nfield/),float) 

 do n=0,nstation-1
 do m=0,nfield-1   
    ccr(n,m) = esccr(data_ob_ann(m,:,n),data_mod_ann(m,:,n),0)
    bias = sum(abs(data_mod_ann(m,:,n)-data_ob_ann(m,:,n))/(abs(data_mod_ann(m,:,n))+abs(data_ob_ann(m,:,n))))
    M_score(n,m) = (1. -(bias/nmonth)) * score_max
 end do
 end do

 M_nee = avg(M_score(:,0))
 M_rad = avg(M_score(:,1))
 M_lh  = avg(M_score(:,2))
 M_sh  = avg(M_score(:,3))
 M_gpp = avg(M_score(:,4))
 M_er  = avg(M_score(:,5))
 M_all = M_nee+ M_rad +M_lh + M_sh + M_gpp + M_er

 M_ameriflux_nee = sprintf("%.2f", M_nee)
 M_ameriflux_rad = sprintf("%.2f", M_rad)
 M_ameriflux_lh  = sprintf("%.2f", M_lh )
 M_ameriflux_sh  = sprintf("%.2f", M_sh )
 M_ameriflux_gpp = sprintf("%.2f", M_gpp)
 M_ameriflux_er  = sprintf("%.2f", M_er )
 M_ameriflux_all = sprintf("%.2f", M_all)

;*******************************************************************
; for station line plot
;*******************************************************************

; for x-axis in xyplot
  mon = ispan(1,12,1)
  mon@long_name = "month"

;-------------------------------------------------------------------

  plot_data   = new((/2,nmonth/),float)
  plot_data!0 = "case"
  plot_data!1 = "month"

  do n = 0,nstation-1
;----------------------------
; for observed

    plot_name = station(n)+"_ob"    
    title = station(n)+"("+sprintf("%5.2f",lat_ob(n))+","+sprintf("%5.2f",lon_ob(n))+")"
    res@tiMainString = title

    wks = gsn_open_wks (plot_type,plot_name)
    plot=new(nfield,graphic)                        ; create graphic array   

    do i = 0,nfield-1                           
       plot_data(0,:) = (/data_ob_ann(i,:,n)/)
       plot_data@long_name = field(i)+" ("+field_unit(i)+")"   
       plot(i)=gsn_csm_xy(wks,mon,plot_data(0,:),res)    ; create plot 
    end do

    gsn_panel(wks,plot,(/3,2/),pres)                 ; create panel plot

    delete (wks)  
    delete (plot)

    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)

;----------------------------
; for model_vs_ob

    plot_name = station(n)+"_model_vs_ob"
    title = station(n)+"("+sprintf("%5.2f",lat_ob(n))+","+sprintf("%5.2f",lon_ob(n))+")"    
    res@tiMainString = title

    wks = gsn_open_wks (plot_type,plot_name)
    plot=new(nfield,graphic)                         ; create graphic array   

    do i = 0,nfield-1                           
       plot_data(0,:) = (/data_ob_ann(i,:,n)/)
       plot_data(1,:) = (/data_mod_ann(i,:,n)/)
       plot_data@long_name = field(i)+" ("+field_unit(i)+")"   
       plot(i)=gsn_csm_xy(wks,mon,plot_data,res)     ; create plot 
    end do
   
    gsn_panel(wks,plot,(/3,2/),pres)                 ; create panel plot

    delete (wks)  
    delete (plot)

    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)
 end do

;###################################################################
; for the following tables,
; sort by latitude in decending order (N->S)
; sort by lat in decending order (N->S)

  isort = dim_pqsort(lat_ob,-1)

  station_sort = station(isort)
  year_ob_sort = year_ob(isort)
  lat_ob_sort  = lat_ob(isort)
  lon_ob_sort  = lon_ob(isort)
  M_score_sort = M_score(isort,:)
 
; print(isort)
; print(lat_ob_sort)
;###################################################################
;*******************************************************************
; html table of site: observed
;*******************************************************************
  output_html = "line_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>Energy at Site: Observation</H1>" \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=60%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Site Name</th>" \
       ,"   <th bgcolor=DDDDDD >Latitude</th>" \
       ,"   <th bgcolor=DDDDDD >Longitude</th>" \
       ,"   <th bgcolor=DDDDDD >Observed</th>" \ 
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
  
  do n = 0,nstation-1
     set_line(lines,nline,row_header)

     txt0 = station_sort(n)
     txt1 = sprintf("%5.2f", lat_ob_sort(n))
     txt2 = sprintf("%5.2f", lon_ob_sort(n))
     txt3 = year_ob_sort(n)

     set_line(lines,nline,"<th><a href="+txt0+"_ob.png>"+txt0+"</a></th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")

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
  delete (idx)

;*******************************************************************
; score and line table : model vs observed
;*******************************************************************
  output_html = "score+line_vs_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>Energy at Site: Model "+model_name+"</H1>" \
            /) 
  footer = "</HTML>"

  delete (table_header)
  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=100%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Site Name</th>" \
       ,"   <th bgcolor=DDDDDD >Latitude</th>" \
       ,"   <th bgcolor=DDDDDD >Longitude</th>" \
       ,"   <th bgcolor=DDDDDD >Observed</th>" \
       ,"   <th bgcolor=DDDDDD >NEE Flux</th>" \
       ,"   <th bgcolor=DDDDDD >Shortwave <br> Incoming</th>" \
       ,"   <th bgcolor=DDDDDD >Latent Heat</th>" \
       ,"   <th bgcolor=DDDDDD >Sensible Heat</th>" \
       ,"   <th bgcolor=DDDDDD >GPP Flux</th>" \
       ,"   <th bgcolor=DDDDDD >Respiration</th>" \
       ,"   <th bgcolor=DDDDDD >Average</th>" \
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
  
  do n = 0,nstation-1
     set_line(lines,nline,row_header)

     txt0  = station_sort(n)
     txt1  = sprintf("%5.2f", lat_ob_sort(n))
     txt2  = sprintf("%5.2f", lon_ob_sort(n))
     txt3  = year_ob_sort(n)
     txt4  = sprintf("%5.2f", M_score_sort(n,0))
     txt5  = sprintf("%5.2f", M_score_sort(n,1))
     txt6  = sprintf("%5.2f", M_score_sort(n,2))
     txt7  = sprintf("%5.2f", M_score_sort(n,3))
     txt8  = sprintf("%5.2f", M_score_sort(n,4))
     txt9  = sprintf("%5.2f", M_score_sort(n,5))
     txt10 = sprintf("%5.2f", avg(M_score_sort(n,:)))

     set_line(lines,nline,"<th><a href="+txt0+"_model_vs_ob.png>"+txt0+"</a></th>")
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

; last row, summary
  set_line(lines,nline,row_header)

  txt0  = "All_"+sprintf("%.0f", nstation)
  txt1  = "-"
  txt2  = "-"
  txt3  = "-"
  txt4  = M_ameriflux_nee
  txt5  = M_ameriflux_rad
  txt6  = M_ameriflux_lh
  txt7  = M_ameriflux_sh
  txt8  = M_ameriflux_gpp
  txt9  = M_ameriflux_er
  txt10 = M_ameriflux_all

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
  set_line(lines,nline,"<th>"+txt10+"</th>")

  set_line(lines,nline,row_footer)
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
  delete (idx)

;**************************************************************************************
; update score
;**************************************************************************************
 
  if (isvar("compare")) then
     system("sed -e '1,/M_ameriflux_nee/s/M_ameriflux_nee/"+M_ameriflux_nee+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_ameriflux_rad/s/M_ameriflux_rad/"+M_ameriflux_rad+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_ameriflux_lh/s/M_ameriflux_lh/"+M_ameriflux_lh+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_ameriflux_sh/s/M_ameriflux_sh/"+M_ameriflux_sh+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_ameriflux_gpp/s/M_ameriflux_gpp/"+M_ameriflux_gpp+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_ameriflux_er/s/M_ameriflux_er/"+M_ameriflux_er+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_ameriflux_nee#"+M_ameriflux_nee+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_ameriflux_rad#"+M_ameriflux_rad+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_ameriflux_lh#"+M_ameriflux_lh+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_ameriflux_sh#"+M_ameriflux_sh+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_ameriflux_gpp#"+M_ameriflux_gpp+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_ameriflux_er#"+M_ameriflux_er+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name) 

;***************************************************************************
; add total score and write to file
;***************************************************************************
  M_total = M_ameriflux_all

  asciiwrite("M_save.ameriflux", M_total)

;***************************************************************************
; output plot and html
;***************************************************************************
  output_dir = model_name+"/ameriflux"

  system("mv *.png *.html " + dirm + output_dir) 
;***************************************************************************

exit
end

