;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
  minlat = 70.0
 ; minlat = 75.0
 ; minlat = 80.0
 ;minlat = 88.0

  ;vmag = 0.1
  vmag = 20.00
  vthn = 0.012
  ;vthn = 0.0
  ;minlat = 86.0
  ;vmag = 0.50
  ;vthn = 0.008
  ;vthn = 0.012

  ;minlat =  88.0
  ;maxlat =  90.0
  ;minlat =  -40.0
  ;maxlat =  -38.0
  ;minlon =  58.0
  ;maxlon =  62.0

  model = "ice"
  ;model = "ocn"
  ;model = "atmocn"

;************************************************
; read in netCDF file
;************************************************

  rt1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  rt2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  rt3 = "/scratch3/NCEPDEV/stmp3/Denise.Worthen/"
  rt4 = "/scratch3/NCEPDEV/stmp4/Denise.Worthen/"

  ;rtsrc=rt2+"rtgen.88603/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  rtsrc=rt2+"rtgen.69386/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"

;************************************************
;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.
;************************************************

  if(model .eq. "ice")then
     model = "ice"
  ;varnames = (/"inst_pres_height_lowest", "inst_zonal_wind_height_lowest", "inst_merid_wind_height_lowest"/)
  ;varnames = (/"inst_pres_height_surface", "ocn_current_zonal", "ocn_current_merid"/)
  ;varnames = (/"ice_fraction", "stress_on_air_ice_zonal", "stress_on_air_ice_merid"/)
  ;varnames = (/"inst_pres_height_surface", "stress_on_ocn_ice_zonal", "stress_on_ocn_ice_merid"/)
  ;varnames = (/"inst_pres_height_surface", "sea_surface_slope_zonal", "sea_surface_slope_merid"/)
  varnames = (/"ice_fraction", "inst_zonal_wind_height_lowest", "inst_merid_wind_height_lowest"/)
  coordname = (/"center", "corner", "corner"/)
   rotfile = addfile("/scratch3/NCEPDEV/marine/noscrub/Denise.Worthen/EMC_CICE/tools/grid/grid_cice_NEMS_mx025.nc","r")
     angle = rotfile->angle
    sinrot = sin(angle)
    cosrot = cos(angle)
  end if

  if(model .eq. "ocn")then
  varnames = (/"sea_lev", "sea_surface_slope_zonal", "sea_surface_slope_merid"/)
  coordname = (/"center", "center", "center"/)
  ;varnames = (/"sea_surface_temperature", "mean_zonal_moment_flx", "mean_merid_moment_flx"/)
  ;varnames = (/"sea_surface_temperature", "ocn_current_zonal", "ocn_current_merid"/)
   rotfile = addfile(rtsrc+"ocn_2016_10_03_03.nc","r")
    sinrot = rotfile->sinrot
    cosrot = rotfile->cosrot
  end if

  if(model .eq. "atmocn")then
  varnames = (/"temperature_2m", "stress_on_air_ocn_zonal", "stress_on_air_ocn_merid"/)
  end if

      nvars = dimsizes(varnames)
  ; array contour levels for variables
    varlevs = new((/nvars,3/),float)
    ;varlevs(0,:) = (/ (/    -2.0,   0.0,  0.02/) /)
    ;varlevs(0,:) = (/ (/    -0.5,   -0.3,  0.005/) /)
    ;varlevs(0,:) = (/ (/  -1.00,    1.00,  0.1/) /)
   ;varlevs(0,:) = (/ (/    -0.5,   0.5,  0.02/) /)
   ;varlevs(0,:) = (/ (/    -0.2,   0.2,  0.02/) /)
    ;varlevs(0,:) = (/ (/    -1.64,   -1.54,  0.002/) /)
    ;varlevs(0,:) = (/ (/    -1.56,   -1.46,  0.002/) /)
    ;varlevs(0,:) = (/ (/    -1.72,   -1.63,  0.002/) /)
   ; varlevs(0,:) = (/ (/   1012.0,   1016.0,  0.050/) /)
    ;varlevs(1,:) = (/ (/  -1.00,    1.00,  0.050/) /)
    ;varlevs(2,:) = (/ (/  -1.00,    1.00,  0.050/) /)
    ;varlevs(1,:) = (/ (/  -0.05,    0.05,  0.005/) /)
    ;varlevs(2,:) = (/ (/  -0.05,    0.05,  0.005/) /)
    ;varlevs(1,:) = (/ (/  -1.00,    1.00,  0.1/) /)
    ;varlevs(2,:) = (/ (/  -1.00,    1.00,  0.1/) /)
    varlevs(0,:) = (/ (/    0.0,   1.0,  0.1/) /)

    ;varlevs(0,:) = (/ (/   0.86,   0.98,  0.002/) /)
    varlevs(1,:) = (/ (/  -0.05,    0.05,  0.005/) /)
    varlevs(2,:) = (/ (/  -0.05,    0.05,  0.005/) /)
    ;varlevs(1,:) = (/ (/  -0.10,    0.10,  0.010/) /)
    ;varlevs(2,:) = (/ (/  -0.10,    0.10,  0.010/) /)
    ;varlevs(1,:) = (/ (/  -0.20,    0.20,  0.020/) /)
    ;varlevs(2,:) = (/ (/  -0.20,    0.20,  0.020/) /)
    ;varlevs(1,:) = (/ (/  -0.020,    0.020,  0.0020/) /)
    ;varlevs(2,:) = (/ (/  -0.020,    0.020,  0.0020/) /)

  ; these are on A-grid, so no unstagger
  ;field = "field_"+model+"_export_"
  ;field = "field_"+model+"_import_"
  ; some of the internal ice fields are on U grid
  field = "field_"+model+"_internal_"
  ;field = "field_med_to_"+model+"_"
  ;field = "field_med_from_"+model+"_"
  ;field = "fields_med_"+model

  aname = varnames(0)
  uname = varnames(1)
  vname = varnames(2)

  if(model .eq. "atmocn")then
   lonfile=addfile(rtsrc+"array_med_ocn_grid_coord1.nc","r")
   latfile=addfile(rtsrc+"array_med_ocn_grid_coord2.nc","r")
    afile=addfile(rtsrc+"fields_med_atmocn.nc","r")
    ufile=addfile(rtsrc+"fields_med_atmocn.nc","r")
    vfile=addfile(rtsrc+"fields_med_atmocn.nc","r")
  else
   centerlonfile=addfile(rtsrc+"array_med_"+model+"_grid_coord1.nc","r")
   centerlatfile=addfile(rtsrc+"array_med_"+model+"_grid_coord2.nc","r")
   cornerlonfile=addfile(rtsrc+"array_med_"+model+"_grid_corner1.nc","r")
   cornerlatfile=addfile(rtsrc+"array_med_"+model+"_grid_corner2.nc","r")
  ;print(latfile)
  ;print(lonfile) 
    afile=addfile(rtsrc+field+aname+".nc","r")
    ufile=addfile(rtsrc+field+uname+".nc","r")
    vfile=addfile(rtsrc+field+vname+".nc","r")
  ;print(afile)
  ;print(ufile)
  ;print(vfile)
  end if

  lstep=20-1
  ;avar=afile->$aname$(lstep,:,:)
  ;avar=afile->$aname$(lstep,:,:)-273.15
  ;avar=afile->$aname$(lstep,:,:)/1.0e2
  ;uvar=ufile->$uname$(lstep,:,:)
  ;vvar=vfile->$vname$(lstep,:,:)
  ;uvar=ufile->$uname$(lstep,:,:)*10.
  ;vvar=vfile->$vname$(lstep,:,:)*10.
  ;uvar=ufile->$uname$(lstep,:,:)*1.0e5
  ;vvar=vfile->$vname$(lstep,:,:)*1.0e5

  avar=dim_avg_n_Wrap(afile->$aname$(:,:,:),0)
  uvar=dim_avg_n_Wrap(ufile->$uname$(:,:,:),0)
  vvar=dim_avg_n_Wrap(vfile->$vname$(:,:,:),0)
  ; final ~6hr average
  ;lstep=192-1
  ;avar=afile->$aname$(lstep-11:lstep,:,:)
  ;avar=afile->$aname$(lstep-11:lstep,:,:)-273.15
  ;avar=afile->$aname$(lstep-11:lstep,:,:)/1.0e2
  ;uvar=ufile->$uname$(lstep-11:lstep,:,:)*10.0
  ;vvar=vfile->$vname$(lstep-11:lstep,:,:)*10.0
  ;aavg=dim_avg_n_Wrap(avar,0)
  ;uavg=dim_avg_n_Wrap(uvar,0)
  ;vavg=dim_avg_n_Wrap(vvar,0)
  ;avar :=aavg
  ;uvar :=uavg
  ;vvar :=vavg
   avar@lon2d=centerlonfile->lon_center
   avar@lat2d=centerlatfile->lat_center
  if(coordname(1) .eq. "center" .and. coordname(2) .eq. "center")then
   uvar@lon2d=centerlonfile->lon_center
   uvar@lat2d=centerlatfile->lat_center
   vvar@lon2d=centerlonfile->lon_center
   vvar@lat2d=centerlatfile->lat_center
  else
   uvar@lon2d=cornerlonfile->lon_corner(1:,:)
   uvar@lat2d=cornerlatfile->lat_corner(1:,:)
   vvar@lon2d=cornerlonfile->lon_corner(1:,:)
   vvar@lat2d=cornerlatfile->lat_corner(1:,:)
  end if

  uvar@_FillValue = -1.0e-20
  vvar@_FillValue = -1.0e-20
  uvar = where(uvar@lat2d .ge. minlat, uvar, uvar@_FillValue)
  vvar = where(vvar@lat2d .ge. minlat, vvar, vvar@_FillValue)

  ;plottitle=rtsrc+"~C~"+field+uname+"  "+ field+vname+" lstep = "+lstep
  lstep1=lstep+1
  plottitle=rtsrc+"  "+field+" lstep = "+lstep1
  ;plottitle=field+"  "+uname+", "+vname

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
     size=1200 ; imac
     ;size= 800 ; mpb
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=size
  wkstype@wkHeight=size
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

;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.

  res@vcRefMagnitudeF       = vmag              ; vector magnitude
  res@vcRefLengthF          = 0.10          ; size of ref vector in NDC units
  ;res@vcMinFracLengthF      = 1.0
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcGlyphStyle          = "CurlyVector"
  ;res@vcPositionMode = "ArrowTail"

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
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs)
begin

   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours

   res@gsnLeftString = name

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   return(splot)
end
;************************************************
;
;************************************************

  levs = (/0.0, 0.0, 0.0/)

 ;      ii = 0
 ;    vnum = 0
 ; levs(:) = varlevs(vnum,:)
 ;   vname = varnames(vnum)
 ; plot(ii) = subplot(ii,vname,avar,levs)
 ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

 ;      ii = 0
 ;    vnum = 1
 ; levs(:) = varlevs(vnum,:)
 ;   vname = varnames(vnum)
 ; plot(ii) = subplot(ii,vname,urot,levs)
 ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

       ii = 1
     vnum = 2
  levs(:) = varlevs(vnum,:)
    vname = varnames(vnum)
  plot(ii) = subplot(ii,vname,vrot,levs)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

 ;      ii = 2
       ii = 0
     vnum = 0
    vname = varnames(vnum)
  levs(:) = varlevs(vnum,:)
   res@gsnLeftString = vname
   ;res@cnFillPalette        = "BlWhRe"  
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = levs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = levs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = levs(2)            ; set the interval between contours
 plot(ii) = gsn_csm_vector_scalar_map_polar(wks,urot,vrot,avar,res)    ; create the plot
 ;plot(ii) = subplot(ii,vname,avar,levs)
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
  ;gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

exit
end
