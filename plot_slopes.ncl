;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  ;minlat = 66.0
  ;minlat = 76.0
  minlat = 88.0
  ;minlat = 80.0

  ;minlat =  88.0
  maxlat =  88.0
  minlon =  140.0
  maxlon =  270.0
;************************************************
; read in netCDF file
;************************************************

  RT4 = "/glade/scratch/worthen/"

  runtyp="cice6_cold2"

  rtsrc=RT4+"ciceTests/"+runtyp+"/"

;************************************************
;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.
;************************************************

  lstep=1-1
  fcpl = addfile(rtsrc+"ufs.s2s.cpl.hi.2012-01-01-01800.nc","r")
  vmag = 0.15
  vthn = 0.01
  uname = "iceExp_So_dhdx"
  vname = "iceExp_So_dhdy"

  uvar=fcpl->$uname$(lstep,:,:)*1.0e5
  vvar=fcpl->$vname$(lstep,:,:)*1.0e5
  uvar@lon2d=fcpl->ocnimp_lon
  uvar@lat2d=fcpl->ocnimp_lat
  vvar@lon2d=fcpl->ocnimp_lon
  vvar@lat2d=fcpl->ocnimp_lat

  uvar@_FillValue = -1.0e-20
  vvar@_FillValue = -1.0e-20
  uvar = where(uvar@lat2d .ge. minlat, uvar, uvar@_FillValue)
  vvar = where(vvar@lat2d .ge. minlat, vvar, vvar@_FillValue)

  plottitle="test"

  levs = (/30.0,32.0,0.1/)

;************************************************
;
;************************************************

  ;these are rotated in cap, so don't rotate!
   urot = uvar
   vrot = vvar

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
  wks   = gsn_open_wks (wkstype,runtyp)              ; send graphics to X11 window

  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@mpFillOn   = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@gsnScalarContour   = True              ; vectors over scalars
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF    =  minlat                          ; minimum lat to plot
  res@mpCenterLonF = -45

   ;res@mpProjection = "Stereographic"
   ;res@mpLimitMode  = "LatLon"
   ;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
   ;res@mpGridAndLimbOn       = True         ; turn on lat/lon lines

   ;res@mpMinLatF            =  minlat      ; range to zoom in on
   ;res@mpMaxLatF            =  maxlat
   ;res@mpMinLonF            =  minlon
   ;res@mpMaxLonF            =  maxlon
   ;res@mpCenterLonF = 60
   ;res@mpCenterLatF = 88

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.

  res@vcRefMagnitudeF       = vmag              ; vector magnitude
  res@vcRefLengthF          = 0.10          ; size of ref vector in NDC units
  ;res@vcMinFracLengthF      = 1.0
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  ;res@vcGlyphStyle          = "CurlyVector"
  res@vcPositionMode = "ArrowTail"

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
;
;************************************************

  ;ii = 0
  ; plot(ii) = gsn_csm_contour_map_polar(wks,urot,res)    ; create the plot
  ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;ii = 1
  ; plot(ii) = gsn_csm_contour_map_polar(wks,vrot,res)    ; create the plot
  ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii = 0
  plot(ii) = gsn_csm_vector_map_polar(wks,urot,vrot,res)    ; create the plot
   ;plot(ii) = gsn_csm_vector_scalar_map_polar(wks,urot,vrot,avar,res)    ; create the plot
   ;plot(ii) = gsn_csm_vector_scalar_map(wks,urot,vrot,avar,res)    ; create the plot
  ;plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  ; dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

exit
end
