  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "levscmapCICE.ncl"
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;----------------------------------------------------------------------
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
;----------------------------------------------------------------------
; Draw a histogram of your data, given a set of levels that span
; the data, a title, and the max value expected for a bin.
;
; The max_bin is for animation purposes, in order to keep the Y axis
; the same for each iteration. Set to -1 if you want the max_bin set
; by this procedure.
;----------------------------------------------------------------------
procedure draw_histogram(wks,data,levels[*]:numeric,title[1]:string,max_bin[1])
local hist_levels, hres
begin
;---For the histogram, we need 2 extra levels for the low/high end of the bins
  hist_levels = get_hist_levels(data,levels)
;---Create a histogram
  hres                             = True
  hres@gsnMaximize                 = True
  hres@vpWidthF                    = 0.7
  hres@vpHeightF                   = 0.5
  hres@gsnHistogramComputePercentages  = True    ; change left axis to %

  hres@tiMainString                = title

  if(max_bin.gt.0) then
    hres@trYMaxF                   = max_bin+1
  end if

  hres@gsnHistogramClassIntervals  = hist_levels
  hres@gsnHistogramBarWidthPercent = 100.      ; make the bars the full
                                                 ; width of the interval
  hres@tiXAxisFontHeightF          = 0.02
  hres@tiYAxisFontHeightF          = 0.02
  hres@tiXAxisString               = "Data intervals"

  hres@tmYMajorGrid                = True     ; turn on y grid lines
  hres@tmYMajorGridLineDashPattern = 2
  hres@tmGridDrawOrder             = "PreDraw"   ; only available in NCL 6.5.0

  plot = gsn_histogram(wks,ndtooned(data),hres)
end
;----------------------------------------------------------------------
; Given a dataset and a set of levels, count how many values fall
; in each range:
;   # vals < levels(0)
;   # vals >= levels(0) and < levels(1)
;   # vals >= levels(1) and < levels(2)
;     . . .
;   # vals >= levels(nlevels-2) and < levels(nlevels-1)
;   # vals >= levels(nlevels-1)
;
; Also count number of valid values and missing values.
; Returns the max number found in a bin, for plotting purposes later
;
; This procedure is mainly for debug purposes.
;----------------------------------------------------------------------
function print_binned_info(data:numeric,levels[*]:numeric)
local total_binned, nlevels, count, scount, total_valid, total_msg
begin
  nlevels = dimsizes(levels)
  total_binned = 0
  max_bin      = -1
  do nl=0,nlevels
    if(nl.eq.0) then
      count = num(data.lt.levels(0))
      scount = sprinti("%4i",count)
      print("    " + scount + " values < " + levels(0))
    else if(nl.eq.nlevels) then
      count = num(data.ge.levels(nlevels-1))
      scount = sprinti("%4i",count)
      print("    " + scount + " values >= " + levels(nlevels-1))
    else
      count = num(data.ge.levels(nl-1).and.data.lt.levels(nl))
      scount = sprinti("%4i",count)
      print("    " + scount + " values >= " + levels(nl-1) + " and < " + levels(nl))
    end if
    end if
    total_binned = total_binned + count
    max_bin      = max((/max_bin,count/))
  end do

  total_valid = num(.not.ismissing(data))
  total_msg   = num(ismissing(data))

  print("    There are " + total_valid + " valid values and " + \
        total_msg + " missing values.")
  print("    " + total_binned + " values were binned." + \
        " (This should be equal to the # of valid values.)")
  return(max_bin)
end
;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
     bmnum="2"
     bench = RT2+"BM"+bmnum+"_ice/"
     Year = "2012"
     idate = Year+"0715"

  icefilelist = systemfunc("ls "+bench+"gfs."+idate+"/ice*.nc")
   ;icefilelist = systemfunc("ls "+dirname+"iceh_06h*.nc")
          icef = addfiles(icefilelist,"r")
        ntimes = dimsizes(icefilelist)

  hi = icef[:]->hi_h(:,800:,:)
  ts = where(hi .gt. 0.0, hi, hi@_FillValue)
  ;printVarSummary(ts)   ;
  ;printMinMax(ts,0)
  ntim = dimsizes(ts(:,0,0))     ; 1872 time steps

;---Select some levels that span the data. Could also calculate programmatically.
 ; levels = ispan(0,4,.5)
 ; print(levels)
  levels = fspan(0,4,16)
 ;levels = (/0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
;---Calculate the max_bin across all time steps.
  max_bin = -1
;  do nt=0,ntim-1
;    max_bin = max((/max_bin,print_binned_info(ts(nt,:,:),levels)/))
;  end do

  wks = gsn_open_wks("X11","histo")

;---Loop through every 100th timestep and create a histogram of the values
  do nt=0,ntim-1,2
    title = "Time index " + nt
    draw_histogram(wks,ts(nt,:,:),levels,title,max_bin)
  end do

;---Convert PNGs to an animated GIF.
  ANIMATE = False
  if(ANIMATE) then
    delete(wks)      ; This forces the PNGs to be closed
    system("convert -trim -delay 50 histo.000*.png histo.gif")
    system("rm -rf histo.000*.png")
  end if
end

