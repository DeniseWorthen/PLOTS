	; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ;MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WW3_input_data_20220624/"
  ;scrpfile   = "no_land_CardDeck.SCRIP.nc"

  ;MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_wavunstr/moddefs/"
  ;scrpfile   = "trip15minmask_dd.SCRIP.nc"
  ;scrpfile   = "trip1degmask_dd.SCRIP.nc"

  ;MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/addunstr.2acd891b.ww.33d337356/moddefs/"
  MD = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/moddefs/"

  scrpfile = "trip1degmask.SCRIP.nc"
  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

  ; cheyenne
  RT1 = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/"
  ; hera
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_wavunstr/"
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/addunstr.2acd891b.ww.33d337356/"

  gridtype  = (/"unstructured","unstructured"/)
   plotlabs = (/"unstr 30deg 5PE"  , "unstr 1deg 20PE"/)
        rts = (/"CPLD/base/", "CPLD/mpi/"/)

  date = "2021-03-22-"
  time = "24480"
  fsrc = "ufs.cpld.cpl.hi.wav."

  fnames = RT1+rts+fsrc+date+time+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"wavImp_Sw_z0" ,  \
           "wavExp_Sa_u10m", \
           "wavExp_Sa_v10m", \
           "wavImp_Sw_pstokes_x2", \
           "wavImp_Sw_pstokes_y2"/)

  fldwgts = (/1.0e3, \
              1., \
              1., \
              1.0e15, \
              1.0e6/)

  lonname = "wavImp_lon"
  latname = "wavImp_lat"

  nflds = dimsizes(flds)
  nplots = 1

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.5,    0.5,  0.01/)   ; z0
  plotlevs( 1,:) = (/ -20.0,   20.0,  0.50/)   ; u10m
  plotlevs( 2,:) = (/ -20.0,   20.0,  0.50/)   ; v10m
  plotlevs( 3,:) = (/  -2.0,    2.0,  0.02/)   ; stokes_x2
  plotlevs( 4,:) = (/  -1.0,    1.0,  0.01/)   ; stokes_y2

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 3
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time
  ;wkstitle = plotlabs(0)

   cmap = "BlueWhiteOrangeRed"
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
  plot = new(nplots,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  ;res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label

  ;res@mpFillOn           = False
  ;res@mpOutlineOn        = False
   ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,gtype,pltvar,pltlevs,palette)
begin
  res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
  res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
  res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
  res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  res@cnFillPalette        = palette

  if (gtype .eq. "unstructured") then
    res@sfXCellBounds = cx(:,0:5)
    res@sfYCellBounds = cy(:,0:5)
  end if

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
  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

; ***************************************************
;
; ***************************************************

     ii = 0
          vname = flds(fldtoplot)
          gtype = gridtype(ii)
          if (gtype .eq. "structured")then
           data = files[1]->$vname$(0,:,:) - files[0]->$vname$(0,:,:)
         else
           data = files[1]->$vname$(0,0,:) - files[0]->$vname$(0,0,:)
           data@lon1d = files[0]->$lonname$(0,0,:)
           data@lat1d = files[0]->$latname$(0,0,:)
         end if
         data = data*wgt

          plot(ii) = subplot(ii,plotlabs(1)+"-"+plotlabs(0),gtype,data,levs,cmap)
        delete(data)

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
