;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT="/gpfs/f6/drsa-hurr1/proj-shared/Denise.Worthen/sfs.restart/"
  rtname = "base/"

  ;hemi = "NH"
  hemi = "SH"
  ;hemi = "none"

 ;rad2deg=180.d0/acos(-1.0d0)
 ; icemin = 1.0e-6
 ;const_lhvap = 2.501e6

;************************************************
;  Atm lats/lons and mask
;************************************************
  tile=6

  gf = addfile("./C192.mx025.orodata.nc","r")
  lonname="geolon"
  latname="geolat"
  atmlons = gf->$lonname$(tile-1,:,:)
  atmlats = gf->$latname$(tile-1,:,:)
  aland = where(gf->land_frac(tile-1,:,:) .ge. 1.0, 0.0, 1.0)   ; alnd = 1 on ocean
  atmlons@units = "degrees_E"
  atmlats@units = "degrees_N"
    aland@lon2d = atmlons
    aland@lat2d = atmlats

;************************************************
;
;************************************************

    lstep=0

    hemi="SH"

    afile = addfile(RT+rtname+"ufs.cpld.cpl.hi.atm.1994-05-01-40200.nc","r")
    ;print(afile)

    aname = "atmImp_Faxa_snow"
    tmp = afile->$aname$(0,tile-1,:,:)
    ;avar = where(aland .ge. 1.0, tmp, default_fillvalue(typeof(tmp)))
    avar=8640*tmp
    avar@units="cm/day"
    avar@long_name=aname
    avar@lon2d = atmlons
    avar@lat2d = atmlats

    palette="BlueWhiteOrangeRed"
    levs = (/0.0, 5.0, .05/)

;************************************************
; define the map
;************************************************

    wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"test")              ; send graphics to X11 window

  plot = new(1,graphic)
 oplot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpOutlineOn   = False

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  ;res@lbBoxLinesOn      = False                   ; Turn off labelbar box lines

  res@gsnStringFontHeightF = 0.01

  if(hemi .eq. "NH" .or. hemi .eq. "SH")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  66.0                          ; minimum lat to plot
    res@mpCenterLonF = -45
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = -50                            ; minimum lat to plot
    res@mpCenterLonF = 0.0
   end if
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         =  midlon
  end if

  res@cnLinesOn         = False                 ; no contour lines
  res@cnFillOn          = True                 ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  plot = gsn_csm_contour_map_polar(wks,avar(:,:),res)    ; create the plot

  draw(plot)
  frame(wks)

exit
end
