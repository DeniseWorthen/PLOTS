;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ;hemi = "wedge"
       hemi = "NH"
  ;    hemi = "SH"
  varnames = (/"HS"/)
  plotlevs = (/0.0,4.0,.05/)

  if(hemi .eq. "wedge")then
   minlat =  60.0
   maxlat =  88.0
   minlon = 20.0
   maxlon = 90.0
  else
    if(hemi .eq. "NH")then
      minlat = 66.0
    else
      maxlat = -50.0
    end if
  end if

  ; these are in degrees
     rfactor=1.0
   tlatname="lat"
   tlonname="lon"

  cyear = "2021"
   cmon = "08"
   cday = "24"
   hour = "060000"
  cdate = cyear+cmon+cday+"."+hour
  lstep = 1-1

;************************************************
; read in netCDF file
;************************************************

   rtname1 = "base"
    rtsrc1 = RT2+"testpr1/"

   rtname2 = "pr1"
    rtsrc2 = RT2+"testpr1/"

       dir1 = rtsrc1+rtname1+"/"
       dir2 = rtsrc2+rtname2+"/"
       dirs = (/dir1,dir2/)

     fnames = new((/2/),string)
  fnames(0) = dirs(0)+cdate+".out_grd.ww3.nc"
  fnames(1) = dirs(1)+cdate+".out_grd.ww3.nc"

  filelist = addfiles(fnames,"r")
  ;print(filelist)
  wkstitle = "testpr1"
  plottitle = "testpr1"
  cmap = "WhBlGrYeRe"
  nplots=2

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
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)

  plot = new(2,graphic)
  oplot = new(2, graphic)
  dum = new(2,graphic)

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
    res@gsnPolarLabelFontHeightF = 0.020           ; change font height of labels
  end if

  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@gsnStringFontHeightF     = 0.025
  res@lbLabelFontHeightF       = 0.020

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
function subplot(ii,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours

   res@cnFillPalette        = palette
   if(hemi .eq. "wedge")then
     splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
   else
     splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   end if
   return(splot)
end

; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page
  resP@gsnPanelFigureStrings = (/"PR3","PR1"/)
  resP@amJust = "TopLeft"

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ;ores@cnFillOn         = True
  ;ores@cnFillPalette    = "black"
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ;ores@lbLabelBarOn       = False                 ; turn off individual colorbars
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/0.75/)

; ***************************************************
;
; ***************************************************

     ii = 0
     do ii = 0,nplots-1
       vname = varnames(0)
       data = filelist[ii]->$vname$(0,:,:)
       mskvar = filelist[ii]->ICE(0,:,:)
       data@long_name=""
       data@lon2d = filelist[ii]->$tlonname$(:,:)
       data@lat2d = filelist[ii]->$tlatname$(:,:)
       mskvar@lon2d = filelist[ii]->$tlonname$(:,:)
       mskvar@lat2d = filelist[ii]->$tlatname$(:,:)

       plot(ii) = subplot(ii,data,plotlevs,cmap)
       oplot(ii) = gsn_csm_contour(wks,mskvar,ores)
       overlay(plot(ii),oplot(ii))
       dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
     end do

;************************************************
; make the panel
;************************************************

   gsn_panel(wks,plot,(/nplots,1/),resP)

 frame(wks)
  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if
exit
end
