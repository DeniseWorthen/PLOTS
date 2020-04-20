;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
;************************************************
;
;************************************************
function rot2ew(u,v,ang,mode)
begin
  if(mode .eq. 1)then
   uvrot=u
   ;uvrot=tofloat(cos(ang)*u - sin(ang)*v)
   uvrot=tofloat(cos(ang)*u + sin(ang)*v)
  end if
  if(mode .eq. 2)then
   uvrot=v
   uvrot=tofloat(-sin(ang)*u + cos(ang)*v)
  end if
  return(uvrot)
end
begin
;************************************************
; read in netCDF file
;************************************************

  ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/no_mods_on_lons/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/mods_on_lons/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.69386/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"

;************************************************
;
;************************************************

  ; the mediator should see all fields on center staggers
  ; and in true zonal,meridional direction
  ;model = "ocn"
  model = "ice"
 ;  vmag = 0.25
 ;  vmag = 0.30
 ;  vthn = 0.01
  vmag = 0.08
 ;  vthn = 0.015
   vthn = 0.008
  uname = "ocn_current_zonal"
  vname = "ocn_current_merid"
  ;field = "med_from_ocn_"
  ;field = "med_to_ice"
  field = "ocn_internal_"

  lonfile=addfile(rtsrc+"array_med_"+model+"_grid_coord1.nc","r")
  latfile=addfile(rtsrc+"array_med_"+model+"_grid_coord2.nc","r")
  ; mediator field
  ufile=addfile(rtsrc+"field_"+field+uname+".nc","r")
  vfile=addfile(rtsrc+"field_"+field+vname+".nc","r")
  print(ufile)
  print(vfile)

  lstep=50-1
  uvar=ufile->$uname$(lstep,:,:)
  vvar=vfile->$vname$(lstep,:,:)

  ;uvar=ufile->$uname$(:lstep,:,:)
  ;vvar=vfile->$vname$(:lstep,:,:)
  ;uavg=dim_avg_n_Wrap(uvar,0)
  ;vavg=dim_avg_n_Wrap(vvar,0)
  ;uvar:=uavg
  ;vvar:=vavg

  uvar@lon2d=lonfile->lon_center
  uvar@lat2d=latfile->lat_center
  vvar@lon2d=lonfile->lon_center
  vvar@lat2d=latfile->lat_center

  plottitle=rtsrc+"~C~"+field+uname+"  "+ field+vname
  ;plottitle=field+"  "+uname+", "+vname

;************************************************
;
;************************************************

   ; use ice file for angle
   ;gf =addfile(rtsrc+"history/iceh_ic.2016-10-03-00000.nc","r")
   ; in radians
   ;rotang = gf->ANGLET(:,:)
   ;printVarSummary(rotang)

   ;urot = rot2ew(uvar,vvar,rotang,1)
   ;vrot = rot2ew(uvar,vvar,rotang,2)

   ;uvar = urot
   ;vvar = vrot

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

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  ;res@mpMinLatF    =  66                          ; minimum lat to plot
  ;res@mpMinLatF    =  88                          ; minimum lat to plot
  res@mpMinLatF    =  86                          ; minimum lat to plot
  ;res@mpMinLatF    =  70                          ; minimum lat to plot
  res@mpCenterLonF = -45

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcRefLengthF          = 0.5*vmag          ; size of ref vector
  ;res@vcRefLengthF          =  0.05        ; size of ref vector
  ;res@vcGlyphStyle          = "CurlyVector"

  res@tiMainString = plottitle
  res@tiMainFontHeightF = .010

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

   plot(ii) = gsn_csm_vector_map_polar(wks,uvar,vvar,res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)
exit
end
