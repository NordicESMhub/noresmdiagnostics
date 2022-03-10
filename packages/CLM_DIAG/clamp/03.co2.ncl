; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load dirscript + "taylor_diagram.ncl"
;************************************************
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
;****************************************************************************

begin

  plot_type = "ps"
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
; read model data

  fm    = addfile(dirm+film3,"r")

  x     = fm->CO2
  xi    = fm->lon
  yi    = fm->lat

  delete (fm)

  xdim  = dimsizes(x)
  nlev  = xdim(1)
  y     = x(:,0,:,:)
  
; get co2 at the lowest level
  y     = x(:,nlev-1,:,:)

; change to unit of observed (u mol/mol)
; Model_units [=] kgCO2 / kgDryAir
; 28.966 = molecular weight of dry air
; 44.       = molecular weight of CO2
; u mol = 1e-6 mol

  factor = (28.966/44.) * 1e6
  y      = y * factor

  y@_FillValue = 1.e36
  y@units      = "u mol/mol"

;************************************************
; read data: observed
;************************************************
  diri  = diro + "co2/"
  fili  = "co2_globalView_98.nc"
  g     = addfile (diri+fili,"r")

  val   = g->CO2_SEAS  
  lon   = g->LON 
  lat   = g->LAT
  sta   = chartostring(g->STATION)
 
  delete (g)

  ncase = dimsizes(lat)
;**************************************************************
; get only the lowest level at each station 
;**************************************************************
  lat_tmp = lat
  lat_tmp@_FillValue = 1.e+36
 
  do n = 0,ncase-1
     if (.not. ismissing(lat_tmp(n))) then 
        indexes = ind(lat(n) .eq. lat .and. lon(n) .eq. lon)
        if (dimsizes(indexes) .gt. 1) then
           lat_tmp(indexes(1:)) = lat_tmp@_FillValue
        end if
        delete (indexes)
     end if
  end do

  indexes = ind(.not. ismissing(lat_tmp))
 
  lat_ob = lat(indexes)
  lon_ob = lon(indexes)
  val_ob = val(indexes,:)
;************************************************************
; interpolate model data into observed station
; note: model is 0-360E, 90S-90N
;************************************************************
; to be able to handle observation at (-89.98,-24.80)
  yi(0) = -90.

  i = ind(lon_ob .lt. 0.)
  lon_ob(i) = lon_ob(i) + 360.  

  yo = linint2_points_Wrap(xi,yi,y,True,lon_ob,lat_ob,0)

  val_model = yo(pts|:,time|:)
  val_model_0 = val_model
;************************************************************
; remove annual mean
;************************************************************
  val_model = val_model - conform(val_model,dim_avg(val_model),0)

;*******************************************************************
; res for station line plot
;*******************************************************************
; for x-axis in xyplot
  mon = ispan(1,12,1)
  mon@long_name = "month"

  res                   = True                      ; plot mods desired
  res@xyLineThicknesses = (/2.0,2.0,2.0/)           ; make 2nd lines thicker
  res@xyLineColors      = (/"red","black"/)  ; change line color

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
  res@xyExplicitLegendLabels = (/model_name,"observed"/)
;************************************************************
; number of latitude zone
;************************************************************
  nzone = 4

; saving data for zone
; number of rows for zone table (with data)
  nrow_zone = nzone 

; number of columns for zone table
  ncol_zone = 7

  text = new((/nrow_zone,ncol_zone/),string)

do z = 0,nzone-1

  if (z .eq. 0) then 
     zone = "60N-90N" 
     score_max = 5.0
     ind_z = ind(lat_ob .ge. 60.)
  end if

  if (z .eq. 1) then 
     zone = "30N-60N" 
     score_max = 5.0
     ind_z = ind(lat_ob .ge. 30. .and. lat_ob .lt. 60.)
  end if

  if (z .eq. 2) then 
     zone = "EQ-30N"
     score_max = 5.0
     ind_z = ind(lat_ob .ge. 0. .and. lat_ob .lt. 30.)
  end if

  if (z .eq. 3) then 
     zone = "90S-EQ" 
     score_max = 5.0
     ind_z = ind(lat_ob .lt. 0. )
  end if

  npts = dimsizes(ind_z)

;------------------------------------------------------
; for metric table computation
  amp_ob        = new((/npts/),float)
  amp_model     = new((/npts/),float)

  amp_ratio_sta = new((/npts/),float)
  ccr_sta       = new((/npts/),float)
  M_sta         = new((/npts/),float)
  score_sta     = new((/npts/),float)

  var_sta       = new((/npts/),float)
;-----------------------------------------------------
; for station line plot
  npts_str = ""
  npts_str = npts

  plot_data   = new((/2,12,npts/),float)
  plot_data_0 = new((/12,npts/),float)

  plot_data!0 = "case"
  plot_data!1 = "month"
  plot_data!2 = "pts"
  plot_data@long_name   = "CO2 Seasonal"

  plot_data_0!0 = "month"
  plot_data_0!1 = "pts"
  plot_data_0@long_name = "CO2"
;--------------------------------------------------------------------------
  do n=0,npts-1

     amp_ob(n)    = max(val_ob(ind_z(n),:)) - min(val_ob(ind_z(n),:)) 
     amp_model(n) = max(val_model(ind_z(n),:)) - min(val_model(ind_z(n),:))

     amp_ratio_sta(n) = amp_model(n)/amp_ob(n)
     ccr_sta(n) = esccr(val_ob(ind_z(n),:),val_model(ind_z(n),:),0)
     M_sta(n) = 1.-abs(amp_ratio_sta(n)-1.)
     score_sta(n) = (ccr_sta(n)*ccr_sta(n) + M_sta(n))*0.5 * score_max
 
     var_model = stddev(val_model(ind_z(n),:))
     var_ob    = stddev(val_ob(ind_z(n),:))
     var_sta(n)= var_model/var_ob 
;----------------------------------------------------------------------
; for station line plot

     plot_data(0,:,n) = (/val_model(ind_z(n),:)/)
     plot_data(1,:,n) = (/val_ob(ind_z(n),:)/)

     plot_data_0(:,n) = (/val_model_0(ind_z(n),:)/)
   
     plot_name = sta(ind_z(n))    
     title = plot_name+"("+lat(ind_z(n))+","+lon(ind_z(n))+")"

     wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
;------------------------------------------
;    for panel plot
   
     plot=new(2,graphic)                        ; create graphic array
     res@gsnFrame     = False                   ; Do not draw plot 
     res@gsnDraw      = False                   ; Do not advance frame

     pres                            = True     ; panel plot mods desired
     pres@gsnPanelYWhiteSpacePercent = 5        ; increase white space around
                                               ; indiv. plots in panel
     pres@gsnMaximize                = True     ; fill the page
;------------------------------------------
     res@tiMainString = title                           ; add title

     plot(0)=gsn_csm_xy(wks,mon,plot_data(:,:,n),res)   ; create plot 1

     plot(1)=gsn_csm_xy(wks,mon,plot_data_0(:,n),res) ; create plot 2

     gsn_panel(wks,plot,(/2,1/),pres)                 ; create panel plot

     delete (wks)
     delete (plot)

     system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
            "rm "+plot_name+"."+plot_type)

;---------------------------------------------------------------------------  
  end do

;-------------------------------------------------------------------------
; for Taylor plot in a zone

; Cases [Model]
  case      = (/ model_name /) 
  nCase     = dimsizes(case )                 ; # of Cases [Cases]

; station compared
  var       = sta(ind_z) 
  nVar      = dimsizes(var)                   ; # of stations

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(var_sta) )  
  cc         = new ((/nCase, nVar/),typeof(ccr_sta) ) 

  ratio(0,:) = var_sta 
  cc(0,:)    = ccr_sta

;---------------------------------
; create plot

  rest   = True                           ; default taylor diagram
        
  rest@Markers      = (/16/)               ; make all solid fill
  rest@Colors       = (/"red" /)          
; rest@varLabels    = var
  rest@caseLabels   = "model " + case

  plot_name = "taylor_diagram_"+ zone
  title = "CO2 annual in "+ zone
  rest@tiMainString = title
  
  wks  = gsn_open_wks (plot_type,plot_name)        ; open workstation  
  plot = taylor_diagram(wks,ratio,cc,rest)

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

  delete (ratio)
  delete (cc)
  delete (var_sta)
  delete (var)

;-------------------------------------------------------------------------
; for line plot in a zone

  plot_name = "All_"+npts_str
  title = plot_name + " in "+ zone

  wks = gsn_open_wks (plot_type,plot_name)        ; open workstation
;-----------------------------------------
; for panel plot
   
  plot=new(2,graphic)                        ; create graphic array
  res@gsnFrame     = False                   ; Do not draw plot 
  res@gsnDraw      = False                   ; Do not advance frame

  pres                            = True     ; panel plot mods desired
  pres@gsnPanelYWhiteSpacePercent = 5        ; increase white space around
                                               ; indiv. plots in panel
  pres@gsnMaximize                = True     ; fill the page
;-----------------------------------------
  res@tiMainString = title                                     ; add title

  plot(0) = gsn_csm_xy (wks,mon,dim_avg_Wrap(plot_data),res)   ; create plot 1
    
  plot(1) = gsn_csm_xy (wks,mon,dim_avg_Wrap(plot_data_0),res) ; create plot 2

  gsn_panel(wks,plot,(/2,1/),pres)                 ; create panel plot

  delete (wks)
  delete (plot)

  system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
         "rm "+plot_name+"."+plot_type)

  delete (plot_data)
  delete (plot_data_0)    
;---------------------------------------------------------------------------
; values saved for zone table 

  amp_ratio_zone = avg(amp_ratio_sta)
  ccr_zone       = avg(ccr_sta)
  M_zone         = 1.- (sum(abs(amp_model-amp_ob)/(amp_model+amp_ob))/npts) 
  score_zone     = (ccr_zone*ccr_zone + M_zone)*0.5 * score_max

  text(z,0) = zone
  text(z,1) = sprintf("%.0f", npts)
  text(z,2) = sprintf("%.2f", amp_ratio_zone)
  text(z,3) = sprintf("%.2f", ccr_zone)
  text(z,4) = sprintf("%.2f", M_zone)
  text(z,5) = sprintf("%.2f", score_zone)
  text(z,6) = zone  

;*******************************************************************
; html table -- station
;*******************************************************************
  output_html = "score+line_"+zone+".html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>Latitude Zone "+zone+": Model "+model_name+"</H1>" \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=100%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Site Name</th>" \
       ,"   <th bgcolor=DDDDDD >Latitude</th>" \
       ,"   <th bgcolor=DDDDDD >Longitude</th>" \
       ,"   <th bgcolor=DDDDDD >model vs obs.<br>amplitude ratio</th>" \
       ,"   <th bgcolor=DDDDDD >Correlation Coef.</th>" \
       ,"   <th bgcolor=DDDDDD >M Score</th>" \
       ,"   <th bgcolor=DDDDDD >Combined Score</th>" \
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
  
  do n = 0,npts-1
     set_line(lines,nline,row_header)

     txt0 = sta(ind_z(n))
     txt1 = sprintf("%5.2f", (/lat(ind_z(n))/))
     txt2 = sprintf("%5.2f", (/lon(ind_z(n))/))
     txt3 = sprintf("%5.2f", (/amp_ratio_sta(n)/))
     txt4 = sprintf("%5.2f", (/ccr_sta(n)/))
     txt5 = sprintf("%5.2f", (/M_sta(n)/))
     txt6 = sprintf("%5.2f", (/score_sta(n)/))

     set_line(lines,nline,"<th><a href="+txt0+".png>"+txt0+"</a></th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")

     set_line(lines,nline,row_footer)
  end do

; last row, summary
  set_line(lines,nline,row_header)

  txt0 = "All_"+sprintf("%.0f", (/npts/))
  txt1 = "-"
  txt2 = "-"
  txt3 = sprintf("%5.2f", (/amp_ratio_zone/))
  txt4 = sprintf("%5.2f", (/ccr_zone/))
  txt5 = sprintf("%5.2f", (/M_zone/))
  txt6 = sprintf("%5.2f", (/score_zone/))

  set_line(lines,nline,"<th><a href="+txt0+".png>"+txt0+"</a></th>")
  set_line(lines,nline,"<th>"+txt1+"</th>")
  set_line(lines,nline,"<th>"+txt2+"</th>")
  set_line(lines,nline,"<th>"+txt3+"</th>")
  set_line(lines,nline,"<th>"+txt4+"</th>")
  set_line(lines,nline,"<th>"+txt5+"</th>")
  set_line(lines,nline,"<th>"+txt6+"</th>")

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
;-----------------------------------------------------------------

  delete (ind_z)
  delete (amp_model)
  delete (amp_ob)
  delete (amp_ratio_sta)
  delete (ccr_sta)
  delete (M_sta)
  delete (score_sta)
end do

;*******************************************************************
; html table -- zone
;*******************************************************************
  output_html = "score+line_vs_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>CO2 Seasonal Cycle Comparisons by Latitude Zone: Model "+model_name+"</H1>" \
            /) 
  footer = "</HTML>"

  delete (table_header)
  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=80%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Zone</th>" \
       ,"   <th bgcolor=DDDDDD >Number of Site</th>" \
       ,"   <th bgcolor=DDDDDD >model vs obs.<br>amplitide ratio</th>" \
       ,"   <th bgcolor=DDDDDD >Correlation Coef.</th>" \
       ,"   <th bgcolor=DDDDDD >M Score</th>" \
       ,"   <th bgcolor=DDDDDD >Combined Score</th>" \
       ,"   <th bgcolor=DDDDDD >Taylor diagram</th>" \
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
 
  do n = 0,nrow_zone-1
     set_line(lines,nline,row_header)

     set_line(lines,nline,"<th><a href=score+line_"+text(n,0)+".html>"+text(n,0)+"</th>")
     set_line(lines,nline,"<th>"+text(n,1)+"</th>")
     set_line(lines,nline,"<th>"+text(n,2)+"</th>")
     set_line(lines,nline,"<th>"+text(n,3)+"</th>")
     set_line(lines,nline,"<th>"+text(n,4)+"</th>")
     set_line(lines,nline,"<th>"+text(n,5)+"</th>")
     set_line(lines,nline,"<th><a href=taylor_diagram_"+text(n,6)+".png>Taylor_diagram</th>")

     set_line(lines,nline,row_footer)
  end do

; for the last row

     txt0 = "All"
     txt1 = sum(stringtofloat(text(0:3,1))) 
     txt2 = "-"
     txt3 = "-"
     txt4 = "-"
     txt5 = sum(stringtofloat(text(0:3,5)))
     txt6 = "-"

     set_line(lines,nline,row_header)

     set_line(lines,nline,"<th>"+txt0+"</th>")
     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")

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
;--------------------------------------------------------------------------
 
  M_co2 = txt5

  if (isvar("compare")) then

     system("sed -e '1,/M_co2/s/M_co2/"+M_co2+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_co2#"+M_co2+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)

;***************************************************************************
; add total score and write to file
;***************************************************************************
  M_total = M_co2

  asciiwrite("M_save.co2", M_total)
 
;***************************************************************************
; output plots
;***************************************************************************
  output_dir = model_name+"/co2"

  system("mv *.png *.html " + dirm + output_dir)
;*************************************************************************** 
exit
end
