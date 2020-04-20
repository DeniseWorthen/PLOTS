;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "levscmapCICE.ncl"

;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

    hemi = "NH"
  minlat = 66.0

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

   varname = "Tsfc"
   ;varname = "flwdn"
;************************************************
; read in netCDF file
;************************************************

     cdate = "20120101"
       rts =  (/"bm3.0606",  "bm3.bitwf.0610"/)
     files = addfiles(RT3+"For_ESRL/"+rts+"."+cdate+".nc","r")

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
  wks   = gsn_open_wks (wkstype,varname)

  ;drawNDCGrid(wks)
  ; left are fields, right is diff
  plotleft = new(2,graphic)
  plotrght = new(2,graphic)
   dumleft = new(2,graphic)
   dumrght = new(2,graphic)

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

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020     

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
; left plot and colorbar, same variable 
;************************************************

    lstep = 1-1

         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)

       freturn = levscmapCICE(varname,hemi)
    pltlevs(:) = freturn[0]
    colormap   = freturn[1]
  ;print(pltlevs)
         vname = varname+"_h"

  do ii = 0,1
        icevar = files[ii]->$vname$(lstep,:,:)
         aivar = files[ii]->aice_h(lstep,:,:)
  ivar = icevar
  ;ivar = where(aivar .gt. 0.95, icevar, icevar@_FillValue)
  ivar@lon2d = files[ii]->$tlonname$*rfactor
  ivar@lat2d = files[ii]->$tlatname$*rfactor
  labelstrings(ii) = icevar@long_name+" ("+icevar@units+")  "+"["+vname+"]"
  ivar@long_name = " "
  ivar@units= " "
  ;res@gsnCenterString = rts[ii]
  plotleft(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dumleft(ii) = gsn_add_polyline(wks,plotleft(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;print(labelstrings(0))
  delete(icevar)
  delete(ivar)
  end do 

;************************************************
; right plot and colorbar, differenc 
;************************************************

  ii = 0
  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ivar@lon2d = files[0]->$tlonname$*rfactor
  ivar@lat2d = files[0]->$tlatname$*rfactor
   pltlevs = (/-4,4,.2/)
;   pltlevs = (/-12,12,1/)
  colormap = "BlWhRe"
  plotrght(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dumrght(ii) = gsn_add_polyline(wks,plotrght(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

 resP1                  = True                ; mods desired
 resP1@gsnFrame         = False               ; save panel until both ready
 resP1@gsnPanelRight    = 0.5                 ; draw from left edge to center
 resP1@gsnPanelLabelBar = True                ; commom label bar

 resP2                  = True                ; mods desired
 resP2@gsnFrame         = False               ; save panel until both ready
 resP2@gsnPanelLeft     = 0.5                 ; draw from center to right edge 
 resP2@gsnPanelLabelBar = True                ; commom label bar

 resP1@gsnPanelYWhiteSpacePercent = 10
 resP1@gsnPanelXWhiteSpacePercent = 10
 resP2@gsnPanelYWhiteSpacePercent = 10
 resP2@gsnPanelXWhiteSpacePercent = 10

 gsn_panel(wks,plotleft,(/2,1/),resP1)          ; create first panel
 gsn_panel(wks,plotrght,(/2,1/),resP2)          ; create second panel


  frame(wks)
exit
end
