; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; gaea
  RT = "/lustre/f2/scratch/ncep/Denise.Worthen/FV3_RT/"

 ; hemi = "NH"
 ; hemi = "SH"
  hemi = "none"

  ;plottype = "land"
  plottype = "ocean"

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

 ; in coupler history files
    tlonname = "grid_xt"
    tlatname = "grid_yt"

 wkstitle = "cpldcontrol"
  runlabs = (/"Control","Restart"/)
 dirs = (/"restarts/rm_caglobal/base/", "restarts/rm_caglobal/rest/" /)
 ;dirs = (/"restarts/base/", "restarts/rest/" /)
  time = "2021-03-22-65520."
  fsrc = "ufs.cpld.cpl.hi."
 ndirs = dimsizes(dirs)
   nts = dimsizes(time)

  ; add cpl history files on tile
  files=addfiles(RT+dirs+fsrc+time+tile+".nc","r")
  print(files)

  ; set plot limits if not polar
  tilecorners = tilegrid(files[0]->$tlonname$,files[0]->$tlatname$,tile)
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
    minlat =  50.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  ;palette="BlueWhiteOrangeRed"
  palette="BlWhRe"

  ; atm fields
  atmflds = (/ "atmImp_Faxa_rain",  \
               "atmImp_Sa_pbot",    \
               "atmImp_Sa_shum",    \
               "atmImp_Sa_tbot",    \
               "atmImp_Sa_z",       \
               "atmImp_Faxa_lwnet"  \
            /)
  nflds = dimsizes(atmflds)

  ; easier plots 
  atmwgts = (/1.e4, \
              1.00, \
              1.e4, \
              1.00, \
              1.00, \
              1.00 \
            /)

  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.02,  0.02, 0.002/) ; rain
  plotlevs( 1,:) = (/  -0.02,  0.02, 0.002/) ; pbot
  plotlevs( 2,:) = (/  -0.02,  0.02, 0.002/) ; shum
  plotlevs( 3,:) = (/  -0.02,  0.02, 0.002/) ; tbot
  plotlevs( 4,:) = (/  -0.02,  0.02, 0.002/) ; zbot
  plotlevs( 5,:) = (/  -0.02,  0.02, 0.002/) ; lwnet

  ; atm fields
  ;atmflds = (/"aod550",     \
  ;            "bc_aod550",  \
  ;            "du_aod550",  \
  ;            "oc_aod550",  \
  ;            "ss_aod550",  \
  ;            "su_aod550"   \
  ;            /)
  ;nflds = dimsizes(atmflds)

  ;plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/  0.0,  1.00, 0.100/)
  ;plotlevs( 1,:) = (/  0.0,  0.02, 0.001/)  ; bc
  ;plotlevs( 2,:) = (/  0.0,  1.00, 0.100/)  ; du
  ;plotlevs( 3,:) = (/  0.0,  0.20, 0.010/)  ; oc
  ;plotlevs( 4,:) = (/  0.0,  0.20, 0.010/)  ; ss
  ;plotlevs( 5,:) = (/  0.0,  0.20, 0.010/)  ; su
  
  ; retrieve orodata file from INPUT directory for masking
  ofile = addfile(RT+dirs(0)+"INPUT/oro_data."+tile+".nc","r")
  mskname = "slmsk"
  msklonname = "geolon"
  msklatname = "geolat"
  mskvar = ofile->$mskname$(:,:)
  mskvar@lon2d = ofile->$msklonname$
  mskvar@lat2d = ofile->$msklatname$

  plottitle=runlabs(1)+" - "+runlabs(0)+"  "+tile

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

  plot = new(nflds,graphic)

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

  do ii = 0,nflds-1
   aname = atmflds(ii)
     wgt = atmwgts(ii)
   print("variable "+aname+"  weight "+wgt)

    avar = files[1]->$aname$(:,:)-files[0]->$aname$(:,:)

    lndonly = avar
    lndonly = mask(avar*wgt,mskvar,1.0)  ; land only
    ocnonly = avar
    ocnonly = mask(avar*wgt,mskvar,0.0)  ; ocean only

    if(plottype .eq. "land")then 
     avar = lndonly
     msklab = "Land Points Only"
    else
     avar = ocnonly
     msklab = "Ocean Points Only"
    end if
    levs = plotlevs(ii,:)
    avar@lon2d = files[0]->$tlonname$
    avar@lat2d = files[0]->$tlatname$

    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

    res@gsnCenterString                 = aname
    if(hemi .eq. "none")then
      plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    else
      plot(ii) = gsn_csm_contour_map(wks,avar,res)    ; create the plot
    end if
 end do

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle + ",  "+msklab

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,3/),resP)
  ;gsn_panel(wks,plot,(/1,1/),resP)

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
