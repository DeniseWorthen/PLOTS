; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/WaveUnstr/"

 plotlabs = (/"Unstr no land CardDeck","Unstr land DD"/)
      rts = (/"unstr_noland2/","pdlib5PE/"/)

  date = "2021-03-22-23760"
  files1 = addfile(RT1+rts(0)+"ufs.atmw.ww3.hi."+date+".nc","r")
  files2 = addfile(RT1+rts(1)+"ufs.atmw.ww3.hi."+date+".nc","r")

  flds = (/"HS"/)
  nflds = dimsizes(flds)

  ; easier plots
  ;fldwgts = (/1.e3/)
  fldwgts = (/1./)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    0.5,  0.01/)   ; z0

  ;cmap="BlueWhiteOrangeRed"
  cmap = "NCV_jet"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
        wgt = fldwgts(fldtoplot)
   wkstitle = flds(fldtoplot)+"_"+date
   ;wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
   ;plottitle="Exported "+flds(fldtoplot)+"(*"+sprintf("%5.0e", wgt)+")"
   plottitle=flds(fldtoplot)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@cnInfoLabelOn      = False           ; turn off cn info label

  res@mpFillOn           = True
  res@mpOutlineOn        = False

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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

   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

  res@gsnCenterStringFontHeightF      = 0.010
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

  ii = 0
  name = flds(fldtoplot)
  f1 = files1->$name$(0,0,:)
  f1@lon1d = files1->lon(0,:)
  f1@lat1d = files1->lat(0,:)
  ;printVarSummary(files1->lat)
  plot(ii) = subplot(ii,plotlabs(ii),f1,levs,cmap)

  ii = 1
  f2 = files2->$name$(0,0,:)
  f2@lon1d = files2->lon(0,:)
  f2@lat1d = files2->lat(0,:)
  plot(ii) = subplot(ii,plotlabs(ii),f2,levs,cmap)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,1/),resP)
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
