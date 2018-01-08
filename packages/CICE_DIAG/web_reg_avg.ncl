
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

pre_proc = getenv("PRE_PROC_ROOT")
wkdir = getenv("WKDIR")
yr1 = getenv("YR1")
yr2 = getenv("YR2")
yr1_diff = getenv("YR1_DIFF")
yr2_diff = getenv("YR2_DIFF")

xyr1 = stringtofloat(yr1)
xyr1_diff = stringtofloat(yr1_diff)

; This version of the time series plots uses the offsets differently.
; Added flexibility allows the user to plot two time series of different
; lengths and offset the case in the x-direction as needed.

x1_off = stringtofloat(getenv("X1_OFF"))
x2_off = stringtofloat(getenv("X2_OFF"))

ix1_off = stringtoint(getenv("X1_OFF"))
ix2_off = stringtoint(getenv("X2_OFF"))

case_to_cont = getenv("CASE_TO_CONT")
f1 = addfile(pre_proc+"/"+case_to_cont+"/"+"ice_vol_"+case_to_cont+"_"+yr1+"-"+yr2+".nc","r")

plot_line_diff = getenv("PLOT_LINE_DIFF")
if (plot_line_diff .eq. 1) then
   case_to_diff = getenv("CASE_TO_DIFF")
   f2 = addfile(pre_proc+"/"+case_to_diff+"/"+"ice_vol_"+case_to_diff+"_"+yr1_diff+"-"+yr2_diff+".nc","r")
   case = case_to_cont+"-"+case_to_diff
   ncases = 2
else
   case = case_to_cont
   ncases = 1
end if


vhi_mo_Lab_1 = f1->vhi_mo_Lab
vai_mo_Lab_1 = f1->vai_mo_Lab
vhs_mo_Lab_1 = f1->vhs_mo_Lab

ndim = dimsizes(vhi_mo_Lab_1)
ntimes = ndim(0)
nregions = 16
vhi_mo_regions_1 = new((/nregions,ntimes/),float)
vai_mo_regions_1 = new((/nregions,ntimes/),float)
vhs_mo_regions_1 = new((/nregions,ntimes/),float)

vhi_mo_regions_1(0,:) = vhi_mo_Lab_1
vai_mo_regions_1(0,:) = f1->vai_mo_Lab
vhs_mo_regions_1(0,:) = f1->vhs_mo_Lab 
vhi_mo_regions_1(1,:) = f1->vhi_mo_GIN
vai_mo_regions_1(1,:) = f1->vai_mo_GIN
vhs_mo_regions_1(1,:) = f1->vhs_mo_GIN
vhi_mo_regions_1(2,:) = f1->vhi_mo_Bar
vai_mo_regions_1(2,:) = f1->vai_mo_Bar
vhs_mo_regions_1(2,:) = f1->vhs_mo_Bar
vhi_mo_regions_1(3,:) = f1->vhi_mo_ArcOc
vai_mo_regions_1(3,:) = f1->vai_mo_ArcOc
vhs_mo_regions_1(3,:) = f1->vhs_mo_ArcOc
vhi_mo_regions_1(4,:) = f1->vhi_mo_Sib
vai_mo_regions_1(4,:) = f1->vai_mo_Sib
vhs_mo_regions_1(4,:) = f1->vhs_mo_Sib
vhi_mo_regions_1(5,:) = f1->vhi_mo_Beau
vai_mo_regions_1(5,:) = f1->vai_mo_Beau
vhs_mo_regions_1(5,:) = f1->vhs_mo_Beau
vhi_mo_regions_1(6,:) = f1->vhi_mo_CArc
vai_mo_regions_1(6,:) = f1->vai_mo_CArc
vhs_mo_regions_1(6,:) = f1->vhs_mo_CArc

vhi_mo_regions_1(7,:) = f1->vhi_mo_Bering
vai_mo_regions_1(7,:) = f1->vai_mo_Bering
vhs_mo_regions_1(7,:) = f1->vhs_mo_Bering
vhi_mo_regions_1(8,:) = f1->vhi_mo_Okhotsk
vai_mo_regions_1(8,:) = f1->vai_mo_Okhotsk
vhs_mo_regions_1(8,:) = f1->vhs_mo_Okhotsk
vhi_mo_regions_1(9,:) = f1->vhi_mo_Hudson
vai_mo_regions_1(9,:) = f1->vai_mo_Hudson
vhs_mo_regions_1(9,:) = f1->vhs_mo_Hudson
vhi_mo_regions_1(10,:) = f1->vhi_mo_CAArch
vai_mo_regions_1(10,:) = f1->vai_mo_CAArch
vhs_mo_regions_1(10,:) = f1->vhs_mo_CAArch

vhi_mo_regions_1(11,:) = f1->vhi_mo_Wed
vai_mo_regions_1(11,:) = f1->vai_mo_Wed
vhs_mo_regions_1(11,:) = f1->vhs_mo_Wed
vhi_mo_regions_1(12,:) = f1->vhi_mo_Ross
vai_mo_regions_1(12,:) = f1->vai_mo_Ross
vhs_mo_regions_1(12,:) = f1->vhs_mo_Ross
vhi_mo_regions_1(13,:) = f1->vhi_mo_Ind
vai_mo_regions_1(13,:) = f1->vai_mo_Ind
vhs_mo_regions_1(13,:) = f1->vhs_mo_Ind
vhi_mo_regions_1(14,:) = f1->vhi_mo_Pac
vai_mo_regions_1(14,:) = f1->vai_mo_Pac
vhs_mo_regions_1(14,:) = f1->vhs_mo_Pac
vhi_mo_regions_1(15,:) = f1->vhi_mo_BAm
vai_mo_regions_1(15,:) = f1->vai_mo_BAm
vhs_mo_regions_1(15,:) = f1->vhs_mo_BAm

vhi_data1 = new((/nregions,5,ntimes/12/),float)
vai_data1 = new((/nregions,5,ntimes/12/),float)
vhs_data1 = new((/nregions,5,ntimes/12/),float)

ntimes_tot = ntimes

if (ncases .gt. 1) then
   vhi_mo_Lab_2 = f2->vhi_mo_Lab
   vai_mo_Lab_2 = f2->vai_mo_Lab
   vhs_mo_Lab_2 = f2->vhs_mo_Lab

   ndim = dimsizes(vhi_mo_Lab_2)
   ntimes2 = ndim(0)

   vhi_mo_regions_2 = new((/nregions,ntimes2/),float)
   vai_mo_regions_2  = new((/nregions,ntimes2/),float)
   vhs_mo_regions_2 = new((/nregions,ntimes2/),float)

   vhi_mo_regions_2(0,:) = vhi_mo_Lab_2
   vai_mo_regions_2(0,:) = f2->vai_mo_Lab
   vhs_mo_regions_2(0,:) = f2->vhs_mo_Lab 
   vhi_mo_regions_2(1,:) = f2->vhi_mo_GIN
   vai_mo_regions_2(1,:) = f2->vai_mo_GIN
   vhs_mo_regions_2(1,:) = f2->vhs_mo_GIN
   vhi_mo_regions_2(2,:) = f2->vhi_mo_Bar
   vai_mo_regions_2(2,:) = f2->vai_mo_Bar
   vhs_mo_regions_2(2,:) = f2->vhs_mo_Bar
   vhi_mo_regions_2(3,:) = f2->vhi_mo_ArcOc
   vai_mo_regions_2(3,:) = f2->vai_mo_ArcOc
   vhs_mo_regions_2(3,:) = f2->vhs_mo_ArcOc
   vhi_mo_regions_2(4,:) = f2->vhi_mo_Sib
   vai_mo_regions_2(4,:) = f2->vai_mo_Sib
   vhs_mo_regions_2(4,:) = f2->vhs_mo_Sib
   vhi_mo_regions_2(5,:) = f2->vhi_mo_Beau
   vai_mo_regions_2(5,:) = f2->vai_mo_Beau
   vhs_mo_regions_2(5,:) = f2->vhs_mo_Beau
   vhi_mo_regions_2(6,:) = f2->vhi_mo_CArc
   vai_mo_regions_2(6,:) = f2->vai_mo_CArc
   vhs_mo_regions_2(6,:) = f2->vhs_mo_CArc
   vhi_mo_regions_2(7,:) = f2->vhi_mo_Bering
   vai_mo_regions_2(7,:) = f2->vai_mo_Bering
   vhs_mo_regions_2(7,:) = f2->vhs_mo_Bering
   vhi_mo_regions_2(8,:) = f2->vhi_mo_Okhotsk
   vai_mo_regions_2(8,:) = f2->vai_mo_Okhotsk
   vhs_mo_regions_2(8,:) = f2->vhs_mo_Okhotsk
   vhi_mo_regions_2(9,:) = f2->vhi_mo_Hudson
   vai_mo_regions_2(9,:) = f2->vai_mo_Hudson
   vhs_mo_regions_2(9,:) = f2->vhs_mo_Hudson
   vhi_mo_regions_2(10,:) = f2->vhi_mo_CAArch
   vai_mo_regions_2(10,:) = f2->vai_mo_CAArch
   vhs_mo_regions_2(10,:) = f2->vhs_mo_CAArch
   vhi_mo_regions_2(11,:) = f2->vhi_mo_Wed
   vai_mo_regions_2(11,:) = f2->vai_mo_Wed
   vhs_mo_regions_2(11,:) = f2->vhs_mo_Wed
   vhi_mo_regions_2(12,:) = f2->vhi_mo_Ross
   vai_mo_regions_2(12,:) = f2->vai_mo_Ross
   vhs_mo_regions_2(12,:) = f2->vhs_mo_Ross
   vhi_mo_regions_2(13,:) = f2->vhi_mo_Ind
   vai_mo_regions_2(13,:) = f2->vai_mo_Ind
   vhs_mo_regions_2(13,:) = f2->vhs_mo_Ind
   vhi_mo_regions_2(14,:) = f2->vhi_mo_Pac
   vai_mo_regions_2(14,:) = f2->vai_mo_Pac
   vhs_mo_regions_2(14,:) = f2->vhs_mo_Pac
   vhi_mo_regions_2(15,:) = f2->vhi_mo_BAm
   vai_mo_regions_2(15,:) = f2->vai_mo_BAm
   vhs_mo_regions_2(15,:) = f2->vhs_mo_BAm

   ntimes_tot = max((/ntimes+ix1_off*12,ntimes2+ix2_off*12/))

   vhi_data2 = new((/nregions,5,ntimes2/12/),float)
   vai_data2 = new((/nregions,5,ntimes2/12/),float)
   vhs_data2 = new((/nregions,5,ntimes2/12/),float)

end if

do nr=0,nregions-1
; Compute seasonal and annual means

   vhi_mo_1 = onedtond(vhi_mo_regions_1(nr,:),(/ntimes/12,12/))
   vhi_mo_1!0 = "years"
   vhi_mo_1!1 = "months"
   vhi_data1(nr,0,:) = dim_avg(vhi_mo_1)
   vhi_data1(nr,1,:) = dim_avg(vhi_mo_1(years|:,months|0:2))
   vhi_data1(nr,2,:) = dim_avg(vhi_mo_1(years|:,months|3:5))
   vhi_data1(nr,3,:) = dim_avg(vhi_mo_1(years|:,months|6:8))
   vhi_data1(nr,4,:) = dim_avg(vhi_mo_1(years|:,months|9:11))

   vhs_mo_1 = onedtond(vhs_mo_regions_1(nr,:),(/ntimes/12,12/))
   vhs_mo_1!0 = "years"
   vhs_mo_1!1 = "months"
   vhs_data1(nr,0,:) = dim_avg(vhs_mo_1)
   vhs_data1(nr,1,:) = dim_avg(vhs_mo_1(years|:,months|0:2))
   vhs_data1(nr,2,:) = dim_avg(vhs_mo_1(years|:,months|3:5))
   vhs_data1(nr,3,:) = dim_avg(vhs_mo_1(years|:,months|6:8))
   vhs_data1(nr,4,:) = dim_avg(vhs_mo_1(years|:,months|9:11))

   vai_mo_1 = onedtond(vai_mo_regions_1(nr,:),(/ntimes/12,12/))
   vai_mo_1!0 = "years"
   vai_mo_1!1 = "months"
   vai_data1(nr,0,:) = dim_avg(vai_mo_1)
   vai_data1(nr,1,:) = dim_avg(vai_mo_1(years|:,months|0:2))
   vai_data1(nr,2,:) = dim_avg(vai_mo_1(years|:,months|3:5))
   vai_data1(nr,3,:) = dim_avg(vai_mo_1(years|:,months|6:8))
   vai_data1(nr,4,:) = dim_avg(vai_mo_1(years|:,months|9:11))

   if (ncases .gt. 1) then
      vhi_mo_2 = onedtond(vhi_mo_regions_2(nr,:),(/ntimes2/12,12/))
      vhi_mo_2!0 = "years" 
      vhi_mo_2!1 = "months"
      vhi_data2(nr,0,:) = dim_avg(vhi_mo_2)
      vhi_data2(nr,1,:) = dim_avg(vhi_mo_2(years|:,months|0:2))
      vhi_data2(nr,2,:) = dim_avg(vhi_mo_2(years|:,months|3:5))
      vhi_data2(nr,3,:) = dim_avg(vhi_mo_2(years|:,months|6:8))
      vhi_data2(nr,4,:) = dim_avg(vhi_mo_2(years|:,months|9:11))
   
      vhs_mo_2 = onedtond(vhs_mo_regions_2(nr,:),(/ntimes2/12,12/))
      vhs_mo_2!0 = "years" 
      vhs_mo_2!1 = "months"
      vhs_data2(nr,0,:) = dim_avg(vhs_mo_2)
      vhs_data2(nr,1,:) = dim_avg(vhs_mo_2(years|:,months|0:2))
      vhs_data2(nr,2,:) = dim_avg(vhs_mo_2(years|:,months|3:5))
      vhs_data2(nr,3,:) = dim_avg(vhs_mo_2(years|:,months|6:8))
      vhs_data2(nr,4,:) = dim_avg(vhs_mo_2(years|:,months|9:11))
   
      vai_mo_2 = onedtond(vai_mo_regions_2(nr,:),(/ntimes2/12,12/))
      vai_mo_2!0 = "years"
      vai_mo_2!1 = "months" 
      vai_data2(nr,0,:) = dim_avg(vai_mo_2)
      vai_data2(nr,1,:) = dim_avg(vai_mo_2(years|:,months|0:2))
      vai_data2(nr,2,:) = dim_avg(vai_mo_2(years|:,months|3:5))
      vai_data2(nr,3,:) = dim_avg(vai_mo_2(years|:,months|6:8))
      vai_data2(nr,4,:) = dim_avg(vai_mo_2(years|:,months|9:11))
   end if

end do

ice_mon_area = new((/nregions,ntimes_tot/),float)
ice_max_area = new((/nregions,ntimes_tot/),float)
ice_min_area = new((/nregions,ntimes_tot/),float)

ice_mon_area@_FillValue = -999
ice_mon_area(0,ntimes_tot-12:ntimes_tot-1) =  \
   (/1.057, 1.1732, 1.1799, 1.0912, 0.8993, 0.6336, 0.3097, \
     0.0635, 0.0224, 0.1478, 0.5077, 0.7933 /)
ice_max_area(0,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(0,:))
ice_min_area(0,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(0,:))

ice_mon_area(1,ntimes_tot-12:ntimes_tot-1) = \
   (/ 0.5367, 0.5494, 0.5372, 0.5180, 0.4468, 0.3726, 0.2694, \
      0.1607, 0.1616, 0.2788, 0.381, 0.4738/)
ice_max_area(1,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(1,:))
ice_min_area(1,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(1,:))

ice_mon_area(2,ntimes_tot-12:ntimes_tot-1) = \
   (/ 1.3551, 1.4171, 1.4215, 1.4529, 1.2997, 1.0107, 0.6158, \
      0.2575, 0.1668, 0.4915, 0.9840, 1.12144/)
ice_max_area(2,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(2,:))
ice_min_area(2,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(2,:))

ice_mon_area(3,ntimes_tot-12:ntimes_tot-1) = \
   (/ 7.0293, 7.0360, 7.0382, 7.0448, 7.0040, 6.7064, 6.1653, \
      5.4009, 5.3122, 6.3462, 6.8888, 7.0344/)
ice_max_area(3,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(3,:))
ice_min_area(3,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(3,:))

ice_mon_area(4,ntimes_tot-12:ntimes_tot-1) = \
   (/ 2.1979, 2.1954, 2.1976, 2.1954, 2.1745, 2.0077, 1.7000, \
     1.2259, 1.1517, 1.8395, 2.1160, 2.2012/)
ice_max_area(4,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(4,:))
ice_min_area(4,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(4,:))

ice_mon_area(5,ntimes_tot-12:ntimes_tot-1) = \
   (/ 1.5149, 1.5130, 1.5111, 1.5148, 1.4880, 1.3638, 1.2086, \
      1.0144, 1.0157, 1.2461, 1.4655, 1.5156/)
ice_max_area(5,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(5,:))
ice_min_area(5,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(5,:))

ice_mon_area(6,ntimes_tot-12:ntimes_tot-1) = \
   (/ 3.3165, 3.3276, 3.3295, 3.3347, 3.3414, 3.3349, 3.2568, 3.1615, \
      3.1449, 3.2606, 3.3074, 3.3176/)
ice_max_area(6,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(6,:))
ice_min_area(6,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(6,:))

ice_mon_area(7,ntimes_tot-12:ntimes_tot-1) = \
   (/ 0.5805, 0.6825, 0.7258, 0.6051, 0.2910, 0.0549, 0.0048, \
      0.0011, 0.0016, 0.0074, 0.0935, 0.3686/)
ice_max_area(7,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(7,:))
ice_min_area(7,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(7,:))

ice_mon_area(8,ntimes_tot-12:ntimes_tot-1) = \
   (/ 0.6079, 0.8955, 0.9309, 0.5798, 0.1515, 0.0235, 0.0006, \
     0.00000, 0.0000, 0.0002, 0.0139, 0.2111/)
ice_max_area(8,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(8,:))
ice_min_area(8,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(8,:))

ice_mon_area(9,ntimes_tot-12:ntimes_tot-1) = \
   (/ 1.1551, 1.1626, 1.1610, 1.1493, 1.0711, 0.8136, 0.3422, \
      0.0694, 0.0170, 0.0482, 0.3807, 1.0148/)
ice_max_area(9,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(9,:))
ice_min_area(9,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(9,:))

ice_mon_area(10,ntimes_tot-12:ntimes_tot-1) = \
   (/ 0.5633, 0.5606, 0.5606, 0.5617, 0.5611, 0.5250, 0.4881, \
      0.4006, 0.3816, 0.5225, 0.5648, 0.5657/)
ice_max_area(10,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(10,:))
ice_min_area(10,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(10,:))

ice_mon_area(11,ntimes_tot-12:ntimes_tot-1) = \
   (/ 1.3270, 0.8938, 1.1207, 1.8940, 3.0629, 4.2639, 5.2141, \
     5.7140, 5.8563, 5.5995, 4.8859, 2.9889/)
ice_max_area(11,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(11,:))
ice_min_area(11,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(11,:))

ice_mon_area(12,ntimes_tot-12:ntimes_tot-1) = \
   (/  0.6879, 0.3424, 0.7425, 1.5638, 2.1772, 2.5934, 2.9363, \
     3.0767, 3.0820, 3.0063, 2.6774, 1.6719/) 
ice_max_area(12,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(12,:))
ice_min_area(12,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(12,:))

ice_mon_area(13,ntimes_tot-12:ntimes_tot-1) = \
   (/  0.2530, 0.1101, 0.1579, 0.4537, 0.9642, 1.5665, 2.1796,\
      2.6866, 2.9934, 3.01365, 2.3006, 0.8843/)
ice_max_area(13,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(13,:))
ice_min_area(13,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(13,:))

ice_mon_area(14,ntimes_tot-12:ntimes_tot-1) = \
   (/  0.3683, 0.2310, 0.2744, 0.5224, 0.8443, 1.1136, 1.3012,\
       1.4531, 1.4770, 1.4152, 1.0433, 0.5743/)
ice_max_area(14,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(14,:))
ice_min_area(14,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(14,:))

ice_mon_area(15,ntimes_tot-12:ntimes_tot-1) = \
   (/   0.7738, 0.4954, 0.5579, 0.8964, 1.2854, 1.6407, 1.9414,\
       2.1922, 2.2838, 2.1561, 1.8657, 1.3109/)
ice_max_area(15,:) = fspan(1,1,ntimes_tot)*max(ice_mon_area(15,:))
ice_min_area(15,:) = fspan(1,1,ntimes_tot)*min(ice_mon_area(15,:))

plotname  = new((/nregions,6/),string)
plotname2 = new((/nregions,5/),string)
title     = new((/nregions,6/),string)
title2    = new((/nregions,5/),string)

region_titles = (/"Lab","GIN","Bar","ArcOC", "Sib","Beau","CArc","Bering","Okhotsk","Hudson",\
     "CAArch","Wed","Ross","Ind","Pac","BAm"/)

title(0:nregions-1,0) = "ANN Mean "+case
title(0:nregions-1,1) = "JFM Mean "+case
title(0:nregions-1,2) = "AMJ Mean "+case
title(0:nregions-1,3) = "JAS Mean "+case
title(0:nregions-1,4) = "OND Mean "+case
title(0:nregions-1,5) = case

title2(0:nregions-1,0) = "ANN Anomalies "+case
title2(0:nregions-1,1) = "JFM Anomalies "+case
title2(0:nregions-1,2) = "AMJ Anomalies "+case
title2(0:nregions-1,3) = "JAS Anomalies "+case
title2(0:nregions-1,4) = "OND Anomalies "+case

if (ncases .gt. 1) then
   add_title = "_diff"
else
   add_title = ""
end if
do nr=0,nregions-1
   plotname(nr,0) = "line_avg_ANN_" + region_titles(nr) + add_title
   plotname(nr,1) = "line_avg_JFM_" + region_titles(nr) + add_title
   plotname(nr,2) = "line_avg_AMJ_" + region_titles(nr) + add_title
   plotname(nr,3) = "line_avg_JAS_" + region_titles(nr) + add_title
   plotname(nr,4) = "line_avg_OND_" + region_titles(nr) + add_title
   plotname(nr,5) = "line_mo_" + region_titles(nr) + add_title

   plotname2(nr,0) = "line_var_ANN_" + region_titles(nr) + add_title
   plotname2(nr,1) = "line_var_JFM_" + region_titles(nr) + add_title
   plotname2(nr,2) = "line_var_AMJ_" + region_titles(nr) + add_title
   plotname2(nr,3) = "line_var_JAS_" + region_titles(nr) + add_title
   plotname2(nr,4) = "line_var_OND_" + region_titles(nr) + add_title

end do
resP = True
resP@gsnMaximize         = True
resP@gsnPaperOrientation = "portrait"
resP@txFont              = "helvetica"
resP@txFuncCode          = "~"
resP@tiMainFont          = "helvetica"
resP@tiMainFuncCode          = "~"
resP@tiXAxisFont          = "helvetica"
resP@tiXAxisFuncCode          = "~"
resP@tiYAxisFont          = "helvetica"
resP@tiYAxisFuncCode          = "~"
resP@tmXBLabelFont          = "helvetica"
resP@tmYLLabelFont          = "helvetica"

resP@gsnPanelYWhiteSpacePercent = 0.0

res = True
res@gsnDraw = False
res@gsnFrame = False
res@txFont   = "helvetica"
res@txFuncCode = "~"
res@tiMainFont          = "helvetica"
res@tiMainFuncCode          = "~"
res@tiXAxisFont          = "helvetica"
res@tiXAxisFuncCode          = "~"
res@tiYAxisFont          = "helvetica"
res@tiYAxisFuncCode          = "~"
res@tmXBLabelFont          = "helvetica"
res@tmYLLabelFont          = "helvetica"

res@tmYLAutoPrecision = False
res@tmYLPrecision = 3

res@vpHeightF = 0.2
res@vpWidthF = 0.9

do iseas=0,5

climatol = False
if (iseas .eq. 5) then
   climatol = True
end if

do nr=0,nregions-1

   resP@txString = title(nr,iseas)

   if (climatol) then
      if (ncases .gt. 1) then

         delete(res@xyLineThicknesses)
         delete(res@xyDashPatterns)
         delete(res@xyLineColors)
         resb = res

         resb@xyLineThicknesses = (/2/)
         resb@xyLineColors      = (/"red"/)

      end if

      res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines","Markers"/)
      res@xyMarkerColors  = (/"white","white","white","white","red"/)
      res@xyMarkers         = (/0,0,0,0,0/)
      res@xyDashPatterns    = (/0,0,0,0,0/)
      res@xyLineThicknesses = (/2,1,1,1,1/)    
      res@xyLineColors      = (/"blue","cyan","black","black","white"/)

;****************************************************
; Line that adds climatological average, min and max
; is deleted out for now (y3 = ...). We don't have 
; climatological values yet for individual regions ....
;****************************************************
       if (ncases .gt. 1) then
          y1   = new((/ntimes_tot/),float)
          y2   = new((/ntimes_tot/),float)
          y3   = new((/5,ntimes_tot/),float)
          y1b  = new((/ntimes_tot/),float)
          y2b  = new((/ntimes_tot/),float)
          y3b  = new((/ntimes_tot/),float)
          y1   = -999.
          y2   = -999.
          y3   = -999.
          y1b  = -999.
          y2b  = -999.
          y3b  = -999.

          y1(ix1_off*12:ntimes-1+ix1_off*12)  = vhi_mo_regions_1(nr,:)
          y2(ix1_off*12:ntimes-1+ix1_off*12)  = vhs_mo_regions_1(nr,:)
          y1b(ix2_off*12:ntimes2-1+ix2_off*12) = vhi_mo_regions_2(nr,:)
          y2b(ix2_off*12:ntimes2-1+ix2_off*12) = vhs_mo_regions_2(nr,:)
          vai_mean = fspan(1,1,ntimes_tot)*avg(vai_mo_regions_1(nr,:))
          y3(0,ix1_off*12:ntimes-1+ix1_off*12)  = vai_mo_regions_1(nr,:)
          y3(1:4,:)  = (/vai_mean, ice_max_area(nr,:), ice_min_area(nr,:), \
                                  ice_mon_area(nr,:)/)
          y3b(ix2_off*12:ntimes2-1+ix2_off*12) = vai_mo_regions_2(nr,:)

          x1 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1      - x1_off
          x2 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1_diff - x2_off

       else
          y1 = vhi_mo_regions_1(nr,:)
          y2 = vhs_mo_regions_1(nr,:)
          vai_mean = fspan(1,1,ntimes_tot)*avg(vai_mo_regions_1(nr,:))
          y3 = (/vai_mo_regions_1(nr,:),vai_mean,ice_max_area(nr,:), \
                  ice_min_area(nr,:),ice_mon_area(nr,:)/)

          x1 = vhi_mo_regions_1&time / 365.
          x2 = x1

       end if

    else

       if (ncases .gt. 1) then
          res@xyLineThicknesses = (/2/)
          res@xyDashPatterns    = (/0/)
          res@xyLineColors      = (/"blue"/)
          resb = res
          resb@xyLineColors      = (/"red"/)

          y1   = new((/ntimes_tot/12/),float)
          y2   = new((/ntimes_tot/12/),float)
          y3   = new((/ntimes_tot/12/),float)
          y1b  = new((/ntimes_tot/12/),float)
          y2b  = new((/ntimes_tot/12/),float)
          y3b  = new((/ntimes_tot/12/),float)
          y1   = -999.
          y2   = -999.
          y3   = -999.
          y1b  = -999.
          y2b  = -999.
          y3b  = -999.
          y4   = new((/ntimes_tot/12/),float)
          y5   = new((/ntimes_tot/12/),float)
          y6   = new((/ntimes_tot/12/),float)
          y4b  = new((/ntimes_tot/12/),float)
          y5b  = new((/ntimes_tot/12/),float)
          y6b  = new((/ntimes_tot/12/),float)
          y4   = -999.
          y5   = -999.
          y6   = -999.
          y4b  = -999.
          y5b  = -999.
          y6b  = -999.

          y1(ix1_off:ntimes/12-1+ix1_off)  = vhi_data1(nr,iseas,:)
          y2(ix1_off:ntimes/12-1+ix1_off)  = vhs_data1(nr,iseas,:)
          y3(ix1_off:ntimes/12-1+ix1_off)  = vai_data1(nr,iseas,:)
          y1b(ix2_off:ntimes2/12-1+ix2_off) = vhi_data2(nr,iseas,:)
          y2b(ix2_off:ntimes2/12-1+ix2_off) = vhs_data2(nr,iseas,:)
          y3b(ix2_off:ntimes2/12-1+ix2_off) = vai_data2(nr,iseas,:)

          vhi_anom0 = vhi_data1(nr,iseas,:)-dim_avg(vhi_data1(nr,iseas,:))
          vhs_anom0 = vhs_data1(nr,iseas,:)-dim_avg(vhs_data1(nr,iseas,:))
          vai_anom0 = vai_data1(nr,iseas,:)-dim_avg(vai_data1(nr,iseas,:))
          vhi_anom1 = vhi_data2(nr,iseas,:)-dim_avg(vhi_data2(nr,iseas,:))
          vhs_anom1 = vhs_data2(nr,iseas,:)-dim_avg(vhs_data2(nr,iseas,:))
          vai_anom1 = vai_data2(nr,iseas,:)-dim_avg(vai_data2(nr,iseas,:))

          y4(ix1_off:ntimes/12-1+ix1_off)  = vhi_anom0
          y5(ix1_off:ntimes/12-1+ix1_off)  = vhs_anom0
          y6(ix1_off:ntimes/12-1+ix1_off)  = vai_anom0
          y4b(ix2_off:ntimes2/12-1+ix2_off) = vhi_anom1
          y5b(ix2_off:ntimes2/12-1+ix2_off) = vhs_anom1
          y6b(ix2_off:ntimes2/12-1+ix2_off) = vai_anom1

          x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1      - x1_off
          x2 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1_diff - x2_off

       else
          res@xyLineThicknessF = 2
          res@xyLineColor      = "blue"
          y1 = vhi_data1(nr,iseas,:)
          y2 = vhs_data1(nr,iseas,:)
          y3 = vai_data1(nr,iseas,:)
          vhi_anom0 = vhi_data1(nr,iseas,:)-dim_avg(vhi_data1(nr,iseas,:))
          vhs_anom0 = vhs_data1(nr,iseas,:)-dim_avg(vhs_data1(nr,iseas,:))
          vai_anom0 = vai_data1(nr,iseas,:)-dim_avg(vai_data1(nr,iseas,:))
          y4 = vhi_anom0
          y5 = vhs_anom0
          y6 = vai_anom0

          x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + stringtofloat(yr1)
          x2 = x1

       end if

   end if

   wks1 = gsn_open_wks("ps",wkdir+plotname(nr,iseas))

   y1@long_name = region_titles(nr) + " Ice Volume 10~S~13~N~ m~S~3~N~"
   y2@long_name = region_titles(nr) + " Snow Volume 10~S~13~N~ m~S~3~N~"
   y3@long_name = region_titles(nr) + " Ice Area 10~S~12~N~ m~S~2~N~"

   y1@_FillValue = -999
   y2@_FillValue = -999
   y3@_FillValue = -999
   x1@units = "years"
   x1@long_name = "Years"

   res@tmXMajorGrid = True
   res@tmXMajorGridLineDashPattern = 2
   res@tmXMajorGridThicknessF = 1
   if (ncases .gt. 1) then
      res@gsnRightString = case_to_cont
      res@gsnRightStringFontColor = "blue"
      res@gsnLeftString = case_to_diff
      res@gsnLeftStringFontColor = "red"

      y1b@_FillValue = -999.
      y2b@_FillValue = -999.
      y3b@_FillValue = -999.
      x2@units = "years"
      x2@long_name = "Years"

;      print(x1)
;      print(x2)

      res@tmXBLabelFontColor = "blue"

      res@trYMinF = min((/min(y1),min(y1b)/))
      res@trYMaxF = max((/max(y1),max(y1b)/))
      resb@trYMinF = min((/min(y1),min(y1b)/))
      resb@trYMaxF = max((/max(y1),max(y1b)/))

      resb@gsnRightString = " "
      resb@gsnLeftString = " "
      resb@tmXTLabelFontColor = "red"
      resb@tmYROn = False
      resb@tmXMajorGrid = False
      ;resb@tmYMajorGrid = False

      res@trXMinF = min((/min(x1),min(x1)/))
      res@trXMaxF = max((/max(x1),max(x1)/))
      resb@trXMinF = min((/min(x2),min(x2)/))
      resb@trXMaxF = max((/max(x2),max(x2)/))

      plot1 = gsn_csm_x2y2(wks1,x1,x2,y1,y1b,res,resb)
      res@gsnRightString = " "
      res@gsnLeftString = " "
      res@trYMinF = min((/min(y2),min(y2b)/))
      res@trYMaxF = max((/max(y2),max(y2b)/))
      resb@trYMinF = min((/min(y2),min(y2b)/))
      resb@trYMaxF = max((/max(y2),max(y2b)/))
      plot2 = gsn_csm_x2y2(wks1,x1,x2,y2,y2b,res,resb)
      res@trYMinF = min((/min(y3),min(y3b)/))
      res@trYMaxF = max((/max(y3),max(y3b)/))
      resb@trYMinF = min((/min(y3),min(y3b)/))
      resb@trYMaxF = max((/max(y3),max(y3b)/))
      plot3 = gsn_csm_x2y2(wks1,x1,x2,y3,y3b,res,resb)
   else
      res@trXMinF = min((/x1/))
      res@trXMaxF = max((/x1/))
      plot1 = gsn_csm_xy(wks1,x1,y1,res)
      plot2 = gsn_csm_xy(wks1,x1,y2,res)
      plot3 = gsn_csm_xy(wks1,x1,y3,res)
   end if
;   txres               = True
;   txres@txFontHeightF = 19
;   txres@txFontColor   = "blue"
;   txres@txFont        = "helvetica"
;   gsn_text_ndc(wks1,case_to_cont,0.30,0.92,txres)

;   if (ncases .gt. 1) then
;      txres               = True
;      txres@txFontHeightF = 19
;      txres@txFontColor   = "red"
;      gsn_text_ndc(wks1,case_to_diff,0.80,0.92,txres)
;   end if

   gsn_panel(wks1,(/plot1,plot2,plot3/),(/3,1/),resP)

   if (.not. climatol) then

      wks2 = gsn_open_wks("ps",wkdir+plotname2(nr,iseas))

      res2 = res
      resP2 = resP
      resP2@txString = title2(nr,iseas)

      y4@long_name = region_titles(nr) + " Ice Volume 10~S~13~N~ m~S~3~N~"
      y5@long_name = region_titles(nr) + " Snow Volume 10~S~13~N~ m~S~3~N~"
      y6@long_name = region_titles(nr) + " Ice Area 10~S~12~N~ m~S~2~N~"

      y4@_FillValue = -999
      y5@_FillValue = -999
      y6@_FillValue = -999
      x1@units = "years"
      x1@long_name = "Years"

      if (ncases .gt. 1) then
         res2@gsnRightString = case_to_cont
         res2@gsnRightStringFontColor = "blue"
         res2@gsnLeftString = case_to_diff
         res2@gsnLeftStringFontColor = "red"

         y4b@_FillValue = -999.
         y5b@_FillValue = -999.
         y6b@_FillValue = -999.
         x2@units = "years"
         x2@long_name = "Years"

         res2b = resb
         res2@tmXBLabelFontColor = "blue"
         res2b@tmXMajorGrid = False
         ;res2b@tmYMajorGrid = False

         res2@trYMinF = min((/min(y4),min(y4b)/))
         res2@trYMaxF = max((/max(y4),max(y4b)/))
         res2b@trYMinF = min((/min(y4),min(y4b)/))
         res2b@trYMaxF = max((/max(y4),max(y4b)/))

         res2b@tmXTLabelFontColor = "red"
         res2b@tmYROn = False

         res2@trXMinF = min((/min(x1),min(x1)/))
         res2@trXMaxF = max((/max(x1),max(x1)/))
         res2b@trXMinF = min((/min(x2),min(x2)/))
         res2b@trXMaxF = max((/max(x2),max(x2)/))

         plot4 = gsn_csm_x2y2(wks2,x1,x2,y4,y4b,res2,res2b)
         res2@trYMinF = min((/min(y5),min(y5b)/))
         res2@trYMaxF = max((/max(y5),max(y5b)/))
         res2b@trYMinF = min((/min(y5),min(y5b)/))
         res2b@trYMaxF = max((/max(y5),max(y5b)/))
         plot5 = gsn_csm_x2y2(wks2,x1,x2,y5,y5b,res2,res2b)
         res2@trYMinF = min((/min(y6),min(y6b)/))
         res2@trYMaxF = max((/max(y6),max(y6b)/))
         res2b@trYMinF = min((/min(y6),min(y6b)/))
         res2b@trYMaxF = max((/max(y6),max(y6b)/))
         plot6 = gsn_csm_x2y2(wks2,x1,x2,y6,y6b,res2,res2b)
      else
         res2@trXMinF = min((/x1/))
         res2@trXMaxF = max((/x1/))
         plot4 = gsn_csm_xy(wks2,x1,y4,res2)
         plot5 = gsn_csm_xy(wks2,x1,y5,res2)
         plot6 = gsn_csm_xy(wks2,x1,y6,res2)
      end if
      txres               = True
      txres@txFontHeightF = 19
      txres@txFontColor   = "blue"
      gsn_text_ndc(wks2,case_to_cont,0.30,0.92,txres)

      if (ncases .gt. 1) then
         txres               = True
         txres@txFontHeightF = 19
         txres@txFontColor   = "red"
         gsn_text_ndc(wks2,case_to_diff,0.80,0.92,txres)
      end if

      gsn_panel(wks2,(/plot4,plot5,plot6/),(/3,1/),resP2)

      delete(y4)
      delete(y5)
      delete(y6)

      delete(resP2@txString)
      if (ncases .gt. 1) then
         delete(y4b)
         delete(y5b)
         delete(y6b)
      end if

   end if

   delete(y1)
   delete(y2)
   delete(y3)
   delete(x1)
   delete(x2)
   delete(resP@txString)

   if (ncases .gt. 1) then
      delete(y1b)
      delete(y2b)
      delete(y3b)
   end if

end do

end do

exit
end
