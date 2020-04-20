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

  rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_meddump/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"

;************************************************
;
;************************************************

  ;model = "ice"
  model = "ocn"

  lonfile=addfile(rtsrc+"array_med_"+model+"_grid_coord1.nc","r")
  latfile=addfile(rtsrc+"array_med_"+model+"_grid_coord2.nc","r")

  lonname="lon_center"
  latname="lat_center"

  lons=lonfile->$lonname$(:,:)
  lats=latfile->$latname$(:,:)

  lons@lon2d=lonfile->$lonname$
  lons@lat2d=latfile->$latname$

  lats@lon2d=lonfile->$lonname$
  lats@lat2d=latfile->$latname$

  mvar=lons
  levs=(/0.0, 360.0, 10.0/)
  ;levs=(/-180.0, 180.0, 10.0/)
  ;mvar=lats
  ;levs=(/60.0, 90.0, 2.0/)

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
  wks   = gsn_open_wks (wkstype,"polar")              ; send graphics to X11 window

  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@gsnPolar   = "NH"                  ; specify the hemisphere
  res@mpFillOn   = True
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF    =  66                          ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

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

  ii = 0
  plot(ii) = gsn_csm_contour_map_polar(wks,mvar,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)

end
