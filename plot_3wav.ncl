; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
  
  MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WW3_input_data_20220624/"
  scrpfile   = "no_land_CardDeck.SCRIP.nc"
  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

  ; cheyenne
  ;RT1 = "/glade/scratch/worthen/WaveUnstr/"
  ; hera
  RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_9631/"

 gridtype  = (/"structured",   \
               "unstructured", \
               "unstructured"/)

 plotlabs = (/"Str CardDeck",   \
              "Unstr CardDeck", \
              "Unstr Domain Decomp"/)
      rts = (/"atmwav_control_noaero_p8/",     \
              "atmwav_unstr_control_noaero_p8/", \
              "atmwav_pdlib_control_noaero_p8/"/)

  date = "2021-03-23-"
  time = "21600"
  fsrc = "ufs.atmw.ww3.hi."

  fnames = RT1+rts+fsrc+date+time+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"HS" , \
           "UAX", \
           "UAY"/)
  fldwgts = (/1., \
              1., \
              1./)
  lonname = "lon"
  latname = "lat"

  nflds = dimsizes(flds)
  nplots = dimsizes(gridtype)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    4.0,  0.05/)   ; hs
  plotlevs( 1,:) = (/ -20.0,   20.0,  0.50/)   ; uax
  plotlevs( 2,:) = (/ -20.0,   20.0,  0.50/)   ; vax

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time
  ;wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
   plottitle=flds(fldtoplot)

;************************************************
; define the map
;************************************************

  wkstype="X11"
						; wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)       ; send graphics to X11 window
  ; drawNDCGrid(wks)
  plot = new(3,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.35

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label

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

  resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008
; ***************************************************
;
; ***************************************************

      do ii = 0,nplots-1
        vname = flds(fldtoplot)
        gtype = gridtype(ii) 
        if (gtype .eq. "structured")then
        data = files[ii]->$vname$(0,:,:)
        data@lon2d = files[ii]->$lonname$(:,:)
        data@lat2d = files[ii]->$latname$(:,:)
      else
        data = files[ii]->$vname$(0,0,:)
        data@lon1d = files[ii]->$lonname$(0,:)
        data@lat1d = files[ii]->$latname$(0,:)
      end if      
      plot(ii) = subplot(ii,plotlabs(ii),gtype,data,levs,cmap)
      delete(data)
      end do

;************************************************
; make the panel
;************************************************

   gsn_panel(wks,plot,(/3,1/),resP)

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
