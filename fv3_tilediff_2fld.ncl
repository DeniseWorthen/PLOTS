;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

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

 tlonname = "grid_xt"
 tlatname = "grid_yt"

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

  cyear = "2012"
   cmon = "07"
   ;cmon = "10"
   ;cday = "01"
   cday = "02"
  ;cyear = "2016"
  ; cmon = "10"
  ; cday = "05"
  idate = cyear+cmon+"01"+"00"
  ;model = "phyf000:07:30."
  ;model = "phyf000:15:00."
  ;model = "phyf006:00:00."
  ;model = "phyf045:00:00."
  model = "phyf048."

 ; rts = (/"NEMS_hera","NEMS_SM_hera"/)
 ; cset = "/2012070100_1d_inst/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
 ; rts = (/"NEMS_upfv3_fix","NEMS_Shan_fix"/)
 ; rts = (/"NEMS_upfv3_minice","NEMS_jun10"/)
 ; cset = "/2012070100_2d_iiout/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"

   rts = (/"FMC_Testing/NEMS_Shan","FMC_Testing/NEMS_upfv3_2"/)
  cset = "/"+idate+"_2d/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
  files=addfiles(RT1+rts+cset+model+tile+".nc","r")

  tilecorners = tilegrid(files[0]->$tlonname$*rad2deg,files[0]->$tlatname$*rad2deg,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   print(tile)
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

  print(rts(1)+" - "+rts(0))
  plottitle=rts(1)+" - "+rts(0)+": "+model+tile

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"fv3_inst_diff")

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
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

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020     

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

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
 
         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)
    colormap = "BlueDarkRed18"

        ii = 0
     vname = "icec"
  ; pltlevs = (/-.1,.1,.01/)
  ;   vname = "land"
   pltlevs = (/-1,1,.1/)
  res@gsnCenterString  = vname

  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ivar@lon2d = files[0]->$tlonname$*rad2deg
  ivar@lat2d = files[0]->$tlatname$*rad2deg
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap,hemi)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

        ii = 1
   ;  vname = "tmpsfc"
   pltlevs = (/-2,2,.2/)
     vname = "tisfc"
  ; pltlevs = (/-.5,.5,.05/)
  ;   vname = "land"
  ; pltlevs = (/-4,4,1/)

  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  res@gsnCenterString  = vname
  ;avar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ;res@gsnCenterString  = vname+" (ocean only)"
  ;ivar = avar ; copy atts
  ;ivar = where(files[1]->land(lstep,:,:) .eq. 0.0, avar, avar@_FillValue)
  ;ivar = where(files[1]->land(lstep,:,:) .eq. 0.0, files[1]->$vname$(lstep,:,:), 0.0) - \
  ;       where(files[0]->land(lstep,:,:) .eq. 0.0, files[0]->$vname$(lstep,:,:), 0.0)
  ivar@lon2d = files[0]->$tlonname$*rad2deg
  ivar@lat2d = files[0]->$tlatname$*rad2deg
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap,hemi)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)
exit
end
