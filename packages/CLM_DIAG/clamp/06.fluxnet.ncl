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
; read model data

  fm    = addfile(dirm+film2,"r")
  
  xm    = fm->lon
  ym    = fm->lat

  nlat = dimsizes(ym)
  nlon = dimsizes(xm)

; for 4 fields, 12-monthly
  nmon      = 12
  nfield    = 4

  data_mod0 = new ((/nfield,nmon,nlat,nlon/),float)

; change to unit of observed (u mol/m2/s)
; Model_units [=] gC/m2/s
; 12. = molecular weight of C
; u mol = 1e-6 mol
  factor = 1e6 /12.

if (ENERGY .eq. "old") then

  data = fm->NEE
  data_mod0(0,:,:,:) = data(:,:,:) * factor
  delete (data)

; data  = fm->LATENT
  data1 = fm->FCEV
  data2 = fm->FCTR
  data3 = fm->FGEV
  data_mod0(2,:,:,:) = data1(:,:,:)+data2(:,:,:)+data3(:,:,:) 
  delete (data1)
  delete (data2)
  delete (data3)

; data = fm->SENSIBLE
  data  = fm->FSH
  data_mod0(3,:,:,:) = data(:,:,:) 
  delete (data)

; data  = fm->NETRAD
  data1 = fm->FSA
  data2 = fm->FIRA
  data_mod0(1,:,:,:) = data1(:,:,:)-data2(:,:,:) 
  delete (data1)
  delete (data2)

else

  data = fm->NEE
  data_mod0(0,:,:,:) = data(:,:,:) * factor
  delete (data)

  data = fm->NETRAD
  data_mod0(1,:,:,:) = data(:,:,:) 
  delete (data)

  data = fm->LATENT
  data_mod0(2,:,:,:) = data(:,:,:) 
  delete (data)

  data = fm->FSH
  data_mod0(3,:,:,:) = data(:,:,:) 
  delete (data)
end if

 delete (fm)

;************************************************
; read data: observed
;************************************************

 station = (/"BOREAS_NSA_OBS" \
            ,"CastelPorziano" \
            ,"Hyytiala" \
            ,"Kaamanen" \
            ,"LBA_Tapajos_KM67" \
            ,"Lethbridge" \
            ,"Tharandt" \
            ,"Vielsalm" \
            /)

 year_ob = (/"1994-2004" \
            ,"1997-2003" \
            ,"1996-2003" \
            ,"2000-2003" \
            ,"2002-2005" \
            ,"1999-2004" \
            ,"1996-2003" \
            ,"1998-2003" \
            /)

 field   = (/"NEE" \
            ,"Net Radiation" \
            ,"Latent Heat" \
            ,"Sensible Heat" \
            /)

 nstation  = dimsizes(station)
 nmon      = 12
 nfield    = dimsizes(field)

 data_ob   = new ((/nstation, nfield, nmon/),float)
 lat_ob    = new ((/nstation/),float)
 lon_ob    = new ((/nstation/),float)

 diri_root  = diro + "fluxnet/"

 do n = 0,nstation-1
    diri = diri_root + station(n)+"/"
    fili = station(n)+"_"+year_ob(n)+"_monthly.nc"
    g     = addfile (diri+fili,"r")
 
    lon_ob(n) = g->lon 
    lat_ob(n) = g->lat

    data      = g->CO2_FLUX
    data_ob(n,0,:) = dim_avg(data(month|:,year|:))
    delete (data)

    data      = g->RAD_FLUX
    data_ob(n,1,:) = dim_avg(data(month|:,year|:))
    delete (data)

    data      = g->LH_FLUX
    data_ob(n,2,:) = dim_avg(data(month|:,year|:))
    delete (data)

    data      = g->SH_FLUX
    data_ob(n,3,:) = dim_avg(data(month|:,year|:))
    delete (data)

    delete (g)
 end do

;************************************************************
; interpolate model data into observed station
; note: model is 0-360E, 90S-90N
;************************************************************

; to be able to handle observation at (-89.98,-24.80)
  ym(0) = -90.  

  yy = linint2_points_Wrap(xm,ym,data_mod0,True,lon_ob,lat_ob,0)

  delete (data_mod0)
  yy!0 = "field"
  data_mod = yy(pts|:,field|:,time|:)

;************************************************************
; compute correlation coef and M score
;************************************************************

 score_max = 5.

 ccr     = new ((/nstation, nfield/),float)
 M_score = new ((/nstation, nfield/),float) 

 do n=0,nstation-1
 do m=0,nfield-1   
    ccr(n,m) = esccr(data_ob(n,m,:),data_mod(n,m,:),0)
    bias = sum(abs(data_mod(n,m,:)-data_ob(n,m,:))/(abs(data_mod(n,m,:))+abs(data_ob(n,m,:))))
    M_score(n,m) = (1. -(bias/nmon)) * score_max
 end do
 end do

 M_nee = avg(M_score(:,0))
 M_rad = avg(M_score(:,1))
 M_lh  = avg(M_score(:,2))
 M_sh  = avg(M_score(:,3))
 M_all = M_nee+ M_rad +M_lh + M_sh

 M_fluxnet_nee = sprintf("%.2f", M_nee)
 M_fluxnet_rad = sprintf("%.2f", M_rad)
 M_fluxnet_lh  = sprintf("%.2f", M_lh )
 M_fluxnet_sh  = sprintf("%.2f", M_sh )
 M_fluxnet_all = sprintf("%.2f", M_all)

;*******************************************************************
; for station line plot
;*******************************************************************

; for x-axis in xyplot
  mon = ispan(1,12,1)
  mon@long_name = "month"

  res                   = True               ; plot mods desired
  res@xyLineThicknesses = (/2.0,2.0/)        ; make 2nd lines thicker
  res@xyLineColors      = (/"blue","red"/)   ; line color (ob,model)
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

  plot_data   = new((/2,12/),float)
  plot_data!0 = "case"
  plot_data!1 = "month"

  do n = 0,nstation-1
;----------------------------
; for observed

    plot_name = station(n)+"_ob"    
    title = station(n)+"("+sprintf("%5.2f",lat_ob(n))+","+sprintf("%5.2f",lon_ob(n))+")"
    res@tiMainString = title

    wks = gsn_open_wks (plot_type,plot_name)
    plot=new(4,graphic)                        ; create graphic array   
                           
    plot_data(0,:) = (/data_ob (n,0,:)/)
    plot_data@long_name = field(0)   
    plot(0)=gsn_csm_xy(wks,mon,plot_data(0,:),res)   ; create plot 1

    plot_data(0,:) = (/data_ob (n,1,:)/)
    plot_data@long_name = field(1)
    plot(1)=gsn_csm_xy(wks,mon,plot_data(0,:),res)   ; create plot 2

    plot_data(0,:) = (/data_ob (n,2,:)/)
    plot_data@long_name = field(2)   
    plot(2)=gsn_csm_xy(wks,mon,plot_data(0,:),res)   ; create plot 3

    plot_data(0,:) = (/data_ob (n,3,:)/)
    plot_data@long_name = field(3)
    plot(3)=gsn_csm_xy(wks,mon,plot_data(0,:),res)   ; create plot 4

    gsn_panel(wks,plot,(/2,2/),pres)                 ; create panel plot

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
    plot=new(4,graphic)                        ; create graphic array   
                           
    plot_data(0,:) = (/data_ob (n,0,:)/)
    plot_data(1,:) = (/data_mod(n,0,:)/)
    plot_data@long_name = field(0)   
    plot(0)=gsn_csm_xy(wks,mon,plot_data,res)   ; create plot 1

    plot_data(0,:) = (/data_ob (n,1,:)/)
    plot_data(1,:) = (/data_mod(n,1,:)/)
    plot_data@long_name = field(1)
    plot(1)=gsn_csm_xy(wks,mon,plot_data,res)   ; create plot 2

    plot_data(0,:) = (/data_ob (n,2,:)/)
    plot_data(1,:) = (/data_mod(n,2,:)/)
    plot_data@long_name = field(2)   
    plot(2)=gsn_csm_xy(wks,mon,plot_data,res)   ; create plot 3

    plot_data(0,:) = (/data_ob (n,3,:)/)
    plot_data(1,:) = (/data_mod(n,3,:)/)
    plot_data@long_name = field(3)
    plot(3)=gsn_csm_xy(wks,mon,plot_data,res)   ; create plot 4

    gsn_panel(wks,plot,(/2,2/),pres)                 ; create panel plot

    delete (wks)  
    delete (plot)

    system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
           "rm "+plot_name+"."+plot_type)
 end do

;*******************************************************************
; html table of site: observed
;*******************************************************************
  output_html = "line_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>Fluxnet at Site: Observation</H1>" \
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

     txt0 = station(n)
     txt1 = sprintf("%5.2f", lat_ob(n))
     txt2 = sprintf("%5.2f", lon_ob(n))
     txt3 = year_ob(n)

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
            ,"<H1>Fluxnet at Site: Model "+model_name+"</H1>" \
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
       ,"   <th bgcolor=DDDDDD >NEE</th>" \
       ,"   <th bgcolor=DDDDDD >Net Radiation</th>" \
       ,"   <th bgcolor=DDDDDD >Latent Heat</th>" \
       ,"   <th bgcolor=DDDDDD >Sensible Heat</th>" \
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

     txt0 = station(n)
     txt1 = sprintf("%5.2f", lat_ob(n))
     txt2 = sprintf("%5.2f", lon_ob(n))
     txt3 = year_ob(n)
     txt4 = sprintf("%5.2f", M_score(n,0))
     txt5 = sprintf("%5.2f", M_score(n,1))
     txt6 = sprintf("%5.2f", M_score(n,2))
     txt7 = sprintf("%5.2f", M_score(n,3))
     txt8 = sprintf("%5.2f", avg(M_score(n,:)))

     set_line(lines,nline,"<th><a href="+txt0+"_model_vs_ob.png>"+txt0+"</a></th>")
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

; last row, summary
  set_line(lines,nline,row_header)

  txt0 = "All_"+sprintf("%.0f", nstation)
  txt1 = "-"
  txt2 = "-"
  txt3 = "-"
  txt4 = M_fluxnet_nee
  txt5 = M_fluxnet_rad
  txt6 = M_fluxnet_lh
  txt7 = M_fluxnet_sh
  txt8 = M_fluxnet_all

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
     system("sed -e '1,/M_fluxnet_nee/s/M_fluxnet_nee/"+M_fluxnet_nee+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_fluxnet_rad/s/M_fluxnet_rad/"+M_fluxnet_rad+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_fluxnet_lh/s/M_fluxnet_lh/"+M_fluxnet_lh+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2+";"+ \
            "sed -e '1,/M_fluxnet_sh/s/M_fluxnet_sh/"+M_fluxnet_sh+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_fluxnet_nee#"+M_fluxnet_nee+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_fluxnet_rad#"+M_fluxnet_rad+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_fluxnet_lh#"+M_fluxnet_lh+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "sed s#M_fluxnet_sh#"+M_fluxnet_sh+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name) 

;***************************************************************************
; add total score and write to file
;***************************************************************************
  M_total = M_fluxnet_all

  asciiwrite("M_save.fluxnet", M_total)

;***************************************************************************
; output plots
;***************************************************************************
  output_dir = model_name+"/fluxnet"

  system("mv *.png *.html " + dirm + output_dir) 
;***************************************************************************
exit
end
