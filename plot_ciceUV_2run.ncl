;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  ; hera
  ;RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  ;RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  ; cheyenne
  RT2 = "/glade/scratch/worthen/FV3_RT/rt_27488/"

    hemi = "NH"
 ;   hemi = "SH"
 if(hemi .eq. "NH")then
  minlat =  76.0
  midlon = -45.0
 else
  maxlat = -50.0
  midlon =   0.0
 end if

   rad2deg = 180.d0/acos(-1.0d0)
   ;rfactor = rad2deg
   rfactor = 1.0

   vmag = 0.05
   vthn = 0.01

   uicename = "uvel_h"
   vicename = "vvel_h"
   iceulonname="ULON"
   iceulatname="ULAT"
   icemaskname="UMASK"
   tlatname = "TLAT"
   tlonname = "TLON"

;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "2021"
      cmon = "03"
      cday = "27"
      csec = "21600"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

      rts = (/"bgrid","cgrid"/)
     cset = "/history/"

     files = addfiles(RT2+rts+cset+"iceh_06h."+cyear+"-"+cmon+"-"+cday+"-"+csec+".nc","r")

     print(rts(1)+" - "+rts(0))
     plottitle=rts(1)+" - "+rts(0)

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

   rotang = files[0]->ANGLE

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"ice_diff")

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10              ; size of ref vector
  ;res@vcMonoLineArrowColor  = True             ; multiple colors desired
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  ;res@vcLineArrowThicknessF = 1.5
  res@vcGlyphStyle          = "CurlyVector"
  ;res@vcPositionMode = "ArrowTail"

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020

  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  ;print(pltlevs)
  ;print(palette)

  splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")+"@ "+csec+" secs "

;************************************************
;
;************************************************
 
    labelstrings = new((/2/),string)

     ii = 0
   uvar = files[ii]->$uicename$(lstep,:,:)
   vvar = files[ii]->$vicename$(lstep,:,:)
   uvar@lon2d=files[ii]->$iceulonname$*rfactor
   uvar@lat2d=files[ii]->$iceulatname$*rfactor
   vvar@lon2d=files[ii]->$iceulonname$*rfactor
   vvar@lat2d=files[ii]->$iceulatname$*rfactor
   printVarSummary(uvar)

   ; copy metadata
   urot = uvar
   vrot = vvar
   urot = cos(rotang)*uvar - sin(rotang)*vvar
   vrot = sin(rotang)*uvar + cos(rotang)*vvar
   urot = where(urot@lat2d .ge. minlat, urot, uvar@_FillValue)
   vrot = where(vrot@lat2d .ge. minlat, vrot, vvar@_FillValue)
   print("urot min = "+min(urot)+" urot max = "+max(urot))
   print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))

  plot(ii) = gsn_csm_vector_map_polar(wks,urot,vrot,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)


   ii = 1
   uvar = files[ii]->$uicename$(lstep,:,:)
   vvar = files[ii]->$vicename$(lstep,:,:)
   uvar@lon2d=files[ii]->$iceulonname$*rfactor
   uvar@lat2d=files[ii]->$iceulatname$*rfactor
   vvar@lon2d=files[ii]->$iceulonname$*rfactor
   vvar@lat2d=files[ii]->$iceulatname$*rfactor

   ; copy metadata
   urot = uvar
   vrot = vvar
   urot = cos(rotang)*uvar - sin(rotang)*vvar
   vrot = sin(rotang)*uvar + cos(rotang)*vvar
   urot = where(urot@lat2d .ge. minlat, urot, uvar@_FillValue)
   vrot = where(vrot@lat2d .ge. minlat, vrot, vvar@_FillValue)
   print("urot min = "+min(urot)+" urot max = "+max(urot))
   print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))

  plot(ii) = gsn_csm_vector_map_polar(wks,urot,vrot,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)
exit
end
