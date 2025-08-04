;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  RT = "/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2185131/"

;************************************************
; read in netCDF file
;************************************************

   idate = ""
   cyear = "2021"
    cmon = "04"
    cday = "01"
   cdate = cyear+"-"+cmon+"-"+cday
   rtsrc = RT+"base.10d/"

   ; use one file for grid
   ;gf =addfile(rtsrc+"iceic"+idate+"00.01."+idate+"00.nc","r")
   gf =addfile(rtsrc+"history/iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc","r")
   ;print(gf)
   tlatname="TLAT"
   tlonname="TLON"
   rfactor=1.0
   ;dirname=rtsrc+"history/"
   dirname=rtsrc
   wkstitle="test"

;************************************************
; ice
;************************************************

  lstep=1-1
  print("cdate = "+cdate)

  poles = (/"NH", "SH"/)
  npoles=2
  print(poles)

  varname="Tsfc_h"
  fname = "iceh_06h."+cdate+"-00000.nc"
 ; plot levels
  plotlevs = new((/npoles,3/), float)
  plotlevs( 0,:) = (/  -38.0, 2.0, 0.5/)
  plotlevs( 1,:) = (/  -30.0, 2.0, 0.5/)
  cmap="BlueWhiteOrangeRed"

    icef = addfile(rtsrc+"history/"+fname,"r")
  icevar = icef->$varname$(lstep,:,:)

  maskname="aice_h"
  mvar=icef->$maskname$(lstep,:,:)

  ;icevar = where(mvar .gt. .01, icevar, icevar@_FillValue)

  ;icevar = icevar/100.0
  icevar@lon2d=gf->$tlonname$*rfactor
  icevar@lat2d=gf->$tlatname$*rfactor
  ;printVarSummary(icevar)
  icevar@units=""
  icevar@long_name=""
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
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(npoles,graphic)

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
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,tilename)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

   res@cnMissingValFillColor    = "gray70" ; set color for missing areas

   res@gsnCenterStringFontHeightF      = 0.020
   ;res@gsnCenterString                 = name
   ;res@gsnCenterStringOrthogonalPosF   = 0.15

   if(tilename .eq. "NH")then
     res@gsnPolar   =  "NH"
     res@mpMaxLatF    = 90.0
     res@mpMinLatF    = 65.0                          ; minimum lat to plot
     res@mpCenterLonF =  0.0
   end if
   if(tilename .eq. "SH")then
     res@gsnPolar   =  "SH"
     res@mpMinLatF    = -90
     res@mpMaxLatF    = -65.0                            ; minimum lat to plot
     res@mpCenterLonF = 0.0
   end if
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot

  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = varname+" "+fname

; ***************************************************
;
; ***************************************************

  do ii = 0,npoles-1
    levs = plotlevs(ii,:)
    plot(ii) = subplot(ii,"ice "+"at 2021-04-01-00000 ",icevar,levs,cmap,poles(ii))
  end do

  ;  ii = 0
  ;  levs = plotlevs(ii,:)
  ;  plot(ii) = subplot(ii,"ice "+"at ",icevar,levs,cmap,poles(ii))

   ; ii = 1
   ; levs = plotlevs(ii,:)
   ; plot(ii) = subplot(ii,"ice "+"at ",icevar,levs,cmap,poles(ii))

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/3,1/),resP)
  gsn_panel(wks,plot,(/1,npoles/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
