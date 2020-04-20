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
  hemi = "NH"
 ; hemi = "SH"

  lstep = 35 - 1
 ; lstep = 1 - 1
 ;   cdate = "20120101"
    cdate = "20120401"
 ;  cdate = "20120701"
 ; cdate = "20121001"
   varname = "aice"

 end if

  tlonname = "TLON"
  tlatname = "TLAT"
  rfactor = 1.0

 if(hemi .eq. "NH")then
  minlat =  66.0
  midlon = -45.0       
 else
  maxlat = -50.0
  midlon =   0.0       
 end if

   fancylevs = "yes"
   ;fancylevs = "no"
    vartitle = "Ice Concentration"

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************

         rts =  (/"BM1_ice/",  "CMEPS_ice/", "BM2_ice/"/)
       files = addfiles(RT2+rts +"dm_"+varname+"_h."+cdate+".nc","r")
     rtnames = (/"NEMS-BM1", "CMEPS-BM1", "NEMS-BM2"/)

     ; get the lstep date in the files to set the obs date
          times = files[0]->time
      timeUnits = files[0]->time@units
   timeCalendar = files[0]->time@calendar
        obsdate = cd_string(times(lstep),"%Y%N%D")
        obsyear = cd_string(times(lstep),"%Y")
 
   print("using obsdate "+obsdate)
      obssrc = "/scratch3/NCEPDEV/marine/save/Denise.Worthen/IceData/"
   if(hemi .eq. "NH")then
      obsdir = "north/"+obsyear+"/seaice_conc_daily_nh_f17_"
    else
      obsdir = "south/"+obsyear+"/seaice_conc_daily_sh_f17_"
    end if
     icelonname="longitude"
     icelatname="latitude"

    ; obsvar="seaice_conc_cdr"
     obsvar="goddard_bt_seaice_conc"
     ;obsvar="goddard_nt_seaice_conc"
    ; obsvar="goddard_merged_seaice_conc"

    obsname = "Observed (Goddard BT)"
    ;obsname = "Observed (Goddard NT)"
      obsfile = addfile(obssrc+obsdir+obsdate+"_v03r01.nc","r")

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

  ;wkstitle = hemi+"."+varname+"."+cdate+"."+sprinti("%2.2i", lstep)
  wkstitle = hemi+"."+varname+"."+cdate
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

     plot = new(4,graphic)
      dum = new(4,graphic)

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

   res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  else
   res@mpMaxLatF    = maxlat
   res@mpCenterLonF = 0.0
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

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  delete(res@cnLevels)
  delete(res@lbLabelStrings)
  return(splot)
end
;************************************************
; 
;************************************************

         pltlevs = new((/3/),float)
    labelstrings = new((/3/),string)
           vname = varname+"_h"
         freturn = levscmapCICE(varname,hemi)
      pltlevs(:) = freturn[0]
      colormap   = freturn[1]

  
     ii = 0
        icevar = files[ii]->$vname$(lstep,:,:)
  icevar@lon2d = files[ii]->$tlonname$*rfactor
  icevar@lat2d = files[ii]->$tlatname$*rfactor
  labelstrings(ii) = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = rtnames(ii)
  plot(ii) = subplot(vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

     ii = 1
        icevar = files[ii]->$vname$(lstep,:,:)
  icevar@lon2d = files[ii]->$tlonname$*rfactor
  icevar@lat2d = files[ii]->$tlatname$*rfactor
  labelstrings(ii) = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = rtnames(ii)
  plot(ii) = subplot(vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

     ii = 2
        icevar = files[ii]->$vname$(lstep,:,:)
  icevar@lon2d = files[ii]->$tlonname$*rfactor
  icevar@lat2d = files[ii]->$tlatname$*rfactor
  labelstrings(ii) = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = rtnames(ii)
  plot(ii) = subplot(vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  delete(icevar)

     ii = 3
         icevar = obsfile->$obsvar$(0,:,:)
   icevar@lon2d = obsfile->$icelonname$
   icevar@lat2d = obsfile->$icelatname$
   labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  ;printVarSummary(icevar)
  ; reset to blank
  icevar@units=""
  icevar@long_name=""
  res@gsnCenterString = obsname

  ivar=byte2flt(icevar)
  copy_VarCoords(icevar,ivar)

  plot(ii) = subplot(vname,ivar(:,:),pltlevs,colormap)
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

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

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
