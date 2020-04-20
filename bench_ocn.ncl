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
 end if
 if(region .eq. "SPole")then
    hemi = "SH"
  maxlat = -50.0
  cenlon = -45.0
 end if

 ;dirname = "/scratch4/NCEPDEV/nems/noscrub/Bin.Li/Benchmark_set1/20160501/COMFV3/c384/gfs.20160501/00/OCN/"
 dirname = "/scratch4/NCEPDEV/ocean/save/Bhavani.Rajan/MOM6/MOM_out/"

;************************************************
; make a list of the files from the run
; this will 'catch' the initial condition file
; until Bin rewrites the workflow to give the 
; initial condition file a more unique name
;************************************************

   print(hemi)
   print(dirname)

   ocnfilelist = systemfunc("ls "+dirname+"ocn*.nc")
          ocnf = addfiles(ocnfilelist,"r")
        ntimes = dimsizes(ocnfilelist)
    print("ntimes = "+ntimes)
    ;print(ocnfilelist)
 
      tname = "temp"
      sname = "so"
      uname = "uo"
      vname = "vo"
   tlonname = "geolon"
   tlatname = "geolat"
   ulatname = "geolat_u"
   ulonname = "geolon_u"
   vlatname = "geolat_v"
   vlonname = "geolon_v"
   zcoordname = "z_i"
         kmax = 40-1
       rotate = "yes"
   ; rad 2 degree
      rfactor = 180.0/acos(-1.0)

;************************************************
;
;************************************************

  if(batch .eq. "no")then
   ;  zlevel to plot
   zlevel = 0.0
   ;zlevel = 50.0
   ;zlevel = 100.0
   ;zlevel = 250.0
   ;zlevel = 500.0
   ;zlevel = 1000.0
  end if

  ; use the first file to retrieve grid variables
  ; ocean depths
      odepth = ocnf[0]->$zcoordname$
  ; find the k index closest to the zlevel depth
       kstep = closest_val(zlevel,odepth)
       depth = odepth(kstep)
      cosrot = ocnf[0]->cosrot 
      sinrot = ocnf[0]->sinrot 
 
  ; load the variables, avg over 35 d
       tvar = dim_avg_n_Wrap(ocnf[:]->$tname$(:,kstep,:,:),0)
       svar = dim_avg_n_Wrap(ocnf[:]->$sname$(:,kstep,:,:),0)
       uvar = dim_avg_n_Wrap(ocnf[:]->$uname$(:,kstep,:,:),0)
       vvar = dim_avg_n_Wrap(ocnf[:]->$vname$(:,kstep,:,:),0)
  
      ; dim(0) =>j; dim(1) =>i   
      tdims = dimsizes(tvar)
      udims = dimsizes(uvar)
      vdims = dimsizes(vvar)
      print(tdims(0)+" "+tdims(1))
      print(udims(0)+" "+udims(1))
      print(vdims(0)+" "+vdims(1))

       uvar = where(ismissing(uvar),0.0,uvar)
       vvar = where(ismissing(vvar),0.0,vvar)
       print("uvar min = "+min(uvar)+" uvar max = "+max(uvar))
       print("vvar min = "+min(vvar)+" vvar max = "+max(vvar))
       ut = unstaggerMOM6(uvar,"U",symmetric)
       vt = unstaggerMOM6(vvar,"V",symmetric)
       tt = tvar
       st = svar

   tt@lon2d = ocnf[0]->$tlonname$
   tt@lat2d = ocnf[0]->$tlatname$
   st@lon2d = ocnf[0]->$tlonname$
   st@lat2d = ocnf[0]->$tlatname$
   ut@lon2d = ocnf[0]->$tlonname$
   ut@lat2d = ocnf[0]->$tlatname$
   vt@lon2d = ocnf[0]->$tlonname$
   vt@lat2d = ocnf[0]->$tlatname$

   tt@lon2d = mod(tt@lon2d+720.0,360.0)
   st@lon2d = mod(st@lon2d+720.0,360.0)
   ut@lon2d = mod(tt@lon2d+720.0,360.0)
   vt@lon2d = mod(tt@lon2d+720.0,360.0)

;************************************************
;
;************************************************

   urot = ut
   vrot = vt

    urot = tofloat( ut*cosrot + vt*sinrot)
    vrot = tofloat( vt*cosrot - ut*sinrot)
      ut = urot
      vt = vrot
      ut = where(ut@lat2d .ge. minlat, ut, urot@_FillValue)
      vt = where(vt@lat2d .ge. minlat, vt, vrot@_FillValue)
     
        ;psm = 0.50 
        ;qsm = -0.25  ;light
        ;qsm =  0.25  ;heavy
        ;qsm =  0.00  ;5pt
        ;usm = smth9_Wrap(uvar, psm, qsm, False) ; light local smooth
        ;vsm = smth9_Wrap(vvar, psm, qsm, False)
      ;uvar = usm
      ;vvar = vsm

  plottitle="test"
  wkstitle="test"

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

  ; print(vmag)
  ; print(vthn)
  ;print(tlevs)
  ;print(slevs)
;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

    lon1=  60.00
    lon2=-120.00
    lat1=  60.00
    lat2=  60.00

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  ;wkstype@wkWidth=800
  ;wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)             
  
  ;drawNDCGrid(wks)

  plot = new(2,graphic)
 oplot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = True
  res@cnFillMode           = "MeshFill"
 
  res@gsnScalarContour   = True              ; vectors over scalars
  res@cnFillOn           = True              ; color fill
  res@cnLinesOn          = False             ; no contour lines
  res@cnLineLabelsOn     = False             ; no contour lines

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
   res@mpMaxLatF    = maxlat
   res@mpCenterLonF = 0.0
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
  end if
  end if

  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF = 0.020           ; change font height of labels
  res@gsnStringFontHeightF     = 0.025
  res@lbLabelFontHeightF       = 0.020

  res@cnFillPalette   =  "MPL_rainbow"                      ; choose colormap

;Vectors whose magnitude is equal to the reference magnitude are drawn at the reference length. 
;By default, the reference magnitude is the maximum magnitude in the vectorfield, but it may be set to any arbitrary value. 
;The default reference length is determined dynamically based on the viewport and the number of elements along 
;each data dimension. Note that the length of each vector arrow increases as you increase the reference length 
;but decreases as you increase the reference magnitude.

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.02               ; size of ref vector
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
   ;plot(ii) = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  ;oplot(ii) = gsn_csm_contour(wks,pltvar,ores)             ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   ; overlay(plot(ii),oplot(ii))
  else
   plot(ii) = gsn_csm_vector_scalar_map(wks,ut,vt,pltvar,res)    ; create the plot
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
;
;************************************************

  resP                     = True                ; modify the panel plot
  
  ;resP@gsnPanelMainString  = runnam
  ;resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

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
