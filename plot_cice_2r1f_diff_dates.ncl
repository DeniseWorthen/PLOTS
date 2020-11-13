;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  LSF = "/scratch2/NCEPDEV/climate/Lydia.B.Stefanova/Models/"

    hemi = "NH"
 ;   hemi = "SH"
 if(hemi .eq. "NH")then
  minlat =  66.0
  midlon = -45.0
 else
  maxlat = -50.0
  midlon =   0.0
 end if

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

;************************************************
; read in netCDF file
;************************************************

      cyear = "2017"
      cmons = (/"01", "04", "07", "10"/)
  Dates2Plt = (/"0204", "0505", "0804", "1104"/)
     idates = cyear+cmons+"01"
     ;print(idates)
     lstep = 1-1
      csec = "00000"
    ndates = dimsizes(Dates2Plt)

     ; Lydia's b31 sea ice files
     ; Wcoss stability RT ice file
      rts = (/"ufs_b31/SeaIce","ufs_p5/SeaIce"/)

     filelist0 = LSF+rts(0)+"/"+idates+"/ice"+cyear+Dates2Plt+".01."+idates+"00.subset.nc"
     print(filelist0)
     filelist1 = LSF+rts(1)+"/"+idates+"/ice"+cyear+Dates2Plt+".01."+idates+"00.subset.nc"
     ;print(filelist1)
     ;files = addfiles((/filelist0,filelist1/),"r")
     files0 = addfiles(filelist0,"r")
     files1 = addfiles(filelist1,"r")
     ;ListSetType(files0,"cat")
     ;ListSetType(files1,"cat")

     print(rts(1)+" - "+rts(0))
     plottitle="No Mediator Fluxes - "+rts(0)

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
  wks   = gsn_open_wks (wkstype,"ice_inst_diff")

  ;drawNDCGrid(wks)
  plot = new(ndates,graphic)
   dum = new(ndates,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
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
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle

;************************************************
;
;************************************************
         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)
    colormap = "BlueDarkRed18"
    ;colormap = "amwg256"

  ;   vname = "aice_h"
  ; pltlevs = (/-.2,.2,.02/)
 
     vname = "hi_h"
   pltlevs = (/-1.0,1.0,.1/)

      ii = -1
  do iii = 0,ndates-1
      ii = ii+1
  ;printVarSummary(files1->$vname$(lstep,:,:))
  res@gsnCenterString  = vname+"   "+cyear+Dates2Plt(iii)

  ivar = files1[iii]->$vname$(lstep,:,:)-files0[iii]->$vname$(lstep,:,:)
  ivar@lon2d = files0[iii]->$tlonname$*rfactor
  ivar@lat2d = files0[iii]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   end do

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)
exit
end
