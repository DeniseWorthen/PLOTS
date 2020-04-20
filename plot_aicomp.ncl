;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

 ;batch = "yes"
 batch = "no"

  hemi="NH"
  ;hemi="SH"

begin
;************************************************
;
;************************************************

   IDate = "20120815"

;************************************************
; read in netCDF file
;************************************************

   benchsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchIce/gfs."+IDate
   cfsv2src = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchCFSv2/cfs."+IDate
   nsidcsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/IceData/north/2012/"

   bench = addfile(benchsrc+"ice2012091512.01.2012081500.subset.nc","r")
   cfsv2 = addfile(cfsv2src+"cfsv2.2012081500.nc","r")
   nsidc = addfile(nsidcsrc+"seaice_conc_daily_nh_f17_20120915_v03r01.nc","r")

   aibench = bench->aice_h(0,:,:)
   aicfsv2 = cfsv2->aice_h(35-1,:,:)
   ainisdc = nsidc->byte2flt(seaice_conc_cdr(0,:,:))

   icelatname = "TLAT"
   icelonname = "TLON"
     aicename = "aice_h"

;************************************************
; a list of the files
;************************************************

   icefilelist = rtsrc+"gfs."+IDates+"/ice"+Dates2Plt+".subset.nc"
  print(icefilelist)
  icedmfiles=addfiles(icefilelist,"r")
  ListSetType(icedmfiles,"join")

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; load an ice field
;************************************************

   varname = aicename
  colormap = "WhBlGrYeRe"

  icevar=icedmfiles[:]->$varname$(:,:,:,:)
  ;printVarSummary(icevar)
  icevar@lon2d=icedmfiles[0]->$icelonname$
  icevar@lat2d=icedmfiles[0]->$icelatname$
  ;labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  ;labelstring = Year+"0916"
  ;printVarSummary(icevar)
  ; reset to blank
  icevar@units=""
  icevar@long_name=""

  ;mask = where(icevar(0,0,:,:) .eq. icevar@_FillValue, 0.0, 1.0)

  plottitle=rtsrc+varname
  wkstitle=varname

;************************************************
; define the map
;************************************************

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
  npanels = ndates
 ; for panels
 if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else
    ;ncols = 4
    ncols = 1
    nrows = ndates
    ;nrows = 1+npanels/ncols
 end if
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
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .020        ; change font height of labels

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

  do ii = 0,ndates-1
   ;res@gsnCenterString = Year+Dates2Plt(ii)
   res@gsnCenterString = Years2Plt(ii)+Date+" (initialized "+IDates(ii)+")"

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,0,:,:),res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@txFontHeightF = .025
  ;resP@txString = labelstring
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
