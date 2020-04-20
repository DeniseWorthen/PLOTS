;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

  ;minlat = 66.0
  minlat = 76.0
  ;minlat = 88.0
  ;minlat = 80.0

  ;minlat =  88.0
  ;maxlat =  90.0
  ;minlon =  40.0
  ;maxlon =  80.0
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch3/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  ;runtyp="emc"
  runtyp="moa"

  MOM = runtyp+"_1d/"
  rtsrc=RT4+MOM+"tmp/cpld_datm_mom6_cice_5d/"

;************************************************

  ; the mediator should see all fields on center staggers
  ; and in true zonal,meridional direction
  ;model = "atm"
  model = "ocn"
  ; vmag = 0.30
   vmag = 0.05
   vthn = 0.015
  uname = "mean_zonal_moment_flx"
  vname = "mean_merid_moment_flx"
  ; mediator fields are E-W
  ; these are rotated in cap, so don't rotate!
  ;rotate = "no"
  ; field = "med_from_atm_"
  ; field = "med_to_ocn_"
  ; internal ocean fields need rotating to plot correctly
  rotate = "yes"
   field = "ocn_internal_"

  lonfile=addfile(rtsrc+"array_med_"+model+"_grid_coord1.nc","r")
  latfile=addfile(rtsrc+"array_med_"+model+"_grid_coord2.nc","r")
  ; mediator field
  ufile=addfile(rtsrc+"field_"+field+uname+".nc","r")
  vfile=addfile(rtsrc+"field_"+field+vname+".nc","r")
  ;print(ufile)
  ;print(vfile)
  ; an ocn output file for cosrot,sinrot info
  rotfile=addfile(rtsrc+"ocn_2013_07_01_03.nc","r")
  sinrot=rotfile->sin_rot
  cosrot=rotfile->cos_rot

  lstep=12-1
  uvar=ufile->$uname$(lstep,:,:)
  vvar=vfile->$vname$(lstep,:,:)

  uvar@lon2d=lonfile->lon_center
  uvar@lat2d=latfile->lat_center
  vvar@lon2d=lonfile->lon_center
  vvar@lat2d=latfile->lat_center

  plottitle=rtsrc+"~C~"+field+uname+"  "+ field+vname
  ;plottitle=field+"  "+uname+", "+vname

  uvar@_FillValue = -1.0e-20
  vvar@_FillValue = -1.0e-20
  uvar = where(uvar@lat2d .ge. minlat, uvar, uvar@_FillValue)
  vvar = where(vvar@lat2d .ge. minlat, vvar, vvar@_FillValue)

;************************************************
;
;************************************************

   urot = uvar
   vrot = vvar
  if(rotate .eq. "yes")then
   ; as in cap, rotate from MOM's tripole back to E-W
   ; this is how the cap treats the export variables
   urot = uvar*cosrot + vvar*sinrot
   vrot = vvar*cosrot - uvar*sinrot
  end if
   ; as in cap, original code
   ;urot = uvar*cosrot - vvar*sinrot
   ;vrot = vvar*cosrot + uvar*sinrot

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

  res@gsnPolar   = "NH"                  ; specify the hemisphere
  res@mpFillOn   = True

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF    =  minlat                          ; minimum lat to plot
  res@mpCenterLonF = -45

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

  ii = 0
   plot(ii) = gsn_csm_vector_map_polar(wks,urot,vrot,res)    ; create the plot
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
