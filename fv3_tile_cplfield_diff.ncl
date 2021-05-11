; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ;hemi = "NH"
  hemi = "SH"
  ;hemi = "none"

 rad2deg=180.d0/acos(-1.0d0)
 rhosnow=330.0

 tilelonname = "grid_xt"
 tilelatname = "grid_yt"

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile5"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if


; idate = "2016100300"
; plotlabs = (/"DT900", "DT720"/)
;      rts = (/"test_dts_c96/",\
;              "test_dts_c96/"/)
;    csets = (/"cpld_debugfrac/ufs.cpld.cpl.hi.2016-10-03-00900.",\
;              "cpld_debugfrac_dt/ufs.cpld.cpl.hi.2016-10-03-00720."/)

 idate = "2011050100"
 plotlabs = (/"DT225", "DT300"/)
      rts = (/"test_dts/",\
              "test_dts/"/)
    csets = (/"v16test_dt225/ufs.cpld.cpl.hi.2011-05-01-00225.",\
              "v16test_dt300/ufs.cpld.cpl.hi.2011-05-01-00300."/)
  files = addfiles(RT2+rts+csets+tile+".nc","r")
  ;print(files)

  tilecorners = tilegrid(files[0]->$tilelonname$,files[0]->$tilelatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   ;minlon = -90.0
   ;minlat = -30.0
   ;maxlon = -60.0
   ;maxlat = 0.0
   midlon = minlon + 0.5*(maxlon - minlon)
   ;print(minlat+"   "+maxlat)
   ;print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
   ; minlat =  76.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  ;vname = "atmImp_Sa_tbot"
  ;levs=(/-0.1,0.1,0.01/)
  ;vname = "atmImp_Sa_pbot"
  ;levs=(/-10.0,10.0,1.0/)
  vname = "atmImp_Sa_z"
  levs=(/-1.0,1.0,0.1/)
  diff = files[1]->$vname$(:,:) ; copy atts
  diff = files[1]->$vname$(:,:)-files[0]->$vname$(:,:)
  ;printVarSummary(diff)

  diff@lon2d = files[0]->grid_xt
  diff@lat2d = files[0]->grid_yt
  colormap="BlueWhiteOrangeRed"

  plottitle=plotlabs(1)+" - "+plotlabs(0)+":  "+tile+"  "+vname

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wkstitle=tile+"."+vname
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                         ; minimum lat to plot
    res@mpCenterLonF =  midlon
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = maxlat                            ; minimum lat to plot
    res@mpCenterLonF = midlon
   end if
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         =  midlon
  end if

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,diff,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,diff,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
