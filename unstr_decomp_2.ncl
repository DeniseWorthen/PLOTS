; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
  
  ;MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WW3_input_data_20220624/"
  ;scrpfile   = "no_land_CardDeck.SCRIP.nc"
  MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/moddefs3/"
  scrpfile   = "trip1deg_noland.SCRIP.nc"
  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

  ; cheyenne
  ;RT1 = "/glade/scratch/worthen/WaveUnstr/"
  ; hera
  RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/atmwtrip/"

 gridtype  = (/"unstructured", \
               "unstructured", \
               "unstructured", \
               "unstructured"  /)

 plotlabs = (/"Unstr DomainDecomp, no UST, 3PE",   \
              "Unstr Domain Decomp, with UST, 3PE", \
              "Unstr Domain Decomp, with UST, 5PE", \
              "Unstr Domain Decomp, with UST, 6PE"/)

      rts = (/"noust3PE/",      \
              "withust3PE/", \
              "withust5PE/", \
              "withust6PE/"  /)

  fnames = RT1+rts+"emesh.decomp.nc"
  files  = addfiles(fnames,"r")
  nplots = dimsizes(gridtype)
  levs = (/1,10,1/)

  fdof = "dof.wav.nc"
  dofs = addfiles(RT1+rts+fdof,"r")
  wkstitle = "decomp"
  plottitle= "decomp"

;************************************************
; define the map
;************************************************

  wkstype="X11"
						; wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
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
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,gtype,pltvar,pltlevs,palette)
begin
  res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
  res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
  res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
  res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  res@cnFillPalette        = palette
  
  if (gtype .eq. "unstructured") then
    res@sfXCellBounds = cx(:,0:5)
    res@sfYCellBounds = cy(:,0:5)
  end if
    
  res@gsnCenterStringFontHeightF      = 0.012
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05
 
  pltvar@units = ""
  pltvar@long_name = ""

  if (gtype .eq. "structured") then
    res@mpCenterLonF       = 180
    res@mpFillOn           = False
    res@mpOutlineOn        = False
    splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
    delete(res@mpCenterLonF)
    delete(res@mpFillOn)
    delete(res@mpOutlineOn)
  else
    splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  end if
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end

;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 1.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnLinesOn        = True
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ;ores@cnLevelSelectionMode = "ManualLevels"
  ;ores@cnLevels         = (/1,6,1/)
  ;ores@cnFillPatterns   = (/17,17,17,17/)
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
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  ;resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  ;resP@amJust = "TopLeft"
  ;resP@gsnPanelFigureStringsFontHeightF = 0.008
; ***************************************************
;
; ***************************************************
  
      wgt = 1.0
      cmap = "circular_2"
      do ii = 0,nplots-1
        vname = "decomp"
        gtype = gridtype(ii)
        if (gtype .eq. "structured")then
        data = files[ii]->$vname$(0,:,:)
        data = data*wgt
        data@lon2d = files[ii]->$lonname$(:,:)
        data@lat2d = files[ii]->$latname$(:,:)
      else
        data = files[ii]->$vname$
        data = data*wgt

        dof = dofs[ii]->dof
          ip = dim_pqsort(dof,1)
          var1d_sort = data
          var1d_sort = data(ip)
          data       = var1d_sort
          data@lon1d = x
          data@lat1d = y
      end if
      plot(ii) = subplot(ii,plotlabs(ii),gtype,data,levs,cmap)
      
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
