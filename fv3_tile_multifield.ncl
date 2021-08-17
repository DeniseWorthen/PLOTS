; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; gaea
  RT = "/lustre/f2/scratch/ncep/Denise.Worthen/FV3_RT/"

   hemi = "NH"
 ; hemi = "SH"
  ;hemi = "none"

  rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile1"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

  tlonname = "grid_xt"
  tlatname = "grid_yt"
  orolonname = "geolon"
  orolatname = "geolat"

  ;rtsrc = "FV3_RT/test96/debug/INPUT/"
  ;afile = addfile(RT2+rtsrc+model+tile+".nc","r")
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/grids-20210201/C96.mx100.tile4.nc","r")
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/GRIDS/C96.mx100.tile4.nc","r")
  ;afile = addfile("/scratch2/NCEPDEV/climate/Denise.Worthen/GTMP/C96.mx100.tile4.nc","r")

 ;model="P6 IC"
 ; rtsrc = "FV3_RT/rt_201936/test/"
 ; wkstitle="dt=225s"
 ; afile = addfile(RT2+rtsrc+"ufs.cpld.cpl.hi.2011-05-01-00225."+tile+".nc","r")
 ; rtsrc = "FV3_RT/tests_dt/test3_300/"
 ; wkstitle="dt=300s"
 ; afile = addfile(RT2+rtsrc+"ufs.cpld.cpl.hi.2011-05-01-00300."+tile+".nc","r")

 ; wkstitle="dt_diff"
 ; afile = addfile(RT2+rtsrc+"diff.nc","r")
 ; ofile = addfile(RT2+rtsrc+"cpld_debugfrac/INPUT/oro_data."+tile+".nc","r")

 ;model="DT test"
 ; rtsrc = "FV3_RT/test_dts_c96/cpld_debugfrac_na/"
 ;  time = "00900"
 ; wkstitle="dt_"+time
 ; afile = addfile(RT2+rtsrc+"ufs.cpld.cpl.hi.2016-10-03-"+time+"."+tile+".nc","r")
  ; retrieve orodata file from INPUT directory
 ; ofile = addfile(RT2+rtsrc+"INPUT/oro_data."+tile+".nc","r")

 model = "cpld_control"
 rtsrc = "FV3_RT/truefalse_rt_2532/test/"
  wkstitle="cpldcontrol"
  time = ""
  afile = addfile(RT+rtsrc+"ufs.cpld.cpl.hi.2016-10-03-"+time+"."+tile+".nc","r")
  ; retrieve orodata file from INPUT directory
  ofile = addfile(RT2+rtsrc+"INPUT/oro_data."+tile+".nc","r")

  tilecorners = tilegrid(afile->$tlonname$,afile->$tlatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   ;minlon = 144.0
   ;minlat = -10.
   ;maxlon = 154.0
   ;maxlat = 0.0
   midlon = minlon + 0.5*(maxlon - minlon)
   print(minlat+"   "+maxlat)
   print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  aname = "atmImp_Faxa_sen"
  ;levs=(/-5.0,5.0,0.5/)
  ;levs=(/-1.0,1.0,0.1/)
  ;aname = "atmImp_Sa_z"
  levs=(/-20.0,20.0,1.0/)
  ;levs=(/10.0,30.0,0.5/)
  palette="BlueWhiteOrangeRed"
  ;palette="WhBlGrYeRe"

  ; atm fields
  ;atmflds = (/"aod550",     \
  ;            "bc_aod550",  \
  ;            "du_aod550",  \
  ;            "oc_aod550",  \
  ;            "ss_aod550",  \
  ;            "su_aod550"   \
  ;            /)
  nflds = dimsizes(atmflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/  0.0,  1.00, 0.100/)
  ;plotlevs( 1,:) = (/  0.0,  0.02, 0.001/)  ; bc
  ;plotlevs( 2,:) = (/  0.0,  1.00, 0.100/)  ; du
  ;plotlevs( 3,:) = (/  0.0,  0.20, 0.010/)  ; oc
  ;plotlevs( 4,:) = (/  0.0,  0.20, 0.010/)  ; ss
  ;plotlevs( 5,:) = (/  0.0,  0.20, 0.010/)  ; su

  oname = "slmsk"
  ovar = ofile->$oname$(:,:)
  ovar@lon2d = ofile->$orolonname$
  ovar@lat2d = ofile->$orolatname$
  ;printVarSummary(ovar)

  plottitle=model+" sfcf000 "+tile

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  plot = new(nflds,graphic)
 oplot = new(nflds,graphic)

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
  ;  res@mpMinLatF    =  66.0                          ; minimum lat to plot
    res@mpMinLatF    =  50.0                          ; minimum lat to plot
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
   res@mpCenterLonF         =  midlon
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill
  res@cnFillPalette            = palette

  ;res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  ;res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  ;res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@tiMainFontHeightF = .010
  ;res@tiMainString = plottitle

;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/0.999/)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle

;************************************************
;
;************************************************

  do ii = 0,nflds-1
   aname = atmflds(ii)
    avar = afile->$aname$(0,:,:)
    levs = plotlevs(ii,:)
    avar@lon2d = afile->$tlonname$
    avar@lat2d = afile->$tlatname$

    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

   if(hemi .eq. "none")then
     plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    oplot(ii) = gsn_csm_contour(wks,ovar,ores)    ; create the plot
    overlay(plot(ii),oplot(ii))
   else
     plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    oplot(ii) = gsn_csm_contour(wks,ovar,ores)    ; create the plot
    overlay(plot(ii),oplot(ii))
   end if
 end do

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/2,3/),resP)
  gsn_panel(wks,plot,(/1,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
