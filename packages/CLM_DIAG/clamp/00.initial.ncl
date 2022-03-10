;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;****************************************************************************
; Main code.
;****************************************************************************
begin

;--------------------------------------------------
; edit table.html of current model for movel1_vs_model2

 if (isvar("compare")) then
    html_name2 = compare+"/table.html"  
    html_new2  = html_name2 +".new" 

;   print((/"sed -e '/"+modeln+"/s/"+modeln+"/"+model_name+"/' "+html_name2+" > "+html_new2+";"+ \
;          "mv -f "+html_new2+" "+html_name2/))

    system("sed -e '/"+modeln+"/s/"+modeln+"/"+model_name+"/' "+html_name2+" > "+html_new2+";"+ \
           "mv -f "+html_new2+" "+html_name2)
 end if
;-------------------------------------
; edit table.html for current model

 html_name = model_name+"/table.html"  
 html_new  = html_name +".new"

;print((/"sed s#model_name#"+model_name+"# "+html_name+" > "+html_new+";"+ \
;       "mv -f "+html_new+" "+html_name/))

 system("sed s#model_name#"+model_name+"# "+html_name+" > "+html_new+";"+ \
        "mv -f "+html_new+" "+html_name)
;---------------------------------------------------------------------------
exit
end

