;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  ; hycom-cice
  ;rtsrc  = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"
  ;grdsrc = "cice_data/mx024/"
  ;grdfile = "cice_grid_024.nc"

  ; mom6-cice
  rtsrc = "/home/Denise.Worthen/MOM2CICE_2/"
  grdsrc = ""
  grdfile = "grid_cice_NEMS_mx025.nc"
 
  rad2deg = 180.d0/acos(-1.0d0)

;************************************************
; ice
;************************************************

  ; load the grid file
  gr =addfile(rtsrc+grdsrc+grdfile,"r")

  varname="htn"
  latname="latCv"
  lonname="lonCv"
  levs=(/6400.0, 6600.0, 5.0/)
  minlat=88.0

  ;varname="hte"
  ;latname="latCu"
  ;lonname="lonCu"
  ;levs=(/9200.0, 12200.0, 100.0/)
  ;minlat=82.0

  var = gr->$varname$
  var@lon2d=gr->$lonname$*rad2deg
  var@lat2d=gr->$latname$*rad2deg

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=60.00
  lon2=-120.00
  lat1=60
  lat2=60

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"grid")              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillMode = "MeshFill"
  res@mpFillOn   = True

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF  = minlat                            ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = False                  ; color fill
  res@cnLinesOn         = True                 ; no contour lines
  res@cnLineLabelsOn    = False

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillPalette        = "NCV_jet"              ; choose colormap

  res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  res@gsnStringFontHeightF = 0.02
  ;res@gsnCenterString = cd_string(times(lstep),"%d %F")

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

  plot = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)

end
