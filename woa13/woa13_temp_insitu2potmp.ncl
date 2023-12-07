load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/nird/home/yanchun/local/ncl/functions/myfun.ncl"

begin
  droot     = getenv("droot")
  tfile     = getenv("tfile")
  sfile     = getenv("sfile")
  potmpfile = getenv("potmpfile")

  tfid      = addfile(droot+"/"+tfile,"r")
  sfid      = addfile(droot+"/"+sfile,"r")
  potmpfid  = addfile(droot+"/"+potmpfile,"w")
  t_an  = tfid->t_an(0,:,:,:)
  s_an  = sfid->s_an(0,:,:,:)
  depth = tfid->depth

  pref  = 0.0                                   ; reference pressure at ocean surface

  pres  = depth_to_pres(depth, False)*10  ; bar->dbar; ignore atmos pressure
  pres@units    = "decibar"
  potmp = potmp_insitu_ocn(t_an,s_an,pres,pref,0,False)

  potmpfid->t_an    = potmp

end

