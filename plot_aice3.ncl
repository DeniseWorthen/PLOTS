;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

  batch = "no"

begin
  Year = 2012
  hemi = "NH"

  ;Year = 2017
  ;hemi = "SH"

  Date = Year+"0915"
 IDate = Year+"0815"

   cfsv2src = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchCFSv2/"
   benchsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchIce/"
   nsidcsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/IceData/"

    ndates = 1
   ; 3 explict files
    cfsv2f = addfile(cfsv2src+"cfs."+IDate+"/cfsv2."+IDate+"00.cice5grid.nc","r")
    benchf = addfile(benchsrc+"gfs."+IDate+"/ice"+Date+"12.01."+IDate+"00.subset.nc","r")
   if(hemi .eq. "NH")then
    nsidcf = addfile(nsidcsrc+"north/"+Year+"/seaice_conc_daily_nh_f17_"+Date+"_v03r01.nc","r")
   else
    nsidcf = addfile(nsidcsrc+"south/"+Year+"/seaice_conc_daily_sh_f17_"+Date+"_v03r01.nc","r")
   end if

   ; for cfsv2
    lstep=32-1
    cfsice=cfsv2f->aice_h(lstep,:,:)
    modice=benchf->aice_h(0,:,:)

    cfsice@lon2d = benchf->TLON
    cfsice@lat2d = benchf->TLAT
    modice@lon2d = benchf->TLON
    modice@lat2d = benchf->TLAT

    obsice=byte2flt(nsidcf->seaice_conc_cdr(0,:,:))
    obsice@lon2d=nsidcf->longitude
    obsice@lat2d=nsidcf->latitude

    cfsice@units=" "
    cfsice@long_name=" "
    modice@units=" "
    modice@long_name=" "
    obsice@units=" "
    obsice@long_name=" "
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

  wkstitle= hemi+Year
  colormap = "WhBlGrYeRe"

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)

  ; panel number
  npanels = 3
    ncols = 3
    nrows = 1
     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@cnFillMode           = "RasterFill"
  ;res@mpFillOn             = True
  res@mpOutlineOn          = False

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66                          ; minimum lat to plot
  ; res@mpMinLatF    =  80                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -53                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  res@cnMissingValPerimOn     = False           ; turn on the missing value perimeter
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .025        ; change font height of labels

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
; make plots
;************************************************

  ii = 0
  res@gsnCenterString = "CFSv2 Initialized "+IDate
  plot(ii) = gsn_csm_contour_map_polar(wks,cfsice(:,:),res)    ; create the plot
    ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii = 1
  res@gsnCenterString = "Observed "
  plot(ii) = gsn_csm_contour_map_polar(wks,obsice(:,:),res)    ; create the plot
    ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii = 2
  res@gsnCenterString = "UFS Initialized "+IDate
  plot(ii) = gsn_csm_contour_map_polar(wks,modice(:,:),res)    ; create the plot
    ;dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

   ;res@gsnCenterString = Years2Plt(ii)+Date+" (initialized "+IDates(ii)+")"

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.020               ; make labels smaller

  resP@gsnPanelMainString  = Date
  resP@gsnPanelMainFontHeightF = 0.025            ; new resource added in NCL 

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  ;resP@amOrthogonalPosF = 0.8
  ;resP@gsnPanelFigureStringsJust = "TopLeft"
  ;resP@gsnPanelFigureStrings= (/"A)","B)","C)"/) ; add strings to panel

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
