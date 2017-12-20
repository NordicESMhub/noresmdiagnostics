;----------------------------------------------------------------------
; Original code written by Dennis Shea and modified by Sheri Mickelson
; March 2013 and then by Keith Oleson October 2013
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; Only works for ncl V6.2.0
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

;---Data file containing source grid and variables
;   SE_dir   = getenv("procDir")
;   SE_file  = getenv("InFile") 
    SE_dir   = "/glade/scratch/oleson/ANALYSIS/cam5clm45bgc_ne30cesm12rel06_2000b/"
    SE_file  = "SE_NE30_cam5clm45bgc_ne30cesm12rel06_2000b_ANN_climo.nc"
    sfile    = addfile(SE_dir + SE_file,"r")
    SE_nfile = dimsizes(sfile)

;   method    = getenv("method")
    method    = "conserve"

;---Get 1d destination lat/lons
    LL_dir   = "/glade/p/cesm/lmwg/diag/lnd_diag4.2/regriddingFiles/ne30/"
    LL_file  = "SE_NE30_to_FV_192x288.bilinear.nc"
    LL_path  = LL_dir + LL_file
    fLL           = addfile(LL_path, "r")
    dst_grid_dims  = fLL->dst_grid_dims
    dst_mlon       = dst_grid_dims(0)
    dst_lat        = dble2flt(fLL->yc_b(::dst_mlon))
    dst_lon        = dble2flt(fLL->xc_b(:dst_mlon-1))

;--- Output nc file containing all the variables
;   RGRD_dir  = getenv("procDir")
;   RGRD_file = getenv("OutFile")
    RGRD_dir  = "/glade/scratch/oleson/ANALYSIS/cam5clm45bgc_ne30cesm12rel06_2000b/"
    RGRD_file = "FV_192x288_cam5clm45bgc_ne30cesm12rel06_2000b_ANN_climo_diag_conserve.nc"
    RGRD_path = RGRD_dir + RGRD_file

;---Get all variables on the SE file
    var_in   = getfilevarnames( sfile )
    nvar_in  = dimsizes(var_in)

;---Specify a list of 1D variables on the source SE file that should NOT be copied
    var_in_exclude = (/"lat", "lon", "date_written", "time_written", "time_bounds", "ZSOI", "DZSOI", "WATSAT", "SUCSAT", "BSW", "HKSAT", "area"/)  

;---Specify a list of variables on the source SE file that should be directly copied 
    var_in_copy = (/"time", "levgrnd", "levlak", "levdcmp", "hist_interval","mscur"/)

;---Specify a list of variables to be regridded
    var_out        = "All_Variables"     ; to be regridded

;---Generate the latitudinal weights
    gw  = latRegWgt(dst_lat, "double", 0)
    gw!0= "lat"

;---Use the destination (FV) grid info on the weight file to create lat/lon
    lat       = dst_lat                  ; get from weight file
    lat@long_name = "latitude"
    lat!0     = "lat"
    lat@units = "degrees_north"
    lat&lat   =  lat
    nlat      = dimsizes(lat)            ; same as dst_nlat

    lon       = dst_lon                  ; get from weight file
    lon@long_name = "longitude"
    lon!0     = "lon"
    lon@units = "degrees_east"
    lon&lon   =  lon
    mlon      = dimsizes(lon)            ; same as dst_mlon

;---Loop over all variables; regrid appropriate variables; write to netCDF

    system("/bin/rm -f "+RGRD_path)      ; delete any pre-existing file
    rgrd_nc   = addfile(RGRD_path, "c")  ; open for writing

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                    PREDEFINE MODE
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    setfileoption(rgrd_nc,"DefineMode",True)
    setfileoption("nc","format","largefile")

;===================================================================
; create global attributes of the netCDF file containing regridded data
;===================================================================
    global    = True
    global@separator2= "---------------------------------------"
    copy_VarAtts(sfile, global)
    global@separator1= "------- SOURCE FILE ATTRIBUTES --------"

    if (isatt(sfile,"title")) then
        global@TITLE = "REMAPPED: "+sfile@title
    end if

    global@remap         = "NCL: ESMF_regrid"
    global@method    = method
    global@creation_date = systemfunc("date")

    fileattdef( rgrd_nc, global )        ; copy file attributes to netCDF file

;===================================================================
; predefine the coordinate dimension names and their sizes
;===================================================================
    dNames   = getvardims(sfile)       ; get level info from source file
    dSizes   = getfiledimsizes(sfile)
    ia       = ind(dNames.eq."levgrnd" )   ; # of levels
    ib       = ind(dNames.eq."levlak")
    klevgrnd = dSizes(ia)
    klevlak  = dSizes(ib)
    if (any(dNames .eq. "levdcmp")) then
      ic       = ind(dNames.eq."levdcmp")
      klevdcmp = dSizes(ic) 
                                       ; standard CLM dimensions
      dimNames = (/"time",    "lat",    "lon", "levgrnd",  "levlak", "levdcmp", "hist_interval"/)
      dimSizes = (/    -1,     nlat,     mlon,  klevgrnd,   klevlak,  klevdcmp,               2/)
      dimUnlim = (/  True,    False,    False,     False,     False,     False,           False/)
      filedimdef(rgrd_nc,dimNames,dimSizes,dimUnlim)
    else
      dimNames = (/"time",    "lat",    "lon", "levgrnd",  "levlak", "hist_interval"/)
      dimSizes = (/    -1,     nlat,     mlon,  klevgrnd,   klevlak,               2/)
      dimUnlim = (/  True,    False,    False,     False,     False,           False/)
      filedimdef(rgrd_nc,dimNames,dimSizes,dimUnlim)
    end if

;--- The following are explicitly added because they are 'special'

    filevardef(rgrd_nc, "lat", typeof(lat), getvardims(lat))
    filevarattdef(rgrd_nc,"lat" ,lat)
 
    filevardef(rgrd_nc, "lon", typeof(lon), getvardims(lon))
    filevarattdef(rgrd_nc,"lon" ,lon)

    filevardef(rgrd_nc, "gw", typeof(gw), getvardims(gw))
    filevarattdef(rgrd_nc,"gw" ,gw)

;--- Loop over all variables and predfine meta data
    do nv=0,nvar_in-1
       if (.not.any(var_in(nv).eq.var_in_exclude)) then

           rank_in = dimsizes(getfilevardimsizes(sfile, var_in(nv)))
	   varvar_types = (/ "float" /)

           if (any(var_in(nv).eq.var_in_copy) ) then
               filevardef(rgrd_nc, var_in(nv), getfilevartypes(sfile,var_in(nv)) \
                                             , getfilevardims(sfile,var_in(nv))  )
               dumAtts = new( 1, getfilevartypes(sfile,var_in(nv)))
           end if

           if (rank_in .eq.1 .and. .not.any(var_in(nv).eq.var_in_copy) ) then
               filevardef(rgrd_nc, var_in(nv), varvar_types \
                                             , (/ "lat", "lon" /)   )
               dumAtts = new( 1, varvar_types)
           end if
           
           if (rank_in .eq.2 .and. .not.any(var_in(nv).eq.var_in_copy)) then
               filevardef(rgrd_nc, var_in(nv), varvar_types \
                                             , (/ "time", "lat", "lon" /)        )
               dumAtts = new( 1, varvar_types)
           end if
           if (rank_in .eq.3) then
               vdims = getfilevardims(sfile, var_in(nv))
               filevardef(rgrd_nc, var_in(nv), varvar_types \
                                             , (/ "time", vdims(1),  "lat", "lon" /)        )
               dumAtts = new( 1, varvar_types)
           end if

           varAtts = getfilevaratts(sfile, var_in(nv))
           if (.not.ismissing(varAtts(0))) then
               nAtts = dimsizes(varAtts)
               do na=0,nAtts-1
                  dumAtts@$varAtts(na)$ = sfile->$var_in(nv)$@$varAtts(na)$
               end do
               filevarattdef(rgrd_nc, var_in(nv) , dumAtts)
           end if
           delete([/varAtts, dumAtts/])   ; may change size next iteration
        end if
    end do       ; nv

;===================================================================
; explicitly exit file definition mode. **NOT REQUIRED in NCL**
;===================================================================
    setfileoption(rgrd_nc,"DefineMode",False)

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;        Write the basic and regridded data values to the predefined structures
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    rgrd_nc->lat  = (/ lat /)
    rgrd_nc->lon  = (/ lon /)
    rgrd_nc->gw   = (/ gw  /)

    WgtFileName  = "weights_file_"+SE_file
    SCRIPFileName  = "/glade/p/work/oleson/lnd_diag4.2.19_commit/regriddingFiles/ne30/SCRIPgrid_ne30np4_nomask_c101123.nc"
    system("/bin/cp -f " + SCRIPFileName + " .")
    SrcSCRIPFileName = "SCRIPgrid_ne30np4_nomask_c101123.nc"
    DstFileName  = "destination_grid_file_"+RGRD_file

    ;---To get corners for destination grid for rectilinear_to_SCRIP, use mapping file from mkprocdata_map
    Opt_RtS = True
    Opt_RtS@PrintTimings = True
    Opt_RtS@Debug = True
    fMAP_dir  = "/glade/p/work/oleson/clm4_5_25/models/lnd/clm/tools/shared/mkprocdata_map/"
    fMAP_file = "map_ne30np4_nomask_TO_fv0.9x1.25_nomask_aave.130917.nc"
    fMAP_path = fMAP_dir + fMAP_file
    fMAP      = addfile(fMAP_path,"r")
    Opt_RtS@GridCornerLat = ndtooned(fMAP->yv_b)
    Opt_RtS@GridCornerLon = ndtooned(fMAP->xv_b)

    ;---Convert destination grid to SCRIP file
    rectilinear_to_SCRIP(DstFileName,dst_lat,dst_lon,Opt_RtS)

    Opt_GW = True
    Opt_GW@PrintTimings = True
    Opt_GW@Debug = True
    Opt_GW@InterpMethod = method

    Opt_RGWW = True
    Opt_RGWW@PrintTimings = True
    Opt_RGWW@Debug = True
    Opt_RGWW@InterpMethod = method
    Opt_RGWW@DstGridType = "rectilinear"

    do nv = 0, nvar_in-1
;   do nv=418, 418  ;TSA_U
       print(var_in(nv))
       if (.not.any(var_in(nv).eq.var_in_exclude)) then
              if (any(var_in(nv).eq.var_in_copy)) then
                 rgrd_nc->$var_in(nv)$ = sfile->$var_in(nv)$
              else

                 if (var_in(nv) .eq. "landmask" .or. var_in(nv) .eq. "pftmask") then
                   maskmiss = int2flt(sfile->$var_in(nv)$)
                   maskmiss@_FillValue = 0.
                   maskmiss = where(ismissing(maskmiss),0.,1.)
                 else
                   maskmiss = where(ismissing(sfile->$var_in(nv)$),0.,1.)
                 end if
                 cdf_file = addfile(SrcSCRIPFileName,"w")
                 rank_in = dimsizes(getfilevardimsizes(sfile, var_in(nv)))
                 if (rank_in .eq. 1) then
                   cdf_file->grid_imask = (/maskmiss/)
                 else
                   if (rank_in .eq. 2) then
                     cdf_file->grid_imask = (/maskmiss(0,:)/)
                   else
                     if (rank_in .eq. 3) then
                       cdf_file->grid_imask = (/maskmiss(0,0,:)/)
                     end if
                   end if
                 end if

                 ;---Generation of weights
                 ESMF_regrid_gen_weights(SrcSCRIPFileName,DstFileName,WgtFileName,Opt_GW)

                 ;---Regridding
                 rgrd_nc->$var_in(nv)$  = (/ ESMF_regrid_with_weights(sfile->$var_in(nv)$,WgtFileName,Opt_RGWW) /)

                 system("/bin/rm -f " + WgtFileName)
                 delete(maskmiss)
              end if
       end if
    end do
    system("/bin/rm -f " + DstFileName)
    system("/bin/rm -f " + SrcSCRIPFileName)

end
