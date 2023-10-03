; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/fixsigns/"

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"

 ;plottype = "unmasked"
 ;plottype = "land"
  plottype = "ocean"

  rad2deg=180.d0/acos(-1.0d0)

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

 ; in coupler history files
    tlonname = "ocnExp_lon"
    tlatname = "ocnExp_lat"

 wkstitle = "signs_units"
  runlabs = (/"Lat->Evap conversion in CMEPS","Direct Evap flux export"/)
 dirs = (/"cpld.base/", "cpld.sign/" /)
  fsrc = "ocn.hi"
 ndirs = dimsizes(dirs)

  ; add cpl history files on tile
  files=addfiles(RT+dirs+fsrc+".nc","r")
  print(files)

  ; set plot limits if not polar
  tilecorners = tilegrid(files[0]->$tlonname$(0,:,:),files[0]->$tlatname$(0,:,:),tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   print(minlat+"   "+maxlat)
   print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  else
   if(hemi .eq. "NH")then
    ;minlat =  50.0
    minlat =  34.0
    midlon = -45.0
   else
    maxlat = -34.0
    midlon =   0.0
   end if
  end if

  palette="BlueWhiteOrangeRed"
  ;palette="BlWhRe"

  ; ocn fields
  ocnflds = (/ "ocnExp_Faxa_rain",  \
               "ocnExp_Sa_pbot",    \
               "ocnExp_Sa_shum",    \
               "ocnExp_Sa_tbot",    \
               "ocnExp_Sa_z",       \
               "ocnExp_Faxa_lwnet", \
               "ocnExp_Faxa_evap"   \
            /)

  nflds = dimsizes(ocnflds)

  ; easier plots
  ocnwgts = (/1.e4, \
              1.00, \
              1.e4, \
              1.00, \
              1.00, \
              1.00, \
              86400.\     ; kg/m2/s->mm day
            /)

  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.02,  0.02, 0.002/) ; rain
  plotlevs( 1,:) = (/  -0.02,  0.02, 0.002/) ; pbot
  plotlevs( 2,:) = (/  -0.02,  0.02, 0.002/) ; shum
  plotlevs( 3,:) = (/  -0.02,  0.02, 0.002/) ; tbot
  plotlevs( 4,:) = (/  -0.02,  0.02, 0.002/) ; zbot
  plotlevs( 5,:) = (/  -0.02,  0.02, 0.002/) ; lwnet
  plotlevs( 6,:) = (/  -0.02,  0.02, 0.002/) ; evap

  ; retrieve masking
  mskname = "ocnImp_So_omask"
  msklonname = "ocnExp_lon"
  msklatname = "ocnExp_lat"
  mskvar = files[1]->$mskname$(0,:,:)
  mskvar@lon2d = files[1]->$msklonname$(0,:,:)
  mskvar@lat2d = files[1]->$msklatname$(0,:,:)
  printVarSummary(mskvar)

  plottitle=runlabs(1)+" - "+runlabs(0)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  ;plot = new(nflds,graphic)
  plot = new(1,graphic)

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF =  midlon
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = maxlat                            ; minimum lat to plot
    res@mpCenterLonF = midlon
   end if
  else
  ; res@mpMinLatF            =  minlat      ; range to zoom in on
  ; res@mpMaxLatF            =  maxlat
  ; res@mpMinLonF            =  minlon
  ; res@mpMaxLonF            =  maxlon
  ; res@mpCenterLonF         =  midlon
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  res@cnFillPalette     = palette

  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
;function subplot(ii,name,pltvar,pltlevs,palette,hemi)
;begin
;   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
;   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
;   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
;   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
;   res@cnFillPalette        = palette
;
;  res@gsnCenterStringFontHeightF      = 0.020
;  res@gsnCenterString                 = name
;  res@gsnCenterStringOrthogonalPosF   = 0.12
;
;  if(hemi .eq. "none" .or. hemi .eq. "global")then
;   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
;  else
;   splot = gsn_csm_contour_map_polar(wks,plotvar,res)    ; create the plot
;  end if
;  return(splot)
;end

;************************************************
;
;************************************************

  lstep = 6-1
  variable_to_plot=6
  aname = ocnflds(variable_to_plot)
  wgt = ocnwgts(variable_to_plot)
  print("variable "+aname+"  weight "+wgt)

  ; first plot, control values
  ii = 0
  var = files[0]->$aname$(lstep,:,:)
  levs = plotlevs(variable_to_plot,:)
  var@lon2d = files[0]->$tlonname$(0,:,:)
  var@lat2d = files[0]->$tlatname$(0,:,:)
  plot(ii) = subplot(

    var = files[1]->$aname$(lstep,:,:)-files[0]->$aname$(lstep,:,:)
    printVarSummary(var)
    avar = var
    lndonly = avar
    lndonly = mask(avar*wgt,mskvar,0.0)  ; land only
    ocnonly = avar
    ocnonly = mask(avar*wgt,mskvar,1.0)  ; ocean only

    if(plottype .eq. "land")then
      avar = lndonly
      msklab = "Land Points Only"
    else if(plottype .eq. "ocean")then
      avar = ocnonly
      msklab = "Ocean Points Only"
    else
      avar = var*wgt
      msklab = "All Points"
    end if
    end if
    levs = plotlevs(variable_to_plot,:)
    avar@lon2d = files[0]->$tlonname$(0,:,:)
    avar@lat2d = files[0]->$tlatname$(0,:,:)

    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

    res@gsnCenterString                 = aname
    ;if(hemi .eq. "none")then
      plot(0) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    ;else
    ;  plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    ;end if
 ;end do

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  ;resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle + ",  "+msklab

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/3,3/),resP)
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
