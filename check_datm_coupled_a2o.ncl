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
  rtsrc= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/DATM/rtgen.127255/tmp/cpld_datm_mom6_cice5_2d_"+runname+"/"
  
  datmflds = (/"mean_zonal_moment_flx_atm", \
               "mean_merid_moment_flx_atm", \
               "mean_down_sw_vis_dir_flx",  \
               "mean_net_lw_flx",          \
               "mean_sensi_heat_flx",       \
               "mean_laten_heat_flx",       \
               "mean_prec_rate",            \
               "mean_fprec_rate"            \
              /)

  datmwgts = (/1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0, \
               3600.0, \
               3600.0/)

  nflds = dimsizes(datmflds)

  ocnflds = (/"mean_zonal_moment_flx",      \
              "mean_merid_moment_flx",      \
              "mean_net_sw_vis_dir_flx",    \
              "mean_net_lw_flx",            \
              "mean_sensi_heat_flx",        \
              "mean_evap_heat_flx",         \
              "mean_prec_rate",             \
              "mean_fprec_rate"             \
              /)

  ; ocn has sign changes relative to atm export
  ocnwgts = (/-1.0, \
              -1.0, \
               1.0, \
              -1.0, \
              -1.0, \
              -1.0*lhvap, \
              3600.0, \
              3600.0/)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.00,    1.00,  0.050/)   ; dusfc
  plotlevs( 1,:) = (/  -1.00,    1.00,  0.050/)   ; dvsfc
  plotlevs( 2,:) = (/   0.00, 1000.00, 20.000/)   ; visible direct
  plotlevs( 3,:) = (/-200.00,  200.00, 10.000/)   ; net lw
  plotlevs( 4,:) = (/-120.00,  120.00, 10.000/)   ; latent (evap to ocean converted)
  plotlevs( 5,:) = (/ -20.00,  300.00, 10.000/)   ; sensible
  plotlevs( 6,:) = (/   0.00,    1.00,  0.050/)     ; lprec*3600 mm/hr
  plotlevs( 7,:) = (/   0.00,    0.10,  0.005/)     ; fprec*3600 mm/hr

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
    ocnimp="field_ocn_import_"+timestamp
  print(atmexp)
  print(ocnimp)

  ; atm grid coords in mediator
  gmedx_a = addfile(rtsrc+"atmlonc.nc","r")
  gmedy_a = addfile(rtsrc+"atmlatc.nc","r")
  ; atm coords
  atmlon=gmedx_a->atmlonc
  atmlat=gmedy_a->atmlatc

  ; ocn grid coords in ocniator
  gocnx_o = addfile(rtsrc+"array_med_ocn_grid_coord1.nc","r")
  gocny_o = addfile(rtsrc+"array_med_ocn_grid_coord2.nc","r")
  ; atm coords
  ocnlon=gocnx_o->lon_center
  ocnlat=gocny_o->lat_center

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 7
       levs = plotlevs(fldtoplot,:)
   ofldname =  ocnflds(fldtoplot)
   dfldname = datmflds(fldtoplot)
   wkstitle = runname+"_"+dfldname+"_"+date
 
  ; special settings
  awgt = datmwgts(fldtoplot)
  owgt =  ocnwgts(fldtoplot)

  ; ocn import
   focn = addfile(rtsrc+ocnimp+".nc","r")
   aocn = focn->$ofldname$(lstep,:,:)
   aocn = owgt*aocn
  if(ofldname .eq. "mean_prec_rate" .or. ofldname .eq. "mean_fprec_rate")then   ; make levels easier
     aocn@units = "mm/hr"
  end if
  if(ofldname .eq. "mean_evap_rate" )
     aocn@units = "W/m2"
  end if
   aocn@lat2d=ocnlat
   aocn@lon2d=ocnlon

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
  plot = new(2,graphic)

  res            = True                          ; plot mods desired
  ;res@gsnPolar   = "NH"                          ; specify the hemisphere
  ;res@mpMinLatF  = 45                            ; minimum lat to plot
  ;res@mpMinLatF  = 85                            ; minimum lat to plot
  ;res@mpMinLatF  = 66                            ; minimum lat to plot
  res@mpFillOn   = False
  res@cnFillMode = "MeshFill"

  res@gsnDraw = False
  res@gsnFrame = False
  ;res@gsnMaximize=True

  res@cnFillDrawOrder    = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  ;res@cnLevelSpacingF   = 3.                    ; interval spacing
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

   if(owgt .ne. 1.0)then
    res@gsnCenterString = "ocn_import: "+ofldname+" (weighted by "+owgt+")"
   else
    res@gsnCenterString = "ocn_import: "+ofldname
   end if
  plot(0) = gsn_csm_contour_map(wks,aocn,res)    ; create the plot

   res@gsnCenterString = "DATM export"
  plot(1) = gsn_csm_contour_map(wks,aexp,res)    ; create the plot

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

  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

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

end
