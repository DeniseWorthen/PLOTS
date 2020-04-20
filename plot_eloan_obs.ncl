;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

;************************************************

   hemi = "NH"
   ;batch = "no"
   batch = "yes"

begin
;************************************************
;
;************************************************

  cyear = "2015"
   cday = "01"
 if(batch .eq. "no")then
   cmon = "05"
 end if

  cdate = cyear+cmon+cday

;************************************************
; read in netCDF file
;************************************************

       rtsrc1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_eloan/"
     aicename = "ice_coverage" 
   icelonname = "Longitude"
   icelatname = "Latitude"
     timename = "MT"
    
        ijskp = 3
        ;ijskp = 1

      icefile = rtsrc1+"archv."+cyear+cmon+cday+"_ice.nc"
         icef = addfile(icefile,"r") 
      
;************************************************
; read in netCDF file
;************************************************

        rtsrc2 = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/IceData/"
       obsname = "ICEC_P0_L101_GLL0"
    obslonname = "lon_0"
    obslatname = "lat_0"

       obsfile = rtsrc2+"seaice.t00z.5min.grb.grib2."+cyear+"-"+cmon+"-"+cday+".nc"
          obsf = addfile(obsfile,"r") 

   levs = (/0.0, 1.0, 0.1/)
   wkstitle = "eloan"+cdate

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

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window
  ;gsn_reverse_colormap(wks)

  npanels = 2
    ncols = 2
    nrows = 1
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

   lstep = 1-1

   ii = 0
  icevar = icef->$aicename$(lstep,::ijskp,::ijskp)
  icevar@lon2d=icef->$icelonname$(::ijskp,::ijskp)
  icevar@lat2d=icef->$icelatname$(::ijskp,::ijskp)
  icevar@long_name=""
  icevar@units=""
  res@gsnCenterString = "Energy Loan "+aicename
   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   delete(icevar)

   ii = 1
  icevar = obsf->$obsname$(lstep,::ijskp,::ijskp)
  icevar@lon=obsf->$obslonname$(::ijskp)
  icevar@lat=obsf->$obslatname$(::ijskp)
  icevar@long_name=""
  icevar@units=""
  res@gsnCenterString = "Obs "+aicename
   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   delete(icevar)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller
  resP@gsnPanelMainString  = cdate

  ;resP@txFontHeightF = .01
  ;resP@txString = rtsrc+"  "+varname

 resP@gsnPanelYWhiteSpacePercent = 5
 resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot

  if(batch .eq. "yes")then
   imcmd = "convert "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
