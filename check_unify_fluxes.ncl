;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch3/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  rtsrc = RT4+"fmc_unify4_1.5d/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"

  icefile="history/iceh_06h.2016-10-04-43200.nc"
  ocnfile="ocn_2016_10_04_09.nc"

;************************************************
;
;************************************************

  ocnsrc=addfile(rtsrc+ocnfile,"r")
  icesrc=addfile(rtsrc+icefile,"r")

  ocnfsalt = "salt_flux_in"
  icefsalt = "fsalt_h"
   botmelt = "meltb_h"
    frazil = "frazil_h"
    congel = "congel_h"

  icelont = "TLON"
  icelatt = "TLAT"

  ocnlont = "geolon"
  ocnlatt = "geolat"

  lstep=1-1
  tvar=ocnsrc->$ocnfsalt$(lstep,:,:)*1.0e6
 
  landmask = icesrc->tmask(:,:)
      ivar = icesrc->$icefsalt$(lstep,:,:)*1.0e6
   totmelt = icesrc->$botmelt$(lstep,:,:)
   ffrazil = icesrc->$frazil$(lstep,:,:)
   fcongel = icesrc->$congel$(lstep,:,:)
   ;printVarSummary(totfrez)
   totfrez = icesrc->$frazil$(lstep,:,:) + icesrc->$congel$(lstep,:,:)
  print(ivar@long_name)

  ;levs = (/-300.0,60.0,10.0/)
  ;levs = (/87.0,90.0,0.10/)
  ;levs = (/-1.68,-1.58,0.005/)
  ;levs = (/-0.5,0.5,.05/)
  ;levs = (/-1.6,1.6,.1/)

  ;tvar@long_name=" "
  ;tvar@units=" "
;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=  60.00
  lon2=-120.00
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"chkflux")              ; send graphics to X11 window

  plot = new(4,graphic)
 oplot = new(4,graphic)
   dum = new(4,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@mpFillOn   = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@gsnStringFontHeightF = 0.05
  res@gsnLeftStringFontHeightF = 0.015
  res@gsnRightStringFontHeightF = 0.015

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  ;res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  ;res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette = "BlueWhiteOrangeRed"
  ;res@cnFillPalette = "t2m_29lev"

;************************************************
; Resources for the polyline
;************************************************

  ;res@mpGreatCircleLinesOn = True
  ;pres                  = True           ; polyline mods desired
  ;pres@gsLineThicknessF = 4.0            ; line thickness
  ;pres@gsLineColor      = "black"         ; color of lines
  ;pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnFillOn         = True                  ; color fill
  ores@cnLinesOn        = False                 ; no contour lines
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources

  ores@cnFillPalette = "GMT_gray"
  ores@cnLevels        = (/1.0/)                      ; set the minimum contour level

;************************************************
;
;************************************************

 fname = new(4,"string")
 uname = new(4,"string")

     levs = (/0.0,2.0,0.1/)
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   = "gui_default"

       ii = 0
  plotvar = totmelt
  fname(ii) = plotvar@long_name
  uname(ii) = plotvar@units
   plot(ii) = gsn_csm_contour(wks,plotvar,res)    ; create the plot
  plotvar@long_name=" "
  plotvar@units=" "
  delete(plotvar)

       ii = 1
  plotvar = totfrez
   plot(ii) = gsn_csm_contour(wks,plotvar,res)    ; create the plot
  fname(ii) = plotvar@long_name
  uname(ii) = plotvar@units
  delete(plotvar)

     levs = (/-1.0,1.0,0.1/)
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   =  "BlueWhiteOrangeRed"         ; choose colormap

       ii = 2
  plotvar = ivar
   plot(ii) = gsn_csm_contour(wks,plotvar,res)    ; create the plot
  fname(ii) = plotvar@long_name
  uname(ii) = plotvar@units
  delete(plotvar)

       ii = 3
  plotvar = tvar
   plot(ii) = gsn_csm_contour(wks,plotvar,res)    ; create the plot
  fname(ii) = plotvar@long_name
  uname(ii) = plotvar@units
  delete(plotvar)

  print(fname)
;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot

  ;resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0
  ;res@gsnLeftString = (/totmelt@long_name,totfrez@long_name,ivar@long_name,tvar@longname/)
  ;res@gsnRightString = plotvar@units

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
  ;gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

end
