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
  csec = "43200"
 cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

 plotlabs = (/"original", "fixed_coldstart", "ocean_lag"/)
      rts = (/  "cold2/",      "cold2_fix/", "nocold/"/)
     cset = ""

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"

  latname = "grid_yt"
  lonname = "grid_xt"
;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile4"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

 cplfiles = addfiles(RT1+rts+cset+"ufs.cpl.hi-"+csec+"."+tile+".nc","r")
     lons = cplfiles[0]->$lonname$(:,:)
     lats = cplfiles[0]->$latname$(:,:)

  tilecorners = tilegrid(lons,lats,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   print(tile)
   print(minlat+"   "+maxlat)
   print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
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

  ;fldtyp = "atmImp"
  ;  flds = (/"Sa_tbot"  \
  ;           /)
  fldtyp = "atmExp"
    flds = (/"So_t"  \
             /)

  nflds = dimsizes(flds)
  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs(0,:) = (/-0.2, 0.2, 0.02/)
  ;plotlevs(0,:) = (/-2.0, 2.0, 0.20/)
  ;plotlevs(0,:) = (/0.0 ,150.0, 5.0/)

  ;default
  cmap="BlueWhiteOrangeRed"
  ;cmap="BlueDarkRed18"

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = fldtyp+"_"+flds(fldtoplot)
   wkstitle = fldname

      pltlab0 = plotlabs(1)+" - "+plotlabs(0)
        fvar0 = (cplfiles[1]->$fldname$(:,:) - cplfiles[0]->$fldname$(:,:))
  fvar0@lon2d = lons
  fvar0@lat2d = lats

      pltlab1 = plotlabs(1)+" - "+plotlabs(2)
        fvar1 = (cplfiles[1]->$fldname$(:,:) - cplfiles[2]->$fldname$(:,:))
  fvar1@lon2d = lons
  fvar1@lat2d = lats

      pltlab2 = plotlabs(2)+" - "+plotlabs(0)
        fvar2 = (cplfiles[2]->$fldname$(:,:) - cplfiles[0]->$fldname$(:,:))
  fvar2@lon2d = lons
  fvar2@lat2d = lats
   
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(3,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

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

   res@cnMissingValPerimOn     = False           ; turn on the missing value perimeter
   res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
   res@cnMissingValFillColor   = "gray"         ; color fill missing areas blue

   res@gsnCenterStringFontHeightF      = 0.015
   res@gsnCenterString                 = plottitle

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF =  midlon
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = maxlat                            ; minimum lat to plot
    res@mpCenterLonF = midlon
   end if
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         =  midlon
  end if

  if(hemi .eq. "none")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
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

  resP@gsnPanelMainString = fldname+" ufs.s2s.cpl.hi."+cdate+".nc"
  resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0

;************************************************
;
;************************************************

   ii = 0
   plot(ii) = subplot(ii,pltlab0,fvar0,levs,cmap,hemi)    ; create the plot

   ii = 1
   plot(ii) = subplot(ii,pltlab1,fvar1,levs,cmap,hemi)    ; create the plot

   ii = 2
   plot(ii) = subplot(ii,pltlab2,fvar2,levs,cmap,hemi)    ; create the plot

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
