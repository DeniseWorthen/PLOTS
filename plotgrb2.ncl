load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;     float SALTY_P8_L161_GLL0_avg6h ( lv_DBWS0, lat_0, lon_0 )
begin
;---Open file and read data
  filename = "/scratch1/NCEPDEV/stmp2/Rahul.Mahajan/RUNTESTS/COMROOT/oi2/gfs.20160701/00/products/ocean/grib2/0p25/gfs.ocean.t00z.0p25.f018.grib2"
  a    = addfile(filename,"r")
  ;print(a)
  vname="SALTY_P8_L161_GLL0_avg6h"
  ;vname="WTMP_P8_L161_GLL0_avg6h"
  var=a->$vname$
  print(dimsizes(var))

  nz = 40-1
  ny = 721-1
  nx = 1440-1

;---Start the graphics
  wks = gsn_open_wks("X11","test")

;---Set some resources
  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@cnFillOn          = True     ; turn on color fill
  res@cnLinesOn         = False    ; turn off contour lines

  plot = gsn_csm_contour(wks,var(:,:,720),res)
end