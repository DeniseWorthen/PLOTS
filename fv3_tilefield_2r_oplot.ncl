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
  ; theia
  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  ;RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

 ;  hemi = "NH"
 ; hemi = "SH"
  hemi = "none"
  zoom = "yes"

  rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6
  ;icemin = 1.0e-11

;************************************************
;
;************************************************

  lstep=0
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

  model = "phyf006."
  tlonname = "grid_xt"
  tlatname = "grid_yt"
  rfactor=rad2deg

      rts = (/"FMC_Testing/NEMS_Moorthi","FMC_Testing/NEMS_upfv3_2"/)
     cset = "/2012070100_2d/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
    files = addfiles(RT1+rts+cset+model+tile+".nc","r")

     afile = files[0]
  tilecorners = tilegrid(afile->$tlonname$*rad2deg,afile->$tlatname$*rad2deg,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   if(zoom .eq. "yes")then
  ;  minlon =  10.0
    minlon =  0.0
    minlat = -20.0
    maxlat =  20.0
   end if
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if
  delete(afile)

  ;colormap="MPL_rainbow"
  colormap="amwg256"
  ;aname = "icec"
  ;pltlevs=(/0.0,1.0,0.1/)
  ;aname = "land"
  ;pltlevs=(/0.0,2.0,1/)
  ;aname = "tisfc"
  ;pltlevs=(/-5.0,0.0,.2/)
  aname = "tmpsfc"
  ;pltlevs=(/-2.0,2.0,.2/)
  pltlevs=(/10.0,32.0,1./)
  ;aname = "ulwrf"
  ;pltlevs=(/0,350,10/)

  plottitle=model+tile+".nc  "+aname
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,model+tile)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
 oplot = new(2,graphic)
   dum = new(2,graphic)

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

   ;res@cnMissingValFillColor    = "gray70" ; set color for missing areas

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
  ores@cnLevels         = (/0.5/)

;************************************************
;
;************************************************

          ii = 0
        avar = (files[ii]->$aname$(lstep,:,:)) - 273.15
        ovar = files[ii]->land(lstep,:,:)
  ;      avar = where(files[ii]->land(lstep,:,:) .eq. 1.0, avar@_FillValue, avar)
  ;      avar = where(files[ii]->icec(lstep,:,:) .lt. icemin, avar@_FillValue, avar)
  ;      avar = where(files[ii]->icec(lstep,:,:) .ge. icemin, avar, avar@_FillValue)
  avar@lon2d = files[ii]->$tlonname$*rfactor
  avar@lat2d = files[ii]->$tlatname$*rfactor
  ovar@lon2d = files[ii]->$tlonname$*rfactor
  ovar@lat2d = files[ii]->$tlatname$*rfactor
  ;res@gsnCenterString  = rts(ii)+" ai>icemin"
  res@gsnCenterString  = rts(ii)
  plot(ii) = subplot(ii,aname,avar(:,:),pltlevs,colormap,hemi)
 oplot(ii) = gsn_csm_contour(wks,ovar(:,:),ores)             ; create the plot
 overlay(plot(ii),oplot(ii))

          ii = 1
        avar = (files[ii]->$aname$(lstep,:,:)) - 273.15
        ovar = files[ii]->land(lstep,:,:)
  ;      avar = where(files[ii]->land(lstep,:,:) .eq. 1.0, avar@_FillValue, avar)
  ;      avar = where(files[ii]->icec(lstep,:,:) .lt. icemin, avar@_FillValue, avar)
  ;      avar = where(files[ii]->icec(lstep,:,:) .ge. icemin, avar, avar@_FillValue)
  avar@lon2d = files[ii]->$tlonname$*rfactor
  avar@lat2d = files[ii]->$tlatname$*rfactor
  ovar@lon2d = files[ii]->$tlonname$*rfactor
  ovar@lat2d = files[ii]->$tlatname$*rfactor
  ;res@gsnCenterString  = rts(ii)+" ai>icemin"
  res@gsnCenterString  = rts(ii)
  plot(ii) = subplot(ii,aname,avar(:,:),pltlevs,colormap,hemi)
 oplot(ii) = gsn_csm_contour(wks,ovar(:,:),ores)             ; create the plot
 overlay(plot(ii),oplot(ii))

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
