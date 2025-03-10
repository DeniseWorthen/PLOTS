; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

; Plot the decomposition of an unstructured mesh from WW3

   RT = "/work2/noaa/stmp/dworthen/stmp/dworthen/ultralow.2/"
   ;RT = "/work2/noaa/stmp/dworthen/stmp/dworthen/FV3_RT/rt_188291/"

   plotlabs = (/"Unstr 2PE"/)
   rts=(/"warm.48/"/)
   ;rts=(/"cpld_debug_pdlib_p8_intel/"/)

   fnames = RT+rts+"emesh.decomp.nc"
   files  = addfiles(fnames,"r")
   nplots = dimsizes(rts)
   print(fnames)

  ; auto-set the max fill level
  dmax = new((/nplots/),integer)
  do ii = 0,nplots-1
    dc = toint(files[ii]->decomp)
    dmax(ii) = max(dc)
  end do
  levs = (/1,max(dmax)+1,1/)

  wkstitle = "decomp"
  plottitle= "Decomposition Examples"

;************************************************
; define the map
;************************************************

  wkstype="X11"
 ; wkstype="png"
  wkstype@wkWidth=600
  wkstype@wkHeight=600
  wks   = gsn_open_wks (wkstype,wkstitle)       ; send graphics to X11 window
  ; drawNDCGrid(wks)
  plot = new(nplots,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  ;res@mpFillOn           = False
  ;res@mpOutlineOn        = False
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; add coord marks
;************************************************

  mkres = True
  mkres@gsMarkerSizeF = 2.
  mkres@gsnFrame        = False
  mkres@gsnDraw         = False
  mkres@gsnCoordsAttach = True

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,nconn,pltlevs,palette)
begin
  res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
  res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
  res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
  res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  res@cnFillPalette        = palette

  res@gsnCenterStringFontHeightF      = 0.012
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  pltvar@units = ""
  pltvar@long_name = ""

  res@sfElementNodes = nconn
  res@sfFirstNodeIndex = 1
  ;res@mpFillOn             = False
  ;res@mpOutlineOn          = False
  splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  ;gsn_coordinates(wks,splot,pltvar,mkres)
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  ;resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  ;resP@amJust = "TopLeft"
  ;resP@gsnPanelFigureStringsFontHeightF = 0.008
; ***************************************************
;
; ***************************************************

      latname = "coordy"
      lonname = "coordx"
     connname = "nconn"
      vname = "decomp"
      cmap = "cb_9step"
      do ii = 0,nplots-1
        data = files[ii]->$vname$
        dof = files[ii]->dof
        ip = dim_pqsort(dof,1)

	var1d_sort = data
	var1d_sort = data(ip)
	data = var1d_sort

	cnodes = files[ii]->nconn
	;printVarSummary(cnodes)
	print(cnodes(0:9,:))
	; sort across dim 0

	cnodes_sort = cnodes
        cnodes_sort(:,:) = cnodes(ip,:)
	;print(cnodes_sort(0:9,:))
	;cnodes_sort = cnodes
	;cnodes_sort = cnodes(ip,:)
	;printVarSummary(var1d_sort)
        ;var1d_sort(:,0:2) = var1d_sort(ip,0:2)
        cnodes     = cnodes_sort
        print(cnodes(0:9,:))

	x = files[ii]->$lonname$
	y = files[ii]->$latname$

	x_sort = x
	x_sort = x(ip)
	x = x_sort

	y_sort = y
	y_sort = y(ip)
	y = y_sort

        data@lon1d = x
        data@lat1d = y
        plot(ii) = subplot(ii,plotlabs(ii),data,cnodes,levs,cmap)

      delete(data)
    end do

;************************************************
; make the panel
;************************************************

   gsn_panel(wks,plot,(/nplots,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
