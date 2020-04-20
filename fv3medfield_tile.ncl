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
  rtsrc = rtname+"/2012010100_12hr/tmp/cpld_fv3_384_mom6_cice_2d_bmark/"

  hemi = "NH"
  ;hemi = "SH"
  ;hemi = "none"

 rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6

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

 ; a file for the Atm lats/lons
       gf = addfile(RT2+rtsrc+"phyf000."+tile+".nc","r")
    tlonname = "grid_xt"
    tlatname = "grid_yt"
 atmlandname = "land"
   rfactor = rad2deg
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

 ; a file for the Ocn lats/lons and mask
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

    fatm = "field_med_from_atm_0000"
  atmfld = "mean_sensi_heat_flx"
    focn = "field_med_to_ocn"
  ocnfld = "mean_sensi_heat_flx"
    fice = "field_med_from_ice"
  icefld = "ice_fraction"

  levs = (/-40,40,2/)
  ;levs = (/0,3,1/)
  ;levs = (/.8,1,.01/)
  ocnstp = 5
  atmstp = (ocnstp-1) + 3*(ocnstp-2)
  lbeg = atmstp
  lend = atmstp+3
  print("lbeg:lend = "+lbeg+"  "+lend)

  ocnfile = addfile (RT2+rtsrc+focn+"_"+ocnfld+".nc","r")
     ovar = ocnfile->$ocnfld$(ocnstp,:,:)
  ovar@lon2d = ocnlons
  ovar@lat2d = ocnlats   
  ovar = where(oland .eq. 0.0, default_fillvalue(typeof(ovar)), ovar)
  ovar@_FillValue = default_fillvalue(typeof(ovar))

  aland = gf->$atmlandname$(0,:,:)
  aland@lon2d = gf->$tlonname$
  aland@lat2d = gf->$tlatname$
  ;printVarSummary(aland)

  atmlist = systemfunc("ls "+RT2+rtsrc+fatm+"*"+tile+".nc")
  ;print(atmlist)
  atmfiles = addfiles(atmlist,"r")
  ListSetType(atmfiles,"join")
   tmp = atmfiles[lbeg:lend]->$atmfld$
  avar = dim_avg_n_Wrap(tmp(:,:,:),0)
  ;printVarSummary(avar)
  ;avar@lon2d = lon2d
  ;avar@lat2d = lat2d
  avar@lon2d = gf->$tlonname$
  avar@lat2d = gf->$tlatname$
  avar = where(aland .eq. 1.0, default_fillvalue(typeof(avar)), -1.0*avar)
  avar@_FillValue = default_fillvalue(typeof(avar))
  ;print(avar(:,180))

  icefile = addfile (RT2+rtsrc+fice+"_"+icefld+".nc","r")
     ivar = dim_avg_n_Wrap(icefile->$icefld$(lbeg:lend,:,:),0)
  ivar@lon2d = ocnlons
  ivar@lat2d = ocnlats

  pltvar=avar
  fldname=atmfld
  plottitle=rtname+" med from atm "+atmfld+" step "+lbeg+":"+lend
  ;pltvar=ovar
  ;fldname=ocnfld
  ;plottitle=rtname+" med to ocn "+ocnfld+" step "+ocnstp
  ;pltvar=ivar
  ;fldname=icefld
  ;plottitle=rtname+" med to ice "+icefld+" step "+lbeg+":"+lend

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,fldname)              ; send graphics to X11 window


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
  
  ;res@cnFillOn          = False                  ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

exit
end
