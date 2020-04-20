load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

begin

 batch = "no"
 ;batch = "yes"

 ;modvar = "himod"
 ;yaxlab = "mean ice thickness (m)"
 ;modvar = "tmelt"
 ;yaxlab = "mean ice melt rate (cm/d)"
 modvar = "tprod"
 yaxlab = "mean ice production rate (cm/d)"

 bmnum="1"
 bench = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BM"+bmnum+"_ice/"

 if(batch .eq. "no")then
    Year = 2017
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
    
     BM = bench+"stats.nc"
     BMF = addfile(BM,"r")

    ;retrieve time axis
    time = BMF->time
    timeUnits = BMF->time@units
    timeCalendar = BMF->time@calendar
    ;print(timeUnits)
    ;print(timeCalendar)
    time0 = cd_inv_calendar(Year,   1,  1, 12, 00, 00,timeUnits,0)
    timef = cd_inv_calendar(Year+1, 1, 18, 12, 00, 00,timeUnits,0)
    ;starting and ending index in time axis for this year
    lstep0=get1Dindex(time,time0)
    lstepf=get1Dindex(time,timef)
    print("lstep = "+lstep0+"   "+lstepf)
    delete(time)

    bm = BMF->$modvar$(lstep0:lstepf,:,Region)

    ; 2 runs/month each year
      nexp = 24
    kstep0 = max(ind(.not.ismissing(bm(0,:))))
    kstep0 = where(.not.ismissing(kstep0),kstep0,6)
    kstepf = kstep0 + (nexp-1)
    print("kstep = "+kstep0+"   "+kstepf)
    delete(bm)

    time = BMF->time(lstep0:lstepf)
    timeUnits = BMF->time@units
    timeCalendar = BMF->time@calendar

    bm = BMF->$modvar$(lstep0:lstepf,kstep0:kstepf,Region)
    dims = dimsizes(bm)
    ntime = dims(0)
    rnum = Region+1
    delete(dims)

  wkstitle=modvar+Year+"_region"+rnum

;************************************************
; 0 = bm1 
; 1 = bm2 
;************************************************

    data_all = new((/2,nexp,ntime/),"float")
    dims = dimsizes(data_all)
    ;print("data_all "+dims(0)+"  "+dims(1)+"  "+dims(2))
    do k = 0,nexp-1
     data_all(0,k,:) = bm(:,k)
    end do

;************************************************
;
;************************************************

 ; bmx2 + bm2x2 
  nlines = 2

 legendlabs = new((/nlines/),"string")
 legendfhgt = new((/nlines/),"float")
 legendcols = new((/nlines/),"string")
 legendthik = new((/nlines/),"float")
 legenddash = new((/nlines/),"float")
 legendmark = new((/nlines/),"float")

     colors = (/"red",  "blue"/)

  legendlabs(0) = "BM"+bmnum+", initialized 1st"
  legendlabs(1) = "BM"+bmnum+", initialized 15th"
  legendfhgt    =  0.015

 do ii = 0,nlines-1
  legendcols(ii) =  colors(ii)
  legendthik(ii) =  3.0
  legenddash(ii) =  0
  legendfhgt(ii) =  0.015
 end do

    mmin = min(data_all(:,:,:))
    mmax = max(data_all(:,:,:))
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

  res@trYMinF = 0.98*mmin
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

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = nlines
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  lgres@lgLineThicknesses    = legendthik
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgLabelFontHeightF   = 0.20
  lgres@lgItemOrder          = (/5,4,3,2,1,0/)
  lgres@lgItemTypes          = False

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

  ; 1st of each month
  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "red"
  res@xyDashPattern     = 0
      plot = gsn_csm_xy (wks,time,data_all(0,0:nexp-1:2,:), res) ; create plot
  ; 15th of each month
  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "blue"
  res@xyDashPattern     = 0
  oplot(0) = gsn_csm_xy (wks,time,data_all(0,1:nexp-1:2,:), res) ; create plot

  overlay(plot,oplot(0))

 ; add a legend to last year in batch, otherwise add legend
  if(batch .eq. "yes")then
   if(Year .eq. 2017)then
    simple_legend_ndc(wks,gres,lineres,textres)
   end if
  else
    simple_legend_ndc(wks,gres,lineres,textres)
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
