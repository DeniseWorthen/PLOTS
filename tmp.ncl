;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  RT="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"

    hemi = "NH"
 ;   hemi = "SH"

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
     plotlabs = (/"base", "floediam", "base+butterfly"/)
     cset = "/history/"

     files = addfiles(RT+rts+cset+"iceh_06h."+cyear+"-"+cmon+"-"+cday+"-"+csec+".nc","r")
     ;print(files)
     ;print(rts(1)+" - "+rts(0))
     ;plottitle=rts(1)+" - "+rts(0)

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
  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = False

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  ; res@gsnPolar   =  hemi                         ; specify the hemisphere
  ; if(hemi .eq. "NH")then
  ;   res@mpMinLatF    =  66                    ; minimum lat to plot
  ;   res@mpCenterLonF = -45
  ; end if
  ; if(hemi .eq. "SH")then
  ;   res@mpMaxLatF    = -66
  ;   res@mpCenterLonF = 0.0
  ; end if

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

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
function subplot(ii,name,pltvar,pltlevs,pltlab,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  ;print(pltlevs)
  ;print(palette)

   splot = gsn_csm_contour(wks, pltvar, res)
   ;splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
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

  resP@amJust = "BottomLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStrings = (/plotlabs(1)+" - "+plotlabs(0), plotlabs(2)+" - "+plotlabs(0)/)

;************************************************
;
;************************************************

    vname = "aice_h"
    pltlevs = (/-0.02,0.02,.002/)
    lstep=0
    colormap = "BlueWhiteOrangeRed"

    pltlab=plotlabs(1)+" - "+plotlabs(0)
    ii = 0
    ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
    ivar@lon2d = files[0]->$tlonname$*rfactor
    ivar@lat2d = files[0]->$tlatname$*rfactor
    plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,pltlab,colormap)

    pltlab=plotlabs(2)+" - "+plotlabs(0)
    ii = 1
    ivar = files[2]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
    ivar@lon2d = files[0]->$tlonname$*rfactor
    ivar@lat2d = files[0]->$tlatname$*rfactor
    plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,pltlab,colormap)

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/1,2/),resP)
  gsn_panel(wks,plot,(/2,1/),resP)

  frame(wks)
exit
end
