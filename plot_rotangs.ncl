;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
;************************************************
;
;************************************************

  ; rad 2 degree
  rad2deg = 180.0d0/acos(-1.0d0)
 
  ;model = "hycice"
  model = "m6c5fv3_ocn"
  ;model = "m6c5fv3_ice"

;************************************************
; read in netCDF file
;************************************************

  if(model .eq. "m6c5fv3_ocn")then
  ;   rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d_newrot/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
  ;   rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.110847/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;  runnam = "FixFreezeMelt using MLD; MOM6-CICE5-FV3 35-day spinup"
  ; get ang from ocean diagnostic output
      varsrc  = "ocn_2016_10_03_03.nc"
     rtsrc = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/S2S_momupdate/rtgen.173722/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
;    varsrc  = "MOM6_OUTPUT/ocean_geometry.nc"
  ; on tracer points
  angname_sin = "sin_rot"
  angname_cos = "cos_rot"
   anglonname = "geolon"
   anglatname = "geolat"
  ; lat,lon are degrees
      rfactor = 1.0
  end if

  if(model .eq. "m6c5fv3_ice")then
  ;   rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d_newrot/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
  ;   rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.12389/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
  ;  runnam = "FixFreezeMelt using MLD; MOM6-CICE5-FV3 35-day spinup"
  ; get ang from current cice grid file (angleT is wrong)
  ;    varsrc  = "grid_cice_NEMS_mx025.nc"
     ;rtsrc = "/home/Denise.Worthen/MOM2CICE_3/"
  ;  runnam = "generate_cice_fix_file.F90"
     rtsrc = "$WORK/EMC_CICE/tools/"
  ; get ang from cice grid file 
   varsrc  = "grid_cice_NEMS_mx025.nc"
  ;   rtsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
  ; varsrc = "jiande_fixed_grid_cice_NEMS_mx025.nc"

  ;angname_sin = "angle"
  ;angname_cos = "angle"
  ; lat,lon are radians
  ;    rfactor = rad2deg
  ; anglonname = "ulon"
  ; anglatname = "ulat"
  angname_sin = "anglet"
  angname_cos = "anglet"
  ; lat,lon are degrees
   anglonname = "lonT"
   anglatname = "latT"
      rfactor = 1.0
  end if

  if(model .eq. "hycice")then
     rtsrc = "/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/HYCOM-GSM-CICE/trunk-20180420/CICE/"
      varsrc  = "grid_cice_NEMS_mx24.nc"
  ;   rtsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
  ;    varsrc  = "cice_grid_024.nc"
    runnam = "HYCOM-CICE5 grid file"
  ; on corner points
  angname_sin = "angle"
  angname_cos = "angle"
   anglonname = "ulon"
   anglatname = "ulat"
  ; lat,lon are radians
      rfactor = rad2deg
  end if

     filesrc = addfile(rtsrc+varsrc,"r")
   plottitle = rtsrc+varsrc
       levs = (/-1.6, 1.6, 0.1/)
   ;    levs = (/-1.0, 1.0, 0.2/)
   ;    levs = (/-90.0, 90.0, 10.0/)

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

 if(model .eq. "m6c5fv3_ocn" .or. model .eq. "m6c5fv3_ice" .or. model .eq. "supergrid")then
  lon1=  60.00
  lon2=-120.00
 end if
 if(model .eq. "hycice")then
   lon1=  74.12
   lon2=-105.88
 end if
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"polar")              ; send graphics to X11 window

  npanels = 2
     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = False
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"

  if(model .eq. "m6c5fv3_ocn")then
   res@gsnAddCyclic     = False
  end if 

  res@cnFillDrawOrder    = "PreDraw"             ; draw contours first
  res@cnFillOn           = True              ; color fill
  res@cnLinesOn          = False             ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@gsnPolar     = "NH"                   ; specify the hemisphere
  ;res@mpMinLatF    =  50                    ; minimum lat to plot
  ;res@mpMinLatF    =  66                    ; minimum lat to plot
  res@mpMinLatF    =  88                    ; minimum lat to plot
  res@mpCenterLonF = -45

  ;res@cnFillPalette   =  "cmp_b2r"                         ; choose colormap
  ;res@cnFillPalette   =  "NCV_blu_red"                     ; choose colormap
  ;res@cnFillPalette   =  "MPL_rainbow"                      ; choose colormap
  ;res@cnFillPalette   =  "BlueWhiteOrangeRed"                      ; choose colormap
  res@cnFillPalette   =  "WhBlReWh"                      ; choose colormap

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@gsnLeftStringFontHeightF = 0.020

  ;res@tiMainString = plottitle
  ;res@tiMainFontHeightF = .010

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"
;************************************************
;
;************************************************

  ; sinrot
  ;angle2plot="sinrot"
  ; rot, actual angle
  angle2plot="rot"

  res@gsnLeftString = angle2plot
  ;res@gsnLeftString = "asin(sin_rot)"
          ii = 0
  if(model .eq. "m6c5fv3_ocn")then
  ; from ocn output, contains sinrot,cosrot
          ang = filesrc->$angname_sin$(:,:)
         if(angle2plot .eq. "rot")then
          ; get angle from sinrot
          ang = asin(ang)
         end if
   ang@lon2d = filesrc->$anglonname$
   ang@lat2d = filesrc->$anglatname$
  else
  ; from ice grid, either m6c5 or hyc5, actual angle is in the file
          ang = filesrc->$angname_sin$(:,:)
         if(angle2plot .eq. "sinrot")then
          ang = sin(ang)
         end if
   ang@lon2d = filesrc->$anglonname$*rfactor
   ang@lat2d = filesrc->$anglatname$*rfactor
  end if
  ;printVarSummary(ang)
  ang@units     = " "
  ang@long_name = " "

  plot(ii) = gsn_csm_contour_map_polar(wks,ang,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ; cosrot
  angle2plot="cosrot"
  ; rot
  ;angle2plot="rot"

  res@gsnLeftString = angle2plot

          ii = 1
  if(model .eq. "m6c5fv3_ocn")then
  ; from ocn output, contains sinrot,cosrot
          ang = filesrc->$angname_cos$(:,:)
         if(angle2plot .eq. "rot")then
          ; get angle from cosrot
          ang = acos(ang)
         end if
   ang@lon2d = filesrc->$anglonname$
   ang@lat2d = filesrc->$anglatname$
  else
  ; from ice grid, either m6c5 or hyc5, actual angle is in the file
          ang = filesrc->$angname_cos$(:,:)
         if(angle2plot .eq. "cosrot")then
          ang = cos(ang)
         end if
   ang@lon2d = filesrc->$anglonname$*rfactor
   ang@lat2d = filesrc->$anglatname$*rfactor
  end if
  ;printVarSummary(ang)
  ang@units     = " "
  ang@long_name = " "

  ;plot(ii) = gsn_csm_contour_map_polar(wks,ang,res)    ; create the plot
  ; dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)


;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0

  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

exit
end
