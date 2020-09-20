;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

 ;batch = "yes"
 batch = "no"

  hemi="NH"
 ; hemi="SH"

begin
;************************************************
;
;************************************************

  ;Dates2Plt = (/"2015-06-15", "2015-06-30" \
  ;             ,"2015-07-15", "2015-07-30" \
  ;             ,"2015-08-15", "2015-08-30" \
  ;             ,"2015-09-15", "2015-09-30" \ 
  ;             ,"2015-10-15", "2015-10-30" \ 
  ;             /)

  ;Dates2Plt = (/"2015-06-10", "2015-06-12" \
  ;             ,"2015-06-14", "2015-06-16" \
  ;             ,"2015-06-18", "2015-06-20" \
  ;             ,"2015-06-22", "2015-06-24" \
  ;             /)

  ;Dates2Plt = (/"2016-07-01", "2016-07-31" \
  ;             /)

  ; 0918 is last date avail for 0815 initialized run
  Dates2Plt = (/"0801", "0904"/)
  ;Dates2Plt = (/"0204","0505","0804","1104"/)
  ;Dates2Plt = (/"20160904", "20160905" \
  ;             ,"20160906", "20160907" \
  ;             ,"20160908", "20160909" \
  ;             ,"20160910" \
  ;             /)

  ndates = dimsizes(Dates2Plt)

  Years2Plt = (/"2013"/)
  ;Years2Plt = (/"2012", "2013", "2014" \
  ;             ,"2015", "2016", "2017"/)

  ;ndates = dimsizes(Years2Plt)
  ;Year = "2012"

;************************************************
; read in netCDF file
;************************************************

   rtsrc="/scratch2/NCEPDEV/climate/Denise.Worthen/IceData/"
   if(hemi .eq. "NH")then
      dirsrc="north/"+Years2Plt+"/seaice_conc_daily_nh_f17_"
    else
      dirsrc="south/"+Years2Plt+"/seaice_conc_daily_sh_f17_"
    end if
     icelonname="longitude"
     icelatname="latitude"

    varnames = (/"seaice_conc_cdr", \
                 "goddard_bt_seaice_conc", \
                 "goddard_nt_seaice_conc", \
                 "goddard_merged_seaice_conc"/)

    plotlabs = (/"NOAA/NSIDC Climate Data Record", \
                 "Bootstrap algorithm with Goddard QC", \
                 "NASA Team algorithm with Goddard QC", \
                 "Goddard Edited Climate Data Record"/)

;************************************************
; a list of the files
;************************************************

   icefilelist = rtsrc+dirsrc+Years2Plt+Dates2Plt+"_v03r01.nc"
  print(icefilelist)
  icedmfiles=addfiles(icefilelist,"r")
  ListSetType(icedmfiles,"cat")

;************************************************
; load an ice field
;************************************************

   fldtoplot = 0
   varname = varnames(fldtoplot)
   plotlab = plotlabs(fldtoplot)

  ;colormap = "WhBlGrYeRe"
  colormap = "amwg256"
  levs = (/0.1, 0.9, 0.1/)

  icevar=icedmfiles[:]->$varname$(:,:,:)
   icevar@lon2d=icedmfiles[0]->$icelonname$
   icevar@lat2d=icedmfiles[0]->$icelatname$
   labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  ;printVarSummary(icevar)
  ; reset to blank
  icevar@units=""
  icevar@long_name=""

   ivar=byte2flt(icevar)
   copy_VarCoords(icevar,ivar)
  ;icemasked=mask(ivar, (ivar .lt. 0.0), False)
  ;ivar=icemasked/100.0
  ;ivar=ivar/100.0
  ;printVarSummary(ivar)
  ;copy_VarCoords(ivar,icemasked)
 
; Get the time axis 
  ;times= icemmfiles[:]->time
  ;timeUnits = icemmfiles[:]->time@units
  ;timeCalendar = icemmfiles[:]->time@calendar
  ;print(times)

  plottitle=rtsrc+varname
  wkstitle=varname

;************************************************
; define the map
;************************************************

   ;wkstype="X11"
   ;wkstype@wkWidth=800
   ;wkstype@wkHeight=800
   wkstype="png"
   wkstype@wkWidth=2500
   wkstype@wkHeight=2500

   wks   = gsn_open_wks (wkstype,wkstitle)

  ; panel number
  npanels = ndates
 ; for panels
 ;if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 ;else
 ;   ncols = 2
 ;   nrows = 2
 ;end if
     plot = new(npanels,graphic)

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

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

   ;res@cnLevelSelectionMode        = "ExplicitLevels"
   ;res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   ;res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .020        ; change font height of labels

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
    ;res@gsnCenterString = Years2Plt(ii)+Dates2Plt(0)
    res@gsnCenterString = Years2Plt(0)+Dates2Plt(ii)

   plot(ii) = gsn_csm_contour_map_polar(wks,ivar(ii,:,:),res)    ; create the plot
  end do

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plotlab

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
