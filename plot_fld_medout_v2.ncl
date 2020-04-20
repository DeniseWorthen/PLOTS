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

  rtname = "DATM"
  rtsrc= RT2+rtname+"/rtgen.117935/tmp/cpld_datm_mom6_cice_cold/"

  ;fname="Shtfl"
  ;aname="mean_sensi_heat_flx"
  ;oname="mean_sensi_heat_flx"
  ;levs = (/-100.0,100.0,10.0/)
  ;wgt=1.0

  fname="Vbdsf"
  aname="mean_down_sw_vis_dir_flx"
  oname="mean_net_sw_vis_dir_flx"
  iname="mean_down_sw_vis_dir_flx"
  levs = (/0.0,200.0,20.0/)
  wgt=1.0

  ;fname="Snwrate"
  ;aname="mean_fprec_rate"
  ;oname="mean_fprec_rate"
  ;iname="mean_fprec_rate"
  ;levs = (/0.0,2.0,0.2/)
  ;wgt=1.0e5

  ;fname="mean_prec_rate"
  ;aname="mean_prec_rate"
  ;oname="mean_prec_rate"
  ;iname="mean_prec_rate"
  ;levs = (/0.0,2.0,0.2/)
  ;wgt=1.0e4

  lstep = 1-1
  timestamp = "2011-10-01T00:15:00"

    atmexp="field_atm_exporta_"+timestamp
  medfld_i="field_ice_import_"+timestamp
  medfld_o="field_ocn_import_"+timestamp
  medfld_a="field_med_from_atm_"+timestamp

;************************************************
; med field out to ice or ocn
;************************************************

  ; atm grid coords in mediator
  gmedx_a = addfile(rtsrc+"array_med_atm_grid_coord1.nc","r")
  gmedy_a = addfile(rtsrc+"array_med_atm_grid_coord2.nc","r")
  ; atm coords
  atmlon=gmedx_a->lon_center
  atmlat=gmedy_a->lat_center

  ; ice grid coords in mediator
  gmedx_i = addfile(rtsrc+"array_med_ice_grid_coord1.nc","r")
  gmedy_i = addfile(rtsrc+"array_med_ice_grid_coord2.nc","r")
  ; ice coords
  icelon=gmedx_i->lon_center
  icelat=gmedy_i->lat_center

  ;ocn grid coords in mediator
  gmedx_o = addfile(rtsrc+"array_med_ocn_grid_coord1.nc","r")
  gmedy_o = addfile(rtsrc+"array_med_ocn_grid_coord2.nc","r")
  ; ocn coords
  ocnlon=gmedx_o->lon_center
  ocnlat=gmedy_o->lat_center

  ; field exported by atm
  faexp = addfile(rtsrc+atmexp+".nc","r")
   aexp = faexp->$fname$(lstep,:,:)
   ;aexp = wgt*aexp*0.5
   aexp = wgt*aexp
   aexp@lat2d=atmlat
   aexp@lon2d=atmlon

  ;med field from atm
  ffatm =addfile(rtsrc+medfld_a+".nc","r")
  medfatm=ffatm->$aname$(lstep,:,:)
  ;medfatm=wgt*medfatm*0.5
  medfatm=wgt*medfatm
  medfatm@lat2d=atmlat
  medfatm@lon2d=atmlon

  ;field to ice
  f2ice =addfile(rtsrc+medfld_i+".nc","r")
  med2ice=f2ice->$iname$(lstep,:,:)
  med2ice=wgt*med2ice
  med2ice@lat2d=icelat
  med2ice@lon2d=icelon

  ; field to ocn
  f2ocn =addfile(rtsrc+medfld_o+".nc","r")
  med2ocn=f2ocn->$oname$(lstep,:,:)
  med2ocn=wgt*med2ocn
  med2ocn@lat2d=ocnlat
  med2ocn@lon2d=ocnlon

;************************************************
; create plot
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks = gsn_open_wks(wkstype,"test")              ; send graphics to PNG file
  plot = new(4,graphic)

  res            = True                          ; plot mods desired
  ;res@gsnPolar   = "NH"                          ; specify the hemisphere
  ;res@mpMinLatF  = 45                            ; minimum lat to plot
  ;res@mpMinLatF  = 85                            ; minimum lat to plot
  ;res@mpMinLatF  = 66                            ; minimum lat to plot
  res@mpFillOn   = True
  res@cnFillMode = "MeshFill"

  res@gsnDraw = False
  res@gsnFrame = False
  ;res@gsnMaximize=True

  res@cnFillDrawOrder    = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  ;res@cnLevelSpacingF   = 3.                    ; interval spacing
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  ;res@lbLabelBarOn      = False                 ; turn off individual cb's
  res@lbLabelBarOn       = True                  ; turn off individual cb's

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@mpGreatCircleLinesOn = True
  res@cnFillPalette        = "NCV_jet"              ; choose colormap

  res@tiMainFontHeightF    = 0.015
;************************************************
;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  9            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"
;************************************************

  res@tiMainString = medfld_i+" "+iname
  plot(0) = gsn_csm_contour_map(wks,med2ice,res)    ; create the plot

  res@tiMainString = medfld_o+" "+oname
  plot(1) = gsn_csm_contour_map(wks,med2ocn,res)    ; create the plot

  res@tiMainString = medfld_a+" "+aname
  plot(2) = gsn_csm_contour_map(wks,medfatm,res)    ; create the plot

  res@tiMainString = atmexp+" "+fname
  plot(3) = gsn_csm_contour_map(wks,aexp,res)    ; create the plot

;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  ;resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.007               ; make labels smaller

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

  frame(wks)
end
