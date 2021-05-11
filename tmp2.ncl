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
  hemi = "SH"
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

  tlonname = "grid_xt"
  tlatname = "grid_yt"
  rfactor=rad2deg

  ;rtsrc = "FV3_RT/test96/debug/INPUT/"
  ;afile = addfile(RT2+rtsrc+model+tile+".nc","r")
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/grids-20210201/C96.mx100.tile4.nc","r")
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/GRIDS/C96.mx100.tile4.nc","r")
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/GTMP/C96.mx100.tile4.nc","r")

 ;model="P6 IC"
 ; rtsrc = "FV3_RT/rt_201936/test/"
 ; wkstitle="dt=225s"
 ; afile = addfile(RT2+rtsrc+"ufs.cpld.cpl.hi.2011-05-01-00225."+tile+".nc","r")
 ; rtsrc = "FV3_RT/tests_dt/test3_300/"
 ; wkstitle="dt=300s"
 ; afile = addfile(RT2+rtsrc+"ufs.cpld.cpl.hi.2011-05-01-00300."+tile+".nc","r")

 model="DT test"
  rtsrc = "FV3_RT/test_dts_c96/"
  wkstitle="dt_diff"
  afile = addfile(RT2+rtsrc+"diff.nc","r")
  ofile = addfile(RT2+rtsrc+"cpld_debugfrac/INPUT/oro_data."+tile+".nc","r")

  ;tilecorners = tilegrid(afile->$tlonname$,afile->$tlatname$,tile)
  tilecorners = tilegrid(ofile->$tlonname$,ofile->$tlatname$,tile)
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

  ;palette="MPL_rainbow"
  ;print(afile)
  ;aname = "icec"
  ;levs=(/0.0,1.0,0.1/)
  ;aname = "land"
  ;levs=(/0.0,2.0,1/)
  ;aname = "tisfc"
  ;aname = "tmpsfc"
  ;levs=(/-2.0,0.0,.2/)
  ;aname = "ulwrf"
  ;levs=(/300,322,1/)

  aname = "atmImp_Sa_tbot"
  oname = "Med_frac_atm_ofrac"
  ;levs=(/-5.0,5.0,0.5/)
  levs=(/-1.0,1.0,0.1/)
  palette="BlueWhiteOrangeRed"

  avar = afile->$aname$(:,:)
  avar@lon2d = afile->$tlonname$
  avar@lat2d = afile->$tlatname$

  oname = "slmsk"
  ovar = ofile->$oname$(:,:)
  ovar@lon2d = afile->$tlonname$
  ovar@lat2d = afile->$tlatname$

  plottitle=model+" "+tile+" "+aname

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  plot = new(1,graphic)
 oplot = new(1,graphic)

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
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/0.99/)

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  oplot = gsn_csm_contour(wks,ovar,ores)    ; create the plot
  overlay(plot,oplot)
   ;plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
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
