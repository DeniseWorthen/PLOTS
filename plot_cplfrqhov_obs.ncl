begin
 ; one of two dates
 run2plt = 0

  runsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/CplFrq/"
 
  cdates = (/"201301","201307"/)
 runames = (/"20130121:20130125 mean", "20130721:20130725 mean"/)
 ;runlabs = (/"slowfast1 : cpl_slow =3600; dt_therm = 3600; dt = 900; cpl_fast=dt_atmos=dt_cice=450", \
 ;            "slowfast2 : cpl_slow = 900; dt_therm = 3600; dt = 900; cpl_fast=dt_atmos=dt_cice=450", \
 ;            "slowfast3 : cpl_slow = 900; dt_therm =  900; dt = 900; cpl_fast=dt_atmos=dt_cice=450", \
 ;            "benchmark : cpl_slow=cplfast=1800; dt_atmos=450; dt_cice=900; dt_therm=3600; dt_900"/)
 runlabs = (/"slowfast1",\
             "slowfast2",\
             "slowfast3",\
             "benchmark"/)
 print(runlabs)

  obsf=addfiles(runsrc+"oisst."+cdates+".nc","r")
  obs1=dim_avg_Wrap(obsf[run2plt]->sst)

  ndata = 4
  file_sf1=addfiles(runsrc+"slowfast1_25d_"+cdates+"0100/SST.025deg.nc","r")
  file_sf2=addfiles(runsrc+"slowfast2_25d_"+cdates+"0100/SST.025deg.nc","r")
  file_sf3=addfiles(runsrc+"slowfast3_25d_"+cdates+"0100/SST.025deg.nc","r")
  file_bv2=addfiles(runsrc+  "benchv2_25d_"+cdates+"0100/SST.025deg.nc","r")
  ;print(file_sf1)
  
  sf1=dim_avg_Wrap(file_sf1[run2plt]->sst)
  sf2=dim_avg_Wrap(file_sf2[run2plt]->sst)
  sf3=dim_avg_Wrap(file_sf3[run2plt]->sst)
  bv2=dim_avg_Wrap(file_bv2[run2plt]->sst)
   dims = dimsizes(sf1)
  ntime = dims(0)
  nlats = dims(1)
  print("ntime = "+ntime+" nlats = "+nlats)
  ;printVarSummary(sf1)
  ;print(nlats)

  sf1 = sf1-obs1
  sf2 = sf2-obs1
  sf3 = sf3-obs1
  bv2 = bv2-obs1

  sf1@units=" "
  sf1@long_name=" "
  sf2@units=" "
  sf2@long_name=" "
  sf3@units=" "
  sf3@long_name=" "
  bv2@units=" "
  bv2@long_name=" "

  levs=(/-1.,1.,.1/)

;************************************************
;
;************************************************

  wkstype = "X11"
  wks =  gsn_open_wks(wkstype, "test")

  npanels=ndata
  plot = new(npanels,graphic)

  res = True
 
  res@vpWidthF         = 0.8                      ; set width and height
  res@vpHeightF        = 0.3

  res@gsnDraw  = False
  res@gsnFrame = False
  res@gsnPaperOrientation = "auto"

  res@cnFillOn         = True                ; color on
  res@lbLabelStride    = 2                   ; every other label
  res@lbOrientation    = "Vertical"          ; vertical label bar
  res@cnLinesOn        = False               ; turn off contour lines
  res@cnLineLabelsOn   = False             
  res@cnInfoLabelOn    = False                
  res@cnFillPalette    = "BlueWhiteOrangeRed"    ; set color map

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tmXBLabelStride  = 2                   ; tick mark label stride
  res@tiYAxisString    = "days since "+cdates(run2plt)              ; y axis title

  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  latmin=-60.0
  latmax= 60.0
;************************************************
;
;************************************************

  ii = 0
  res@gsnCenterString = runlabs(ii)+" - OISST"
  plot(ii) = gsn_csm_time_lat (wks,sf1(:,{latmin:latmax}),res) ; create plot

  ii = 1
  res@gsnCenterString = runlabs(ii)+" - OISST"
  plot(ii) = gsn_csm_time_lat (wks,sf2(:,{latmin:latmax}),res) ; create plot

  ii = 2
  res@gsnCenterString = runlabs(ii)+" - OISST"
  plot(ii) = gsn_csm_time_lat (wks,sf3(:,{latmin:latmax}),res) ; create plot

  ii = 3
  res@gsnCenterString = runlabs(ii)+" - OISST"
  plot(ii) = gsn_csm_time_lat (wks,bv2(:,{latmin:latmax}),res) ; create plot

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  resP@gsnPanelLabelBar    = True                ; add common colorbar

  gsn_panel(wks,plot,(/npanels,1/),resP)               ; now draw as one plot

;************************************************
;
;************************************************

end
  
