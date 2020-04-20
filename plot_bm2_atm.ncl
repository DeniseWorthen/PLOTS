;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  hemi="NH"
  ;hemi="SH"

  minlat = 66.0

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************

   cdate = "20120715"
   fhour = 252
   rtsrc = RT3+"For_ESRL/BM2/gfs."+cdate+"/00/"

   albf = addfile(rtsrc+"albdo.f"+fhour+".nc","r")
   icef = addfile(rtsrc+"icec.f"+fhour+".nc","r")
  ;print(albf)

  albname = "ALBDO_surface"
     levs = (/0.10,0.70,0.05/)

  icename = "ICEC_surface"
  albvar = albf->$albname$(0,:,:)
  albvar = albvar/100.
  icevar = icef->$icename$(0,:,:)

  albvar = where(icevar .gt. 0.0, albvar, albvar@_FillValue)
  albvar@units=""
  albvar@long_name=""
  ;printVarSummary(albvar)
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
  wks   = gsn_open_wks (wkstype,"cice5")              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette        = "BlWhRe"              ; choose colormap
  ;res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap
  ;res@cnFillPalette        = "NCV_roullet"              ; choose colormap
  res@cnFillPalette        = "WhBlGrYeRe"              ; choose colormap

  ;res@tiMainString = dirname+" "+cdate
  ;res@tiMainString = rtsrc+" "+cdate
  res@tiMainString = rtsrc+" "+"fcst hour "+fhour
  res@tiMainFontHeightF = .01

  ;res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  ;res@gsnStringFontHeightF = 0.01
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

  plot = gsn_csm_contour_map_polar(wks,albvar,res)    ; create the plot
  ;plot = gsn_csm_contour_map_polar(wks,albvar({66.:90},:),res)    ; create the plot

  draw(plot)
  frame(wks)

exit

end
