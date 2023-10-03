; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
;
;************************************************

  RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_26501/"
  wkstitle = "signs_units"
  runlabs = (/"Lat->Evap conversion in CMEPS","Direct Evap flux export"/)
  dirs = (/"cpld.dev/", "cpld.evap/" /)
  fsrc = "ocn.hi"
  ndirs = dimsizes(dirs)

  ; add cpl history files on tile
  files=addfiles(RT+dirs+fsrc+".nc","r")
  print(files)

  ; field to plot
  ocnfld = "ocnExp_Faxa_evap"
  ;ocnwgt = 86400.                     ; kg/m2/s->mm/day
  ocnwgt = 1.0e14*86400.                     ; kg/m2/s->mm/day
  ocnunits = "mm/day"
  baselevs = (/-10.0, 10.0, 1./)       ; for base plot
  difflevs = (/-0.5,  0.5, 0.05/)  ; for difference plot

  ; palettes
  basecmap = "BlueWhiteOrangeRed"
  diffcmap = "BlueWhiteOrangeRed"

 ; in coupler history files
  tlonname = "ocnExp_lon"
  tlatname = "ocnExp_lat"

  ; retrieve masking
  mskname = "ocnImp_So_omask"
  msklonname = "ocnExp_lon"
  msklatname = "ocnExp_lat"
  mskvar = files[1]->$mskname$(0,:,:)
  mskvar@lon2d = files[1]->$msklonname$(0,:,:)
  mskvar@lat2d = files[1]->$msklatname$(0,:,:)
  printVarSummary(mskvar)

  plottitle=ocnfld+":  "+runlabs(1)+" - "+runlabs(0)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  plot = new(2,graphic)

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
function subplot(pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  ;res@gsnCenterStringFontHeightF      = 0.020
  ;res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = 0.12

   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  return(splot)
end
;************************************************
;
;************************************************

  lstep = 1-1
  ;lstep = 24-1
  ii = 0
  avar = files[0]->$ocnfld$(lstep,:,:)
  avar = mask(avar*ocnwgt, mskvar, 1.0)
  avar@units=ocnunits
  avar@lon2d = files[0]->$tlonname$(0,:,:)
  avar@lat2d = files[0]->$tlatname$(0,:,:)
  ;plot(ii) = subplot(avar,baselevs,basecmap)

  ; second plot, difference
  ;ii = 1
  avar = files[1]->$ocnfld$(lstep,:,:)-files[0]->$ocnfld$(lstep,:,:)
  avar = mask(avar*ocnwgt, mskvar, 1.0)
  avar@units=ocnunits
  plot(ii) = subplot(avar,difflevs,diffcmap)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False

  ;resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
