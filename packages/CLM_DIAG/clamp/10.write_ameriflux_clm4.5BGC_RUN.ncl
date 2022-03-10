;************************************************
;    Read ascii, Write nc
;    output: lat: N->S     lon: -180W->180E                         
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;************************************************
begin

; user modifications

  nlats = getenv("nlat")
  nlons = getenv("nlon")

  year_starts =  getenv("first_yr")
  year_ends   =  getenv("last_yr")

  nyears  = getenv("nyear")
  nmonth = 12

  nlat = stringtointeger(nlats)
  nlon = stringtointeger(nlons)
  year_start = stringtointeger(year_starts)
  year_end = stringtointeger(year_ends)
  nyear = stringtointeger(nyears)

  model_name = getenv("caseid")                 
  prefix_name = getenv("prefix")
  model_dir = getenv("prefix_dir")
  diro  = model_dir + "/" ; end user mods unless changing diri

  filo  = prefix_name + "_ameriflux_" + year_start + "-" + year_end + "_monthly.nc"
  c = addfile(diro+filo,"c")
  filedimdef(c,"year",-1,True) 

  data0  = new((/nyear,nmonth,nlat,nlon/),float)
  data1  = new((/nyear,nmonth,nlat,nlon/),float)
  data2  = new((/nyear,nmonth,nlat,nlon/),float)
  data3  = new((/nyear,nmonth,nlat,nlon/),float)
  data4  = new((/nyear,nmonth,nlat,nlon/),float)
  data5a  = new((/nyear,nmonth,nlat,nlon/),float)
  data5b  = new((/nyear,nmonth,nlat,nlon/),float)
  data5c  = new((/nyear,nmonth,nlat,nlon/),float)
  data6  = new((/nyear,nmonth,nlat,nlon/),float)
  data7  = new((/nyear,nmonth,nlat,nlon/),float)
  data8  = new((/nyear,nmonth,nlat,nlon/),float)
  date   = new((/nyear,nmonth/),integer)

;  name dimensions and assign coordinate variables

  data0!0    ="year"
  data0!1    ="month"
  data0!2    = "lat"
  data0!3    = "lon"

  data1!0    ="year"
  data1!1    ="month"
  data1!2    = "lat"
  data1!3    = "lon"

  data2!0    ="year"
  data2!1    ="month"
  data2!2    = "lat"
  data2!3    = "lon"

  data3!0    ="year"
  data3!1    ="month"
  data3!2    = "lat"
  data3!3    = "lon"

  data4!0    ="year"
  data4!1    ="month"
  data4!2    = "lat"
  data4!3    = "lon"

  data5a!0    ="year"
  data5a!1    ="month"
  data5a!2    = "lat"
  data5a!3    = "lon"

  data5b!0    ="year"
  data5b!1    ="month"
  data5b!2    = "lat"
  data5b!3    = "lon"

  data5c!0    ="year"
  data5c!1    ="month"
  data5c!2    = "lat"
  data5c!3    = "lon"

  data6!0    ="year"
  data6!1    ="month"
  data6!2    = "lat"
  data6!3    = "lon"

  data7!0    ="year"
  data7!1    ="month"
  data7!2    = "lat"
  data7!3    = "lon"

  data8!0    ="year"
  data8!1    ="month"
  data8!2    = "lat"
  data8!3    = "lon"

  date!0    ="year"
  date!1    ="month"
  date@long_name  = "date: yyyymm"

; input dir
  diri  = getenv("case_dir") 

  do m = 0,nyear-1
     year = year_start + m
  do n = 0,nmonth-1
     nn = n+1
     date(m,n) = year*100 +nn 
     
;    input file
     if (year .ge. 1000) then
        if (nn .ge. 10) then
           fili = model_name+".clm2.h0."+year+"-"+nn+".nc"
        else
           fili = model_name+".clm2.h0."+year+"-0"+nn+".nc"
        end if
      else
        if (year .ge. 100) then
          if (nn .ge. 10) then
            fili = model_name+".clm2.h0.0"+year+"-"+nn+".nc"
          else
            fili = model_name+".clm2.h0.0"+year+"-0"+nn+".nc"
          end if
        else
          if (year .ge. 10) then
            if (nn .ge. 10) then
              fili = model_name+".clm2.h0.00"+year+"-"+nn+".nc"
            else
              fili = model_name+".clm2.h0.00"+year+"-0"+nn+".nc"
            end if
          else
            if (nn .ge. 10) then
              fili = model_name+".clm2.h0.000"+year+"-"+nn+".nc"
            else
              fili = model_name+".clm2.h0.000"+year+"-0"+nn+".nc"
            end if
          end if
        end if
      end if

     print(diri)
     print(fili)

     g = addfile (diri+fili,"r")

     b = g->NPP
     data0(m,n,:,:) = (/b(0,:,:)/)
     data0@long_name  = b@long_name
     data0@units      = b@units
     data0@_FillValue = b@_FillValue
     delete (b)

     b = g->NEE
     data1(m,n,:,:) = (/b(0,:,:)/)
     data1@long_name  = b@long_name
     data1@units      = b@units
     data1@_FillValue = b@_FillValue
     delete (b)

     b = g->GPP
     data2(m,n,:,:) = (/b(0,:,:)/)
     data2@long_name  = b@long_name
     data2@units      = b@units
     data2@_FillValue = b@_FillValue
     delete (b)

     b = g->AR
     data3(m,n,:,:) = (/b(0,:,:)/)
     b = g->HR
     data3(m,n,:,:) = data3(m,n,:,:)+(/b(0,:,:)/)
     data3@long_name  = "total ecosystem respiration, autotrophic + heterotrophic"
     data3@units      = b@units
     data3@_FillValue = b@_FillValue
     delete (b)

     b = g->FSDS
     data4(m,n,:,:) = (/b(0,:,:)/)
     data4@long_name  = b@long_name
     data4@units      = b@units
     data4@_FillValue = b@_FillValue
     delete (b)

     b = g->FCEV
     data5a(m,n,:,:) = (/b(0,:,:)/)
     data5a@long_name  = "canopy evaporation"
     data5a@units      = b@units
     data5a@_FillValue = b@_FillValue
     delete (b)

     b = g->FCTR
     data5b(m,n,:,:) = (/b(0,:,:)/)
     data5b@long_name  = "canopy transpiration"
     data5b@units      = b@units
     data5b@_FillValue = b@_FillValue
     delete (b)

     b = g->FGEV
     data5c(m,n,:,:) = (/b(0,:,:)/)
     data5c@long_name  = "ground evaporation"
     data5c@units      = b@units
     data5c@_FillValue = b@_FillValue
     delete (b)

     b = g->FSH
     data6(m,n,:,:) = (/b(0,:,:)/)
     data6@long_name  = b@long_name
     data6@units      = b@units
     data6@_FillValue = b@_FillValue
     delete (b)

     b = g->FSDS
     data7(m,n,:,:) = (/b(0,:,:)/)
     data7@long_name  = b@long_name
     data7@units      = b@units
     data7@_FillValue = b@_FillValue
     delete (b)
  
     b = g->COL_FIRE_CLOSS
     data8(m,n,:,:) = (/b(0,:,:)/)
     data8@long_name  = b@long_name
     data8@units      = b@units
     data8@_FillValue = b@_FillValue
     delete (b)
  
  end do
  end do
         
  c->NPP    = data0
  c->NEE    = data1
  c->GPP    = data2
  c->ER     = data3
  c->NETRAD = data4
  c->FCEV   = data5a
  c->FCTR   = data5b
  c->FGEV   = data5c
  c->FSH    = data6
  c->FSDS   = data7
  c->COL_FIRE_CLOSS = data8
  c->date   = date
  c->area   = g->area

; print (date)

end
