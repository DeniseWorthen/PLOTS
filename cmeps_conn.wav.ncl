; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/FV3_RT/wave_test/"

 plotlabs = (/"CMEPS ", "Connector"/)
      rts = (/"base/", "base.conn/"/)

  files1 = addfile(RT1+rts(0)+"ufs.cpld.cpl.hi.wav.2021-03-22-43200.nc","r")
  files2 = addfile(RT1+rts(1)+"field_WAV_export.nc","r")
  ; to add land
  files3 = addfile(RT1+rts(0)+"kmtu_cice_NEMS_mx100.nc","r")

  ; coupler fields
  cmepsflds = (/"wavImp_Sw_ustokes1",   \
                "wavImp_Sw_ustokes2",   \
                "wavImp_Sw_ustokes3",   \
                "wavImp_Sw_vstokes1",   \
                "wavImp_Sw_vstokes2",   \
                "wavImp_Sw_vstokes3",   \
                "wavImp_Sw_z0"          \
               /)

  ; connector fields
  connflds = (/"eastward_partitioned_stokes_drift_1",   \
               "eastward_partitioned_stokes_drift_2",   \
               "eastward_partitioned_stokes_drift_3",   \
               "northward_partitioned_stokes_drift_1",  \
               "northward_partitioned_stokes_drift_2",  \
               "northward_partitioned_stokes_drift_3",  \
               "wave_z0_roughness_length"               \
               /)

  nflds = dimsizes(cmepsflds)

  ; easier plots
  fldwgts = (/1.e0, \
              1.e0, \
              1.e0, \
              1.e0, \
              1.e0, \
              1.e0, \
              1.e3  \
            /)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.1,    0.1,  0.01/)   ; u1
  plotlevs( 1,:) = (/  -0.1,    0.1,  0.01/)   ; u2
  plotlevs( 2,:) = (/  -0.1,    0.1,  0.01/)   ; u3
  plotlevs( 3,:) = (/  -0.1,    0.1,  0.01/)   ; v1
  plotlevs( 4,:) = (/  -0.1,    0.1,  0.01/)   ; v2
  plotlevs( 5,:) = (/  -0.1,    0.1,  0.01/)   ; v3
  plotlevs( 6,:) = (/   0.0,    1.0,  0.05/)   ; z0

  cmap="BlueWhiteOrangeRed"

  
;************************************************
;
;************************************************

  ; pick a field to plot
  ;fldtoplot = 6
       levs = plotlevs(fldtoplot,:)
        wgt = fldwgts(fldtoplot)
   wkstitle = cmepsflds(fldtoplot)
  plottitle="6-hour "+connflds(fldtoplot)

  if(fldtoplot .eq. 6)then
   cmap = "WhiteBlueGreenYellowRed"
   ;cmap = "MPL_rainbow"
   plottitle="6-hour "+connflds(fldtoplot)+"(*"+sprintf("%5.0e", wgt)+")"
  end if
  fland = files3->kmt

;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
  oplot = new(2,graphic)

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
  res@gsnCenterStringOrthogonalPosF   = 0.15

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

; ***************************************************
;
; ***************************************************

  ii = 0
  name = cmepsflds(fldtoplot)
  f1 = files1->$name$(0,:,:)
  plot(ii) = subplot(ii,plotlabs(ii),wgt*f1,levs,cmap)
  oplot(ii) = gsn_csm_contour(wks,fland,ores)
  overlay(plot(ii),oplot(ii))

  ii = 1
  lstep=31-1
  name = connflds(fldtoplot)
  f2 = files2->$name$(lstep,:,:)
  plot(ii) = subplot(ii,plotlabs(ii),wgt*f2,levs,cmap)
  oplot(ii) = gsn_csm_contour(wks,fland,ores)
  overlay(plot(ii),oplot(ii))

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,1/),resP)

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
