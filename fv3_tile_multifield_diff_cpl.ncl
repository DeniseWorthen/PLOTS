; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; gaea
  RT = "/lustre/f2/scratch/ncep/Denise.Worthen/FV3_RT/"

 ;  hemi = "NH"
 ; hemi = "SH"
  hemi = "none"

  rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6

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

  tlonname = "grid_xt"
  tlatname = "grid_yt"
  orolonname = "geolon"
  orolatname = "geolat"

 model = "cpld_control"
 runlabs = (/"Control","Restart"/)
 dirs = (/"rt_730/rm_caglobal/base/", "rt_730/rm_caglobal/rest/" /)
 ;dirs = (/"rt_730/base/", "rt_730/rest/" /)
  wkstitle="cpldcontrol"
  time = "2021-03-22-65520."
  fsrc = "ufs.cpld.cpl.hi."
 ndirs = dimsizes(dirs)
   nts = dimsizes(time)


  ; retrieve orodata file from INPUT directory
  ofile = addfile(RT+dirs(0)+"INPUT/oro_data."+tile+".nc","r")

  files=addfiles(RT+dirs+fsrc+time+tile+".nc","r")
  print(files)
  tilecorners = tilegrid(files[0]->$tlonname$,files[0]->$tlatname$,tile)
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

  ;aname = "atmImp_Faxa_lwnet"
  ;levs=(/-5.0,5.0,0.5/)
  ;levs=(/-1.0,1.0,0.1/)
  ;aname = "atmImp_Sa_z"
  ;levs=(/-20.0,20.0,1.0/)
  ;levs=(/10.0,30.0,0.5/)
  palette="BlueWhiteOrangeRed"
  ;palette="WhBlGrYeRe"

  ; atm fields
  ;atmflds = (/"atmImp_Faxa_lwnet"/)
  atmflds = (/ "atmImp_Faxa_rain", "atmImp_Sa_tbot"/)

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
  plotlevs( 0,:) = (/  -0.02,  0.02, 0.002/)

  oname = "slmsk"
  ovar = ofile->$oname$(:,:)
  ovar@lon2d = ofile->$orolonname$
  ovar@lat2d = ofile->$orolatname$
  ;printVarSummary(ovar)

  plottitle=atmflds(0)+": "+runlabs(1)+" - "+runlabs(0)

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

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
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
  ;resP@gsnPanelMainString = plottitle + ", Land points only "
  resP@gsnPanelMainString = plottitle + ", Ocean points only "

;************************************************
;
;************************************************

  do ii = 0,nflds-1
   aname = atmflds(ii)
    avar = files[1]->$aname$(:,:)-files[0]->$aname$(:,:)
    xvar = avar
    xvar = mask(avar, ovar, 0); ocean only
    ;xvar = mask(avar, ovar, 1) ; land only
    avar = xvar
    printVarSummary(avar)

    levs = plotlevs(ii,:)
    avar@lon2d = files[0]->$tlonname$
    avar@lat2d = files[0]->$tlatname$

    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

   if(hemi .eq. "none")then
     plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
   ; oplot(ii) = gsn_csm_contour(wks,ovar,ores)    ; create the plot
   ; overlay(plot(ii),oplot(ii))
   else
     plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
   ; oplot(ii) = gsn_csm_contour(wks,ovar,ores)    ; create the plot
   ; overlay(plot(ii),oplot(ii))
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
