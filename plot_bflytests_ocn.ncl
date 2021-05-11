;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

 plotlabs = (/"Dev", "Dev+Butterfly", "Unitynorm"/)
      rts = (/"ufs_dev", "ufs_dev", "ufs_unity"/)
    csets = (/"/cpld_controlfrac_c192/",\
              "/cpld_controlfrac_c192_bfly/", \
              "/cpld_controlfrac_c192/"/)

   print(rts+csets)

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"
  ;hemi = "global"

 rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6
 const_lhvap = 2.501e6

;************************************************
; use the right atm tile to set matching lat-lon
; limits for ocn grid fields
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile1"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if
 
 if(hemi .eq. "global")then
  pltres = "global"
 else
  pltres = tile
 end if

 if(hemi .eq. "global")then
  minlon =   0.0
  maxlon = 360.0
  minlat = -90.0
  maxlat =  90.0
 else
 ; uses nhout=1 file, could also hourly
       gf = addfile(RT2+"FV3_RT/NORM_ONE_TESTS_2/"+rts(0)+csets(0)+"phyf000."+tile+".nc","r")
    tlonname = "grid_xt"
    tlatname = "grid_yt"
  tilecorners = tilegrid(gf->$tlonname$,gf->$tlatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
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
 end if

;************************************************
;
;************************************************

     lstep = 1-1
     cyear = "2016"
      cmon = "10"
      cday = "04"
     ; cmon = "02"
     ; cday = "04"
     chour = "21"

   ocnfiles = addfiles(RT2+"FV3_RT/NORM_ONE_TESTS_2/"+rts+csets+"ocn_"+cyear+"_"+cmon+"_"+cday+"_"+chour+".nc","r")
   ListSetType(ocnfiles,"cat")
   ;print(ocnfiles)

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
  plotlevs( 0,:) = (/  -0.1,  0.1, 0.010/)   ; sst
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

  ; special settings
       owgt = 1.0
  if(fldname .eq. "lprec")then   ; make levels easier
       owgt = 3600.0
  end if

  ; Dev - Dev+Butterfly; first copy metadata
  odiff0 = ocnfiles[0]->$fldname$(0,:,:)
  odiff0 = ocnfiles[0]->$fldname$(0,:,:) - ocnfiles[1]->$fldname$(0,:,:)
  odiff0 = odiff0*owgt
 pltlab0 = plotlabs(0)+" - "+plotlabs(1)
  ; Dev - Feature
  odiff1 = ocnfiles[0]->$fldname$(0,:,:)
  odiff1 = ocnfiles[0]->$fldname$(0,:,:) - ocnfiles[2]->$fldname$(0,:,:)
  odiff1 = odiff1*owgt
 pltlab1 = plotlabs(0)+" - "+ plotlabs(2)

  if(fldname .eq. "lprec")then   ; make levels easier
   odiff0@units = "mm/d"
   odiff1@units = "mm/d"
  end if
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wkstitle = fldname+"_"+pltres
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
  if(hemi .ne. "none" .and. hemi .ne. "global")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF = -45
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = -50                            ; minimum lat to plot
    res@mpCenterLonF = 0.0
   end if
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         = (maxlon - minlon)/2.0
  end if

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,hemi)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

  if(hemi .eq. "none" .or. hemi .eq. "global")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,plotvar,res)    ; create the plot
  end if
  return(splot)
end

; ***************************************************
;
; ***************************************************

  ii = 0
  plot(ii) = subplot(ii,pltlab0,odiff0,levs,cmap,hemi)
  ii = 1
 ; ii = 0
  plot(ii) = subplot(ii,pltlab1,odiff1,levs,cmap,hemi)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = "SST differences: 2d integration from "+cyear+cmon+"03"

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
