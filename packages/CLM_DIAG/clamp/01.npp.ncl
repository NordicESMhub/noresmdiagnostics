;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;****************************************************************************
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
procedure get_bin(RAIN1_1D[*]:numeric, NPP1_1D[*]:numeric \
                 ,RAIN2_1D[*]:numeric, NPP2_1D[*]:numeric \
                 ,xvalues[*][*]:numeric, yvalues[*][*]:numeric \
                 ,mn_yvalues[*][*]:numeric, mx_yvalues[*][*]:numeric \
                 ,dx4[1]:numeric \
                  )
begin
; Calculaee "nice" bins for binning the data in equally spaced ranges.
; input : RAIN1_1D, RAIN2_1D, NPP1_1D, NPP2_1D
; output: xvalues, yvalues, mn_yvalues, mx_yvalues,dx4

  nbins       = 15     ; Number of bins to use.

  nicevals    = nice_mnmxintvl(min(RAIN1_1D),max(RAIN1_1D),nbins,True)
  nvals       = floattoint((nicevals(1) - nicevals(0))/nicevals(2) + 1)
  range       = fspan(nicevals(0),nicevals(1),nvals)

; Use this range information to grab all the values in a
; particular range, and then take an average.

  nr           = dimsizes(range)
  nx           = nr-1
; print (nx)

; xvalues      = new((/2,nx/),typeof(RAIN1_1D))
  xvalues(0,:) = range(0:nr-2) + (range(1:)-range(0:nr-2))/2.
  dx           = xvalues(0,1) - xvalues(0,0)       ; range width
  dx4          = dx/4                              ; 1/4 of the range
  xvalues(1,:) = xvalues(0,:) - dx/5.
; yvalues      = new((/2,nx/),typeof(RAIN1_1D))
; mn_yvalues   = new((/2,nx/),typeof(RAIN1_1D))
; mx_yvalues   = new((/2,nx/),typeof(RAIN1_1D))

  do nd=0,1

; See if we are doing model or observational data.

    if(nd.eq.0) then
      data     = RAIN1_1D
      npp_data = NPP1_1D
    else
      data     = RAIN2_1D
      npp_data = NPP2_1D
    end if

; Loop through each range and check for values.

    do i=0,nr-2
      if (i.ne.(nr-2)) then
;        print("")
;        print("In range ["+range(i)+","+range(i+1)+")")
        idx = ind((range(i).le.data).and.(data.lt.range(i+1)))
      else
;        print("")
;        print("In range ["+range(i)+",)")
        idx = ind(range(i).le.data)
      end if

; Calculate average, and get min and max.

      if(.not.any(ismissing(idx))) then
        yvalues(nd,i)    = avg(npp_data(idx))
        mn_yvalues(nd,i) = min(npp_data(idx))
        mx_yvalues(nd,i) = max(npp_data(idx))
        count = dimsizes(idx)
      else
        count            = 0
        yvalues(nd,i)    = yvalues@_FillValue
        mn_yvalues(nd,i) = yvalues@_FillValue
        mx_yvalues(nd,i) = yvalues@_FillValue
      end if

; Print out information.
;      print(data_types(nd) + ": " + count + " points, avg = " + yvalues(nd,i))
;      print("Min/Max:  " + mn_yvalues(nd,i) + "/" + mx_yvalues(nd,i))

; Clean up for next time in loop.

      delete(idx)
    end do
    delete(data)
    delete(npp_data)
  end do 
end
;****************************************************************************
; Main code.
;****************************************************************************
begin

 plot_type     = "ps"
 plot_type_new = "png"

;-----------------------------------------------------
; edit table.html of current model for movel1_vs_model2

 if (isvar("compare")) then
    html_name2 = compare+"/table.html"  
    html_new2  = html_name2 +".new"
;   print((/html_name2/))
;   print((/html_new2/))
 end if
;------------------------------------------------------
; edit table.html for current model

 html_name = model_name+"/table.html"  
 html_new  = html_name +".new"
;print((/html_name/))
;print((/html_new/))

;------------------------------------------------------
; read model data

 fm   = addfile (dirm+film1,"r")
  
 nppmod0  = fm->NPP
 rainmod0 = fm->RAIN
 xm       = fm->lon  
 ym       = fm->lat

 delete (fm)

;----------------------------------------------------
; read ob data

;(1) data at 81 sites

 dir81 = diro + "npp/"
 fil81 = "data.81.nc"
 f81   = addfile (dir81+fil81,"r")

 id81   = f81->SITE_ID  
 npp81  = f81->TNPP_C
 rain81 = tofloat(f81->PREC_ANN)
 x81    = f81->LONG_DD  
 y81    = f81->LAT_DD

 delete (f81)

 id81@long_name  = "SITE_ID"

;change longitude from (-180,180) to (0,360)
;for model data interpolation

 do i= 0,dimsizes(x81)-1
    if (x81(i) .lt. 0.) then
        x81(i) = x81(i)+ 360.
    end if
 end do

;-------------------------------------
;(2) data at 933 sites

 dir933 = diro + "npp/"
 fil933 = "data.933.nc"
 f933   = addfile (dir933+fil933,"r")

 id933   = f933->SITE_ID  
 npp933  = f933->TNPP_C
 rain933 = f933->PREC
 x933    = f933->LONG_DD  
 y933    = f933->LAT_DD 

 delete (f933)

 id933@long_name  = "SITE_ID"

;change longitude from (-180,180) to (0,360)
;for model data interpolation

 do i= 0,dimsizes(x933)-1
    if (x933(i) .lt. 0.) then
        x933(i) = x933(i)+ 360.
    end if
 end do

;----------------------------------------
;(3) global data, interpolated into model grid

 dirg = diro + "npp/"
 filg = "Npp_"+model_grid+"_mean.nc"
 fglobe   = addfile (dirg+filg,"r")
 
 nppglobe0 = fglobe->NPP
 nppglobe  = nppglobe0

 delete (fglobe)

;***********************************************************************
; interpolate model data into ob sites
;***********************************************************************

 nppmod   = nppmod0(0,:,:)
 rainmod  = rainmod0(0,:,:)
 delete (nppmod0)
 delete (rainmod0)

 nppmod81  =linint2_points(xm,ym,nppmod,True,x81,y81,0)

 nppmod933 =linint2_points(xm,ym,nppmod,True,x933,y933,0)

 rainmod81 =linint2_points(xm,ym,rainmod,True,x81,y81,0)

 rainmod933=linint2_points(xm,ym,rainmod,True,x933,y933,0)

;**********************************************************
; unified units
;**********************************************************
; Units for these variables are:
;
; rain81  : mm/year
; rainmod : mm/s
; npp81   : g C/m^2/year
; nppmod81: g C/m^2/s
; nppglobe: g C/m^2/year
;
; We want to convert these to "m/year" and "g C/m^2/year".

  nsec_per_year = 60*60*24*365                 

  rain81    = rain81 / 1000.
  rainmod81 = (rainmod81/ 1000.) * nsec_per_year
  nppmod81  = nppmod81 * nsec_per_year

  rain933    = rain933 / 1000.
  rainmod933 = (rainmod933/ 1000.) * nsec_per_year
  nppmod933  = nppmod933 * nsec_per_year

  nppmod  = nppmod * nsec_per_year

  npp81@units      = "gC/m^2/yr"
  nppmod81@units   = "gC/m^2/yr"
  npp933@units     = "gC/m^2/yr"
  nppmod933@units  = "gC/m^2/yr"
  nppmod@units     = "gC/m^2/yr"
  nppglobe@units   = "gC/m^2/yr"
  rain81@units     = "m/yr"
  rainmod81@units  = "m/yr"
  rain933@units    = "m/yr"
  rainmod933@units = "m/yr"

  npp81@long_name      = "NPP (gC/m2/year)"
  npp933@long_name     = "NPP (gC/m2/year)"
  nppmod81@long_name   = "NPP (gC/m2/year)"
  nppmod933@long_name  = "NPP (gC/m2/year)"
  nppmod@long_name     = "NPP (gC/m2/year)"
  nppglobe@long_name   = "NPP (gC/m2/year)"
  rain81@long_name     = "PREC (m/year)"
  rain933@long_name    = "PREC (m/year)"
  rainmod81@long_name  = "PREC (m/year)"
  rainmod933@long_name = "PREC (m/year)"

;*******************************************************************
;(A)-1 html table of site81 -- observed
;*******************************************************************
  output_html = "table_site81_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>EMDI Observations Class A (81 sites)</H1>" \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=60%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Site ID</th>" \
       ,"   <th bgcolor=DDDDDD >Latitude</th>" \
       ,"   <th bgcolor=DDDDDD >Longitude</th>" \
       ,"   <th bgcolor=DDDDDD >NPP(gC/m2/year)</th>" \
       ,"   <th bgcolor=DDDDDD >PPT(m/year)</th>" \
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
  
  nrow = dimsizes(id81)
  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1 = sprintf("%5.0f", id81(n))
     txt2 = sprintf("%5.2f", y81(n))  
     txt3 = sprintf("%5.2f", x81(n))    
     txt4 = sprintf("%5.2f", npp81(n))     
     txt5 = sprintf("%5.2f", rain81(n)) 

     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")

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

;*******************************************************************
;(A)-2 html table of site933 -- observed
;*******************************************************************
  output_html = "table_site933_ob.html"

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,"<H1>EMDI Observations Class B (933 sites)</H1>" \
            /) 
  footer = "</HTML>"

  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=60%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >Site ID</th>" \
       ,"   <th bgcolor=DDDDDD >Latitude</th>" \
       ,"   <th bgcolor=DDDDDD >Longitude</th>" \
       ,"   <th bgcolor=DDDDDD >NPP(gC/m2/year)</th>" \
       ,"   <th bgcolor=DDDDDD >PPT(m/year)</th>" \
       ,"</tr>" \
       /)
  table_footer = "</table>"
  row_header = "<tr>"
  row_footer = "</tr>"

  delete (lines)  
  lines = new(50000,string)
  nline = 0

  set_line(lines,nline,header)
  set_line(lines,nline,table_header)
;-----------------------------------------------
;row of table
  
  nrow = dimsizes(id933)
  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1 = sprintf("%5.0f", id933(n))
     txt2 = sprintf("%5.2f", y933(n))  
     txt3 = sprintf("%5.2f", x933(n))    
     txt4 = sprintf("%5.2f", npp933(n))     
     txt5 = sprintf("%5.2f", rain933(n))

     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")

     set_line(lines,nline,row_footer)
  end do
;-----------------------------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file.
  delete (idx)
  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

;*******************************************************************
;(A)-3 html table of site81 -- model vs ob
;*******************************************************************
  output_html = "table_site81_model_vs_ob.html"

  header_text = "<H1>Model "+model_name+" vs Observed at 81 sites</H1>" 

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,header_text \
            /) 
  footer = "</HTML>"

  delete (table_header)
  table_header_text = "   <th bgcolor=DDDDDD >"+model_name+"</th>"
  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=100%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Site ID</th>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Latitude</th>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Longitude</th>" \
       ,"   <th bgcolor=DDDDDD colspan=2>NPP(gC/m2.year)</th>" \
       ,"   <th bgcolor=DDDDDD colspan=2>RAIN(m/year)</th>" \
       ,"</tr>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,     table_header_text \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,     table_header_text \
       ,"</tr>" \
       /)
  table_footer = "</table>"
  row_header = "<tr>"
  row_footer = "</tr>"

  delete (lines)
  lines = new(50000,string)
  nline = 0

  set_line(lines,nline,header)
  set_line(lines,nline,table_header)
;-----------------------------------------------
;row of table
  
  nrow = dimsizes(id81)
  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1 = sprintf("%5.0f", id81(n))
     txt2 = sprintf("%5.2f", y81(n))  
     txt3 = sprintf("%5.2f", x81(n))    
     txt4 = sprintf("%5.2f", npp81(n))
     txt5 = sprintf("%5.2f", nppmod81(n))     
     txt6 = sprintf("%5.2f", rain81(n))
     txt7 = sprintf("%5.2f", rainmod81(n)) 

     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")
     set_line(lines,nline,"<th>"+txt7+"</th>")

     set_line(lines,nline,row_footer)
  end do
;-----------------------------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file.
  delete (idx)
  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

;*******************************************************************
;(A)-4 html table of site933 -- model vs ob
;*******************************************************************
  output_html = "table_site933_model_vs_ob.html"

  header_text = "<H1>Model "+model_name+" vs Observed at 933 sites</H1>" 

  header = (/"<HTML>" \
            ,"<HEAD>" \
            ,"<TITLE>CLAMP metrics</TITLE>" \
            ,"</HEAD>" \
            ,header_text \
            /) 
  footer = "</HTML>"

  delete (table_header)
  table_header_text = "   <th bgcolor=DDDDDD >"+model_name+"</th>"
  table_header = (/ \
        "<table border=1 cellspacing=0 cellpadding=3 width=100%>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Site ID</th>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Latitude</th>" \
       ,"   <th bgcolor=DDDDDD rowspan=2>Longitude</th>" \
       ,"   <th bgcolor=DDDDDD colspan=2>NPP(gC/m2.year)</th>" \
       ,"   <th bgcolor=DDDDDD colspan=2>RAIN(m/year)</th>" \
       ,"</tr>" \
       ,"<tr>" \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,     table_header_text \
       ,"   <th bgcolor=DDDDDD >observed</th>" \
       ,     table_header_text \
       ,"</tr>" \
       /)
  table_footer = "</table>"
  row_header = "<tr>"
  row_footer = "</tr>"

  delete (lines)
  lines = new(50000,string)
  nline = 0

  set_line(lines,nline,header)
  set_line(lines,nline,table_header)
;-----------------------------------------------
;row of table
  
  nrow = dimsizes(id933)
  do n = 0,nrow-1
     set_line(lines,nline,row_header)

     txt1 = sprintf("%5.0f", id933(n))
     txt2 = sprintf("%5.2f", y933(n))  
     txt3 = sprintf("%5.2f", x933(n))    
     txt4 = sprintf("%5.2f", npp933(n))
     txt5 = sprintf("%5.2f", nppmod933(n))     
     txt6 = sprintf("%5.2f", rain933(n))
     txt7 = sprintf("%5.2f", rainmod933(n)) 

     set_line(lines,nline,"<th>"+txt1+"</th>")
     set_line(lines,nline,"<th>"+txt2+"</th>")
     set_line(lines,nline,"<th>"+txt3+"</th>")
     set_line(lines,nline,"<th>"+txt4+"</th>")
     set_line(lines,nline,"<th>"+txt5+"</th>")
     set_line(lines,nline,"<th>"+txt6+"</th>")
     set_line(lines,nline,"<th>"+txt7+"</th>")

     set_line(lines,nline,row_footer)
  end do
;-----------------------------------------------
  set_line(lines,nline,table_footer)
  set_line(lines,nline,footer) 

; Now write to an HTML file.
  delete (idx)
  idx = ind(.not.ismissing(lines))
  if(.not.any(ismissing(idx))) then
    asciiwrite(output_html,lines(idx))
  else
   print ("error?")
  end if

;***************************************************************************
;(A)-5 scatter plot, model vs ob 81
;***************************************************************************
  
 plot_name = "scatter_model_vs_ob_81"
 title     = model_name +" vs ob 81 sites"

 wks   = gsn_open_wks (plot_type,plot_name)    ; open workstation
 res                   = True                  ; plot mods desired
 res@tiMainString      = title                 ; add title
 res@xyMarkLineModes   = "Markers"             ; choose which have markers
 res@xyMarkers         =  16                   ; choose type of marker  
 res@xyMarkerColor     = "red"                 ; Marker color
 res@xyMarkerSizeF     = 0.01                  ; Marker size (default 0.01)
 res@tmLabelAutoStride = True                  ; nice tick mark labels

 res@gsnDraw           = False
 res@gsnFrame          = False                 ; don't advance frame yet
;-------------------------------
;compute correlation coef. and M
 ccr81 = esccr(nppmod81,npp81,0)
;print (ccr81)

 score_max = 2.5

 bias = sum(abs(nppmod81-npp81)/(abs(nppmod81)+abs(npp81))) 
 M81s = (1. - (bias/dimsizes(y81)))*score_max
 M_npp_S81  = sprintf("%.2f", M81s)

 if (isvar("compare")) then
    system("sed -e '1,/M_npp_S81/s/M_npp_S81/"+M_npp_S81+"/' "+html_name2+" > "+html_new2+";"+ \
           "mv -f "+html_new2+" "+html_name2)
 end if

 system("sed s#M_npp_S81#"+M_npp_S81+"# "+html_name+" > "+html_new+";"+ \
        "mv -f "+html_new+" "+html_name)
 
 tRes  = True
 tRes@txFontHeightF = 0.025

 correlation_text = "(correlation coef = "+sprintf("%5.2f", ccr81)+")"

 gsn_text_ndc(wks,correlation_text,0.5,0.95,tRes)
;--------------------------------
 plot  = gsn_csm_xy (wks,npp81,nppmod81,res)       ; create plot
;-------------------------------
; add polyline

 dum=gsn_add_polyline(wks,plot,(/0,1200/),(/0,1200/),False)
;-------------------------------
 draw (plot)
 delete (wks)
 delete (dum)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;***************************************************************************
;(A)-6 scatter plot, model vs ob 933
;***************************************************************************
  
 plot_name = "scatter_model_vs_ob_933"
 title     = model_name +" vs ob 933 sites"

 wks   = gsn_open_wks (plot_type,plot_name)    ; open workstation
 res                   = True                  ; plot mods desired
 res@tiMainString      = title                 ; add title
 res@xyMarkLineModes   = "Markers"             ; choose which have markers
 res@xyMarkers         =  16                   ; choose type of marker  
 res@xyMarkerColor     = "red"                 ; Marker color
 res@xyMarkerSizeF     = 0.01                  ; Marker size (default 0.01)
 res@tmLabelAutoStride = True                  ; nice tick mark labels

 res@gsnDraw           = False
 res@gsnFrame          = False                 ; don't advance frame yet
;-------------------------------
;compute correlation coef. and M

 ccr933 = esccr(nppmod933,npp933,0)

 score_max = 2.5

 bias  = sum(abs(nppmod933-npp933)/(abs(nppmod933)+abs(npp933)))
 M933s = (1. - (bias/dimsizes(y933)))*score_max
 M_npp_S933  = sprintf("%.2f", M933s)

 if (isvar("compare")) then
    system("sed -e '1,/M_npp_S933/s/M_npp_S933/"+M_npp_S933+"/' "+html_name2+" > "+html_new2+";"+ \
           "mv -f "+html_new2+" "+html_name2)
 end if

 system("sed s#M_npp_S933#"+M_npp_S933+"# "+html_name+" > "+html_new+";"+ \
        "mv -f "+html_new+" "+html_name)

 tRes  = True
 tRes@txFontHeightF = 0.025

 correlation_text = "(correlation coef = "+sprintf("%5.2f", ccr933)+")"

 gsn_text_ndc(wks,correlation_text,0.5,0.95,tRes)
;--------------------------------
 plot  = gsn_csm_xy (wks,npp933,nppmod933,res)    ; create plot
;-------------------------------
; add polyline

 dum=gsn_add_polyline(wks,plot,(/0,1500/),(/0,1500/),False)
;-------------------------------
 draw (plot)
 delete (wks)
 delete (dum)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;**************************************************************************
;(B) histogram 81
;**************************************************************************
;get data
  RAIN1_1D = ndtooned(rain81)
  RAIN2_1D = ndtooned(rainmod81)
  NPP1_1D  = ndtooned(npp81)
  NPP2_1D  = ndtooned(nppmod81)

; number of bin
  nx = 8

  xvalues      = new((/2,nx/),float)
  yvalues      = new((/2,nx/),float)
  mn_yvalues   = new((/2,nx/),float)
  mx_yvalues   = new((/2,nx/),float)
  dx4          = new((/1/),float)

  get_bin(RAIN1_1D, NPP1_1D, RAIN2_1D, NPP2_1D \
         ,xvalues,yvalues,mn_yvalues,mx_yvalues,dx4)

;----------------------------------------
;compute correlation coeff and M score
 
 u = yvalues(0,:)
 v = yvalues(1,:)

 good = ind(.not.ismissing(u) .and. .not.ismissing(v))
 uu = u(good)
 vv = v(good)

 ccr81h = esccr(uu,vv,0)

 score_max = 2.5

 bias = sum(abs(vv-uu)/(abs(vv)+abs(uu)))
 M81h = (1.- (bias/dimsizes(uu)))*score_max
 M_npp_H81  = sprintf("%.2f", M81h)

 if (isvar("compare")) then
    system("sed -e '1,/M_npp_H81/s/M_npp_H81/"+M_npp_H81+"/' "+html_name2+" > "+html_new2+";"+ \
           "mv -f "+html_new2+" "+html_name2)
 end if

 system("sed s#M_npp_H81#"+M_npp_H81+"# "+html_name+" > "+html_new+";"+ \
        "mv -f "+html_new+" "+html_name)
 
 delete (u)
 delete (v)
 delete (uu)
 delete (vv)
;----------------------------------------------------------------------
; histogram res
  resh                = True
  resh@gsnMaximize    = True
  resh@gsnDraw        = False
  resh@gsnFrame       = False
  resh@xyMarkLineMode = "Markers"
  resh@xyMarkerSizeF  = 0.014
  resh@xyMarker       = 16
  resh@xyMarkerColors = (/"Brown","Blue"/)
  resh@trYMinF        = min(mn_yvalues) - 10.
  resh@trYMaxF        = max(mx_yvalues) + 10.

  resh@tiYAxisString  = "NPP (g C/m2/year)"
  resh@tiXAxisString  = "Precipitation (m/year)"

  max_bar = new((/2,nx/),graphic)
  min_bar = new((/2,nx/),graphic)
  max_cap = new((/2,nx/),graphic)
  min_cap = new((/2,nx/),graphic)

  lnres = True
  line_colors = (/"brown","blue"/)

;**************************************************************************
;(B)-1 histogram plot, ob 81 site 
;**************************************************************************

  plot_name = "histogram_ob_81"
  title     = "Observed 81 site"
  resh@tiMainString  = title

  wks   = gsn_open_wks (plot_type,plot_name)    

  xy = gsn_csm_xy(wks,xvalues(0,:),yvalues(0,:),resh)

;-------------------------------
;Attach the vertical bar and the horizontal cap line 

  do nd=0,0
    lnres@gsLineColor = line_colors(nd)
    do i=0,nx-1
     
      if(.not.ismissing(mn_yvalues(nd,i)).and. \
         .not.ismissing(mx_yvalues(nd,i))) then
;
; Attach the vertical bar, both above and below the marker.
;
        x1 = xvalues(nd,i)
        y1 = yvalues(nd,i)
        y2 = mn_yvalues(nd,i)
        plx = (/x1,x1/)
        ply = (/y1,y2/)
        min_bar(nd,i) = gsn_add_polyline(wks,xy,plx,ply,lnres)

        y2 = mx_yvalues(nd,i)
        plx = (/x1,x1/)
        ply = (/y1,y2/)
        max_bar(nd,i) = gsn_add_polyline(wks,xy,plx,ply,lnres)
;
; Attach the horizontal cap line, both above and below the marker.
;
        x1 = xvalues(nd,i) - dx4
        x2 = xvalues(nd,i) + dx4
        y1 = mn_yvalues(nd,i)
        plx = (/x1,x2/)
        ply = (/y1,y1/)
        min_cap(nd,i) = gsn_add_polyline(wks,xy,plx,ply,lnres)

        y1 = mx_yvalues(nd,i)
        plx = (/x1,x2/)
        ply = (/y1,y1/)
        max_cap(nd,i) = gsn_add_polyline(wks,xy,plx,ply,lnres)
      end if
    end do
  end do

  draw(xy)
  delete (wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;****************************************************************************
;(B)-2 histogram plot, model vs ob 81 site 
;****************************************************************************

  plot_name = "histogram_model_vs_ob_81"
  title     = model_name+ " vs Observed 81 site"
  resh@tiMainString  = title

  wks   = gsn_open_wks (plot_type,plot_name)    ; open workstation

;-----------------------------
; Add a boxed legend using the more simple method, which won't have
; vertical lines going through the markers.

  resh@pmLegendDisplayMode    = "Always"
; resh@pmLegendWidthF         = 0.1
  resh@pmLegendWidthF         = 0.08
  resh@pmLegendHeightF        = 0.05
  resh@pmLegendOrthogonalPosF = -1.17
; resh@pmLegendOrthogonalPosF = -1.00  ;(downward)
; resh@pmLegendParallelPosF   =  0.18
  resh@pmLegendParallelPosF   =  0.88  ;(rightward)

; resh@lgPerimOn              = False
  resh@lgLabelFontHeightF     = 0.015
  resh@xyExplicitLegendLabels = (/"observed",model_name/)
;-----------------------------
  tRes  = True
  tRes@txFontHeightF = 0.025

  correlation_text = "(correlation coef = "+sprintf("%5.2f", ccr81h)+")"

  gsn_text_ndc(wks,correlation_text,0.56,0.85,tRes)

  xy = gsn_csm_xy(wks,xvalues,yvalues,resh)
;-------------------------------
;Attach the vertical bar and the horizontal cap line 

  do nd=0,1
    lnres@gsLineColor = line_colors(nd)
    do i=0,nx-1
     
      if(.not.ismissing(mn_yvalues(nd,i)).and. \
         .not.ismissing(mx_yvalues(nd,i))) then
;
; Attach the vertical bar, both above and below the marker.
;
        x1 = xvalues(nd,i)
        y1 = yvalues(nd,i)
        y2 = mn_yvalues(nd,i)
        min_bar(nd,i) = gsn_add_polyline(wks,xy,(/x1,x1/),(/y1,y2/),lnres)

        y2 = mx_yvalues(nd,i)
        max_bar(nd,i) = gsn_add_polyline(wks,xy,(/x1,x1/),(/y1,y2/),lnres)
;
; Attach the horizontal cap line, both above and below the marker.
;
        x1 = xvalues(nd,i) - dx4
        x2 = xvalues(nd,i) + dx4
        y1 = mn_yvalues(nd,i)
        min_cap(nd,i) = gsn_add_polyline(wks,xy,(/x1,x2/),(/y1,y1/),lnres)

        y1 = mx_yvalues(nd,i)
        max_cap(nd,i) = gsn_add_polyline(wks,xy,(/x1,x2/),(/y1,y1/),lnres)
      end if
    end do
  end do

  draw(xy)
  delete(wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

 delete (RAIN1_1D)
 delete (RAIN2_1D)
 delete (NPP1_1D)
 delete (NPP2_1D)
;delete (range)
 delete (xvalues) 
 delete (yvalues)
 delete (mn_yvalues)
 delete (mx_yvalues)
 delete (good)
 delete (max_bar)
 delete (min_bar)
 delete (max_cap)
 delete (min_cap)
   
;**************************************************************************
;(B) histogram 933
;**************************************************************************

; get data
  RAIN1_1D = ndtooned(rain933)
  RAIN2_1D = ndtooned(rainmod933)
  NPP1_1D  = ndtooned(npp933)
  NPP2_1D  = ndtooned(nppmod933)

; number of bin
  nx = 10

  xvalues      = new((/2,nx/),float)
  yvalues      = new((/2,nx/),float)
  mn_yvalues   = new((/2,nx/),float)
  mx_yvalues   = new((/2,nx/),float)
  dx4          = new((/1/),float)

  get_bin(RAIN1_1D, NPP1_1D, RAIN2_1D, NPP2_1D \
         ,xvalues,yvalues,mn_yvalues,mx_yvalues,dx4)
 
;----------------------------------------
;compute correlation coeff and M score
 
 u = yvalues(0,:)
 v = yvalues(1,:)

 good = ind(.not.ismissing(u) .and. .not.ismissing(v))
 uu = u(good)
 vv = v(good)

 ccr933h = esccr(uu,vv,0)

 score_max = 2.5

 bias  = sum(abs(vv-uu)/(abs(vv)+abs(uu)))
 M933h = (1.- (bias/dimsizes(uu)))*score_max
 M_npp_H933 = sprintf("%.2f", M933h)

 if (isvar("compare")) then
    system("sed -e '1,/M_npp_H933/s/M_npp_H933/"+M_npp_H933+"/' "+html_name2+" > "+html_new2+";"+ \
           "mv -f "+html_new2+" "+html_name2)
 end if

 system("sed s#M_npp_H933#"+M_npp_H933+"# "+html_name+" > "+html_new+";"+ \
        "mv -f "+html_new+" "+html_name)

 delete (u)
 delete (v)
 delete (uu)
 delete (vv)
;----------------------------------------------------------------------
; histogram res
  delete (resh)
  resh                = True
  resh@gsnMaximize    = True
  resh@gsnDraw        = False
  resh@gsnFrame       = False
  resh@xyMarkLineMode = "Markers"
  resh@xyMarkerSizeF  = 0.014
  resh@xyMarker       = 16
  resh@xyMarkerColors = (/"Brown","Blue"/)
  resh@trYMinF        = min(mn_yvalues) - 10.
  resh@trYMaxF        = max(mx_yvalues) + 10.

  resh@tiYAxisString  = "NPP (g C/m2/year)"
  resh@tiXAxisString  = "Precipitation (m/year)"

  max_bar = new((/2,nx/),graphic)
  min_bar = new((/2,nx/),graphic)
  max_cap = new((/2,nx/),graphic)
  min_cap = new((/2,nx/),graphic)

  lnres = True
  line_colors = (/"brown","blue"/)

;**************************************************************************
;(B)-3 histogram plot, ob 933 site 
;**************************************************************************

  plot_name = "histogram_ob_933"
  title     = "Observed 933 site"
  resh@tiMainString  = title

  wks   = gsn_open_wks (plot_type,plot_name)    

  xy = gsn_csm_xy(wks,xvalues(0,:),yvalues(0,:),resh)

;-------------------------------
;Attach the vertical bar and the horizontal cap line 

  do nd=0,0
    lnres@gsLineColor = line_colors(nd)
    do i=0,nx-1
     
      if(.not.ismissing(mn_yvalues(nd,i)).and. \
         .not.ismissing(mx_yvalues(nd,i))) then

; Attach the vertical bar, both above and below the marker.

        x1 = xvalues(nd,i)
        y1 = yvalues(nd,i)
        y2 = mn_yvalues(nd,i)
        min_bar(nd,i) = gsn_add_polyline(wks,xy,(/x1,x1/),(/y1,y2/),lnres)

        y2 = mx_yvalues(nd,i)
        max_bar(nd,i) = gsn_add_polyline(wks,xy,(/x1,x1/),(/y1,y2/),lnres)

; Attach the horizontal cap line, both above and below the marker.

        x1 = xvalues(nd,i) - dx4
        x2 = xvalues(nd,i) + dx4
        y1 = mn_yvalues(nd,i)
        min_cap(nd,i) = gsn_add_polyline(wks,xy,(/x1,x2/),(/y1,y1/),lnres)

        y1 = mx_yvalues(nd,i)
        max_cap(nd,i) = gsn_add_polyline(wks,xy,(/x1,x2/),(/y1,y1/),lnres)
      end if
    end do
  end do

  draw(xy)
  delete (xy)
  delete (wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;****************************************************************************
;(B)-4 histogram plot, model vs ob 933 site
;**************************************************************************** 

  plot_name = "histogram_model_vs_ob_933"
  title     = model_name+ " vs Observed 933 site"
  resh@tiMainString  = title

  wks   = gsn_open_wks (plot_type,plot_name)    ; open workstation

;-----------------------------
; Add a boxed legend using the more simple method, which won't have
; vertical lines going through the markers.

  resh@pmLegendDisplayMode    = "Always"
; resh@pmLegendWidthF         = 0.1
  resh@pmLegendWidthF         = 0.08
  resh@pmLegendHeightF        = 0.05
  resh@pmLegendOrthogonalPosF = -1.17
; resh@pmLegendOrthogonalPosF = -1.00  ;(downward)
; resh@pmLegendParallelPosF   =  0.18
  resh@pmLegendParallelPosF   =  0.88  ;(rightward)

; resh@lgPerimOn              = False
  resh@lgLabelFontHeightF     = 0.015
  resh@xyExplicitLegendLabels = (/"observed",model_name/)
;-----------------------------
  tRes  = True
  tRes@txFontHeightF = 0.025

  correlation_text = "(correlation coef = "+sprintf("%5.2f", ccr933h)+")"

  gsn_text_ndc(wks,correlation_text,0.56,0.85,tRes)

  xy = gsn_csm_xy(wks,xvalues,yvalues,resh)
;-------------------------------
;Attach the vertical bar and the horizontal cap line 

  do nd=0,1
    lnres@gsLineColor = line_colors(nd)
    do i=0,nx-1
     
      if(.not.ismissing(mn_yvalues(nd,i)).and. \
         .not.ismissing(mx_yvalues(nd,i))) then
;
; Attach the vertical bar, both above and below the marker.
;
        x1 = xvalues(nd,i)
        y1 = yvalues(nd,i)
        y2 = mn_yvalues(nd,i)
        min_bar(nd,i) = gsn_add_polyline(wks,xy,(/x1,x1/),(/y1,y2/),lnres)

        y2 = mx_yvalues(nd,i)
        max_bar(nd,i) = gsn_add_polyline(wks,xy,(/x1,x1/),(/y1,y2/),lnres)
;
; Attach the horizontal cap line, both above and below the marker.
;
        x1 = xvalues(nd,i) - dx4
        x2 = xvalues(nd,i) + dx4
        y1 = mn_yvalues(nd,i)
        min_cap(nd,i) = gsn_add_polyline(wks,xy,(/x1,x2/),(/y1,y1/),lnres)

        y1 = mx_yvalues(nd,i)
        max_cap(nd,i) = gsn_add_polyline(wks,xy,(/x1,x2/),(/y1,y1/),lnres)
      end if
    end do
  end do

  draw(xy)
  delete(xy)
  delete(wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;***************************************************************************
;(C) global contour 
;***************************************************************************

;res
  resg                     = True             ; Use plot options
  resg@cnFillOn            = True             ; Turn on color fill
  resg@gsnSpreadColors     = True             ; use full colormap
; resg@cnFillMode          = "RasterFill"     ; Turn on raster color
; resg@lbLabelAutoStride   = True
  resg@cnLinesOn           = False            ; Turn off contourn lines
  resg@mpFillOn            = False            ; Turn off map fill

  resg@gsnSpreadColors      = True            ; use full colormap
  resg@cnLevelSelectionMode = "ManualLevels"  ; Manual contour invtervals
  resg@cnMinLevelValF       = 0.              ; Min level
  resg@cnMaxLevelValF       = 2200.           ; Max level
  resg@cnLevelSpacingF      = 200.            ; interval

;****************************************************************************
;(C)-1 global contour plot, ob
;****************************************************************************

  delta = 0.00000000001
  nppglobe = where(ismissing(nppglobe).and.(ismissing(nppmod).or.(nppmod.lt.delta)),0.,nppglobe)
  
  plot_name = "global_ob"
  title     = "Observed MODIS MOD 17"
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,nppglobe,resg)
   
  delete (wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)
;****************************************************************************
;(C)-2 global contour plot, model
;****************************************************************************

  plot_name = "global_model"
  title     = "Model "+ model_name
  resg@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  plot = gsn_csm_contour_map_ce(wks,nppmod,resg)
   
  delete (wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;****************************************************************************
;(C)-3 global contour plot, model vs ob
;****************************************************************************

  plot_name = "global_model_vs_ob"

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation
  gsn_define_colormap(wks,"gui_default")     ; choose colormap

  delete (plot)
  plot=new(3,graphic)                        ; create graphic array

  resg@gsnFrame             = False          ; Do not draw plot 
  resg@gsnDraw              = False          ; Do not advance frame

; compute correlation coef and M score

  uu1 = ndtooned(nppmod)
  vv1 = ndtooned(nppglobe)

  delete (good) 
  good = ind(.not.ismissing(uu1) .and. .not.ismissing(vv1))

  ug = uu1(good)
  vg = vv1(good)

  ccrG = esccr(ug,vg,0)

  score_max = 5.0

  MG   = (ccrG*ccrG)* score_max
  M_npp_G = sprintf("%.2f", MG)

 if (isvar("compare")) then
    system("sed -e '1,/M_npp_G/s/M_npp_G/"+M_npp_G+"/' "+html_name2+" > "+html_new2+";"+ \
           "mv -f "+html_new2+" "+html_name2)
 end if

  system("sed s#M_npp_G#"+M_npp_G+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)

; plot correlation coef

  gRes  = True
  gRes@txFontHeightF = 0.02
  gRes@txAngleF = 90

  correlation_text = "(correlation coef = "+sprintf("%5.2f", ccrG)+")"

  gsn_text_ndc(wks,correlation_text,0.20,0.50,gRes)
;--------------------------------------------------------------------  
;(a) ob

  title     = "Observed MODIS MOD 17"
  resg@tiMainString  = title

  plot(0) = gsn_csm_contour_map_ce(wks,nppglobe,resg)       

;(b) model

  title     = "Model "+ model_name
  resg@tiMainString  = title

  plot(1) = gsn_csm_contour_map_ce(wks,nppmod,resg) 

;(c) model-ob

  zz = nppmod
  zz = nppmod - nppglobe
  title = "Model_"+model_name+" - Observed"

  resg@cnMinLevelValF  = -500           ; Min level
  resg@cnMaxLevelValF  =  500.          ; Max level
  resg@cnLevelSpacingF =  50.           ; interval
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
;(D)-1 zonal line plot, ob
;***************************************************************************
 
  vv     = zonalAve(nppglobe)
  vv@long_name = nppglobe@long_name

  plot_name = "zonal_ob"
  title     = "Observed MODIS MOD 17"

  resz = True
  resz@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   ; open workstation

  plot  = gsn_csm_xy (wks,ym,vv,resz)
   
  delete (wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;****************************************************************************
;(D)-2 zonal line plot, model vs ob
;****************************************************************************

  s  = new ((/2,dimsizes(ym)/), float)  

  s(0,:) = zonalAve(nppglobe) 
  s(1,:) = zonalAve(nppmod)

  s@long_name = nppglobe@long_name
;-------------------------------------------
; compute correlation coef and M score

  score_max = 5.0

  ccrZ = esccr(s(1,:), s(0,:),0)
  MZ   = (ccrZ*ccrZ)* score_max
  M_npp_Z = sprintf("%.2f", MZ)

  if (isvar("compare")) then
     system("sed -e '1,/M_npp_Z/s/M_npp_Z/"+M_npp_Z+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_npp_Z#"+M_npp_Z+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name)
;-------------------------------------------
  plot_name = "zonal_model_vs_ob"
  title     = "Zonal Average"
  resz@tiMainString  = title

  wks = gsn_open_wks (plot_type,plot_name)   

; resz@vpHeightF          = 0.4               ; change aspect ratio of plot
; resz@vpWidthF           = 0.7

  resz@xyMonoLineColor    = "False"           ; want colored lines
  resz@xyLineColors       = (/"black","red"/) ; colors chosen
; resz@xyLineThicknesses  = (/3.,3./)         ; line thicknesses
  resz@xyLineThicknesses  = (/2.,2./)         ; line thicknesses
  resz@xyDashPatterns     = (/0.,0./)         ; make all lines solid

  resz@tiYAxisString      = s@long_name       ; add a axis title    
  resz@txFontHeightF      = 0.0195            ; change title font heights

; Legent
  resz@pmLegendDisplayMode    = "Always"      ; turn on legend
  resz@pmLegendSide           = "Top"         ; Change location of 
; resz@pmLegendParallelPosF   = .45           ; move units right
  resz@pmLegendParallelPosF   = .82           ; move units right
  resz@pmLegendOrthogonalPosF = -0.4          ; move units down

  resz@pmLegendWidthF         = 0.10          ; Change width and
  resz@pmLegendHeightF        = 0.10          ; height of legend.
  resz@lgLabelFontHeightF     = .02           ; change font height
; resz@lgTitleOn              = True          ; turn on legend title
; resz@lgTitleString          = "Example"     ; create legend title
; resz@lgTitleFontHeightF     = .025          ; font of legend title
  resz@xyExplicitLegendLabels = (/"Observed",model_name/) ; explicit labels
;--------------------------------------------------------------------
  zRes  = True
  zRes@txFontHeightF = 0.025

  correlation_text = "(correlation coef = "+sprintf("%5.2f", ccrZ)+")"

  gsn_text_ndc(wks,correlation_text,0.50,0.77,zRes)
;--------------------------------------------------------------------
  
  plot  = gsn_csm_xy (wks,ym,s,resz)      
                                           
  delete (wks)

 system("convert "+plot_name+"."+plot_type+" "+plot_name+"."+plot_type_new+";"+ \
        "rm "+plot_name+"."+plot_type)

;***************************************************************************
; add total score and write to file
;***************************************************************************
  M_total = M81s + M81h + M933s + M933h + MG + MZ

  asciiwrite("M_save.npp", M_total)

;***************************************************************************
; output plots
;***************************************************************************
  output_dir = model_name+"/npp"

; print((/"mv table_*.html " + dirm+ output_dir +";"+ \ 
;        "mv *.png " + dirm + output_dir/))
  system("mv table_*.html " + dirm+ output_dir +";"+ \ 
         "mv *.png " + dirm + output_dir)
 
;***************************************************************************
exit
end

