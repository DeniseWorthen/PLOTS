;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

  ; hera
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/"

;************************************************

  hemi = "NH"
  if(hemi .eq. "NH")then
    minlat = 66.0
  else
    maxlat = -50.0
  end if

  ; these are in degrees
     rfactor=1.0
   tlatname="TLAT"
   tlonname="TLON"
   ulatname="ULAT"
   ulonname="ULON"
;************************************************
; read in netCDF file
;************************************************

   rt = "cicepr.netcdf.cdf1/cpld_control_p8_intel/"
   icfile = RT2+rt+"cice_model.res.nc"
   ichist = RT2+rt+"history/iceh_ic.2021-03-22-21600.nc"

   print(icfile)
   print(ichist)

   ifile = addfile(icfile,"r")
   hfile = addfile(ichist,"r")

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
  wks   = gsn_open_wks (wkstype,"cice_2r2f")

  ;drawNDCGrid(wks)

  ;plot = new(2,graphic)
  ;dum  = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = True
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat
   res@mpCenterLonF = 0.0
  end if

  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF = 0.020           ; change font height of labels
  res@gsnStringFontHeightF     = 0.025
  res@lbLabelFontHeightF       = 0.020

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
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
;************************************************
;
;************************************************

  colormap = "MPL_rainbow"              ; choose colormap
  pltlevs = (/-0.5,0.5,0.05/)
  vname = "aice"

  ii = 0
  icevar = hfile->$vname$(0,:,:)
  printVarSummary(icevar)
  icevar@lon2d = hfile->$tlonname$(:,:)
  icevar@lat2d = hfile->$tlatname$(:,:)

  ;labelstrings(vnum) = icevar@long_name+" ("+icevar@units+")  "+"["+vname+"]"
  ;icevar@long_name = " "
  ;icevar@units= " "
  plot = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
  ;plot(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;print(labelstrings(0))

   ;ii = 0
   ;icevar = hfile->$vname$(0,:,:)
   ;plot = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   ;plot(ii) = subplot(ii,vname,icevar(:,:),,pltlevs,colormap)
   ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;delete(icevar)
;************************************************
;
;************************************************

 res                  = True                ; mods desired
 res@gsnFrame         = False               ; save panel until both ready
 res@gsnPanelRight    = 0.5                 ; draw from left edge to center
 res@gsnPanelLabelBar = True                ; commom label bar

 res@gsnPanelYWhiteSpacePercent = 10
 res@gsnPanelXWhiteSpacePercent = 10

 gsn_panel(wks,plot,(/2,1/),res)          ; create first panel

 frame(wks)
exit
end
