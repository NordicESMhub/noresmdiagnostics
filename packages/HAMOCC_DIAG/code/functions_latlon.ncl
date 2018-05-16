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

function get_talk (inptr:file,z:numeric,z0:numeric)
begin
   if (isfilevar(inptr,"talklvl")) then
      tmp3d = inptr->talklvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(0,iz,:,:)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "TAlk z="+flt2string(z0)+"m"
      print(xvar@long_name)
      xvar@units = "mol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_talk: no talklvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_pp (inptr:file)
begin
   if (isfilevar(inptr,"pp_tot")) then
      tmp = inptr->pp_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(0,:,:))
      else
         xvar = tmp(0,:,:)
      end if
      xvar@long_name = "PP"
      print(xvar@long_name)
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_pp: no pp_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_ppint (inptr:file)
begin
   if (isfilevar(inptr,"ppint")) then
      tmp = inptr->ppint
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(0,:,:))
      else
         xvar = tmp(0,:,:)
      end if
      xvar  = xvar*365*24*3600
      xvar@long_name = "PP"
      print(xvar@long_name)
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_ppint: no ppint variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_epc (inptr:file)
begin
   if (isfilevar(inptr,"epc100")) then
      tmp = inptr->epc100
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(0,:,:))
      else
         xvar = tmp(0,:,:)
      end if
      xvar = (/xvar*86400*365/)
      xvar@long_name = "Export production"
      print(xvar@long_name)
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_epc: no epc100 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_pco2 (inptr:file)
begin
   if (isfilevar(inptr,"pco2")) then
      tmp = inptr->pco2
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(0,:,:))
      else
         xvar = tmp(0,:,:)
      end if
      xvar@long_name = "sea-surface pCO2"
      print(xvar@long_name)
      xvar@units = "uatm"
      assignFillValue(xvar,xvar)
   else
      print("get_pco2: no pco2 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_co2fxn (inptr:file)
begin
   if (isfilevar(inptr,"co2fxd") .and. isfilevar(inptr,"co2fxu")) then
      tmpd = inptr->co2fxd
      if (typeof(tmpd).eq."double") then
         xvard = dble2flt(tmpd(0,:,:))
      else
         xvard = tmpd(0,:,:)
      end if
      tmpu = inptr->co2fxu
      if (typeof(tmpu).eq."double") then
         xvaru = dble2flt(tmpu(0,:,:))
      else
         xvaru = tmpu(0,:,:)
      end if
      xvar = xvard
      xvar = xvard-xvaru
      xvar = (/xvar*86400*365*1000/12/)
      xvar@long_name = "net downward CO2 flux"
      print(xvar@long_name)
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_co2fxn: no co2fxd or co2fxu variables present")
      xvar = -999.0
   end if
   return (xvar)
end


