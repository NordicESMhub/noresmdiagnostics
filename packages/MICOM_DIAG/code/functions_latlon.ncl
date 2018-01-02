; NCL script
; functions_latlon.ncl
; Johan Liakka, Dec 2017
;******************************************************************
 
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/compute_rho.ncl"

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
;--------------------------------------------------------
; Compute mld by density changes in the uppermost layers
; (de Boyer Montegut et al. 2004)
;--------------------------------------------------------
begin
   if (isfilevar(inptr,"temp") .and. isfilevar(inptr,"saln") .and. isfilevar(inptr,"dz")) then
      print("Computing mld from density profiles...")
;     --------------
;     Read variables
;     --------------
      tmp = inptr->temp       ; READ temperature
      if (typeof(tmp).eq."double") then
         temp = dble2flt(tmp(0,:,:,:))
      else
         temp = tmp(0,:,:,:)
      end if
      assignFillValue(temp,temp)
      delete(tmp)
      tmp = inptr->saln      ; READ salinity
      if (typeof(tmp).eq."double") then
         saln = dble2flt(tmp(0,:,:,:))
      else
         saln = tmp(0,:,:,:)
      end if
      assignFillValue(saln,saln)
      delete(tmp)
      tmp = inptr->dz      ; READ dz
      if (typeof(tmp).eq."double") then
         dz = dble2flt(tmp(0,:,:,:))
      else
         dz = tmp(0,:,:,:)
      end if
      assignFillValue(dz,dz)
      delete(tmp)
;     --------------
;     Get dimensions
;     --------------
      dims = dimsizes(temp)
      nz = dims(0)
      nlat = dims(1)
      nlon = dims(2)
;     --------------
;     Define z
;     --------------
      zc = dz
      zc(:,:,:) = 0.0
      do iz = 0, nz-2
         zc(iz+1,:,:) = zc(iz,:,:) + dz(iz,:,:)
      end do
;     -------------------------
;     Define reference pressure
;     -------------------------
      pr = temp
      pr(:,:,:) = 0.0
;     -------------------
;     Define mld
;     -------------------
      xvar=temp(0,:,:) ; copy metadata
      xvar@long_name = "Mixed layer depth"
      xvar@units = "m"
      assignFillValue(xvar,xvar)
;     -------------------
;     Compute the density
;     -------------------
      sig0 = compute_rho(pr,temp,saln)
      delete(pr)
      delete(temp)
      delete(saln)
      sig0top=sig0(0,:,:)
;     -----------------------
;     Compute the mixed layer
;     -----------------------
      do ilat = 0,nlat-1
        do ilon = 0,nlon-1
       
          if ( .not.ismissing(xvar(ilat,ilon)) ) then
            sig0trg=sig0top(ilat,ilon)+0.03
            kz1 = 0
            kz2 = 0
	    first_find = 0
	    do iz = 0,nz-1
              if ( .not.ismissing(sig0(iz,ilat,ilon)) ) then
                if (sig0(iz,ilat,ilon).lt.sig0trg) then
                  kz1=iz
                end if
                if (sig0(iz,ilat,ilon).gt.sig0trg .and. first_find.eq.0) then
                  first_find=1
                  kz2=iz
                end if
              end if
            end do

            if (kz2.eq.0) then
              xvar(ilat,ilon)=zc(kz1+1,ilat,ilon)
            else
              xvar(ilat,ilon)=((sig0(kz2,ilat,ilon)-sig0trg)*(zc(kz1+1,ilat,ilon)+zc(kz1,ilat,ilon)) \
                 +(sig0trg-sig0(kz1,ilat,ilon))*(zc(kz2+1,ilat,ilon)+zc(kz2,ilat,ilon)))/(2*(sig0(kz2,ilat,ilon)-sig0(kz1,ilat,ilon)))
	    end if
          end if
        end do
      end do
      delete(sig0)
      delete(sig0top)
      delete(sig0trg)
      delete(zc)
      delete(kz1)
      delete(kz2)
      delete(first_find)
      delete(nlon)
      delete(nlat)
      delete(nz)
   else
      print("get_mld: no temp and/or saln and/or dz present: cannot compute mld.")
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
      xvar@long_name = "SSH"
      print(xvar@long_name)
      xvar@units = "m"
      assignFillValue(xvar,xvar)
   else
      print("get_sealv: no sealv variable present")
      xvar = -999.0
   end if
   return (xvar)
end



