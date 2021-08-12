;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/lustre/f2/scratch/Denise.Worthen/FV3_RT/"

 idate = "2016_03_03"
 plotlabs = (/"Aofrac normalization","Control"/)
      rts = (/"test_aofrac",\
              "test_aofrac"/)
    csets = (/"/cpld_controlfrac_c192_aofrac/",\
              "/cpld_controlfrac_c192/"/)

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
    tile = "tile4"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

 if(hemi .eq. "global")then
  minlon =   0.0
  maxlon = 360.0
  minlat = -90.0
  maxlat =  90.0
 else 
 ; uses nhout=1 file, could also hourly
       gf = addfile(RT1+rts(0)+csets(0)+"phyf000."+tile+".nc","r")
    tlonname = "grid_xt"
    tlatname = "grid_yt"
  tilecorners = tilegrid(gf->$tlonname$,gf->$tlatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   ;maxlon = tilecorners[2]
   ;maxlat = tilecorners[3]
   maxlat = 0.0
   maxlon = 160.0
   midlon = minlon + 0.5*(maxlon - minlon)
   print(minlon+"   "+maxlon)
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
     chour = "21"
   cdate = cyear+cmon+"01"

   ocnfiles = addfiles(RT1+rts+csets+"ocn_"+cyear+"_"+cmon+"_"+cday+"_"+chour+".nc","r")
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
  plotlevs( 0,:) = (/  -0.1,   0.1, 0.010/)   ; sst
  ;plotlevs( 1,:) = (/  -0.2,  0.2, 0.02/)   ; sss
  plotlevs( 1,:) = (/ -0.02,  0.02, 0.002/)   ; sss
  ;plotlevs( 2,:) = (/  -0.2,  0.2, 0.02/)   ; ssh
  plotlevs( 2,:) = (/  -0.01,  0.01, 0.001/)   ; ssh
  ;plotlevs( 3,:) = (/  -0.2,  0.2, 0.02/)   ; speed
  plotlevs( 3,:) = (/  -0.1,  0.1, 0.01/)   ; speed
  ;plotlevs( 4,:) = (/ -30.0, 30.0, 2.0/)   ; mld
  plotlevs( 4,:) = (/ -2.0, 2.0, 0.20/)   ; mld
  ;plotlevs( 5,:) = (/-120.0,120.0,10.0/) ; latent
  plotlevs( 5,:) = (/-10.0,10.0,1.0/) ; latent
  ;plotlevs( 6,:) = (/-120.0,120.0,10.0/) ; sensible
  plotlevs( 6,:) = (/-4.0,4.0,0.5/) ; sensible
  plotlevs( 7,:) = (/-240.0,240.0,20.0/) ; SW
  plotlevs( 8,:) = (/-10.0,10.0,2.0/) ; LW
  ;plotlevs( 8,:) = (/-1.0,1.0,0.1/) ; LW
  ;plotlevs( 9,:) = (/  -2.0,  2.0, 0.2/) ; lprec*3600 mm/hr
  plotlevs( 9,:) = (/  -0.01,  0.01, 0.001/) ; lprec*3600 mm/hr
  
  cmap="BlueWhiteOrangeRed"

  ;flds = (/0,1,2,4/)
  ;flds = (/0,1,2/)
  ;flds = (/5,6,8,9/)
  flds = (/5,6/)

;************************************************
;  Ocn lats/lons and mask
;************************************************
  
   olonname = "geolon"
   olatname = "geolat"
  olandname = "wet_c"

    ocnlons = ocnfiles[0]->$olonname$
    ocnlats = ocnfiles[0]->$olatname$
      oland = ocnfiles[0]->$olandname$

    pltlab0 = plotlabs(0)+"-"+plotlabs(1)
   ;wkstitle = rts(0)+"-"+rts(1)+"_"+cday
   wkstitle = hemi
   print(wkstitle)
;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  if(wkstype .eq. "png")then
   wkstype@wkWidth=2500
   wkstype@wkHeight=2500
  else
   wkstype@wkWidth=800
   wkstype@wkHeight=800
  end if
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(dimsizes(flds),graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False
  res@lbLabelBarOn  = True                 ; turn off individual colorbars

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
function subplot(ii,pltvar,pltlevs,palette,hemi)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

   res@gsnStringFontHeightF = 0.020
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

  do kk = 0,dimsizes(flds)-1
  fldtoplot = flds(kk)
       levs = plotlevs(fldtoplot,:)
    fldname = ocnflds(fldtoplot)

  ; special settings
       owgt = 1.0
  if(fldname .eq. "lprec")then   ; make levels easier
       owgt = 3600.0
  end if

  ; Hera Nems-cmeps; first copy metadata
  odiff0 = ocnfiles[0]->$fldname$(0,:,:)
  odiff0 = ocnfiles[0]->$fldname$(0,:,:) - ocnfiles[1]->$fldname$(0,:,:)
  odiff0 = odiff0*owgt

  if(fldname .eq. "lprec")then   ; make levels easier
   odiff0@units = "mm/d"
  end if
  if(fldname .eq. "latent")then  ; shorten long name
   tmp = odiff0@long_name
   print(tmp)
   ii = str_index_of_substr(tmp,"due",0)
   ;print(ii)
   odiff0@long_name = str_get_cols(tmp,0,ii(0)-1)
  end if

  plot(kk) = subplot(kk,odiff0,levs,cmap,hemi)
  end do

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = cday+"-d integration from "+cdate+": "+pltlab0
  resP@gsnPanelMainString = "2-d integration from "+cdate+": "+pltlab0

 ; resP@gsnCenterStringFontHeightF      = 0.020
 ; resP@gsnCenterString                 = pltlab0
 ; resP@gsnCenterStringOrthogonalPosF   = 0.12

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/dimsizes(flds),1/),resP)
  ;gsn_panel(wks,plot,(/2,2/),resP)

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
