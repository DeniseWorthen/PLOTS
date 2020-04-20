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

  ;rtname = "S2S_tod"
  rtname = "S2S_names"
  ;rtsrc = rtname+"/2012010100_06hr/tmp/cpld_fv3_384_mom6_cice_2d_bmark/"
  rtsrc = rtname+"/2012010100_06hr_aofld/tmp/cpld_fv3_384_mom6_cice_2d_bmark/"

  hemi = "NH"
  ;hemi = "SH"
  ;hemi = "none"

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

 ; uses nhout=1 file, could also hourly
       gf = addfile(RT2+rtsrc+"phyf000:07:30."+tile+".nc","r")
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

;************************************************
;  Ocn lats/lons and mask
;************************************************
  
       olon = addfile(RT2+rtsrc+"array_med_ocn_grid_coord1.nc","r")
       olat = addfile(RT2+rtsrc+"array_med_ocn_grid_coord2.nc","r")
      omask = addfile(RT2+rtsrc+"array_med_ocn_grid_mask.nc","r")
   olonname = "lon_center"
   olatname = "lat_center"
  olandname = "mask"

        ocnlons = olon->$olonname$
        ocnlats = olat->$olatname$
          oland = omask->$olandname$
  ocnlons@units = "degrees_E"
  ocnlats@units = "degrees_N"
    oland@lon2d = ocnlons
    oland@lat2d = ocnlats

;************************************************
;
;************************************************

  ocnstp = 5

  ; to ocn fields
  fto_ocn = "field_aofield_to_ocn"
  ocnflds = (/"mean_sensi_heat_flx_atm_into_ocn",\
              "mean_evap_rate_atm_into_ocn",\
              "stress_on_air_ocn_zonal",\
              "stress_on_air_ocn_merid",\
              "mean_up_lw_flx_ocn"/) 

   aosgns = (/ 1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0 /)

  ; plot levels
  plotlevs = new((/5,3/), float)
  plotlevs(0,:) = (/-900,40,20/)
  plotlevs(1,:) = (/-15.,5.,1.0/)
  plotlevs(2,:) = (/-0.8,0.8,.02/)
  plotlevs(3,:) = (/-0.8,0.8,.02/)
  plotlevs(4,:) = (/-320,-300,1./)
  
  ;print(plotlevs)

  ;default
  cmap="cmp_flux"

;************************************************
;
;************************************************

  ; get ocnflds...steps in single file
  ocnfiles = addfiles(RT2+rtsrc+fto_ocn+"_"+ocnflds+".nc","r")
  ;print(ocnfiles)

  ; pick a field to plot
  fldtoplot = 4
       levs = plotlevs(fldtoplot,:)
    fldname = ocnflds(fldtoplot)
  plottitle = rtname+" aofield to ocn "+fldname
   wkstitle = rtname+"_"+fto_ocn+"_"+fldname

  ; special settings
       owgt = 1.0
  if(fldname .eq. "mean_evap_rate_atm_into_ocn")then   ; make levels easier
       owgt = 1.0e5*aosgns(fldtoplot)
       cmap = "amwg256"
  end if
  if(fldname .eq. "mean_up_lw_flx")then
       cmap = "amwg256"
  end if
  if(fldname .eq. "mean_sensi_heat_flx_atm_into_ocn")then
       cmap = "amwg256"
  end if

        ovar = ocnfiles[fldtoplot]->$fldname$(ocnstp,:,:)
        ovar = ovar*owgt
  ovar@lon2d = ocnlons
  ovar@lat2d = ocnlats
  ovar = where(oland .eq. 0.0, default_fillvalue(typeof(ovar)), ovar)
  ovar@_FillValue = default_fillvalue(typeof(ovar))
  
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
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01
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
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         = (maxlon - minlon)/2.0
  end if

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

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle
;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,ovar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,ovar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
