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
  icemin = 1.0e-6
  ;icemin = 1.0e-11

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

  model = "phyf240."
  tlonname = "grid_xt"
  tlatname = "grid_yt"
  rfactor=rad2deg

 plotlabs = (/"Hera-NEMS", "Hera-CMEPS", "Hera-CMEPS_latest"/)
      rts = (/"S2S_nems", "S2S_cmepsfix", "S2S_cmepschanges"/)
    csets = (/"/2012010100_35d/tmp/cpld_fv3_384_mom6_cice_2d_bmark/",\
              "/2012010100_35d/tmp/cpld_fv3_384_mom6_cice_2d_cmeps_bmark/", \
              "/2012010100_35d/tmp/cpld_fv3_384_mom6_cice_2d_cmeps_bmark/"/)
  atmfiles = addfiles(RT4+rts+csets+model+tile+".nc","r")

     afile = atmfiles[0]
  tilecorners = tilegrid(afile->$tlonname$,afile->$tlatname$,tile)
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
    ;minlat =  66.0
    minlat =  40.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if
  delete(afile)

  ; atm fields
  atmflds = (/"icec",     \
              "land",     \
              "tmpsfc",   \
              "ulwrf"     \
              /)
  nflds = dimsizes(atmflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.0,    1.0,  0.10/)   ; icec
  plotlevs( 1,:) = (/  -2.0,    2.0,  1.00/)   ; land
  plotlevs( 2,:) = (/ -10.0,   10.0,  1.00/)   ; tmpsfc
  plotlevs( 3,:) = (/-100.0,  100.0, 10.00/)   ; ulwrf

  cmap="BlueWhiteOrangeRed"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot =2
       levs = plotlevs(fldtoplot,:)
    fldname = atmflds(fldtoplot)
   ;wkstitle = rts(0)+"-"+rts(1)
   ;wkstitle = rts(0)+"-"+rts(2)
   wkstitle = "fv3_field_"+fldname

  ; special settings
       owgt = 1.0
  if(fldname .eq. "lprec")then   ; make levels easier
       owgt = 3600.0
  end if

  ; Hera Nems-cmeps; first copy metadata
  odiff0 = atmfiles[0]->$fldname$(0,:,:)
  odiff0 = atmfiles[0]->$fldname$(0,:,:) - atmfiles[1]->$fldname$(0,:,:)
  odiff0 = odiff0*owgt
  odiff0@lon2d = atmfiles[0]->$tlonname$
  odiff0@lat2d = atmfiles[0]->$tlatname$
 pltlab0 = plotlabs(0)+" - "+plotlabs(1)
  ; Hera Nems-Wcoss Nems
  odiff1 = atmfiles[0]->$fldname$(0,:,:)
  odiff1 = atmfiles[0]->$fldname$(0,:,:) - atmfiles[2]->$fldname$(0,:,:)
  odiff1 = odiff1*owgt
  odiff1@lon2d = atmfiles[0]->$tlonname$
  odiff1@lat2d = atmfiles[0]->$tlatname$
 pltlab1 = plotlabs(0)+" - "+ plotlabs(2)

  if(fldname .eq. "lprec")then   ; make levels easier
   odiff0@units = "mm/d"
   odiff1@units = "mm/d"
  end if
  plottitle=model+tile+".nc  "+fldname
;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = True

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
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

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,hemi)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

  if(hemi .eq. "none")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle

; ***************************************************
;
; ***************************************************

  ii = 0
  plot(ii) = subplot(ii,pltlab0,odiff0,levs,cmap,hemi)
  ii = 1
  ;ii = 0
  plot(ii) = subplot(ii,pltlab1,odiff1,levs,cmap,hemi)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

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
