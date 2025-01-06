;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;************************************************
;
;************************************************

   hemi="NH"
   minlat = 76.0
   rad2deg=180.0/acos(-1.0)
   vmag = 0.20
   vthn = 0.015
begin
;************************************************
; read in netCDF file
;************************************************

  rt = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/tripole/"
  dirs = (/"base.mx100/history/", "fix.mx100/history/"/)
  labs = (/"base", "fix"/)

  fname = "iceh.5dm.nc"
  ff = addfiles(rt+dirs+fname,"r")
  print(ff)
  ListSetType(ff,"join")

  ai = ff[:]->aice_h(:,0,:,:)
  ub = ff[:]->uvel_h(:,0,:,:)
  vb = ff[:]->vvel_h(:,0,:,:)
  rotang = ff[:]->ANGLE(:,:,:)
  ;printVarSummary(rotang)
  ;printVarSummary(ub)

  lon2d = ff[0]->ULON(0,:,:)
  lat2d = ff[0]->ULAT(0,:,:)
  ub@lon2d = lon2d
  ub@lat2d = lat2d
  vb@lon2d = lon2d
  vb@lat2d = lat2d

  ;ub = where(ai .gt. 0.15, ub, default_fillvalue(typeof(ub)))
  ;vb = where(ai .gt. 0.15, vb, default_fillvalue(typeof(vb)))
  urot = ub
  vrot = vb
  urot = cos(rotang)*ub - sin(rotang)*vb
  vrot = sin(rotang)*ub + cos(rotang)*vb
  uvmag = urot ; copy metadata
  uvmag = sqrt(urot*urot + vrot*vrot)

  uvdir = urot ; copy metadata
  uvdir = where(uvmag .ge. 0.0, atan2(vrot,urot), default_fillvalue(typeof(ai)))

  diff = urot(0,:,:) ; copy metadata
  diff = uvdir(1,:,:) - uvdir(0,:,:)
  ;levs = (/-1,1,.1/)
  levs = (/-5,5,.5/)

  ;urot = where(urot@lat2d .ge. minlat, urot, 0.0)
  ;vrot = where(vrot@lat2d .ge. minlat, vrot, 0.0)
  ;print("urot min = "+min(urot)+" urot max = "+max(urot))
  ;print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=60.00
   lon2=-120.00
   lat1=60
   lat2=60

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice_uv")              ; send graphics to X11 window

  ;plot = new(1,graphic)
  ;oplot = new(1,graphic)
  plot = new(3,graphic)
  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  ;res@cnFillMode         = "RasterFill"
  res@cnFillMode         = "MeshFill"

  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010
  res@gsnScalarContour  = True                  ; vectors over scalars

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10              ; size of ref vector
  ;res@vcMonoLineArrowColor  = True             ; multiple colors desired
  res@vcMinDistanceF        = vthn              ; thins arrows near pole

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF  = minlat                            ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette        = "NCV_jet"              ; choose colormap
  res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

  res@stMinDistanceF     = 0.03                 ; distance between lines
  res@stMinLineSpacingF  = 0.005

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  ;resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle+"  "+grdfile

  resP@gsnPanelFigureStrings = (/"angle on Ct","-angle on Bu", "angle on Ct","-angle on Bu"/)

;************************************************
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineThicknessF = 4.0            ; line thickness
  ores@cnLineColor      = "green"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ;ores@gsnLeftString    = ""    ; no titles
  ;ores@gsnRightString   = ""
  ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnLevelSelectionMode = "EqualSpacedLevels"     ; set the contour levels with the following 3 resources

;************************************************
;
;************************************************

  ;ii = 0
  ;uvar = urot(ii,:,:)
  ;vvar = vrot(ii,:,:)
  ;plot(ii) = gsn_csm_vector_map_polar(wks,uvar,vvar,res)    ; create the plot
  ;plot(ii) = gsn_csm_streamline_map_polar(wks,uvar,vvar,res)    ; create the plot

  ;ii = 0
  ;uvar = urot(ii,:,:)
  ;vvar = vrot(ii,:,:)
  ;plot(ii) = gsn_csm_vector_map_polar(wks,uvar,vvar,res)    ; create the plot
  ;oplot(ii) = gsn_csm_streamline_map_polar(wks,uvar,vvar,ores)    ; create the plot

  ;overlay(plot(ii),oplot(ii))

 ;ii=0
  ;ii = 2
 ;plot(ii) = gsn_csm_contour_map_polar(wks,diff,res)
  plot(0) = gsn_csm_contour_map_polar(wks,uvdir(0,:,:),res)    ; create the plot
  plot(1) = gsn_csm_contour_map_polar(wks,uvdir(1,:,:),res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/1,1/),resP)
  gsn_panel(wks,plot,(/1,2/),resP)
  ;gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
