;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
 ; minlat = 70.0
 ; minlat = 75.0
 ; minlat = 80.0
  minlat = 88.0

  ;vmag = 0.10
  ;vthn = 0.008
  ;vthn = 0.0
  ;minlat = 86.0
  vmag = 0.50
  vthn = 0.008
  ;vthn = 0.012

  ;minlat =  88.0
  ;maxlat =  90.0
  ;minlat =  -40.0
  ;maxlat =  -38.0
  ;minlon =  58.0
  ;maxlon =  62.0
;************************************************
; read in netCDF file
;************************************************

  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_symm_4ddump/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_4ddump/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/frzmlt_allflddump/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.66448/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.5997/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_4ddump_noicestress/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_dumpice_internal/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"

;************************************************
;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.
;************************************************

 ; model = "ocn"
  model = "ice"
 ; aname = "sea_surface_temperature"
  ;aname = "stress_on_ocn_ice_zonal"
  ;uname = "stress_on_ocn_ice_zonal"
  ;vname = "stress_on_ocn_ice_merid"
  aname = "stress_on_air_ice_zonal"
  uname = "stress_on_air_ice_zonal"
  vname = "stress_on_air_ice_merid"

  ;uname = "ocn_current_zonal"
  ;vname = "ocn_current_merid"
  ;aname = "inst_pres_height_surface"
  ;aname = "inst_pres_height_lowest"
  ;aname = "mean_net_lw_flx"
  ;uname = "mean_zonal_moment_flx"
  ;vname = "mean_merid_moment_flx"
  ; these are on A-grid, so no unstagger
  field = "field_"+model+"_internal_"
  ;field = "field_med_to_"+model+"_"
  ;field = "field_med_from_"+model+"_"

  lonfile=addfile(rtsrc+"array_med_"+model+"_grid_coord1.nc","r")
  latfile=addfile(rtsrc+"array_med_"+model+"_grid_coord2.nc","r")
  ;print(latfile)
  ;print(lonfile) 
  afile=addfile(rtsrc+field+aname+".nc","r")
  ufile=addfile(rtsrc+field+uname+".nc","r")
  vfile=addfile(rtsrc+field+vname+".nc","r")
  ;print(ufile)
  ;print(vfile)
  ; an ocn output file for cosrot,sinrot info
  ;rotfile=addfile(rtsrc+"ocn_2016_10_03_03.nc","r")
  ;sinrot=rotfile->sinrot
  ;cosrot=rotfile->cosrot
  rotfile=addfile("/scratch3/NCEPDEV/marine/noscrub/Denise.Worthen/EMC_CICE/tools/grid_cice_NEMS_mx025.nc","r")
  angle=rotfile->anglet
  sinrot = sin(angle)
  cosrot = cos(angle)

  lstep=192-1
  ;avar=afile->$aname$(lstep,:,:)-273.15
  avar=afile->$aname$(lstep,:,:)
  ;avar=afile->$aname$(lstep,:,:)/1.0e2
  ;avar=afile->$aname$(lstep,:,:)
  uvar=ufile->$uname$(lstep,:,:)
  vvar=vfile->$vname$(lstep,:,:)
  ; final ~6hr average
  ;lstep=192-1
  ;avar=afile->$aname$(lstep-11:lstep,:,:)-273.15
  ;avar=afile->$aname$(lstep-11:lstep,:,:)/1.0e2
  ;uvar=ufile->$uname$(lstep-11:lstep,:,:)
  ;vvar=vfile->$vname$(lstep-11:lstep,:,:)
  ;aavg=dim_avg_n_Wrap(avar,0)
  ;uavg=dim_avg_n_Wrap(uvar,0)
  ;vavg=dim_avg_n_Wrap(vvar,0)
  ;avar :=aavg
  ;uvar :=uavg
  ;vvar :=vavg
  avar@lon2d=lonfile->lon_center
  avar@lat2d=latfile->lat_center
  uvar@lon2d=lonfile->lon_center
  uvar@lat2d=latfile->lat_center
  vvar@lon2d=lonfile->lon_center
  vvar@lat2d=latfile->lat_center

  uvar@_FillValue = -1.0e-20
  vvar@_FillValue = -1.0e-20
  uvar = where(uvar@lat2d .ge. minlat, uvar, uvar@_FillValue)
  vvar = where(vvar@lat2d .ge. minlat, vvar, vvar@_FillValue)

  ;plottitle=rtsrc+"~C~"+field+uname+"  "+ field+vname+" lstep = "+lstep
  plottitle=rtsrc+"  "+field+" lstep = "+lstep
  ;plottitle=field+"  "+uname+", "+vname

  ;levs = (/-3.0,3.0,.10/)
  ;levs = (/-0.1,0.1,.01/)
  ;levs = (/-0.14,-0.04,.0005/)
  levs = (/-1.72, -1.63, 0.002/)
  ;levs = (/-1.60, -1.20, 0.02/)
  ;levs = (/-1.20, -0.20, 0.02/)
  ;levs = (/1012.0,1016.0,0.05/)
  ;levs = (/1005.0,1035.0,1.00/)

;************************************************
;
;************************************************

  ;these are rotated in cap, so don't rotate!
   urot = uvar
   vrot = vvar
  if(model .eq. "ice")then
   ; cice dump internal is unrotated, native model farray
   urot = uvar*cosrot - vvar*sinrot
   vrot = vvar*cosrot + uvar*sinrot
  end if
   ; as in cap, SIS2 code
   ;urot = uvar*cosrot + vvar*sinrot
   ;vrot = vvar*cosrot - uvar*sinrot

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

  plot = new(3,graphic)
   dum = new(3,graphic)

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
   ;;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
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

  ;res@cnFillPalette   =  "WhBlReWh"                      ; choose colormap

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

  res@gsnLeftStringFontHeightF = 0.020
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
  ; res@gsnLeftString = aname
  ; plot(ii) = gsn_csm_vector_map_polar(wks,urot,vrot,res)    ; create the plot
  ; plot(ii) = gsn_csm_vector_scalar_map_polar(wks,urot,vrot,avar,res)    ; create the plot
   ;plot(ii) = gsn_csm_vector_scalar_map(wks,urot,vrot,avar,res)    ; create the plot
  ; plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ;levs = (/-0.1,0.1,0.01/)
  ;levs = (/-0.02,0.02,0.002/)
  levs = (/-0.01,0.01,0.001/)
  ;levs = (/-0.05,0.05,0.005/)
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ii = 0
   res@gsnLeftString =uname
   plot(ii) = gsn_csm_contour_map_polar(wks,urot,res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii = 1
   res@gsnLeftString = vname
   plot(ii) = gsn_csm_contour_map_polar(wks,vrot,res)    ; create the plot
  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  ;gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot
  ;gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

exit
end
