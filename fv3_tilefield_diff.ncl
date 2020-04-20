; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/scrub/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"


  hemi = "NH"
 ; hemi = "SH"
 ; hemi = "none"

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

  model = "phyf006."

  ;vname = "icec"
  ;vname = "tmpsfc"
  ;vname = "tisfc"
  ;vname = "dlwrf"
  ;vname = "ulwrf"
  vname = "land"

    rts = (/"S2S_SM","S2S_nems"/)
  csets = (/"/rtgen.158125/tmp/cpld_fv3_384_mom6_cice_2d_bmark/", \
            "/2012010100_12d/tmp/cpld_fv3_384_mom6_cice_2d_bmark/"/)
  files = addfiles(RT4+rts+csets+model+tile+".nc","r")

  tilecorners = tilegrid(files[0]->$tilelonname$,files[0]->$tilelatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
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

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar
  
  diff = files[1]->$vname$(lstep,:,:) ; copy atts
  diff = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ;printVarSummary(diff)

  ;weasd->snow depth
  ;avar = avar/rhosnow
  ;avar@long_name = "weasd convert to snow depth (m); rho_snow = 330 kg/m3"
  ;avar@units = " "

  ;snod->snow depth
  ;avar = avar*1.0e3
  ;avar@long_name = "snod*1000.0"
  ;avar@units = " "

  ;prate
  ;avar = avar*3600.0 ;(prate unit = kg/m2 s; equiv to mm/s; mult by 3600 mm/hr))
  ;avar@long_name = "prate_ave*3600.0"
  ;avar@units = "mm/hr"
  ;levs = (/0.0,2.00,.10/)

  ;tmpsfc,tisfc
        avar = diff
  ;      avar = where(files[1]->$vname$(lstep,:,:) .eq. 1.0, diff@_FillValue, files[1]->$vname$(lstep,:,:))
  avar@lon2d = files[0]->grid_xt
  avar@lat2d = files[0]->grid_yt
  ;levs=(/0.0,2.0,1.0/)
  levs=(/-3.0,3.0,1.0/)
  ;levs=(/-1.0,1.0,0.1/)
  ;levs=(/-0.1,0.1,0.01/)
  colormap = "BlueDarkRed18"

  plottitle=rts(1)+" - "+rts(0)+":  "+model+tile+".nc  "+vname

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,model+tile)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = True
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

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

exit
end
