;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

 ;batch = "yes"
 batch = "no"

  hemi="NH"

begin
;************************************************
;
;************************************************

  Year = "2012"
 ; Dates2Plt = (/"0115", "0315" \
 ;              ,"0515", "1015" \
 ;              ,"1115", "1215" \
 ;              /)
  Dates2Plt = (/"0101", "0401" \
               /)

  ndates = dimsizes(Dates2Plt)

;************************************************
; read in netCDF file
;************************************************

   rtsrc="/scratch2/NCEPDEV/climate/Denise.Worthen/IceSat/"+Year+"/"
     icelonname="lon"
     icelatname="lat"

     hiname="sea_ice_thickness"
  
;************************************************
; a list of the files
;************************************************

   icefilelist = rtsrc+"RDEFT4_"+Year+Dates2Plt+".nc"
  print(icefilelist)
  icedmfiles=addfiles(icefilelist,"r")
  ListSetType(icedmfiles,"cat")

;************************************************
; load an ice field
;************************************************

   varname = hiname
  ;colormap = "WhBlGrYeRe"
  colormap = "MPL_rainbow"
  ;levs = (/0.0, 3.0, 0.05/)
  levs = (/0.0, 4.0, 0.20/)
  icevar = new((/ndates,448,304/),"float")

  do nd = 0,ndates-1
   icevar(nd,:,:) = icedmfiles[nd]->$varname$(:,:)
  end do
   icevar@lon2d=icedmfiles[0]->$icelonname$
   icevar@lat2d=icedmfiles[0]->$icelatname$
  labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  printVarSummary(icevar)
  ; reset to blank
  icevar@units=""
  icevar@long_name=""

  plottitle=rtsrc+varname
  wkstitle=varname

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ; panel number
  npanels = ndates
 ; for panels
 if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else
    ncols = 3
    nrows = 2
    ;nrows = 1+npanels/ncols
    ;ncols = 1
    ;nrows = ndates
 end if
     plot = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@cnFillMode           = "RasterFill"
  ;res@mpFillOn             = True
  res@mpOutlineOn          = False

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar     =  hemi                        ; specify the hemisphere
  res@mpMinLatF    =  66                          ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

   ;res@cnLevelSelectionMode        = "ExplicitLevels"
   ;res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   ;res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .020        ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  ;res@gsnCenterStringOrthogonalPosF = .15          ; raise the CenterString slightly
  res@gsnCenterStringFontHeightF = 0.040

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
; make plots
;************************************************

  do ii = 0,ndates-1
    ;res@gsnCenterString = Years2Plt(ii)+Dates2Plt(0)
    res@gsnCenterString = Year+Dates2Plt(ii)

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
  end do

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@txFontHeightF = .01
  ;resP@txString = labelstring
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot

;************************************************
;
;************************************************

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
