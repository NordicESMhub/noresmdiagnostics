load "$DIAG_HOME/popRemap.ncl"
;************************************************
;--------------------------------------------------------------------
; remap. note, you must have contributed.ncl loaded before popRemap.ncl
;--------------------------------------------------------------------
begin

; This plots 2 vector fields and their difference from 2
; cases of CCSM output.  Differences are of the form
; new - prev

wkdir = getenv("WKDIR")
case_new  = getenv("CASE_NEW")
case_prev = getenv("CASE_PREV")
path_new  = getenv("PATH_NEW")
path_prev = getenv("PATH_PREV")
var_name_new = getenv("VAR_NAME_NEW")
var_name_prev = getenv("VAR_NAME_PREV")
grid_new = getenv("GRID_CONT")
grid_prev = getenv("GRID_DIFF")
new_frst_avg_yr = getenv("NEW_YR_AVG_FRST")
new_last_avg_yr = getenv("NEW_YR_AVG_LAST")
prev_frst_avg_yr = getenv("PREV_YR_AVG_FRST")
prev_last_avg_yr = getenv("PREV_YR_AVG_LAST")
hires = getenv("HIRES")

;---------USER DEFINED QUANTITIES------------------
c_hemisphere = (/"NH", "SH"/)
season = (/"ann","jfm","amj","jas","ond"/)   ; These are for file names
min_lat   = (/40., -90./) 
max_lat   = (/90., -45./)
if (var_name_new.eq."NEW")then
  var_to_read_new = (/"uvel","vvel"/)
else
  var_to_read_new = (/"u","v"/)
end if
if (var_name_prev.eq."NEW")then
  var_to_read_prev = (/"uvel","vvel"/)
else
  var_to_read_prev = (/"u","v"/)
end if
title_for_plot = "Ice Velocity"
units_for_plot = "(cm/s)"

min_vector        =  0.
max_vector        = 22.
vec_spacing       =  2.
ref_vec_magnitude = 10.

; Also a scale for difference vector/contour plots
;diff_min_con           = -8.
;diff_max_con           =  8.
;diff_con_spacing       =  2.
;diff_min_vec           =  0.
;diff_max_vec           = 10.
;diff_vec_spacing       =  2.
;diff_ref_vec_magnitude = 10.
;-------END USER DEFINED QUANTITIES----------------

main_labels = (/"ANN Mean", "JFM Mean", "AMJ Mean", "JAS Mean", "OND Mean"/)

left_label = title_for_plot
right_label= units_for_plot

nseasons = dimsizes(season)

inew_frst_yr = stringtointeger(new_frst_avg_yr)
inew_last_yr = stringtointeger(new_last_avg_yr)
iprev_frst_yr = stringtointeger(prev_frst_avg_yr)
iprev_last_yr = stringtointeger(prev_last_avg_yr)

cnew_frst_yr = sprinti("%0.4i",inew_frst_yr)
cnew_last_yr = sprinti("%0.4i",inew_last_yr)
cprev_frst_yr = sprinti("%0.4i",iprev_frst_yr)
cprev_last_yr = sprinti("%0.4i",iprev_last_yr)

cnew_yr_range = "  Yrs " + cnew_frst_yr + " - " + cnew_last_yr
cprev_yr_range = "  Yrs " + cprev_frst_yr + " - " + cprev_last_yr
center_labels = (/case_new + cnew_yr_range, \
                 case_prev+ cprev_yr_range, \
                 case_new + " - " + case_prev /)

;--------------------------------------------------------------------
; Decide which grid to use for plotting
;--------------------------------------------------------------------

if (grid_new.eq.grid_prev) then   ; Grids are identical, use native grid
  plot_grid = "native"
else
  plot_grid = "1x1d"              ; Grids differ, remap to 1x1 grid
                                  ; Set info for SCRIP remapping file
  new_map_file_ext = "999999"
  prev_map_file_ext = "999999"
  if (grid_new.eq."gx1v3".and.grid_prev.eq."gx3v4") then  
    new_map_file_ext = "010808"
    prev_map_file_ext = "020604"
  end if
  if (grid_new.eq."gx3v4".and.grid_prev.eq."gx1v3") then  
    prev_map_file_ext = "010808"
    new_map_file_ext = "020604"
  end if
  if (grid_new.eq."gx1v3".and.grid_prev.eq."gx3v5") then  
    new_map_file_ext = "010808"
    prev_map_file_ext = "040607"
  end if
  if (grid_new.eq."gx3v5".and.grid_prev.eq."gx1v3") then  
    prev_map_file_ext = "010808"
    new_map_file_ext = "040607"
  end if
  if (new_map_file_ext.eq."999999".or.prev_map_file_ext.eq."999999") then
    print (grid_new + " or " + grid_prev + " not supported; see vect_diff.ncl")
    print ("See available mapping files in /fs/cgd/csm/mapping/maps or ")
    print ("/fis/cgd/cseg/csm/mapping/maps")
    exit
  end if
end if

;--------------------------------------------------------------------
; U and V are put in same array since they will always be the same
; size.  The new and prev cases need to have individual arrays, since
; they may be different sizes.
;--------------------------------------------------------------------

print (" Plotting " + var_to_read_new(0) + "," + var_to_read_new(1) + " (1/1)")
do jj = 0, nseasons-1       ; Loop through seasonal means

;--------------------------------------------------------------------
; Construct file name
;--------------------------------------------------------------------
  new_file_name = season(jj)+"_avg_"+ cnew_frst_yr+"-"+ cnew_last_yr+".nc"
  prev_file_name= season(jj)+"_avg_"+cprev_frst_yr+"-"+cprev_last_yr+".nc"
  a = addfile(path_prev  + "/" + prev_file_name,"r")
  b = addfile(path_new   + "/" + new_file_name,"r")

;--------------------------------------------------------------------
; Read variables into memory
;--------------------------------------------------------------------
  if (hires .eq. 0) then
      u_new  = b->$var_to_read_new(0)$(0,:,:)
      v_new  = b->$var_to_read_new(1)$(0,:,:)
      u_prev = a->$var_to_read_prev(0)$(0,:,:)
      v_prev = a->$var_to_read_prev(1)$(0,:,:)
      lat2d_new    = b->ULAT
      lon2d_new    = b->ULON
      Urotang_new  = b->ANGLE     ; Rotation angle on the U grid
      lat2d_prev   = a->ULAT
      lon2d_prev   = a->ULON
      Urotang_prev = a->ANGLE     ; Rotation angle on the U grid
  else
      u_new  = b->$var_to_read_new(0)$(0,::8,::8)
      v_new  = b->$var_to_read_new(1)$(0,::8,::8)
      u_prev = a->$var_to_read_prev(0)$(0,::8,::8)
      v_prev = a->$var_to_read_prev(1)$(0,::8,::8)
      lat2d_new    = b->ULAT(::8,::8)
      lon2d_new    = b->ULON(::8,::8)
      Urotang_new  = b->ANGLE(::8,::8)     ; Rotation angle on the U grid
      lat2d_prev   = a->ULAT(::8,::8)
      lon2d_prev   = a->ULON(::8,::8)
      Urotang_prev = a->ANGLE(::8,::8)     ; Rotation angle on the U grid
  end if

  if (u_new@units.eq."m/s") then
     u_new = u_new*100.
  end if
  if (v_new@units.eq."m/s") then
     v_new = v_new*100.
  end if
  if (u_prev@units.eq."m/s") then
     u_prev = u_prev*100.
  end if
  if (v_prev@units.eq."m/s") then
     v_prev = v_prev*100.
  end if

;--------------------------------------------------------------------
; Convert velocities from the POP grid to regular meridional grid
;--------------------------------------------------------------------

  urot_new  = u_new(:,:)     ; Copy coordinare variables
  vrot_new  = v_new(:,:)
  urot_prev = u_prev(:,:) 
  vrot_prev = v_prev(:,:)
;--------------------------------------------------------------------
; Rotate the vectors to regular E-N direction, but still on U grid
;--------------------------------------------------------------------
  urot_new  = u_new(:,:)*cos(Urotang_new) - v_new(:,:)*sin(Urotang_new)
  vrot_new  = u_new(:,:)*sin(Urotang_new) + v_new(:,:)*cos(Urotang_new)
  urot_prev = u_prev(:,:)*cos(Urotang_prev) - v_prev(:,:)*sin(Urotang_prev)
  vrot_prev = u_prev(:,:)*sin(Urotang_prev) + v_prev(:,:)*cos(Urotang_prev)
  delete(Urotang_new)
  delete(Urotang_prev)

  urot_new@lat2d = lat2d_new   ; Assign coordinate attributes
  vrot_new@lat2d = lat2d_new
  urot_new@lon2d = lon2d_new
  vrot_new@lon2d = lon2d_new
  urot_prev@lat2d = lat2d_prev
  vrot_prev@lat2d = lat2d_prev
  urot_prev@lon2d = lon2d_prev
  vrot_prev@lon2d = lon2d_prev

;--------------------------------------------------------------------
; Calculate magnitude of velocity for top 2 plots
;--------------------------------------------------------------------
  mag_vel_new  = urot_new(:,:)       ; Copy coordinate variables
  mag_vel_prev = urot_prev(:,:)      ; Copy coordinate variables
  mag_vel_new  = sqrt(urot_new(:,:)^2 + vrot_new(:,:)^2)
  mag_vel_prev = sqrt(urot_prev(:,:)^2 + vrot_prev(:,:)^2)

;--------------------------------------------------------------------
; Remap the data to a 1x1 grid for difference plot if necessary
; NOTE:  Do not pass rotated vectors into popRemap if remapping to
; 1x1 grid.  This will be done in popRemap.
;--------------------------------------------------------------------
  if (plot_grid.eq."1x1d") then
  ;--------------------------------------------------------------------
  ; See NOTES regarding problems with mapping vectors using standard
  ; NCL popRemap.  First move unrotated u and v from U to T grid
  ;--------------------------------------------------------------------
    if (isfilevar(b,"ANGLET").and.isfilevar(a,"ANGLET") ) then
     Trotang_new  = b->ANGLET    ; Rotation angle on the T grid
     Trotang_prev = a->ANGLET    ; Rotation angle on the T grid
     new_dims  = filevardimsizes(b,"u")  ; (0) time (1) lat (2) lon
     prev_dims = filevardimsizes(a,"u")
     u_new_T  = u_new    ; Copy coordinate variables
     v_new_T  = v_new    ; Copy coordinate variables

     u_new_T(:,0)  = 0.
     v_new_T(:,0)  = 0.
     do j = 1,new_dims(2)-1
       do i = 0,new_dims(1)-1
         im1 = i-1
         if (im1.eq.-1) then
           im1 = new_dims(1)-1
         end if
         u_new_T(i,j) = 0.25*(u_new(i,j) + u_new(im1,j) + \
                              u_new(i,j-1) + u_new(im1,j-1))
         v_new_T(i,j) = 0.25*(v_new(i,j) + v_new(im1,j) + \
                              v_new(i,j-1) + v_new(im1,j-1))
       end do
     end do

     u_prev_T = u_prev    ; Copy coordinate variables
     v_prev_T = v_prev    ; Copy coordinate variables
     u_prev_T(:,0) = 0.
     v_prev_T(:,0) = 0.
     do j = 1,prev_dims(2)-1
      do i = 0,prev_dims(1)-1
        im1 = i-1
        if (im1.eq.-1) then
          im1 = prev_dims(1)-1
        end if
        u_prev_T(i,j) = 0.25*(u_prev(i,j) + u_prev(im1,j) + \
                             u_prev(i,j-1) + u_prev(im1,j-1))
        v_prev_T(i,j) = 0.25*(v_prev(i,j) + v_prev(im1,j) + \
                             v_prev(i,j-1) + v_prev(im1,j-1))
      end do
     end do

  ;--------------------------------------------------------------------
  ; Pass u, v on T grid and rotation angle on T grid to popRemap
  ; This is compatible with SCRIP remapping file, all in T grid
  ;--------------------------------------------------------------------
     vels_new_1x1  = PopLatLonV(u_new_T(:,:), v_new_T(:,:), \
                                Trotang_new(:,:), grid_new, plot_grid, \
                                "bilin","da",new_map_file_ext)
     vels_prev_1x1 = PopLatLonV(u_prev_T(:,:), v_prev_T(:,:), \
                                Trotang_prev(:,:), grid_prev, plot_grid, \
                                "bilin","da",prev_map_file_ext)

;   vels_new_1x1  = PopLatLonV(u_new(:,:), v_new(:,:), \
;                       grid_new, plot_grid,"bilin","da",new_map_file_ext)
;   vels_prev_1x1 = PopLatLonV(u_prev(:,:), v_prev(:,:), \
;                       grid_prev, plot_grid,"bilin","da",prev_map_file_ext)

     u_diff = vels_new_1x1(0,:,:)     ; Copy coordinate attributes
     v_diff = vels_new_1x1(0,:,:)
  ;--------------------------------------------------------------------
  ; Calculate differences on 1x1 grid
  ;--------------------------------------------------------------------

     u_diff = vels_new_1x1(0,:,:) - vels_prev_1x1(0,:,:)
     v_diff = vels_new_1x1(1,:,:) - vels_prev_1x1(1,:,:)
  ;--------------------------------------------------------------------
  ; Calculate the magnitude of the velocity for scalar part of the plot
  ;--------------------------------------------------------------------
     mag_diff = u_diff                ; Copy coordinate variables
     mag_1x1_new  = sqrt(vels_new_1x1(0,:,:)^2 + vels_new_1x1(1,:,:)^2)
     mag_1x1_prev = sqrt(vels_prev_1x1(0,:,:)^2 + vels_prev_1x1(1,:,:)^2)
     mag_diff = mag_1x1_new - mag_1x1_prev
    else
     print("ANGLET not found in both cases: exiting")
     exit
    end if
  else
  ;--------------------------------------------------------------------
  ; Plot the difference on the native grid if both cases are on same grid
  ;--------------------------------------------------------------------
    u_diff   = urot_new               ; Copy coordinate attributes
    v_diff   = vrot_new
    u_diff = urot_new - urot_prev
    v_diff = vrot_new - vrot_prev
    mag_diff = urot_new               ; Copy coordinate attributes
    mag_diff = mag_vel_new - mag_vel_prev

  end if 
  get_dims = dimsizes(mag_diff)  ; Get approximate index for equator
  nlat  = get_dims(0)-1            ; for calculating max/min
  ihalf = get_dims(0)/2            ; for calculating max/min

;************************************************
; Loop through the hemispheres to create plots
;************************************************
  do ihem = 0,1          

    if (ihem.eq.0) then   ; NH
      min_diff = min(mag_diff(ihalf:nlat,:))   ; This isn't very accurate on a
      max_diff = max(mag_diff(ihalf:nlat,:))   ; rotated grid, but  close enough
    else
      min_diff = min(mag_diff(0:ihalf,:))  
      max_diff = max(mag_diff(0:ihalf,:)) 
    end if
                                    ; for diagnostics.
;    print (c_hemisphere(ihem) + " "+ main_labels(jj) + " Min diff " \
;           + title_for_plot + "=" + min_diff)
;    print (c_hemisphere(ihem) + " "+ main_labels(jj) + " Max diff " \
;           + title_for_plot + "=" + max_diff)

    if (min_diff.eq.0 .and. max_diff.eq.0) then
      print ("Skipping plot since fields are identical")
    else


      if (var_name_new.eq."NEW" .or. var_name_prev.eq."NEW")then
	 wks = gsn_open_wks("ps",wkdir + "diff_vec_"+season(jj)+"_"  \
                         + "uvel" + "_cice_"+c_hemisphere(ihem))
      else
         wks = gsn_open_wks("ps",wkdir + "diff_vec_"+season(jj)+"_"  \
                         + "uvel" + "_csim4_"+c_hemisphere(ihem))
      end if

      gsn_define_colormap(wks,"gui_default")
; 0->23 is first colormap, 24->124 is second colormap
      gsn_merge_colormaps(wks,"gui_default", "BlWhRe") ; merge 2 colormaps
;     gsn_draw_colormap(wks) ; draw colormap

      i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap

      plot = new(3,graphic)

      res                      = True
      res@gsnDraw              = False             ; do not draw picture
      res@gsnFrame             = False             ; do not advance frame
      res@gsnPolar             = c_hemisphere(ihem)
      res@gsnScalarContour     = True              ; vectors over scalars
      res@gsnTickMarksOn       = False            ; don't write long. labels

      res@vcRefMagnitudeF      = ref_vec_magnitude ; vec magnitude
      res@vcRefLengthF         = 0.06              ; define length of vec ref
      res@vcLineArrowColor     = "black"           ; black vectors
      res@vcMinDistanceF       = 0.019             ; thins arrows near pole 
      res@vcGlyphStyle         = "CurlyVector"     ; turn on curly vectors

      res@vcLevelSelectionMode = "ManualLevels"
      res@vcMinLevelValF       = min_vector + vec_spacing
      res@vcMaxLevelValF       = max_vector - vec_spacing
      res@vcLevelSpacingF      = vec_spacing       ; Manually sets the vector levels. 

      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF       = min_vector + vec_spacing
      res@cnMaxLevelValF       = max_vector - vec_spacing
      res@cnLevelSpacingF      = vec_spacing       ; Manually sets the contour levels. 

      res@cnFillOn             = True              ; turn on color for contours
      res@cnLinesOn            = False             ; turn off contour lines
      res@cnLineLabelsOn       = False             ; turn off contour line labels
      res@gsnScalarContour     = True              ; contours desired

      res@trGridType           = "TriangularMesh"
      res@cnFillMode           = "RasterFill"

      res@gsnSpreadColors      = True              ; use full colormap
      res@gsnSpreadColorStart  = 4
      res@gsnSpreadColorEnd    = 23 

      res@gsnLeftString        = left_label
      res@gsnRightString       = right_label
      res@gsnAddCyclic         = True

      res@lbLabelBarOn         = False            ; Turns off label bar for first plot
      res@lbLabelStride        = 1                 ; Label bar stride
      res@lbLabelFontHeightF   = 0.02              ; Label bar font height
      res@lbOrientation        = "Vertical"

      res@txFontHeightF        = 0.025
      res@gsnLeftString        = left_label
      res@gsnRightString       = right_label
      res@tiMainString         = center_labels(0)
      res@tiMainFontHeightF    = 0.03              ; size of title main string

      res@mpMinLatF            = min_lat(ihem)     ; minimum lat to plot
      res@mpMaxLatF            = max_lat(ihem)     ; maximum lat to plot
      res@mpLandFillColor      = "grey"            ; color of continents
      res@mpLabelFontHeightF   = 0.0015            ; size of map long. labels

      if (hires .eq. 0) then
        plot(0) = gsn_csm_vector_scalar_map_polar \
                (wks,urot_new(:,:), vrot_new(:,:), mag_vel_new(:,:), res)
      else
        delete(res@gsnScalarContour)
        delete(res@vcRefMagnitudeF)
        delete(res@vcRefLengthF)
        delete(res@vcLineArrowColor)
        delete(res@vcMinDistanceF)
        delete(res@vcGlyphStyle)

        delete(res@vcLevelSelectionMode)
        delete(res@vcMinLevelValF)
        delete(res@vcMaxLevelValF)
        delete(res@vcLevelSpacingF)

        plot(0) = gsn_csm_contour_map_polar \
                (wks,mag_vel_new(:,:), res)
      end if
      res@tiMainString         = center_labels(1)

      res@lbLabelBarOn         = True             ; Turns on the individual label bars
      if (hires .eq. 0) then
        plot(1) = gsn_csm_vector_scalar_map_polar \
                (wks,urot_prev(:,:), vrot_prev(:,:), mag_vel_prev(:,:),res)
      else
        plot(1) = gsn_csm_contour_map_polar \
                (wks,mag_vel_prev(:,:),res)
      end if
;--------------------------------------------------
; Define new scale and colormap for NH difference plot
;--------------------------------------------------

      maxXY = min((/fabs(max_diff),fabs(min_diff)/))
      mnmxint = nice_mnmxintvl( 0., maxXY, 5, False)
      diff_min_con           =  -mnmxint(1)
      diff_max_con           =   mnmxint(1)
      diff_con_spacing       =  mnmxint(2)

      diff_min_vec           =  0.
      diff_max_vec           =  mnmxint(1)
      diff_vec_spacing       =  mnmxint(2)
      diff_ref_vec_magnitude = mnmxint(1)

      res@gsnSpreadColorStart  = 54
      res@gsnSpreadColorEnd    = 94

      color_start              = 54
      color_end                = 94
      mid_pt                   = 74
; This is a test to get the white color near the 0 contour
;    if (diff_max_con + diff_min_con .ge. 0) then
;      new_color_start = (diff_min_con*(color_end-mid_pt) +  \
;                         diff_max_con*mid_pt)/diff_max_con
;      res@gsnSpreadColorStart = floattointeger(new_color_start)
;      print ("new_color_start = "+floattointeger(new_color_start))
;    else
;      new_color_end = (diff_max_con*(color_start-mid_pt) +  \
;                       diff_min_con*mid_pt)/diff_min_con
;      res@gsnSpreadColorEnd   = floattointeger(new_color_end)
;      print ("new_color_end = "+floattointeger(new_color_end))
;    end if
   
     res@tiMainString         = center_labels(2)
     res@lbTitleFontHeightF = 0.02
     res@lbTitleString = "MIN = "+sprintf("%6.2f",min_diff)+ \
                        " MAX = "+sprintf("%6.2f",max_diff)

     res@vcRefMagnitudeF      = diff_ref_vec_magnitude ; vec magnitude
     res@vcMinLevelValF       = diff_min_vec
     res@vcMaxLevelValF       = diff_max_vec
     res@vcLevelSpacingF      = diff_vec_spacing       ; set contour spacing
     res@cnMinLevelValF       = diff_min_con
     res@cnMaxLevelValF       = diff_max_con
     res@cnLevelSpacingF      = diff_con_spacing       ; set contour spacing
;--------------------------------------------------
; Make difference plot
;--------------------------------------------------
     if (hires .eq. 0) then
         plot(2) = gsn_csm_vector_scalar_map_polar \
                  (wks,u_diff(:,:), v_diff(:,:), mag_diff(:,:), res)
     else
         delete(res@vcRefMagnitudeF)
         delete(res@vcMinLevelValF)
         delete(res@vcMaxLevelValF)
         delete(res@vcLevelSpacingF)
         plot(2) = gsn_csm_contour_map_polar \
                  (wks,mag_diff(:,:), res)
     end if
; draw panel without white space
     resP = True
     resP@gsnPaperOrientation = "portrait"  
     resP@gsnPanelYWhiteSpacePercent = 5
     resP@gsnMaximize         = True        ; maximize plot area
     resP@txFontHeightF       = 0.02        ; Font height of top label
     resP@txFontColor         = "black"          ; Font color of top label
     resP@txString            = main_labels(jj) 
     gsn_panel(wks,plot,(/2,2/),resP)

     delete(res@lbTitleString)

   end if  ; skip plot if fields are identical

  end do   ; End loop through hemispheres
  delete(u_new)
  delete(v_new)
  delete(u_prev)
  delete(v_prev)
  delete(urot_new)
  delete(vrot_new)
  delete(urot_prev)
  delete(vrot_prev)
  delete(u_diff)
  delete(v_diff)
  delete(mag_vel_new)
  delete(mag_vel_prev)
  delete(mag_diff)
  delete(lat2d_new)
  delete(lat2d_prev)

  end do   ; End loop through seasonal means (panels)

  exit
end
