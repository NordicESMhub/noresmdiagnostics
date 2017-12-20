;***************************************************************
; This script is a copy of pre_process.ncl. It has been modified
; to process regional polar averages for plotting.
; Laura Landrum
; October, 2009
; December, 2009	Added Bering Sea, Sea of Okhotsk, Hudson
;			Bay and Canadian Archipelago regions and
;			modified Labrador Sea a bit.
;***************************************************************
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

wkdir = getenv("PATHDAT")
case = getenv("CASE_READ")
pre_proc_dir = getenv("PRE_PROC_DIR")
pre_proc_file = getenv("PRE_PROC_FILE")
yr1 = getenv("YR1")
yr2 = getenv("YR2")
nyears = stringtointeger(getenv("NYEARS"))
nyr1 = stringtointeger(getenv("YR1"))

;if (nyears .gt. 1) then
;   fnames = wkdir+"/"+case+".*.h.{"+sprinti("%0.4i",nyr1)
;
;   do nn = 1, nyears-1
;     fnames = fnames+","+sprinti("%0.4i",nyr1+nn)
;  end do

;  fnames = fnames+"}*.nc"

;else
;   fnames = wkdir+"/"+case+".cice.h."+sprinti("%0.4i",nyr1)+"*.nc"
;end if
;****************************************************************
; Boundary areas for regional masks:
; Northern Hemisphere:
;       Lab            Lab Sea
;       GIN            GIN Sea
;       Bar            Barents/Kara Sea
;       ArcOc          Arctic Ocean
;       Sib            Siberian Sea
;       Beau           Beaufort Sea
;       CArc           Central Arctic
;       Bering         Bering Sea
;       Okhotsk        Sea of Okhotsk
;       Hudson         Hudson Bay
;       CAArch         Canadian Archipelago
;
;Southern Hemisphere:
;       Wed            Weddell Sea
;       Ross           Ross Sea
;       Ind            Indian sector
;       Pac            Pacific sector
;       BAm            Bellingshausen-Amundsen Sea
;
;******************************************************************

Lab_lat = (/50.,78./)
Lab_long = (/284.,315./)
GIN_lat = (/65.,80./)
GIN_long1 = (/315.,360./)
GIN_long2 = (/0.,15./)
Bar_lat = (/66.,80./)
Bar_long = (/15.,100./)
ArcOc_lat1 = (/80.,90./)
ArcOc_lat2 = ArcOc_lat1
ArcOc_lat3 = (/68.,90./)
ArcOc_long1 = (/243.,360./)
ArcOc_long2 = (/0.,100./)
ArcOc_long3 = (/100.,243./)
Sib_lat = (/68.,80./)
Sib_long = (/100.,192./)
Beau_lat = (/68.,80./)
Beau_long = (/192.,243./)
CArc_lat = (/80.,90./)
CArc_long = (/0.,360./)
;---------------------------------------------------------------
; These Arctic regions are more complicated geographically
; and will be defined by polygons rather than min,max lat,lon
;--------------------------------------------------------------
Lab_poly_lat = (/50., 64., 74., 78., 78., 50./)
Lab_poly_long = (/295., 292., 280., 280., 315., 315./)
Bering_poly_lat = (/56., 60., 68., 68., 58., 52.5, 52.5/)
Bering_poly_long = (/162., 162., 178., 200., 204., 190., 180./)
Okhotsk_poly_lat = (/44., 44., 46., 51., 60., 64., 60., 55., 44./)
Okhotsk_poly_long = (/142., 145., 150., 157., 162., 168., 140., 133., 142./)
Hudson_poly_lat = (/50., 66., 66., 70., 70., 68., 62., 60., 50./)
Hudson_poly_long = (/265., 265., 274., 274., 290., 290., 292., 295., 295./)
CAArch_poly_lat = (/67., 80., 80., 70., 67./)
CAArch_poly_long = (/243., 243., 281., 281., 275./)
; ------SH regions------------------
Wed_lat = (/-90.,-50./)
Wed_long1 = (/300.,360./)
Wed_long2 = (/0.,20./)
Ross_lat = (/-90.,-50./)
Ross_long = (/160.,220./)
Ind_lat = (/-90.,-50./)
Ind_long = (/20.,90./)
Pac_lat = (/-90.,-50./)
Pac_long = (/90.,160./)
BAm_lat = (/-90.,-50./)
BAm_long = (/220.,300./)

vai_mo_nh = new((/nyears*12/),float)
ext_mo_nh = new((/nyears*12/),float)
vhi_mo_nh = new((/nyears*12/),float)
vhs_mo_nh = new((/nyears*12/),float)
vai_mo_sh = new((/nyears*12/),float)
ext_mo_sh = new((/nyears*12/),float)
vhi_mo_sh = new((/nyears*12/),float)
vhs_mo_sh = new((/nyears*12/),float)

;*****************************
; regional arrays: Arctic
;*****************************
vai_mo_Lab = new((/nyears*12/),float)
vhi_mo_Lab = new((/nyears*12/),float)
vhs_mo_Lab = new((/nyears*12/),float)
vai_mo_GIN = new((/nyears*12/),float)
vhi_mo_GIN = new((/nyears*12/),float)
vhs_mo_GIN = new((/nyears*12/),float)
vai_mo_Bar = new((/nyears*12/),float)
vhi_mo_Bar = new((/nyears*12/),float)
vhs_mo_Bar = new((/nyears*12/),float)
vai_mo_ArcOc = new((/nyears*12/),float)
vhi_mo_ArcOc = new((/nyears*12/),float)
vhs_mo_ArcOc = new((/nyears*12/),float)
vai_mo_Sib = new((/nyears*12/),float)
vhi_mo_Sib = new((/nyears*12/),float)
vhs_mo_Sib = new((/nyears*12/),float)
vai_mo_Beau = new((/nyears*12/),float)
vhi_mo_Beau = new((/nyears*12/),float)
vhs_mo_Beau = new((/nyears*12/),float)
vai_mo_CArc = new((/nyears*12/),float)
vhi_mo_CArc = new((/nyears*12/),float)
vhs_mo_CArc = new((/nyears*12/),float)
vai_mo_Bering = new((/nyears*12/),float)
vhi_mo_Bering = new((/nyears*12/),float)
vhs_mo_Bering = new((/nyears*12/),float)
vai_mo_Okhotsk = new((/nyears*12/),float)
vhi_mo_Okhotsk = new((/nyears*12/),float)
vhs_mo_Okhotsk = new((/nyears*12/),float)
vai_mo_Hudson = new((/nyears*12/),float)
vhi_mo_Hudson = new((/nyears*12/),float)
vhs_mo_Hudson = new((/nyears*12/),float)
vai_mo_CAArch = new((/nyears*12/),float)
vhi_mo_CAArch = new((/nyears*12/),float)
vhs_mo_CAArch = new((/nyears*12/),float)
;*****************************
; regional arrays: Antarctic
;*****************************
vai_mo_Wed = new((/nyears*12/),float)
vhi_mo_Wed = new((/nyears*12/),float)
vhs_mo_Wed = new((/nyears*12/),float)
vai_mo_Ross = new((/nyears*12/),float)
vhi_mo_Ross = new((/nyears*12/),float)
vhs_mo_Ross = new((/nyears*12/),float)
vai_mo_Ind = new((/nyears*12/),float)
vhi_mo_Ind = new((/nyears*12/),float)
vhs_mo_Ind = new((/nyears*12/),float)
vai_mo_Pac = new((/nyears*12/),float)
vhi_mo_Pac = new((/nyears*12/),float)
vhs_mo_Pac = new((/nyears*12/),float)
vai_mo_BAm = new((/nyears*12/),float)
vhi_mo_BAm = new((/nyears*12/),float)
vhs_mo_BAm = new((/nyears*12/),float)

time = new((/nyears*12/),float)

do nn = 0, nyears-1

   imo1 = 12*nn
   imo2 = 12*nn+11

   fnames = wkdir+"/"+case+".cice.h."+sprinti("%0.4i",nyr1+nn)+"*.nc"
   files = systemfunc("ls "+fnames)
   f    = addfiles (files, "r")                 ; note the "s" of addfile

   tarea = f[0]->tarea
   tlat  = f[0]->TLAT
   tlon = f[0]->TLON

   if (.not.isatt(tlon,"_FillValue")) then              ;tlon missing fill value
      if (max(tlon) .gt. 360.) then
         tlon@_FillValue = max(tlon)
      else
         if (min(tlon) .lt. 0.) then
            tlon@_FillValue = min(tlon)
         end if
      end if
   end if
   if (.not.isatt(tlat,"_FillValue")) then              ;tlat missing fill value
      if (max(tlat) .gt. 90.) then
         tlat@_FillValue = max(tlat)
      else
         if (min(tlat) .lt. -90.) then
            tlat@_FillValue = min(tlat)
         end if
      end if
   end if

   time1 = addfiles_GetVar (f, files, "time")
   hi    = addfiles_GetVar (f, files, "hi")
   ai    = addfiles_GetVar (f, files, "aice")
   hs    = addfiles_GetVar (f, files, "hs")

   max_val = max(ai)
   if (max_val.le.1) then
      ai=ai*100.
   end if

   nrank = dimsizes(dimsizes(tlat))

   if (nrank .eq. 3) then
      tlat2 = conform(hi,tlat(0,:,:),(/1,2/))
      tlon2 = conform(hi,tlon(0,:,:),(/1,2/))
      vhi = hi*conform(hi,tarea(0,:,:),(/1,2/))
      vai = ai*conform(ai,tarea(0,:,:),(/1,2/))
      ext = where(ai.ge.15.,1.,0.)*conform(ai,tarea(0,:,:),(/1,2/))
      vhs = hs*conform(hs,tarea(0,:,:),(/1,2/))
   else
      tlat2 = conform(hi,tlat,(/1,2/))
      tlon2 = conform(hi,tlon,(/1,2/))
      vhi = hi*conform(hi,tarea,(/1,2/))
      vai = ai*conform(ai,tarea,(/1,2/))
      ext = where(ai.ge.15.,1.,0.)*conform(ai,tarea,(/1,2/))
      vhs = hs*conform(hs,tarea,(/1,2/))
   end if
;-------------------------------------------------------------
; create masks for Labrador Sea, Bering Sea, Sea of Okhotsk,
; Hudson Bay and Canadian Archipelago here. They are not simply
; rectangles...........
; Only need to do this once (first year of nyears)
;------------------------------------------------------------
   if (nn .eq. 0) then
      Lab_mask = new(dimsizes(vhi),typeof(vhi),vhi@_FillValue)
      Bering_mask = new(dimsizes(vhi),typeof(vhi),vhi@_FillValue)
      Okhotsk_mask = new(dimsizes(vhi),typeof(vhi),vhi@_FillValue)
      CAArch_mask = new(dimsizes(vhi),typeof(vhi),vhi@_FillValue)
      Hudson_mask = new(dimsizes(vhi),typeof(vhi),vhi@_FillValue)
      np = dimsizes(tlat)
      nlat = np(0)
      nlon = np(1)
      do i=0,nlat-1
         zlat = ind(.not.ismissing(tlat(i,:)))
         zlon = ind(.not.ismissing(tlon(i,:)))
         j1 = min((/min(zlat),min(zlon)/))
         j2 = max((/max(zlat),max(zlon)/))
         delete(zlat)
         delete(zlon)
;detivan
         if (ismissing(j1) .or. ismissing(j2)) then
             continue
         end if
;detivan
         do j=j1,j2
	    plat = tlat(i,j)
            plon = tlon(i,j)
            if .not.(ismissing(plat) .or. ismissing(plon)) then
 	    if ((plat.ge.min(Okhotsk_poly_lat)).and.(plon.ge.min(Okhotsk_poly_long))) then
               Lab_inout = gc_inout(plat,plon,Lab_poly_lat,Lab_poly_long)
               Bering_inout = gc_inout(plat,plon,Bering_poly_lat,Bering_poly_long)
               Okhotsk_inout = gc_inout(plat,plon,Okhotsk_poly_lat,Okhotsk_poly_long)
               Hudson_inout = gc_inout(plat,plon,Hudson_poly_lat,Hudson_poly_long)
               CAArch_inout = gc_inout(plat,plon,CAArch_poly_lat,CAArch_poly_long)
               if (Lab_inout .eq. True) then
	           Lab_mask(:,i,j) = 1.
	       end if
               if (Bering_inout .eq. True) then
                  Bering_mask(:,i,j) = 1.
               end if
               if (Okhotsk_inout .eq. True) then
                  Okhotsk_mask(:,i,j) = 1.
               end if
               if (Hudson_inout .eq. True) then
                  Hudson_mask(:,i,j) = 1.
               end if
               if (CAArch_inout .eq. True) then
                  CAArch_mask(:,i,j) = 1.
               end if
	    end if
            end if
         end do
      end do
   end if

   vhi_nh = mask(vhi,(tlat2.ge.0.),True)
   vai_nh = mask(vai,(tlat2.ge.0.),True)
   ext_nh = mask(ext,(tlat2.ge.0.),True)
   vhs_nh = mask(vhs,(tlat2.ge.0.),True)

   vhi_sh = mask(vhi,(tlat2.ge.0.),False)
   vai_sh = mask(vai,(tlat2.ge.0.),False)
   ext_sh = mask(ext,(tlat2.ge.0.),False)
   vhs_sh = mask(vhs,(tlat2.ge.0.),False)

   vhi_Lab = mask(vhi,(Lab_mask .eq. 1.), True)
   vai_Lab = mask(vai,(Lab_mask .eq. 1.), True)
   vhs_Lab = mask(vhs,(Lab_mask .eq. 1.), True)
 
   vhi_GIN = mask(vhi,(tlat2.ge.GIN_lat(0) .and. tlat2.le.GIN_lat(1) .and.\
                  ((tlon2.ge.GIN_long1(0) .and. tlon2.le.GIN_long1(1)) .or.\
		   (tlon2.ge.GIN_long2(0) .and. tlon2.le.GIN_long2(1)))), True)
   vai_GIN = mask(vai,(tlat2.ge.GIN_lat(0) .and. tlat2.le.GIN_lat(1) .and.\
                  ((tlon2.ge.GIN_long1(0) .and. tlon2.le.GIN_long1(1)) .or.\
                   (tlon2.ge.GIN_long2(0) .and. tlon2.le.GIN_long2(1)))), True)
   vhs_GIN = mask(vhs,(tlat2.ge.GIN_lat(0) .and. tlat2.le.GIN_lat(1) .and.\
                  ((tlon2.ge.GIN_long1(0) .and. tlon2.le.GIN_long1(1)) .or.\
                   (tlon2.ge.GIN_long2(0) .and. tlon2.le.GIN_long2(1)))), True)
   vhi_Bar = mask(vhi,(tlat2.ge.Bar_lat(0) .and. tlat2.le.Bar_lat(1) .and.\
                  tlon2.ge.Bar_long(0) .and. tlon2.le.Bar_long(1)), True)
   vai_Bar = mask(vai,(tlat2.ge.Bar_lat(0) .and. tlat2.le.Bar_lat(1) .and.\
                  tlon2.ge.Bar_long(0) .and. tlon2.le.Bar_long(1)), True)
   vhs_Bar = mask(vhs,(tlat2.ge.Bar_lat(0) .and. tlat2.le.Bar_lat(1) .and.\
                  tlon2.ge.Bar_long(0) .and. tlon2.le.Bar_long(1)), True)

   vhi_ArcOc = mask(vhi,((tlat2.ge.ArcOc_lat1(0) .and. (tlon2.ge.ArcOc_long1(0) .or.\
                  tlon2.le.ArcOc_long2(1))) .or. (tlat2.ge.ArcOc_lat3(0) .and.\
                   (tlon2.ge.ArcOc_long3(0) .and. tlon2.le.ArcOc_long3(1)))), True)
   vai_ArcOc = mask(vai,((tlat2.ge.ArcOc_lat1(0) .and. (tlon2.ge.ArcOc_long1(0) .or.\
                  tlon2.le.ArcOc_long2(1))) .or. (tlat2.ge.ArcOc_lat3(0) .and.\
                   (tlon2.ge.ArcOc_long3(0) .and. tlon2.le.ArcOc_long3(1)))), True)
   vhs_ArcOc = mask(vhs,((tlat2.ge.ArcOc_lat1(0) .and. (tlon2.ge.ArcOc_long1(0) .or.\
                  tlon2.le.ArcOc_long2(1))) .or. (tlat2.ge.ArcOc_lat3(0) .and.\
                   (tlon2.ge.ArcOc_long3(0) .and. tlon2.le.ArcOc_long3(1)))), True)

   vhi_Sib = mask(vhi,(tlat2.ge.Sib_lat(0) .and. tlat2.le.Sib_lat(1) .and.\
                  tlon2.ge.Sib_long(0) .and. tlon2.le.Sib_long(1)), True)
   vai_Sib = mask(vai,(tlat2.ge.Sib_lat(0) .and. tlat2.le.Sib_lat(1) .and.\
                  tlon2.ge.Sib_long(0) .and. tlon2.le.Sib_long(1)), True)
   vhs_Sib = mask(vhs,(tlat2.ge.Sib_lat(0) .and. tlat2.le.Sib_lat(1) .and.\
                  tlon2.ge.Sib_long(0) .and. tlon2.le.Sib_long(1)), True)

   vhi_Beau = mask(vhi,(tlat2.ge.Beau_lat(0) .and. tlat2.le.Beau_lat(1) .and.\
                  tlon2.ge.Beau_long(0) .and. tlon2.le.Beau_long(1)), True)
   vai_Beau = mask(vai,(tlat2.ge.Beau_lat(0) .and. tlat2.le.Beau_lat(1) .and.\
                  tlon2.ge.Beau_long(0) .and. tlon2.le.Beau_long(1)), True)
   vhs_Beau = mask(vhs,(tlat2.ge.Beau_lat(0) .and. tlat2.le.Beau_lat(1) .and.\
                  tlon2.ge.Beau_long(0) .and. tlon2.le.Beau_long(1)), True)

   vhi_CArc = mask(vhi,(tlat2.ge.CArc_lat(0) .and. tlat2.le.CArc_lat(1) .and.\
                  tlon2.ge.CArc_long(0) .and. tlon2.le.CArc_long(1)), True)
   vai_CArc = mask(vai,(tlat2.ge.CArc_lat(0) .and. tlat2.le.CArc_lat(1) .and.\
                  tlon2.ge.CArc_long(0) .and. tlon2.le.CArc_long(1)), True)
   vhs_CArc = mask(vhs,(tlat2.ge.CArc_lat(0) .and. tlat2.le.CArc_lat(1) .and.\
                  tlon2.ge.CArc_long(0) .and. tlon2.le.CArc_long(1)), True)

   vhi_Bering = mask(vhi,(Bering_mask .eq. 1.), True)
   vai_Bering = mask(vai,(Bering_mask .eq. 1.), True)
   vhs_Bering = mask(vhs,(Bering_mask .eq. 1.), True)

   vhi_Okhotsk = mask(vhi,(Okhotsk_mask .eq. 1.), True)
   vai_Okhotsk = mask(vai,(Okhotsk_mask .eq. 1.), True)
   vhs_Okhotsk = mask(vhs,(Okhotsk_mask .eq. 1.), True)

   vhi_Hudson = mask(vhi,(Hudson_mask .eq. 1.), True)
   vai_Hudson = mask(vai,(Hudson_mask .eq. 1.), True)
   vhs_Hudson = mask(vhs,(Hudson_mask .eq. 1.), True)

   vhi_CAArch = mask(vhi,(CAArch_mask .eq. 1.), True)
   vai_CAArch = mask(vai,(CAArch_mask .eq. 1.), True)
   vhs_CAArch = mask(vhs,(CAArch_mask .eq. 1.), True)

   vhi_Wed = mask(vhi,(tlat2.le.Wed_lat(1) .and. ((tlon2.ge.Wed_long1(0) \
                  .and. tlon2.le.Wed_long1(1)) .or. (tlon2.ge.Wed_long2(0) \
                   .and. tlon2.le.Wed_long2(1)))), True)
   vai_Wed = mask(vai,(tlat2.le.Wed_lat(1) .and.((tlon2.ge.Wed_long1(0) \
                  .and. tlon2.le.Wed_long1(1)) .or. (tlon2.ge.Wed_long2(0) \
                  .and. tlon2.le.Wed_long2(1)))), True)
   vhs_Wed = mask(vhs,(tlat2.le.Wed_lat(1) .and. ((tlon2.ge.Wed_long1(0) \ 
                  .and. tlon2.le.Wed_long1(1)) .or. (tlon2.ge.Wed_long2(0) \
		  .and. tlon2.le.Wed_long2(1)))), True)

   vhi_Ross = mask(vhi,(tlat2.le.Ross_lat(1) .and. tlon2.ge.Ross_long(0) \
		   .and. tlon2.le.Ross_long(1)), True)
   vai_Ross = mask(vai,(tlat2.le.Ross_lat(1) .and. tlon2.ge.Ross_long(0) \
		   .and. tlon2.le.Ross_long(1)), True)
   vhs_Ross = mask(vhs,(tlat2.le.Ross_lat(1) .and. tlon2.ge.Ross_long(0) \
		   .and. tlon2.le.Ross_long(1)), True)

   vhi_Ind = mask(vhi,(tlat2.le.Ind_lat(1) .and. tlon2.ge.Ind_long(0) \
                   .and. tlon2.le.Ind_long(1)), True)
   vai_Ind = mask(vai,(tlat2.le.Ind_lat(1) .and. tlon2.ge.Ind_long(0) \
                   .and. tlon2.le.Ind_long(1)), True)
   vhs_Ind = mask(vhs,(tlat2.le.Ind_lat(1) .and. tlon2.ge.Ind_long(0) \
                   .and. tlon2.le.Ind_long(1)), True)

   vhi_Pac = mask(vhi,(tlat2.le.Pac_lat(1) .and. tlon2.ge.Pac_long(0) \
                   .and. tlon2.le.Pac_long(1)), True)
   vai_Pac = mask(vai,(tlat2.le.Pac_lat(1) .and. tlon2.ge.Pac_long(0) \
                   .and. tlon2.le.Pac_long(1)), True)
   vhs_Pac = mask(vhs,(tlat2.le.Pac_lat(1) .and. tlon2.ge.Pac_long(0) \
                   .and. tlon2.le.Pac_long(1)), True)

   vhi_BAm = mask(vhi,(tlat2.le.BAm_lat(1) .and. tlon2.ge.BAm_long(0) \
                   .and. tlon2.le.BAm_long(1)), True)
   vai_BAm = mask(vai,(tlat2.le.BAm_lat(1) .and. tlon2.ge.BAm_long(0) \
                   .and. tlon2.le.BAm_long(1)), True)
   vhs_BAm = mask(vhs,(tlat2.le.BAm_lat(1) .and. tlon2.ge.BAm_long(0) \
                   .and. tlon2.le.BAm_long(1)), True)
;********************************
; northern hemisphere monthly ...
;********************************

   vhi_mo_nh(imo1:imo2) = dim_sum(dim_sum(vhi_nh))*1.0e-13 
   vai_mo_nh(imo1:imo2) = dim_sum(dim_sum(vai_nh))*1.0e-14 
   ext_mo_nh(imo1:imo2) = dim_sum(dim_sum(ext_nh))*1.0e-12
   vhs_mo_nh(imo1:imo2) = dim_sum(dim_sum(vhs_nh))*1.0e-13 

   vhi_mo_Lab(imo1:imo2) = dim_sum(dim_sum(vhi_Lab))*1.0e-13 
   vai_mo_Lab(imo1:imo2) = dim_sum(dim_sum(vai_Lab))*1.0e-14 
   vhs_mo_Lab(imo1:imo2) = dim_sum(dim_sum(vhs_Lab))*1.0e-13
 
   vhi_mo_GIN(imo1:imo2) = dim_sum(dim_sum(vhi_GIN))*1.0e-13 
   vai_mo_GIN(imo1:imo2) = dim_sum(dim_sum(vai_GIN))*1.0e-14 
   vhs_mo_GIN(imo1:imo2) = dim_sum(dim_sum(vhs_GIN))*1.0e-13
 
   vhi_mo_Bar(imo1:imo2) = dim_sum(dim_sum(vhi_Bar))*1.0e-13 
   vai_mo_Bar(imo1:imo2) = dim_sum(dim_sum(vai_Bar))*1.0e-14 
   vhs_mo_Bar(imo1:imo2) = dim_sum(dim_sum(vhs_Bar))*1.0e-13
 
   vhi_mo_ArcOc(imo1:imo2) = dim_sum(dim_sum(vhi_ArcOc))*1.0e-13 
   vai_mo_ArcOc(imo1:imo2) = dim_sum(dim_sum(vai_ArcOc))*1.0e-14 
   vhs_mo_ArcOc(imo1:imo2) = dim_sum(dim_sum(vhs_ArcOc))*1.0e-13 

   vhi_mo_Sib(imo1:imo2) = dim_sum(dim_sum(vhi_Sib))*1.0e-13 
   vai_mo_Sib(imo1:imo2) = dim_sum(dim_sum(vai_Sib))*1.0e-14 
   vhs_mo_Sib(imo1:imo2) = dim_sum(dim_sum(vhs_Sib))*1.0e-13 

   vhi_mo_Beau(imo1:imo2) = dim_sum(dim_sum(vhi_Beau))*1.0e-13 
   vai_mo_Beau(imo1:imo2) = dim_sum(dim_sum(vai_Beau))*1.0e-14 
   vhs_mo_Beau(imo1:imo2) = dim_sum(dim_sum(vhs_Beau))*1.0e-13
 
   vhi_mo_CArc(imo1:imo2) = dim_sum(dim_sum(vhi_CArc))*1.0e-13 
   vai_mo_CArc(imo1:imo2) = dim_sum(dim_sum(vai_CArc))*1.0e-14 
   vhs_mo_CArc(imo1:imo2) = dim_sum(dim_sum(vhs_CArc))*1.0e-13 

   vhi_mo_Bering(imo1:imo2) = dim_sum(dim_sum(vhi_Bering))*1.0e-13 
   vai_mo_Bering(imo1:imo2) = dim_sum(dim_sum(vai_Bering))*1.0e-14 
   vhs_mo_Bering(imo1:imo2) = dim_sum(dim_sum(vhs_Bering))*1.0e-13

   vhi_mo_Okhotsk(imo1:imo2) = dim_sum(dim_sum(vhi_Okhotsk))*1.0e-13 
   vai_mo_Okhotsk(imo1:imo2) = dim_sum(dim_sum(vai_Okhotsk))*1.0e-14 
   vhs_mo_Okhotsk(imo1:imo2) = dim_sum(dim_sum(vhs_Okhotsk))*1.0e-13

   vhi_mo_Hudson(imo1:imo2) = dim_sum(dim_sum(vhi_Hudson))*1.0e-13 
   vai_mo_Hudson(imo1:imo2) = dim_sum(dim_sum(vai_Hudson))*1.0e-14 
   vhs_mo_Hudson(imo1:imo2) = dim_sum(dim_sum(vhs_Hudson))*1.0e-13

   vhi_mo_CAArch(imo1:imo2) = dim_sum(dim_sum(vhi_CAArch))*1.0e-13 
   vai_mo_CAArch(imo1:imo2) = dim_sum(dim_sum(vai_CAArch))*1.0e-14 
   vhs_mo_CAArch(imo1:imo2) = dim_sum(dim_sum(vhs_CAArch))*1.0e-13
;********************************
; southern hemisphere monthly ...
;********************************

   vhi_mo_sh(imo1:imo2) = dim_sum(dim_sum(vhi_sh))*1.0e-13 
   vai_mo_sh(imo1:imo2) = dim_sum(dim_sum(vai_sh))*1.0e-14 
   ext_mo_sh(imo1:imo2) = dim_sum(dim_sum(ext_sh))*1.0e-12
   vhs_mo_sh(imo1:imo2) = dim_sum(dim_sum(vhs_sh))*1.0e-13 

   vhi_mo_Wed(imo1:imo2) = dim_sum(dim_sum(vhi_Wed))*1.0e-13 
   vai_mo_Wed(imo1:imo2) = dim_sum(dim_sum(vai_Wed))*1.0e-14 
   vhs_mo_Wed(imo1:imo2) = dim_sum(dim_sum(vhs_Wed))*1.0e-13

   vhi_mo_Ross(imo1:imo2) = dim_sum(dim_sum(vhi_Ross))*1.0e-13 
   vai_mo_Ross(imo1:imo2) = dim_sum(dim_sum(vai_Ross))*1.0e-14 
   vhs_mo_Ross(imo1:imo2) = dim_sum(dim_sum(vhs_Ross))*1.0e-13

   vhi_mo_Ind(imo1:imo2) = dim_sum(dim_sum(vhi_Ind))*1.0e-13 
   vai_mo_Ind(imo1:imo2) = dim_sum(dim_sum(vai_Ind))*1.0e-14 
   vhs_mo_Ind(imo1:imo2) = dim_sum(dim_sum(vhs_Ind))*1.0e-13

   vhi_mo_Pac(imo1:imo2) = dim_sum(dim_sum(vhi_Pac))*1.0e-13 
   vai_mo_Pac(imo1:imo2) = dim_sum(dim_sum(vai_Pac))*1.0e-14 
   vhs_mo_Pac(imo1:imo2) = dim_sum(dim_sum(vhs_Pac))*1.0e-13

   vhi_mo_BAm(imo1:imo2) = dim_sum(dim_sum(vhi_BAm))*1.0e-13 
   vai_mo_BAm(imo1:imo2) = dim_sum(dim_sum(vai_BAm))*1.0e-14 
   vhs_mo_BAm(imo1:imo2) = dim_sum(dim_sum(vhs_BAm))*1.0e-13

;   print(time1)
   time(imo1:imo2) = time1
   if (time(imo2) .lt. 0.) then
      time(imo2) = 25915
   end if

end do ; nn

time@units = time1@units
;print(time)
;print(vhi_mo_nh)

vai_mo_nh!0 = "time"
vai_mo_nh&time = time
vai_mo_nh@units = "1.E+12 m2"
vai_mo_nh@coordinates = "time"
vai_mo_nh@missing_value = 1.e+30
vai_mo_nh@_FillValue = 1.e+30
vai_mo_nh@cell_methods = "time:mean"

ext_mo_nh!0 = "time"
ext_mo_nh&time = time
ext_mo_nh@units = "1.E+12 m2"
ext_mo_nh@coordinates = "time"
ext_mo_nh@missing_value = 1.e+30
ext_mo_nh@_FillValue = 1.e+30
ext_mo_nh@cell_methods = "time:mean"

vhi_mo_nh!0 = "time"
vhi_mo_nh&time = time
vhi_mo_nh@units = "1.E+13 m3"
vhi_mo_nh@coordinates = "time"
vhi_mo_nh@missing_value = 1.e+30
vhi_mo_nh@_FillValue = 1.e+30
vhi_mo_nh@cell_methods = "time:mean"

vhs_mo_nh!0 = "time"
vhs_mo_nh&time = time
vhs_mo_nh@units = "1.E+13 m3"
vhs_mo_nh@coordinates = "time"
vhs_mo_nh@missing_value = 1.e+30
vhs_mo_nh@_FillValue = 1.e+30
vhs_mo_nh@cell_methods = "time:mean"

copy_VarMeta(vai_mo_nh,vai_mo_Lab)
copy_VarMeta(vhi_mo_nh,vhi_mo_Lab)
copy_VarMeta(vhs_mo_nh,vhs_mo_Lab)

copy_VarMeta(vai_mo_nh,vai_mo_GIN)
copy_VarMeta(vhi_mo_nh,vhi_mo_GIN)
copy_VarMeta(vhs_mo_nh,vhs_mo_GIN)

copy_VarMeta(vai_mo_nh,vai_mo_Bar)
copy_VarMeta(vhi_mo_nh,vhi_mo_Bar)
copy_VarMeta(vhs_mo_nh,vhs_mo_Bar)

copy_VarMeta(vai_mo_nh,vai_mo_ArcOc)
copy_VarMeta(vhi_mo_nh,vhi_mo_ArcOc)
copy_VarMeta(vhs_mo_nh,vhs_mo_ArcOc)

copy_VarMeta(vai_mo_nh,vai_mo_Sib)
copy_VarMeta(vhi_mo_nh,vhi_mo_Sib)
copy_VarMeta(vhs_mo_nh,vhs_mo_Sib)

copy_VarMeta(vai_mo_nh,vai_mo_Beau)
copy_VarMeta(vhi_mo_nh,vhi_mo_Beau)
copy_VarMeta(vhs_mo_nh,vhs_mo_Beau)

copy_VarMeta(vai_mo_nh,vai_mo_CArc)
copy_VarMeta(vhi_mo_nh,vhi_mo_CArc)
copy_VarMeta(vhs_mo_nh,vhs_mo_CArc)

copy_VarMeta(vai_mo_nh,vai_mo_Bering)
copy_VarMeta(vhi_mo_nh,vhi_mo_Bering)
copy_VarMeta(vhs_mo_nh,vhs_mo_Bering)

copy_VarMeta(vai_mo_nh,vai_mo_Okhotsk)
copy_VarMeta(vhi_mo_nh,vhi_mo_Okhotsk)
copy_VarMeta(vhs_mo_nh,vhs_mo_Okhotsk)

copy_VarMeta(vai_mo_nh,vai_mo_Hudson)
copy_VarMeta(vhi_mo_nh,vhi_mo_Hudson)
copy_VarMeta(vhs_mo_nh,vhs_mo_Hudson)

copy_VarMeta(vai_mo_nh,vai_mo_CAArch)
copy_VarMeta(vhi_mo_nh,vhi_mo_CAArch)
copy_VarMeta(vhs_mo_nh,vhs_mo_CAArch)

vai_mo_sh!0 = "time"
vai_mo_sh&time = time
vai_mo_sh@units = "1.E+12 m2"
vai_mo_sh@coordinates = "time"
vai_mo_sh@missing_value = 1.e+30
vai_mo_sh@_FillValue = 1.e+30
vai_mo_sh@cell_methods = "time:mean"

ext_mo_sh!0 = "time"
ext_mo_sh&time = time
ext_mo_sh@units = "1.E+12 m2"
ext_mo_sh@coordinates = "time"
ext_mo_sh@missing_value = 1.e+30
ext_mo_sh@_FillValue = 1.e+30
ext_mo_sh@cell_methods = "time:mean"

vhi_mo_sh!0 = "time"
vhi_mo_sh&time = time
vhi_mo_sh@units = "1.E+13 m3"
vhi_mo_sh@coordinates = "time"
vhi_mo_sh@missing_value = 1.e+30
vhi_mo_sh@_FillValue = 1.e+30
vhi_mo_sh@cell_methods = "time:mean"

vhs_mo_sh!0 = "time"
vhs_mo_sh&time = time
vhs_mo_sh@units = "1.E+13 m3"
vhs_mo_sh@coordinates = "time"
vhs_mo_sh@missing_value = 1.e+30
vhs_mo_sh@_FillValue = 1.e+30
vhs_mo_sh@cell_methods = "time:mean"

copy_VarMeta(vai_mo_sh,vai_mo_Wed)
copy_VarMeta(vhi_mo_sh,vhi_mo_Wed)
copy_VarMeta(vhs_mo_sh,vhs_mo_Wed)

copy_VarMeta(vai_mo_sh,vai_mo_Ross)
copy_VarMeta(vhi_mo_sh,vhi_mo_Ross)
copy_VarMeta(vhs_mo_sh,vhs_mo_Ross)

copy_VarMeta(vai_mo_sh,vai_mo_Ind)
copy_VarMeta(vhi_mo_sh,vhi_mo_Ind)
copy_VarMeta(vhs_mo_sh,vhs_mo_Ind)

copy_VarMeta(vai_mo_sh,vai_mo_Pac)
copy_VarMeta(vhi_mo_sh,vhi_mo_Pac)
copy_VarMeta(vhs_mo_sh,vhs_mo_Pac)

copy_VarMeta(vai_mo_sh,vai_mo_BAm)
copy_VarMeta(vhi_mo_sh,vhi_mo_BAm)
copy_VarMeta(vhs_mo_sh,vhs_mo_BAm)

fout = addfile(pre_proc_dir+"/"+pre_proc_file,"c")
setfileoption(fout,"DefineMode",True)

fileAtt = True
fileAtt@creation_date = systemfunc("date")
fileattdef(fout,fileAtt)

dimNames = (/"time"/)
dimSizes = (/-1/)
dimUnlim = (/True/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

filevardef(fout,"time",typeof(time),getvardims(time))
filevarattdef(fout,"time",time)

filevardef(fout,"vai_mo_nh",typeof(vai_mo_nh),getvardims(vai_mo_nh))
filevardef(fout,"ext_mo_nh",typeof(ext_mo_nh),getvardims(ext_mo_nh))
filevardef(fout,"vhi_mo_nh",typeof(vhi_mo_nh),getvardims(vhi_mo_nh))
filevardef(fout,"vhs_mo_nh",typeof(vhs_mo_nh),getvardims(vhs_mo_nh))
filevardef(fout,"vai_mo_sh",typeof(vai_mo_sh),getvardims(vai_mo_sh))
filevardef(fout,"ext_mo_sh",typeof(ext_mo_sh),getvardims(ext_mo_sh))
filevardef(fout,"vhi_mo_sh",typeof(vhi_mo_sh),getvardims(vhi_mo_sh))
filevardef(fout,"vhs_mo_sh",typeof(vhs_mo_sh),getvardims(vhs_mo_sh))

filevardef(fout,"vai_mo_Lab",typeof(vai_mo_Lab),getvardims(vai_mo_Lab))
filevardef(fout,"vhi_mo_Lab",typeof(vhi_mo_Lab),getvardims(vhi_mo_Lab))
filevardef(fout,"vhs_mo_Lab",typeof(vhs_mo_Lab),getvardims(vhs_mo_Lab))

filevardef(fout,"vai_mo_GIN",typeof(vai_mo_GIN),getvardims(vai_mo_GIN))
filevardef(fout,"vhi_mo_GIN",typeof(vhi_mo_GIN),getvardims(vhi_mo_GIN))
filevardef(fout,"vhs_mo_GIN",typeof(vhs_mo_GIN),getvardims(vhs_mo_GIN))

filevardef(fout,"vai_mo_Bar",typeof(vai_mo_Bar),getvardims(vai_mo_Bar))
filevardef(fout,"vhi_mo_Bar",typeof(vhi_mo_Bar),getvardims(vhi_mo_Bar))
filevardef(fout,"vhs_mo_Bar",typeof(vhs_mo_Bar),getvardims(vhs_mo_Bar))

filevardef(fout,"vai_mo_ArcOc",typeof(vai_mo_ArcOc),getvardims(vai_mo_ArcOc))
filevardef(fout,"vhi_mo_ArcOc",typeof(vhi_mo_ArcOc),getvardims(vhi_mo_ArcOc))
filevardef(fout,"vhs_mo_ArcOc",typeof(vhs_mo_ArcOc),getvardims(vhs_mo_ArcOc))

filevardef(fout,"vai_mo_Sib",typeof(vai_mo_Sib),getvardims(vai_mo_Sib))
filevardef(fout,"vhi_mo_Sib",typeof(vhi_mo_Sib),getvardims(vhi_mo_Sib))
filevardef(fout,"vhs_mo_Sib",typeof(vhs_mo_Sib),getvardims(vhs_mo_Sib))

filevardef(fout,"vai_mo_Beau",typeof(vai_mo_Beau),getvardims(vai_mo_Beau))
filevardef(fout,"vhi_mo_Beau",typeof(vhi_mo_Beau),getvardims(vhi_mo_Beau))
filevardef(fout,"vhs_mo_Beau",typeof(vhs_mo_Beau),getvardims(vhs_mo_Beau))

filevardef(fout,"vai_mo_CArc",typeof(vai_mo_CArc),getvardims(vai_mo_CArc))
filevardef(fout,"vhi_mo_CArc",typeof(vhi_mo_CArc),getvardims(vhi_mo_CArc))
filevardef(fout,"vhs_mo_CArc",typeof(vhs_mo_CArc),getvardims(vhs_mo_CArc))

filevardef(fout,"vai_mo_Bering",typeof(vai_mo_Bering),getvardims(vai_mo_Bering))
filevardef(fout,"vhi_mo_Bering",typeof(vhi_mo_Bering),getvardims(vhi_mo_Bering))
filevardef(fout,"vhs_mo_Bering",typeof(vhs_mo_Bering),getvardims(vhs_mo_Bering))

filevardef(fout,"vai_mo_Okhotsk",typeof(vai_mo_Okhotsk),getvardims(vai_mo_Okhotsk))
filevardef(fout,"vhi_mo_Okhotsk",typeof(vhi_mo_Okhotsk),getvardims(vhi_mo_Okhotsk))
filevardef(fout,"vhs_mo_Okhotsk",typeof(vhs_mo_Okhotsk),getvardims(vhs_mo_Okhotsk))

filevardef(fout,"vai_mo_Hudson",typeof(vai_mo_Hudson),getvardims(vai_mo_Hudson))
filevardef(fout,"vhi_mo_Hudson",typeof(vhi_mo_Hudson),getvardims(vhi_mo_Hudson))
filevardef(fout,"vhs_mo_Hudson",typeof(vhs_mo_Hudson),getvardims(vhs_mo_Hudson))

filevardef(fout,"vai_mo_CAArch",typeof(vai_mo_CAArch),getvardims(vai_mo_CAArch))
filevardef(fout,"vhi_mo_CAArch",typeof(vhi_mo_CAArch),getvardims(vhi_mo_CAArch))
filevardef(fout,"vhs_mo_CAArch",typeof(vhs_mo_CAArch),getvardims(vhs_mo_CAArch))

filevardef(fout,"vai_mo_Wed",typeof(vai_mo_Wed),getvardims(vai_mo_Wed))
filevardef(fout,"vhi_mo_Wed",typeof(vhi_mo_Wed),getvardims(vhi_mo_Wed))
filevardef(fout,"vhs_mo_Wed",typeof(vhs_mo_Wed),getvardims(vhs_mo_Wed))

filevardef(fout,"vai_mo_Ross",typeof(vai_mo_Ross),getvardims(vai_mo_Ross))
filevardef(fout,"vhi_mo_Ross",typeof(vhi_mo_Ross),getvardims(vhi_mo_Ross))
filevardef(fout,"vhs_mo_Ross",typeof(vhs_mo_Ross),getvardims(vhs_mo_Ross))

filevardef(fout,"vai_mo_Ind",typeof(vai_mo_Ind),getvardims(vai_mo_Ind))
filevardef(fout,"vhi_mo_Ind",typeof(vhi_mo_Ind),getvardims(vhi_mo_Ind))
filevardef(fout,"vhs_mo_Ind",typeof(vhs_mo_Ind),getvardims(vhs_mo_Ind))

filevardef(fout,"vai_mo_Pac",typeof(vai_mo_Pac),getvardims(vai_mo_Pac))
filevardef(fout,"vhi_mo_Pac",typeof(vhi_mo_Pac),getvardims(vhi_mo_Pac))
filevardef(fout,"vhs_mo_Pac",typeof(vhs_mo_Pac),getvardims(vhs_mo_Pac))

filevardef(fout,"vai_mo_BAm",typeof(vai_mo_BAm),getvardims(vai_mo_BAm))
filevardef(fout,"vhi_mo_BAm",typeof(vhi_mo_BAm),getvardims(vhi_mo_BAm))
filevardef(fout,"vhs_mo_BAm",typeof(vhs_mo_BAm),getvardims(vhs_mo_BAm))

filevarattdef(fout,"vhi_mo_nh",vhi_mo_nh)
filevarattdef(fout,"vai_mo_nh",vai_mo_nh)
filevarattdef(fout,"ext_mo_nh",ext_mo_nh)
filevarattdef(fout,"vhs_mo_nh",vhs_mo_nh)
filevarattdef(fout,"vhi_mo_sh",vhi_mo_sh)
filevarattdef(fout,"vai_mo_sh",vai_mo_sh)
filevarattdef(fout,"ext_mo_sh",ext_mo_sh)
filevarattdef(fout,"vhs_mo_sh",vhs_mo_sh)

filevarattdef(fout,"vhi_mo_Lab",vhi_mo_Lab)
filevarattdef(fout,"vai_mo_Lab",vai_mo_Lab)
filevarattdef(fout,"vhs_mo_Lab",vhs_mo_Lab)

filevarattdef(fout,"vhi_mo_GIN",vhi_mo_GIN)
filevarattdef(fout,"vai_mo_GIN",vai_mo_GIN)
filevarattdef(fout,"vhs_mo_GIN",vhs_mo_GIN)

filevarattdef(fout,"vhi_mo_Bar",vhi_mo_Bar)
filevarattdef(fout,"vai_mo_Bar",vai_mo_Bar)
filevarattdef(fout,"vhs_mo_Bar",vhs_mo_Bar)

filevarattdef(fout,"vhi_mo_ArcOc",vhi_mo_ArcOc)
filevarattdef(fout,"vai_mo_ArcOc",vai_mo_ArcOc)
filevarattdef(fout,"vhs_mo_ArcOc",vhs_mo_ArcOc)

filevarattdef(fout,"vhi_mo_Sib",vhi_mo_Sib)
filevarattdef(fout,"vai_mo_Sib",vai_mo_Sib)
filevarattdef(fout,"vhs_mo_Sib",vhs_mo_Sib)

filevarattdef(fout,"vhi_mo_Beau",vhi_mo_Beau)
filevarattdef(fout,"vai_mo_Beau",vai_mo_Beau)
filevarattdef(fout,"vhs_mo_Beau",vhs_mo_Beau)

filevarattdef(fout,"vhi_mo_CArc",vhi_mo_CArc)
filevarattdef(fout,"vai_mo_CArc",vai_mo_CArc)
filevarattdef(fout,"vhs_mo_CArc",vhs_mo_CArc)

filevarattdef(fout,"vhi_mo_Bering",vhi_mo_Bering)
filevarattdef(fout,"vai_mo_Bering",vai_mo_Bering)
filevarattdef(fout,"vhs_mo_Bering",vhs_mo_Bering)
filevarattdef(fout,"vhi_mo_Okhotsk",vhi_mo_Okhotsk)
filevarattdef(fout,"vai_mo_Okhotsk",vai_mo_Okhotsk)
filevarattdef(fout,"vhs_mo_Okhotsk",vhs_mo_Okhotsk)
filevarattdef(fout,"vhi_mo_Hudson",vhi_mo_Hudson)
filevarattdef(fout,"vai_mo_Hudson",vai_mo_Hudson)
filevarattdef(fout,"vhs_mo_Hudson",vhs_mo_Hudson)
filevarattdef(fout,"vhi_mo_CAArch",vhi_mo_CAArch)
filevarattdef(fout,"vai_mo_CAArch",vai_mo_CAArch)
filevarattdef(fout,"vhs_mo_CAArch",vhs_mo_CAArch)

filevarattdef(fout,"vhi_mo_Wed",vhi_mo_Wed)
filevarattdef(fout,"vai_mo_Wed",vai_mo_Wed)
filevarattdef(fout,"vhs_mo_Wed",vhs_mo_Wed)

filevarattdef(fout,"vhi_mo_Ross",vhi_mo_Ross)
filevarattdef(fout,"vai_mo_Ross",vai_mo_Ross)
filevarattdef(fout,"vhs_mo_Ross",vhs_mo_Ross)

filevarattdef(fout,"vhi_mo_Ind",vhi_mo_Ind)
filevarattdef(fout,"vai_mo_Ind",vai_mo_Ind)
filevarattdef(fout,"vhs_mo_Ind",vhs_mo_Ind)

filevarattdef(fout,"vhi_mo_Pac",vhi_mo_Pac)
filevarattdef(fout,"vai_mo_Pac",vai_mo_Pac)
filevarattdef(fout,"vhs_mo_Pac",vhs_mo_Pac)

filevarattdef(fout,"vhi_mo_BAm",vhi_mo_BAm)
filevarattdef(fout,"vai_mo_BAm",vai_mo_BAm)
filevarattdef(fout,"vhs_mo_BAm",vhs_mo_BAm)

fout->time = time
fout->vhi_mo_nh = vhi_mo_nh
fout->vai_mo_nh = vai_mo_nh
fout->ext_mo_nh = ext_mo_nh
fout->vhs_mo_nh = vhs_mo_nh
fout->vhi_mo_sh = vhi_mo_sh
fout->vai_mo_sh = vai_mo_sh
fout->ext_mo_sh = ext_mo_sh
fout->vhs_mo_sh = vhs_mo_sh

fout->vhi_mo_Lab = vhi_mo_Lab
fout->vai_mo_Lab = vai_mo_Lab
fout->vhs_mo_Lab = vhs_mo_Lab
fout->vhi_mo_GIN = vhi_mo_GIN
fout->vai_mo_GIN = vai_mo_GIN
fout->vhs_mo_GIN = vhs_mo_GIN
fout->vhi_mo_Bar = vhi_mo_Bar
fout->vai_mo_Bar = vai_mo_Bar
fout->vhs_mo_Bar = vhs_mo_Bar

fout->vhi_mo_ArcOc = vhi_mo_ArcOc
fout->vai_mo_ArcOc = vai_mo_ArcOc
fout->vhs_mo_ArcOc = vhs_mo_ArcOc
fout->vhi_mo_Sib = vhi_mo_Sib
fout->vai_mo_Sib = vai_mo_Sib
fout->vhs_mo_Sib = vhs_mo_Sib
fout->vhi_mo_Beau = vhi_mo_Beau
fout->vai_mo_Beau = vai_mo_Beau
fout->vhs_mo_Beau = vhs_mo_Beau
fout->vhi_mo_CArc = vhi_mo_CArc
fout->vai_mo_CArc = vai_mo_CArc
fout->vhs_mo_CArc = vhs_mo_CArc

fout->vhi_mo_Bering = vhi_mo_Bering
fout->vai_mo_Bering = vai_mo_Bering
fout->vhs_mo_Bering = vhs_mo_Bering
fout->vhi_mo_Okhotsk = vhi_mo_Okhotsk
fout->vai_mo_Okhotsk = vai_mo_Okhotsk
fout->vhs_mo_Okhotsk = vhs_mo_Okhotsk
fout->vhi_mo_Hudson = vhi_mo_Hudson
fout->vai_mo_Hudson = vai_mo_Hudson
fout->vhs_mo_Hudson = vhs_mo_Hudson
fout->vhi_mo_CAArch = vhi_mo_CAArch
fout->vai_mo_CAArch = vai_mo_CAArch
fout->vhs_mo_CAArch = vhs_mo_CAArch

fout->vhi_mo_Wed = vhi_mo_Wed
fout->vai_mo_Wed = vai_mo_Wed
fout->vhs_mo_Wed = vhs_mo_Wed
fout->vhi_mo_Ross = vhi_mo_Ross
fout->vai_mo_Ross = vai_mo_Ross
fout->vhs_mo_Ross = vhs_mo_Ross

fout->vhi_mo_Ind = vhi_mo_Ind
fout->vai_mo_Ind = vai_mo_Ind
fout->vhs_mo_Ind = vhs_mo_Ind
fout->vhi_mo_Pac = vhi_mo_Pac
fout->vai_mo_Pac = vai_mo_Pac
fout->vhs_mo_Pac = vhs_mo_Pac
fout->vhi_mo_BAm = vhi_mo_BAm
fout->vai_mo_BAm = vai_mo_BAm
fout->vhs_mo_BAm = vhs_mo_BAm

exit
end
