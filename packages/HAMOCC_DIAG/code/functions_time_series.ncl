; NCL script
; functions_time_series.ncl
; Johan Liakka, Nov 2017
;******************************************************************
 
function get_o2 (inptr:file) 
begin
   if (isfilevar(inptr,"o2") .or. isfilevar(inptr,"o2lvl")) then
      if (isfilevar(inptr,"o2lvl")) then
          tmp = inptr->o2lvl
          coords=" (depth)"
      else
          tmp = inptr->o2
          coords=" (sigma)"
      end if
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Oxygen"+coords
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_o2: no o2 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_si (inptr:file) 
begin
   if (isfilevar(inptr,"si") .or. isfilevar(inptr,"silvl")) then
      if (isfilevar(inptr,"silvl")) then
          tmp = inptr->silvl
          coords=" (depth)"
      else
          tmp = inptr->si
          coords=" (sigma)"
      end if
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Silicate"+coords
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_si: no si variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_po4 (inptr:file) 
begin
   if (isfilevar(inptr,"po4") .or. isfilevar(inptr,"po4lvl")) then
      if (isfilevar(inptr,"po4lvl")) then
          tmp = inptr->po4lvl
          coords=" (depth)"
      else
          tmp = inptr->po4
          coords=" (sigma)"
      end if
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Phosphate"+coords
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_po4: no po4 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_no3 (inptr:file) 
begin
   if (isfilevar(inptr,"no3") .or. isfilevar(inptr,"no3lvl")) then
      if (isfilevar(inptr,"no3lvl")) then
          tmp = inptr->no3lvl
          coords=" (depth)"
      else
          tmp = inptr->no3
          coords=" (sigma)"
      end if
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Nitrate"+coords
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_no3: no no3 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_dissic (inptr:file) 
begin
   if (isfilevar(inptr,"dissic") .or. isfilevar(inptr,"dissiclvl")) then
      if (isfilevar(inptr,"dissiclvl")) then
          tmp = inptr->dissiclvl
          coords=" (depth)"
      else
          tmp = inptr->dissic
          coords=" (sigma)"
      end if
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "DIC"+coords
      xvar@units = "mol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_dissic: no dissic variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_talk (inptr:file) 
begin
   if (isfilevar(inptr,"talk") .or. isfilevar(inptr,"talklvl")) then
      if (isfilevar(inptr,"talklvl")) then
          tmp = inptr->talklvl
          coords=" (depth)"
      else
          tmp = inptr->talk
          coords=" (sigma)"
      end if
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Alkalinity"+coords
      xvar@units = "eq m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_talk: no talk/talklvl variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_dissiclvl100m (inptr:file) 
begin
   if (isfilevar(inptr,"dissiclvl100m")) then
      tmp = inptr->dissiclvl100m
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "DIC (0-100m)"
      xvar@units = "mol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_dissic: no dissiclvl100m variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_talklvl100m (inptr:file) 
begin
   if (isfilevar(inptr,"talklvl100m")) then
      tmp = inptr->talklvl100m
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "Alkalinity (0-100m)"
      xvar@units = "eq m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_talk: no talklvl100m variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_co2fxd (inptr:file) 
begin
   if (isfilevar(inptr,"co2fxd_tot")) then
      tmp = inptr->co2fxd_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total downward CO2 flux"
      xvar@units = "Pg yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_co2fxd: no co2fxd_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_co2fxu (inptr:file) 
begin
   if (isfilevar(inptr,"co2fxu_tot")) then
      tmp = inptr->co2fxu_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total upward CO2 flux"
      xvar@units = "Pg yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_co2fxu: no co2fxu_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_co2fxn (inptr:file) 
begin
   if (isfilevar(inptr,"co2fxd_tot") .and. isfilevar(inptr,"co2fxu_tot")) then
      tmpd = inptr->co2fxd_tot
      if (typeof(tmpd).eq."double") then
         xvard = dble2flt(tmpd)
      else
         xvard = tmpd
      end if
      tmpu = inptr->co2fxu_tot
      if (typeof(tmpu).eq."double") then
         xvaru = dble2flt(tmpu)
      else
         xvaru = tmpu
      end if
      xvar = xvard
      xvar = xvard-xvaru
      xvar@long_name = "net downward CO2 flux"
      xvar@units = "Pg yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_co2fxn: no co2fxd_tot or co2fxu_tot variables present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_pp (inptr:file) 
begin
   if (isfilevar(inptr,"pp_tot")) then
      tmp = inptr->pp_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total primary production (pp)"
      xvar@units = "Pg C yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_pp: no pp_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_ppint (inptr:file) 
begin
   if (isfilevar(inptr,"ppint_tot")) then
      tmp = inptr->ppint_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total primary production (ppint)"
      xvar@units = "Pg C yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_ppint: no ppint_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_epc (inptr:file) 
begin
   if (isfilevar(inptr,"epc100_tot")) then
      tmp = inptr->epc100_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total export production"
      xvar@units = "Pg yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_epc: no epc100_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_epcalc (inptr:file) 
begin
   if (isfilevar(inptr,"epcalc100_tot")) then
      tmp = inptr->epcalc100_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total export CaCO3"
      xvar@units = "Pg yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_epcalc: no epcalc100_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_dmsflux (inptr:file) 
begin
   if (isfilevar(inptr,"dmsflux_tot")) then
      tmp = inptr->dmsflux_tot
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "total DMS flux"
      xvar@units = "TgS yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_dmsflux: no dmsflux_tot variable present")
      xvar = -999.0
   end if
   return (xvar)
end
