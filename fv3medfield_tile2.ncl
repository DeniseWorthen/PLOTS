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
       gf = addfile(RT2+rtsrc+"phyf000:07:30."+tile+".nc","r")
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

  ffr_atm = "field_med_from_atm_0000"
   atmfld = "mean_sensi_heat_flx"
   atmsgn = -1.0
 ;  atmfld = "mean_net_lw_flx"
 ;  atmsgn = 1.0

  ;fto_ocn = "field_med_to_ocn"
  ; ocnfld = "mean_sensi_heat_flx"
  ; ocnfld = "mean_net_lw_flx"
  ; ocnfld = "mean_zonal_moment_flx"
  ; ocnfld = "mean_merid_moment_flx"
  ; ocnfld = "mean_evap_rate"

  fto_ocn = "field_aofield_to_ocn"
   ocnfld = "mean_sensi_heat_flx_atm_into_ocn"

  fto_atm = "field_med_to_atm_0000"
   icefld = "ice_fraction"

  ocnstp = 5
  atmstp = (ocnstp-1) + 3*(ocnstp-2)
  lbeg = atmstp
  lend = atmstp+3
  print("lbeg:lend = "+lbeg+"  "+lend)

  ocnfile = addfile (RT2+rtsrc+fto_ocn+"_"+ocnfld+".nc","r")
     ovar = ocnfile->$ocnfld$(ocnstp,:,:)
  ovar@lon2d = ocnlons
  ovar@lat2d = ocnlats   
  ovar = where(oland .eq. 0.0, default_fillvalue(typeof(ovar)), ovar)
  ovar@_FillValue = default_fillvalue(typeof(ovar))

  aland = gf->$atmlandname$(0,:,:)
  aland@lon2d = gf->$tlonname$
  aland@lat2d = gf->$tlatname$
  ;printVarSummary(aland)

  ; get atmfld from "from_atm" file
  fr_atmlist = systemfunc("ls "+RT2+rtsrc+ffr_atm+"*"+tile+".nc")
  ;print(fr_atmlist)
  fr_atmfiles = addfiles(fr_atmlist,"r")
  ListSetType(fr_atmfiles,"join")
   tmp = fr_atmfiles[lbeg:lend]->$atmfld$
  fr_avar = dim_avg_n_Wrap(tmp(:,:,:),0)
  ;printVarSummary(avar)
  ;avar@lon2d = lon2d
  ;avar@lat2d = lat2d
  fr_avar@lon2d = gf->$tlonname$
  fr_avar@lat2d = gf->$tlatname$
  fr_avar = where(aland .eq. 1.0, default_fillvalue(typeof(fr_avar)), atmsgn*fr_avar)
  fr_avar@_FillValue = default_fillvalue(typeof(fr_avar))
  ;print(avar(:,180))

  ; get ice_fration from "to_atm" file
  to_atmlist = systemfunc("ls "+RT2+rtsrc+fto_atm+"*"+tile+".nc")
  ;print(to_atmlist)
  to_atmfiles = addfiles(to_atmlist,"r")
  ListSetType(to_atmfiles,"join")
   tmp = to_atmfiles[lbeg:lend]->ice_fraction
  to_avar = dim_avg_n_Wrap(tmp(:,:,:),0)
  to_avar@lon2d = gf->$tlonname$
  to_avar@lat2d = gf->$tlatname$
  to_avar = where(aland .eq. 1.0, default_fillvalue(typeof(to_avar)), to_avar)
  atmwgt = to_avar ; copy metadata
  ; open water fraction
  atmwgt = (1.0 - to_avar)

  ;default
  cmap="cmp_flux"

  ;levs = (/-40,40,2/)
  ;levs = (/-150,150,10/)
  ;pltvar=fr_avar ; copy metadata
  ;pltvar=fr_avar*atmwgt
  ;fldname=atmfld+".opw"
  ;plottitle=rtname+" med from atm "+atmfld+"*(1-ifrac)"

  levs = (/-800,100,50/)
  ;pltvar=fr_avar 
  ;pltvar=fr_avar*atmsgn
  ;fldname=atmfld
  ;plottitle=rtname+" med from atm "+atmfld

  ;fldname="opw"
  ;pltvar=atmwgt
  ;  cmap="WhBlGrYeRe"  
  ;levs = (/0,1,.05/)
  ;plottitle=rtname+" open water fraction (1-ice_fraction) "

  ;levs = (/-40,40,2/)
  ;levs = (/-150,150,10/)
  ;levs = (/-0.8,0.8,.05/)
  ;levs = (/-1.,1.,.05/)
  pltvar=ovar  ; copy metadata
  ;pltvar=ovar*1.0e5
  fldname=ocnfld
  ;plottitle=rtname+" med to ocn "+ocnfld
  plottitle=rtname+" aofield to ocn "+ocnfld

  wkstitle=rtname+"_"+fldname

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
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
   
  ;res@cnFillOn          = False                  ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle
  
  res@cnFillPalette     = cmap

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

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   ;imcmd = "convert -bordercolor white -border 0x20 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   ;system(imcmd)
  end if
exit
end
