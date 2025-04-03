; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

  RT = "/work2/noaa/stmp/dworthen/stmp/dworthen/maskchange/"
  plotlabs = (/"base",   \
               "mask"/)

 ;     rts = (/"base/cpld_control_pdlib_p8_intel/", \
 ;             "mask/cpld_control_pdlib_p8_intel/"/)

      rts = (/"base/cpld_control_gfsv17_intel/", \
              "mask/cpld_control_gfsv17_intel/"/)

  fnames = RT+rts+plotlabs+".hi.ice.nc"
  print(fnames)
  files=addfiles(fnames,"r")

  flds = (/"iceExp_Sa_tbot" /)

  fldwgts = 1.0
  ;fldwgts = (/1.0e11, \
  ;            1., \
  ;            1./)

  nflds = dimsizes(flds)
  nplots = dimsizes(plotlabs)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.2,    0.2,  0.02/)   ; Sa_tbot
 ; plotlevs( 1,:) = (/ -20.0,   20.0,  0.50/)   ; u10m
 ; plotlevs( 2,:) = (/ -20.0,   20.0,  0.50/)   ; v10m

  maskvar = files[0]->iceImp_Si_imask(0,:,:)
  printVarSummary(maskvar)

;************************************************
;
;************************************************

  ; pick a field to plot
  lstep=5-1
  fldtoplot = 0
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)
  ;wkstitle = plotlabs(0)

   times=files[0]->time
   cmap = "BlueWhiteOrangeRed"
   ;cmap = "WhiteBlueGreenYellowRed"
   plottitle=flds(fldtoplot)

;************************************************
; define the map
;************************************************

  wkstype="X11"
						; wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)       ; send graphics to X11 window
  ; drawNDCGrid(wks)
  plot = new(1,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label

  ;res@mpFillOn           = False
  ;res@mpOutlineOn        = False
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

  res@gsnCenterStringFontHeightF      = 0.012
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  pltvar@units = ""
  pltvar@long_name = ""
  splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot

  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 1.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnLinesOn        = True
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ;ores@cnLevelSelectionMode = "ManualLevels"
  ;ores@cnLevels         = (/1,6,1/)
  ;ores@cnFillPatterns   = (/17,17,17,17/)
; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D%H%M%S")
  ;resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

; ***************************************************
;
; ***************************************************


  ii = 0
  vname = flds(fldtoplot)
  data = where(maskvar .eq. 1.0, files[0]->$vname$(lstep,:,:)-files[1]->$vname$(lstep,:,:), maskvar@_FillValue)
  ;data = abs(data)*wgt
  ;data@lon1d = files[0]->$lonname$(0,0,:)
  ;data@lat1d = files[0]->$latname$(0,0,:)
  plot(ii) = subplot(ii,plotlabs(0)+"-"+plotlabs(1),data,levs,cmap)

;************************************************
; make the panel
;************************************************

   gsn_panel(wks,plot,(/nplots,1/),resP)

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
