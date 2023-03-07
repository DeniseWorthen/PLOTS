; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/WaveUnstr2/"

  scrpfile = "trip1degmask.SCRIP.nc"
  MD = "/glade/scratch/worthen/WaveUnstr2/moddefs/"
  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

 plotlabs = (/"Unstr land 2PE"/)
      rts = (/"pdlib2PE/"/)

  date = "2021-03-22-"
  time = "25920"
  fsrc = "ufs.atmw.cpl.hi.wav."

  fname = RT1+rts+fsrc+date+time+".nc"
  fdat = addfile(fname,"r")
  ;flds = (/"wavImp_Sw_z0"/)
  flds = (/"wavExp_Sa_u10m"/)
  ;fldwgts = (/1.e3/)
  fldwgts = (/1.e0/)
  lonname = "wavImp_lon"
  latname = "wavImp_lat"

  nflds = dimsizes(flds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/   0.0,    0.5,  0.005/)   ; z0
  plotlevs( 0,:) = (/   -10.0,   10.,  0.5/)   ; u10

  fdecomp  = addfile(RT1+rts+"emesh.decomp.nc","r")
  decomp = fdecomp->decomp
  decomp@lon1d = fdecomp->coordx
  decomp@lat1d = fdecomp->coordy
  print(fdecomp->coordx(0:9)+"  "+fdecomp->coordy(0:9)+"  "+decomp(0:9))

  if(1 .eq. 0) then
  fdof = addfile(RT1+rts+"dof.wav.nc","r")
  ;print(dofs)
  dof = fdof->dof
  ip                    = dim_pqsort(dof,1)
       var1d = decomp
       var1d_sort       = var1d
       var1d_sort       = var1d(ip)
       decomp            = var1d_sort
  print(fdecomp->coordx(0:9)+"  "+fdecomp->coordy(0:9)+"  "+decomp(0:9))
 end if
;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time
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

  plot = new(1,graphic)
  oplot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@cnInfoLabelOn      = False           ; turn off cn info label
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

  res@cnMissingValFillColor    = "gray70" ; set color for missing areas
  ;res@sfXCellBounds = cx(:,0:5)
  ;res@sfYCellBounds = cy(:,0:5)

  res@gsnCenterStringFontHeightF      = 0.010
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  return(splot)
end
;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 1.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/1,5,1/)
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

  resP@gsnPanelFigureStrings = (/date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.01
; ***************************************************
;
; ***************************************************

      ii = 0
      name = flds(fldtoplot)
      f1 = fdat->$name$(0,0,:)
      f1@lon1d = fdat->$lonname$(0,0,:)
      f1@lat1d = fdat->$latname$(0,0,:)
      f1 = f1*wgt
  print(fdat->$lonname$(0,0,0:9)+"  "+fdat->$latname$(0,0,0:9)+"  "+f1(0:9))

      ;plot(ii) = subplot(ii,plotlabs(ii),f1,levs,cmap)

  ores@cnMissingValFillColor    = "gray70" ; set color for missing areas
  ores@cnFillOn           = True                  ; color fill
  ;    ores@sfXCellBounds = cx(:,0:5)
  ;    ores@sfYCellBounds = cy(:,0:5)
      printVarSummary(decomp)
  print(sfile->grid_corner_lon(9,:)+"  "+sfile->grid_corner_lat(9,:))
      ;oplot(ii) = gsn_csm_contour(wks,decomp,ores)
      ;overlay(plot(ii),oplot(ii))
      plot(ii) = gsn_csm_contour(wks,decomp,ores)

;************************************************
; make the panel
;************************************************

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
