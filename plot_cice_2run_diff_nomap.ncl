;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  RT = "/scratch4/NCEPDEV/stmp/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2099962/"

;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "1994"
      cmon = "05"
      cday = "31"
      csec = "00000"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

      rts = (/"base.r100","base.r1000"/)
     cset = "/history/"

     files = addfiles(RT+rts+cset+"iceh_06h."+cyear+"-"+cmon+"-"+cday+"-"+csec+".nc","r")

     print(rts(1)+" - "+rts(0))
     plottitle=rts(1)+" - "+rts(0)

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"ice_diff")

  ;drawNDCGrid(wks)
  plot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillMode = "RasterFill"

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette
   splot = gsn_csm_contour(wks,pltvar,res)

return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")+"@ "+csec+" secs "

;************************************************
;
;************************************************

  ;   varname = "icespd"
  ;     uname = "uvel_h"
  ;     vname = "vvel_h"
  ;   uvar = files[1]->$uname$(lstep,:,:)-files[0]->$uname$(lstep,:,:)
  ;   vvar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ;   ivar = (uvar^2 + vvar^2)^0.5
  ;   ivar = ivar*1e1
  ;   ivar@units = "mm/s"
  ;   ivar@long_name = "Ice speed"
  ;   labelstring = ivar@long_name+" ("+ivar@units+") "

  ;        pltlevs = new((/3/),float)
  ;   labelstrings = new((/2/),string)
  ;   ;colormap = "BlueDarkRed18"
      colormap = "BlueWhiteOrangeRed"
  ;   ;colormap = "amwg256"
  ;   colormap = "cmp_flux"

  ;       ii = 0
  ;    vname = "ice speed"
  ; ; pltlevs = (/-0.1,0.1,0.01/)
  ; pltlevs = (/-0.2,0.2,0.02/)
  ; res@gsnCenterString  = vname
  ; ivar@lon2d = files[0]->$tlonname$*rfactor
  ; ivar@lat2d = files[0]->$tlatname$*rfactor
  ; plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
  ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ;       ii = 1
  ;    vname = "aice_h"
  ;   ivar@units = "nd"
  ;   ivar@long_name = "Ice concentration"
  ;  pltlevs = (/-0.1,0.1,.01/)
  ; ;pltlevs = (/-0.5,0.5,0.05/)
  ; res@gsnCenterString  = vname

  ; ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ; ;ivar = ivar*100.0   ; in cm
  ; ivar@lon2d = files[0]->$tlonname$*rfactor
  ; ivar@lat2d = files[0]->$tlatname$*rfactor
  ; plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
  ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

        ii = 0
     vname = "snoice_h"
   pltlevs = (/-0.12,0.12,.01/)
  ;pltlevs = (/-0.5,0.5,0.05/)
  res@gsnCenterString  = vname

  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ivar@units = " "
  ivar@long_name = " "

  ;ivar = ivar*100.0   ; in cm
  ;ivar@lon2d = files[0]->$tlonname$*rfactor
  ;ivar@lat2d = files[0]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,1/),resP)
  frame(wks)
exit
end
