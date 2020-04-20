;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "regionTS.ncl"

;************************************************
begin
 ; print(model)
 ; print(zlevel)

 ;batch = "yes"
 batch = "no"

 ; for grtofs only; where to get the lats/lons
 ;grfile_coord = "yes"
 grfile_coord = "no"

;************************************************
; set up for depth dependent contour levels
;************************************************

  region = "NPole"
  ;region = "GIN"
  ;region = "NAtl"
  ;region = "SPole"

;************************************************
; set up
;************************************************

  if(batch .eq. "no")then
   ;model="hycice"
   ;model="hykiss"
   ;model="m6c5IC"
   ;model="m6c5fv3"
   ;model="cfsrv2"
   ;model="grtofs"
   ;model="grtofs_climo"
   ;model="grtofs_eloan"
   ;model="m5c5"

   model="phc3"
   ;model="woa13"
   ;model="gdem3"
   ;model="gdem3tp"
   ;model="mom6_hyIC"
  end if

  ; whether to plot variables regridded to rectilinear using weights file
  ;regridded = "yes"
  regridded = "no"

  if(batch .eq. "no")then
   ;  zlevel to plot
   ;zlevel = 0.0
   ;zlevel = 10.0
   ;zlevel = 50.0
   ;zlevel = 100.0
   zlevel = 250.0
   ;zlevel = 500.0
   ;zlevel = 1000.0
  end if

;************************************************
; lats/lons for regridded tripole grids
;************************************************

  nemsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"

  if(model .eq. "cfsrv2")then
   grdfile=nemsrc+"regrids/etopo050_oceanmask.nc"
  else
   grdfile=nemsrc+"regrids/etopo024_oceanmask.nc"
  end if
  gr=addfile(grdfile,"r")

  tlon=gr->lon
  tlat=gr->lat

;************************************************
; weights for regridding
;************************************************

   wgtsrc=nemsrc+"regrids/"

  if(model .eq. "m6c5")then
   wgtfile="mom6_rect024.nc"
  end if

  if(model .eq. "hycice" .or. model .eq. "hykiss" .or. model .eq. "gdem3tp")then
   wgtfile="kiss024_rect024.nc"
  end if

  ; fix this---each prob needs own nc,regrid
  if(model .eq. "grtofs" .or. model .eq. "grtofs_climo" .or. model .eq. "grtofs_eloan")then
   wgtfile="kiss008_rect024.nc"
  end if

  if(model .eq. "cfsrv2")then
   wgtfile="mom4_rect050.nc"
  end if

  if(model .eq. "phc3")then
   wgtfile=""
  end if

  if(model .eq. "woa13")then
   wgtfile=""
  end if

  if(model .eq. "gdem3")then
   wgtfile=""
  end if

  if(model .eq. "m5c5")then
   wgtfile=""
  end if

  if(model .eq. "m6c5fv3")then
   wgtfile=""
  end if

  if(model .eq. "mom6_hyIC")then
   wgtfile=""
  end if

  ;print(wgtsrc)
  ;print(wgtfile)
  wgts=wgtsrc+wgtfile

;************************************************
; ocean variables 
;************************************************

  if(model .eq. "m5c5")then
   runnam="MOM5-CICE5"
   rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/test/"
   t_ocnsrc="ocnf.201502.nc"
   s_ocnsrc="ocnf.201502.nc"

        tname="POT_P0_L160_GLL0"
        sname="SALTY_P0_L160_GLL0"
   ocnlonname="lon_0"
   ocnlatname="lat_0"
   zcoordname="lv_DBSL0"
         kmax=40-1
  end if

  if(model .eq. "m6c5IC")then
  ;    rtsrc="/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/FV3-MOM6-CICE5/updateFV3-20180418/MOM6_IC/"
  ;   runnam="MOM6-CICE5-FV3 ICs (source?: MOM4_TS_restart_regular_2016100300.nc)"
  ; t_ocnsrc="MOM6_IC_TS"
  ; s_ocnsrc="MOM6_IC_TS"
      rtsrc="/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/UGCS/cpld_fv3_mom6_cice/MOM6-INPUT/"
     runnam="MOM6-CICE5-FV3 Initial conditions from CFSRv2"
   t_ocnsrc="CFSV2_IC_TS_regrided_2015040100.nc"
   s_ocnsrc="CFSV2_IC_TS_regrided_2015040100.nc"

        tname="temp"
        sname="salinity"
   ocnlonname="xt_ocean"
   ocnlatname="yt_ocean"
   zcoordname="st_ocean"
         kmax=40-1
  end if

  if(model .eq. "m6c5fv3")then
     ; rtsrc="/scratch3/NCEPDEV/stmp2/Bin.Li/post400/rtgen.11643/tmp/ocn/"
     ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
     rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.10294/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
     ;runnam="No FixFreezeMelt; MOM6-CICE5-FV3 35-day spinup"
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/fixfrzmlt_delT_MLD/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_4d_dump/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
     runnam="FixFreezeMelt using MLD; MOM6-CICE5-FV3 35-day spinup"
   t_ocnsrc="ocn_2016_10_06_21.nc"
   s_ocnsrc="ocn_2016_10_06_21.nc"
   ;t_ocnsrc="ocn_2016_10_23_03.nc"
   ;s_ocnsrc="ocn_2016_10_23_03.nc"

        tname="temp"
        sname="so"
   ocnlonname="geolon"
   ocnlatname="geolat"
   zcoordname="zt"
         kmax=40-1
  end if

  if(model .eq. "hycice")then
  ;    rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/"
      rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/ocnout/"
     runnam="HYCOM-CICE5-GSM"
   ;t_ocnsrc="arch.2015-04"
   ;s_ocnsrc="arch.2015-04"
   t_ocnsrc="archv.2015_092_00_3dtz"
   s_ocnsrc="archv.2015_092_00_3dsz"

        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "hykiss")then
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/KISS007/"
     runnam="HYCOM-KISS-GSM"
   t_ocnsrc="arch.2015-07"
   s_ocnsrc="arch.2015-07"

        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "grtofs_climo")then
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_climo/"
     runnam="HYCOM 1/12 + CICE4 (April mean after 20year spinup)"
   t_ocnsrc="arch.1920-04.3dtz"
   s_ocnsrc="arch.1920-04.3dsz"
   ;t_ocnsrc="arch.1920-10.3dtz"
   ;s_ocnsrc="arch.1920-10.3dsz"

        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "grtofs")then
     ; rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS/"
     ; rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/testget/20170701/"
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_para/"
     runnam="RTOFS operational"
   Date2Plt = "20161015"
   t_ocnsrc="rtofs_glo_3dz_n048_daily_3ztio."+Date2Plt+".nc"
   s_ocnsrc="rtofs_glo_3dz_n048_daily_3zsio."+Date2Plt+".nc"
   ;t_ocnsrc="rtofs_glo_3dz_n048_daily_3ztio.20180515.nc"
   ;s_ocnsrc="rtofs_glo_3dz_n048_daily_3zsio.20180515.nc"
   ;t_ocnsrc="rtofs_glo_3dz_n048_daily_3ztio.20170701.nc"
   ;s_ocnsrc="rtofs_glo_3dz_n048_daily_3zsio.20170701.nc"
   ;t_ocnsrc="rtofs_glo_3dz_f024_daily_3ztio.nc"
   ;s_ocnsrc="rtofs_glo_3dz_f024_daily_3zsio.nc"

   ;     tname="temperature"
        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1

   ; load the grid file
   gf =addfile(nemsrc+"hycom_data/mx008/hycom_grid_008.nc","r")
   gfocnlonname="plon"
   gfocnlatname="plat"
  end if

 if(model .eq. "grtofs_eloan")then
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_eloan/"
     runnam="RTOFS operational, HYCOM + ELoan"
      cdate="20150701"
   t_ocnsrc="archv."+cdate+"_3ztio.nc"
   s_ocnsrc="archv."+cdate+"_3zsio.nc"

        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "cfsrv2")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/mom_data/mx050/"
     runnam="CFSv2 20150401 (source: ocnanl.gdas.2015040100.tar=>ocean_temp_salt.res.nc, ocean_velocity.res.nc)"
   t_ocnsrc="cfsv2_TSUV_init"
   s_ocnsrc="cfsv2_TSUV_init"

        tname="temp"
        sname="salt"
   ocnlonname="plon"
   ocnlatname="plat"
   zcoordname="zt"
         kmax=40-1
  end if

  if(model .eq. "phc3")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/phc3/"
     runnam="PHC3.0"
   t_ocnsrc="phc3.0_annual_fixed"
   s_ocnsrc="phc3.0_annual_fixed"
   ;t_ocnsrc="phc3.0_monthly_fixed"
   ;s_ocnsrc="phc3.0_monthly_fixed"

        tname="temp"
        sname="salt"
   ocnlonname="lon"
   ocnlatname="lat"
   zcoordname="depth"
         kmax=33-1
  end if

  if(model .eq. "woa13")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/woa13/"
     runnam="WOA13"
   t_ocnsrc="woa13_annualTS"
   s_ocnsrc="woa13_annualTS"

        tname="t_an"
        sname="s_an"
   ocnlonname="lon"
   ocnlatname="lat"
   zcoordname="depth"
         kmax=102-1
  end if

  if(model .eq. "gdem3")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/gdem3/"
     runnam="GDEM3"
   t_ocnsrc="t_m10"
   s_ocnsrc="s_m10"

        tname="Potential_Temperature"
        sname="Salinity"
   ocnlonname="longitude"
   ocnlatname="latitude"
   zcoordname="depth"
         kmax=78-1
  end if

  if(model .eq. "gdem3tp")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/gdem3/"
     runnam="GDEM3"
   t_ocnsrc="gdem3_10"
   s_ocnsrc="gdem3_10"

        tname="ptemp"
        sname="salt"
   ocnlonname="plon"
   ocnlatname="plat"
   zcoordname="zt"
         kmax=78-1
  end if

  if(model .eq. "mom6_hyIC")then
      rtsrc="/scratch4/NCEPDEV/stmp4/Bin.Li/RT/HYCOM/20160327/GLBp0.25/"
     runnam="MOM6 ICs from HYCOM (20160327)"
   t_ocnsrc="v1_archv.20160327_3zt"
   s_ocnsrc="v1_archv.20160327_3zt"

        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=40-1
  end if

  t_ocnfile=addfile(rtsrc+t_ocnsrc+".nc","r")
  s_ocnfile=addfile(rtsrc+s_ocnsrc+".nc","r")
  print(t_ocnsrc)
  print(s_ocnsrc)

;************************************************
; load an ocn field
;************************************************

  lstep=1-1

  ; ocean depths
      odepth=t_ocnfile->$zcoordname$
  ; find the k index closest to the zlevel depth
       kstep=closest_val(zlevel,odepth)
  if(model .eq. "m6c5IC" .or. model .eq. "gdem3")then
        tvar=t_ocnfile->$tname$(kstep,:,:)
        svar=s_ocnfile->$sname$(kstep,:,:)
  else 
        tvar=t_ocnfile->$tname$(lstep,kstep,:,:)
        svar=s_ocnfile->$sname$(lstep,kstep,:,:)
  end if
       depth=odepth(kstep)
  print("depth = "+depth)

  if(model .eq. "phc3" .or. model .eq. "woa13" .or. model .eq. "gdem3" .or. model .eq. "m5c5" .or. model .eq. "m6c5IC")then
   tvar@lon=t_ocnfile->$ocnlonname$
   tvar@lat=t_ocnfile->$ocnlatname$
   svar@lon=s_ocnfile->$ocnlonname$
   svar@lat=s_ocnfile->$ocnlatname$
  ; already on rectilinear grid
       tvar_regrid = tvar
       svar_regrid = svar
   ;printVarSummary(tvar_regrid)
   tvar_regrid@lon = tvar@lon
   tvar_regrid@lat = tvar@lat
   svar_regrid@lon = svar@lon
   svar_regrid@lat = svar@lat
  ; reassign tlon,tlat
              tlon := tvar@lon
              tlat := tvar@lat
  else
   if(model .eq. "grtofs" .and. grfile_coord .eq. "yes")then
    tvar@lon2d=gf->$gfocnlonname$
    tvar@lat2d=gf->$gfocnlatname$
    svar@lon2d=gf->$gfocnlonname$
    svar@lat2d=gf->$gfocnlatname$
   else
    tvar@lon2d=t_ocnfile->$ocnlonname$
    tvar@lat2d=t_ocnfile->$ocnlatname$
    svar@lon2d=t_ocnfile->$ocnlonname$
    svar@lat2d=t_ocnfile->$ocnlatname$
    if(model .eq. "m6c5fv3")then
     tvar@lon2d = mod(tvar@lon2d+720.0,360.0) 
     svar@lon2d = mod(svar@lon2d+720.0,360.0) 
    end if
   end if

       tvar_regrid = ESMF_regrid_with_weights(tvar, wgts, True)
       svar_regrid = ESMF_regrid_with_weights(svar, wgts, True)
   tvar_regrid@lon = tlon
   tvar_regrid@lat = tlat
   svar_regrid@lon = tlon
   svar_regrid@lat = tlat
   ;printVarSummary(tvar_regrid)
  end if

  ;plottitle=rtsrc+t_ocnsrc+",  z="+depth
  plottitle=rtsrc+t_ocnsrc
  ;plottitle=t_ocnsrc+",  z="+depth
  wkstitle=model+"_z"+zlevel

  tvar@units=""
  tvar@long_name=""
  svar@units=""
  svar@long_name=""

;************************************************
;
;************************************************

  if(model .eq. "m5c5")then
   tvar = tvar - 273.15
   svar = svar*1.0e3
  end if

;************************************************
; set appropriate levels
;************************************************

   ; pick the values appropriate for this region
   levels = regionTS(region,zlevel,False)
   ;print(levels)
   tlevs = levels(0,:)
   slevs = levels(1,:)
    vmag = levels(2,0)
    vthn = levels(2,1)

  ;print("found contour intervals at klev = "+klev+" for depth "+zlevel)
  ;print(tlevs)
  ;print(slevs)

;************************************************
; region resources
;************************************************

 ; default
 nrows = 1
 ncols = 2
 
 if(region .eq. "NPole")then
    hemi = "NH"
  ;minlat =  66.0
  minlat =  88.0
  cenlon = -45.0
 end if
 if(region .eq. "GIN")then
  minlat =  62.0
  maxlat =  84.0
  minlon = -20.0
  maxlon =  20.0
 end if
 if(region .eq. "NAtl")then
  minlat =  20.0
  maxlat =  60.0
  minlon = -82.0
  maxlon =  10.0
   nrows = 2
   ncols = 1
 end if
 if(region .eq. "SPole")then
    hemi = "SH"
  maxlat = -50.0
  cenlon = -45.0
 end if

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  if(region .eq. "NPole")then
   if(model .eq. "m6c5" .or. model .eq. "m5c5" .or. model .eq. "m6c5fv3")then
    lon1=  60.00
    lon2=-120.00
   else if(model .eq. "cfsrv2")then
    lon1=  80.00
    lon2=-100.00
   else
    lon1=  74.12
    lon2=-105.88
   end if
   end if
    lat1=  60.00
    lat2=  60.00
  end if

  if(region .eq. "NPole")then
  ; a xsection to mark
   ;xlon1 = 195.00
   ;xlon2 =  15.00

   ;xlon1 = 170.00
   ;xlon2 =  10.00

   xlon1 = 140.00
   xlon2 = 345.00

   xlat1 =  66.00
   xlat2 =  66.00
  end if
  if(region .eq. "NAtl")then
   ; GS
  xlat1 =  33.0
  xlon1 = -80.0+360.0
  xlat2 =  30.0
  xlon2 = -77.0+360.0
 end if

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  ;wkstype@wkWidth=1200
  ;wkstype@wkHeight=1200
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)             
  ;drawNDCGrid(wks)

  plot = new(2,graphic)
 oplot = new(2,graphic)
   dum = new(2,graphic)
  xum1 = new(2,graphic)
  xum2 = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnFillDrawOrder      = "PreDraw"             ; draw contours first

  if(model .eq. "m6c5fv3")then
   res@gsnAddCyclic     = False
  end if

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  if(region .eq. "NPole")then
   res@gsnPolar     =  "NH"                  ; specify the hemisphere
   res@mpMinLatF    =  minlat                ; minimum lat to plot
   res@mpCenterLonF =  cenlon
   res@mpGreatCircleLinesOn = True
  else
  if(region .eq. "SPole")then
   res@gsnPolar     =  hemi                  ; specify the hemisphere
   res@mpMaxLatF    =  maxlat                ; minimum lat to plot
   res@mpCenterLonF =  cenlon
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
  end if
  end if

  ;res@cnFillPalette   =  "cmp_b2r"                         ; choose colormap
  ;res@cnFillPalette   =  "NCV_blu_red"                     ; choose colormap
  res@cnFillPalette   =  "MPL_rainbow"                      ; choose colormap

;************************************************
; Resources for the polyline
;************************************************

  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
; Resources for the x-section polyline
;************************************************

  xres1                   = True          ; polyline mods desired
  xres1@gsLineThicknessF  = 4.0           ; line thickness
  xres1@gsLineColor       = "blue"        ; color of lines
  xres1@gsLineDashPattern =  2            ; short dashes

  xres2                   = True          ; polyline mods desired
  xres2@gsLineThicknessF  = 4.0           ; line thickness
  xres2@gsLineColor       = "black"       ; color of lines
  xres2@gsLineDashPattern =  2            ; short dashes

;************************************************
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineThicknessF = 4.0            ; line thickness
  ores@cnLineColor      = "green"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnLevelSelectionMode = "EqualSpacedLevels"     ; set the contour levels with the following 3 resources

;************************************************
; the subplot call
;************************************************

function subplot(ii,scalarfield)
begin
   ; pick the scalar field
   if(scalarfield .eq. "temperature")then
    if(regridded .eq. "yes")then
     pltvar=tvar_regrid
    else
     pltvar=tvar
    end if
     pltlev=tlevs
     ores@cnLevels = (/1.8/)
   end if

   if(scalarfield .eq. "salinity")then
    if(regridded .eq. "yes")then
     pltvar=svar_regrid
    else
     pltvar=svar
    end if
     pltlev=slevs
     ores@cnLevels = (/34.98/)
   end if

   ;res@gsnCenterString = scalarfield+" z="+sprintf("%5.0f", depth)
   ;res@gsnCenterStringFontHeightF = 0.02

   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   res@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   res@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   res@cnLevelSpacingF = pltlev(2)                      ; set the interval between contours

   ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   ;ores@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   ;ores@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   ;ores@cnLevelSpacingF = 2.0                            ; set the interval between contours

  if(region .eq. "NPole" .or. region .eq. "SPole")then
   plot(ii) = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  oplot(ii) = gsn_csm_contour(wks,pltvar,ores)             ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;    xlon1 = 210.00
  ;    xlon2 =  30.00
  ;  xum1(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres1)
  ; add a second 
  ;     xlon1 = 140.00
  ;     xlon2 = 345.00
  ;  xum2(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres2)
    overlay(plot(ii),oplot(ii))
  else
   plot(ii) = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
   xum1(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres1)
  end if
   return(plot(ii))
end
;************************************************
;
;************************************************

  ii = 0
  plot(ii) = subplot(ii,"temperature")    ; create the plot
  ;ii = 1
  ;plot(ii) = subplot(ii,   "salinity")    ; create the plot

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.008                     ; font smaller. default big

  xx = 0.5
  yy = 0.15
; page coordinates are normalized. go from 0->1 not 0->8" etc.
   gsn_text_ndc(wks,rtsrc+t_ocnsrc,xx,yy,txres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
   
  ;resP@gsnPanelMainString  = plottitle
  ;resP@gsnPanelMainString  = runnam
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

  ;resP@txFontHeightF = .015
  ;resP@txString = plottitle
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

  if(batch .eq. "yes")then
   imcmd = "convert "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
