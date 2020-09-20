;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

 cyear = "2016"
  cmon = "10"
  cday = "04"
 chour = "21"
;  cday = "07"
; chour = "21"
 cdate = cyear+"_"+cmon+"_"+cday+"_"+chour

 ;plotlabs = (/"MOM6 TS clim file", "MOM6 1/4->1/2 restart file"/)
 ;     rts = (/"mx050_5d_tsinit/", "mx050_5d_dainit/"/)
 ;plotlabs = (/"MOM6 1/4->1/2 restart file","MOM6 1/4->1/2 restart file, ALE init"/)
 ;     rts = (/"mx050_5d_dainit/","mx050_5d_dainit_ale/"/)

 plotlabs = (/"MOM6 TS clim file", \
              "MOM6 1/4->1/2 restart file", \
              "MOM6 1/4->1/2 restart file, 3 its"/)

      rts = (/"mx050_5d_tsinit/", \
              "mx050_5d_dainit/",  \
              "mx050_5d_dainit_3/"/)

     cset = "cpld_c192_mx050_2d/"
 print(cset)

 nruns = dimsizes(rts)

;************************************************
;
;************************************************

    flds = (/"SSH",  \
           "speed"/)

  nflds = dimsizes(flds)
  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs(0,:) = (/-1.0, 1.0, 0.10/)
  ;plotlevs(0,:) = (/-1.6, 1.6, 0.20/)
  plotlevs(1,:) = (/ 0.0, 2.0, 0.20/)

  ;default
  cmap="amwg256"

;************************************************
;
;************************************************

  ocnfiles = addfiles(RT2+"S2S_RT/"+rts+cset+"ocn_"+cdate+".nc","r")

   latname = "geolat"
   lonname = "geolon"
      lons = ocnfiles[0]->$lonname$(:,:)
      lats = ocnfiles[0]->$latname$(:,:)

   wkstitle = "ocn_init_"+cdate

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  if(wkstype .eq. "png")then
   wkstype@wkWidth=2500
   wkstype@wkHeight=2500
  else
   wkstype@wkWidth=800
   wkstype@wkHeight=800
  end if
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(nruns,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = False
  ;res@mpOutlineOn   = False
  ;res@mpCenterLonF  = 180.0
  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@gsnStringFontHeightF = 0.01

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@lbLabelBarOn      = False

  ;res@tiMainFontHeightF = .010
  ;res@tiMainString = fldname+"  ocn"+cdate

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

   res@gsnCenterStringFontHeightF      = 0.015
   res@gsnCenterString                 = name

   splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot

  return(splot)
end
;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = flds(fldtoplot)
  plottitle = plotlabs(1)+"-"+plotlabs(0)+" "+fldname

  
  ii = 0
      fvar = ocnfiles[0]->$fldname$(0,:,:) 
  plot(ii) = subplot(ii,plotlabs(ii),fvar,levs,cmap)

  ii = 1
       fvar = ocnfiles[1]->$fldname$(0,:,:)
  plot(ii) = subplot(ii,plotlabs(ii),fvar,levs,cmap)

  ii = 2
       fvar = ocnfiles[2]->$fldname$(0,:,:)
  plot(ii) = subplot(ii,plotlabs(ii),fvar,levs,cmap)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5

  ;resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = fldname+"  ocn_"+cdate

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/nruns,1/),resP)

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
