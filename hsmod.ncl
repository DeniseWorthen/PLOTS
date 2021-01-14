load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

begin
  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/scrub/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
   CL = "/scratch2/NCEPDEV/climate/Denise.Worthen/"

 batch = "no"
 ;batch = "yes"

  varname = "hs"
   yaxlab = "Mean Snow Depth (m)"
   wkslab = "Snow"

 obsvar = varname+"obs"
 modvar = varname+"mod"

 bmnum = (/"31","5"/)
 bench = CL+"P"+bmnum+"ice/"
 cfsv2 = CL+"CFSv2/"
 iobs =  CL+"IceData/"
 print(bench)

 if(batch .eq. "no")then
    Year = 2013
;  Region = 15-1
  Region = 10-1
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
     ; here just use obs for the time axis retrieval
     obssrc = "goddard_nt_seaice_conc"
     obslab = "NASA Team"
     ;obssrc = "seaice_conc_cdr"
     ;obslab = "CDR"

     Obs = iobs+"iceobs_stats."+obssrc+".nc"
     BMs = bench+"stats.nc"
     CFS = cfsv2+"cfsv2.ice.stats.nc"
    ObsF = addfile(Obs,"r")
    BMsF = addfiles(BMs,"r")
    CFSF = addfile(CFS,"r")

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

    bm = BMsF[0]->$modvar$(lstep0:lstepf,:,Region)
    ; 2 runs/month each year
      nexp = 24
    kstep0 = max(ind(.not.ismissing(bm(0,:))))
    kstep0 = where(.not.ismissing(kstep0),kstep0,6)
    kstepf = kstep0 + (nexp-1)
    print("kstep = "+kstep0+"   "+kstepf)
    delete(bm)

    time = ObsF->time(lstep0:lstepf)
    timeUnits = ObsF->time@units
    timeCalendar = ObsF->time@calendar

    ; bm1 = bm choice 1, bm2 = bm choice 2
    bm1 = BMsF[0]->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    bm2 = BMsF[1]->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    cfs = CFSF->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    dims = dimsizes(bm2)
    ntime = dims(0)
    rnum = Region+1
    delete(dims)

    ;print(bm1(0:ntime-1,0))

  wkstitle=wkslab+Year+"_region"+rnum

;************************************************
; 0 = bm choice 1
; 1 = bm choice 2
; 2 = cfs
;************************************************

    tot = 1 + dimsizes(bmnum)
    data_all = new((/tot,nexp,ntime/),"float")
    dims = dimsizes(data_all)
    ;print("data_all "+dims(0)+"  "+dims(1)+"  "+dims(2))
    do k = 0,nexp-1
     data_all(0,k,:) = bm1(:,k)
     data_all(1,k,:) = bm2(:,k)
     data_all(2,k,:) = cfs(:,k)
    end do

     lines = (/ \
                "Lines", "Lines" \
               ,"Lines", "Lines" \
               ,"Lines", "Lines" \
             /)
     colors = (/ \
                    "red",   "red" \
               ,   "blue",  "blue" \
               , "grey50", "grey50" \
              /)
     thicks = (/  \
                    3.0,     3.0 \
               ,    3.0,     3.0 \
               ,    3.0,     3.0 \
              /)
     dashes = (/  \
                    0.0,     1.0 \
               ,    0.0,     1.0 \
               ,    0.0,     1.0 \
              /)

;************************************************
;
;************************************************

 ;  2*(2 benchmark choices) + cfsx2
  nlines = 2*2+2

 legendlabs = new((/nlines/),"string")
 legendfhgt = new((/nlines/),"float")
 legendcols = new((/nlines/),"string")
 legendthik = new((/nlines/),"float")
 legenddash = new((/nlines/),"float")
 legendmark = new((/nlines/),"float")

   legendlabs(0) = "P"+bmnum(0)+", initialized 1st"
   legendlabs(1) = "P"+bmnum(0)+", initialized 15th"
   legendlabs(2) = "P"+bmnum(1)+", initialized 1st"
   legendlabs(3) = "P"+bmnum(1)+", initialized 15th"
   legendlabs(4) = "CFSv2, initialized 1st"
   legendlabs(5) = "CFSv2, initialized 15th"
   legendfhgt    =  0.10

    mmin = min(data_all)
    mmax = max(data_all)
   ;print(mmin)
   ;print(mmax)
  
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
  lgres@vpWidthF             = 0.3                   ; width of legend (NDC)
  lgres@vpHeightF            = 0.15                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgItemCount          = nlines
  lgres@lgLabelsOn           = True
  lgres@lgLabelFontHeightF   = legendfhgt
  lgres@lgMonoItemType       = False
  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgItemTypes          = lines
  lgres@lgDashIndexes        = dashes
  lgres@lgLineColors         = colors
  lgres@lgLineThicknesses    = thicks
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgItemOrder          = (/6,5,4,3,2,1,0/)
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
  lineres@LineLengthPercent = 2.                        ; expressed as %, 0->100, length of line
  lineres@lgItemTypes       = False

  textres = True
  textres@lgLabels = legendlabs                                   ; legend labels (required)
  textres@lgLabelFontHeights = legendfhgt                         ; label font heights

;************************************************
;
;************************************************

   jj = 0
  ; 1st, 15th of each month, first plotted bm (bmnum(0))
  res@xyLineThicknessF  = thicks(jj)
  res@xyLineColor       = colors(jj)
  res@xyDashPattern     = dashes(jj)
   plot = gsn_csm_xy (wks,time,data_all(0,0:nexp-1:2,:), res) ; create plot
  jj = jj+1
  res@xyLineColor       = colors(jj)
  res@xyDashPattern     = dashes(jj)
  oplot(jj-1) = gsn_csm_xy (wks,time,data_all(0,1:nexp-1:2,:), res) ; create plot

  ; 1st, 15th of each month, second plotted bm (bmnum(1))
  jj = jj+1
  res@xyLineThicknessF  = thicks(jj)
  res@xyLineColor       = colors(jj)
  res@xyDashPattern     = dashes(jj)
  oplot(jj-1) = gsn_csm_xy (wks,time,data_all(1,0:nexp-1:2,:), res) ; create plot
  jj = jj+1
  res@xyLineColor       = colors(jj)
  res@xyDashPattern     = dashes(jj)
  oplot(jj-1) = gsn_csm_xy (wks,time,data_all(1,1:nexp-1:2,:), res) ; create plot

  ; 1st, 15th of each month, cfs
  jj = jj+1
  res@xyLineThicknessF  = thicks(jj)
  res@xyLineColor       = colors(jj)
  res@xyDashPattern     = dashes(jj)
  oplot(jj-1) = gsn_csm_xy (wks,time,data_all(2,0:nexp-1:2,:), res) ; create plot
  jj = jj+1
  res@xyLineColor       = colors(jj)
  res@xyDashPattern     = dashes(jj)
  oplot(jj-1) = gsn_csm_xy (wks,time,data_all(2,1:nexp-1:2,:), res) ; create plot

  do ii = 0,4
   overlay(plot,oplot(ii))
  end do

;************************************************
;
;************************************************

  xx = 0.65
  yy = 0.20
 ; add a legend to last year in batch, otherwise add legend
  if(batch .eq. "yes")then
   if(Year .eq. 2017)then
   gsn_legend_ndc(wks,nlines,legendlabs,xx,yy,lgres)
   end if
  else
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
