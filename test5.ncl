;**********************************************************
;
;**********************************************************
begin

     ;RT = "/glade/scratch/worthen/WaveUnstr/str3PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr/unstrnoland3PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr2/pdlib2PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr/pdlibnoland3PE/"
      RT = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/base.noresmP/"

     ;polar="false"
     polar="true"
     ; minlat = 66.0
     ; zoom in
     minlat = 89.0
     ;minlat = 80.0

     ff = addfile(RT+"mesh.wise.tnx1v4p.100k.nc","r")

     data=ff->elementMask
     lon=ff->nodeCoords(0,:)
     lat=ff->nodeCoords(0,1)

     lon@units="degrees_east"
     lat@units="degrees_north"
     data@lon1d=lon
     data@lat1d=lat

     data=1
     levs = (/0,1,1/)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="unstr.wave"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                 ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@cnMonoLineColor  = False
  res@lbLabelBarOn      = True
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ;res@cnFillPalette   = "amwg"
  ;res@cnFillPalette   = "MPL_rainbow"
  res@cnFillPalette   = "WhiteBlueGreenYellowRed"
  ;res@cnFillPalette    = "cb_9step"
  res@tiMainFontHeightF = .010
  res@tiMainString = "test"
  ;if (filetype .eq. "wave history") then
    res@sfElementNodes = ff->elementConn
    res@sfFirstNodeIndex = 1
    res@mpFillOn             = False
    res@mpOutlineOn          = False
    res@mpFillOn             = False
  ;else
  ;  res@mpFillOn             = True
  ;  res@mpOutlineOn          = True
  ;end if

  if(polar .eq. "true")then
    res@mpMinLatF    =  minlat                    ; minimum lat to plot
    res@mpCenterLonF = -45
    res@gsnPolar   =  "NH"                        ; specify the hemisphere
  else
    res@vpWidthF          = 0.70
    res@vpHeightF         = 0.40
  end if

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            =  0.
  ;res@mpMinLonF            = -90.
  ;res@mpMaxLonF            = -70.

;************************************************
;
;************************************************

    res@gsnAddCyclic         = False

    if(polar .eq. "true")then
      plot = gsn_csm_contour_map_polar(wks,data,res)    ; create the plot
      mkres = True
      mkres@gsMarkerSizeF = 5.
      mkres@gsnFrame        = False
      mkres@gsnDraw         = False
      mkres@gsnCoordsAttach = True
      gsn_coordinates(wks,plot,data,mkres)
    else
      plot = gsn_csm_contour_map(wks,data,res)    ; create the plot
    end if

;---Draw the triangular mesh
;  lnres = True
;  lnres@gsnCoordsMeshVerticesOnCell     = f->nconn
;  lnres@gsnCoordsMeshLatVertices        = f->lat(0,:)
;  lnres@gsnCoordsMeshLonVertices        = f->lon(0,:)
;  lnres@gsnCoordsMeshVerticesStartIndex = 1

;  lnres@gsLineColor                     = "White"

;  gsn_coordinates(wks,plot,data,lnres)

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
