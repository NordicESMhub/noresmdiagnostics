

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

if (nyears .gt. 1) then
   fnames = wkdir+"/"+case+".*.h.{"+sprinti("%0.4i",nyr1)

   do nn = 1, nyears-1
      fnames = fnames+","+sprinti("%0.4i",nyr1+nn)
   end do

   fnames = fnames+"}*.nc"

else
   fnames = wkdir+"/"+case+".csim.h."+sprinti("%0.4i",nyr1)+"*.nc"
end if

files = systemfunc("ls "+fnames)
f    = addfiles (files, "r")                 ; note the "s" of addfile

tarea = f[0]->tarea
tlat  = f[0]->TLAT

time    = addfiles_GetVar (f, files, "time")
hi    = addfiles_GetVar (f, files, "hi")
ai    = addfiles_GetVar (f, files, "aice")
hs    = addfiles_GetVar (f, files, "hs")

tlat2 = conform(hi,tlat,(/1,2/))

vhi = hi*conform(hi,tarea,(/1,2/))
vai = ai*conform(ai,tarea,(/1,2/))
vhs = hs*conform(hs,tarea,(/1,2/))

vhi_nh = mask(vhi,(tlat2.ge.0.),True)
vai_nh = mask(vai,(tlat2.ge.0.),True)
vhs_nh = mask(vhs,(tlat2.ge.0.),True)

vhi_sh = mask(vhi,(tlat2.ge.0.),False)
vai_sh = mask(vai,(tlat2.ge.0.),False)
vhs_sh = mask(vhs,(tlat2.ge.0.),False)

vhi_mo_nh = dim_sum(dim_sum(vhi_nh))*1.0e-13 
vai_mo_nh = dim_sum(dim_sum(vai_nh))*1.0e-14 
vhs_mo_nh = dim_sum(dim_sum(vhs_nh))*1.0e-13 

vhi_mo_sh = dim_sum(dim_sum(vhi_sh))*1.0e-13 
vai_mo_sh = dim_sum(dim_sum(vai_sh))*1.0e-14 
vhs_mo_sh = dim_sum(dim_sum(vhs_sh))*1.0e-13 

vai_mo_nh!0 = "time"
vai_mo_nh&time = time
vai_mo_nh@units = "1.E+12 m2"
vai_mo_nh@coordinates = "time"
vai_mo_nh@missing_value = 1.e+30
vai_mo_nh@_FillValue = 1.e+30
vai_mo_nh@cell_methods = "time:mean"

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

vai_mo_sh!0 = "time"
vai_mo_sh&time = time
vai_mo_sh@units = "1.E+12 m2"
vai_mo_sh@coordinates = "time"
vai_mo_sh@missing_value = 1.e+30
vai_mo_sh@_FillValue = 1.e+30
vai_mo_sh@cell_methods = "time:mean"

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
filevardef(fout,"vhi_mo_nh",typeof(vhi_mo_nh),getvardims(vhi_mo_nh))
filevardef(fout,"vhs_mo_nh",typeof(vhs_mo_nh),getvardims(vhs_mo_nh))
filevardef(fout,"vai_mo_sh",typeof(vai_mo_sh),getvardims(vai_mo_sh))
filevardef(fout,"vhi_mo_sh",typeof(vhi_mo_sh),getvardims(vhi_mo_sh))
filevardef(fout,"vhs_mo_sh",typeof(vhs_mo_sh),getvardims(vhs_mo_sh))

filevarattdef(fout,"vhi_mo_nh",vhi_mo_nh)
filevarattdef(fout,"vai_mo_nh",vai_mo_nh)
filevarattdef(fout,"vhs_mo_nh",vhs_mo_nh)
filevarattdef(fout,"vhi_mo_sh",vhi_mo_sh)
filevarattdef(fout,"vai_mo_sh",vai_mo_sh)
filevarattdef(fout,"vhs_mo_sh",vhs_mo_sh)

fout->time = time
fout->vhi_mo_nh = vhi_mo_nh
fout->vai_mo_nh = vai_mo_nh
fout->vhs_mo_nh = vhs_mo_nh
fout->vhi_mo_sh = vhi_mo_sh
fout->vai_mo_sh = vai_mo_sh
fout->vhs_mo_sh = vhs_mo_sh

exit
end
