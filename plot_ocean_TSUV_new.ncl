;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "regionTS.ncl"
  load "unstaggerMOM6.ncl"

;************************************************
begin
 ; print(model)
 ; print(zlevel)

  ;default
  symmetric = "false"

 ;batch = "yes"
 batch = "no"

 ; add back codes for other models!
 if(batch .eq. "no")then
  model="m6c5fv3"
 end if

;************************************************
; set up for depth dependent contour levels
;************************************************

  region = "NPole"
  ;region = "GIN"
  ;region = "NAtl"
  ;region = "SPole"


;************************************************
; region resources
;************************************************

 if(region .eq. "NPole")then
    hemi = "NH"
  minlat =  76.0
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
 end if
 if(region .eq. "SPole")then
    hemi = "SH"
  maxlat = -50.0
  cenlon = -45.0
 end if

;************************************************
; ocean variables 
;************************************************
  ;default
      rotate = "no"
     rfactor = 1.0

  if(model .eq. "m6c5fv3")then
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Bin.Li/post400/rtgen.11643/tmp/ocn/"
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/nofixfrzmlt_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
      ;runnam="No FixFreezeMelt ; MOM6-CICE5-FV3 35-day spinup"
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d_newrot_A/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
      ;runnam="FixFreezeMelt using MLD; MOM6-CICE5-FV3 35-day spinup"
      ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.10294/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
      rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.86606/tmp/cpld_fv3_384_mom6_cice_30d_atm_flux/"
      ;rtsrc="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/Benchmark_set1/20160501/COMFV3/c384/gfs.20160501/00/OCN/"
   cday="2011_09_13"  
   t_ocnsrc="ocn_"+cday+"_21.nc"
   s_ocnsrc="ocn_"+cday+"_21.nc"
   u_ocnsrc="ocn_"+cday+"_21.nc"
   v_ocnsrc="ocn_"+cday+"_21.nc"
   ;cday="2016060500"  
   ;t_ocnsrc="ocn"+cday+".01.2016050100"
   ;s_ocnsrc="ocn"+cday+".01.2016050100"
   ;u_ocnsrc="ocn"+cday+".01.2016050100"
   ;v_ocnsrc="ocn"+cday+".01.2016050100"

        tname="temp"
        sname="so"
        uname="uo"
        vname="vo"
   tlonname="geolon"
   tlatname="geolat"
   ulatname="geolat_u"
   ulonname="geolon_u"
   vlatname="geolat_v"
   vlonname="geolon_v"
   zcoordname="z_i"
         kmax=40-1
       rotate="yes"
   ; rad 2 degree
      rfactor=180.0/acos(-1.0)
  end if

  t_ocnfile=addfile(rtsrc+t_ocnsrc+".nc","r")
  s_ocnfile=addfile(rtsrc+s_ocnsrc+".nc","r")
  u_ocnfile=addfile(rtsrc+u_ocnsrc+".nc","r")
  v_ocnfile=addfile(rtsrc+v_ocnsrc+".nc","r")

   print(rtsrc+t_ocnsrc)
;************************************************
; load an ocn field
;************************************************

  lstep=1-1
  if(batch .eq. "no")then
   ;  zlevel to plot
   ;zlevel = 0.0
   ;zlevel = 50.0
   ;zlevel = 100.0
   zlevel = 250.0
   ;zlevel = 500.0
   ;zlevel = 1000.0
  end if

  ; ocean depths
      odepth=t_ocnfile->$zcoordname$
  ; find the k index closest to the zlevel depth
       kstep=closest_val(zlevel,odepth)
       depth=odepth(kstep)

        tvar=t_ocnfile->$tname$(lstep,kstep,:,:)
        svar=s_ocnfile->$sname$(lstep,kstep,:,:)
        uvar=u_ocnfile->$uname$(lstep,kstep,:,:)
        vvar=v_ocnfile->$vname$(lstep,kstep,:,:)

     cosrot=t_ocnfile->cos_rot 
     sinrot=t_ocnfile->sin_rot 
   
      ; dim(0) =>j; dim(1) =>i   
      tdims = dimsizes(tvar)
      udims = dimsizes(uvar)
      vdims = dimsizes(vvar)
      print(tdims(0)+" "+tdims(1))
      print(udims(0)+" "+udims(1))
      print(vdims(0)+" "+vdims(1))

      if(model .eq. "m6c5fv3")then
       uvar = where(ismissing(uvar),0.0,uvar)
       vvar = where(ismissing(vvar),0.0,vvar)
       print("uvar min = "+min(uvar)+" uvar max = "+max(uvar))
       print("vvar min = "+min(vvar)+" vvar max = "+max(vvar))
       ut = unstaggerMOM6(uvar,"U",symmetric)
       vt = unstaggerMOM6(vvar,"V",symmetric)
      else 
       ut = uvar
       vt = vvar
      end if 
       tt = tvar
       st = svar

   tt@lon2d=t_ocnfile->$tlonname$
   tt@lat2d=t_ocnfile->$tlatname$
   st@lon2d=s_ocnfile->$tlonname$
   st@lat2d=s_ocnfile->$tlatname$
   ut@lon2d=t_ocnfile->$tlonname$
   ut@lat2d=t_ocnfile->$tlatname$
   vt@lon2d=t_ocnfile->$tlonname$
   vt@lat2d=t_ocnfile->$tlatname$
   if(model .eq. "m6c5fv3")then
    tt@lon2d = mod(tt@lon2d+720.0,360.0)
    st@lon2d = mod(st@lon2d+720.0,360.0)
    ut@lon2d = mod(tt@lon2d+720.0,360.0)
    vt@lon2d = mod(tt@lon2d+720.0,360.0)
   else
    ut@lon2d=u_ocnfile->$ulonname$
    ut@lat2d=u_ocnfile->$ulatname$
    vt@lon2d=v_ocnfile->$vlonname$
    vt@lat2d=v_ocnfile->$vlatname$
   end if

    if(rotate .eq. "yes")then
;************************************************
;
;************************************************

      print("doing vector rotation to EW")
      urot = ut
      vrot = vt

      urot = tofloat( ut*cosrot + vt*sinrot)
      vrot = tofloat( vt*cosrot - ut*sinrot)
   
      ut = urot
      vt = vrot
      tt = tvar
      st = svar

      ut = where(ut@lat2d .ge. minlat, ut, urot@_FillValue)
      vt = where(vt@lat2d .ge. minlat, vt, vrot@_FillValue)
    end if
     
        ;psm = 0.50 
        ;qsm = -0.25  ;light
        ;qsm =  0.25  ;heavy
        ;qsm =  0.00  ;5pt
        ;usm = smth9_Wrap(uvar, psm, qsm, False) ; light local smooth
        ;vsm = smth9_Wrap(vvar, psm, qsm, False)
      ;uvar = usm
      ;vvar = vsm

  ;plottitle=rtsrc+t_ocnsrc+",  z="+depth
  plottitle=rtsrc+t_ocnsrc
  wkstitle=model+"_zuv"+zlevel

   tt@units=""
   tt@long_name=""
   st@units=""
   st@long_name=""
   ut@units=""
   ut@long_name=""
   vt@units=""
   vt@long_name=""

;************************************************
; set appropriate levels
;************************************************

   ; pick the values appropriate for this region
   levels = regionTS(region,zlevel,False)
   ;print(levels)
   tlevs = levels(0,:)
   slevs = levels(1,:)
    vmag = levels(2,1)
    vthn = levels(2,2)
  print(vmag)
  print(vthn)

  ;print("found contour intervals at klev = "+klev+" for depth "+zlevel)
  ;print(tlevs)
  ;print(slevs)
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

  ; a xsection to mark
   ;xlon1=195.00
   ;xlon2= 15.00

   ;xlon1=170.00
   ;xlon2= 10.00

   xlon1=140.00
   xlon2=345.00

   xlat1= 66.00
   xlat2= 66.00
  end if

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="png"
  ;wkstype@wkWidth=1200
  ;wkstype@wkHeight=1200
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)             
  
  ;drawNDCGrid(wks)

  plot = new(2,graphic)
 oplot = new(2,graphic)
   dum = new(2,graphic)
   xum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = True
  res@cnFillMode           = "MeshFill"
 
  if(model .eq. "m6c5fv3")then
   res@gsnAddCyclic     = False
  end if
  res@gsnScalarContour  = True              ; vectors over scalars
  res@cnFillOn          = True              ; color fill
  res@cnLinesOn         = False             ; no contour lines

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

;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10               ; size of ref vector
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
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
     pltvar=tt
     pltlev=tlevs
     ores@cnLevels = (/1.8/)
   end if

   if(scalarfield .eq. "salinity")then
     pltvar=st
     pltlev=slevs
     ores@cnLevels = (/34.98/)
   end if

   ;res@gsnCenterString = " z="+sprintf("%5.0f", depth)+"m"
   ;res@gsnCenterStringFontHeightF = 0.016
   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   res@cnMinLevelValF  = pltlev(0)                      ; set the minimum contour level
   res@cnMaxLevelValF  = pltlev(1)                      ; set the maximum contour level
   res@cnLevelSpacingF = pltlev(2)                      ; set the interval between contours

  if(region .eq. "NPole" .or. region .eq. "SPole")then
   plot(ii) = gsn_csm_vector_scalar_map_polar(wks,ut,vt,pltvar,res)    ; create the plot
  oplot(ii) = gsn_csm_contour(wks,pltvar,ores)             ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
    ;xum(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres)
    overlay(plot(ii),oplot(ii))
  else
   plot(ii) = gsn_csm_vector_scalar_map(wks,ut,vt,pltvar,res)    ; create the plot
    ;xum(ii) = gsn_add_polyline(wks,plot(ii),(/xlon1, xlon2/) , (/xlat1, xlat2/) ,xres)
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
