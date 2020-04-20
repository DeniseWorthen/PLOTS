; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

 ; C96 supergrid
 grdsrc = "/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/NEMSfv3gfs/trunk-20180912/FV3_input_data/INPUT/"
  grres = "C96"
 ; C384 supergrid
 ;grdsrc = "/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/NEMSfv3gfs/trunk-20180912/FV3_input_data_c384/INPUT/"
 ; grres = "C384"

  minlat =  75.0
  ;minlat =  88.0
  maxlat =  90.0

;************************************************
;
;************************************************

   tile = "tile3"
     gf = addfile(grdsrc+grres+"_grid."+tile+".nc","r")

  ;angname="angle_dx"
  angname="angle_dy"
  ang = gf->$angname$
  ang@lon2d = gf->x
  ang@lat2d = gf->y
  ang = where(ang .lt. 0.0, ang+360.0, ang)

  ;levs = (/-0.12,0.12,0.01/)
  ;levs = (/120.0,300.0,10.0/)
  ;levs = (/0.0,360.0,5.0/)
  ;levs = (/-180.0,180.0,2.0/)
  ;levs = (/-30.0,150.0,2.0/)
  levs = (/176.0,184.0,0.5/)
  ;levs = (/90.0,180.0,1.0/)
  ;levs = (/-180.0,0.0,2.0/)
  ;levs = (/-90.0,90.0,1.0/)

  ;plottitle=rtsrc+model+tile+".nc  "+aname

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

  nplots= 1
   plot = new(nplots,graphic)
    dum = new(nplots,graphic)

  res            = True                          ; plot mods desired
  res@mpProjection = "Satellite"

  res@mpMinLatF            =  minlat     ; range to zoom in on
  res@mpMaxLatF            =  maxlat
  res@mpMinLonF            =  0.
  res@mpMaxLonF            =  360.
  res@mpCenterLatF         =  90.0
  res@mpCenterLonF         = -45.0
  res@mpLimitMode          = "LatLon"
  ;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
  res@mpGridAndLimbOn       = True         ; turn on lat/lon lines

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@tiMainFontHeightF = .01
  res@gsnStringFontHeightF = 0.015

  res@mpFillOn             = False
  res@mpOutlineOn          = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
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
  ;res@cnFillPalette      = "radar"
  res@cnFillPalette      = "NCV_banded"

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  ;resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

  ii=0
  plot(ii) = gsn_csm_contour_map(wks,ang,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************


  gsn_panel(wks,plot,(/1,1/),resP)

  frame(wks)

exit
end
