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

 ; hemi = "NH"
 ; hemi = "SH"
  hemi = "none"

 rad2deg=180.d0/acos(-1.0d0)
  icemin=1.0e-6


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

 cyear="2012"
  cmon="10"

  ;model = "phyf000:07:30."
  ;model = "phyf000:15:00."
  ;model = "phyf006:00:00."
  ;model = "phyf045:00:00."
  model = "phyf240."
 tlonname = "grid_xt"
 tlatname = "grid_yt"

      rts = (/"S2S_tod/"+cyear+"_10d","S2S_fv3stab/"+cyear+"_35d"/)
     cset = "/tmp/cpld_fv3_384_mom6_cice_5d_"+cyear+cmon+"0100/"

  files=addfiles(RT4+rts+cset+model+tile+".nc","r")

  tilecorners = tilegrid(files[0]->$tlonname$*rad2deg,files[0]->$tlatname$*rad2deg,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
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

  plottitle=tile

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,tile)              ; send graphics to X11 window

  plot = new(2,graphic)
   dum = new(2,graphic)

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

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020

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

  ;print(pltlevs)
  ;print(palette)
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")
  resP@gsnPanelMainString = plottitle

;************************************************
;
;************************************************

   ;colormap = "amwg"
   colormap = "MPL_rainbow"

        ii = 0
   ;  vname = "icec"
   ;pltlevs = (/0.7,1.0,0.02/)
     vname = "tmpsfc"
  ; pltlevs = (/-2.0,0.0,0.1/)
   pltlevs = (/-20.,20.0,1.0/)
  res@gsnCenterString  = vname
  ;ivar = files[0]->$vname$(lstep,:,:)
  ivar = (files[0]->$vname$(lstep,:,:)) - 273.15
  ;ivar = where(files[0]->land(lstep,:,:) .eq. 1.0, ivar@_FillValue, ivar)
  ivar@lon2d = files[0]->$tlonname$*rad2deg
  ivar@lat2d = files[0]->$tlatname$*rad2deg
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap,hemi)
  delete(ivar)

        ii = 1
     vname = "ulwrf"
 ;  pltlevs = (/300,322,1/)
   pltlevs = (/200,500,10/)
  res@gsnCenterString  = vname
  ivar = files[0]->$vname$(lstep,:,:) 
  ;ivar = (files[0]->$vname$(lstep,:,:)) - 273.15
  ;ivar = where(files[0]->land(lstep,:,:) .eq. 1.0, ivar@_FillValue, ivar)
  ;ivar = where(files[0]->icec(lstep,:,:) .lt. icemin, ivar@_FillValue, ivar)
  ivar@lon2d = files[0]->$tlonname$*rad2deg
  ivar@lat2d = files[0]->$tlatname$*rad2deg
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap,hemi)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)
exit
end
