; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  hemi = "none"
  hemi="SH"
  if(hemi .eq. "none")then
    tile = "tile1"
  else
    if(hemi .eq. "NH")then
      tile = "tile3"
    end if
    if(hemi .eq. "SH")then
      tile = "tile6"
    end if
  end if

;************************************************
;
;************************************************

   ;plotlabs = (/"Control", "Continue", "Restart"/)

   ;RT1 = "/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/sfs_restart/"
   ;hours = (/"19940501.010000","19940501.011000","19940501.011000"/)

   ;RT1 = "/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/c192.restart/"
   ;hours = (/"20210322.070000","20210322.071000","20210322.071000"/)

   ;rts = (/"base.c192/", "base.c192/", "rest.c192/"/)

   RT1="/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2185131/"
   rts="base.10d/"
   hours = "84"

   ;atmfiles = addfiles(RT1+rts+"RESTART/"+hours+".sfc_data."+tile+".nc","r")
   atmfiles = addfiles(RT1+rts+"sfcf024."+tile+".nc","r")

   gf = addfile(RT1+rts(0)+"INPUT/oro_data."+tile+".nc","r")
   tlonname = "geolon"
   tlatname = "geolat"
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
      minlat =  40.0
      midlon = -45.0
    else
      maxlat = -50.0
      midlon =   0.0
    end if
  end if

   ; atm fields
   atmflds = (/"snodl", \
              "weasdl", \
              "snodi", \
              "weasdi", \
              "tsea", \
              "tisfc" /)
  nflds = dimsizes(atmflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.0e20,    1.0e20,  1.e20/)
  plotlevs( 1,:) = (/  -1.0e20,    1.0e20,  1.e20/)
  plotlevs( 2,:) = (/  -1.0e20,    1.0e20,  1.e20/)
  plotlevs( 3,:) = (/  -1.0e20,    1.0e20,  1.e20/)
  plotlevs( 4,:) = (/  270.0, 310.0, 2.0/)
  plotlevs( 5,:) = (/  -40.0, 5.0, 1.0/)
  ;plotlevs (5,:) = (/-1.0, 4.0, 1.0/)
  ; plotlevs( 0,:) = (/  -1.0,    1.0,  0.10/)   ; icec
  ; plotlevs( 1,:) = (/  -2.0,    2.0,  1.00/)   ; land
  ; plotlevs( 2,:) = (/  -4.0,    4.0,  0.20/)   ; tmpsfc
  ; plotlevs( 3,:) = (/  -4.0,    4.0,  0.20/)   ; tisfc
  ; plotlevs( 4,:) = (/ -20.0,   20.0,  2.00/)   ; ulwrf
  ; plotlevs( 5,:) = (/ -40.0,   40.0,  2.00/)   ; lhtfl
  ; plotlevs( 6,:) = (/ -40.0,   40.0,  2.00/)   ; shtfl

  cmap="BlueWhiteOrangeRed"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 5
  levs = plotlevs(fldtoplot,:)
  fldname = atmflds(fldtoplot)
  wkstitle="test"
   ;wkstitle = fldname+"_"+model+tile
   ;wkstitle = rts(0)+"-"+rts(2)

  ; special settings
  ;     owgt = 1.0
  ;if(fldname .eq. "lprec")then   ; make levels easier
  ;     owgt = 3600.0
  ;end if

  ;plottile="test"
  plottitle=fldname
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  ;plot = new(3,graphic)
  plot = new(1,graphic)

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
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

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
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle

; ***************************************************
;
; ***************************************************

  maskvar="land"
  mvar=atmfiles[0]->$maskvar$(0,:,:)
  ;printVarSummary(mvar)

  ii = 0
  diff = atmfiles[ii]->$fldname$(0,:,:)
  diff = where(mvar .ne. 1.0, diff-273.15, diff@_FillValue)
  diff@_units="degC"
  diff@_long_name=""
  diff@lon2d = gf->$tlonname$
  diff@lat2d = gf->$tlatname$
  plot(ii) = subplot(ii,"sfcf "+"at "+hours(ii),diff,levs,cmap,hemi)

;  ii = 1
;  diff = atmfiles[ii]->$fldname$(0,:,:)
;  diff@lon2d = gf->$tlonname$
;  diff@lat2d = gf->$tlatname$
;  plot(ii) = subplot(ii,plotlabs(ii)+" at "+hours(ii),diff,levs,cmap,hemi)

;  ii = 2
;  diff = atmfiles[ii]->$fldname$(0,:,:)
;  diff@lon2d = gf->$tlonname$
;  diff@lat2d = gf->$tlatname$
;  plot(ii) = subplot(ii,plotlabs(ii)+" at "+hours(ii),diff,levs,cmap,hemi)

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/3,1/),resP)
  gsn_panel(wks,plot,(/1,1/),resP)

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
