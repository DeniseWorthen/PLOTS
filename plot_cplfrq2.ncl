begin
  runsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/CplFrq/"
 
  compare2obs="no"

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

  obsf=addfiles(runsrc+"oisst."+cdates+".5d.nc","r")
  obs1=dim_avg_Wrap(obsf[0]->sst)
  obs2=dim_avg_Wrap(obsf[1]->sst)
  ;printVarSummary(obs1)
  ; dims = dimsizes(obs1)
  ;print(dims(0)+" "+dims(1))

  ndata = 4
  file_sf1=addfiles(runsrc+"slowfast1_25d_"+cdates+"0100/SST.025deg.5d.nc","r")
  file_sf2=addfiles(runsrc+"slowfast2_25d_"+cdates+"0100/SST.025deg.5d.nc","r")
  file_sf3=addfiles(runsrc+"slowfast3_25d_"+cdates+"0100/SST.025deg.5d.nc","r")
  file_bv2=addfiles(runsrc+  "benchv2_25d_"+cdates+"0100/SST.025deg.5d.nc","r")
  ;print(file_sf1)
 
  if(compare2obs .eq. "yes")then
   sf1=dim_avg_Wrap(file_sf1[0]->sst)-dim_avg_Wrap(obsf[0]->sst)
   sf2=dim_avg_Wrap(file_sf2[0]->sst)-dim_avg_Wrap(obsf[0]->sst)
   sf3=dim_avg_Wrap(file_sf3[0]->sst)-dim_avg_Wrap(obsf[0]->sst)
   bv2=dim_avg_Wrap(file_bv2[0]->sst)-dim_avg_Wrap(obsf[0]->sst)
  else 
   sf1=dim_avg_Wrap(file_sf1[0]->sst)-dim_avg_Wrap(file_sf3[0]->sst)
   sf2=dim_avg_Wrap(file_sf2[0]->sst)-dim_avg_Wrap(file_sf3[0]->sst)
   sf3=dim_avg_Wrap(file_sf3[0]->sst)-dim_avg_Wrap(file_sf3[0]->sst)
   bv2=dim_avg_Wrap(file_bv2[0]->sst)-dim_avg_Wrap(file_sf3[0]->sst)
  end if 
   dims = dimsizes(sf1)
  nlats = dims(1)
  ;printVarSummary(sf1)
  ;print(nlats)

  if(compare2obs .eq. "yes")then
   data1 = new((/ndata,nlats/),float)
   data1(0,:) = sf1(0,:)
   data1(1,:) = sf2(0,:)
   data1(2,:) = sf3(0,:)
   data1(3,:) = bv2(0,:)
   colors = (/"black", "blue", "red", "green"/)
  else
   data1 = new((/ndata-1,nlats/),float)
   data1(0,:) = sf1(0,:)
   data1(1,:) = sf2(0,:)
   data1(2,:) = bv2(0,:)
   colors = (/"black", "blue", "green"/)
  end if

  if(compare2obs .eq. "yes")then
   sf1=dim_avg_Wrap(file_sf1[1]->sst)-dim_avg_Wrap(obsf[1]->sst)
   sf2=dim_avg_Wrap(file_sf2[1]->sst)-dim_avg_Wrap(obsf[1]->sst)
   sf3=dim_avg_Wrap(file_sf3[1]->sst)-dim_avg_Wrap(obsf[1]->sst)
   bv2=dim_avg_Wrap(file_bv2[1]->sst)-dim_avg_Wrap(obsf[1]->sst)
  else 
   sf1=dim_avg_Wrap(file_sf1[1]->sst)-dim_avg_Wrap(file_sf3[1]->sst)
   sf2=dim_avg_Wrap(file_sf2[1]->sst)-dim_avg_Wrap(file_sf3[1]->sst)
   sf3=dim_avg_Wrap(file_sf3[1]->sst)-dim_avg_Wrap(file_sf3[1]->sst)
   bv2=dim_avg_Wrap(file_bv2[1]->sst)-dim_avg_Wrap(file_sf3[1]->sst)
  end if 

  if(compare2obs .eq. "yes")then
   data2 = new((/ndata,nlats/),float)
   data2(0,:) = sf1(0,:)
   data2(1,:) = sf2(0,:)
   data2(2,:) = sf3(0,:)
   data2(3,:) = bv2(0,:)
  colors = (/"black", "blue", "red", "green"/)
  else
   data2 = new((/ndata-1,nlats/),float)
   data2(0,:) = sf1(0,:)
   data2(1,:) = sf2(0,:)
   data2(2,:) = bv2(0,:)
  colors = (/"black", "blue", "green"/)
  end if

  lats = file_sf1[0]->lat

;************************************************
;
;************************************************

 if(compare2obs .eq. "yes")then
  legendlabs = new((/ndata/),"string")
  legendcols = new((/ndata/),"string")
  legendthik = new((/ndata/),"float")
  legenddash = new((/ndata/),"integer")
  do ii = 0,ndata-1
   legendlabs(ii) = runlabs(ii)
   legendcols(ii) =  colors(ii)
  end do
 else
  legendlabs = new((/ndata-1/),"string")
  legendcols = new((/ndata-1/),"string")
  legendthik = new((/ndata-1/),"float")
  legenddash = new((/ndata-1/),"integer")
  do ii = 0,1
   legendlabs(ii) = runlabs(ii)
   legendcols(ii) =  colors(ii)
   print(legendlabs(ii))
  end do
   legendlabs(2) = runlabs(3)
   legendcols(2) =  colors(3)
 end if
   legendthik(:) =  3.0
   legenddash(:) =  0
 
;************************************************
;
;************************************************

  wkstitle="zm_sst_anom"
  wkstype = "X11"
  wks =  gsn_open_wks(wkstype, wkstitle)

  npanels=dimsizes(cdates)
  plot = new(npanels,graphic)

  res = True
  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.30

  res@gsnDraw  = False
  res@gsnFrame = False
  res@gsnPaperOrientation = "auto"

  res@xyMarkLineMode    = "Lines"
  res@xyLineThicknessF  = 3.0
  res@xyLineColors      = colors
  res@gsnYRefLine = 0.0
 
  ;res@tiMainString      = runames[0]
  ;res@tiMainFontHeightF = 0.015

  res@tiYAxisString = "Zonal Mean Difference (deg)"
  res@tiXAxisString = "Latitude"
  res@tiYAxisFontHeightF = 0.012
  res@tiXAxisFontHeightF = 0.012
  res@trXMinF = -60.0
  res@trXMaxF =  60.0

  ;res@xyDashPatterns = (/0, 0, 0, 2/)
  res@xyDashPattern = 0

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.30                  ; width of legend (NDC)
  lgres@vpHeightF            = 0.12                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = ndata
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  lgres@lgLineThicknesses    = legendthik
  lgres@lgLineLabelStrings   = legendlabs
  if(compare2obs .eq. "yes")then
   lgres@lgItemOrder = (/3,2,1,0/)
  else
   lgres@lgItemOrder = (/2,1,0/)
  end if

;************************************************
;  for simple_legend
;************************************************

  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          =  10.      ; from the bottom
  gres@XPosPercent          =  5.
  gres@ItemSpacePercent     =  10.
  lineres@LineLengthPercent =  5.      ; expressed as %, 0->100, length of line

  textres@lgLabels           = legendlabs
  textres@lgLabelFontHeights = 0.020

  lineres@lgLineColors      = legendcols
  lineres@lgLineThicknesses = legendthik      ; line thicknesses

;************************************************
;
;************************************************

  ii = 0
  res@trYMinF = -1.1
  res@trYMaxF =  1.1
  res@gsnCenterString = runames(ii) 
  plot(0) = gsn_csm_xy (wks,lats,data1,res) ; create plot

  ii = 1
  ;res@trYMinF = -2.1
  ;res@trYMaxF =  2.1
  res@gsnCenterString = runames(ii) 
  plot(1) = gsn_csm_xy (wks,lats,data2,res) ; create plot

  xx = 0.60
  yy = 0.15
  gsn_legend_ndc(wks,ndata,legendlabs,xx,yy,lgres)

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelBottom = 0.18  ; Leave room for legend at the bottom.

  gsn_panel(wks,plot,(/npanels,1/),resP)               ; now draw as one plot

;************************************************
;
;************************************************

end
  
