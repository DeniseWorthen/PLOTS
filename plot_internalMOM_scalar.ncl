;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  minlat = 66.0
  ;minlat = 76.0
  ;minlat = 88.0
  ;minlat = 80.0

  ;minlat =  88.0
  maxlat =  88.0
  minlon =  140.0
  maxlon =  270.0
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch3/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  runtyp="emc"
  ;runtyp="moa"
  ;runtyp="benchv2"

  MOM = runtyp+"_datm/"
  ;rtsrc=RT4+MOM+"tmp/cpld_datm_mom6_cice_5d/"
  ;MOM = "rtgen.135423/"
  ;MOM = runtyp+"_dump_emcrot/"
  ;MOM = runtyp+"_dump_cesmrot/"
  ;rtsrc=RT4+MOM+"tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
  rtsrc=RT4+MOM+"tmp/cpld_datm_mom6_cice_5d/"

;************************************************
;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.
;************************************************

  model = "ocn"
  ;vmag = 0.02
  vmag = 0.15
  ;vmag = 0.50
  ;vthn = 0.008
  vthn = 0.01
 ;  vmag = 0.08
  ; vthn = 0.0
  ;aname = "sea_surface_temperature"
  ;aname = "sea_lev"
  ;aname = "mean_evap_rate"
  aname = "mean_sensi_heat_flx"
  ;aname = "mean_sensi_heat_flx_atm_into_ice"
  ;aname = "ice_fraction"
  ;aname = "inst_pres_height_surface"
  ; these are on A-grid, so no unstagger
  field = "field_ocn_internal_"
  ;field = "field_ocn_export_"
  ;field = "field_med_to_ocn_"
  ;field = "field_med_from_ocn_"
  ;field = "field_med_to_ice_"
  ;field = "field_med_from_ice_"

  lonfile=addfile(rtsrc+"array_med_"+model+"_grid_coord1.nc","r")
  latfile=addfile(rtsrc+"array_med_"+model+"_grid_coord2.nc","r")
  print(latfile)
  print(lonfile)
 
  afile=addfile(rtsrc+field+aname+".nc","r")

  lstep=6-1
  ;avar=afile->$aname$(lstep,:,:)-273.15
  ;avar=afile->$aname$(lstep,:,:)*1.0e4
  avar=afile->$aname$(lstep,:,:)
  ;avar=afile->$aname$(lstep,:,:)*10.0
  avar@lon2d=lonfile->lon_center
  avar@lat2d=latfile->lat_center

  plottitle=rtsrc+"~C~"+field+aname+" lstep = "+lstep

  ;levs = (/0.0,1.0,.1/)
  ;levs = (/-0.1,0.1,.01/)
  ;levs = (/-0.03,0.03,.002/)
  ;levs = (/-0.02,0.02,.001/)
  ;levs = (/-1.72, -1.63, 0.002/)
  ;levs = (/-1.60, -1.20, 0.02/)
  ;levs = (/1010.0,1020.0,0.1/)
  ;levs = (/-1.0,1.0,0.05/)
  levs = (/-50.0,50.0,2.00/)

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
   plot(ii) = gsn_csm_contour_map_polar(wks,avar,res) 
  ; plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

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
