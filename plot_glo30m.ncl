;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

  RT = "/glade/scratch/worthen/WW3_input_data_20211113/createmoddefs/"
  fname = RT+"glo30m.nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  wmaskname="MASK30M"
  depthname="DEPTH30M"

  wmask=ff->$wmaskname$
  wbath=ff->$depthname$
  wbath = -1.0*wbath/1.0e3

    hemi = "NH"
    minlat =  66.0
    midlon = -45.0

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
  res@mpOutlineOn          = True

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                    ; minimum lat to plot
    res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat
   res@mpCenterLonF = 0.0
  end if

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  ; res@cnFillPalette        = "BlueWhiteOrangeRed"
   res@cnFillPalette        = "MPL_rainbow"
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources


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
  ;resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")+"@ "+csec+" secs "

; **************************************************
;
; **************************************************

  ii = 0
  pltlevs = (/0.,2,1/)
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours

  plot(ii) = gsn_csm_contour_map_polar(wks,wmask,res)    ; create the plot

  ;ii = 1
  ;ii = 0
  ;pltlevs = (/0.,5000,250/)
  ;res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
  ;res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
  ;res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours

  ;plot(ii) = gsn_csm_contour_map_polar(wks,wbath,res)    ; create the plot

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/1,2/),resP)
  ;gsn_panel(wks,plot,(/2,1/),resP)
  gsn_panel(wks,plot,(/1,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
