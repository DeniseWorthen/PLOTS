;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************
begin
 ; print(model)
 ; print(zlevel)

 ;batch = "yes"
 batch = "no"

;************************************************
; arrays for depth dependent contour levels
;************************************************

  ;tlevs_polar(0,:) = (/ (/   0.0, -1.5,  1.5,  .050/) /)
  ;tlevs_polar(3,:) = (/ (/ 500.0, -0.2,  1.0,  .020/) /)

  tlevs_polar = new((/5,4/),float)
  ;tlevs_polar(0,:) = (/ (/   0.0, -1.8, -1.2,  .010/) /)
  ;tlevs_polar(0,:) = (/ (/   0.0, -1.8,  4.0,  .200/) /)
  tlevs_polar(0,:) = (/ (/ 100.0, -1.72,  -1.2,  .010/) /)
  tlevs_polar(1,:) = (/ (/ 100.0, -1.4,   0.6,  .020/) /)
  tlevs_polar(2,:) = (/ (/ 200.0, -0.2,  3.0,  .050/) /)
  ;tlevs_polar(3,:) = (/ (/ 500.0, -0.8,  2.4,  .050/) /)
  tlevs_polar(3,:) = (/ (/ 500.0, 0.0,  1.2,  .020/) /)
  tlevs_polar(4,:) = (/ (/1000.0, -0.7,  0.7,  .025/) /)

  slevs_polar = new((/5,4/),float)
  slevs_polar(0,:) = (/ (/   0.0, 28.40,  35.20,  0.200/) /)
  ;slevs_polar(1,:) = (/ (/ 100.0, 30.40,  32.50,  0.020/) /)
  slevs_polar(1,:) = (/ (/ 100.0, 31.60,  34.80,  0.050/) /)
  slevs_polar(2,:) = (/ (/ 200.0, 33.50,  35.10,  0.025/) /)
  ;slevs_polar(3,:) = (/ (/ 500.0, 34.60,  35.02,  0.010/) /)
  slevs_polar(3,:) = (/ (/ 500.0, 34.80,  35.00,  0.005/) /)
  slevs_polar(4,:) = (/ (/1000.0, 34.86,  34.94,  0.002/) /)

;************************************************
; set up
;************************************************

  if(batch .eq. "no")then
   ;model="phc3"
   model="woa13"
  end if

  region = "polar"
  ;region = "GIN"

  ; whether to plot variables regridded to rectilinear using weights file
  ;regridded = "yes"
  regridded = "no"

  if(model .eq. "phc3")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/phc3/"
     runnam="PHC3.0"
   t_ocnsrc="phc3.0_annual_fixed"
   s_ocnsrc="phc3.0_annual_fixed"
   ;t_ocnsrc="phc3.0_monthly_fixed"
   ;s_ocnsrc="phc3.0_monthly_fixed"

        tname="temp"
        sname="salt"
   ocnlonname="lon"
   ocnlatname="lat"
   zcoordname="depth"
         kmax=33-1
  end if

  if(model .eq. "woa13")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/woa13/"
     runnam="WOA13"
   t_ocnsrc="woa13_annualTS"
   s_ocnsrc="woa13_annualTS"

        tname="t_an"
        sname="s_an"
   ocnlonname="lon"
   ocnlatname="lat"
   zcoordname="depth"
         kmax=102-1
  end if

  if(model .eq. "gdem3")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/gdem3/"
     runnam="GDEM3"
   t_ocnsrc="t_m10"
   s_ocnsrc="s_m10"

        tname="Potential_Temperature"
        sname="Salinity"
   ocnlonname="longitude"
   ocnlatname="latitude"
   zcoordname="depth"
         kmax=78-1
  end if

  t_ocnfile=addfile(rtsrc+t_ocnsrc+".nc","r")
  s_ocnfile=addfile(rtsrc+s_ocnsrc+".nc","r")
  print(t_ocnsrc)

;************************************************
; load an ocn field
;************************************************

  lstep=1-1
  if(batch .eq. "no")then
   ;  zlevel to plot
   zlevel = 0.0
   ;zlevel = 10.0
   ;zlevel = 50.0
   ;zlevel = 100.0
   ;zlevel = 250.0
   ;zlevel = 500.0
   ;zlevel = 1000.0
  end if

  ; ocean depths
      odepth=t_ocnfile->$zcoordname$
  ; find the k index closest to the zlevel depth
       kstep=closest_val(zlevel,odepth)
        tvar=t_ocnfile->$tname$(lstep,kstep,:,:)
        svar=s_ocnfile->$sname$(lstep,kstep,:,:)
       depth=odepth(kstep)
  print("depth = "+depth)

   tvar@lon=t_ocnfile->$ocnlonname$
   tvar@lat=t_ocnfile->$ocnlatname$
   svar@lon=s_ocnfile->$ocnlonname$
   svar@lat=s_ocnfile->$ocnlatname$
  ; already on rectilinear grid
       tvar_regrid = tvar
       svar_regrid = svar

  ;plottitle=rtsrc+t_ocnsrc+",  z="+depth
  ;plottitle=rtsrc+t_ocnsrc
  plottitle=model
  ;plottitle=t_ocnsrc+",  z="+depth
  wkstitle=model+"_z"+zlevel

  tvar@units=""
  tvar@long_name=""
  svar@units=""
  svar@long_name=""

;************************************************
; set appropriate levels
;************************************************

  if(region .eq. "polar")then
   ; pick the values appropriate for this depth
   klev=closest_val(zlevel,tlevs_polar(:,0))
   tlevs=tlevs_polar(klev,1:3)
   slevs=slevs_polar(klev,1:3)
  end if

  print("found contour intervals at klev = "+klev+" for depth "+zlevel)
  ;print(tlevs)
  ;print(slevs)

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)             
  ;drawNDCGrid(wks)

  plot = new(2,graphic)
 oplot = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = False
  res@cnFillMode           = "MeshFill"
  ;res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@gsnPolar     = "NH"                   ; specify the hemisphere
  res@mpMinLatF    =  66                    ; minimum lat to plot
  ;res@mpMinLatF    =  85                    ; minimum lat to plot
  res@mpCenterLonF = -45
  res@mpGreatCircleLinesOn = True

  ;res@cnFillPalette   =  "cmp_b2r"                         ; choose colormap
  ;res@cnFillPalette   =  "NCV_blu_red"                     ; choose colormap
  res@cnFillPalette   =  "MPL_rainbow"                      ; choose colormap

;************************************************
; Resources for the polyline
;************************************************

  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
; Resources for the x-section polyline
;************************************************

  xres1                   = True          ; polyline mods desired
  xres1@gsLineThicknessF  = 4.0           ; line thickness
  xres1@gsLineColor       = "blue"        ; color of lines
  xres1@gsLineDashPattern =  2            ; short dashes

  xres2                   = True          ; polyline mods desired
  xres2@gsLineThicknessF  = 4.0           ; line thickness
  xres2@gsLineColor       = "black"       ; color of lines
  xres2@gsLineDashPattern =  2            ; short dashes

;************************************************
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnLevelSelectionMode = "EqualSpacedLevels"     ; set the contour levels with the following 3 resources

;************************************************
; the subplot call
;************************************************

function subplot(ii,scalarfield)
begin
   ; pick the scalar field
   if(scalarfield .eq. "temperature")then
    if(regridded .eq. "yes")then
     pltvar=tvar_regrid
    else
     pltvar=tvar
    end if
     pltlev=tlevs
     ores@cnLevels = (/1.8/)
   end if

   if(scalarfield .eq. "salinity")then
    if(regridded .eq. "yes")then
     pltvar=svar_regrid
    else
     pltvar=svar
    end if
     pltlev=slevs
     ores@cnLevels = (/34.98/)
   end if

   ;res@gsnCenterString = scalarfield+" z="+sprintf("%5.0f", depth)
   ;res@gsnCenterStringFontHeightF = 0.02

   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   res@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   res@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   res@cnLevelSpacingF = pltlev(2)                      ; set the interval between contours

   ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   ;ores@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   ;ores@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   ;ores@cnLevelSpacingF = 2.0                            ; set the interval between contours

    plot(ii) = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   oplot(ii) = gsn_csm_contour(wks,pltvar,ores)             ; create the plot
     ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
       xlon1 = 210.00
       xlon2 =  30.00
  ;  xum1(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres1)
  ; add a second 
       xlon1 = 140.00
       xlon2 = 345.00
   ; xum2(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres2)
   ;overlay(plot(ii),oplot(ii))
   return(plot(ii))
end
;************************************************
;
;************************************************

  ii = 0
  plot(ii) = subplot(ii,"temperature")    ; create the plot
  ;ii = 1
  ;plot(ii) = subplot(ii,   "salinity")    ; create the plot

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.008                     ; font smaller. default big

  xx = 0.5
  yy = 0.15
; page coordinates are normalized. go from 0->1 not 0->8" etc.
   gsn_text_ndc(wks,rtsrc+t_ocnsrc,xx,yy,txres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
   
  resP@gsnPanelMainString  = plottitle
  ;resP@gsnPanelMainString  = runnam
  resP@gsnPanelMainFontHeightF = 0.018            ; new resource added in NCL V6.4.0

  ;resP@txFontHeightF = .015
  ;resP@txString = plottitle
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

  if(batch .eq. "yes")then
   imcmd = "convert "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
