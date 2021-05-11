; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

 ;  hemi = "NH"
 ; hemi = "SH"
  hemi = "none"

  rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile4"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if


  ;rtsrc = "grids-20210223"
  ;gfile = "C96.mx100."+tile+".nc"
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/"+rtsrc+"/"+gfile,"r")
  ;plottitle="New mapped ocean mask "+gfile

  ;rtsrc = "mapped_omask_fix_mx100"
  ;gfile = "C96.mx100."+tile+".nc"
  ;afile = addfile("/scratch2/NCEPDEV/stmp1/Denise.Worthen/ForShan/"+rtsrc+"/"+gfile,"r")
  ;plottitle="Previous mapped ocean mask "+gfile

  ;tlonname = "grid_xt"
  ;tlatname = "grid_yt"
  ;rfactor=rad2deg

  ;rtsrc = "C96_l127.mx100_frac"
  ;gfile = "oro_data."+tile+".nc"
  ;afile = addfile("/scratch2/BMC/gsd-fv3-dev/FV3-MOM6-CICE5/inputdata_v16_rtest/FV3_input_frac/"+rtsrc+"/"+gfile,"r")
  ;plottitle="New mapped ocean mask "+gfile

  rtsrc = "C96_L127.mx100_frac"
  gfile = "oro_data."+tile+".nc"
  afile = addfile("/scratch1/NCEPDEV/stmp4/Denise.Worthen/input-data_20210426/FV3_input_frac/"+rtsrc+"/"+gfile,"r")
  plottitle="New inputdata ocean mask "+gfile

  tlonname = "geolon"
  tlatname = "geolat"

  tilecorners = tilegrid(afile->$tlonname$,afile->$tlatname$,tile)
  if(hemi .eq. "none")then
   ;minlon = tilecorners[0]
   ;minlat = tilecorners[1]
   ;maxlon = tilecorners[2]
   ;maxlat = tilecorners[3]
   minlon = 144.0
   minlat = -10.
   maxlon = 154.0
   maxlat = 0.0
   midlon = minlon + 0.5*(maxlon - minlon)
   print(minlat+"   "+maxlat)
   print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  palette="MPL_rainbow"
  aname = "land_frac"
  levs=(/0.0,1.0,0.1/)

  avar = afile->$aname$(:,:)
  avar = 1.0 - avar
  avar@lon2d = afile->$tlonname$
  avar@lat2d = afile->$tlatname$


;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle=rtsrc+"_"+gfile
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  66.0                          ; minimum lat to plot
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
   res@mpCenterLonF         =  midlon
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill
  res@cnFillPalette            = palette

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
; Resources for the polymark
;************************************************

  pmres                 = True           ; polyline mods desired
  pmres@gsMarkerIndex   = 16             ; Use filled dots for markers.
  pmres@gsMarkerSizeF   = 0.02

  xlat = -5.818
  xlon = 148.5

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  end if
  dum = gsn_add_polymarker(wks,plot,xlon,xlat,pmres)

  draw(plot)
  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x20 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if
exit
end
