load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

begin

 batch = "no"
 ;batch = "yes"

 ice_thick = True
  add_sis2 = True
   add_cpc = False

 if(ice_thick)then
  varname = "hi"
   yaxlab = "Mean Ice Thickness (m)"
   wkslab = "Thick"
 else
  varname = "ar"
   yaxlab = "Extent (Millions of square kilometers)"
   wkslab = "Area"
 end if

 obsvar = varname+"obs"
 modvar = varname+"mod"

 bmnum = "2"
 bench = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BM"+bmnum+"_ice/"
 cfsv2 = "/scratch3/NCEPDEV/marine/save/Denise.Worthen/CFSv2/"
 iobs = "/scratch3/NCEPDEV/marine/save/Denise.Worthen/IceData/"
 sis2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/SIS2_ice/"
 cpcr = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/CPC_ice/"

 if(batch .eq. "no")then
    Year = 2015
  Region = 15-1
;  Region = 21-1
 end if
 
 Dates2Label = (/(/Year,  1, 15,0,0,0/) \
                ,(/Year,  2, 15,0,0,0/) \
                ,(/Year,  3, 15,0,0,0/) \
                ,(/Year,  4, 15,0,0,0/) \
                ,(/Year,  5, 15,0,0,0/) \
                ,(/Year,  6, 15,0,0,0/) \
                ,(/Year,  7, 15,0,0,0/) \
                ,(/Year,  8, 15,0,0,0/) \
                ,(/Year,  9, 15,0,0,0/) \
                ,(/Year, 10, 15,0,0,0/) \
                ,(/Year, 11, 15,0,0,0/) \
                ,(/Year, 12, 15,0,0,0/) \
                ,(/Year+1,1, 15,0,0,0/) \
                ,(/Year+1,2, 15,0,0,0/) \
                /)

   RegNames = (/ "Gulf of Alaska   "\   ; 01
                ,"Bering Sea       "\   ; 02
                ,"Chukchi Sea      "\   ; 03
                ,"Beaufort Sea     "\   ; 04
                ,"Baffin Bay       "\   ; 05
                ,"Lincoln Sea      "\   ; 06
                ,"White Sea        "\   ; 07
                ,"EastSib Sea      "\   ; 08
                ,"NW Passages      "\   ; 09
                ,"Central Arctic   "\   ; 10
                ,"Barents Sea      "\   ; 11
                ,"Greenland Sea    "\   ; 12
                ,"Kara Sea         "\   ; 13
                ,"Laptev Sea       "\   ; 14
                ,"Nocn >50N        "\   ; 15
                ,"Weddell Sea      "\   ; 16
                ,"Indian Ocean     "\   ; 17
                ,"Pacific Ocean    "\   ; 18
                ,"Ross Sea         "\   ; 19
                ,"Belling-Amund Sea"\   ; 20
                ,"Socn <50S        "\   ; 21
                /)

;************************************************
; obs,cfsv2 and benchmark files all have same
; time axis beginning 1-jan-2011 thru 18-jan-2018
; to plot a single year comparison, need to find
; both the k-index for the run (168 total) as well 
; as the l-index in the time series
;************************************************
    
     Obs = iobs+"iceobs_stats.nc"
     BM1 = bench+"stats.nc"
     CFS = cfsv2+"stats.nc"
     SIS = sis2+"stats.nc"
     CPC = cpcr+"stats.nc"
    ObsF = addfile(Obs,"r")
    BM1F = addfile(BM1,"r")
    CFSF = addfile(CFS,"r")
    SISF = addfile(SIS,"r")
    CPCF = addfile(CPC,"r")

    ;retrieve time axis
    time = ObsF->time
    timeUnits = ObsF->time@units
    timeCalendar = ObsF->time@calendar
    ;print(timeUnits)
    ;print(timeCalendar)
    time0 = cd_inv_calendar(Year,   1,  1, 12, 00, 00,timeUnits,0)
    timef = cd_inv_calendar(Year+1, 1, 18, 12, 00, 00,timeUnits,0)
    ;starting and ending index in time axis for this year
    lstep0=get1Dindex(time,time0)
    lstepf=get1Dindex(time,timef)
    print("lstep = "+lstep0+"   "+lstepf)
    delete(time)

    ;obs = ObsF->exobs(lstep0:lstepf,Region)
    bm1 = BM1F->$modvar$(lstep0:lstepf,:,Region)
    ;cfs = CFSF->exmod(lstep0:lstepf,:,Region)
    ;print(bm1(lstep0,:,20))

    ; 2 runs/month each year
      nexp = 24
    kstep0 = max(ind(.not.ismissing(bm1(0,:))))
    kstep0 = where(.not.ismissing(kstep0),kstep0,6)
    kstepf = kstep0 + (nexp-1)
    print("kstep = "+kstep0+"   "+kstepf)
    delete(bm1)

    time = ObsF->time(lstep0:lstepf)
    timeUnits = ObsF->time@units
    timeCalendar = ObsF->time@calendar

    obs = ObsF->$obsvar$(lstep0:lstepf,Region)
    bm1 = BM1F->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    cfs = CFSF->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    sis = SISF->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    cpc = CPCF->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    dims = dimsizes(bm1)
    ntime = dims(0)
    rnum = Region+1
    delete(dims)

    ;print(bm1(0:ntime-1,0))

  wkstitle=wkslab+Year+"_region"+rnum

;************************************************
; 0 = obs
; 1 = bm1 
; 2 = cfs
; 3 = sis2 or cpc
;************************************************

    data_all = new((/4,nexp,ntime/),"float")
    dims = dimsizes(data_all)
    ;print("data_all "+dims(0)+"  "+dims(1)+"  "+dims(2))
    do k = 0,nexp-1
     data_all(0,k,:) = obs(:)
     data_all(1,k,:) = bm1(:,k)
     data_all(2,k,:) = cfs(:,k)
     if(add_sis2)then
      data_all(3,k,:) = sis(:,k)
     end if
     if(add_cpc)then
      data_all(3,k,:) = cpc(:,k)
     end if
    end do

     lines = (/ "Lines", "Lines", "Lines", "Lines", "Lines", "Markers"/)
     colors = (/"black",   "red",   "red",  "blue",  "blue",   "green"/)
     thicks = (/    5.0,    3.0,     3.0,     3.0,     3.0,      3.0/)
     dashes = (/    0.0,    0.0,     2.0,     0.0,     2.0,      0.0/)
     markrs = (/    0.0,    0.0,     0.0,     0.0,     0.0,     16.0/)

;************************************************
;
;************************************************

 ; 1 obs + bm1x2 + cfsx2 + sis2x1
  nlines = 1+2+2
 if(add_sis2 .or. add_cpc)then
  nlines = nlines+1
 end if

 legendlabs = new((/nlines/),"string")
 legendfhgt = new((/nlines/),"float")
 legendcols = new((/nlines/),"string")
 legendthik = new((/nlines/),"float")
 legenddash = new((/nlines/),"float")
 legendmark = new((/nlines/),"float")

   if(ice_thick)then
   legendlabs(0) = "CryoSat-2 Level-4 Ice Thickness, v1"
   else
   legendlabs(0) = "NOAA/NSIDC Climate Record Ice Concentration, v3"
   end if

   legendlabs(1) = "BM"+bmnum+", initialized 1st"
   legendlabs(2) = "BM"+bmnum+", initialized 15th"
   legendlabs(3) = "CFSv2, initialized 1st"
   legendlabs(4) = "CFSv2, initialized 15th"
   legendfhgt    =  0.015

   if(add_sis2 .or. add_cpc)then
    if(add_sis2)then
     legendlabs(5) = "SIS2"
    end if
    if(add_cpc)then
     legendlabs(5) = "CPC"
    end if
    mmin = min(data_all)
    mmax = max(data_all)
   else
    mmin = min(data_all(0:nlines-2,:,:))
    mmax = max(data_all(0:nlines-2,:,:))
   end if
   print(mmin)
   print(mmax)
  
;************************************************
;
;************************************************
  
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
   ;wkstype="X11"
  end if
  wks =  gsn_open_wks(wkstype, wkstitle)

  ;drawNDCGrid(wks)

  oplot = new(nlines-1,graphic)

  res = True
  res@vpWidthF          = 0.80
  res@vpHeightF         = 0.30

  res@gsnDraw  = False
  res@gsnFrame = False
  res@gsnPaperOrientation = "auto"
  res@gsnMaximize = True
  res@xyXStyle  = "Time"

;       default Format = "0@*+^sg"
 res@tmYLFormat = "0*+^f"       ; use "e" symbol, don't force 0's (see documentation)
 ;res@tmYLMinorOn = False        ; turn the minor tick marks off
  res@tmYLPrecision = 3          ; set the precision

  res@tiXAxisString = "Date"
  res@tiYAxisString = yaxlab
  res@tiYAxisFontHeightF = 0.012
  res@tiXAxisFontHeightF = 0.012

  res@trYMinF = 0.90*mmin
  res@trYMaxF = 1.02*mmax
  res@trXMaxF   = max(time)+5*24
  res@trXMinF   = min(time)-5*24

  res@tiMainString      = Year
  res@tiMainFontHeightF = 0.015

;************************************************
;
;************************************************

  restick = True
  restick@ttmFormat = "%N%D"
  res@tmXBLabelFontHeightF = 0.015 ; resize tick labels
  restick@ttmValues = Dates2Label
  time_axis_labels(time,res,restick)

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.2                   ; width of legend (NDC)
  lgres@vpHeightF            = 0.10                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgItemCount          = nlines
  lgres@lgLabelsOn           = True
  lgres@lgLabelFontHeightF   = 0.25
  lgres@lgMonoItemType       = False
  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgItemTypes          = lines
  lgres@lgMarkerIndexes      = markrs
  lgres@lgMarkerColors       = colors
  lgres@lgDashIndexes        = dashes
  lgres@lgLineColors         = colors
  lgres@lgLineThicknesses    = thicks
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgItemOrder          = (/5,4,3,2,1,0/)

  ;print(lines)
;************************************************
; for simple_legend_ndc
;************************************************

  gres = True
  gres@YPosPercent = 20.    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 55.    ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres = True
  lineres@lgLineColors      = legendcols                ; line colors
  lineres@lgLineThicknesses = legendthik                ; line thicknesses
  lineres@lgDashIndexes     = legenddash                ; line types
  lineres@LineLengthPercent = 5.                        ; expressed as %, 0->100, length of line
  lineres@lgItemTypes       = False

  textres = True
  textres@lgLabels = legendlabs                                   ; legend labels (required)
  textres@lgLabelFontHeights = legendfhgt                         ; label font heights

;************************************************
;
;************************************************

 ; obs
  res@xyLineThicknessF  = 5.0
  res@xyLineColor       = "black"
  plot = gsn_csm_xy (wks,time,data_all(0,0,:),res) ; create plot

  ; 1st of each month, first bm, then cfs
  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "red"
  res@xyDashPattern     = 0
  oplot(0) = gsn_csm_xy (wks,time,data_all(1,0:nexp-1:2,:), res) ; create plot
  res@xyDashPattern     = 2
  oplot(1) = gsn_csm_xy (wks,time,data_all(2,0:nexp-1:2,:), res) ; create plot

  ; 15th of each month, first bm, then cfs
  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "blue"
  res@xyDashPattern     = 0
  oplot(2) = gsn_csm_xy (wks,time,data_all(1,1:nexp-1:2,:), res) ; create plot
  res@xyDashPattern     = 2
  oplot(3) = gsn_csm_xy (wks,time,data_all(2,1:nexp-1:2,:), res) ; create plot

  overlay(plot,oplot(0))
  overlay(plot,oplot(1))
  overlay(plot,oplot(2))
  overlay(plot,oplot(3))

  if(add_sis2 .or. add_cpc)then
  ; sis2
   res@xyMarkLineMode  = "Markers"
   res@xyMarkerColor   = "green"
   res@xyMarker        = 1
   res@xyMarkerSizeF   = 0.03
   oplot(4) = gsn_csm_xy (wks,time,data_all(3,0:nexp-1,:),   res) ; create plot
   overlay(plot,oplot(4))
  end if
  
  
  ;if(1 .eq. 0)then
  ; 1st of each month, first bm, then cfs
  ;res@xyLineThicknessF  = 3.0
  ;res@xyLineColor       = "red"
  ;res@xyDashPattern     = 0
  ;oplot1 = gsn_csm_xy (wks,time, data_all(1,0:nexp-1:2,:), res) ; create plot
  ;overlay(plot,oplot1)
  ;res@xyDashPattern     = 2
  ;oplot2 = gsn_csm_xy (wks,time, data_all(2,0:nexp-1:2,:), res) ; create plot
  ;overlay(plot,oplot2)

  ; 15th of each month, first bm, then cfs
  ;res@xyLineColor       = "blue"
  ;res@xyDashPattern     = 0
  ;oplot3 = gsn_csm_xy (wks,time, data_all(1,1:nexp-1:2,:),res) ; create plot
  ;overlay(plot,oplot3)
  ;res@xyDashPattern     = 2
  ;oplot4 = gsn_csm_xy (wks,time, data_all(2,1:nexp-1:2,:), res) ; create plot
  ;overlay(plot,oplot4)
  ;end if

;************************************************
;
;************************************************

 ; sis2 markers
  ;oplot5 = gsn_csm_xy (wks,time, data_all(3,0:nexp-1:2,:),res) ; create plot
  ;overlay(plot,oplot5)
 ; oplot6 = gsn_csm_xy (wks,time, data_all(3,1:nexp-1:2,:),res) ; create plot
 ; overlay(plot,oplot6)

  xx = 0.70
  yy = 0.05
  ;gsn_legend_ndc(wks,nlines,legendlabs,xx,yy,lgres)

 ; add a legend to last year in batch, otherwise add legend
  if(batch .eq. "yes")then
   if(Year .eq. 2017)then
   ; simple_legend_ndc(wks,gres,lineres,textres)
   gsn_legend_ndc(wks,nlines,legendlabs,xx,yy,lgres)
   end if
  else
   ; simple_legend_ndc(wks,gres,lineres,textres)
   gsn_legend_ndc(wks,nlines,legendlabs,xx,yy,lgres)
  end if

  draw(plot)
  frame(wks)

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x20 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
