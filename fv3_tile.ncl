; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

 ;rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_35d_july_blowup/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
 ;grdsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_c384_cold/tmp/cpld_fv3_384_mom6_cice_cold_atm_flux/"

 ;rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/" 
 ;grdsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/" 
 ;rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/rtgen.1000/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"

 ;rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/rtgen.113668/tmp/cpld_fv3_384_mom6_cice_2d_bm2/" 
 ;rtsrc = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/rtgen.23553/tmp/cpld_fv3_384_mom6_cice_2d_bm2/" 
 ;rtsrc = "/scratch4/NCEPDEV/stmp3/Jessica.Meixner/rtgen.110708/tmp/cpld_fv3_384_mom6_cice_2d_bm2/"
 ;rtsrc = "/scratch4/NCEPDEV/stmp3/Jessica.Meixner/rtgen.110097/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
 ;rtsrc = "/scratch3/NCEPDEV/stmp1/Jessica.Meixner/rtgen.15088/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
 ;rtsrc = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/SeaIce/rtgen.4491/tmp/cpld_fv3_384_mom6_cice_2d_bm2/" 

  rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/BM2TstOut/"

  ; GIN
  ;minlat =  58.0
  ;maxlat =  84.0
  ;minlon = -30.0
  ;maxlon =  10.0

  minlon =   0.0
  maxlon = 360.0
  minlat =  60.0
  ;minlat =  88.0
  maxlat =  90.0

  ;minlat =  -90.0
  ;maxlat =  -40.0
;************************************************
;
;************************************************

 ; SP
 ;  tile = "tile6"
 ; NP
   tile = "tile3"

  ;model = "phyf087."
  ;model = "phyf012."
  ;model = "phyf021."
  ;aname = "uflx_ave"
  ;aname = "vflx_ave"
  ;aname = "dlwrf_ave"
  ;aname = "tmpsfc"
  model = "fv3."
  aname = "tisfc"

  rad2deg=180.d0/acos(-1.0d0)
  print(rtsrc+model+aname+".nc")
  afile=addfile(rtsrc+model+aname+".nc","r")
  ifile=addfile(rtsrc+model+"icec.nc","r")
   ;  gf=addfile(rtsrc+"dynf000."+tile+".nc","r")
  ;   gf=addfile(grdsrc+"grid_spec."+tile+".nc","r")

  lstep=80-1
  ivar = ifile->icec(:lstep,:,:)
  avar = afile->$aname$(:lstep,:,:)
  avar@lon2d = afile->grid_xt*rad2deg
  avar@lat2d = afile->grid_yt*rad2deg
  ;avar = dim_avg_n_Wrap(afile->$aname$(:lstep,:,:),0)
  avar = mask(avar, ivar .eq. 0.0, False)
  amask = dim_avg_n_Wrap(avar,0)
  copy_VarCoords(avar,amask)
  amask = amask - 273.15
  ;avar@units = "degC"

  ;avar@lon2d = gf->grid_xt
  ;avar@lat2d = gf->grid_yt
  ;printVarSummary(avar)

  levs = (/-8.00,0.0,.2/)
  ;levs = (/-6.00,0.0,.1/)
  ;levs = (/-2.00,0.0,.02/)
  ;levs = (/-0.12,0.12,0.01/)
  ;levs = (/120.0,300.0,10.0/)

  plottitle=rtsrc+model+tile+".nc  "+aname

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
    pmk = new(nplots,graphic)

  res            = True                          ; plot mods desired
  ;res@mpProjection = "Satellite"

  ;res@mpMinLatF            =  minlat     ; range to zoom in on
  ;res@mpMaxLatF            =  maxlat
  ;res@mpMinLonF            =  minlon
  ;res@mpMaxLonF            =  maxlon
  ;;res@mpCenterLatF         =  (maxlat - minlat)*0.50
  ;res@mpCenterLatF         =  90.0
  ;res@mpCenterLonF         = -45.0
  ;res@mpLimitMode          = "LatLon"
  ;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
  ;res@mpGridAndLimbOn       = True         ; turn on lat/lon lines

  res@gsnPolar     =  "NH"
  res@mpMinLatF    =  minlat                          ; minimum lat to plot
  res@mpCenterLonF = -45

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@tiMainFontHeightF = .01
  res@gsnStringFontHeightF = 0.015

  res@mpFillOn             = False
  res@mpOutlineOn          = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015
  ;res@cnFillPalette      = "radar"
  res@cnFillPalette        = "MPL_rainbow"              ; choose colormap

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
; Resources for the polymark
;************************************************

  ;mres@mpGreatCircleLinesOn = True
  ;mres                  = True           ; polyline mods desired
  ;mres@gsMarkerIndex   = 16             ; Use filled dots for markers.
; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

  xx = -10.5
  yy = 70.59

  ii=0
  ;plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  plot(ii) = gsn_csm_contour_map_polar(wks,amask,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   ;pmk(ii) = gsn_add_polymarker(wks,plot(ii),xx,yy,mres)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,1/),resP)

  frame(wks)

exit
end
