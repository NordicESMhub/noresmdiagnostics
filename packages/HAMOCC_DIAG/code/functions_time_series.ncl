; NCL script
; functions_time_series.ncl
; Johan Liakka, Nov 2017
;******************************************************************
 
function get_o2 (inptr:file) 
begin
   if (isfilevar(inptr,"o2")) then
      tmp = inptr->o2
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Oxygen"
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
   if (isfilevar(inptr,"si")) then
      tmp = inptr->si
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Silicate"
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
   if (isfilevar(inptr,"po4")) then
      tmp = inptr->po4
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Phosphate"
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
   if (isfilevar(inptr,"no3")) then
      tmp = inptr->no3
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar = (/xvar*1.0e3/)
      xvar@long_name = "Nitrate"
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
   if (isfilevar(inptr,"dissic")) then
      tmp = inptr->dissic
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp)
      else
         xvar = tmp
      end if
      xvar@long_name = "DIC"
      xvar@units = "mol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_dissic: no dissic variable present")
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
      xvar@long_name = "total primary production"
      xvar@units = "Pg yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_pp: no pp_tot variable present")
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
