;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************
begin
 ; print(model)
 ; print(zlevel)

 ;batch = "yes"
 batch = "no"

;************************************************
; arrays for depth dependent contour levels
;************************************************

  ;tlevs_polar(0,:) = (/ (/   0.0, -1.5,  1.5,  .050/) /)
  ;tlevs_polar(3,:) = (/ (/ 500.0, -0.2,  1.0,  .020/) /)

  tlevs_polar = new((/5,4/),float)
  tlevs_polar(0,:) = (/ (/   0.0, -1.8, -1.2,  .010/) /)
  ;tlevs_polar(1,:) = (/ (/ 100.0, -1.6,  3.2,  .050/) /)
  tlevs_polar(1,:) = (/ (/ 100.0, -1.4,   0.6,  .020/) /)
  tlevs_polar(2,:) = (/ (/ 200.0, -0.2,  3.0,  .050/) /)
  ;tlevs_polar(3,:) = (/ (/ 500.0, -0.8,  2.4,  .050/) /)
  tlevs_polar(3,:) = (/ (/ 500.0, 0.0,  1.2,  .020/) /)
  tlevs_polar(4,:) = (/ (/1000.0, -0.7,  0.7,  .025/) /)

  slevs_polar = new((/5,4/),float)
  slevs_polar(0,:) = (/ (/   0.0, 28.40,  35.20,  0.200/) /)
  ;slevs_polar(1,:) = (/ (/ 100.0, 28.40,  35.20,  0.200/) /)
  slevs_polar(1,:) = (/ (/ 100.0, 31.60,  34.80,  0.050/) /)
  slevs_polar(2,:) = (/ (/ 200.0, 33.50,  35.10,  0.025/) /)
  ;slevs_polar(3,:) = (/ (/ 500.0, 34.60,  35.02,  0.010/) /)
  slevs_polar(3,:) = (/ (/ 500.0, 34.80,  35.00,  0.005/) /)
  slevs_polar(4,:) = (/ (/1000.0, 34.86,  34.94,  0.002/) /)

  ; an array for depth dependent vector settings
  ; depth,vmag,vthin
  vecvals = new((/5,3/),float)
  vecvals(0,:) = (/ (/   0.0, 0.30, 0.010/) /)
  vecvals(1,:) = (/ (/ 100.0, 0.10, 0.008/) /)
 ; vecvals(2,:) = (/ (/ 200.0, 0.10, 0.008/) /)
  vecvals(2,:) = (/ (/ 200.0, 0.05, 0.008/) /)
  vecvals(3,:) = (/ (/ 500.0, 0.06, 0.008/) /)
  vecvals(4,:) = (/ (/1000.0, 0.04, 0.008/) /)

;************************************************
; set up
;************************************************

  if(batch .eq. "no")then
   ;model="hycice"
   ;model="hykiss"
   ;not working yet---need to move velocities,rotate
   ;;model="m6c5"
   ;model="m5c5"
   ;model="cfsrv2"
   ;model="grtofs"
   ;model="grtofs_climo"
   ; no velocities so remove the vector plots
   model="mom6_IC"
  end if

  region = "polar"
  ;region = "GIN"

  ; whether to plot variables regridded to rectilinear using weights file
  ;regridded = "yes"
  regridded = "no"

;************************************************
; lats/lons for regridded tripole grids
;************************************************

  nemsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"

  if(model .eq. "cfrsv2")then
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

  if(model .eq. "m5c5")then
   wgtfile=" "
  end if

  if(model .eq. "m6c5")then
   wgtfile="mom6_rect024.nc"
  end if

  if(model .eq. "hycice" .or. model .eq. "hykiss")then
   wgtfile="kiss024_rect024.nc"
  end if

  if(model .eq. "grtofs" .or. model .eq. "grtofs_climo")then
   wgtfile="hycom008_rect024.nc"
  end if

  if(model .eq. "cfsrv2")then
   wgtfile="mom4_rect050.nc"
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

  if(model .eq. "m5c5")then
   rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/test/"
   t_ocnsrc="ocnf.201502.nc"
   s_ocnsrc="ocnf.201502.nc"
   u_ocnsrc="ocnf.201502.nc"
   v_ocnsrc="ocnf.201502.nc"

        tname="POT_P0_L160_GLL0"
        sname="SALTY_P0_L160_GLL0"
        uname="UOGRD_P0_L160_GLL0"
        vname="VOGRD_P0_L160_GLL0"
       rotate="no"
   ocnlonname="lon_0"
   ocnlatname="lat_0"
   zcoordname="lv_DBSL0"
         kmax=40-1
        xyskp=1
        uvskp=1
  end if

  if(model .eq. "m6c5")then
   rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/mom6_cice5/ocnout/"
   t_ocnsrc="ocn_2015_04_01"
   s_ocnsrc="ocn_2015_04_01"
   u_ocnsrc="ocn_2015_04_01"
   v_ocnsrc="ocn_2015_04_01"
   ;   rtsrc="/scratch3/NCEPDEV/stmp1/Jiande.Wang/For_Denise/RUN-M25.574.2015010100_1D_NEW/"
   ;t_ocnsrc="ocn_2015_01_01_03"
   ;s_ocnsrc="ocn_2015_01_01_03"
   ;u_ocnsrc="ocn_2015_01_01_03"
   ;v_ocnsrc="ocn_2015_01_01_03"

        tname="temp"
        sname="so"
        uname="uo"
        vname="vo"
       rotate="yes"
   ocnlonname="geolon"
   ocnlatname="geolat"
   zcoordname="zt"
         kmax=40-1
        xyskp=1
        uvskp=1
  end if

  if(model .eq. "hycice")then
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/"
      rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/ocnout/"
     runnam="HYCOM-CICE5-GSM"
   ;t_ocnsrc="arch.2015-04"
   ;s_ocnsrc="arch.2015-04"
   ;u_ocnsrc="arch.2015-04"
   ;v_ocnsrc="arch.2015-04"
   t_ocnsrc="archv.2015_092_00_3dtz"
   s_ocnsrc="archv.2015_092_00_3dsz"
   u_ocnsrc="archv.2015_092_00_3duz"
   v_ocnsrc="archv.2015_092_00_3dvz"

        tname="pot_temp"
        sname="salinity"
        uname="u"
        vname="v"
       rotate="no"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
        xyskp=1
        uvskp=1
  end if

  if(model .eq. "hykiss")then
      rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/KISS016/"
   t_ocnsrc="arch.2015-04"
   s_ocnsrc="arch.2015-04"
   u_ocnsrc="arch.2015-04"
   v_ocnsrc="arch.2015-04"

        tname="pot_temp"
        sname="salinity"
        uname="u"
        vname="v"
       rotate="no"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
        xyskp=1
        uvskp=1
  end if

  if(model .eq. "grtofs_climo")then
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_climo/"
     runnam="HYCOM 1/12 + CICE4 (April mean after 20year spinup)"
   t_ocnsrc="arch.1920-04.3dtz"
   s_ocnsrc="arch.1920-04.3dsz"
   u_ocnsrc="arch.1920-04.3duz"
   v_ocnsrc="arch.1920-04.3dvz"

        tname="pot_temp"
        sname="salinity"
        uname="u"
        vname="v"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=33-1
        xyskp=3
        uvskp=8
  end if

  if(model .eq. "grtofs")then
      ;rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_20150401/"
      ;rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_climo/"
      rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS/"
     runnam="RTOFS operational, n048 "
   Date2Plt = "20171017"
   t_ocnsrc="rtofs_glo_3dz_n048_daily_3ztio."+Date2Plt+".nc"
   s_ocnsrc="rtofs_glo_3dz_n048_daily_3zsio."+Date2Plt+".nc"
   u_ocnsrc="rtofs_glo_3dz_n048_daily_3zuio."+Date2Plt+".nc"
   v_ocnsrc="rtofs_glo_3dz_n048_daily_3zvio."+Date2Plt+".nc"
   ;t_ocnsrc="archv.20150401_3dtz"
   ;s_ocnsrc="archv.20150401_3dsz"
   ;u_ocnsrc="archv.20150401_3duz"
   ;v_ocnsrc="archv.20150401_3dvz"
   ;   rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_20170401/"
   ;t_ocnsrc="archv.2017_091_00_3dtz"
   ;s_ocnsrc="archv.2017_091_00_3dsz"
   ;   rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_20161215/"
   ;t_ocnsrc="rtofs_glo_3dz_f024_daily_3ztio.nc"
   ;s_ocnsrc="rtofs_glo_3dz_f024_daily_3zsio.nc"
   ;u_ocnsrc="rtofs_glo_3dz_f024_daily_3zuio.nc"
   ;v_ocnsrc="rtofs_glo_3dz_f024_daily_3zvio.nc"
   ;   rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_20170401_32/"
   ;t_ocnsrc="rtofs_glo_3dz_f024_daily_3ztio.nc"
   ;s_ocnsrc="rtofs_glo_3dz_f024_daily_3zsio.nc"

  ;      tname="pot_temp"
        tname="temperature"
        sname="salinity"
        uname="u"
        vname="v"
       rotate="no"
   ocnlonname="Longitude"
   ocnlatname="Latitude"
   zcoordname="Depth"
         kmax=40-1
        xyskp=3
        uvskp=5
  end if

  if(model .eq. "cfsrv2")then
      rtsrc="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/mom_data/mx050/"
     runnam="CFSv2 20150401 (source: ocnanl.gdas.2015040100.tar=>ocean_temp_salt.res.nc, ocean_velocity.res.nc)"
   t_ocnsrc="cfsv2_TSUV_init"
   s_ocnsrc="cfsv2_TSUV_init"
   u_ocnsrc="cfsv2_TSUV_init"
   v_ocnsrc="cfsv2_TSUV_init"

        tname="temp"
        sname="salt"
        uname="u"
        vname="v"
       rotate="no"
   ocnlonname="plon"
   ocnlatname="plat"
   zcoordname="zt"
         kmax=40-1
        xyskp=1
        uvskp=1
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
  if(model .ne. "mom6_IC")then
   u_ocnfile=addfile(rtsrc+u_ocnsrc+".nc","r")
   v_ocnfile=addfile(rtsrc+v_ocnsrc+".nc","r")
  end if
;************************************************
; load an ocn field
;************************************************

  lstep=1-1
  if(batch .eq. "no")then
   ;  zlevel to plot
   ;zlevel = 50.0
   zlevel = 100.0
   ;zlevel = 250.0
   ;zlevel = 500.0
   ;zlevel = 1000.0
  end if

  ; ocean depths
      odepth=t_ocnfile->$zcoordname$
  ; find the k index closest to the zlevel depth
       kstep=closest_val(zlevel,odepth)
       depth=odepth(kstep)

        tvar=t_ocnfile->$tname$(lstep,kstep,::xyskp,::xyskp)
        svar=s_ocnfile->$sname$(lstep,kstep,::xyskp,::xyskp)
      if(model .ne. "mom6_IC")then
        uvar=u_ocnfile->$uname$(lstep,kstep,::uvskp,::uvskp)
        vvar=v_ocnfile->$vname$(lstep,kstep,::uvskp,::uvskp)

        psm = 0.50 
        ;qsm = -0.25  ;light
        qsm =  0.25  ;heavy
        ;qsm =  0.00  ;5pt
        usm = smth9_Wrap(uvar, psm, qsm, False) ; light local smooth
        vsm = smth9_Wrap(vvar, psm, qsm, False)
      ;uvar = usm
      ;vvar = vsm
      end if

  if(model .eq. "m5c5" .or. model .eq. "mom6_IC")then
    tvar@lon=t_ocnfile->$ocnlonname$(::xyskp)
    tvar@lat=t_ocnfile->$ocnlatname$(::xyskp)
    svar@lon=s_ocnfile->$ocnlonname$(::xyskp)
    svar@lat=s_ocnfile->$ocnlatname$(::xyskp)
  ; already on rectilinear grid
       tvar_regrid = tvar
       svar_regrid = svar
   tvar_regrid@lon = tvar@lon
   tvar_regrid@lat = tvar@lat
   svar_regrid@lon = svar@lon
   svar_regrid@lat = svar@lat

   if(model .ne. "mom6_IC")then
    uvar@lon=u_ocnfile->$ocnlonname$(::xyskp)
    uvar@lat=u_ocnfile->$ocnlatname$(::xyskp)
    vvar@lon=v_ocnfile->$ocnlonname$(::xyskp)
    vvar@lat=v_ocnfile->$ocnlatname$(::xyskp)
  ; already on rectilinear grid
        uvar_regrid = uvar
        vvar_regrid = vvar
    uvar_regrid@lon = uvar@lon
    uvar_regrid@lat = uvar@lat
    vvar_regrid@lon = vvar@lon
    vvar_regrid@lat = vvar@lat
   end if
  ; reassign tlon,tlat
              tlon := tvar@lon
              tlat := tvar@lat
  else
   tvar@lon2d=t_ocnfile->$ocnlonname$(::xyskp,::xyskp)
   tvar@lat2d=t_ocnfile->$ocnlatname$(::xyskp,::xyskp)
   svar@lon2d=s_ocnfile->$ocnlonname$(::xyskp,::xyskp)
   svar@lat2d=s_ocnfile->$ocnlatname$(::xyskp,::xyskp)
   uvar@lon2d=u_ocnfile->$ocnlonname$(::uvskp,::uvskp)
   uvar@lat2d=u_ocnfile->$ocnlatname$(::uvskp,::uvskp)
   vvar@lon2d=v_ocnfile->$ocnlonname$(::uvskp,::uvskp)
   vvar@lat2d=v_ocnfile->$ocnlatname$(::uvskp,::uvskp)

   if(regridded .eq. "yes")then
       tvar_regrid = ESMF_regrid_with_weights(tvar, wgts, True)
       svar_regrid = ESMF_regrid_with_weights(svar, wgts, True)
       uvar_regrid = ESMF_regrid_with_weights(uvar, wgts, True)
       vvar_regrid = ESMF_regrid_with_weights(vvar, wgts, True)
   tvar_regrid@lon = tlon
   tvar_regrid@lat = tlat
   svar_regrid@lon = tlon
   svar_regrid@lat = tlat
   uvar_regrid@lon = tlon
   uvar_regrid@lat = tlat
   vvar_regrid@lon = tlon
   vvar_regrid@lat = tlat
   ;printVarSummary(tvar_regrid)
   end if
  end if

  ;plottitle=rtsrc+t_ocnsrc+",  z="+depth
  plottitle=rtsrc+t_ocnsrc
  wkstitle=model+"_zuv"+zlevel

   tvar@units=""
   tvar@long_name=""
   svar@units=""
   svar@long_name=""
  if(model .ne. "mom6_IC")then
   uvar@units=""
   uvar@long_name=""
   vvar@units=""
   vvar@long_name=""
  end if

;************************************************
; set appropriate levels
;************************************************

  if(region .eq. "polar")then
   ; pick the values appropriate for this depth
   klev=closest_val(zlevel,tlevs_polar(:,0))
   tlevs=tlevs_polar(klev,1:3)
   slevs=slevs_polar(klev,1:3)
    vmag=vecvals(klev,1)
    vthn=vecvals(klev,2)
  end if
  ;vmag = 0.75*vmag
  ;vmag = 0.65*vmag

  print("found contour intervals at klev = "+klev+" for depth "+zlevel)
  ;print(tlevs)
  ;print(slevs)

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  if(model .eq. "m6c5" .or. model .eq. "m5c5")then
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

  ; a xsection to use
  ;xlon1=195.00
  ;xlon2= 15.00

  ;xlon1=170.00
  ;xlon2= 10.00

  xlon1=140.00
  xlon2=345.00

  xlat1= 66.00
  xlat2= 66.00

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  ;wkstype@wkWidth=800
  ;wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)             
  
  ;drawNDCGrid(wks)

  plot = new(2,graphic)
   dum = new(2,graphic)
   xum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = True
  res@cnFillMode           = "MeshFill"

  res@gsnScalarContour  = True              ; vectors over scalars
  res@cnFillOn          = True              ; color fill
  res@cnLinesOn         = False             ; no contour lines

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar     = "NH"                   ; specify the hemisphere
  res@mpMinLatF    =  66                    ; minimum lat to plot
  res@mpCenterLonF = -45
  res@mpGreatCircleLinesOn = True

  ;res@cnFillPalette   =  "cmp_b2r"                         ; choose colormap
  ;res@cnFillPalette   =  "NCV_blu_red"                     ; choose colormap
  res@cnFillPalette   =  "MPL_rainbow"                      ; choose colormap

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcRefLengthF          = 0.1              ; size of ref vector
  res@vcGlyphStyle          = "CurlyVector"

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

  xres                   = True          ; polyline mods desired
  xres@gsLineThicknessF  = 4.0           ; line thickness
  xres@gsLineColor       = "blue"        ; color of lines
  xres@gsLineDashPattern =  2            ; short dashes

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
   end if

   if(scalarfield .eq. "salinity")then
    if(regridded .eq. "yes")then
     pltvar=svar_regrid
    else
     pltvar=svar
    end if
     pltlev=slevs
   end if

   ;res@gsnCenterString = " z="+sprintf("%5.0f", depth)+"m"
   ;res@gsnCenterStringFontHeightF = 0.016
   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   res@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   res@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   res@cnLevelSpacingF = pltlev(2)                      ; set the interval between contours

  if(model .ne. "mom6_IC")then 
   plot(ii) = gsn_csm_vector_scalar_map_polar(wks,uvar,vvar,pltvar,res)    ; create the plot
  else 
   plot(ii) = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   ; xum(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres)
   return(plot(ii))
end
;************************************************
;
;************************************************

  ii = 0
  plot(ii) = subplot(ii,"temperature")    ; create the plot
 ; ii = 1
 ; plot(ii) = subplot(ii,   "salinity")    ; create the plot

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.008                     ; font smaller. default big

  xx = 0.5
  yy = 0.18
; page coordinates are normalized. go from 0->1 not 0->8" etc.
  ; gsn_text_ndc(wks,rtsrc+t_ocnsrc,xx,yy,txres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
  
  ;resP@gsnPanelMainString  = runnam
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

 ; resP@txFontHeightF = .012
 ; resP@txString = plottitle
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

  if(batch .eq. "yes")then
   imcmd = "convert "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if


exit
end
