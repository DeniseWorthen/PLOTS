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

  ;region = "NPole"
  ;region = "GIN"
  region = "NAtl"
  ;region = "SPole"

;************************************************
; set up
;************************************************

  if(batch .eq. "no")then
   ;model="hycice"
   ;model="hykiss"
   ;model="m6c5"
   model="m6c5fv3"
   ;model="cfsrv2"
   ;model="grtofs"
   ;model="grtofs_climo"
   ;model="grtofs_eloan"
   ;model="phc3"
   ;model="woa13"
   ;model="gdem3tp"
   ;model="mom6_IC"
  end if

  if(batch .eq. "no")then
   ;  zlevel to plot
   ; zlevel = 0.0
   ;zlevel = 10.0
   ;zlevel = 50.0
   zlevel = 100.0
   ;zlevel = 250.0
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

   wgtsrc = nemsrc+"regrids/"

  if(model .eq. "m6c5")then
   wgtfile="mom6_rect024.nc"
  end if

  if(model .eq. "hycice" .or. model .eq. "hykiss" .or. model .eq. "gdem3tp")then
   wgtfile="kiss024_rect024.nc"
  end if

  if(model .eq. "grtofs" .or. model .eq. "grtofs_climo" .or. model .eq. "grtofs_eloan" .or. model .eq. "grtofs_para")then
   wgtfile="hycom008_rect024.nc"
  end if

  if(model .eq. "cfsrv2")then
   wgtfile="mom4_rect050.nc"
  end if

  if(model .eq. "phc3")then
   wgtsrc=""
   wgtfile=""
  end if

  if(model .eq. "woa13")then
   wgtsrc=""
   wgtfile=""
  end if

  if(model .eq. "m6c5fv3")then
   wgtfile="mom6_rect024.nc"
  end if

  if(model .eq. "mom6_IC")then
   wgtfile=""
  end if

  ;print(wgtsrc)
  ;print(wgtfile)
  wgts=wgtsrc+wgtfile

;************************************************
; ocean variables 
;************************************************

  if(model .eq. "m6c5")then
   ;rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/mom6_cice5/ocnout/"
   ;t_ocnsrc="ocn_2015_04_01"
      rtsrc="/scratch3/NCEPDEV/stmp1/Jiande.Wang/For_Denise/RUN-M25.574.2015010100_1D_NEW/"
     runnam="MOM6-CICE5"
   t_ocnsrc="ocn_2015_01_01_03"
   s_ocnsrc="ocn_2015_01_01_03"

        tname="temp"
        sname="so"
   ocnlonname="geolon"
   ocnlatname="geolat"
   zcoordname="zt"
         kmax=40-1
  end if

  if(model .eq. "m6c5fv3")then
  ;    rtsrc="/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/FV3-MOM6-CICE5/updateFV3-20180418/MOM6_IC/"
  ;   runnam="MOM6-CICE5-FV3 ICs (source?: MOM4_TS_restart_regular_2016100300.nc)"
  ; t_ocnsrc="MOM6_IC_TS"
  ; s_ocnsrc="MOM6_IC_TS"
  ;    rtsrc="/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT/UGCS/cpld_fv3_mom6_cice/MOM6-INPUT/"
  ;   runnam="MOM6-CICE5-FV3 Initial conditions from CFSRv2"
  ; t_ocnsrc="CFSV2_IC_TS_regrided_2015040100.nc"
  ;s_ocnsrc="CFSV2_IC_TS_regrided_2015040100.nc"
      rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d_newrot/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
      runnam="FixFreezeMelt using MLD; MOM6-CICE5-FV3 35-day spinup"
   cday="2016_11_06"
   t_ocnsrc="ocn_"+cday+".nc"
   s_ocnsrc="ocn_"+cday+".nc"

        tname="temp"
        sname="so"
   ocnlonname="geolon"
   ocnlatname="geolat"
   zcoordname="zt"
         kmax=40-1
  end if

  if(model .eq. "hycice")then
     ; rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/"
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
   t_ocnsrc="arch.2015-04"
   s_ocnsrc="arch.2015-04"

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

        tname="pot_temp"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "grtofs")then
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS/"
     runnam="RTOFS operational n048" 
   t_ocnsrc="rtofs_glo_3dz_n048_daily_3ztio.20180515.nc"
   s_ocnsrc="rtofs_glo_3dz_n048_daily_3zsio.20180515.nc"

   ;     tname="pot_temp"
        tname="temperature"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "grtofs_eloan")then
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_eloan/"
     runnam="RTOFS operational, HYCOM+ELOAN, archv from restart "
   t_ocnsrc="archv.20150901_3ztio.nc"
   s_ocnsrc="archv.20150901_3zsio.nc"

        tname="pot_temp"
   ;     tname="temperature"
        sname="salinity"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
  end if

  if(model .eq. "cfsrv2")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/mom_data/mx050/"
     runnam="CFSv2  20150401 (source: ocnanl.gdas.2015040100.tar=>ocean_temp_salt.res.nc, ocean_velocity.res.nc)"
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
     runnam="PHC 3.0"
   t_ocnsrc="phc3.0_annual_fixed"
   s_ocnsrc="phc3.0_annual_fixed"

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

  if(model .eq. "gdem3tp")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/gdem3/"
     runnam="GDEM3"
   t_ocnsrc="gdem3_04"
   s_ocnsrc="gdem3_04"

        tname="ptemp"
        sname="salt"
   ocnlonname="plon"
   ocnlatname="plat"
   zcoordname="zt"
         kmax=78-1
  end if

  if(model .eq. "mom6_IC")then
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
;************************************************
; load an ocn field
;************************************************

  lstep=1-1

  ; ocean depths
      odepth=t_ocnfile->$zcoordname$
  ; find the k index closest to the zlevel depth (add a level to capture zlevel)
       kstep=closest_val(zlevel,odepth)+1
  if(model .eq. "gdem3")then
        tvar=t_ocnfile->$tname$(0:kstep,:,:)
        svar=s_ocnfile->$sname$(0:kstep,:,:)
  else
        tvar=t_ocnfile->$tname$(lstep,0:kstep,:,:)
        svar=s_ocnfile->$sname$(lstep,0:kstep,:,:)
  end if
       depth=odepth(0:kstep)
  ;printVarSummary(svar)

  if(model .eq. "phc3" .or. model .eq. "woa13" .or. model .eq. "mom6_IC")then
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
   tvar@lon2d=t_ocnfile->$ocnlonname$
   tvar@lat2d=t_ocnfile->$ocnlatname$
   svar@lon2d=s_ocnfile->$ocnlonname$
   svar@lat2d=s_ocnfile->$ocnlatname$
  
       tvar_regrid = ESMF_regrid_with_weights(tvar, wgts, True)
       svar_regrid = ESMF_regrid_with_weights(svar, wgts, True)
   tvar_regrid@lon = tlon
   tvar_regrid@lat = tlat
   svar_regrid@lon = tlon
   svar_regrid@lat = tlat
   ;printVarSummary(tvar_regrid)
  end if

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
   levels = regionTS(region,zlevel,True)
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
  minlat =  66.0
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
; xsection along great circle path from (xlon1,xlat1) to (xlon2,xlat2)
;************************************************

 if(region .eq. "NPole")then
 end if
 if(region .eq.  "NAtl")then
  ; GS
  xlat1 =  33.0
  xlon1 = -80.0+360.0
  xlat2 =  30.0
  xlon2 = -77.0+360.0
 end if

  plottitle=rtsrc+t_ocnsrc+" transect along "+xlon1+"E,"+xlon2+"E"
  wkstitle=model+"_xsec_"+xlon1+"_"+xlon2

  npts     =   100                    ; number of points in resulting transect
  dist     = gc_latlon(xlat1,xlon1,xlat2,xlon2,npts,2)
  ;print(dist@gclat)

  ; make a cross-section in z
  temp_xsec  = linint2_points_Wrap(tlon,tlat,tvar_regrid,True,dist@gclon,dist@gclat,2)
  salt_xsec  = linint2_points_Wrap(tlon,tlat,svar_regrid,True,dist@gclon,dist@gclat,2)
  ;copy_VarAtts(tvar,xsec)          ; copy attributes
 
  temp_xsec@units=""
  temp_xsec@long_name=""
  salt_xsec@units=""
  salt_xsec@long_name=""

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window
  ;drawNDCGrid(wks)

  plot = new(2,graphic)
 oplot = new(2,graphic)

;************************************************
;
;************************************************

  res             = True        ; plot mods desired
  res@gsnDraw     = False	; don't draw
  res@gsnFrame    = False	; don't advance frame

  res@cnFillOn             = True
 ; res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@cnLinesOn            = False             ; no contour lines
  res@lbLabelBarOn         = True              ; turn off individual colorbars
  res@lbLabelFontHeightF   = 0.015

  res@trYReverse           = True
  res@gsnYAxisIrregular2Linear = True ; converts irreg depth to linear
  res@sfYArray             = depth

  ;res@vpWidthF             = 0.7
  ;res@vpHeightF            = 0.4
  res@vpWidthF             = 0.9
  res@vpHeightF            = 0.3
 
  n1 = npts-1                             ; convenience
  res@tmXBMode   = "Explicit"
  res@tmXBValues = (/0, 16, 33, 50, 66, 83, n1/)
  res@tmXBLabels = (/sprintf("%5.1f", dist@gclat( 0)) \
                    ,sprintf("%5.1f", dist@gclat(16)) \
                    ,sprintf("%5.1f", dist@gclat(33)) \
                    ,sprintf("%5.1f", dist@gclat(50)) \
                    ,sprintf("%5.1f", dist@gclat(66)) \
                    ,sprintf("%5.1f", dist@gclat(83)) \
                    ,sprintf("%5.1f", dist@gclat(n1)) /)

  ;res@cnFillPalette   =  "cmp_b2r"                     ; choose colormap
  ;res@cnFillPalette   =  "NCV_blu_red"                     ; choose colormap
  res@cnFillPalette   =  "MPL_rainbow"                     ; choose colormap

;************************************************
; resources for overlay
;************************************************

  ores                  = True        ; plot mods desired
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False	; don't draw
  ores@gsnFrame         = False	; don't advance frame
  ores@gsnLeftString    = ""	; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources

;************************************************
; the subplot call
;************************************************

function subplot(ii,scalarfield)
begin
   ; pick the scalar field
   if(scalarfield .eq. "temperature")then
    pltvar=temp_xsec
    pltlev=tlevs
    ores@cnLevels = (/1.8/)
    ;ores@cnLevelSpacingF = 10*pltlev(2)                    ; set the interval between contours
   end if

   if(scalarfield .eq. "salinity")then
    pltvar=salt_xsec
    pltlev=slevs
    ores@cnLevels = (/34.98/)
    ;ores@cnLevelSpacingF = 5*pltlev(2)                    ; set the interval between contours
   end if

   res@gsnCenterString = scalarfield
   res@gsnCenterStringFontHeightF = 0.020

   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   res@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   res@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   res@cnLevelSpacingF = pltlev(2)                      ; set the interval between contours

  ;ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;ores@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
  ;ores@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level

   plot(ii) = gsn_csm_contour(wks,pltvar, res)  
  oplot(ii) = gsn_csm_contour(wks,pltvar,ores)  

  overlay(plot(ii),oplot(ii))
   return(plot(ii))
end

;************************************************
;
;************************************************

  ii = 0
  plot(ii) = subplot(ii,"temperature")    ; create the plot
  ii = 1
  plot(ii) = subplot(ii,   "salinity")    ; create the plot
   
;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.008                     ; font smaller. default big

  xx = 0.5
  yy = 0.35
  ;yy = 0.01
; page coordinates are normalized. go from 0->1 not 0->8" etc.
   gsn_text_ndc(wks,rtsrc+t_ocnsrc,xx,yy,txres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  ;resP@txFontHeightF = .010
  ;resP@txString = plottitle
  resP@gsnPanelMainString  = runnam+" transect along "+xlon1+"E,"+xlon2+"E"
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x30 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)

   ;imcmd = "convert "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
  end if

exit
end
