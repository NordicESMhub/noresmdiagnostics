; NCL script
; functions_time_series.ncl
; Johan Liakka, Nov 2017
; Yanchun He, Jun 2020
; Heiko Goelzer, Jan 2021
;******************************************************************
 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_vol (inptr:file) 
begin
   if (isfilevar(inptr,"vol")) then
      tmp = inptr->vol
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e-9/)
      xvar@long_name = "Ice volume"
      xvar@units = "km^3"
      assignFillValue(xvar,xvar)
   else
      print("get_vol: no vol variable present")
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

