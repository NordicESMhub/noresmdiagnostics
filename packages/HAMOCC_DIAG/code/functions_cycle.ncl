; NCL script
; functions_latlon.ncl
; Johan Liakka, Dec 2017
;******************************************************************
 
function get_po4 (inptr:file,z:numeric,z0:numeric)
begin
   if (isfilevar(inptr,"po4lvl")) then
      tmp3d = inptr->po4lvl
      iz=ind(z.eq.z0)
      tmp = tmp3d(:,iz,0,0)
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "PO4 z="+flt2string(z0)+"m"
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_po4: no po4lvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_pp (inptr:file)
begin
   if (isfilevar(inptr,"pp_tot")) then
      tmp = inptr->pp_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar@long_name = "PP"
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_pp: no pp_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_pco2 (inptr:file)
begin
   if (isfilevar(inptr,"pco2")) then
      tmp = inptr->pco2
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar@long_name = "pCO2"
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
         xvard = dble2flt(tmpd(:,0,0))
      else
         xvard = tmpd(:,0,0)
      end if
      tmpu = inptr->co2fxu
      if (typeof(tmpu).eq."double") then
         xvaru = dble2flt(tmpu(:,0,0))
      else
         xvaru = tmpu(:,0,0)
      end if
      xvar = xvard
      xvar = xvard-xvaru
      xvar = (/xvar*86400*365*1000/12/)
      xvar@long_name = "CO2 flux"
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_co2fxn: no co2fxd or co2fxu variables present")
      xvar = -999.0
   end if
   return (xvar)
end
