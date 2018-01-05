; NCL script
; functions_latlon.ncl
; Johan Liakka, Dec 2017
;******************************************************************
 
function get_o2 (inptr:file,z:numeric,z0:numeric) 
begin
   if (isfilevar(inptr,"o2lvl")) then
      tmp3d = inptr->o2lvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Oxygen z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_o2: no o2lvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_si (inptr:file,z:numeric,z0:numeric)
begin
   if (isfilevar(inptr,"silvl")) then
      tmp3d = inptr->silvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Silicate z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_si: no silvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_po4 (inptr:file,z:numeric,z0:numeric)
begin
   if (isfilevar(inptr,"po4lvl")) then
      tmp3d = inptr->po4lvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Phosphate z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_po4: no po4lvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_no3 (inptr:file,z:numeric,z0:numeric)
begin
   if (isfilevar(inptr,"no3lvl")) then
      tmp3d = inptr->no3lvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Nitrate z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_no3: no no3lvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_dissic (inptr:file,z:numeric,z0:numeric)
begin
   if (isfilevar(inptr,"dissiclvl")) then
      tmp3d = inptr->dissiclvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "DIC z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "mol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_dissic: no dissiclvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end
