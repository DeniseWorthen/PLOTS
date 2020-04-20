;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "unstaggerCICE5.ncl"
  load "levscmapCICE.ncl"
;************************************************
begin
  batch="no"
 ; batch="yes"

  minlat = 76.0

 if(batch .eq. "no")then
  initdate="20160701"
     ndays=35
  itime = cd_inv_string(initdate,"%Y%N%D")
  ;print(itime)
  ; in hours
  etime = itime+35*24
  copy_VarMeta(itime,etime)
  enddate = cd_calendar(etime,-2)
  ;print(enddate)

  syear="2016"
   smon="07"
   sday="02"
  sdate=syear+smon+sday

  eyear="2016"
   emon="07"
   eday="27"
  edate=eyear+emon+eday
 end if

  Dates2Plt = (/sdate, edate/)
  ndates=dimsizes(Dates2Plt)

   vmag = 0.40
   vthn = 0.018

  ; requires U grid right now!!!
  ;usegrid = "T"
  usegrid = "U"

   rad2deg=180.d0/acos(-1.0d0)

;************************************************
; read in netCDF file
;************************************************


  hemi="NH"
  ;hemi="SH"
   rtsrc="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_test/"
   dirsrc=rtsrc+initdate+"/COMFV3/c384_test/gfs."+initdate+"/00/ICE/"
   ; use one file for grid
   icfile="iceic"+initdate+"00.01."+initdate+"00.nc"
   gf =addfile(dirsrc+icfile,"r")

   ;print(gf)
  tarea = gf->tarea
  uarea = gf->uarea
  ; in radians, on t-grid
  if(usegrid .eq. "U")then
   rotang = gf->ANGLE
  else
   rotang = gf->ANGLET
  end if

     aicename = "aice"
       hiname = "hi"
      albname = "albsni"
  topmeltname = "meltt"
  botmeltname = "meltb"
  ; apnd*ai or apnd*alvl*ai ==> ponded ice fraction
   fpondname = "apond"
  ; hpnd*apnd or hpnd*apnd*alvl ==> ponded depth on sea ice (use _ai for ponded depth over grid cell)
  ; hpondname = "hpond"
   hpondname = "hpond"
     socnname = "sss"
     tocnname = "sst"
   frzmltname = "frzmlt"
     uicename = "uvel"
     vicename = "vvel"

   iceulonname="ULON"
   iceulatname="ULAT"
   icetlonname="TLON"
   icetlatname="TLAT"

   rfactor=1.0

  icefilelist = dirsrc+"ice"+Dates2Plt+"00.01."+initdate+"00.nc"
     icefiles = addfiles(icefilelist,"r")
   
;************************************************
; ice
;************************************************

  if(batch .eq. "no")then
   varname= aicename
   ;varname = hiname
   ;varname = albname
   ;varname = topmeltname
   ;varname = botmeltname
   ;varname = fpondname
   ;varname = hpondname
   ;varname = tocnname
   ;varname = socnname
   ;varname = frzmltname
  end if

  ; array contour levels for variables
      pltlevs = new((/3/),float)
      freturn = levscmapCICE(varname)
   pltlevs(:) = freturn[0]
   colormap   = freturn[1]

    varname = varname+"_h"
   uicename = uicename+"_h"
   vicename = vicename+"_h"

  avar = icefiles[:]->$varname$(:,:,:)
  uvar = icefiles[:]->$uicename$(:,:,:)
  vvar = icefiles[:]->$vicename$(:,:,:)

  avar@lon2d = gf->$icetlonname$*rfactor
  avar@lat2d = gf->$icetlatname$*rfactor
  uvar@lon2d = gf->$iceulonname$*rfactor
  uvar@lat2d = gf->$iceulatname$*rfactor
  vvar@lon2d = gf->$iceulonname$*rfactor
  vvar@lat2d = gf->$iceulatname$*rfactor

  ; copy metadata
   urot = uvar
   vrot = vvar
  do kk = 0,ndates-1
   urot(kk,:,:) = cos(rotang)*uvar(kk,:,:) - sin(rotang)*vvar(kk,:,:)
   vrot(kk,:,:) = sin(rotang)*uvar(kk,:,:) + cos(rotang)*vvar(kk,:,:)
  end do
  do kk = 0,ndates-1
   urot(kk,:,:) = where(uvar@lat2d .ge. minlat, urot(kk,:,:), uvar@_FillValue)
   vrot(kk,:,:) = where(vvar@lat2d .ge. minlat, vrot(kk,:,:), vvar@_FillValue)
  end do

  ;printVarSummary(urot)

  print("urot min = "+min(urot)+" urot max = "+max(urot))
  print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))

   labelstring = avar@long_name+" ("+avar@units+")  "+"["+varname+"]"

  avar@units = ""
  avar@long_name = ""

  plotname = ""
  runname = initdate
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
  end if

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
   wkstype="X11"
   ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ; a max of ndates panels, not all used
  npanels = ndates
 ; for panels
 if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else
    ;ncols = 4
    ;nrows = 1+npanels/ncols
    ncols = 2
    nrows = 2
 end if

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@cnFillMode           = "MeshFill"
  ;res@cnFillMode           = "RasterFill"
  res@mpFillOn             = True

  res@gsnScalarContour   = True              ; vectors over scalars
  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  if(varname .eq. "aice_h" .or. varname .eq. "aice")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(varname .eq. "hi_h" .or. varname .eq. "hi")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  end if
  end if
  res@cnFillPalette   = colormap             ; choose colormap

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10              ; size of ref vector
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcGlyphStyle          = "CurlyVector"
  res@vcLineArrowThicknessF = 1.5
  ;res@vcRefAnnoOrthogonalPosF   = -0.33           ; move ref vector
  res@vcRefAnnoParallelPosF     = 1.0             ; move ref vector over
  res@vcRefAnnoFontHeightF      = 0.02

  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  ;res@gsnCenterStringOrthogonalPosF = .15          ; raise the CenterString slightly
  res@gsnCenterStringFontHeightF = 0.040

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
; resources for polymarkers
;************************************************

  mkres               = True
  ;mkres@gsMarkerIndex = 16         ; circle
  mkres@gsMarkerIndex = 15         ; open circle+cross
  ;mkres@gsMarkerIndex = 2         ; cross hair
  mkres@gsMarkerSizeF = 0.020
  mkres@gsMarkerColor = "Red"

;************************************************
;
;************************************************

  do ii = 0,ndates-1
    res@gsnCenterString = Dates2Plt(ii)
;---Only turn on vector reference box for the lower rightmost plot.
    if(ii .eq. ndates-1) then
      res@vcRefAnnoOn = True
    else
      res@vcRefAnnoOn = False
    end if

  plot(ii) = gsn_csm_vector_scalar_map_polar(wks,urot(ii,:,:),vrot(ii,:,:),avar(ii,:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@gsnPanelMainString  = plotname+" "+labelstring
  resP@gsnPanelMainFontHeightF = 0.015            ; new resource added in NCL V6.4.0

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot
;************************************************
;
;************************************************

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
