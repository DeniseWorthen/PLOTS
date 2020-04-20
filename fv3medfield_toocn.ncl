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

;************************************************
;  Atm lats/lons and mask
;************************************************

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
        atmlons = gf->$tlonname$
        atmlats = gf->$tlatname$
          aland = gf->$atmlandname$(0,:,:)
  atmlons@units = "degrees_E"
  atmlats@units = "degrees_N"
    aland@lon2d = atmlons
    aland@lat2d = atmlats

;************************************************
;
;************************************************

  ocnstp = 5
  atmstp = (ocnstp-1) + 3*(ocnstp-2)
  lbeg = atmstp
  lend = atmstp+3
  print("lbeg:lend = "+lbeg+"  "+lend)

  ; from atm fields
  ffr_atm = "field_med_from_atm_0000"
  atmflds = (/"mean_sensi_heat_flx",  \
              "mean_laten_heat_flx",  \
              "mean_zonal_moment_flx",\
              "mean_merid_moment_flx",\
              "mean_net_lw_flx"/)

  atmsgns = (/-1.0, \
              -1.0/const_lhvap,\
              -1.0, \
              -1.0, \
               1.0/)
 
  ; plot levels
  plotlevs = new((/5,3/), float)
  plotlevs(0,:) = (/-900,40,20/)
  plotlevs(1,:) = (/-15.,5.,1./)
  plotlevs(2,:) = (/-0.8,0.8,.02/)
  plotlevs(3,:) = (/-0.8,0.8,.02/)
  plotlevs(4,:) = (/-360,-300,5/)
  
  ;print(plotlevs)

  ;default
  cmap="cmp_flux"

;************************************************
;
;************************************************

  ; get atmflds...steps are in different files
  fr_atmlist = systemfunc("ls "+RT2+rtsrc+ffr_atm+"*"+tile+".nc")
  atmfiles = addfiles(fr_atmlist,"r")
  ListSetType(atmfiles,"join")
  ;print(atmfiles)

  ; pick a field to plot
  fldtoplot = 4
       levs = plotlevs(fldtoplot,:)
    fldname = atmflds(fldtoplot)
  plottitle = rtname+" field from atm "+fldname
   wkstitle = rtname+"_fld_fr_atm_"+fldname

  ; special settings
       awgt = atmsgns(fldtoplot)
  if(fldname .eq. "mean_laten_heat_flx")then
       cmap = "amwg256"
       awgt = awgt*1.0e5      
  end if
  if(fldname .eq. "mean_net_lw_flx")then
       cmap = "amwg256"
  end if
  if(fldname .eq. "mean_sensi_heat_flx")then
       cmap = "amwg256"
  end if

        avar = dim_avg_n_Wrap(atmfiles[:]->$fldname$(lbeg:lend,:,:),0)
        avar = avar*awgt
  avar@lon2d = atmlons
  avar@lat2d = atmlats
  avar = where(aland .eq. 1.0, default_fillvalue(typeof(avar)), avar)
  avar@_FillValue = default_fillvalue(typeof(avar))

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
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
exit
end
