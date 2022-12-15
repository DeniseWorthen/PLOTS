; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************
  ;RT = "/work/noaa/stmp/dworthen/stmp/dworthen/FV3_RT/rt_88781/"
  RT = "/work/noaa/stmp/dworthen/stmp/dworthen/"

 plotlabs = (/"HAFS"/)
      rts = (/"./"/)

  date = "2022-09-22-43200"
  ;date = "2019-08-29-14400"
  ; coupler fields
  flds = (/"atmImp_Sa_t2m"/)
  files1 = addfile(RT+rts(0)+"ufs.hafs.cpl.hi.atm."+date+".2d.nc","r")
  ;files1 = addfile("test.nc","r")
  print("using "+RT+rts(0)+"ufs.hafs.cpl.hi.atm."+date+".2d.nc")
  nflds = dimsizes(flds)

  ; easier plots
  ;fldwgts = (/1.e3/)
  fldwgts = (/1./)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/   0.0,    0.5,  0.01/)   ; z0
  plotlevs( 0,:) = (/   273.0,  310.0,  1.0/)   ; t2m in K

  ;cmap="BlueWhiteOrangeRed"
  cmap = "amwg"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
        wgt = fldwgts(fldtoplot)
   ;wkstitle = flds(fldtoplot)+"_"+date
   wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
   plottitle="Exported "+flds(fldtoplot)+"(*"+sprintf("%5.0e", wgt)+")"
   ;plottitle=plotlabs(0)

;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(1,graphic)
  oplot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@cnInfoLabelOn       = False           ; turn off cn info label

 res@vpWidthF          = 0.70
 res@vpHeightF         = 0.40

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

   res@mpMinLatF      = min(pltvar@lat2d)   ; zoom in on lat/lon area
   res@mpMaxLatF      = max(pltvar@lat2d)
   res@mpMinLonF      = min(pltvar@lon2d)
   res@mpMaxLonF      = max(pltvar@lon2d)
   res@mpCenterLonF   = min(pltvar@lon2d)+ (max(pltvar@lon2d) - min(pltvar@lon2d))/2.0
   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
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
  resP@gsnPanelLabelBar      = True                  ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True                   ; use full page

  resP@gsnPanelFigureStrings = (/date,date/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.01
; ***************************************************
;
; ***************************************************

  idel=3
  jdel=3
  ii = 0
  name = flds(fldtoplot)
  ;f1 = files1->$name$(0,:,:)
  f1 = files1->$name$(::idel,::jdel)
  f1@lon2d = files1->grid_xt(::idel,::jdel)
  f1@lat2d = files1->grid_yt(::idel,::jdel)
  ;printVarSummary(f1)

  plot(ii) = subplot(ii,"",f1,levs,cmap)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,1/),resP)
  ;gsn_panel(wks,plot,(/1,1/),resP)

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
