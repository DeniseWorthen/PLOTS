;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  RT="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "2021"
      cmon = "05"
      cday = "06"
      csec = "00000"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

     rts = (/"resid.dev","resid.ec", "resid.dev.fly"/)
     plotlabs = (/"base", "floediam", "butterfly"/)
     cset = "/history/"
     nplots = 2

     files = addfiles(RT+rts+cset+"iceh_06h."+cyear+"-"+cmon+"-"+cday+"-"+csec+".nc","r")

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
  plot = new(nplots,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  ;res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  ;res@gsnCenterStringFontHeightF = 0.020
  ;res@lbLabelFontHeightF         = 0.020

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

   splot = gsn_csm_contour(wks, pltvar, res)
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

  resP@gsnPanelMainString = "aice_h difference at "+cdate
  resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0

  resP@amJust = "BottomLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStrings = (/plotlabs(1)+" - "+plotlabs(0), plotlabs(2)+" - "+plotlabs(0)/)
  ;resP@gsnPanelFigureStrings = (/legendlabs(0), legendlabs(1)/)
;************************************************
;
;************************************************

  legendlabs = new((/nplots/),"string")

  vname = "aice_h"
  pltlevs = (/-0.02,0.02,.002/)
  lstep=0
  colormap = "BlueWhiteOrangeRed"

  ii = 0
  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ;ivar@lon2d = files[0]->$tlonname$*rfactor
  ;var@lat2d = files[0]->$tlatname$*rfactor
  legendlabs(ii) = plotlabs(1)+" - "+plotlabs(0)
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
  ;print(legendlabs(0))

  ii = 1
  ivar = files[2]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  legendlabs(ii) = plotlabs(2)+" - "+plotlabs(0)
  ;ivar@lon2d = files[0]->$tlonname$*rfactor
  ;ivar@lat2d = files[0]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
  ;print(legendlabs(1))
;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/1,2/),resP)
  gsn_panel(wks,plot,(/2,1/),resP)

  frame(wks)
exit
end
