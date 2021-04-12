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

  ; all tiles are the same
  hemi = "none"
  tile = "tile4"

  rad2deg=180.d0/acos(-1.0d0)

;************************************************
;
;************************************************

  lstep=0

  tlonname = "grid_lon"
  tlatname = "grid_lat"
  rfactor=rad2deg

  rtsrc= RT2+"/FV3_RT/testruns/testbilin/"
  gfile = "grid_spec"
  afile = addfile(rtsrc+gfile+"."+tile+".nc","r")
  plottitle="C96 Area"
  print(rtsrc+gfile)

  tilecorners = tilegrid(afile->$tlonname$,afile->$tlatname$,tile)
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   print(minlat+"   "+maxlat)
   print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))

  palette="amwg256"
  aname = "area"
  levs=(/0.0,140.,5./)

  avar = afile->$aname$(:,:)
  avar = avar/1.0e8
  avar@lon2d = afile->$tlonname$
  avar@lat2d = afile->$tlatname$
  printVarSummary(avar)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="area_"+gfile+"_"+tile
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

   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         =  midlon

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
;
;************************************************

   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot

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
