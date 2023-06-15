;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"

; plotlabs = (/"GEFS dev", "GEFS swfix (albdif=albdir=.06)", "GEFS swfix"/)
;    csets = (/"gefs.nofix/", "gefs.swfix.avg/", "gefs.swfix/"/)

; plotlabs = (/"CPLD dev", "CPLD swfix (albdif=albdir=.06)", "CPLD swfix"/)
;    csets = (/"cpld.nofix/", "cpld.swfix.avg/", "cpld.swfix/"/)

 plotlabs = (/"CPLD dev", "CPLD swfix (max .06)", "CPLD swfix"/)
    csets = (/"cpld.20day/cpld.noswfix/", "cpld.20day/cpld.swfix/", "cpld.20day/cpld.swfix.nolim/"/)

      rts = (/"fixsw/", "fixsw/", "fixsw/" /)

 rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6
 const_lhvap = 2.501e6

  minlon =   0.0
  maxlon = 360.0
  minlat = -90.0
  maxlat =  90.0

;************************************************
;
;************************************************

     lstep = 1-1
     cdate="2021_03_23_03"
     cdate="2021_04_11_03"

   fnames = RT2+rts+csets+"ocn_"+cdate+".nc"
   ocnfiles = addfiles(fnames,"r")
   ListSetType(ocnfiles,"cat")
   print(fnames)

  ; ocn fields
  ocnflds = (/"SST",      \
              "SSS",      \
              "SSH",      \
              "speed",    \
              "MLD_003",  \
              "latent",   \
              "sensible", \
              "SW",       \
              "LW",       \
              "lprec"     \
              /)
  nflds = dimsizes(ocnflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/  -1.0,  1.0, 0.10/)   ; sst
  plotlevs( 0,:) = (/  -0.1,  0.1, 0.01/)   ; sst
  plotlevs( 1,:) = (/  -0.2,  0.2, 0.02/)   ; sss
  plotlevs( 2,:) = (/  -0.2,  0.2, 0.02/)   ; ssh
  plotlevs( 3,:) = (/  -0.2,  0.2, 0.02/)   ; speed
  plotlevs( 4,:) = (/ -20.0, 20.0, 2.0/)   ; mld
  plotlevs( 5,:) = (/-120.0,120.0,10.0/) ; latent
  plotlevs( 6,:) = (/-120.0,120.0,10.0/) ; sensible
  plotlevs( 7,:) = (/-240.0,240.0,20.0/) ; SW
  plotlevs( 8,:) = (/-100.0,100.0,10.0/) ; LW
  plotlevs( 9,:) = (/  -2.0,  2.0, 0.2/) ; lprec*3600 mm/hr

  cmap="BlueWhiteOrangeRed"

;************************************************
;  Ocn lats/lons and mask
;************************************************

   olonname = "geolon"
   olatname = "geolat"
  olandname = "wet_c"

    ocnlons = ocnfiles[0]->$olonname$
    ocnlats = ocnfiles[0]->$olatname$
      oland = ocnfiles[0]->$olandname$

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot =0
       levs = plotlevs(fldtoplot,:)
    fldname = ocnflds(fldtoplot)
   ;wkstitle = rts(0)+"-"+rts(1)
   ;wkstitle = rts(0)+"-"+rts(2)
   wkstitle = fldname+"_latest"

  ; special settings
       owgt = 1.0
  if(fldname .eq. "lprec")then   ; make levels easier
       owgt = 3600.0
  end if

  if(fldname .eq. "lprec")then   ; make levels easier
   odiff0@units = "mm/d"
   odiff1@units = "mm/d"
  end if
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(2,graphic)

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
  res@mpMinLatF            =  minlat      ; range to zoom in on
  res@mpMaxLatF            =  maxlat
  res@mpMinLonF            =  minlon
  res@mpMaxLonF            =  maxlon
  res@mpCenterLonF         = (maxlon - minlon)/2.0

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

  splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  return(splot)
end

; ***************************************************
;
; ***************************************************

  ; copy metadata
  pltvar = ocnfiles[1]->$fldname$(0,:,:)

  ii=0
  pltvar = ocnfiles[1]->$fldname$(0,:,:) - ocnfiles[0]->$fldname$(0,:,:)
  pltvar = pltvar*owgt
  pltlab = plotlabs(1)+" - "+plotlabs(0)
  plot(ii) = subplot(ii,pltlab,pltvar,levs,cmap)

  ii=1
  pltvar = ocnfiles[2]->$fldname$(0,:,:) - ocnfiles[0]->$fldname$(0,:,:)
  pltvar = pltvar*owgt
  pltlab = plotlabs(2)+" - "+plotlabs(0)
  plot(ii) = subplot(ii,pltlab,pltvar,levs,cmap)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot
  resP@gsnPanelYWhiteSpacePercent = 8

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = "1d integration from "+cyear+cmon+"01"

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,1/),resP)
  ;gsn_panel(wks,plot,(/1,1/),resP)

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
