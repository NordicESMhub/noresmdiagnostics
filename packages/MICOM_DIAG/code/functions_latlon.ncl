; NCL script
; functions_latlon.ncl
; Johan Liakka, Dec 2017
;******************************************************************
 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_templvl (inptr:file,z:numeric,z0:numeric) 
begin
   if (isfilevar(inptr,"templvl")) then
      tmp3d = inptr->templvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Temperature z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "degC"
      assignFillValue(xvar,xvar)
   else
      print("get_templvl: no templvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_salnlvl (inptr:file,z:numeric,z0:numeric) 
begin
   if (isfilevar(inptr,"salnlvl")) then
      tmp3d = inptr->salnlvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Salinity z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "g/kg"
      assignFillValue(xvar,xvar)
   else
      print("get_salnlvl: no salnlvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_mld (inptr:file)
begin
   if (isfilevar(inptr,"mld")) then
      tmp = inptr->mld
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(0,:,:))
      else
         xvar = tmp(0,:,:)
      end if
      xvar@long_name = "Mixed layer depth"
      print(xvar@long_name)
      xvar@units = "m"
      assignFillValue(xvar,xvar)
   else
      print("get_mld: no mld variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_sealv (inptr:file)
begin
   if (isfilevar(inptr,"sealv")) then
      tmp = inptr->sealv
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(0,:,:))
      else
         xvar = tmp(0,:,:)
      end if
      xvar@long_name = "Sea level"
      print(xvar@long_name)
      xvar@units = "m"
      assignFillValue(xvar,xvar)
   else
      print("get_sealv: no sealv variable present")
      xvar = -999.0
   end if
   return (xvar)
end

