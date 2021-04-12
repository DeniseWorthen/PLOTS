;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

 plotlabs = (/"Dev", "Dev+Butterfly", "Unitynorm"/)
      rts = (/"ufs_dev", "ufs_dev", "ufs_test"/)
    csets = (/"/cpld_controlfrac_c192/",\
              "/cpld_controlfrac_c192_butterfly/", \
              "/cpld_controlfrac_c192/"/)

;************************************************
;
;************************************************

     lstep = 0
     cyear = "2016"
      cmon = "10"
      cday = "05"
     chour = "00000"

   icefiles = addfiles(RT2+"FV3_RT/NORM_ONE_TESTS/"+rts+csets+"history/iceh_06h."+cyear+"-"+cmon+"-"+cday+"-"+chour+".nc","r")
   ListSetType(icefiles,"cat")
   ;print(icefiles)

  ; ice fields
  iceflds = (/"aice_h",   \
              "hi_h",     \
              "Tsfc_h",   \
              "snow_h",   \
              "flwup_h",  \
              "flat_h",   \
              "fsens_h",  \
              "fswdn_h",  \
              "flwdn_h",  \
              "fresh_h"   \
              /)
  nflds = dimsizes(iceflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.2,  0.2, 0.02/)   ; ai
  plotlevs( 1,:) = (/  -0.2,  0.2, 0.02/)   ; hi
  plotlevs( 2,:) = (/  -2.0,  2.0, 0.20/)   ; tsfc
  plotlevs( 3,:) = (/  -1.0,  1.0, 0.10/)   ; snow fall
  plotlevs( 4,:) = (/-120.0,120.0,10.00/)   ; lwup
  plotlevs( 5,:) = (/ -40.0, 40.0, 2.00/)  ; latent
  plotlevs( 6,:) = (/ -40.0, 40.0, 2.00/)  ; sensible
  plotlevs( 7,:) = (/-240.0,240.0,20.00/)  ; SW
  plotlevs( 8,:) = (/-100.0,100.0,10.00/)  ; LW
  plotlevs( 9,:) = (/  -4.0,  4.0, 0.20/)  ; fresh
  
  cmap="BlueWhiteOrangeRed"

;************************************************
;  Ice lats/lons and mask
;************************************************
  
   ilonname = "TLON"
   ilatname = "TLAT"
  ilandname = "tmask"

    icelons = icefiles[0]->$ilonname$
    icelats = icefiles[0]->$ilatname$
      iland = icefiles[0]->$ilandname$

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot =2
       levs = plotlevs(fldtoplot,:)
    fldname = iceflds(fldtoplot)
   wkstitle = fldname

  ; special settings
      iwgt = 1.0
  if(fldname .eq. "fsalt")then   ; make levels easier
       iwgt = 1.0e-2
  end if

  ; Dev - Dev+Butterfly; first copy metadata
  idiff0 = icefiles[0]->$fldname$(0,:,:)
  idiff0 = icefiles[0]->$fldname$(0,:,:) - icefiles[1]->$fldname$(0,:,:)
  idiff0 = idiff0*iwgt
  idiff0@lon2d = icelons
  idiff0@lat2d = icelats
 pltlab0 = plotlabs(0)+" - "+plotlabs(1)
  ; Dev - Feature
  idiff1 = icefiles[0]->$fldname$(0,:,:)
  idiff1 = icefiles[0]->$fldname$(0,:,:) - icefiles[2]->$fldname$(0,:,:)
  idiff1 = idiff1*iwgt
  idiff1@lon2d = icelons
  idiff1@lat2d = icelats
 pltlab1 = plotlabs(0)+" - "+ plotlabs(2)

  if(fldname .eq. "fsalt_h")then   ; make levels easier
   idiff0@units = "g/m2/s"
   idiff1@units = "g/m2/s"
  end if
;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(4,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False
  res@lbLabelBarOn  = False                 ; turn off individual colorbars

  res@cnFillOn           = True
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines

  res@gsnStringFontHeightF = 0.01

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,hemi,lat0,lon0)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

    res@gsnPolar   =  hemi                         ; specify the hemisphere
    res@mpCenterLonF = lon0
   if(hemi .eq. "NH")then
    res@mpMinLatF    = lat0                       ; minimum lat to plot
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = lat0                           ; minimum lat to plot
   end if

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   delete(res@mpMinLatF)
   delete(res@mpMaxLatF)
  return(splot)
end

; ***************************************************
;
; ***************************************************

    hemi = "NH"
  minlat =  66.0
  midlon = -45.0
  ii = 0
  plot(ii) = subplot(ii,pltlab0,idiff0,levs,cmap,hemi,minlat,midlon)
  ii = 1
  plot(ii) = subplot(ii,pltlab1,idiff1,levs,cmap,hemi,minlat,midlon)

    hemi = "SH"
  maxlat = -50.0
  midlon =   0.0
  ii = 2
  plot(ii) = subplot(ii,pltlab0,idiff0,levs,cmap,hemi,maxlat,midlon)
  ii = 3
  plot(ii) = subplot(ii,pltlab1,idiff1,levs,cmap,hemi,maxlat,midlon)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = "Tsfc differences: 2d integration from "+cyear+cmon+"03"

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,2/),resP)

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
