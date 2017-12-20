; NCL script
; functions_time_series.ncl
; Johan Liakka, Nov 2017
;******************************************************************
 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_CLDHGH (inptr:file) 
begin
   if (isfilevar(inptr,"CLDHGH")) then
      tmp = inptr->CLDHGH
      if (typeof(tmp).eq."double") then
         cldhgh = dble2flt(tmp)
      else
         cldhgh = tmp
      end if
      cldhgh = (/cldhgh*100./)
      cldhgh@long_name = "High-level cloud"
      cldhgh@units = "percent"
      assignFillValue(cldhgh,cldhgh)
   else
      print("CLDHGH: no CLDHGH variable present")
      cldhgh = -999.0
   end if
   return (cldhgh)
end 

function get_CLDLOW (inptr:file) 
begin
   if (isfilevar(inptr,"CLDLOW")) then
      tmp = inptr->CLDLOW
      if (typeof(tmp).eq."double") then
         cldlow = dble2flt(tmp)
      else
         cldlow = tmp
      end if
      cldlow = (/cldlow*100./)
      cldlow@long_name = "Low-level cloud"
      cldlow@units = "percent"
      assignFillValue(cldlow,cldlow)
   else
      print("CLDLOW: no CLDLOW variable present")
      cldlow = -999.0
   end if    
   return (cldlow)
end 

function get_CLDMED (inptr:file) 
begin
   if (isfilevar(inptr,"CLDMED")) then
      tmp = inptr->CLDMED
      if (typeof(tmp).eq."double") then
         cldmed = dble2flt(tmp)
      else
         cldmed = tmp
      end if
      cldmed = (/cldmed*100./)
      cldmed@long_name = "Mid-level cloud"
      cldmed@units = "percent"
      assignFillValue(cldmed,cldmed)
   else
       print("CLDMED: no CLDMED variable present")
       cldmed = -999.0
   end if
   return (cldmed)
end 

function get_CLDTOT (inptr:file) 
begin
   if (isfilevar(inptr,"CLDTOT")) then
      tmp = inptr->CLDTOT
      if (typeof(tmp).eq."double") then
         cldtot = dble2flt(tmp)
      else
         cldtot = tmp
      end if
      cldtot = (/cldtot*100./)
      cldtot@long_name = "Total cloud"
      cldtot@units = "percent"
      assignFillValue(cldtot,cldtot)
   else
      print("CLDTOT: no CLDTOT variable present")
      cldtot = -999.0
   end if
   return (cldtot)
end 

function get_LWCFTOA (inptr:file)
begin
   if (isfilevar(inptr,"LWCF")) then     ; in ccm3.10
      tmp = inptr->LWCF
      if (typeof(tmp).eq."double") then
         lwcftoa = dble2flt(tmp)
      else
         lwcftoa = tmp
      end if
      lwcftoa@long_name = "TOA LW cloud forcing"
      lwcftoa@units = "W/m~S~2~N~"
      assignFillValue(lwcftoa,lwcftoa)
   else
      print("LWCFTOA: no LWCF variable present")
      lwcftoa = -999.0
   end if
   return (lwcftoa)
end

function get_PRECT (inptr:file)
begin
   if (isfilevar(inptr,"PRECT")) then
      prect = inptr->PRECT ; m/s
      tmp = prect
      tmp = (/prect*8.64e7/)  ; convert to mm/day
      if (typeof(tmp).eq."double") then
         prect = dble2flt(tmp)
      else
         prect = tmp
      end if
      prect@units = "mm/day"
      prect@long_name = "Precipitation rate"
      prect@derive_op = "PRECT*8.64e7"
      assignFillValue(prect,prect)
   else
      if (isfilevar(inptr,"PRECC")) then
         precc = inptr->PRECC   ; m/s
         precl = inptr->PRECL   ; m/s
         tmp = precc
         tmp = (/(precc+precl)*8.64e7/)  ; convert to mm/day
         if (typeof(tmp).eq."double") then
            prect = dble2flt(tmp)
         else
            prect = tmp
         end if
         prect@units = "mm/day"
         prect@long_name = "Precipitation rate"
         prect@derive_op = "(PRECC+PRECL)*8.64e7"
         assignFillValue(prect,prect)
      else
         prect = -999.0
      end if
   end if
   return (prect)
end

function get_Rnet (inptr:file)
begin
   if (isfilevar(inptr,"FSNT").and.isfilevar(inptr,"FLNT")) then
      tmp1 = inptr->FSNT
      tmp2 = inptr->FLNT
      if (typeof(tmp1).eq."double") then
         fsnt = dble2flt(tmp1)
      else
         fsnt = tmp1
      end if
      if (typeof(tmp2).eq."double") then
         flnt = dble2flt(tmp2)
      else
         flnt = tmp2
      end if
      Rnet = fsnt
      Rnet = fsnt - flnt
      Rnet@long_name = "net TOA radiation"
      Rnet@units = "W/m~S~2~N~"
      assignFillValue(Rnet,Rnet)
   else
      print("Rnet: no FSNT and FLNT variables present")
      Rnet = -999.0
   end if
   return (Rnet)
end

function get_SWCFTOA (inptr:file)
begin
   if (isfilevar(inptr,"SWCF")) then     ; in ccm3.10
      tmp = inptr->SWCF
      if (typeof(tmp).eq."double") then
         swcftoa = dble2flt(tmp)
      else
         swcftoa = tmp
      end if
      swcftoa@long_name = "TOA SW cloud forcing"
      swcftoa@units = "W/m~S~2~N~"
      assignFillValue(swcftoa,swcftoa)
   else
      print("SWCFTOA: no SWCF variable present")
      swcftoa = -999.0
   end if
   return (swcftoa)
end

function get_TREFHT (inptr:file)
begin
  if (isfilevar(inptr,"TREFHT")) then
     tmp = inptr->TREFHT
     if (typeof(tmp).eq."double") then
        trefht = dble2flt(tmp)
     else
        trefht = tmp
     end if
     trefht@long_name = "2-meter Air Temp"
     trefht@units = "K"
     assignFillValue(trefht,trefht)
  else
      print("TREFHT: no TREFHT variable present")
      trefht = -999.0
  end if
  return (trefht)
end 

; --- OBSERVATIONS ---

function get_CLDHGH_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->CLDHGH
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   cldhgh_obs = new(nt,"float")
   cldhgh_obs = tmp2
   cldhgh_obs@long_name = "High-level cloud"
   cldhgh_obs@units = "percent"
   assignFillValue(cldhgh_obs,cldhgh_obs)
   return(cldhgh_obs)
end

function get_CLDLOW_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->CLDLOW
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   cldlow_obs = new(nt,"float")
   cldlow_obs = tmp2
   cldlow_obs@long_name = "Low-level cloud"
   cldlow_obs@units = "percent"
   assignFillValue(cldlow_obs,cldlow_obs)
   return(cldlow_obs)
end 

function get_CLDMED_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->CLDMED
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   cldmed_obs = new(nt,"float")
   cldmed_obs = tmp2
   cldmed_obs@long_name = "Mid-level cloud"
   cldmed_obs@units = "percent"
   assignFillValue(cldmed_obs,cldmed_obs)
   return(cldmed_obs)
end 

function get_CLDTOT_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->CLDTOT
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   cldtot_obs = new(nt,"float")
   cldtot_obs = tmp2
   cldtot_obs@long_name = "Total cloud"
   cldtot_obs@units = "percent"
   assignFillValue(cldtot_obs,cldtot_obs)
   return(cldtot_obs)
end 

function get_LWCFTOA_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->LWCF
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   lwcf_obs = new(nt,"float")
   lwcf_obs = tmp2
   lwcf_obs@long_name = "TOA LW cloud forcing"
   lwcf_obs@units = "W/m~S~2~N~"
   assignFillValue(lwcf_obs,lwcf_obs)
   return(lwcf_obs)
end

function get_PRECT_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->PRECT
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   prect_obs = new(nt,"float")
   prect_obs = tmp2
   prect_obs@long_name = "Precipitation rate"
   prect_obs@units = "mm/day"
   assignFillValue(prect_obs,prect_obs)
   return(prect_obs)
end

function get_SWCFTOA_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->SWCF
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   swcf_obs = new(nt,"float")
   swcf_obs = tmp2
   swcf_obs@long_name = "TOA SW cloud forcing"
   swcf_obs@units = "W/m~S~2~N~"
   assignFillValue(swcf_obs,swcf_obs)
   return(swcf_obs)
end

function get_TREFHT_obs (inptr:file,nt:integer) 
begin
   tmp = inptr->TREFHT
   if (typeof(tmp).eq."double") then
      tmp2 = dble2flt(tmp)
   else
      tmp2 = tmp
   end if
   trefht_obs = new(nt,"float")
   trefht_obs = tmp2
   trefht_obs@long_name = "2-meter Air Temp"
   trefht_obs@units = "K"
   assignFillValue(trefht_obs,trefht_obs)
   return(trefht_obs)
end


