; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/"

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
    tile = "tile2"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

  model = "phyf048."
  ;model = "phyf006."
  tlonname = "grid_xt"
  tlatname = "grid_yt"
  rfactor=rad2deg

 plotlabs = (/"CMEPS fracF-fracT", "nems fracF-fracT"/)
      ;rts = (/"cmeps", "nems"/)
     meds = (/"cmeps", "nems"/)
      rts = (/"fracTestsifrac/", "fracTests/"/)
  atmfiles = addfiles(RT1+rts+meds+".diff."+model+tile+".nc","r")

  ; difference fields mean that lats and lons are 0
     ;gf = addfile(RT1+"fracT/cmeps_cold2/"+model+tile+".nc","r")
     gf = addfile(RT1+rts(0)+"/fracT/cmeps_cold2/"+model+tile+".nc","r")
  tilecorners = tilegrid(gf->$tlonname$,gf->$tlatname$,tile)
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

  ; atm fields
  atmflds = (/"icec",     \
              "land",     \
              "tmpsfc",   \
              "tisfc",    \
              "ulwrf",    \
              "lhtfl",     \
              "shtfl"     \
              /)
  nflds = dimsizes(atmflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.0,    1.0,  0.10/)   ; icec
  plotlevs( 1,:) = (/  -2.0,    2.0,  1.00/)   ; land
  plotlevs( 2,:) = (/  -4.0,    4.0,  0.20/)   ; tmpsfc
  plotlevs( 3,:) = (/  -4.0,    4.0,  0.20/)   ; tisfc
  plotlevs( 4,:) = (/ -20.0,   20.0,  2.00/)   ; ulwrf
  plotlevs( 5,:) = (/ -40.0,   40.0,  2.00/)   ; lhtfl
  plotlevs( 6,:) = (/ -40.0,   40.0,  2.00/)   ; shtfl

  cmap="BlueWhiteOrangeRed"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot =0
       levs = plotlevs(fldtoplot,:)
    fldname = atmflds(fldtoplot)
   wkstitle = fldname+"_"+model+tile
   ;wkstitle = rts(0)+"-"+rts(2)

  ; special settings
       owgt = 1.0
  if(fldname .eq. "lprec")then   ; make levels easier
       owgt = 3600.0
  end if

  plottitle=model+tile+".nc  "+fldname
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)

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
  res@gsnCenterStringOrthogonalPosF   = 0.15

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
  diff = atmfiles[ii]->$fldname$(0,:,:)
  diff@lon2d = gf->$tlonname$
  diff@lat2d = gf->$tlatname$
  plot(ii) = subplot(ii,plotlabs(ii),diff,levs,cmap,hemi)

  ii = 1
  plot(ii) = subplot(ii,plotlabs(ii),diff,levs,cmap,hemi)
  diff = atmfiles[ii]->$fldname$(0,:,:)
  diff@lon2d = gf->$tlonname$
  diff@lat2d = gf->$tlatname$
  plot(ii) = subplot(ii,plotlabs(ii),diff,levs,cmap,hemi)

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
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
