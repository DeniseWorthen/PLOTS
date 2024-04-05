load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;     float SALTY_P8_L161_GLL0_avg6h ( lv_DBWS0, lat_0, lon_0 )
begin
;---Open file and read data
  ;filename = "/scratch1/NCEPDEV/stmp2/Rahul.Mahajan/RUNTESTS/COMROOT/oi2/gfs.20160701/00/products/ocean/grib2/0p25/gfs.ocean.t00z.0p25.f018.grib2"
  filename="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/ufs_hr1/20200707/gfs.20200707/00/atmos/gfs.t00z.sfluxgrbf264.grib2"
  a    = addfile(filename,"r")
  vname="TMP_P0_L1_GGA0"
  ;print(a)
  ;vname="SALTY_P8_L161_GLL0_avg6h"
  ;vname="WTMP_P8_L161_GLL0_avg6h"
  var=a->$vname$
  var=var-273.15
  ;print(dimsizes(var))
  var@units=""
  var@long_name="crappy atm tmpsfc"
  levs=(/-2.0,1.0,.1/)
  minlat = 66.0

;---Start the graphics
  wks = gsn_open_wks("X11","test")

   wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,"cice5")              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

 ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   =  "NH"
  res@mpMinLatF    =  minlat                          ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

;************************************************
;
;************************************************

  plot = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  ;plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;pum= gsn_add_polymarker(wks,plot,center_xlon,center_xlat,mkres)

  draw(plot)
  frame(wks)

exit
end