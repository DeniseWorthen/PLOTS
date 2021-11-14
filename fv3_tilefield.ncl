; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  RT4 = "/glade/scratch/worthen/FV3_RT/wav_test/"

  ;hemi="NH"
  ;hemi="SH"
  ;hemi="none"
  ;hemi="wedge"

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "wedge")then
    tile = "tile3"
  end if
  if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
  if(hemi .eq. "none")then
    tile = tile4
  end if

  model = "phyf000:07:30."
  tlonname = "grid_xt"
  tlatname = "grid_yt"

   rtsrc="cmepsv06_cold2/"
      gf=addfile(RT4+rtsrc+model+tile+".nc","r")

  if(hemi .eq. "none")then
   tilecorners = tilegrid(gf->$tlonname$,gf->$tlatname$,tile)
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   ;print(minlat+"   "+maxlat)
   ;print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  end if
  if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
  end if
  if(hemi .eq. "SH")then
     maxlat = -50.0
     midlon =   0.0
  end if
  if(hemi .eq. "wedge")then
   minlat =  62.0
   maxlat =  76.0
   minlon = 240.0
   maxlon = 280.0
   midlon = minlon + (maxlon - minlon)/2.0
  end if
  print(minlat+"   "+maxlat)
  print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))

  aname = "icec"
  levs=(/0.0,1.0,0.05/)

  avar = gf->$aname$(0,:,:)
  avar@lon2d = gf->$tlonname$
  avar@lat2d = gf->$tlatname$

  imask = avar
  imask = where(gf->land(0,:,:) .eq. 1.0, 0.0, 1.0)
  
  palette="MPL_rainbow"
  plottitle=model+tile

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"test")              ; send graphics to X11 window

  plot = new(1,graphic)
 oplot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  if(hemi .eq. "NH" .or. hemi .eq. "SH")then
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
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels = (/0.0/)
  ores@cnFillOn          = True                  ; color fill
  ;ores@cnFillPalette            = "gray6"

;************************************************
;
;************************************************

  if(hemi .eq. "wedge" .or. hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  end if
  ;oplot = gsn_csm_contour(wks,imask,ores)             ; create the plot
  ;overlay(plot,oplot)

  draw(plot)
  frame(wks)

exit
end
