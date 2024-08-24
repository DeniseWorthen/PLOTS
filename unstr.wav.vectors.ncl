;**********************************************************
;
;**********************************************************
begin

     ;RT = "/glade/scratch/worthen/WaveUnstr/str3PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr/unstrnoland3PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr2/pdlib2PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr/pdlibnoland3PE/"
      RT = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/test/"

     filetype="wave history"
     ;filetype="wave coupler"

     polar="false"
     ;polar="true"
      minlat = 66.0
     ; zoom in
     ;minlat = 88.0
     ;minlat = 85.0
     vmag = 0.20
     vthn = 0.020

     if (filetype .eq. "wave history") then
       time="43200"
       fname = "ufs.atmw.ww3.hi.2021-03-22-"+time+".nc"
       f = addfile(RT+fname,"r")

       vname = "THM"
       levs = (/0.0, 1.00, 0.1/)

       data = f->$vname$(0,:,:)
       ;data = f->$vname$(0,0,:)
       data@lon2d = f->lon(:,:)
       data@lat2d = f->lat(:,:)
       print("plotting "+vname+" from "+RT+fname)
     end if
     printVarSummary(data)
     ;printVarSummary(f->lon)
 ; copy metadata
     uvec = data
     vvec = data
     uvec = cos(data)
     vvec = sin(data)
     print(uvec(0,1:10))
     if (polar .eq. "true") then
       uvec = where(data@lat2d .ge. minlat, -1.*uvec, data@_FillValue)
       vvec = where(data@lat2d .ge. minlat, -1.*vvec, data@_FillValue)
     end if
     ;uvec@lat1d = f->lat(:,:)
     ;uvec@lon1d = f->lon(:,:)
     ;vvec@lat1d = f->lat(:,:)
     ;vvec@lon1d = f->lon(:,:)
     ;printVarSummary(f->lat)
     printVarSummary(uvec)
     printVarSummary(vvec)
     if(1 .eq. 0) then
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="unstr.wave"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
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
  res@tiMainString = fname
  if (filetype .eq. "wave history") then
    res@sfElementNodes = f->nconn
    res@sfFirstNodeIndex = 1
    res@mpFillOn             = False
    res@mpOutlineOn          = False
    res@mpFillOn             = False
  else
    res@mpFillOn             = True
    res@mpOutlineOn          = True
  end if

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

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10              ; size of ref vector
  ;res@vcMonoLineArrowColor  = True             ; multiple colors desired
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  res@vcGlyphStyle          = "CurlyVector"

;************************************************
; add coord marks
;************************************************

  mkres = True
  mkres@gsMarkerSizeF = 2.
  mkres@gsnFrame        = False
  mkres@gsnDraw         = False
  mkres@gsnCoordsAttach = True

  ;mkres@gsnCoordsMaxLat = 80.0
  ;mskdata=data
  ;printVarSummary(mskdata)
  ;mskdata=where(data@lat1d .ge. 80, data@_FillValue, data)
  ;npole=mask(data,mskdata,0.0)
  ;npole@lat1d=f->lat(0,:)
  ;npole@lon1d=f->lon(0,:)
;************************************************
;
;************************************************

  ;mskdata = data
  ;mskdata = where(mskdata@lat1d .le. 89.0, mskdata, mskdata@_FillValue)
  ;data = mskdata

    res@gsnAddCyclic         = False

    if(polar .eq. "true")then
      plot = gsn_csm_vector_map_polar(wks,uvec,vvec,res)    ; create the plot
      ;gsn_coordinates(wks,plot,data,mkres)
    else
      plot = gsn_csm_vector_map(wks,uvec,vvec,res)    ; create the plot
    end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

  end if
exit
end
