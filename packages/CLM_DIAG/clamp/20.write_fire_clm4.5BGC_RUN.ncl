;************************************************
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

  year_starts = getenv("first_yr")
  year_ends   = getenv("last_yr")

  nyears = getenv("nyear")
  nmonth = 12

  nlat = stringtointeger(nlats)
  nlon = stringtointeger(nlons)
  year_start = stringtointeger(year_starts)
  year_end = stringtointeger(year_ends)
  nyear = stringtointeger(nyears)
 
  model_name = getenv("caseid") 
  prefix_name = getenv("prefix")
  model_dir = getenv("prefix_dir")
  diro  = model_dir ; end user mods unless changing diri

  filo  = prefix_name + "_Fire_C_" + year_starts + "-" + year_ends + "_monthly.nc"
  c = addfile(diro+filo,"c")
  filedimdef(c,"year",-1,True) 

  data1  = new((/nyear,nmonth,nlat,nlon/),float)
  data2  = new((/nyear,nmonth,nlat,nlon/),float)
  data3  = new((/nyear,nmonth,nlat,nlon/),float)
  date   = new((/nyear,nmonth/),integer)

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

;    print (fili)

     g  = addfile (diri+fili,"r")

     b1 = g->COL_FIRE_CLOSS
     data1(m,n,:,:) = (/b1(0,:,:)/)

     b2 = g->NPP
     data2(m,n,:,:) = (/b2(0,:,:)/)

     b3 = g->NEE
     data3(m,n,:,:) = (/b3(0,:,:)/)        
  end do
  end do

;  name dimensions and assign coordinate variables

  data1!0    ="year"
  data1!1    ="month"
  data1!2    = "lat"
  data1!3    = "lon"
  data1@long_name  = b1@long_name
  data1@units      = b1@units
  data1@_FillValue = b1@_FillValue

  data2!0    ="year"
  data2!1    ="month"
  data2!2    = "lat"
  data2!3    = "lon"
  data2@long_name  = b2@long_name
  data2@units      = b2@units
  data2@_FillValue = b2@_FillValue

  data3!0    ="year"
  data3!1    ="month"
  data3!2    = "lat"
  data3!3    = "lon"
  data3@long_name  = b3@long_name
  data3@units      = b3@units
  data3@_FillValue = b3@_FillValue

  date!0    ="year"
  date!1    ="month"
  date@long_name  = "date: yyyymm"
         
  c->COL_FIRE_CLOSS = data1
  c->NPP            = data2
  c->NEE            = data3
  c->date           = date
  c->area           = g->area

; print (date)

end
