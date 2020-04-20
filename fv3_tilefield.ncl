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
  ; theia
  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  ;RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

   hemi = "NH"
 ; hemi = "SH"
 ; hemi = "none"

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

  ;model = "phyf000:07:30."
  model = "phyf000:15:00."
  tlonname = "grid_xt"
  tlatname = "grid_yt"
  rfactor=rad2deg
  ;model = "oro_data."
  ;tlonname = "lon"
  ;tlatname = "lat"
  ;rfactor=1.0

  rtsrc = "NEMS_Shan_fix/2012070100_1d_inst/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
  ;rtsrc = "NEMS_upfv3_fix3/2012070100_1d_inst/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
  afile = addfile(RT1+rtsrc+model+tile+".nc","r")

  tilecorners = tilegrid(afile->$tlonname$*rad2deg,afile->$tlatname$*rad2deg,tile)
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
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  palette="MPL_rainbow"
  ;print(afile)
  ;aname = "icec"
  ;levs=(/0.0,1.0,0.1/)
  ;aname = "land"
  ;levs=(/0.0,2.0,1/)
  ;palette="amwg"
  ;aname = "tisfc"
  aname = "tmpsfc"
  levs=(/-2.0,0.0,.2/)
  ;aname = "ulwrf"
  ;levs=(/300,322,1/)

  ;aname = "slmsk"
  ;levs=(/0.0,4.0,1/)

  avar = afile->$aname$(0,:,:)
 ; avar = afile->$aname$(:,:)
  avar = (afile->$aname$(lstep,:,:)) - 273.15
  avar = where(afile->land(lstep,:,:) .eq. 1.0, avar@_FillValue, avar)
  ;avar = where(afile->icec(lstep,:,:) .lt. icemin, avar@_FillValue, avar)
  avar@lon2d = afile->$tlonname$*rad2deg
  avar@lat2d = afile->$tlatname$*rad2deg

  plottitle=rtsrc+model+tile+".nc  "+aname

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
