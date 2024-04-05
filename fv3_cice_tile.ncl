; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

  rtsrc = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/sfctemp/"

  ; GIN
  ;minlat =  58.0
  ;maxlat =  84.0
  ;minlon = -30.0
  ;maxlon =  10.0

  minlon =   0.0
  maxlon = 360.0
  minlat =  60.0
  ;minlat =  88.0
  maxlat =  90.0

  ;minlat =  -90.0
  ;maxlat =  -40.0

  rad2deg=180/3.14

;************************************************
;
;************************************************

  dirsrc="base.nsst2/"
  afile=addfile(rtsrc+dirsrc+"tile3.nc","r")
  ;aname="tmpsfc"
  ;aname="tisfc"
  aname="shtfl_ave"
  afname="icec"

  ifile=addfile(rtsrc+dirsrc+"ice.nc","r")
  printVarSummary(ifile)
  ;iname="Tsfc_h"
  iname="fsens_h"
  ifname="aice_h"

  lstep=54-1
  ivar = ifile->$iname$(lstep,:,:)
  ifrac = ifile->$ifname$(lstep,:,:)
  ivar = where(ifrac .gt. 0.90, ivar, ivar@_FillValue)
  ivar = (-1.0)*ivar
  ivar@lon2d = ifile->TLON(:,:)
  ivar@lat2d = ifile->TLAT(:,:)

  ainame = "icec"
  afrac = afile->$afname$(lstep,:,:)
  avar = afile->$aname$(lstep,:,:)
  ;avar = where(afrac .gt. 0.80, avar-273.15, avar@_FillValue)
  avar = where(afrac .gt. 0.90, avar, avar@_FillValue)
  avar@lon2d = afile->grid_xt(:,:)
  avar@lat2d = afile->grid_yt(:,:)
  ;avar@units = "C"

  ;levs = (/-10.00,1.0,0.5/)
  ;levs = (/0.0,300.0,10.0/)
  levs = (/-20.0, 20.0, 1.0/)

  ; Get the time axis
  times= ifile->time
  timeUnits = ifile->time@units
  timeCalendar = ifile->time@calendar
  ;print(times)

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=  60.00
  lon2=-120.00
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"fv3")              ; send graphics to X11 window

  nplots= 2
   plot = new(nplots,graphic)
    dum = new(nplots,graphic)
    pmk = new(nplots,graphic)

  res            = True                          ; plot mods desired
  ;res@mpProjection = "Satellite"

  ;res@mpMinLatF            =  minlat     ; range to zoom in on
  ;res@mpMaxLatF            =  maxlat
  ;res@mpMinLonF            =  minlon
  ;res@mpMaxLonF            =  maxlon
  ;;res@mpCenterLatF         =  (maxlat - minlat)*0.50
  ;res@mpCenterLatF         =  90.0
  ;res@mpCenterLonF         = -45.0
  ;res@mpLimitMode          = "LatLon"
  ;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
  ;res@mpGridAndLimbOn       = True         ; turn on lat/lon lines

  res@gsnPolar     =  "NH"
  res@mpMinLatF    =  minlat                          ; minimum lat to plot
  res@mpCenterLonF = -45

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@tiMainFontHeightF = .01
  res@gsnStringFontHeightF = 0.015

  res@mpFillOn             = False
  res@mpOutlineOn          = True
  res@cnFillMode           = "MeshFill"
  ;res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015
  ;res@cnFillPalette      = "amwg"
  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
; Resources for the polymark
;************************************************

  ;mres@mpGreatCircleLinesOn = True
  ;mres                  = True           ; polyline mods desired
  ;mres@gsMarkerIndex   = 16             ; Use filled dots for markers.
; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainString  = cd_string(times(lstep),"%Y%N%D")
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

  xx = -10.5
  yy = 70.59

  plot(0) = gsn_csm_contour_map(wks,ivar,res)    ; create the plot
  plot(1) = gsn_csm_contour_map(wks,avar,res)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

exit
end
