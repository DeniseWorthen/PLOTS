;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  batch = "no"

  hemi="NH"
  ;hemi="SH"

  model="grtofs"
  ;model="hycice"
  ;model="grtofs_climo"

  simplelevs="yes"
  ;simplelevs="no"

begin
;************************************************
;
;************************************************

  ;Dates2Plt = (/"2015_187"/)
  ;Dates2Plt = (/"20170701"/)
  Dates2Plt = (/"20171031"/)
  ;Dates2Plt = (/"1920_184"/)

  ;Dates2Plt = (/"20170514", "20170601" \
  ;             ,"20170614", "20170701" \
  ;             ,"20170714", "20170801" \
  ;             ,"20170814", "20170901" \
  ;             /)

   ndates = dimsizes(Dates2Plt)

;************************************************
; a list of the files
;************************************************

  if(model .eq. "grtofs")then
  ;   rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS/"
     rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/testget/"
   runname = "GRTOFS ops"
  filelist = rtsrc+"rtofs_glo_2ds_f024_daily_diag."+Dates2Plt+".nc"
  ;filelist = rtsrc+"rtofs_glo_2ds_n048_daily_diag.nc"
  ;filelist = rtsrc+"rtofs_glo_2ds_f024_daily_diag.nc"
  ;filelist = rtsrc+"rtofs_glo_2ds_f096_daily_diag.nc"
  ;filelist = rtsrc+"rtofs_glo_2ds_f144_daily_diag.nc"

  nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/hycom_data/mx008/"
   ; load the grid file
   gf =addfile(nemsdir+"hycom_grid_008.nc","r")
   icelonname = "plon"
   icelatname = "plat"
  end if

  if(model .eq. "grtofs_climo")then
     rtsrc = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/GRTOFS_climo/ocnout/"
   runname = "GRTOFS climo"
  filelist = rtsrc+"archv."+Dates2Plt+"_00_ice.nc"

  nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/hycom_data/mx008/"
   ; load the grid file
   gf =addfile(nemsdir+"hycom_grid_008.nc","r")
   icelonname = "plon"
   icelatname = "plat"
  end if

  if(model .eq. "hycice")then
  ;    rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/"
     rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008/ocnout/"
   runname = "HYCOM-CICE5-GSM"
  filelist = rtsrc+"archv."+Dates2Plt+"_00_ice.nc"

  nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/hycom_data/mx024/"
   ; load the grid file
   gf =addfile(nemsdir+"hycom_grid_024.nc","r")
   icelonname = "plon"
   icelatname = "plat"
  end if

  icefiles = addfiles(filelist,"r")

   ;icelonname = "Longitude"
   ;icelatname = "Latitude"
         ijskp = 3

    ;     ijskp = 1
     aicename = "ice_coverage"
       hiname = "ice_thickness"

;************************************************
;
;************************************************

       varname = aicename
      ;    levs = (/0.90,1.0,0.002/)
          levs = (/0.0,1.0,0.1/)

        icevar = icefiles[:]->$varname$(:,::ijskp,::ijskp)
  icevar@lon2d = gf->$icelonname$(::ijskp,::ijskp)
  icevar@lat2d = gf->$icelatname$(::ijskp,::ijskp)
  ;icevar@lon2d = icefiles[0]->$icelonname$
  ;icevar@lat2d = icefiles[0]->$icelatname$
  icevar@long_name=""
  icevar@units=""
  ;printVarSummary(icevar)

  times = icefiles[:]->MT
; Get the time units and set the first and last times that we want
  timeUnits = icefiles[:]->MT@units
  timeCalendar = icefiles[:]->MT@calendar

  plottitle = runname
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
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

  ; a max of ndates panels, not all used
  npanels = ndates
 ; for panels
 if(npanels .le. 4)then
   nrows = 1
   ncols = npanels
 else if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else
    ncols = 4
    nrows = 1+npanels/ncols
 end if
 end if
 print("npanels = "+npanels+" nrows = "+nrows+" ncols = "+ncols)

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
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
  ; res@mpMinLatF    =  66                          ; minimum lat to plot
   res@mpMinLatF    =  88                          ; minimum lat to plot
  ; res@mpMinLatF    =  80                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  if(varname .eq. "ice_coverage")then
   if(simplelevs .eq. "yes")then
    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
   else
    res@cnLevelSelectionMode        = "ExplicitLevels"
    res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
    res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
   end if
  else if(varname .eq. "ice_thickness")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  end if
  end if


  res@cnFillPalette   = "WhBlGrYeRe"               ; choose colormap
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

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@txFontHeightF = .01
  ;resP@txString = runname+"  "+labelstring
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot
 ; gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

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
