;********************************************************
; landfrac applied to area only.
; using model biome class
;
; required command line input parameters:
;  ncl 'model_name="10cn" model_grid="T42" dirm="/.../ film="..."' 01.npp.ncl
;
; histogram normalized by rain and compute correleration
;**************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************************************
procedure set_line(lines:string,nline:integer,newlines:string) 
begin
; add line to ascci/html file
    
  nnewlines = dimsizes(newlines)
  if(nline+nnewlines-1.ge.dimsizes(lines))
    print("set_line: bad index, not setting anything.") 
    return
  end if 
  lines(nline:nline+nnewlines-1) = newlines
;  print ("lines = " + lines(nline:nline+nnewlines-1))
  nline = nline + nnewlines
  return 
end
;**************************************************************
; Main code.
begin
;--------------------------------------------------
; edit table.html of current model for movel1_vs_model2

 if (isvar("compare")) then
    html_name2 = compare+"/table.html"  
    html_new2  = html_name2 +".new"
 end if

;-------------------------------------
; edit table.html for current model

 html_name = model_name+"/table.html"  
 html_new  = html_name +".new"

;---------------------------------------------------
; add total score and update metric table

  M_save = 0.

  if (isfilepresent("M_save.npp")) then
     M_save = M_save + asciiread("M_save.npp",(/1/),"float")
  end if

  if (isfilepresent("M_save.lai")) then
     M_save = M_save + asciiread("M_save.lai",(/1/),"float")
  end if 

  if (film3 .ne. "") then
  if (isfilepresent("M_save.co2")) then
     M_save = M_save + asciiread("M_save.co2",(/1/),"float")
  end if
  end if

  if (isfilepresent("M_save.biomass")) then
     M_save = M_save + asciiread("M_save.biomass",(/1/),"float")
  end if

  if (isfilepresent("M_save.fluxnet")) then
     M_save = M_save + asciiread("M_save.fluxnet",(/1/),"float")
  end if

  if (isfilepresent("M_save.beta")) then
     M_save = M_save + asciiread("M_save.beta",(/1/),"float")
  end if

  if (isfilepresent("M_save.fire")) then
     M_save = M_save + asciiread("M_save.fire",(/1/),"float")
  end if

  if (isfilepresent("M_save.ameriflux")) then
     M_save = M_save + asciiread("M_save.ameriflux",(/1/),"float")
  end if

  M_total = sprintf("%.2f", M_save)

  if (isvar("compare")) then
     system("sed -e '1,/M_total/s/M_total/"+M_total+"/' "+html_name2+" > "+html_new2+";"+ \
            "mv -f "+html_new2+" "+html_name2)
  end if

  system("sed s#M_total#"+M_total+"# "+html_name+" > "+html_new+";"+ \
         "mv -f "+html_new+" "+html_name+";"+ \
         "rm M_save.*")
exit
end

