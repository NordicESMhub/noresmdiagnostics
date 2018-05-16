; NCL script
; functions_cycle.ncl
; Johan Liakka, Dec 2017
;******************************************************************

function get_srfo2 (inptr:file)
begin
   if (isfilevar(inptr,"srfo2")) then
      tmp = inptr->srfo2
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Surface oxygen"
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_srfo2: no srfo2 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_srfsi (inptr:file)
begin
   if (isfilevar(inptr,"srfsi")) then
      tmp = inptr->srfsi
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Surface silicate"
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_srfsi: no srfsi variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_srfpo4 (inptr:file)
begin
   if (isfilevar(inptr,"srfpo4")) then
      tmp = inptr->srfpo4
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Surface PO4"
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_srfpo4: no srfpo4 variable present")
      xvar = -999.0
   end if
   return (xvar)
end

function get_srfno3 (inptr:file)
begin
   if (isfilevar(inptr,"srfno3")) then
      tmp = inptr->srfno3
      if (typeof(tmp).eq."double") then
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar = (/xvar*1.0e+3/)
      xvar@long_name = "Surface nitrate"
      xvar@units = "mmol m-3"
      assignFillValue(xvar,xvar)
   else
      print("get_srfno3: no srfno3 variable present")
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
      xvar@long_name = "PP (vertically-integrated, offline)"
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
         xvar = dble2flt(tmp(:,0,0))
      else
         xvar = tmp(:,0,0)
      end if
      xvar@long_name = "PP (vertically-integrated,online)"
      xvar@units = "mol C m-2 yr-1"
      assignFillValue(xvar,xvar)
   else
      print("get_ppint: no ppint variable present")
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
