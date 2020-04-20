;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;************************************************
begin

  batch = "no"
 ; batch = "yes"

 if(batch .eq. "no")then
 ; hemi = "NH"
  hemi = "SH"

  cdate = "20120701"
 ; cdate = "20121001"

  tlonname = "lonT"
  tlatname = "latT"
  lstep = 35 - 1
 end if

 if(hemi .eq. "NH")then
  minlat =  66.0
  midlon = -45.0       
 else
  maxlat = -50.0
  midlon =   0.0       
 end if

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  grdsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/mom6_data/"
      gf = addfile(grdsrc+"grid_mom6_NEMS_mx025.nc","r")

;************************************************
; read in netCDF file
;************************************************
 ; default
    colormap = "MPL_rainbow"

 ; for overlay of ice concentration
       rtice =  (/"BM1_ice/",  "CMEPS_ice/", "BM2_ice/"/)
     icevars =  (/  "aice_h",      "aice_h",   "aice_h"/)
    icefiles = addfiles(RT2+rtice +"dm_"+icevars+"."+cdate+".nc","r")

 ; base plot either from ocn or ice
   ;base = "ocn"
   base = "ice"
       rtbase =  (/"BM1_"+base+"/",  "CMEPS_"+base+"/", "BM2_"+base+"/"/)
   ; basevars =  (/     "mld",         "mld",     "ePBL"/)
   ;     levs =  (/0.0, 150.0, 10.0/)

   ; basevars =  (/ "fresh_h",     "fresh_h",  "fresh_h"/)
   ;     levs =  (/-3.0, 3.0, 0.2/)
   ; colormap = "BlWhRe"

   ; basevars =  (/ "fhocn_h",     "fhocn_h",  "fhocn_h"/)
   ;     levs =  (/-40.0, 0.0, 1.0/)

   ; basevars =  (/ "sst_h",     "sst_h",  "sst_h"/)
   ;     levs =  (/-1.82, -1.68, 0.005/)

   ; basevars =  (/ "hs_h",     "hs_h",  "hs_h"/)
   ;     levs =  (/0.0, 0.70, 0.01/)

    basevars =  (/ "sss_h",     "sss_h",  "sss_h"/)
        levs =  (/33., 35.0, 0.02/)

    basefiles = addfiles(RT2+rtbase +"dm_"+basevars+"."+cdate+".nc","r")
     rtnames = (/"NEMS-BM1", "CMEPS-BM1", "NEMS-BM2"/)

       nruns = dimsizes(rtnames)

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
  ;wkstitle = hemi+"."+varname+"."+cdate
  wkstitle = hemi+".test"
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window
  
     plot = new(nruns,graphic)
      dum = new(nruns,graphic)

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
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/0.15/)

;************************************************
; the subplot call
;************************************************
function subplot(name,pltvar,ovar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours

   res@cnFillPalette            = palette
   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   oplot = gsn_csm_contour(wks,ovar,ores)
   overlay(splot,oplot)
  return(splot)
end
;************************************************
; 
;************************************************

         times = basefiles[0]->time
     timeUnits = basefiles[0]->time@units
  timeCalendar = basefiles[0]->time@calendar

  do ii = 0,nruns-1
       vname = basevars(ii)
       iname = icevars(ii)
        basevar = dim_avg_n_Wrap(basefiles[ii]->$vname$(:,:,:),0)
         icevar = dim_avg_n_Wrap(icefiles[ii]->$iname$(:,:,:),0)
 ; basevar = where(basevar .ne. 0.0,basevar,basevar@_FillValue)
 ; basevar = where(basevar .le. levs(1),basevar,basevar@_FillValue)

  basevar@lon2d = gf->$tlonname$
  basevar@lat2d = gf->$tlatname$
  icevar@lon2d = gf->$tlonname$
  icevar@lat2d = gf->$tlatname$
  ;labelstrings(ii) = basevar@long_name+" ("+basevar@units+")  "+"["+varname+"]"
  basevar@long_name = " "
  basevar@units= " "
  res@gsnCenterString = rtnames(ii)
    plot(ii) = subplot(vname,basevar,icevar,levs,colormap)
     dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
 end do

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
  ;resP@gsnPanelMainString = vartitle+"  "+cd_string(times(lstep),"%Y%N%D")
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/1,3/),resP)               ; now draw as one plot

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
