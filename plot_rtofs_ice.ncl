;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  hemi="NH"

; change the min lat for polar projection
; ijskp reads in every x lat,lon value to make it plot faster

  ;minlat = 66.0
  ; ijskp = 3
  minlat = 84.0
   ijskp = 1

  ;hemi="SH"
  ;maxlat = -50.0

begin
;************************************************
;
;************************************************

  Dates2Plt = (/"2019-08-26"/)

  ;Dates2Plt = (/"2019-08-19", "2019-08-20" \
  ;             ,"2019-08-21", "2019-08-22" \
  ;             ,"2019-08-23", "2019-08-24" \
  ;             ,"2019-08-25", "2019-08-26" \
  ;             /)

   ndates = dimsizes(Dates2Plt)

;************************************************
; a list of the files
;************************************************

     rtsrc = "/scratch3/NCEPDEV/marine/noscrub/Zulema.Garraffo/rtofs/hycom/data/data_2019081700/"
; only used for window title
   runname = "GRTOFS"

; set the file name and the variable in the file
  filelist = rtsrc+"cice_inst."+Dates2Plt+"-00000.nc"
  icelonname = "TLON"
  icelatname = "TLAT"
    timename = "time"
   aicename = "aice"

  ;filelist = rtsrc+"archv.2019_238_00_surf.nc"
  ;icelonname = "Longitude"
  ;icelatname = "Latitude"
  ;  timename = "MT"
  ;  aicename = "ice_coverage"

  icefiles = addfiles(filelist,"r")

; contour levels (min,max,delta)
      levs = (/0.0,1.0,0.05/)

;************************************************
;
;************************************************

; read variable with skipping set
       varname = aicename
        icevar = icefiles[:]->$varname$(:,::ijskp,::ijskp)
  icevar@lon2d = icefiles[0]->$icelonname$(::ijskp,::ijskp)
  icevar@lat2d = icefiles[0]->$icelatname$(::ijskp,::ijskp)
  icevar@long_name=""
  icevar@units=""
  ;printVarSummary(icevar)

; Get the time axis
  times = icefiles[:]->$timename$
  timeUnits = icefiles[:]->$timename$@units
  timeCalendar = icefiles[:]->$timename$@calendar

  plottitle = runname
   wkstitle = runname

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=74.12
  lon2=-105.88
  lat1=60
  lat2=60

;************************************************
; define the map
;************************************************

   wkstype="X11"
  ; wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ; a max of ndates panels, not all used
  npanels = ndates

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@mpFillOn             = True

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False
  
  res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
  res@cnMinLevelValF       = levs(0)            ; set the minimum contour level
  res@cnMaxLevelValF       = levs(1)            ; set the maximum contour level
  res@cnLevelSpacingF      = levs(2)            ; set the interval between contours

  res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
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
; uncomment this line to add dotted line along the seam 
  ;  dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@txFontHeightF = .01
  ;resP@txString = runname+"  "+labelstring
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

; for making only 1 date
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot
; if Dates2Plt > 1, then set this big enough
; eg, if 4 dates use /2,2/ for 2 across, 2 down
  ;gsn_panel(wks,plot,(/3,3/),resP)               ; now draw as one plot

exit
end
