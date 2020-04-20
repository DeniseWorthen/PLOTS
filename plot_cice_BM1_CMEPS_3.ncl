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
 ; hemi = "wedge"

  ;minlat =  -78.0
  ;maxlat =  -68.0
  ;minlon = -50.0
  ;maxlon =  50.0
  ;minlon = -130.0
  ;maxlon = -100.0

 ;  cdate = "20121001"
   cdate = "20120701"
 ;   cdate = "20120401"
 ;   cdate = "20120101"
   varname = "aice"
 ;  varname = "hi"
  tlonname = "TLON"
  tlatname = "TLAT"
  rfactor = 1.0

  ; pick 6hr mean
  ;lstep =  1-1
  ; final 6hr mean
  ;lstep = 140 - 1
  ;lstep = 99 - 1
  lstep = 35 - 1
 end if

  if(hemi .eq. "wedge")then
   minlat =  -78.0
   maxlat =  -68.0
   ;minlon = -50.0
   ;maxlon =  50.0
   minlon = -130.0
   maxlon = -100.0
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0       
   else
    maxlat = -50.0
    midlon =   0.0       
   end if
  end if

  if(varname .eq. "aice")then
   fancylevs = "yes"
   ;fancylevs = "no"
    vartitle = "Ice Concentration"
  else
   fancylevs = "no"
   vartitle = "Ice Thickness"
  end if

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************


   rtnems =  (/"BM1_ice/",   "BM2_ice/"/)
   rtcmeps = (/"CMEPS_ice/", "CMEPS_ice_new/"/)

    nemsnames = (/"NEMS-BM1",  "NEMS-BM2"/)
   cmepsnames = (/"CMEPS-BM1", "CMEPS-BM1-new"/)

    nemsf = addfiles(RT2+rtnems +"dm_"+varname+"_h."+cdate+".nc","r")
   cmepsf = addfiles(RT2+rtcmeps+"dm_"+varname+"_h."+cdate+".nc","r")

   iin = 1
   iic = 0
  ;iin = 1
  ; iic = 0

  print(rtnems(iin))
  print(rtcmeps(iic))

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

  wkstitle = hemi+"."+varname+"."+cdate+"."+sprinti("%2.2i", lstep)
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

    nrows = 1
    ncols = 1
     plot = new(2,graphic)
      dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillMode = "MeshFill"
  ;res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  if(hemi .eq. "wedge")then
   res@mpMinLatF          =  minlat      ; range to zoom in on
   res@mpMaxLatF          =  maxlat
   res@mpMinLonF          =  minlon
   res@mpMaxLonF          =  maxlon
  else
   res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
   end if
   if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat
   res@mpCenterLonF = 0.0
   end if
  end if

  res@gsnCenterStringOrthogonalPosF = .12           ; raise the CenterString slightly
  ;res@gsnPolarLabelFontHeightF = 0.020           ; change font height of labels
  res@gsnStringFontHeightF     = 0.025
  res@lbLabelFontHeightF       = 0.020

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
function subplot(name,pltvar,pltlevs,palette)
begin
 if(fancylevs .eq. "yes")then
  if(name .eq. "aice_h" .or. name .eq. "aice")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(name .eq. "hi_h" .or. name .eq. "hi")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   ;res@lbLabelAlignment     = "InteriorEdges"
  end if
  end if
 else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
 end if

   res@cnFillPalette            = palette
   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

  ;print(pltlevs)
  ;print(palette)

  if(hemi .eq. "wedge")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else 
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  delete(res@cnLevels)
  delete(res@lbLabelStrings)
  return(splot)
end
;************************************************
; 
;************************************************

         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)
           vname = varname+"_h"
         freturn = levscmapCICE(varname,hemi)
      pltlevs(:) = freturn[0]
      colormap   = freturn[1]

         times = nemsf[iin]->time
     timeUnits = nemsf[iin]->time@units
  timeCalendar = nemsf[iin]->time@calendar

     ii = 0
        icevar = nemsf[iin]->$vname$(lstep,:,:)
  icevar@lon2d = nemsf[iin]->$tlonname$*rfactor
  icevar@lat2d = nemsf[iin]->$tlatname$*rfactor
  labelstrings(ii) = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = nemsnames(iin)
  plot(ii) = subplot(vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

     ii = 1
        icevar = cmepsf[iic]->$vname$(lstep,:,:)
  icevar@lon2d = cmepsf[iic]->$tlonname$*rfactor
  icevar@lat2d = cmepsf[iic]->$tlatname$*rfactor
  labelstrings(ii) = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = cmepsnames(iic)
  plot(ii) = subplot(vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  ;resP@gsnPanelRowSpec     = True                ; tell panel what order to plot
  ;resP@gsnPanelCenter      = False               ; don't center

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = vartitle+"  "+cd_string(times(lstep),"%Y%N%D")+ " (initialized "+cd_string(times(0),"%Y%N%D")+")  "
  resP@gsnPanelMainString = vartitle+"  "+cd_string(times(lstep),"%Y%N%D")
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot

;************************************************
;
;************************************************

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
