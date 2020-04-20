;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  ;load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
  ;stolen from Tobys 6.4 installation
  load "cd_inv_string.ncl"

;************************************************

   hemi = "NH"
   batch = "no"

begin
;************************************************
;
;************************************************

   ;Dates2Plt = (/"20150401"/)
   Dates2Plt = (/"20150401", "20150501", "20150601" \
                ,"20150701", "20150801", "20150901"/)

      ndates = dimsizes(Dates2Plt)
 ; print(Dates2Plt)

;************************************************
; read in netCDF file
;************************************************

    icesrc = "archv."
     rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_eloan/"
     aicename = "ice_coverage" 
       hiname = "ice_thickness" 
   icelonname = "Longitude"
   icelatname = "Latitude"
     timename = "MT"
    
        ijskp = 3
        ;ijskp = 1

;************************************************
; a list of the files
;************************************************

  icefilelist = rtsrc+icesrc+Dates2Plt+"_ice.nc"
  print(icefilelist)
  icedmfiles=addfiles(icefilelist,"r")
  ListSetType(icedmfiles,"cat")

;************************************************
; load an ice field
;************************************************

  ;varname = aicename
  ;levs = (/0.0, 1.0, 0.1/)
  varname = hiname
     levs = (/0.0, 2.0, 0.1/)

         icevar = icedmfiles[:]->$varname$(:,::ijskp,::ijskp)
   icevar@lon2d = icedmfiles[0]->$icelonname$(::ijskp,::ijskp)
   icevar@lat2d = icedmfiles[0]->$icelatname$(::ijskp,::ijskp)
  ;printVarSummary(icevar)
  icevar@units     = ""
  icevar@long_name = ""

  ; Get the time axis 
           times = icedmfiles[:]->$timename$
       timeUnits = icedmfiles[:]->$timename$@units
    timeCalendar = icedmfiles[:]->$timename$@calendar

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  74.12
   lon2=-105.88
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"eloan_"+varname)              ; send graphics to X11 window
  ;gsn_reverse_colormap(wks)

  npanels = ndates
 ; for panels
 if(npanels .le. 4)then
   nrows = 1
   ncols = npanels
 else if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else
    ncols = 4
    nrows = 1+npanels/ncols
 end if
 end if
 print("npanels = "+npanels+" nrows = "+nrows+" ncols = "+ncols)

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@cnFillMode           = "MeshFill"
  ;res@cnFillMode           = "RasterFill"
  res@mpFillOn             = True

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; 
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66                          ; minimum lat to plot
  ; res@mpMinLatF    =  88                          ; minimum lat to plot
  ; res@mpMinLatF    =  80                          ; minimum lat to plot
  ; res@mpMinLatF    =  70                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  ;if(varname .eq. aicename)then
  ; res@cnFillPalette   = "WhBlGrYeRe"             ; choose colormap
  ; res@cnLevelSelectionMode        = "ExplicitLevels"
  ;;res@cnLevels     = (/0.15,0.50,0.7,0.8,0.85,0.9,0.950,0.975/)
  ; res@cnLevels     = (/0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
  ; res@lbLabelAlignment = "BoxCenters"
  ;else
   res@cnFillPalette   = "MPL_rainbow"             ; choose colormap
   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
   res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
   res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ;end if

  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

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
;
;************************************************

  do ii = 0,ndates-1
   res@gsnCenterString = Dates2Plt(ii)
   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.007               ; make labels smaller

  ;resP@txFontHeightF = .01
  ;resP@txString = rtsrc+"  "+varname

 resP@gsnPanelYWhiteSpacePercent = 5
 resP@gsnPanelXWhiteSpacePercent = 5

 ; gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/2,3/),resP)               ; now draw as one plot

;  frame(wks)

exit
end
