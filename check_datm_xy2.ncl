; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

begin

;************************************************
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ; latent head evap J/kg
  lhvap = 2.501e6

  runname = "cfsr"
  rtsrc= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/DATM/fixclock/tmp/cpld_datm_mom6_cice5_2d_"+runname+"/"
 
  ocnflds = (/"mean_zonal_moment_flx",      \
              "mean_merid_moment_flx",      \
              "mean_net_sw_vis_dir_flx",    \
              "mean_sensi_heat_flx",        \
              "mean_evap_rate",             \
              "mean_prec_rate",             \
              "mean_fprec_rate"             \
              /)

  ; ocn has sign changes relative to atm export
  ocnwgts = (/-1.0, \
              -1.0, \
               1.0, \
              -1.0, \
              -1.0*lhvap, \
              3600.0, \
              3600.0/)


  forcflds = (/"dusfc",         \
               "dvsfc",         \
               "vbdsf_ave",     \
               "shtfl_ave",     \
               "lhtfl_ave",     \
               "precp",         \
               "fprecp"         \
              /)

  forcwgts = (/1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0, \
               3600.0, \
               3600.0/)

;************************************************
; create an 'hour-minute' time axis
;************************************************

  syear="2011"
  smonth="10"
    sday="01"
   shour="00"
   stime=syear+smonth+sday+shour
    
    eday="01"
   ehour="23"
   etime=syear+smonth+eday+ehour

  ; create a timeaxis
  hourlist = fspan(0,24,49)
  ;   hours = hourlist(0:47)
     hours = hourlist
     mins = hours ; copy size
     mins = 30
  ;print(dimsizes(hours))
  ; create arrays
  years = 0*tointeger(hours)+tointeger(syear)
   mons = 0*tointeger(hours)+tointeger(smonth)
   days = 0*tointeger(hours)+tointeger(sday)
   secs = 0*tointeger(hours)

  do ii = 0,dimsizes(hours)-1
   ihr = hours(ii)
   if(mod(ihr,1) .eq. 0)then
     mins(ii) = 0
   else
    hours(ii) = hours(ii) - 0.5
   end if
  end do
  ;do ii = 0,dimsizes(hours)-1
  ; print(ii+"  "+hours(ii)+"  "+mins(ii))
  ;end do

     units = "hours since "+syear+"-"+smonth+"-"+sday+" 00:00:00"
  time = cd_inv_calendar(years,mons,days,tointeger(hours),tointeger(mins),secs,units,0)
  time!0 = "time"
  nsteps = dimsizes(time)
  print("nsteps = "+nsteps)

;************************************************
;
;************************************************

    ocnlist=systemfunc("ls "+rtsrc+"field_ocn_import_*.nc")
   forclist=systemfunc("ls "+rtsrc+"DATM_INPUT/"+runname+"."+syear+"*.nc")

  ;print(ocnlist)
  ;print(forclist)
  ;print(dimsizes(ocnlist))
   nhours = dimsizes(forclist)
  ;print(dimsizes(forclist))
  ; forcing data is 6 hourly
    nfout = 6
  ; the number of forcing files
  nfhours = dimsizes(ocnlist)/(2*nfout)
  ;print(nfhours)

   ocnfiles=addfiles(ocnlist,"r")
  forcfiles=addfiles(forclist(0:nfhours),"r")
  ;print(ocnlist)
  ;print(forclist(0:nfhours))

  ; ocn grid coords
  gocnx = addfile(rtsrc+"array_med_ocn_grid_coord1.nc","r")
  gocny = addfile(rtsrc+"array_med_ocn_grid_coord2.nc","r")
  ; ocn coords
  ocnlon=gocnx->lon_center
  ocnlat=gocny->lat_center
  ocnlon@units = "degrees_east"
  ocnlat@units = "degrees_north"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 4
    fldname = forcflds(fldtoplot)
   ofldname = ocnflds(fldtoplot)
   wkstitle = fldname
  ; special settings
  owgt =  ocnwgts(fldtoplot)
  fwgt = forcwgts(fldtoplot)
  print(fldname+" "+fwgt)
  print(ofldname+" "+owgt)
  
  ; pick lat/lon
  xlon = 170.0
  xlat =  20.0
  ; nearest pt on ocn grid 
  ij = getind_latlon2d(ocnlat,ocnlon,xlat,xlon)
  ;print(ij)
  ilat = ij(0,0)
  ilon = ij(0,1)
  print(ilat+" "+ilon)

  ; ocn import
  ocnpt = new((/nsteps/),float,default_fillvalue("float"))
  ocnpt = tofloat(ocnfiles[:]->$ofldname$(0:nsteps-1,ilat,ilon))
  ocnpt(nsteps-1) = default_fillvalue("float")
  ;print(time+"   "+ocnpt)
  ocnpt = ocnpt*owgt
  ocnpt!0 = "time"
  ocnpt&time = time
  ; the first ocn import file (at 00:00:00) is empty
  ocnpt(0) = default_fillvalue("float")
  ;printVarSummary(ocnpt)

  ; forcing
  fpt = forcfiles[:]->$fldname$(:,{xlat},{xlon})
  fpt@_FillValue = default_fillvalue(typeof(fpt))
  fpt = fpt*fwgt
  ;print(dimsizes(fpt))

  ntot = 2
  data_all = new((/ntot,dimsizes(time)/),float)
  ;print(dimsizes(data_all))
  ;print(time(0::2*nfout))

  data_all(0,:) = ocnpt
  data_all(1,0::2*nfout) = fpt(:)
 
  ;print(time(0::2*nfout)+"   "+data_all(0,::12))
  print(time+"   "+data_all(0,:)+"  "+data_all(1,:))

 ;labelstring = var@long_name+" ("+var@units+")"
 ;print(labelstring) 
 colors = (/"red", "blue"/)

;************************************************
;
;************************************************

 legendlabs = new((/ntot/),"string")
 legenddesc = new((/ntot/),"string")
 legendcols = new((/ntot/),"string")
 legendthik = new((/ntot/),"float")
 legenddash = new((/ntot/),"integer")
 do ii = 0,ntot-1
  ;legendlabs(ii) = RunLabs(ii)+RunDesc(ii)
  legendcols(ii) =  colors(ii)
  ;legendthik(ii) =  2.0
  ;legenddash(ii) =  0
  ;print(ii+" "+RunLabs(ii))
 end do

 ;print(legendlabs)
 ;print(legendcols)

;************************************************
;
;************************************************

  wkstype="X11"
  wkstitle=runname
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file
  
  ;drawNDCGrid(wks)

   plot = new(1  ,graphic)

 npanels = 1

;************************************************
;---Set plotting parameters
;************************************************

 res                   = True                      ; plot mods desired
 res@vpWidthF          = 0.70
 res@vpHeightF         = 0.30
 res@xyLineThicknessF  = 2.0
 ;res@tiYAxisString     = labelstring

 res@gsnDraw  = False
 res@gsnFrame = False
 res@gsnPaperOrientation = "auto"
 res@gsnMaximize = True
 res@xyXStyle  = "Time"

; 	default Format = "0@*+^sg"
; if(varname .eq. "exmod" .or. varname .eq. "armod")then
; res@tmYLFormat = "0*+^e"	; use "e" symbol, don't force 0's (see documentation)
; end if
; res@tmYLMinorOn = False	; turn the minor tick marks off
; res@tmXBPrecision = 6		; set the precision to 6 significant digits

; res@trXMaxF = max(time)
; res@trXMinF = min(time)
 ;if(varname .ne. "tsfc" .and. varname .ne. "sst")then
 ; res@trYMinF = 0.0
 ;end if
 ;if(varname .eq. "sst")then
 ; res@trYMaxF = 6.0
 ;end if

 ;if(varname .eq. "hpond" .or. varname .eq. "hpond_ai")then
 ; res@trYMaxF = 0.2
 ; res@trYMinF = 0.0
 ;end if
 ;if(varname .eq. "meltt")then
 ; res@trYMaxF = 6.0
 ;end if

 ;restick = True
 ;restick@ttmFormat = "%H%M"
 ;restick@ttmValues = time
 ;time_axis_labels(time,res,restick)

;***********************************************
; legend resources
;***********************************************

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.30                  ; width of legend (NDC)
  lgres@vpHeightF            = 0.12                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  ;lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = ntot
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  ;lgres@lgLineThicknesses    = legendthik
  ;lgres@lgLineLabelStrings   = legendlabs
  ;lgres@lgLabelFontHeightF   = 0.20

  ;lgres@lgMonoLineLabelFontColor = True               ; one label color

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
  ;lineres@lgLineThicknesses = legendthik      ; line thicknesses

;************************************************
; Make the plot
;************************************************

  ; mmax = max(data_all(:,:))
  ; mmin = min(data_all(:,:))
  ; res@trYMinF = mmin
  ; res@trYMaxF = mmax

 res@xyMarkLineModes   = "Markers"                ; choose which have markers
 res@xyMarkers         =  16                      ; choose type of marker  
 res@xyMarkerColor     = "red"                    ; Marker color
 res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)
 plot(0) = gsn_csm_xy (wks,time,data_all( 1,:),res) ; create plot

 res@xyMarkLineModes   = "MarkLines"                ; choose which have markers
 res@xyMarkers         =  16                      ; choose type of marker  
 res@xyMarkerColor     = "blue"                    ; Marker color
 res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)
 oplot = gsn_csm_xy (wks,time,data_all( 0,:),res) ; create plot
 overlay(plot,oplot)

  xx = 0.60
  yy = 0.15
  ;gsn_legend_ndc(wks,ntot,legendlabs,xx,yy,lgres)
;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  gsn_panel(wks,plot,(/1,1/),resP)           ; now draw as one plot

;************************************************
;
;************************************************

  ;xx = 0.80
  ;yy = 0.10
  ;gsn_legend_ndc(wks,ntot,legendlabs,xx,yy,lgres)

  ;gsn_panel(wks,plot,(/nrows,ncols/),resP)           ; now draw as one plot
  ;simple_legend_ndc(wks, genres, lineres, textres)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if
;end if
exit
end
