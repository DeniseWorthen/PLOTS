;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  ; orion
  RT1 = "/work/noaa/stmp/dworthen/stmp/dworthen/COLDSTART2/"

 cyear = "2013"
  imon = "07"
  cmon = "07"
  cday = "01"
  ;csec = "01800"
  ;csec = "03600"
  ;csec = "43200"
 cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

 plotlabs = (/"original", "fixed_coldstart", "ocean_lag"/)
      rts = (/  "cold2/",      "cold2_fix/", "nocold/"/)
     cset = ""

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   minlon =   0.0
   minlat = -90.0
   maxlon = 360.0
   maxlat =  90.0
   midlon = minlon + 0.5*(maxlon - minlon)
  else 
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

;************************************************
;
;************************************************

  fldtyp = "ocnImp"
    flds = (/"So_t"  \
             /)
  ;fldtyp = "ocnExp"
  ;  flds = (/"Foxx_swnet_vdr"  \
  ;           /)

  nflds = dimsizes(flds)
  ; plot levels
  plotlevs = new((/nflds,3/), float)
  ;plotlevs(0,:) = (/-0.2, 0.2, 0.02/)
  ;plotlevs(0,:) = (/-2.0, 2.0, 0.20/)
  ;plotlevs(0,:) = (/0.0 ,150.0, 5.0/)
  ;plotlevs(0,:) = (/-0.1, 0.1, 0.01/)
  plotlevs(0,:) = (/-0.05, 0.05, 0.005/)

  ;default
  cmap="BlueWhiteOrangeRed"
  ;cmap="BlueDarkRed18"

;************************************************
;
;************************************************

  ;print(RT1+rts+cset+"ufs.s2s.cpl.hi."+cdate+".nc")
  cplfiles = addfiles(RT1+rts+cset+"ufs.s2s.cpl.hi."+cdate+".nc","r")

  print(RT1+rts(0)+cset+"ufs.s2s.cpl.hi."+cdate+".nc")
  print(RT1+rts(1)+cset+"ufs.s2s.cpl.hi."+cdate+".nc")
  print(RT1+rts(2)+cset+"ufs.s2s.cpl.hi."+cdate+".nc")

   mskname = fldtyp+"_So_omask"
   latname = fldtyp+"_lat"
   lonname = fldtyp+"_lon"
      lons = cplfiles[0]->$lonname$(0,:,:)
      lats = cplfiles[0]->$latname$(0,:,:)
      land = cplfiles[0]->$mskname$(0,:,:)
      land@_FillValue = default_fillvalue(typeof(land))
      land = where(land .eq. 0.0, land@_FillValue, 1.0)
  ;printVarSummary(land)

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = fldtyp+"_"+flds(fldtoplot)
   wkstitle = fldname+"_"+csec

      pltlab0 = plotlabs(1)+" - "+plotlabs(0)
        fvar0 = (cplfiles[1]->$fldname$(0,:,:) - cplfiles[0]->$fldname$(0,:,:))
        fvar0 = where(ismissing(land),default_fillvalue(typeof(fvar0)), fvar0)
        fvar0@_FillValue = default_fillvalue(typeof(fvar0))
  
      pltlab1 = plotlabs(1)+" - "+plotlabs(2)
        fvar1 = (cplfiles[1]->$fldname$(0,:,:) - cplfiles[2]->$fldname$(0,:,:))
        fvar1 = where(ismissing(land),default_fillvalue(typeof(fvar1)), fvar1)
        fvar1@_FillValue = default_fillvalue(typeof(fvar1))
  ;print(fvar1(0:20,400))

      pltlab2 = plotlabs(2)+" - "+plotlabs(0)
        fvar2 = (cplfiles[2]->$fldname$(0,:,:) - cplfiles[0]->$fldname$(0,:,:))
        fvar2 = where(ismissing(land),default_fillvalue(typeof(fvar2)), fvar2)
        fvar2@_FillValue = default_fillvalue(typeof(fvar2))

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(3,graphic)
  ;plot = new(2,graphic)
  ;plot = new(1,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@vpWidthF = 0.40
  res@vpHeightF = 0.30

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = False
  ;res@mpOutlineOn   = True

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False
  res@cnInfoLabelOn     = False

  ;res@tiMainFontHeightF = .012
  ;res@tiMainString = plottitle

;************************************************
; the subplot call
;************************************************
function subplot(ii,plottitle,pltvar,pltlevs,palette,hemi)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

   if(hemi .ne. "none")then
     res@gsnPolar   =  hemi                         ; specify the hemisphere
     res@mpCenterLonF = midlon
    if(hemi .eq. "NH")then
     res@mpMinLatF    = minlat                       ; minimum lat to plot
    end if
    if(hemi .eq. "SH")then
     res@mpMaxLatF    = maxlat                           ; minimum lat to plot
    end if
   end if

   res@cnMissingValPerimOn     = False           ; turn on the missing value perimeter
   res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
   res@cnMissingValFillColor   = "gray"         ; color fill missing areas blue

   res@gsnCenterStringFontHeightF      = 0.020
   res@gsnCenterString                 = plottitle

  if(hemi .eq. "none")then
   splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
   delete(res@mpMinLatF)
   delete(res@mpMaxLatF)
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
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainString = cdate
  ;resP@gsnPanelMainString = "SST import to mediator from ocean "+cdate
  ;resP@gsnPanelMainString = fldname+" ufs.s2s.cpl.hi."+cdate+".nc"
  ;resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0

;************************************************
;
;************************************************

   ii = 0
   plot(ii) = subplot(ii,pltlab0,fvar0,levs,cmap,hemi)    ; create the plot
   ;print(pltlab0)

   ii = 1
   ;ii = 0
   plot(ii) = subplot(ii,pltlab1,fvar1,levs,cmap,hemi)    ; create the plot
   ;print(pltlab1)

   ii = 2
   ;ii = 1
   plot(ii) = subplot(ii,pltlab2,fvar2,levs,cmap,hemi)    ; create the plot
   ;print(pltlab1)
;************************************************
; make the panel
;************************************************
  ; rows,cols
  ;gsn_panel(wks,plot,(/1,2/),resP)
  gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
