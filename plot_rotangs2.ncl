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

  ;rtsrc = "/scratch1/NCEPDEV/climate/Denise.Worthen/gridsfix-no360/"
  rtsrc = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/CPLD_GRIDGEN/angfix.2ed3a283/500/"
  plottitle="fix"
  ;rtsrc = "/scratch1/NCEPDEV/climate/Denise.Worthen/addangvar-no360/"
  ;rtsrc = "/scratch1/NCEPDEV/nems/role.ufsutils/ufs_utils/reg_tests/cpld_gridgen/baseline_data/025/"
  ;rtsrc = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/CPLD_GRIDGEN/addang360/025/"
  ;plottitle = "baseline"

  grdfile = "tripole.mx500.nc"
  ;grdfile = "tripole.mx025.nc"
  grdsrc = ""
  rad2deg = 180.d0/acos(-1.0d0)

;************************************************
; ice
;************************************************

  ; load the grid file
  gr =addfile(rtsrc+grdsrc+grdfile,"r")
  print(rtsrc+grdsrc+grdfile)

  levs=(/-1.6,1.6,.1/)
  ;minlat = 66.0
  ;minlat = 89.0

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  ; mx500
  lon1=80.0
  lon2=-100.0
  ; mx025,050,100
  ;lon1=60.00
  ;lon2=-120.00
  lat1=60
  lat2=60

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstitle=plottitle
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(4,graphic)
  dum = new(4,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  ;res@mpMinLatF  = minlat                            ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette        = "NCV_jet"              ; choose colormap
  res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap

  res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  res@gsnStringFontHeightF = 0.02
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

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle+"  "+grdfile

  resP@gsnPanelFigureStrings = (/"angle on Ct","-angle on Bu", "angle on Ct","-angle on Bu"/)
;************************************************
;
;************************************************

  minlat = 66.0
  res@mpMinLatF  = minlat

  ii=0
  varname="anglet"
  lonname="lonCt"
  latname="latCt"
  var = gr->$varname$
  var@lon2d=gr->$lonname$
  var@lat2d=gr->$latname$
  var@units=" "
  plot(ii) = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii=1
  varname="angle"
  lonname="lonBu"
  latname="latBu"
  var = gr->$varname$
  ; in tripole file, anglet=(-1)*angle
  var = -1.0*var
  var@lon2d=gr->$lonname$
  var@lat2d=gr->$latname$
  var@units=" "
  plot(ii) = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ; minlat = 89.0
  ; res@mpMinLatF  = minlat

  ; ii=2
  ; varname="anglet"
  ; lonname="lonCt"
  ; latname="latCt"
  ; var = gr->$varname$
  ; var@lon2d=gr->$lonname$
  ; var@lat2d=gr->$latname$
  ; var@units=" "
  ; plot(ii) = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  ; dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ; ii=3
  ; varname="angle"
  ; lonname="lonBu"
  ; latname="latBu"
  ; var = gr->$varname$
  ; ; in tripole file, anglet=(-1)*angle
  ; var = -1.0*var
  ; var@lon2d=gr->$lonname$
  ; var@lat2d=gr->$latname$
  ; var@units=" "
  ; plot(ii) = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  ; dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)
  ;gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
