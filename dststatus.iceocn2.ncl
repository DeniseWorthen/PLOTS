;**********************************************************

  load "dststatus_counts.ncl"

;**********************************************************
begin

  RT="/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ;RT            = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/maskchange/"
  ;rts = (/"base/", "mask.consf/", "mask.bilnr/"/)
  ;plotlabs = (/"base", "srcMask (ATM)->spval", "srcMask (ATM)=1, bilnr->ICE"/)

  ;rts = "base/"
  ;plotlabs = "base"

  ;rts = "mask.consf/"
  ;plotlabs = "srcMask (ATM)->spval"

  ;rts = "mask.bilnr/"
  ;plotlabs = "srcMask (ATM)=1, bilnr->ICE"

  ;rts="sample_cice_run/"
  ;plotlabs="sample_cice_run"
  rts = "arct2/"
  plotlabs="sample_cice_run"

  nl = str_get_nl()
   nflags = 9

   vname = "dstatm_ice_atm_consf"
 ;vname = "dstice_atm_ice_bilnr"
 ;vname = "dstice_atm_ice_consf"
 ;vname = "dstice_atm_ice_nstod_consf"

    levs = (/0,9,1/)
    ;fsrc = "ufs.cpld.dststatus.nc"
    fsrc = "ufs.hafs.dststatus.nc"

    nplots = dimsizes(rts)

    fnames = RT+rts+fsrc
    files  = addfiles(fnames,"r")
    print(fnames)

;************************************************
; define the map
;************************************************


  wkstype="X11"
  ;wkstype="png"
  wkstitle=vname
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;gsn_define_colormap(wks, "amwg")   ; choose colormap
  gsn_define_colormap(wks, "amwg_blueyellowred")

  plot = new(nplots,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.60

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn      = False
  res@lbLabelBarOn      = False
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ;res@cnFillPalette   = "amwg"
  ;res@cnFillPalette   = "sunshine_9lev"
 ;res@cnFillPalette   = "GMT_paired"
 res@cnFillColors = (/-1,8,2,6,7,10,12,14,16/) ; amwg_blueyellowred
  ;res@cnFillPalette   = "amwg_blueyellowred"
  ;cmap = read_colormap_file("amwg_blueyellowred")
  ;ncolors = dimsizes(cmap(:,0))
  ;res@cnMaxLevelCount = ncolors-1       ; make sure NCL chooses 15 or fewer contour levels
 ; cmap(0,:) = namedcolor2rgba("white")
  ;res@cnFillPalette := cmap      ; Use modified RGB/A array

  res@tiMainFontHeightF = .010
  res@tiMainString = plotlabs(0)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  ;resP@gsnPanelFigureStrings = (/plotlabs(0)/)

  ;resP@gsnPanelFigureStrings = (/plotlabs(0),plotlabs(1),plotlabs(2)/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

   ;res@mpMinLatF    =  66.0                          ; minimum lat to plot
   ;res@mpCenterLonF = -45.0
;************************************************
;
;************************************************


  ii = 0
  ;do ii = 0,nplots-1
 ;data = files[ii]->$vname$(200:320,0:180)
 ;data = files[ii]->$vname$
 data = files[ii]->$vname$(0,:,:)
  ;tmp = data
  ;tmp = where(data .ge. 5.0 .and. data .le. 7.0, 5.0, data)
  ;data = tmp
    plot(ii) = gsn_csm_contour(wks,data,res)    ; create the plot
  ;end do

;************************************************
; make the panel
;************************************************

   gsn_panel(wks,plot,(/nplots,1/),resP)

   frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
