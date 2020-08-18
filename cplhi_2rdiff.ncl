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
  RT1 = "/work/noaa/stmp/dworthen/stmp/dworthen/S2S_RT/"

 cyear = "2013"
  imon = "07"
  cmon = "07"
  cday = "01"
  csec = "03600"
 cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

 plotlabs = (/"cice5", "cice6"/)
      rts = (/"cice5_1d/", "cice6_1d/"/)
     cset = "cpld_fv3_ccpp_384_mom6_cice_cmeps_35d_"+cyear+imon+"0100/"
 pltlab0 = plotlabs(1)+" - "+plotlabs(0)
 print(cset)

  hemi = "NH"
  ;hemi = "SH"
  ;hemi = "none"

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   minlon =   0.0
   minlat = -60.0
   maxlon = 360.0
   maxlat =  60.0
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

  fldtyp = "iceImp"
    flds = (/"Fioi_swpen_vdr"  \
             /)
  ;fldtyp = "ocnExp"
  ;  flds = (/"Foxx_swnet_vdr"  \
  ;           /)

  nflds = dimsizes(flds)
  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs(0,:) = (/-0.05, 0.05, 0.005/)
  ;plotlevs(0,:) = (/-2.0, 2.0, 0.20/)
  ;plotlevs(0,:) = (/0.0 ,150.0, 5.0/)

  ;default
  ;cmap="BlueWhiteOrangeRed"
  cmap="BlueDarkRed18"

;************************************************
;
;************************************************

  ;print(RT1+rts+cset+"ufs.s2s.cpl.hi."+cdate+".nc")
  cplfiles = addfiles(RT1+rts+cset+"ufs.s2s.cpl.hi."+cdate+".nc","r")

   latname = fldtyp+"_lat"
   lonname = fldtyp+"_lon"
      lons = cplfiles[0]->$lonname$(0,:,:)
      lats = cplfiles[0]->$latname$(0,:,:)

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = fldtyp+"_"+flds(fldtoplot)
  plottitle = plotlabs(1)+"-"+plotlabs(0)+": "+fldname+" "+cdate
   wkstitle = fldname

       fvar = (cplfiles[1]->$fldname$(0,:,:) - cplfiles[0]->$fldname$(0,:,:))
  fvar@lon2d = lons
  fvar@lat2d = lats
  
;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = True

  ;res@gsnStringFontHeightF = 0.01
  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF = -45
   end if
   if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
    res@mpCenterLonF = 0.0
   end if
  end if

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   = cmap

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@tiMainFontHeightF = .012
  res@tiMainString = plottitle

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,fvar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,fvar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
