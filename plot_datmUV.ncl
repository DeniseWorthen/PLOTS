; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;************************************************
;
;************************************************

    mean="no"
    ;mean="yes"
  plotstress="no"
  print("mean = "+mean+" stresses = "+plotstress)

  ; GIN
  ;minlat =  58.0
  ;maxlat =  84.0
  ;minlon = -30.0
  ;maxlon =  10.0

  minlon =   0.0
  maxlon = 360.0
  minlat =  70.0
  ;minlat =  88.0
  ;maxlat =  90.0

  ;SH
  ;minlat =  -90.0
  ;maxlat =  -40.0

  vmag = 20.00
 ; vmag = 0.25
  ;vthn = 0.008
  vthn = 0.012
  ;vthn = 0.00
begin
;************************************************
;
;************************************************

  nemsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/DATM/"
  runsrc = "BenchNemsio/"
  runtyp = "gfs."
   cdate = "2013070100/"

;************************************************
;
;************************************************

   plotname = runsrc
    runname = runsrc+"_"+cdate
     rtsrc =  nemsrc+runsrc+cdate
         gf = addfile(rtsrc+runtyp+"2013070300.nc","r")
   ;      gf = addfile(rtsrc+runtyp+"2013070218.nc","r")

  varname = "pressfc"
 ; varname = "icec"
 ; varname = "tmp_hyblev1"
  if(plotstress .eq. "yes")then
    uname = "uflx_ave"
    vname = "vflx_ave"
  else
    uname = "ugrd_hyblev1"
    vname = "vgrd_hyblev1"
    ;uname = "ugrd10m"
    ;vname = "vgrd10m"
  end if
  lstep = 1-1

   uvar = gf->$uname$(lstep,:,:)
   vvar = gf->$vname$(lstep,:,:)

  ;uvar = where(uvar@lat2d .ge. minlat, uvar, uvar@_FillValue)
  ;vvar = where(vvar@lat2d .ge. minlat, vvar, vvar@_FillValue)

  ;levs = (/-0.12,0.12,0.01/)
  ;levs = (/120.0,300.0,10.0/)
  ;levs = (/1012.0,1016.0,0.05/)
  levs = (/998.0,1024.0,1.0/)
  ;levs = (/0.0,1.0,0.10/)
  ;levs = (/-2.0,10.0,0.50/)

  plottitle=rtsrc+"~C~"+uname+"  "+vname

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
  wks   = gsn_open_wks (wkstype,"fv3")              ; send graphics to X11 window

  nplots= 1
   plot = new(nplots,graphic)
    dum = new(nplots,graphic)

  res            = True                          ; plot mods desired
  res@gsnPolar   =  "NH"                         ; specify the hemisphere
  ;res@mpProjection = "Satellite"
  res@mpFillOn             = True
  res@mpOutlineOn          = False

  res@mpMinLatF            =  minlat     ; range to zoom in on
  ;res@mpMaxLatF            =  maxlat
  ;res@mpMinLonF            =  minlon
  ;res@mpMaxLonF            =  maxlon
  ;res@mpCenterLatF         =  (maxlat - minlat)*0.50
  ;res@mpCenterLatF         =  -90.0
  res@mpCenterLonF         = -45.0
  ;res@mpLimitMode          = "LatLon"
  ;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
  ;res@mpGridAndLimbOn       = True         ; turn on lat/lon lines

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@tiMainFontHeightF = .01
  res@gsnStringFontHeightF = 0.015

  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@gsnScalarContour   = True              ; vectors over scalars
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette               = "WhBlGrYeRe"             ; choose colormap

  res@vcRefMagnitudeF       = vmag              ; vector magnitude
  res@vcRefLengthF          = 0.10          ; size of ref vector in NDC units
  ;res@vcMinFracLengthF      = 1.0
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcGlyphStyle          = "CurlyVector"
  ;res@vcPositionMode = "ArrowTail"

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
;  resP@gsnPanelYWhiteSpacePercent = 10
;  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

;************************************************
;
;************************************************

  ii=0
  ;plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  ;plot(ii) = gsn_csm_vector_scalar_map_polar(wks,uvar,vvar,avar,res)    ; create the plot
  plot(ii) = gsn_csm_vector_map_polar(wks,uvar,vvar,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ; zoom in
  ;ii=1
  ;minlat = 87.0
  ;res@mpMinLatF            =  minlat     ; range to zoom in on
  ;res@mpMaxLatF            =  maxlat
  ;plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  ;plot(ii) = gsn_csm_vector_scalar_map(wks,uvar,vvar,avar,res)    ; create the plot
   ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
 
;************************************************
; make the panel
;************************************************


  gsn_panel(wks,plot,(/1,1/),resP)
  ;gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

exit
end
