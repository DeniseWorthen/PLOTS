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

  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_2d_july/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
  ;ocnfile="MOM6_OUTPUT/ocean_geometry.nc"
  rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/CplFrq/slowfast1_2d_2013070100/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
  ocnfile="ocn_2013_07_01_03.nc"

  ;rtsrc = "$WORK/EMC_CICE/tools/"
  ;ocnfile="grid_cice_NEMS_mx025.nc"

  rad2deg = 180.d0/acos(-1.d0)

;************************************************
;
;************************************************

  ocnsrc=addfile(rtsrc+ocnfile,"r")
  sinrot=ocnsrc->sinrot
  cosrot=ocnsrc->cosrot

  ;varname = "ulon"
  ;lonname = "ulon"
  ;latname = "ulat"

  ;varname = "geolonb"
  ;lonname = "geolonb"
  ;latname = "geolatb"

  ;varname = "geolon_v"
  ;lonname = "geolon_v"
  ;latname = "geolat_v"

  varname = "sinrot"
  lonname = "geolon"
  latname = "geolat"

  ;varname = "SSH"
  ;lonname = "geolon"
  ;latname = "geolat"

  lstep=1-1
  ;tvar=ocnsrc->$varname$(lstep,:,:)
  tvar=ocnsrc->$varname$(:,:)
  tvar = asin(tvar)
  tvar@lon2d=ocnsrc->$lonname$
  tvar@lat2d=ocnsrc->$latname$
  ;tvar=ocnsrc->$varname$(:,:)*rad2deg
  ;tvar@lon2d=ocnsrc->$lonname$*rad2deg
  ;tvar@lat2d=ocnsrc->$latname$*rad2deg

  plottitle=rtsrc+ocnfile+"  "+varname

  ;levs = (/-300.0,60.0,10.0/)
  ;levs = (/87.0,90.0,0.10/)
  ;levs = (/-1.68,-1.58,0.005/)
  ;levs = (/-0.5,0.5,.05/)
  levs = (/-1.6,1.6,.1/)

  tvar@long_name=" "
  tvar@units=" "
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

  res@mpFillOn   = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  ;res@mpMinLatF    =  66                          ; minimum lat to plot
  ;res@mpMinLatF    =  75                          ; minimum lat to plot
  res@mpMinLatF    =  88                         ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillPalette   =  "WhBlReWh"                      ; choose colormap
  ;res@cnFillPalette = "BlueWhiteOrangeRed"
  ;res@cnFillPalette = "amwg"
  ;res@cnFillPalette = "t2m_29lev"

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 4.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
;
;************************************************

  ii = 0
   plot(ii) = gsn_csm_contour_map_polar(wks,tvar,res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

  ;gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

end
