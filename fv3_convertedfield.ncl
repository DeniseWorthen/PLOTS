; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  ;rtsrc = "For_ESRL/BM2/gfs.20110901/00/"
  rtsrc = "For_ESRL/BM1/gfs.20110901/00/"

  ; GIN
  ;minlat =  58.0
  ;maxlat =  84.0
  ;minlon = -30.0
  ;maxlon =  10.0

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"

  if(hemi .eq. "none")then
   minlon = 120.0
   maxlon = 240.0
   minlat =  -30.0
   maxlat =   30.0
  end if

  ;minlat =  -90.0
  ;maxlat =  -40.0
;************************************************
;
;************************************************

  model = "f012"
  aname = "PRATE_P8_L1_GGA0_avg6h"

  rad2deg=180.d0/acos(-1.0d0)
  afile=addfile(RT3+rtsrc+"gfs.t00z.sfluxgrb"+model+".nc","r")
  ;print(afile)

  avar = afile->$aname$(:,:)
  avar@lon = afile->lon_0
  avar@lat = afile->lat_0
  ;ivar@lon2d = afile->grid_xt*rad2deg
  ;ivar@lat2d = afile->grid_yt*rad2deg
  ;printVarSummary(avar)

  ;weasd->snow depth
  ;avar = avar/rhosnow
  ;avar@long_name = "weasd convert to snow depth (m); rho_snow = 330 kg/m3"
  ;avar@units = " "

  ;snod->snow depth
  ;avar = avar*1.0e3
  ;avar@long_name = "snod*1000.0"
  ;avar@units = " "

  ;prate
  avar = avar*1.0e3 ;(prate unit = kg/m2 s)
  avar@long_name = "prate_ave*1000.0"
  avar@units = "original units = kg/m2 s"
  levs = (/0.0,2.00,.10/)

  plottitle=rtsrc+model+".nc  "+aname

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"fv3")              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  if(hemi .ne. "none")then
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
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         = (maxlon - minlon)/2.0
  end if

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

  plottitle = rtsrc+"  "+aname
  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

exit
end
