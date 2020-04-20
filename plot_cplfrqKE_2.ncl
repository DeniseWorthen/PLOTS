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

  ndata = 4
  file_sf1=addfiles(runsrc+"slowfast1_25d_"+cdates+"0100/ocean.stats.fix.nc","r")
  file_sf2=addfiles(runsrc+"slowfast2_25d_"+cdates+"0100/ocean.stats.fix.nc","r")
  file_sf3=addfiles(runsrc+"slowfast3_25d_"+cdates+"0100/ocean.stats.fix.nc","r")
  file_bv2=addfiles(runsrc+  "benchv2_25d_"+cdates+"0100/ocean.stats.fix.nc","r")
  ;print(file_sf1)
  
  sf1=file_sf1[run2plt]->KE/1.0e16
  sf2=file_sf2[run2plt]->KE/1.0e16
  sf3=file_sf3[run2plt]->KE/1.0e16
  bv2=file_bv2[run2plt]->KE/1.0e16
   dims = dimsizes(sf1)
  ntime = dims(0)
  nlayr = dims(1)
  print("ntime = "+ntime+" nlayr = "+nlayr)
  ;printVarSummary(sf1)
  ;print(nlayr)
  depth = file_sf1[run2plt]->Layer
  ;klast = nlayr-1
  ;upper 2000m
  klast = 65
  ;upper 200m
  ;klast = 39
  print(depth)
  time = file_sf1[run2plt]->Time
  ;keatts = getfilevaratts(file_sf1[run2plt],"KE")
  ;print(keatts)
  dNames = getfiledimnames(file_sf1[run2plt])
  dSizes = getfiledimsizes(file_sf1[run2plt])
  print (dNames+"   "+dSizes)

  sf1 = sf1-sf3
  sf2 = sf2-sf3
  bv2 = bv2-sf3
 
  sf1!0 = "time"
  sf1!1 = "depth"
  sf1&depth = depth
  sf1&time = time
  copy_VarCoords(sf1,sf2)
  copy_VarCoords(sf1,bv2)

  data = new((/3,nlayr,ntime/),double)

  do k = 1,nlayr-1
   data(0,k,:) = sf1(:,k)
   data(1,k,:) = sf2(:,k)
   data(2,k,:) = bv2(:,k)
  end do
  ;printVarSummary(data)

  sf1@units=" "
  sf1@long_name=" "
  sf2@units=" "
  sf2@long_name=" "
  bv2@units=" "
  bv2@long_name=" "

  ;levs=(/-0.2,0.2,.02/)
  levs=(/-0.1,0.1,.01/)
 ; levs=(/-0.5,0.5,.05/)
 ; levs=(/-1.0,1.0,.1/)


;************************************************
;
;************************************************

  wkstitle="ke_anom_"+cdates(run2plt)+"_"+klast
  wkstype = "X11"
  ;wkstype = "png"
  wks =  gsn_open_wks(wkstype, wkstitle)

  npanels=ndata-1
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
  ;res@cnFillMode = "RasterFill"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@tmXBLabelStride  = 2                   ; tick mark label stride
  ;res@tiYAxisString    = "days since "+cdates(run2plt)              ; y axis title
  res@gsnYAxisIrregular2Linear = True ; converts irreg depth to linear 
  res@trYReverse           = True     ; reverses y-axis
  res@sfYArray             = depth(0:klast)
  ;res@sfXArray             = depth
  ;res@gsnXAxisIrregular2Linear = True ; converts irreg depth to linear 
  ;res@sfXArray             = depth
  res@tiXAxisString    = "days since "+cdates(run2plt)              ; y axis title
  res@tiYAxisString    = "Depth"              ; y axis title
  ;res@tiXAxisFontHeightF = 0.015
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  latmin=-60.0
  latmax= 60.0
;************************************************
;
;************************************************

  ii = 0
  res@gsnCenterString = runlabs(0)+" - "+runlabs(2)
  ;plot(ii) = gsn_csm_contour (wks,sf1,res) ; create plot
  ;plot(ii) = gsn_csm_contour (wks,sf1f,res) ; create plot
  plot(ii) = gsn_csm_contour (wks,data(ii,0:klast,:),res) ; create plot

  ii = 1
  res@gsnCenterString = runlabs(1)+" - "+runlabs(2)
  ;plot(ii) = gsn_csm_contour (wks,sf2,res) ; create plot
  plot(ii) = gsn_csm_contour (wks,data(ii,0:klast,:),res) ; create plot

  ii = 2
  res@gsnCenterString = runlabs(3)+" - "+runlabs(2)
  ;plot(ii) = gsn_csm_contour (wks,bv2,res) ; create plot
  plot(ii) = gsn_csm_contour (wks,data(ii,0:klast,:),res) ; create plot

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
  
