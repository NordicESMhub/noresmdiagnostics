; NCL script
; functions_time_series.ncl
; Johan Liakka, Nov 2017
;******************************************************************
 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_voltr (inptr:file) 
begin
   if (isfilevar(inptr,"voltr")) then
      tmp = inptr->voltr
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Volume transport"
      xvar@units = "Sv"
      assignFillValue(xvar,xvar)
   else
      print("get_voltr: no voltr variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_section (inptr:file) 
begin
   if (isfilevar(inptr,"section")) then
      tmp  = inptr->section
      xvar = chartostring(tmp)
   else
      print("get_section: no section variable present")
      status_exit(1)
   end if
   return (xvar)
end

function get_depth (inptr:file) 
begin
   if (isfilevar(inptr,"depth")) then
      tmp  = inptr->depth
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
   else
      print("get_depth: no depth variable present")
      status_exit(1)
   end if
   return (xvar)
end 

function get_temp (inptr:file) 
begin
   if (isfilevar(inptr,"temp")) then
      tmp = inptr->temp
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Temperature"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
      nt=dimsizes(xvar)
      dt = new(nt-1,"float")
      do it = 0,nt-2
         dt(it) = xvar(it+1)-xvar(it)
         if (abs(dt(it)).gt.0.03) then
           print("WARNING: replaced temperature outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
           xvar(it+1) = xvar(it)
         end if
      end do
   else
      print("get_temp: no temp variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_saln (inptr:file) 
begin
   if (isfilevar(inptr,"saln")) then
      tmp = inptr->saln
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Salinity"
      xvar@units = "g kg-1"
      assignFillValue(xvar,xvar)
      nt=dimsizes(xvar)
      ds = new(nt-1,"float")
      do it = 0,nt-2
         ds(it) = xvar(it+1)-xvar(it)
         if (abs(ds(it)).gt.0.002) then
           print("WARNING: replaced salinity outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
           xvar(it+1) = xvar(it)
         end if
      end do
   else
      print("get_saln: no saln variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sst (inptr:file) 
begin
   if (isfilevar(inptr,"sst")) then
      tmp = inptr->sst
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Sea Surface Temperature"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
      nt=dimsizes(xvar)
      dt = new(nt-1,"float")
;      do it = 0,nt-2
;         dt(it) = xvar(it+1)-xvar(it)
;         if (abs(dt(it)).gt.0.03) then
;           print("WARNING: replaced temperature outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
;           xvar(it+1) = xvar(it)
;         end if
;      end do
   else
      print("get_sst: no sst variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sss (inptr:file) 
begin
   if (isfilevar(inptr,"sss")) then
      tmp = inptr->sss
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Sea Surface Salinity"
      xvar@units = "g kg-1"
      assignFillValue(xvar,xvar)
      nt=dimsizes(xvar)
      ds = new(nt-1,"float")
;      do it = 0,nt-2
;         ds(it) = xvar(it+1)-xvar(it)
;         if (abs(ds(it)).gt.0.002) then
;           print("WARNING: replaced salinity outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
;           xvar(it+1) = xvar(it)
;         end if
;      end do
   else
      print("get_sss: no sss variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_tempga (inptr:file) 
begin
   if (isfilevar(inptr,"tempga")) then
      tmp = inptr->tempga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Temperature"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
;      nt=dimsizes(xvar)
;      dt = new(nt-1,"float")
;      do it = 0,nt-2
;         dt(it) = xvar(it+1)-xvar(it)
;         if (abs(dt(it)).gt.0.03) then
;           print("WARNING: replaced temperature outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
;           xvar(it+1) = xvar(it)
;         end if
;      end do
   else
      print("get_tempga: no tempga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_salnga (inptr:file) 
begin
   if (isfilevar(inptr,"salnga")) then
      tmp = inptr->salnga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Salinity"
      xvar@units = "g kg-1"
      assignFillValue(xvar,xvar)
;      nt=dimsizes(xvar)
;      ds = new(nt-1,"float")
;      do it = 0,nt-2
;         ds(it) = xvar(it+1)-xvar(it)
;         if (abs(ds(it)).gt.0.002) then
;           print("WARNING: replaced salinity outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
;           xvar(it+1) = xvar(it)
;         end if
;      end do
   else
      print("get_salnga: no salnga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sstga (inptr:file) 
begin
   if (isfilevar(inptr,"sstga")) then
      tmp = inptr->sstga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Sea Surface Temperature"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
      nt=dimsizes(xvar)
      dt = new(nt-1,"float")
;      do it = 0,nt-2
;         dt(it) = xvar(it+1)-xvar(it)
;         if (abs(dt(it)).gt.0.03) then
;           print("WARNING: replaced temperature outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
;           xvar(it+1) = xvar(it)
;         end if
;      end do
   else
      print("get_sstga: no sstga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sssga (inptr:file) 
begin
   if (isfilevar(inptr,"sssga")) then
      tmp = inptr->sssga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Sea Surface Salinity"
      xvar@units = "g kg-1"
      assignFillValue(xvar,xvar)
      nt=dimsizes(xvar)
      ds = new(nt-1,"float")
;      do it = 0,nt-2
;         ds(it) = xvar(it+1)-xvar(it)
;         if (abs(ds(it)).gt.0.002) then
;           print("WARNING: replaced salinity outlier "+flt2string(xvar(it+1))+" (it="+tostring(it)+") with previous value ("+flt2string(xvar(it))+").")
;           xvar(it+1) = xvar(it)
;         end if
;      end do
   else
      print("get_sssga: no sssga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mmflxd_max (inptr:file) 
begin
   if (isfilevar(inptr,"mmflxd_max")) then
      tmp = inptr->mmflxd_max(:,0)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Max AMOC 20-60N"
      xvar@units = "Sv"
      assignFillValue(xvar,xvar)
   else
      print("get_mmflxd_max: no mmflxd_max variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mmflxd265 (inptr:file) 
begin
   if (isfilevar(inptr,"mmflxd265")) then
      tmp = inptr->mmflxd265(:,0)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Max AMOC 26.5N"
      xvar@units = "Sv"
      assignFillValue(xvar,xvar)
   else
      print("get_mmflxd265: no mmflxd265 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mmflxd45 (inptr:file) 
begin
   if (isfilevar(inptr,"mmflxd45")) then
      tmp = inptr->mmflxd45(:,0)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Max AMOC 45N"
      xvar@units = "Sv"
      assignFillValue(xvar,xvar)
   else
      print("get_mmflxd45: no mmflxd45 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mmflxd_maxext (inptr:file) 
begin
   if (isfilevar(inptr,"mmflxd_max")) then
      dims = getfilevardimsizes(inptr,"mmflxd_max")
      if (dims(1) .eq. 2) then
          tmp = inptr->mmflxd_max(:,1)
          if (typeof(tmp).eq."double") then
             xvar = dble2flt(tmp)
          else
             xvar = tmp
          end if
          xvar = (/xvar*1.0e-9/)
          xvar@long_name = "Max AMOC 20-60N"
          xvar@units = "Sv"
          assignFillValue(xvar,xvar)
      else
          print("get_mmflxd_maxext: mmflxd of region atlantic_arctic_extended_ocean present")
          xvar = -999.0
      end if
   else
      print("get_mmflxd_maxext: no mmflxd_max variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mmflxd265ext (inptr:file) 
begin
   if (isfilevar(inptr,"mmflxd265")) then
      dims = getfilevardimsizes(inptr,"mmflxd265")
      if (dims(1) .eq. 2) then
          tmp = inptr->mmflxd265(:,1)
          if (typeof(tmp).eq."double") then
             xvar = dble2flt(tmp)
          else
             xvar = tmp
          end if
          xvar = (/xvar*1.0e-9/)
          xvar@long_name = "Max AMOC 26.5N"
          xvar@units = "Sv"
          assignFillValue(xvar,xvar)
      else
          print("get_mmflxd265ext: mmflxd of region atlantic_arctic_extended_ocean present")
          xvar = -999.0
      end if
   else
      print("get_mmflxd265ext: no mmflxd265 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mmflxd45ext (inptr:file) 
begin
   if (isfilevar(inptr,"mmflxd45")) then
      dims = getfilevardimsizes(inptr,"mmflxd45")
      if (dims(1) .eq. 2) then
          tmp = inptr->mmflxd45(:,1)
          if (typeof(tmp).eq."double") then
             xvar = dble2flt(tmp)
          else
             xvar = tmp
          end if
          xvar = (/xvar*1.0e-9/)
          xvar@long_name = "Max AMOC 45N"
          xvar@units = "Sv"
          assignFillValue(xvar,xvar)
      else
          print("get_mmflxd45ext: mmflxd of region atlantic_arctic_extended_ocean present")
          xvar = -999.0
      end if
   else
      print("get_mmflxd45ext: no mmflxd45 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_templvl (inptr:file) 
begin
   if (isfilevar(inptr,"templvl")) then
      tmp = inptr->templvl
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Temp"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
   else
      print("get_templvl: no templvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_salnlvl (inptr:file) 
begin
   if (isfilevar(inptr,"salnlvl")) then
      tmp = inptr->salnlvl
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Saln"
      xvar@units = "g kg-1"
      assignFillValue(xvar,xvar)
   else
      print("get_salnlvl: no salnlvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sst_clim (inptr:file) 
begin
   if (isfilevar(inptr,"sst_clim")) then
      tmp  = inptr->sst_clim
      xvar = new(12,float)
      if (typeof(tmp).eq."double") then
         do im=0,11
            xvar(im) = doubletofloat(tmp(im))
         end do
      else
         do im=0,11
            xvar(im) = tmp(im)
         end do
      end if
      xvar@long_name = "SST climatology"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
   else
      print("get_sst_clim: no sst_clim variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sst3 (inptr:file) 
begin
   if (isfilevar(inptr,"sst3")) then
      tmp  = inptr->sst3
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "NINO3 SST"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
   else
      print("get_sst3: no sst3 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sst34 (inptr:file) 
begin
   if (isfilevar(inptr,"sst34")) then
      tmp  = inptr->sst34
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "NINO3.4 SST"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
   else
      print("get_sst34: no sst34 variable present")
      xvar = -999.0
   end if
   return (xvar)
end


