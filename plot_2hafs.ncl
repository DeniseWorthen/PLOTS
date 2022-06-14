; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; cheyenne
  ;RT1 = "/glade/scratch/worthen/FV3_RT/hafs_newold/"
  ;RT1 = "/glade/scratch/worthen/FV3_RT/wave_hafs3/"
  RT1 = "/glade/scratch/worthen/FV3_RT/rt_39580/"

 ;plotlabs = (/"new Cap", "current Cap"/)
 ;plotlabs = (/"new Cap", "new Cap test"/)
 ;plotlabs = (/"new Cap", ""/)
 ;     rts = (/"test/", "testnsea/"/)
 plotlabs = (/"hafs_regional_atm_ocn_wav"/)
      rts = (/"hafs_regional_atm_ocn_wav/"/)

  date = "2019-08-29-21600"
  ;date = "2019-08-29-00360"
  files1 = addfile(RT1+rts(0)+"ufs.hafs.cpl.hi.wav."+date+".nc","r")
  ;files2 = addfile(RT1+rts(1)+"ufs.hafs.cpl.hi.wav."+date+".nc","r")
  ; coupler fields
  flds = (/"wavImp_Sw_z0"/)
  nflds = dimsizes(flds)

  ; easier plots
  fldwgts = (/1.e3/)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    0.5,  0.01/)   ; z0

  cmap="BlueWhiteOrangeRed"
  
;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
        wgt = fldwgts(fldtoplot)
   ;wkstitle = flds(fldtoplot)+"_"+date
   wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
   plottitle="Exported "+flds(fldtoplot)+"(*"+sprintf("%5.0e", wgt)+")"
   ;plottitle=plotlabs(0)

;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
  oplot = new(3,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@cnInfoLabelOn       = False           ; turn off cn info label

 res@vpWidthF          = 0.70
 res@vpHeightF         = 0.40

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/0.1/)

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

   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

   splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = True                  ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True                   ; use full page

  resP@gsnPanelFigureStrings = (/date,date/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.01
; ***************************************************
;
; ***************************************************

  ii = 0
  name = flds(fldtoplot)
  f1 = files1->$name$(0,:,:)
  plot(ii) = subplot(ii,"",wgt*f1,levs,cmap)

  ;ii = 1
  ;ii = 0
  ;plotlabs(ii) = ""
  ;f2 = files2->$name$(0,:,:)
  ;plot(ii) = subplot(ii,plotlabs(ii),wgt*f2,levs,cmap)

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/2,1/),resP)
  gsn_panel(wks,plot,(/1,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
