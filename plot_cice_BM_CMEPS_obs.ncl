;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;************************************************
begin

  batch = "no"
  ;batch = "yes"

 if(batch .eq. "no")then
 ; hemi = "NH"
  hemi = "SH"
   varname = "aice"
 ;  varname = "hi"
 end if

 ice_extent = "yes"
 ;ice_extent = "no"

  if(hemi .eq. "NH")then
    minlat =  50.0
    midlon = -45.0
   if(ice_extent .eq. "yes")then
    plottitle = "Northern Hemisphere Ice Extent (ocean area with ice>15%)"
   else 
    plottitle = "Total Ice Area North of 50N"
   end if       
  else
    maxlat = -50.0
    midlon =   0.0       
   if(ice_extent .eq. "yes")then
    plottitle = "Southern Hemisphere Ice Extent (ocean area with ice>15%)"
   else
    plottitle = "Total Ice Area South of 50S"
   end if
  end if

  if(varname .eq. "aice")then
    vartitle = "Ice Concentration"
  else
   vartitle = "Ice Thickness"
  end if

  ;idates = (/"20120701"/)
  ;idates = (/"20120701", "20121001"/)
  idates = (/"20120101", "20120401", "20120701", "20121001"/)
  ndates = dimsizes(idates)

  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************

   ; +1 for obs
   if(ice_extent .eq. "yes")then
     nruns = 4+1
   else
     nruns = 4
   end if
   rtname1 = "NEMS-BM1"
    rtsrc1 = RT2+"BM1_ice/"
   rtname2 = "CMEPS-BM1 original"
    rtsrc2 = RT2+"CMEPS_ice/"
   ; these files do not contain 35 days
   rtname3 = "CMEPS-BM1 new"
    rtsrc3 = RT2+"CMEPS_ice_new/"
   rtname4 = "NEMS-BM2"
    rtsrc4 = RT2+"BM2_ice/"

   ; obs file, with beginning index matching the idates for NSIDC
    obssrc = "/scratch3/NCEPDEV/marine/save/Denise.Worthen/IceData/iceobs_stats.nc"
      lbeg = (/548-1, 640-1/) ;2012
   rtname5 = "NSIDC v3.0 Daily Ice Extent"

        bm1list = rtsrc1+"dm_"+varname+"_h."+idates+".nc"
        cm1list = rtsrc2+"dm_"+varname+"_h."+idates+".nc"
        cm2list = rtsrc3+"dm_"+varname+"_h."+idates+".nc"
        bm2list = rtsrc4+"dm_"+varname+"_h."+idates+".nc"

   tlatname = "TLAT"
   tlonname = "TLON"
    rfactor = 1.0

  ;print(bm1list)
  ;print(cm1list)
  ;print(cm2list)
  ;print(bm2list)

;************************************************
;
;************************************************

 legendlabs = new((/nruns/),"string")
 legendcols = new((/nruns/),"string")
 legendthik = new((/nruns/),"float")
 legenddash = new((/nruns/),"integer")


  colors = (/"red",  "blue", "green", "magenta", "black"/)

   legendlabs(0) = rtname1 
   legendlabs(1) = rtname2 
   legendlabs(2) = rtname3 
   legendlabs(3) = rtname4 
 do ii = 0,nruns-1
  legendcols(ii) =  colors(ii)
  legendthik(ii) =  2.0
  legenddash(ii) =  0
 end do
 if(ice_extent .eq. "yes")then
   legendlabs(4) = rtname5 
 ; change thickness and dash for final (obs) line
 ii = nruns-1
  legendthik(ii) =  4.0
  legenddash(ii) =  2
 end if

;************************************************
; set up plotting
;************************************************

  wkstitle = hemi+"."+varname
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  ; wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)

  ; add a panel spot for the legend
  npanels=ndates+1
  plot = new(ndates+1,graphic)

  res                   = True                      ; plot mods desired
  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.30
  res@xyLineThicknessF  = legendthik

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
  lgres@vpWidthF             = 0.2                   ; width of legend (NDC)
  lgres@vpHeightF            = 0.10                  ; height of legend (NDC)

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

 maxdays = 35
 ; ndays days (4x/day)
 lstep=maxdays

 nd = 0
 ; do nd = 0,1
  do nd = 0,ndates-1
   bm1files = addfiles(bm1list(nd),"r")
   cm1files = addfiles(cm1list(nd),"r")
   cm2files = addfiles(cm2list(nd),"r")
   bm2files = addfiles(bm2list(nd),"r")

   if(ice_extent .eq. "yes")then
    obsfile = addfile(obssrc,"r")
   end if

  ; retrieve the time axis
         times = bm1files[:]->time
     timeUnits = bm1files[0]->time@units
  timeCalendar = bm1files[0]->time@calendar

 ;     timetics = cd_string(times(::14),"%D%C")
      timetics = cd_string(times,"%D%C")
 ; print(timetics)
 ; print(times)

  res@trXMaxF = max(times-times(0))
  res@trXMinF = min(times-times(0))

  res@xyLineColors  = colors
  res@xyDashPatterns = (/0,0,0,0,1/)
  ;restick = True
  ;restick@ttmFormat = "%D%C"
  ;restick@ttmValues = timetics
  ;time_axis_labels(timetics,res,restick)
  res@tiXAxisString    = "days since "+idates(nd)              ; y axis title

;************************************************
; files contain 140 timesteps (6 hour means)
;************************************************

     vname = varname+"_h"
  ; these all contain 35 days 
    bm1 =  bm1files[:]->$vname$
    cm1 =  cm1files[:]->$vname$
    bm2 =  bm2files[:]->$vname$
  ; these contains fewer timesteps
     dims = dimsizes(cm2files[:]->$vname$)
  print(dims)
  ; a copy of cm1 to set the dimension
      cm2 = 0.0*cm1
     lmax = dims(0)
   cm2(0:lmax-1,:,:)     = cm2files[:]->$vname$(:,:,:)
   cm2(lmax:lstep-1,:,:) = cm2@_FillValue
 ;print(cm2(:,157,706))
 delete(dims)

   dims = dimsizes(bm1)
  tarea = bm1files[0]->tarea
  lat2d = bm1files[0]->TLAT
   tdim = dims(0)
  ;print(tdim)

  masklat = new((/dimsizes(tarea)/),typeof(bm1))
  if(hemi .eq. "NH")then
   masklat = where(lat2d .ge. minlat,tarea,masklat@_FillValue)
  else
   masklat = where(lat2d .le. maxlat,tarea,masklat@_FillValue)
  end if
  ; add a time dimension for simple math
  masklat3 = conform_dims(dimsizes(bm1),masklat,(/1,2/))
  ;print(dimsizes(masklat3))
  
   if(ice_extent .eq. "yes")then
   ; these are ice extents (all ice area>0.15) 
     bm1 = where(bm1 .ge. 0.15,masklat3,bm1@_FillValue)
     cm1 = where(cm1 .ge. 0.15,masklat3,cm1@_FillValue)
     cm2 = where(cm2 .ge. 0.15,masklat3,cm2@_FillValue)
     bm2 = where(bm2 .ge. 0.15,masklat3,bm2@_FillValue)
   else
   ;these are ice areas (include aice_h in area sum) 
     bm1 = where(bm1 .ge. 0.15,bm1*masklat3,bm1@_FillValue)
     cm1 = where(cm1 .ge. 0.15,cm1*masklat3,cm1@_FillValue)
     cm2 = where(cm2 .ge. 0.15,cm2*masklat3,cm2@_FillValue)
     bm2 = where(bm2 .ge. 0.15,bm2*masklat3,bm2@_FillValue)
   end if

         data_all = new((/nruns,dimsizes(bm1&time)/),float)
    data_all(0,:) = dim_sum_n(   bm1,(/1,2/))/1.0e12
    data_all(1,:) = dim_sum_n(   cm1,(/1,2/))/1.0e12
    data_all(2,:) = dim_sum_n(   cm2,(/1,2/))/1.0e12
    data_all(3,:) = dim_sum_n(   bm2,(/1,2/))/1.0e12

   if(ice_extent .eq. "yes")then
    ; add obs for right hemi
    if(hemi .eq. "NH")then
     nsidc = obsfile->exnsidc(:,0)
    else
     nsidc = obsfile->exnsidc(:,1)
    end if
    ; print(nsidc(lbeg(nd):lbeg(nd)+maxdays-1))
    data_all(4,:) = nsidc(lbeg(nd):lbeg(nd)+maxdays-1)
   end if

   ;print(idates(nd)+"   "+hemi)
   ;do ll = 0,tdim-1
   ; print(ll+"  "+data_all(0,ll)+"  "+data_all(1,ll)+"  "+data_all(2,ll)+"  "+data_all(3,ll)+"  "+data_all(4,ll))
   ;end do

    plot(nd) = gsn_csm_xy (wks,bm1&time-times(0),data_all,res) ; create plot
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
