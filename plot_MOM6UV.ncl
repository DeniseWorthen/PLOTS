;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

  load "unstaggerMOM6.ncl"
;************************************************
begin

  ;default
  symmetric = "false"

        mean="yes"
  plotstress="yes"
  print("mean = "+mean+" stresses = "+plotstress)

  ;minlat = 89.0
  minlat = 70.0
  ;minlat = 88.0

   ;minlat = 66.0
   ;vmag = 0.05
   vmag = 0.10
   vthn = 0.012

;************************************************
; read in netCDF file
;************************************************

   RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
   RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
   RT3 = "/scratch3/NCEPDEV/stmp3/Denise.Worthen/"
   RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

   ;runname = "FV3M6C5 prepforbench"
   ;rtsrc =  rt2+"frzmlt_35d_july_bubbly_dp1/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
   ;plotname = "FV3-MOM6-CICE5"

  runtyp="emc"
  ;runtyp="moa"

  ;runname = runtyp+"_05day_dump_alloff"
  runname = runtyp+"_1d_uvatm_only"
  rtsrc=RT4+runname+"/tmp/cpld_datm_mom6_cice_5d/"
  plotname = runtyp

;************************************************
;
;************************************************

  varname = "SST"
  ;varname = "temp"
 if(plotstress .eq. "yes")then
  uocnname = "taux"
  vocnname = "tauy"
 else
  uocnname = "SSU"
  vocnname = "SSV"
  ;uocnname = "uo"
  ;vocnname = "vo"
 end if
  ;kstep = 25-1

  if(mean .eq. "no")then
   lstep = 1-1
   cyear = 2013
    cday = cyear+"_07_02_09"
   ;print("day = "+cday)
   ocnfilelist = (rtsrc+"ocn_"+cday+".nc")
   ;print(ocnfilelist)
          ocnf = addfiles(ocnfilelist,"r")
   avar = ocnf[0]->$varname$(lstep,:,:)
   uvar = ocnf[0]->$uocnname$(lstep,:,:)
   vvar = ocnf[0]->$vocnname$(lstep,:,:)
   ;avar = ocnf[0]->$varname$(lstep,kstep,:,:)
   ;uvar = ocnf[0]->$uocnname$(lstep,kstep,:,:)
   ;vvar = ocnf[0]->$vocnname$(lstep,kstep,:,:)
  else
   ocnfilelist = systemfunc("ls "+rtsrc+"ocn_*.nc")
   print("averaging over "+dimsizes(ocnfilelist)+" files")
          ocnf = addfiles(ocnfilelist,"r")
   avar = dim_avg_n_Wrap(ocnf[:]->$varname$(:,:,:),0)
   uvar = dim_avg_n_Wrap(ocnf[:]->$uocnname$(:,:,:),0)
   vvar = dim_avg_n_Wrap(ocnf[:]->$vocnname$(:,:,:),0)
   ;avar = dim_avg_n_Wrap(ocnf[:]->$varname$(:,kstep,:,:),0)
   ;uvar = dim_avg_n_Wrap(ocnf[:]->$uocnname$(:,kstep,:,:),0)
   ;vvar = dim_avg_n_Wrap(ocnf[:]->$vocnname$(:,kstep,:,:),0)
  end if

       cosrot = ocnf[0]->cos_rot
       sinrot = ocnf[0]->sin_rot
   avar@lon2d = ocnf[0]->geolon
   avar@lat2d = ocnf[0]->geolat
 
   uvar = where(ismissing(uvar),0.0,uvar)
   vvar = where(ismissing(vvar),0.0,vvar)
     ut = unstaggerMOM6(uvar,"U",symmetric)
     vt = unstaggerMOM6(vvar,"V",symmetric)

   ut@lon2d = ocnf[0]->geolon
   ut@lat2d = ocnf[0]->geolat
   vt@lon2d = ocnf[0]->geolon
   vt@lat2d = ocnf[0]->geolat

  ;plottitle=rtsrc+"~C~"+field+uname+"  "+ field+vname
  plottitle=rtsrc+"  "+uocnname+", "+vocnname

  ;levs = (/-0.08,0.08,.005/)
  ;levs = (/0.0, 1.0, 0.1/)
  levs = (/-1.8, 2.2, 0.1/)
  ;levs = (/-1.55, -1.45, 0.002/)
  ;levs = (/-0.20, 3.00, 0.050/)
  ;levs = (/-1.6,1.6,.1/)

;************************************************
;
;************************************************
   
   ; copy metadata
   urot = ut
   vrot = vt
   ; as in cap, original code
   ;urot = ut*cosrot - vt*sinrot
   ;vrot = vt*cosrot + ut*sinrot
   ; as in cap, SIS2 code
   urot = ut*cosrot + vt*sinrot
   vrot = vt*cosrot - ut*sinrot
   urot = where(urot@lat2d .ge. minlat, urot, uvar@_FillValue)
   vrot = where(vrot@lat2d .ge. minlat, vrot, vvar@_FillValue)
   print("urot min = "+min(urot)+" urot max = "+max(urot))
   print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))

  avar@long_name = ""
  ;urot@long_name = ""
  ;vrot@long_name = ""
  avar@units = ""
  ;urot@units = ""
  ;vrot@units = ""
;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=  60.00
  lon2=-120.00
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"polar")              ; send graphics to X11 window

  plot = new(3,graphic)
   dum = new(3,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn   = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"

  res@gsnScalarContour   = True              ; vectors over scalars
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.015

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF    =  minlat                     ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette               = "WhBlGrYeRe"             ; choose colormap

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcRefLengthF          = 0.10              ; size of ref vector
  res@vcGlyphStyle          = "CurlyVector"
  ;res@vcPositionMode = "ArrowTail"

  ;res@tiMainString = plottitle
  ;res@tiMainFontHeightF = .010

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
;
;************************************************

 ; ii = 0
 ;  plot(ii) = gsn_csm_contour_map_polar(wks,tvar,res)    ; create the plot
 ;  plot(ii) = gsn_csm_contour_map_polar(wks,urot,res)    ; create the plot
 ;   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

 ; ii = 1
  ; plot(ii) = gsn_csm_contour_map_polar(wks,vvar,res)    ; create the plot
  ; plot(ii) = gsn_csm_contour_map_polar(wks,vrot,res)    ; create the plot
  ;  dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

 ;  ii = 2
   ii = 0
  ;levs = (/-1.72, -1.63, 0.002/)
  ;levs = (/-1.40, -1.30, 0.002/)
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

   plot(ii) = gsn_csm_vector_scalar_map_polar(wks,urot,vrot,avar,res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot

  resP@gsnPanelMainString  = plottitle
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

  ;gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot
  ;gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

exit
end
