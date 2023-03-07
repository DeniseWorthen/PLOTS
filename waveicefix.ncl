:;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
  runsrc = "/glade/scratch/worthen/FV3_RT/waveicefix/"

  runames = (/"base/", "base.fixmod/"/)
  runlabs = (/"base case", "with fix"/)
  cplfiles = addfiles(runsrc+runames+"wav.cpl.hi.nc","r")
  grdfiles = addfiles(runsrc+runames+"wav.grd.out.nc","r")
  ListSetType(cplfiles,"join")
  ListSetType(grdfiles,"join")

  print(runsrc+runames)

  dcpl = 720
  dgrd = 3600
  dt = dgrd/dcpl
  fnum=25
  ipt = 150-1
  jpt = 55-1
  cplvname="wavImp_Sw_elevation_spectrum25"
  grdvname="EF"

  cpldat = cplfiles[:]->$cplvname$(:,:,jpt,ipt)
  ;printVarSummary(cpldat)
  grddat = grdfiles[:]->$grdvname$(:,:,fnum-1,jpt,ipt)
  ;printVarSummary(grddat)
  ;print(dimsizes(grddat(0,:)))
  ;print(runlabs(0)+"  "+grddat(0,:)+"  "+runlabs(1)+"  "+grddat(1,:))

  time = cplfiles[0]->time
  ;timeUnits = cplfiles[0]->time@units
  ;timeCalendar = cplfiles[0]->time@calendar
  ntime = dimsizes(time)
  ;print(time(0::6))
  ; put output on common time ais
  data = new((/4,ntime/), float)

  data(0:1,:) = tofloat(cpldat)

  ; fill the first timestep
  ;data(2,0) = grddat(0,0)
  ;data(3,0) = grddat(1,0)

  iii = 0
  do ii = dt-1,ntime-1,dt
    iii = iii+1
    ;print("ii = "+ii+" iii = "+iii)
    data(2,ii) = grddat(0,iii)
    data(3,ii) = grddat(1,iii)
  end do
  ;print(runlabs(0)+"  "+data(2,:)+"  "+runlabs(1)+"  "+data(3,:))

;************************************************
;
;************************************************

  wkstitle="wavicefix"
  wkstype = "X11"
  ;wkstype="png"
    wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks =  gsn_open_wks(wkstype, wkstitle)
  ;drawNDCGrid(wks)

  ;npanels=dimsizes(cdates)
  plot = new(2,graphic)
  oplot = new(2,graphic)

  res = True
  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.30

  res@gsnDraw  = False
  res@gsnFrame = False
  res@gsnPaperOrientation = "auto"

  res@xyMarkLineMode    = "Lines"
  res@xyLineThicknessF  = 3.0
  ;res@xyLineColors      = colors
  res@gsnYRefLine = 0.0

  restick = True
  restick@ttmFormat = "%N-%D %H:%M:%S"
  restick@ttmMinorStride = 1
  time_axis_labels(time(5::5),res,restick)
  res@tmXBLabelFontHeightF = 0.01

  gres = True
  txres = True
  txres@txFontHeightF = 0.015

;************************************************
;
;************************************************

  ii=0
  res@xyMarkLineMode    = "MarkLines"
  res@xyMarker       = 1
  res@xyMarkerSizeF  = .012
  res@xyMarkerColor = "black"
  plot(ii) = gsn_csm_xy (wks,time,data(0,:),res) ; create plot

  res@xyMarkLineMode = "Markers"                ; Markers only
  res@xyMarker       = 4
  res@xyMarkerColor = "blue"
  oplot(ii) = gsn_csm_xy (wks,time,data(2,:),res) ; create plot
  ;dum = simple_legend(wks, oplot(ii), gres, lineres, textres)
  overlay(plot(ii),oplot(ii))

  ii=1
  res@xyMarkLineMode    = "MarkLines"
  res@xyMarker       = 1
  res@xyMarkerSizeF  = .012
  res@xyMarkerColor = "black"
  plot(ii) = gsn_csm_xy (wks,time,data(1,:),res) ; create plot

  res@xyMarkLineMode = "Markers"                ; Markers only
  res@xyMarker       = 4
  res@xyMarkerColor = "blue"
  res@xyMarkerSizeF  = .012
  oplot(ii) = gsn_csm_xy (wks,time,data(3,:),res) ; create plot
  overlay(plot(ii),oplot(ii))

  xx = 0.2
  yy = 0.90
  gres@gsMarkerIndex = 1
  gres@gsMarkerSizeF = 20.
  gsn_polymarker_ndc(wks,xx,yy,gres)
  gsn_text_ndc(wks,"coupler history",xx+0.08,yy,txres)
  yy = 0.88
  gres@gsMarkerIndex = 4
  gres@gsMarkerColor = "blue"
  gres@gsMarkerSizeF = 10.
  gsn_polymarker_ndc(wks,xx,yy,gres)
  gsn_text_ndc(wks,"wave history   ",xx+0.08,yy,txres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 2
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  gsn_panel(wks,plot,(/2,1/),resP)           ; now draw as one plot

  ;frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
    imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
    system(imcmd)
  end if
end
