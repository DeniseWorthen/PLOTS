;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************
; read in netCDF file
;************************************************

  ; orion
  RT1 = "/work/noaa/stmp/dworthen/stmp/dworthen/COLDSTART2/"

 ; Timeseries
 plotlabs = (/"original", "fixed_coldstart", "ocean_lag"/)
      rts = (/   "cold2",       "cold2_fix",  "nocold"/)
 cplfiles = addfiles(RT1+rts+".nc","r")
 ListSetType(cplfiles, "join")
 
;************************************************
;
;************************************************

  fldtyp = "ocnImp"
    flds = (/"So_t"  \
             /)

 fldtoplot = 0
   fldname = fldtyp+"_"+flds(fldtoplot)
  wkstitle = "coldstart_xy"
   latname = fldtyp+"_lat"
   lonname = fldtyp+"_lon"
      lons = cplfiles[0]->$lonname$(0,:,:)
      lats = cplfiles[0]->$latname$(0,:,:)

    var = cplfiles[:]->$fldname$
   time = cplfiles[0]->time
  ;printVarSummary(time)

  ; some ij pairs
  ipts = (/400, 600, 800/)
  jpts = (/500, 500, 500/)
 nsteps = dimsizes(time)
 nfiles = dimsizes(rts)  
   npts = dimsizes(ipts)

 ; an array to hold data
  data_all = new((/nfiles,npts,nsteps/),typeof(var))
   latlabs = new((/npts/),typeof(lats))
   lonlabs = new((/npts/),typeof(lons))

 ; retrieve point values
 do k = 0,npts-1
   ii = ipts(k)-1
   jj = jpts(k)-1
  ;print(ii+"  "+jj)
  latlabs(k) = lats(jj,ii)
  lonlabs(k) = lons(jj,ii)
  do kk = 0,nfiles-1
   data_all(kk,k,:) = var(kk,:,jj,ii)
  end do
 end do
  ;print(data_all(1,0,:))
 print(latlabs+"   "+lonlabs)

 legendlabs = new((/nfiles/),"string")
 legendcols = new((/nfiles/),"string")
 legendthik = new((/nfiles/),"float")
 legenddash = new((/nfiles/),"integer")

     colors = (/"red",  "blue", "green"/)

 do ii = 0,nfiles-1
  legendlabs(ii) = plotlabs(ii)
  legendcols(ii) = colors(ii)
  legendthik(ii) =  2.0
  legenddash(ii) =  0
 end do

;************************************************
; define the plot
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(npts+1,graphic)

  ;drawNDCGrid(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@vpWidthF          = 0.90
  res@vpHeightF         = 0.30
  res@xyLineThicknessF  = 2.0
  ;res@tiYAxisString     = labelstring

 res@trXMaxF = max(time+time(0))
 res@trXMinF = min(time-time(0))

 res@xyLineColors   = colors
 res@xyDashPatterns = (/0,0,0/) ; all solid

 restick = True
 restick@ttmFormat = "%H:%M"
 time_axis_labels(time,res,restick)

;***********************************************
; legend resources
;***********************************************

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.20                  ; width of legend (NDC)
  lgres@vpHeightF            = 0.10                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = nfiles
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  lgres@lgLineThicknesses    = legendthik
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgLabelFontHeightF   = 0.12
  lgres@lgItemOrder          = (/2,1,0/)

;************************************************
;
;************************************************
  ;data_all = new((/nfiles,npts,nsteps/),typeof(var))

   ii = 0
   plot(ii) = gsn_csm_xy(wks,time,data_all(:,ii,:),res)

   ii = 1
   plot(ii) = gsn_csm_xy(wks,time,data_all(:,ii,:),res)

   ii = 2
   plot(ii) = gsn_csm_xy(wks,time,data_all(:,ii,:),res)

  xx = 0.55
  yy = 0.25
  gsn_legend_ndc(wks,nfiles,legendlabs,xx,yy,lgres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  gsn_panel(wks,plot,(/npts+1,1/),resP)           ; now draw as one plot

;************************************************
;
;************************************************
  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if
exit
end
