;*************************************************
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ; latent head evap J/kg
  lhvap = 2.501e6

  forcingname = "CFSR"
      runname = "cfsr"
  ;forcingname = "GEFS"
  ;    runname = "gefs"
  rtsrc= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/DATM/plots_sync/tmp/cpld_datm_mom6_cice5_2d_"+runname+"/"
  
  datmflds = (/"inst_zonal_wind_height_lowest", \
               "inst_merid_wind_height_lowest", \
               "mean_down_sw_vis_dir_flx",  \
               "mean_down_lw_flx",          \
               "inst_temp_height_lowest",   \
               "inst_spec_humid_height_lowest", \
               "mean_prec_rate",            \
               "mean_fprec_rate"            \
              /)

  datmwgts = (/1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0e3, \
               3600.0, \
               3600.0/)

  nflds = dimsizes(datmflds)

  iceflds = (/"inst_zonal_wind_height_lowest",      \
              "inst_merid_wind_height_lowest",      \
              "mean_down_sw_vis_dir_flx",   \
              "mean_down_lw_flx",           \
              "inst_temp_height_lowest",        \
              "inst_spec_humid_height_lowest",             \
              "mean_prec_rate",             \
              "mean_fprec_rate"             \
              /)

  ; ice has sign changes relative to atm export
  icewgts = (/ 1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0e3, \
              3600.0, \
              3600.0/)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -5.00,    5.00,  0.500/)   ; uwind
  plotlevs( 1,:) = (/  -5.00,    5.00,  0.500/)   ; vwind
  plotlevs( 2,:) = (/   0.00,  100.00,  5.000/)   ; visible direct
  plotlevs( 3,:) = (/ 100.00,  400.00, 20.000/)   ; down lw
  plotlevs( 4,:) = (/ 240.00,  280.00,  2.000/)   ; tlowest (K) 
  plotlevs( 5,:) = (/   0.00,    4.00,  0.200/)   ; qlowest (kg/kg)
  plotlevs( 6,:) = (/   0.00,    1.00,  0.050/)     ; lprec*3600 mm/hr
  plotlevs( 7,:) = (/   0.00,    0.20,  0.010/)     ; fprec*3600 mm/hr

  cmap="BlueWhiteOrangeRed"

;************************************************
; time step
;************************************************

  lstep = 1-1
  year="2011"
  month="10"
  day="01"
  hour="03"
  timestamp = year+"-"+month+"-"+day+"T"+hour+":00:00"
       date = year+month+day+hour
  
    atmexp="field_atm_exporta_"+timestamp
    iceimp="field_ice_import_"+timestamp
  print(atmexp)
  print(iceimp)

  ; atm grid coords in mediator
  gmedx_a = addfile(rtsrc+"atmlonc.nc","r")
  gmedy_a = addfile(rtsrc+"atmlatc.nc","r")
  ; atm coords
  atmlon=gmedx_a->atmlonc
  atmlat=gmedy_a->atmlatc

  ; ice grid coords in iceiator
  gicex_i = addfile(rtsrc+"array_med_ice_grid_coord1.nc","r")
  gicey_i = addfile(rtsrc+"array_med_ice_grid_coord2.nc","r")
  ; atm coords
  icelon=gicex_i->lon_center
  icelat=gicey_i->lat_center

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 7
       levs = plotlevs(fldtoplot,:)
   ifldname =  iceflds(fldtoplot)
   dfldname = datmflds(fldtoplot)
   wkstitle = runname+"_"+dfldname+"_"+date
  ; special settings
  awgt = datmwgts(fldtoplot)
  iwgt =  icewgts(fldtoplot)

  ; ice import
   fice = addfile(rtsrc+iceimp+".nc","r")
   aice = fice->$ifldname$(lstep,:,:)
   aice = iwgt*aice
  if(ifldname .eq. "mean_prec_rate" .or. ifldname .eq. "mean_fprec_rate")then   ; make levels easier
     aice@units = "mm/hr"
  end if
   aice@lat2d=icelat
   aice@lon2d=icelon

  ; field exported by datm
   fexp = addfile(rtsrc+atmexp+".nc","r")
   aexp = fexp->$dfldname$(lstep,:,:)
   aexp = awgt*aexp
   aexp@lat2d=atmlat
   aexp@lon2d=atmlon

;************************************************
; create plot
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file
  plot = new(4,graphic)

  res            = True                          ; plot mods desired
  res@mpFillOn   = False
  res@cnFillMode = "MeshFill"

  res@gsnDraw = False
  res@gsnFrame = False

  res@cnFillDrawOrder    = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn      = False                 ; turn off individual cb's

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@tiMainFontHeightF    = 0.015
  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterStringOrthogonalPosF = .15

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,hemi,lat0,lon0)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

    res@gsnPolar   =  hemi                         ; specify the hemisphere
    res@mpCenterLonF = lon0
   if(hemi .eq. "NH")then
    res@mpMinLatF    = lat0                       ; minimum lat to plot
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = lat0                           ; minimum lat to plot
   end if

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   delete(res@mpMinLatF)
   delete(res@mpMaxLatF)
  return(splot)
end

; ***************************************************
;
; ***************************************************

    hemi = "NH"
  minlat =  66.0
  midlon = -45.0
 
   if(iwgt .ne. 1.0)then
    pltlab = "ice_import: "+ifldname+" (weighted by "+iwgt+")"
   else
    pltlab = "ice_import: "+ifldname
   end if
    ii = 0
   plot(ii) = subplot(ii,pltlab,aice,levs,cmap,hemi,minlat,midlon)

   pltlab = "DATM export"
    ii = 1
   plot(ii) = subplot(ii,pltlab,aexp,levs,cmap,hemi,minlat,midlon)


  pltlab = ""
    hemi = "SH"
  maxlat = -50.0
  midlon =   0.0
  ii = 2
  plot(ii) = subplot(ii,pltlab,aice,levs,cmap,hemi,maxlat,midlon)
  ii = 3
  plot(ii) = subplot(ii,pltlab,aexp,levs,cmap,hemi,maxlat,midlon)


;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0

  resP@gsnMaximize           = True              ; maximize in frame
  resP@gsnFrame              = False             ; don't advance frame yet
  resP@gsnPanelLabelBar      = True              ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = timestamp

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   print(imcmd)
   system(imcmd)
  end if

exit
end
