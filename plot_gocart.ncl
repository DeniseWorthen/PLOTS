; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
begin
;************************************************
;
;************************************************

  RT = "/glade/scratch/worthen/FV3_RT/rt_72621/cpld_control_p8/"
  date = "20210323_0600z"
;************************************************
;
;************************************************

  f = addfile(RT+"gocart.inst_aod."+date+".nc4","r")

  varname = "AOD"
  data = f->$varname$(0,:,:)
  levs = (/0.0,2.0,0.02/)

  plottitle="test"
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="gocart"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  nplots= 1
   plot = new(nplots,graphic)
    dum = new(nplots,graphic)

  res            = True                          ; plot mods desired
  ;res@gsnPolar   =  "NH"                         ; specify the hemisphere
  ;res@mpProjection = "Satellite"
  res@mpFillOn             = False
  res@mpOutlineOn          = True

  ;res@mpMinLatF            =  minlat     ; range to zoom in on
  ;res@mpMaxLatF            =  maxlat
  ;res@mpMinLonF            =  minlon
  ;res@mpMaxLonF            =  maxlon
  ;res@mpCenterLatF         =  (maxlat - minlat)*0.50
  ;res@mpCenterLatF         =  -90.0
  ;res@mpCenterLonF         = -45.0
  ;res@mpLimitMode          = "LatLon"
  ;res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
  ;res@mpGridAndLimbOn       = True         ; turn on lat/lon lines

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@tiMainFontHeightF = .01
  res@gsnStringFontHeightF = 0.015

  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  ;res@cnFillDrawOrder      = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette               = "WhiteBlueGreenYellowRed"             ; choose colormap
; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
;  resP@gsnPanelYWhiteSpacePercent = 10
;  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  ;resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

;************************************************
;
;************************************************

  ii=0
  plot(ii) = gsn_csm_contour_map(wks,data,res)    ; create the plot

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,1/),resP)
  ;gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
