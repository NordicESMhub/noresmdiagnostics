; NCL script
; functions_time_series.ncl
; Johan Liakka, Nov 2017
; Yanchun He, Jun 2020
; Heiko Goelzer, Jan 2021
;******************************************************************
 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_imass (inptr:file) 
begin
   if (isfilevar(inptr,"imass")) then
      tmp = inptr->imass
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Ice mass"
      xvar@units = "kg"
      assignFillValue(xvar,xvar)
   else
      print("get_imass: no imass variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_imass_above_flotation (inptr:file) 
begin
   if (isfilevar(inptr,"imass_above_flotation")) then
      tmp = inptr->imass_above_flotation
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Ice mass above flotation"
      xvar@units = "kg"
      assignFillValue(xvar,xvar)
   else
      print("get_imass_above_flotation: no imass_above_flotation variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_iareag (inptr:file) 
begin
   if (isfilevar(inptr,"iareag")) then
      tmp = inptr->iareag
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-6/)
      xvar@long_name = "Grounded ice area"
      xvar@units = "km^2"
      assignFillValue(xvar,xvar)
   else
      print("get_iareag: no iareag variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_iareaf (inptr:file) 
begin
   if (isfilevar(inptr,"iareaf")) then
      tmp = inptr->iareaf
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-6/)
      xvar@long_name = "Floating ice area"
      xvar@units = "km^2"
      assignFillValue(xvar,xvar)
   else
      print("get_iareaf: no iareaf variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_total_smb_flux (inptr:file) 
begin
   if (isfilevar(inptr,"total_smb_flux")) then
      tmp = inptr->total_smb_flux
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-6/)
      xvar@long_name = "Total SMB flux"
      xvar@units = "kg/s"
      assignFillValue(xvar,xvar)
   else
      print("get_total_smb_flux: no total_smb_flux variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_total_calving_flux (inptr:file) 
begin
   if (isfilevar(inptr,"total_calving_flux")) then
      tmp = inptr->total_calving_flux
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Total calving flux"
      xvar@units = "kg/s"
      assignFillValue(xvar,xvar)
   else
      print("get_total_calving_flux: no total_calving_flux variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_total_gl_flux (inptr:file) 
begin
   if (isfilevar(inptr,"total_gl_flux")) then
      tmp = inptr->total_gl_flux
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-6/)
      xvar@long_name = "Total grounding line flux"
      xvar@units = "kg/s"
      assignFillValue(xvar,xvar)
   else
      print("get_total_gl_flux: no total_gl_flux variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_total_bmb_flux (inptr:file) 
begin
   if (isfilevar(inptr,"total_bmb_flux")) then
      tmp = inptr->total_bmb_flux
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-6/)
      xvar@long_name = "Total basal melt flux"
      xvar@units = "kg/s"
      assignFillValue(xvar,xvar)
   else
      print("get_total_bmb_flux: no total_bmb_flux variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_thkga (inptr:file) 
begin
   if (isfilevar(inptr,"thkga")) then
      tmp = inptr->thkga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
;      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Mean thickness"
      xvar@units = "km^3"
      assignFillValue(xvar,xvar)
   else
      print("get_thkga: no thkga variable present")
      xvar = -999.0
   end if
   print (xvar)
   return (xvar)
end

function get_smbga (inptr:file) 
begin
   if (isfilevar(inptr,"smbga")) then
      tmp = inptr->smbga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Mean smb"
      xvar@units = "mm/yr"
      assignFillValue(xvar,xvar)
   else
      print("get_smbga: no smbga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_artmga (inptr:file) 
begin
   if (isfilevar(inptr,"artmga")) then
      tmp = inptr->artmga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Mean temperature"
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
   else
      print("get_artmga: no artmga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_topgga (inptr:file) 
begin
   if (isfilevar(inptr,"topgga")) then
      tmp = inptr->topgga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Mean bedrock elevation"
      xvar@units = "m"
      assignFillValue(xvar,xvar)
   else
      print("get_topgga: no topgga variable present")
      xvar = -999.0
   end if
   return (xvar)
end


function get_usurfga (inptr:file) 
begin
   if (isfilevar(inptr,"usurfga")) then
      tmp = inptr->usurfga
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Mean surface elevation"
      xvar@units = "m"
      assignFillValue(xvar,xvar)
   else
      print("get_usurfga: no usurfga variable present")
      xvar = -999.0
   end if
   return (xvar)
end

