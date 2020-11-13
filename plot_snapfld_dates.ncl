;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "unstaggerCICE5.ncl"
  load "levscmapCICE.ncl"

;************************************************
 ;batch = "yes"
 batch = "no"

  hemi = "NH"
  ;hemi = "SH"

       model = "m6cice5"
  addvectors = "no"
     usegrid = "T"
    ;usegrid = "U"

 ; minlat = 89.
 ;   vmag = 0.2
 ;   vthn = 0.0
 ; vectyp = "LineArrow"

  minlat = 66.
    vmag = 0.40
    vthn = 0.018
  vectyp = "CurlyVector"

   rad2deg=180.d0/acos(-1.0d0)

begin
;************************************************
;
;************************************************

   Year2Plt = "2012"

 ; Dates2Plt = (/"-10-04", "-10-14" \
 ;              ,"-10-24", "-11-07" \
 ;              /)
 ; Dates2Plt = (/"-07-02", "-07-04" \
 ;              ,"-07-06", "-07-08" \
 ;              /)
 ; Dates2Plt = (/"-07-01", "-07-18" \
 ;              /)
 ; Dates2Plt = (/"-07-18" \
 ;              /)

  ICDate=(/"-07-01"/)

   Dates2Plt=Year2Plt+Dates2Plt
   print(Dates2Plt)

   ndates = dimsizes(Dates2Plt)
 
;************************************************
; read in netCDF file
;************************************************

   rt1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
   rt2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
   rt3 = "/scratch3/NCEPDEV/stmp3/Denise.Worthen/"
   rt4 = "/scratch3/NCEPDEV/stmp4/Denise.Worthen/"
 
   ;rtsrc =  rt2+"frzmlt_35d_c384/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
  ; rtsrc =  rt2+"frzmlt_35d_july_blowup/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
  ; rtsrc =  rt2+"frzmlt_35d_jul_27d_dtmc/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"

   runname = "prepforbench"
   ;rtsrc =  rt2+"frzmlt_35d_jul_27d_dtmc/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
   ;rtsrc =  rt2+"frzmlt_c384_35d_july/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
   ;rtsrc =  rt2+"frzmlt_35d_july_bubbly_dp1/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
   rtsrc =  rt2+"rtgen.31531/tmp/cpld_datmC384_mom6_cice_30d/"
   plotname = "FV3-MOM6-CICE5"

   ; use ic file for grid
   gf = addfile(rtsrc+"history/iceh_ic."+Year2Plt+ICDate+"-00000.nc","r")

   icetlatname = "TLAT"
   icetlonname = "TLON"
   iceulonname = "ULON"
   iceulatname = "ULAT"
      rfactor = 1.0

  ;icefilelist = rtsrc+"history/iceh_06h."+Dates2Plt+"-21600.nc"
  icefilelist = rtsrc+"history/iceh_06h."+Dates2Plt+"-00000.nc"
     icefiles = addfiles(icefilelist,"r")

  if(model .eq. "hycice" .or. model .eq. "m6cice5")then
     aicename = "aice"
       hiname = "hi"
      albname = "albsni"
  topmeltname = "meltt"
  botmeltname = "meltb"
  ; apnd*ai or apnd*alvl*ai ==> ponded ice fraction
  ; fpondname = "apond_ai"
   fpondname = "apond"
  ; hpnd*apnd or hpnd*apnd*alvl ==> ponded depth on sea ice (use _ai for ponded depth over grid cell)
  ; hpondname = "hpond"
   hpondname = "hpond_ai"
     socnname = "sss"
     tocnname = "sst"
   frzmltname = "frzmlt"
   congelname = "congel"
   frazilname = "frazil"
     uicename = "uvel"
     vicename = "vvel"
  end if

;************************************************
; load an ice field
;************************************************

  if(batch .eq. "no")then
   varname= aicename
   ;varname = hiname
   ;varname = albname
   varname = topmeltname
   ;varname = botmeltname
   ;varname = fpondname
   ;varname = hpondname
   ;varname = tocnname
   ;varname = socnname
   ;varname = frzmltname
   ;varname = congelname
   ;varname = frazilname
  if(addvectors .eq. "yes")then
   uvarname = uicename
   vvarname = vicename
  end if
  end if
 
  ; array contour levels for variables
      pltlevs = new((/3/),float)
      freturn = levscmapCICE(varname,hemi)
   pltlevs(:) = freturn[0]
   colormap   = freturn[1]

       varname =  varname+"_h"
        icevar = icefiles[:]->$varname$(:,:,:)
  icevar@lon2d = gf->$icetlonname$*rfactor
  icevar@lat2d = gf->$icetlatname$*rfactor

  if(addvectors .eq. "yes")then
    uvarname = uvarname+"_h"
    vvarname = vvarname+"_h"
        uvar = icefiles[:]->$uvarname$(:,:,:)
        vvar = icefiles[:]->$vvarname$(:,:,:)
    uvar@lon2d = gf->$iceulonname$*rfactor
    uvar@lat2d = gf->$iceulatname$*rfactor
    vvar@lon2d = gf->$iceulonname$*rfactor
    vvar@lat2d = gf->$iceulatname$*rfactor
  end if

 if(addvectors .eq."yes")then
  tarea = gf->tarea
  uarea = gf->uarea
  copy_VarCoords(icevar(0,:,:),tarea)
  copy_VarCoords(  uvar(0,:,:),uarea)
  ; in radians, on t-grid
  if(usegrid .eq. "U")then
   rotang = gf->ANGLE
  else
   rotang = gf->ANGLET
  end if

  ; copy metadata
   ut = uvar
   vt = vvar
  if(usegrid .eq. "T")then
   print("unstaggering velocities ")
    uvar = where(ismissing(uvar),0.0,uvar)
    vvar = where(ismissing(vvar),0.0,vvar)
    print("uvar min = "+min(uvar)+" uvar max = "+max(uvar))
    print("vvar min = "+min(vvar)+" vvar max = "+max(vvar))
   ; unstagger
   do kk = 0,ndates-1
          utmp = uvar(kk,:,:)
          vtmp = vvar(kk,:,:)
    ut(kk,:,:) = unstaggerCICE5(utmp,uarea,tarea)
    vt(kk,:,:) = unstaggerCICE5(vtmp,uarea,tarea)
   end do
     ut@lon2d = gf->$icetlonname$*rfactor
     ut@lat2d = gf->$icetlatname$*rfactor
     vt@lon2d = gf->$icetlonname$*rfactor
     vt@lat2d = gf->$icetlatname$*rfactor
  end if ; useT

  ; copy metadata
   urot = ut
   vrot = vt
  do kk = 0,ndates-1
   urot(kk,:,:) = cos(rotang)*ut(kk,:,:) - sin(rotang)*vt(kk,:,:)
   vrot(kk,:,:) = sin(rotang)*ut(kk,:,:) + cos(rotang)*vt(kk,:,:)
  end do
   
  do kk = 0,ndates-1
     utmp = urot(kk,:,:)
     vtmp = vrot(kk,:,:)
   urot(kk,:,:) = where(utmp@lat2d .ge. minlat, urot(kk,:,:), utmp@_FillValue)
   vrot(kk,:,:) = where(vtmp@lat2d .ge. minlat, vrot(kk,:,:), vtmp@_FillValue)
  end do
  print("urot min = "+min(urot)+" urot max = "+max(urot))
  print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))
 end if ; addvectors

  ;if(model .eq. "hycice")then
   labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  ;else
  ; labelstring = "["+varname+"]"
  ;end if

  ;printVarSummary(icevar)
  icevar@units = ""
  icevar@long_name = ""
  ;icemasked=icevar
  ;icemasked=mask(icevar, (aivar .eq. 0.0), False)
  ;icevar=icemasked

  plottitle = plotname
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
  end if

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  if(model .eq. "m6cice5")then
   lon1=  60.00
   lon2=-120.00
  else
   lon1=  74.12
   lon2=-105.88
  end if
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
    ;nrows = 2
    ;ncols = 1
    nrows = 1
 end if
     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  res@mpFillOn             = True

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
  ; res@lbLabelAlignment     = "InteriorEdges"
  end if
  end if

  if(addvectors .eq. "yes")then
   res@gsnScalarContour  = True                  ; vectors over scalars

   res@vcRefMagnitudeF       = vmag              ; vec magnitude
   res@vcRefLengthF          = 0.10              ; size of ref vector
   res@vcMinDistanceF        = vthn              ; thins arrows near pole
   res@vcLineArrowThicknessF = 1.5
   res@vcGlyphStyle          = vectyp
  end if
  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  ;res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
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
;
;************************************************

  do ii = 0,ndates-1
    res@gsnCenterString = Dates2Plt(ii)
   if(addvectors .eq. "yes")then
    plot(ii) = gsn_csm_vector_scalar_map_polar(wks,urot(ii,:,:),vrot(ii,:,:),icevar(ii,:,:),res)    ; create the plot
   else
    plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
   end if
     dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@gsnPanelMainFontHeightF = 0.010            ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plotname+"  "+labelstring
  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelXWhiteSpacePercent = 5

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
