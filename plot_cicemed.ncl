;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  ;hemi="NH"
  ;hemi="SH"
  hemi = "none"


  minlat = 66.0
  ;minlat = 76.0
  ;minlat = 88.0
  ;minlat = 80.0

  ;minlat =  88.0
  maxlat = -50.0
  ;minlon =  140.0
  ;maxlon =  270.0

  ;RT4 = "/glade/scratch/worthen/MStone/"
  RT="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/sfs_restart/"
  rtname = "base/"

;************************************************
; read in netCDF file
;************************************************

  lstep=0
  ifile = addfile(RT+rtname+"ufs.cpld.cpl.hi.ice.1994-05-01-40200.nc","r")

  ;iname = "iceExp_Faxa_snow"
  ;icevar@long_name=iname
  ;icevar@units = "cm/day"
  ;icevar = ifile->$iname$(lstep,:,:)
  ;icevar = icevar*8460

    iname = "iceExp_So_t"
    icevar = ifile->$iname$(lstep,:,:)
    icevar = icevar - 273.15
    icevar@long_name=iname
    icevar@units = "degC"

    ;iname = "iceExp_Fioo_q"
    ;icevar = ifile->$iname$(lstep,:,:)
    ;icevar = icevar/1.0e3
    ;icevar@long_name=iname
    ;icevar@units = "kW/m2"

    icelon="iceExp_lon"
    icelat="iceExp_lat"

    icevar@lon2d=ifile->$icelon$(lstep,:,:)
    icevar@lat2d=ifile->$icelat$(lstep,:,:)
    icevar@_FillValue = 1.0e30

    maskname = "iceImp_Si_imask"
    mvar = ifile->$maskname$(lstep,:,:)
    mvar@lon2d=ifile->$icelon$(lstep,:,:)
    mvar@lat2d=ifile->$icelat$(lstep,:,:)

  ; copy metadata
   pltvar = icevar
   pltvar = where(mvar .gt. 0.0, icevar, icevar@_FillValue)
   printVarSummary(mvar)

  palette="BlueWhiteOrangeRed"
  ;levs = (/0.0, 5.0, .05/)
  levs = (/-2.0, 6.0, 0.2/)
  ;levs = (/-280.0, 0.0, 10.0/)

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice5")              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  if (hemi .ne. "none")then
    res@gsnPolar   =  hemi                         ; specify the hemisphere
    if(hemi .eq. "NH")then
      res@mpMinLatF    =  minlat                          ; minimum lat to plot
      res@mpCenterLonF = -45
    end if
    if(hemi .eq. "SH")then
      res@mpMaxLatF    = -50                            ; minimum lat to plot
      res@mpCenterLonF = 0.0
    end if
  else
    ; near tip Greenland
    res@mpMinLatF            =  55.0      ; range to zoom in on
    res@mpMaxLatF            =  66.0
    res@mpMinLonF            =  -50.0
    res@mpMaxLonF            =  -40.0
    res@mpCenterLonF         =  -45
  end if

  ; Near Yenisei
  ;res@mpMinLatF            =  70      ; range to zoom in on
  ;res@mpMaxLatF            =  80.
  ;res@mpMinLonF            =  60.
  ;res@mpMaxLonF            =  90.

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  ;res@cnFillOn          = False                  ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  ; res@cnLevelSelectionMode        = "ExplicitLevels"
  ; res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
  ; res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette        = "BlWhRe"              ; choose colormap
  ;res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap
  ;res@cnFillPalette        = "NCV_roullet"              ; choose colormap
  ;res@cnFillPalette        = "WhBlGrYeRe"              ; choose colormap

  ;res@tiMainString = dirname+" "+cday
  ;res@tiMainString = rtsrc+" "+cdate+" "+varname
  ;res@tiMainFontHeightF = .01

  ;res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  ;res@gsnStringFontHeightF = 0.01
  ;res@gsnCenterString = cd_string(times(lstep),"%d %F")

  res@gsnStringFontHeightF = 0.01
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

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  ;plot = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot
  ;plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;pum= gsn_add_polymarker(wks,plot,center_xlon,center_xlat,mkres)

  draw(plot)
  frame(wks)

exit

end
