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
  rtsrc = RT2+"DATM/rtgen.276629/tmp/cpld_datm_mom6_cice5_2d_cfsr/"
  ;rtsrc= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/DATM/fixclock/tmp/cpld_datm_mom6_cice5_2d_"+runname+"/"
  ;rtsrc= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/DATM/nofix/tmp/cpld_datm_mom6_cice5_2d_"+runname+"/"
 
  atmflds = (/"mean_zonal_moment_flx_atm",      \
              "mean_merid_moment_flx_atm",      \
              "mean_down_sw_vis_dir_flx",    \
              "mean_sensi_heat_flx",        \
              "mean_laten_heat_flx",             \
              "mean_prec_rate"             \
              /)

  atmwgts = (/1.0, \
              1.0, \
              1.0, \
              1.0, \
              1.0, \
              3600.0/)


  forcflds = (/"dusfc",         \
               "dvsfc",         \
               "vbdsf_ave",     \
               "shtfl_ave",     \
               "lhtfl_ave",     \
               "precp"         \
              /)

  forcwgts = (/1.0, \
               1.0, \
               0.94, \       ; albedo = 0.06
               1.0, \
               1.0, \
               3600.0/)

  nflds = dimsizes(forcflds)
  print(nflds)
;************************************************
; create an 'hour-minute' time axis
;************************************************

  atmlist=systemfunc("ls "+rtsrc+"field_atm_exporta_*.nc")
 ;print(atmlist)
  nfiles = dimsizes(atmlist)

  fdates = str_get_cols(atmlist, -22,-13)
  ftimes = str_get_cols(atmlist, -11, -4)
  print(fdates+" "+ftimes)

   years = stringtointeger(str_get_cols(fdates,0,3))
  months = stringtointeger(str_get_cols(fdates,5,6))
    days = stringtointeger(str_get_cols(fdates,8,9))
   hours = stringtointeger(str_get_cols(ftimes,0,1))
  minuts = stringtointeger(str_get_cols(ftimes,3,4))
    secs = stringtointeger(str_get_cols(ftimes,6,7))

   syear =  years(0)
  smonth = months(0)
    sday =   days(0)

     units = "hours since "+syear+"-"+smonth+"-"+sday+" 00:00:00"
  time = cd_inv_calendar(years,months,days,hours,minuts,secs,units,0)
  time!0 = "time"
  nsteps = dimsizes(time)
  ;print("nsteps = "+nsteps)
  print(time)
  ;print(time(0::24))

 forclist=systemfunc("ls "+rtsrc+"DATM_INPUT/"+runname+"."+syear+"*.nc")
;************************************************
;
;************************************************

  ;print(atmlist)
  ;print(forclist)
  ;print(dimsizes(atmlist))
   nhours = dimsizes(forclist)
  ;print(dimsizes(forclist))
  ; forcing data is 6 hourly
    nfout = 6
  ; atm export is 4x/hour
   nfexp = 4
  ; the number of forcing files
  nfhours = dimsizes(atmlist)/(nfexp*nfout)
  print("nfhours = "+nfhours)

   atmfiles=addfiles(atmlist,"r")
  forcfiles=addfiles(forclist(0:nfhours),"r")
  ;print(atmlist)
  print(forclist(0:nfhours))

  ; atm grid coords
  gatmx = addfile(rtsrc+"array_med_atm_grid_coord1.nc","r")
  gatmy = addfile(rtsrc+"array_med_atm_grid_coord2.nc","r")
  ; atm coords
  atmlon=gatmx->lon_center
  atmlat=gatmy->lat_center
  atmlon@units = "degrees_east"
  atmlat@units = "degrees_north"

  ; pick lat/lon
  xlon = 100.0
  xlat =  34.0
  ; nearest pt on atm grid 
  ij = getind_latlon2d(atmlat,atmlon,xlat,xlon)
  ;print(ij)
  ;ilat = ij(0,0)
  ;ilon = ij(0,1)
  ilat = 600
  ilon = 1000
  print(ilat+" "+ilon)
  print(atmlat(ilat,ilon)+"  "+atmlon(ilat,ilon))
  pltlab = "Values at : "+sprintf("%5.2f",atmlat(ilat,ilon))+"N, "+sprintf("%5.2f",atmlon(ilat,ilon))+"E"

;************************************************
;
;************************************************

  ntot = 2
  data_all = new((/nflds,ntot,dimsizes(time)/),float)
     ylabs = new((/nflds/),string)
  print(dimsizes(data_all))
  atmpt = new((/nsteps/),float,default_fillvalue("float"))

  ;ii =3
  do ii = 0,nflds-1
  fldtoplot = ii
    fldname = forcflds(fldtoplot)
   afldname = atmflds(fldtoplot)
   wkstitle = fldname
  ; special settings
  awgt =  atmwgts(fldtoplot)
  fwgt = forcwgts(fldtoplot)
  ;print(fldname+" "+fwgt)
  ;print(afldname+" "+awgt)

  ; atm export
  atmpt = tofloat(atmfiles[:]->$afldname$(0:nsteps-1,ilat,ilon))
  atmpt(nsteps-1) = default_fillvalue("float")
  ;print(time+"   "+atmpt)
  atmpt = atmpt*awgt
  atmpt!0 = "time"
  atmpt&time = time
  ;printVarSummary(atmpt)

  ; forcing
  ;fpt = forcfiles[:]->$fldname$(:,{xlat},{xlon})
  fpt = forcfiles[:]->$fldname$(:,ilat,ilon)
  fpt@_FillValue = default_fillvalue(typeof(fpt))
  fpt = fpt*fwgt
  labstr = fpt@long_name
  ylabs(ii) = labstr
  ;print(ii+"  "+ylabs(ii))
  ;print(dimsizes(fpt))
  ;print(fpt)

  ;print(time(0::2*nfout))

  data_all(ii,0,         :) = atmpt
  data_all(ii,1,0::nfexp*nfout) = fpt
  ;print(time+"   "+data_all(ii,0,:)+"  "+data_all(ii,1,:))
 end do
;if(1 .eq. 0)then
;************************************************
;
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstitle=runname
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file
  
  ;drawNDCGrid(wks)

   plot = new(nflds, graphic)
  oplot = new(nflds, graphic)

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

;************************************************
; Make the plot
;************************************************

;lbeg = 10-1
;lend = 56-1
lbeg = 0
lend = nsteps-1
do ii = 0,nflds-1
 miny = min(data_all(ii,:,lbeg:lend))
 maxy = max(data_all(ii,:,lbeg:lend))
 ;print(miny+" "+maxy)
 res@trYMaxF = maxy
 res@trYMinF = miny

 res@xyMarkLineModes   = "Markers"                ; choose which have markers
 res@xyMarkers         =  16                      ; choose type of marker  
 res@xyMarkerColor     = "black"                    ; Marker color
 res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)
 ;res@xyMarkLineModes   = "Lines"                ; choose which have markers
 res@tiYAxisString     = ylabs(ii)
 plot(ii) = gsn_csm_xy (wks,time(lbeg:lend),data_all(ii, 0,lbeg:lend),res) ; create plot

 res@xyMarkLineModes   = "Markers"                ; choose which have markers
 res@xyMarkers         =  4                       ; choose type of marker  
 res@xyMarkerColor     = "blue"                    ; Marker color
 res@xyMarkerSizeF     = 0.02                     ; Marker size (default 0.01)
 res@xyMarkerThicknessF = 1.10                     ; Marker size (default 0.01)
 oplot(ii) = gsn_csm_xy (wks,time(lbeg:lend),data_all(ii, 1,lbeg:lend),res) ; create plot
overlay(plot(ii),oplot(ii))
end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelXWhiteSpacePercent = 5
  ;resP@gsnPanelCenter      = False

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = pltlab

  gsn_panel(wks,plot,(/3,2/),resP)           ; now draw as one plot

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if
;end if
exit
end
