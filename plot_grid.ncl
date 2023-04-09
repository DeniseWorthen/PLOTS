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

  ;nemsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"
  ;grdsrc = "cice_data/mx024/"
  ;grdsrc2 = "/home/Denise.Worthen/MOM2CICE_2/"
  grdsrc = "/glade/u/home/worthen/ocean_topog_tnx1v4_20170622.nc"
  ;rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_meddump_oldrot/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;grdsrc = "ocn_2016_10_03_03.nc"

  rad2deg = 180.d0/acos(-1.0d0)

;************************************************
;
;************************************************

  ; load the grid file
  ;gr =addfile(nemsrc+grdsrc+"cice_grid_024.nc","r")
  ;gr =addfile(grdsrc+"grid_cice_NEMS_mx025.nc","r")
  ;gr =addfile(rtsrc+grdsrc,"r")
  ;gr2=addfile(grdsrc2+"grid_cice_NEMS_mx025.nc","r")
  gr = addfile(grdsrc,"r")

  ;varname="htn"
  ;latname="ulat"
  ;lonname="ulon"

  ;varname="dxCv"
  ;varname="htn"
  ;latname="geolat_v"
  ;lonname="geolon_v"

  latname = "y"
  lonname = "x"
  varname = "y"
  ;var = gr->$varname$/100.0
  ;var = gr2->$varname$
  ;var@lon2d=gr->$lonname$*rad2deg
  ;var@lat2d=gr->$latname$*rad2deg
  var = gr->$varname$
  var@lon2d=gr->$lonname$
  var@lat2d=gr->$latname$

  ;levs=(/6400.0, 6600.0, 5.0/)
  ;levs=(/10500.0, 11000.0, 5.0/)
  ;levs = (/0, 1, 1/)
  ;levs = (/-180.0,180.0, 5.0/)
  levs = (/50.0, 90.0, 2.0/)

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=60.00
  lon2=-120.00
  lat1=60
  lat2=60

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"grid")              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillMode = "MeshFill"
  res@mpFillOn   = True

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF  = 66                            ; minimum lat to plot
  ;res@mpMinLatF  = 88                            ; minimum lat to plot
  ;res@mpMinLatF  = 82                            ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = False                  ; color fill
  ;res@cnLevelSpacingF   = 3.                    ; interval spacing
  res@cnLinesOn         = True                 ; no contour lines
  res@cnLineLabelsOn   = False

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillPalette        = "NCV_jet"              ; choose colormap

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

;************************************************
;
;************************************************

  plot = gsn_csm_contour_map_polar(wks,var,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)

end
