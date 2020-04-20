; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

 rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/CplFrq/benchv2_cold_2013010100/tmp/cpld_fv3_384_mom6_cice_cold_atm_flux/"

  tilelist=ispan(1,6,1)
  tiles=sprinti("%01i", tilelist)
  ;print(tiles)

  ;tile = "tile5"
  model = "phyf000."
  aname = "land"

  filelist = rtsrc+model+"tile"+tilelist+".nc"
  afile=addfiles(filelist,"r")

  gfilelist = rtsrc+"grid_spec.tile"+tilelist+".nc"
  gfile=addfiles(gfilelist,"r")

  ntiles=dimsizes(tilelist)
  ;print(ntiles)

  ;afile=addfile(rtsrc+model+tile+".nc","r")
  ;gfile=addfile(rtsrc+"grid_spec."+tile+".nc","r")

  lstep=1-1
  ;avar = afile->$aname$(lstep,:,:)
  ;avar@lon2d = gfile->grid_lont
  ;avar@lat2d = gfile->grid_latt
  ;avar@units=""
  ;avar@long_name=""

  ;lons = gfile->grid_lont
  ;latt = gfile->grid_latt
  ;printVarSummary(latt)

;************************************************
; define the map
;************************************************

  wkstitle="fv3"
  ;wkstype="X11"
  wkstype="png"
  ;wkstype@wkWidth=800
  ;wkstype@wkHeight=800

  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window
 
  ;drawNDCGrid(wks)

   plot = new(1,graphic)
  oplot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@vpWidthF             = 0.5
  ;res@vpHeightF            = 0.5

  res@tiMainFontHeightF = .01
  res@gsnStringFontHeightF = 0.015

  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  res@cnLevels         = (/0.0,1.0/)
  ;res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  ;res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  ;res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@cnInfoLabelOn      = False

  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015
  ;gsn_reverse_colormap(wks)           ; Reverse the color map.

  cmap = read_colormap_file("GMT_gray")
  ;res@cnFillPalette      = cmap(::-1,:)
  ;cmap = read_colormap_file("GMT_relief_oceanonly")
  res@cnFillPalette      = cmap

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.05                     ; font smaller. default big

  xx = 0.5
  yy = 0.5

;************************************************
; resources for overlay
;************************************************

  ores                   = True
  ores@gsnCoordsAsLines  = True
  ores@gsnCoordsAttach   = True
  ores@gsnDraw           = False
  ores@gsnFrame          = False

  ;ores                  = True        ; plot mods desired
  ;ores@cnLineThicknessF = 2.0            ; line thickness
  ;ores@cnLineLabelsOn   = False
  ;ores@cnInfoLabelOn    = False
  ;ores@gsnDraw          = False ; don't draw
  ;ores@gsnFrame         = False ; don't advance frame
  ;ores@gsnLeftString    = ""    ; no titles
  ;ores@gsnRightString   = ""
  ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnLevelSelectionMode = "EqualSpacedLevels"     ; set the contour levels with the following 3 resources

; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  ;resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

;************************************************
;
;************************************************

  ;ii=0
  do ii = 0,ntiles-1
  ;do ii = 0,1
   tilenum=tiles(ii)
   avar = afile[ii]->$aname$(lstep,:,:)
   avar = where(avar .gt. 1.0, 0.0, avar)

   avar@lon2d = gfile[ii]->grid_lont
   avar@lat2d = gfile[ii]->grid_latt
   avar@units=""
   avar@long_name=""
   latt = gfile[ii]->grid_latt
    plot(0) = gsn_csm_contour(wks,avar,res)    ; create the plot
   ;gsn_coordinates(wks,plot(0),avar(::64,::64),ores)
     
;************************************************
; make the panel
;************************************************

   draw(plot)
   ;gsn_panel(wks,plot,(/1,1/),resP)
; page coordinates are normalized. go from 0->1 not 0->8" etc.
   gsn_text_ndc(wks,tilenum,xx,yy,txres)
  frame(wks)
  end do

  do ii = 0,ntiles-1
   tilenum=tiles(ii)
   imcmd = "convert -trim "+wkstitle+".00000"+tilenum+".png "+wkstitle+"_"+tilenum+".jpg"
   system(imcmd)
  end do
exit
end
