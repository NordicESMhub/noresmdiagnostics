; NCL script (CISM diagnostics package)
;***********************************************
; ISMIP6 Atlas function
; Plot diagnostic model output
; Heiko Goelzer, NORCE Jan 2021 (heig@horceresearch.no)
;
; Usage: ncl -Q <Arguments> gland_fun.ncl

begin

; Arguments
wkdir      = getenv("WKDIR")
infile1    = getenv("INFILE1")
aexp	   = getenv("aexp")
avar	   = getenv("avar")
atsp	   = getenv("atsp")
apal	   = getenv("apal")
amod	   = getenv("amod")
amin	   = getenv("amin")
amax	   = getenv("amax")
alsp	   = getenv("alsp")
alvl	   = getenv("alvl")

;print(infile1) 
;print(aexp)	
;print(avar)	
;print(atsp)	
;print(apal)	
;print(amod)	
;print(amin)	
;print(amax)	
;print(alsp)	
;print(alvl)	

; add a netcdf file 
  f     = addfile(infile1,"r")
  ; time step
  nt    = toint(atsp)
  ; get variable from file
  data  := f->$avar$(nt,:,:)
  ; scale
  if(isatt(data,"scale_factor")) then
    data_sc = data*data@scale_factor
  else
    data_sc = data
  end if  

  ; array size
  dimgrd= dimsizes(data)
  ny  = dimgrd(0)
  nx  = dimgrd(1)

  ; aspect ratio
  asp = int2flt(nx)/int2flt(ny)

  ; Open png for graphics.
  wks = gsn_open_wks("ps",wkdir+"/"+"set2_ann_"+aexp+"_"+avar+"_1model")
  
  ; Plot setting
  res                      = True
  ; Maximize plot in frame
  res@gsnMaximize          = True          
  ; Match grid aspect ratio
  res@vpWidthF      = asp
  res@vpHeightF     = 1.0

  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn on/off contour lines

; Color map and mapping options
  res@cnFillPalette = "WhiteBlueGreenYellowRed"
  res@cnConstFEnableFill = True
  if(amod .eq. 0) then
    ; automatic levels
    res@cnLevelSelectionMode = "AutomaticLevels"
  else if(amod .eq. 1) then
    ; manual levels range (and step)
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       =  amin
    res@cnMaxLevelValF       =  amax
    if((alsp .ne. 0) ) then
      res@cnLevelSpacingF      =  alsp
    end if  
  else if(amod .eq. 2) then
    ; explicit contour levels
    res@cnLevelSelectionMode = "ExplicitLevels"   
    res@cnLevels    = (/-2e3,-1e3,-5e2,-2e2,-1e2,-5e1,-2e1,-1e1,0,1e2,2e2,3e2,4e2,5e2,6e2,7e2,8e2,9e2,10e2/)
  end if  
  end if
  end if

  res@lbOrientation        = "vertical"

  ; Grid point numbers  
  res@sfXArray = fspan(1,nx,nx)
  res@sfYArray = fspan(1,ny,ny)

  ; Labels
  res@txFontHeightF   = 0.013
  res@tiMainString    = ""
  res@tiXAxisString   = ""
  res@tiYAxisString   = ""

  ; Ticks
  res@tmYLOn = False
  res@tmYROn = False
  res@tmXTOn = False
  res@tmXBOn = False

  ; Tick labels off
  res@tmYLLabelsOn = False
  res@tmXBLabelsOn = False
  
  ; Plot  
;  contour = gsn_csm_contour(wks,data,res)
  contour = gsn_csm_contour(wks,data_sc,res)

end
