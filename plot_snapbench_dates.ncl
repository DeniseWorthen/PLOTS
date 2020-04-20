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

  ; 0918 is last date avail for 0815 initialized run
  ;Year = "2012"
  Years2Plt = (/"2012"/)
  ;Years2Plt = (/"2012", "2013", "2014" \
  ;             ,"2015", "2016", "2017"/)

  IDate = "20120701"
  Dates2Plt = (/"20120701.01."+IDate+"00.subset.nc"\
               ,"20120715.01."+IDate+"00.subset.nc"\
               ,"20120804.01."+IDate+"00.subset.nc"/)
  ;Dates2Plt = (/Date+"12.01."+Year+"081500"\
  ;             ,Date+"12.01."+Year+"090100"\
  ;             ,Date+"12.01."+Year+"091500"/)
  ;Dates2Plt = (/Years2Plt+Date+"12.01."+Years2Plt+"081500"\
  ;             ,Years2Plt+Date+"12.01."+Years2Plt+"090100"/)
  ;Dates2Plt = (/Years2Plt+Date+"12.01."+Years2Plt+"081500"/)
  ;Dates2Plt = (/Years2Plt+Date+"12.01."+Years2Plt+"090100"/)

  ;ndates = dimsizes(Years2Plt)*dimsizes(Dates2Plt)
  ;ndates = 12
  print(Dates2Plt)
  ndates = dimsizes(Dates2Plt)

  ;IDates = str_get_cols(Dates2Plt, 14, 21)
  ;print("gfs."+IDates)
  datelabs = str_get_cols(Dates2Plt, 0, 7)

;************************************************
; read in netCDF file
;************************************************

   rtsrc="/scratch2/NCEPDEV/climate/Lydia.B.Stefanova/Models/ufs_b31/SeaIce/"

   icelatname = "TLAT"
   icelonname = "TLON"
     aicename = "aice_h"

;************************************************
; a list of the files
;************************************************

   icefilelist = rtsrc+IDate+"/ice"+Dates2Plt
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
  ;colormap = "WhBlGrYeRe"
  ;colormap = "MPL_rainbow"
  colormap = "amwg"
      levs = (/0.0,1.0,0.1/)
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
   ;wkstype="png"
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
    ncols = 2
    nrows = 2
    ;ncols = 1
    ;nrows = ndates
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

   ;res@cnLevelSelectionMode        = "ExplicitLevels"
   ;res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   ;res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = levs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = levs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = levs(2)            ; set the interval between contours
   ;res@cnFillPalette        = palette

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
   res@gsnCenterString = datelabs(ii)
   ;res@gsnCenterString = Years2Plt(ii)+IDate+" (initialized "+IDates(ii)+")"

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,0,:,:),res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
; panel it
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.020               ; make labels smaller

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
