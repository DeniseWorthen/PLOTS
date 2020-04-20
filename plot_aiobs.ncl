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
  hemi="NH"
  ;hemi="SH"

   rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchTest/"
   tlatname="plat"
   tlonname="plon"
   rfactor=1
;************************************************
; ice
;************************************************

  lstep=35-1

  ; ice field
  varname="aice"
  levs=(/0.70,1.0,0.005/)

   icef =addfile(rtsrc+"aiobs.nc","r")
  icevar=icef->$varname$(lstep,:,:)
  icevar@lon2d=icef->$tlonname$*rfactor
  icevar@lat2d=icef->$tlatname$*rfactor
  ;printVarSummary(icevar)
  icevar@units=""
  icevar@long_name=""

  ;times= icef->time

; Get the time units and set the first and last times that we want
  ;timeUnits = icef->time@units
  ;timeCalendar = icef->time@calendar

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"kiss")              ; send graphics to X11 window

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
   res@mpMinLatF    =  50                          ; minimum lat to plot
   ;res@mpMinLatF    =  66                          ; minimum lat to plot
  ; res@mpMinLatF    =  88.0                          ; minimum lat to plot
  ; res@mpMinLatF    =  80.0                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
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

  res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette        = "BlWhRe"              ; choose colormap
  ;res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap
  ;res@cnFillPalette        = "NCV_roullet"              ; choose colormap
  ;res@cnFillPalette        = "WhBlGrYeRe"              ; choose colormap

  ;res@tiMainString = dirname+" "+cday
  ;res@tiMainString = compset+"  "+cday+"  "+varname
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
; resources for polymarkers
;************************************************

  mkres               = True
  ;mkres@gsMarkerIndex = 16         ; circle
  mkres@gsMarkerIndex = 15         ; open circle+cross
  ;mkres@gsMarkerIndex = 2         ; cross hair
  mkres@gsMarkerSizeF = 0.020
  mkres@gsMarkerColor = "Red"

;************************************************
;
;************************************************

  plot = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot

  draw(plot)
  frame(wks)

exit

end
