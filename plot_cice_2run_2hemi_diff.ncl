;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  ; orion
  RT1 = "/work/noaa/stmp/dworthen/stmp/dworthen/S2S_RT/"

 ;   hemi = "NH"
    hemi = "SH"
 if(hemi .eq. "NH")then
  minlat =  66.0
  midlon = -45.0       
 else
  maxlat = -50.0
  midlon =   0.0       
 end if

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "2012"
      cmon = "10"
      cday = "03"
      csec = "00000"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

      rts = (/"cice5","cice6"/)
     ; rts = (/"rt_58907/","rt_254013/"/)
     cset = "/cpld_fv3_ccpp_384_mom6_cice_cmeps_35d_"+cyear+cmon+"0100"+"/history/"

     files = addfiles(RT1+rts+cset+"iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc","r")

     print(rts(1)+" - "+rts(0))
     plottitle=rts(1)+" - "+rts(0)

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

  ; ice fields
  iceflds = (/"aice_h",   \
              "hi_h",     \
              "Tsfc_h",   \
              "snow_h",   \
              "flwup_h",  \
              "flat_h",   \
              "fsens_h",  \
              "fswdn_h",  \
              "flwdn_h",  \
              "fresh_h",  \
              "fhocn_h"   \
              /)
  nflds = dimsizes(iceflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.2,  0.2, 0.02/)   ; ai
  plotlevs( 1,:) = (/  -0.2,  0.2, 0.02/)   ; hi
  plotlevs( 2,:) = (/ -20.0, 20.0, 2.00/)   ; tsfc
  plotlevs( 3,:) = (/  -1.0,  1.0, 0.10/)   ; snow fall
  plotlevs( 4,:) = (/-120.0,120.0,10.00/)   ; lwup
  plotlevs( 5,:) = (/ -40.0, 40.0, 2.00/)  ; latent
  plotlevs( 6,:) = (/ -40.0, 40.0, 2.00/)  ; sensible
  plotlevs( 7,:) = (/-240.0,240.0,20.00/)  ; SW
  plotlevs( 8,:) = (/-100.0,100.0,10.00/)  ; LW
  plotlevs( 9,:) = (/  -4.0,  4.0, 0.20/)  ; fresh
  plotlevs(10,:) = (/ -10.0,  10.0, 0.50/)  ; fhocn

  cmap="BlueWhiteOrangeRed"

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
  wks   = gsn_open_wks (wkstype,"ice_inst_diff")

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat  
   res@mpCenterLonF = 0.0
  end if

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020     

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
function subplot(ii,name,pltvar,pltlevs,palette,hemi,lat0,lon0)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

    res@gsnPolar   =  hemi                         ; specify the hemisphere
    res@mpCenterLonF = lon0
   if(hemi .eq. "NH")then
    res@mpMinLatF    = lat0                       ; minimum lat to plot
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = lat0                           ; minimum lat to plot
   end if

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   delete(res@mpMinLatF)
   delete(res@mpMaxLatF)
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
  ;resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")+"@ "+csec+" secs "
  resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")

;************************************************
;
;************************************************
 
  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = iceflds(fldtoplot)
   wkstitle = "test"

        ii = 0
     vname = "aice_h"
  res@gsnCenterString  = vname

  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ivar@lon2d = files[0]->$tlonname$*rfactor
  ivar@lat2d = files[0]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

        ii = 1
     vname = "hi_h"
   pltlevs = (/-0.2,0.2,.01/)
  res@gsnCenterString  = vname

  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
 ; ivar = ivar*100.0   ; in cm
  ivar@lon2d = files[0]->$tlonname$*rfactor
  ivar@lat2d = files[0]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)
exit
end
