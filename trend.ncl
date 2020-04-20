;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  batch = "no"
  ;batch = "yes"

  hemi="NH"
  ;hemi="SH"

begin
;************************************************
; arrays for depth dependent contour levels
;************************************************

  ;tlevs_polar(0,:) = (/ (/   0.0, -1.5,  1.5,  .050/) /)
  ;tlevs_polar(3,:) = (/ (/ 500.0, -0.2,  1.0,  .020/) /)

  tlevs_polar = new((/5,4/),float)
 ; tlevs_polar(0,:) = (/ (/   0.0, -1.8, -1.2,  .010/) /)
  tlevs_polar(0,:) = (/ (/   0.0, -1.8, -1.68,  .001/) /)
  ;tlevs_polar(0,:) = (/ (/   0.0, -1.8,  4.0,  .200/) /)
  ;tlevs_polar(1,:) = (/ (/ 100.0, -1.6,  3.2,  .050/) /)
  tlevs_polar(1,:) = (/ (/ 100.0, -1.4,   0.6,  .020/) /)
  tlevs_polar(2,:) = (/ (/ 200.0, -0.2,  3.0,  .050/) /)
  tlevs_polar(3,:) = (/ (/ 500.0, -1.0,  2.0,  .020/) /)
  ;tlevs_polar(3,:) = (/ (/ 500.0, 0.0,  1.2,  .020/) /)
  tlevs_polar(4,:) = (/ (/1000.0, -0.7,  0.7,  .025/) /)

  slevs_polar = new((/5,4/),float)
  slevs_polar(0,:) = (/ (/   0.0, 28.40,  35.20,  0.200/) /)
  ;slevs_polar(1,:) = (/ (/ 100.0, 28.40,  35.20,  0.200/) /)
  slevs_polar(1,:) = (/ (/ 100.0, 31.60,  34.80,  0.050/) /)
  slevs_polar(2,:) = (/ (/ 200.0, 33.50,  35.10,  0.025/) /)
  ;slevs_polar(3,:) = (/ (/ 500.0, 34.60,  35.02,  0.010/) /)
  slevs_polar(3,:) = (/ (/ 500.0, 34.80,  35.00,  0.005/) /)
  slevs_polar(4,:) = (/ (/1000.0, 34.86,  34.94,  0.002/) /)

;************************************************
;
;************************************************

  ;Dates2Plt = (/"20170701"/)
  ;Dates2Plt = (/"20170901"/)
  ;Dates2Plt = (/"20180415", "20180515"/)
  Dates2Plt = (/"20171017", "20171115", "20171215"\
               ,"20180115", "20180215", "20180315" \
               ,"20180415", "20180515" \
               /)
  ;Hours2Plt = (/"n048", "f024", "f096", "f144", "f192"/)
  Hours2Plt = (/"n048"/)

   nhours = dimsizes(Hours2Plt)
   ndates = dimsizes(Dates2Plt)

;************************************************
; a list of the files
;************************************************

     rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS/"
  ;   rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/testget/20170901/"
  ;   rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/testget/"
   runname = "RTOFS operational, "+Hours2Plt 
  ;runname = "NCEPPROD/1year/hpssprod/runhistory/rh2017/201709/20170901/rtofs_glo_3dz_xxxx_daily_3ztio.nc"
  ;runname = "NCEPPROD/1year/hpssprod/runhistory/rh2017/201710/20171031/rtofs_glo_3dz_xxxx_daily_3ztio.nc"
  filelist = rtsrc+"rtofs_glo_3dz_"+Hours2Plt+"_daily_3ztio."+Dates2Plt+".nc"
  ;filelist = rtsrc+"rtofs_glo_3dz_"+Hours2Plt+"_daily_3zsio."+Dates2Plt+".nc"
  print(filelist)

  nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/hycom_data/mx008/"
   ; load the grid file
   gf =addfile(nemsdir+"hycom_grid_008.nc","r")
   ocnlonname = "plon"
   ocnlatname = "plat"

   ocnfiles = addfiles(filelist,"r")

         ijskp = 5
    ;     ijskp = 3
    ;     ijskp = 1

      varname="temperature"
      ;varname="salinity"
   zcoordname="Depth"
         kmax=33-1

;************************************************
;
;************************************************

   ;  zlevel to plot
   ;zlevel = 0.0
   ;zlevel = 50.0
   ;zlevel = 100.0
   ;zlevel = 250.0
   zlevel = 500.0
   ;zlevel = 1000.0

  ; ocean depths
      odepth=ocnfiles[0]->$zcoordname$
  ; find the k index closest to the zlevel depth
       kstep=closest_val(zlevel,odepth)
        klev=closest_val(zlevel,tlevs_polar(:,0))
       tlevs=tlevs_polar(klev,1:3)

        tvar = ocnfiles[:]->$varname$(:,kstep,::ijskp,::ijskp)
  tvar@lon2d = gf->$ocnlonname$(::ijskp,::ijskp)
  tvar@lat2d = gf->$ocnlatname$(::ijskp,::ijskp)
  tvar@long_name=""
  tvar@units=""
  ;printVarSummary(tvar)

         times = ocnfiles[:]->MT
     timeUnits = ocnfiles[:]->MT@units
  timeCalendar = ocnfiles[:]->MT@calendar

  plottitle = runname
  if(batch .eq. "no")then
   wkstitle = "grtofs"
  else
   wkstitle = "grtofs"+"_"+varname
  end if

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=74.12
  lon2=-105.88
  lat1=60
  lat2=60

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  npanels = ndates
 ; for panels
 if(npanels .le. 4)then
   nrows = 1
   ncols = npanels
 else if(batch .eq. "yes")then
    ncols = nhours
    nrows = 1
 else
    ncols = 4
    nrows = 1+npanels/ncols
 end if
 end if
 print("npanels = "+npanels+" nrows = "+nrows+" ncols = "+ncols+" ijskp = "+ijskp)

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
  res@cnLineLabelsOn     = False                 ; 
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66                          ; minimum lat to plot
  ; res@mpMinLatF    =  88                          ; minimum lat to plot
  ; res@mpMinLatF    =  80                          ; minimum lat to plot
  ; res@mpMinLatF    =  78                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = tlevs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = tlevs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = tlevs(2)                      ; set the interval between contours

  ;res@cnFillPalette   = "WhBlGrYeRe"               ; choose colormap
  ;res@cnFillPalette   = "NCV_jet"               ; choose colormap
  res@cnFillPalette   = "MPL_rainbow"               ; choose colormap
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
;
;************************************************

  do ii = 0,ndates-1
    res@gsnCenterString = Dates2Plt(ii)

   plot(ii) = gsn_csm_contour_map_polar(wks,tvar(ii,:,:),res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  if(ii .eq. 0)then
  ; dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end if
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller

  ;resP@txFontHeightF = .01
  ;resP@txString = runname+"  "+labelstring
  ;resP@gsnPanelMainString  = runname+"  "+Dates2Plt
  resP@gsnPanelMainString  = runname+"  "+varname
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

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

;exit
end
