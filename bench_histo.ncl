;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

;************************************************

function get_hist_levels(data:numeric,levels[*]:numeric)
local nlevels, delta
begin
  nlevels = dimsizes(levels)
  hlevels = new(nlevels+2,typeof(data))
  delta = levels(1)-levels(0)
  hlevels(0)         = levels(0)-delta
  hlevels(nlevels+1) = levels(nlevels-1)+delta
  hlevels(1:nlevels) = levels
  return(hlevels)
end

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

 batch="no"
  ;batch="yes"

 bmnum = "2"
 bench = RT2+"BM"+bmnum+"_ice/"

 if(batch .eq. "no")then
      Year = 2012
      hemi = "NH"
   ;   hemi = "SH"
   varname = "hi_h"
   outname = "_histo"+hemi
     idate = Year+"0715"
   ;  idate = Year+"0215"
 end if

  if(hemi .eq. "NH")then
    minlat = 66.0
  else
    maxlat = -50.0
  end if

   tlatname="TLAT"
   tlonname="TLON"

    levels = fspan(0,4,20)
begin
;************************************************
; make a list of the files from the run
;************************************************

   icefilelist = systemfunc("ls "+bench+"gfs."+idate+"/ice*.nc")
          icef = addfiles(icefilelist,"r")
        ntimes = dimsizes(icefilelist)
    print("ntimes = "+ntimes)
    ;print(icefilelist)

     tlat = icef[0]->$tlatname$

         times = icef[:]->time
     timeUnits = icef[0]->time@units
  timeCalendar = icef[0]->time@calendar

    runname = "BM"+bmnum
   wkstitle = runname

  nt = 0
  ice0 = icef[nt]->$varname$(0,:,:)
   ai0 = icef[nt]->aice_h(0,:,:)
  nt = ntimes-1
  ice1 = icef[nt]->$varname$(0,:,:)
   ai1 = icef[nt]->aice_h(0,:,:)

  ice0 = where(ai0 .gt. 0.0 .and. tlat .ge. minlat, ice0, ice0@_FillValue)
  ice1 = where(ai1 .ge. 0.0 .and. tlat .ge. minlat, ice1, ice1@_FillValue)
 ; ice0 = where(ai0 .gt. 0.0 .and. tlat .le. maxlat, ice0, ice0@_FillValue)
 ; ice1 = where(ai1 .ge. 0.0 .and. tlat .le. maxlat, ice1, ice1@_FillValue)

;************************************************
;
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
 ;  wkstype="X11"
 ;  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)

  npanels = 2
  ; maybe not all used
    ncols = 1
    nrows = 2

     plot = new(npanels,graphic)

;---For the histogram, we need 2 extra levels for the low/high end of the bins
 ; hist_levels = get_hist_levels(ice0,levels)
 ; hist_levels = get_hist_levels(ice0,levels)
 ; print(dimsizes(hist_levels))
 ; print(hist_levels(1::6))
 ; ticlabels=hist_levels(1::6)
 ;hist_levels = (/0.0,0.25,0.75, \
 ;                1.0,1.25,1.75, \
 ;                2.0,2.25,2.75, \
 ;                3.0,3.25,3.75, \
 ;                4.0/)
 ;hist_levels = (/0.25,0.75, \
 ;                1.0,1.25,1.75, \
 ;                2.0,2.25,2.75, \
 ;                3.0,3.25,3.75, \
 ;                4.0/)
 hist_levels = (/0.10,0.5, \
                  1.0,1.5, \
                  2.0,3.0, \
                  4.0/)

 ;print(hist_levels)

;---Create a histogram
  hres                             = True
  hres@gsnMaximize                 = True
  hres@vpWidthF                    = 0.7
  hres@vpHeightF                   = 0.5
  hres@gsnHistogramComputePercentages  = True    ; change left axis to %

  hres@gsnDraw              = False       ; do not draw until the end
  hres@gsnFrame             = False       ; do not automatically advance 'frame'

  ;max_bin = 100.0e3
  max_bin = 50.0e3
  if(max_bin.gt.0) then
    hres@trYMaxF                   = max_bin+1
  end if
 
  ;hres@gsnHistogramMinMaxBinsOn    = True
  ;hres@gsnHistogramClassIntervals  = hist_levels
  hres@gsnHistogramBinIntervals     = hist_levels
  hres@gsnHistogramBarWidthPercent = 100.      ; make the bars the full
                                               ; width of the interval
  hres@gsnHistogramNumberOfBins    = 20 
  hres@tiXAxisFontHeightF          = 0.02
  hres@tiYAxisFontHeightF          = 0.02
  hres@tiXAxisString               = "Data intervals"

  hres@tmYMajorGrid                = True     ; turn on y grid lines
  hres@tmYMajorGridLineDashPattern = 2
  hres@tmGridDrawOrder             = "PreDraw"   ; only available in NCL 6.5.0

 ; setvalues plot
 ;   "tmXBLabelFontHeightF" : 0.02
 ;   "tmXBLabels"           : ticlabels
 ; end setvalues

  plot(0) = gsn_histogram(wks,ndtooned(ice0),hres)
  plot(1) = gsn_histogram(wks,ndtooned(ice1),hres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
   
  resP@gsnFrame            = False
  resP@gsnPanelLabelBar    = False               ; add common colorbar

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

;************************************************
;
;************************************************

    gsn_panel(wks,plot,(/nrows,ncols/),resP)
    frame(wks)

exit
end
