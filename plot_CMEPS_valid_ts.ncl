;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

  load "levscmapCICE.ncl"
;************************************************
begin

  batch = "no"
 ; batch = "yes"

 if(batch .eq. "no")then
 ; hemi = "NH"
  hemi = "SH"
   varname = "aice"
 ;  varname = "hi"
 end if

  if(hemi .eq. "NH")then
    minlat =  50.0
    midlon = -45.0       
    plottitle = "Total Ice Area North of 50N"
  else
    maxlat = -50.0
    midlon =   0.0       
    plottitle = "Total Ice Area South of 50S"
  end if

  if(varname .eq. "aice")then
    vartitle = "Ice Concentration"
  else
   vartitle = "Ice Thickness"
  end if

  idates = (/"20120701", "20121001"/)
  ;idates = (/"20120101", "20120401", "20120701", "20121001"/)
  ndates = dimsizes(idates)

  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************

     nruns = 2
   rtname1 = "NEMS-BM1"
    rtsrc1 = RT2+"BM1_ice/"
   rtname2 = "CMEPS-BM1"
    rtsrc2 = RT2+"CMEPS_ice/"

   tlatname = "TLAT"
   tlonname = "TLON"
    rfactor = 1.0

   nemsfiles = rtsrc1+varname+"_h."+idates+".nc"
  cmepsfiles = rtsrc2+varname+"_h."+idates+".nc"
  print(nemsfiles)
  print(cmepsfiles)

;************************************************
;
;************************************************

  colors = (/"red",  "blue"/)

 legendlabs = new((/nruns/),"string")
 legendcols = new((/nruns/),"string")
 legendthik = new((/nruns/),"float")
 legenddash = new((/nruns/),"integer")

   legendlabs(0) = rtname1 
   legendlabs(1) = rtname2 
 do ii = 0,nruns-1
  legendcols(ii) =  colors(ii)
  legendthik(ii) =  2.0
  legenddash(ii) =  0
 end do

;************************************************
; set up plotting
;************************************************

  wkstitle = hemi+"."+varname
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)

  ; add a panel spot for the legend
  npanels=ndates+1
  plot = new(ndates+1,graphic)

  res                   = True                      ; plot mods desired
  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.30
  res@xyLineThicknessF  = 2.0

  res@tiYAxisString     = "Area (10~S~12~N~ m~S~2~N~)"
  ;res@tmYLFormat        = "0*+^e"       ; use "e" symbol, don't force 0's (see documentation)

  res@gsnDraw  = False
  res@gsnFrame = False

;       default Format = "0@*+^sg"
; if(varname .eq. "exmod" .or. varname .eq. "armod")then
; res@tmYLFormat = "0*+^e"       ; use "e" symbol, don't force 0's (see documentation)
; end if
; res@tmYLMinorOn = False        ; turn the minor tick marks off
 ;res@tmXBPrecision = 6          ; set the precision to 6 significant digits

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.1                   ; width of legend (NDC)
  lgres@vpHeightF            = 0.05                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = nruns
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  lgres@lgLineThicknesses    = legendthik
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgLabelFontHeightF   = 0.20

;************************************************
;
;************************************************

 ndays = 35
 ;ndays = 5
 ; ndays days (4x/day)
 lstep=ndays*4

 nd = 0
 ; do nd = 0,1
  do nd = 0,ndates-1
      nems = addfiles(nemsfiles(nd),"r")
     cmeps = addfiles(cmepsfiles(nd),"r")

  ; retrieve the time axis
         times = nems[:]->time(:lstep-1)
     timeUnits = nems[0]->time@units
  timeCalendar = nems[0]->time@calendar

 ;     timetics = cd_string(times(::14),"%D%C")
      timetics = cd_string(times,"%D%C")
 ; print(timetics)
 ; print(times)

  res@trXMaxF = max(times-times(0))
  res@trXMinF = min(times-times(0))

  res@xyLineColors  = colors
  res@xyDashPatterns = (/0,0/)
  ;restick = True
  ;restick@ttmFormat = "%D%C"
  ;restick@ttmValues = timetics
  ;time_axis_labels(timetics,res,restick)
  res@tiXAxisString    = "days since "+idates(nd)              ; y axis title

;************************************************
; files contain 140 timesteps (6 hour means)
;************************************************

     vname = varname+"_h"
   nemsice =  nems[:]->$vname$(:lstep-1,:,:)
  cmepsice = cmeps[:]->$vname$(:lstep-1,:,:)
  print(dimsizes(nemsice))

   dims = dimsizes(nemsice)
  tarea = nems[0]->tarea
  lat2d = nems[0]->TLAT
   tdim = dims(0)
  ;print(tdim)

       ni =  nemsice
       ci = cmepsice
    do ll = 0,tdim-1
     if(hemi .eq. "NH")then
      ni(ll,:,:) = where(lat2d .ge. minlat,ni(ll,:,:)*tarea(:,:),ni@_FillValue)
      ci(ll,:,:) = where(lat2d .ge. minlat,ci(ll,:,:)*tarea(:,:),ci@_FillValue)
     else
      ni(ll,:,:) = where(lat2d .le. maxlat,ni(ll,:,:)*tarea(:,:),ni@_FillValue)
      ci(ll,:,:) = where(lat2d .le. maxlat,ci(ll,:,:)*tarea(:,:),ci@_FillValue)
     end if
    end do
  ;printVarSummary(ni)
  ;printVarSummary(ci)
  ;print(dimsizes(ni&time))

         data_all = new((/2,dimsizes(ni&time)/),float)
    data_all(0,:) = dim_sum_n(ni,(/1,2/))/1.0e12
    data_all(1,:) = dim_sum_n(ci,(/1,2/))/1.0e12

   print(idates(nd)+"   "+hemi)
   do ll = 0,tdim-1
    print(ll+"  "+data_all(0,ll)+"  "+data_all(1,ll))
   end do

    plot(nd) = gsn_csm_xy (wks,ni&time-times(0),data_all,res) ; create plot
  end do

  xx = 0.50
  yy = 0.18
  gsn_legend_ndc(wks,nruns,legendlabs,xx,yy,lgres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  resP@gsnPanelMainString = plottitle
  resP@gsnPanelMainFontHeightF = 0.015
  gsn_panel(wks,plot,(/npanels,1/),resP)           ; now draw as one plot
  ;frame(wks)

exit
end
