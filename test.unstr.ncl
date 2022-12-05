;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin
     RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/unstr3PE/"
     MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/moddefs3/"

     scrpfile = "no_land_CardDeck.SCRIP.nc"
     sfile = addfile(MD+scrpfile,"r")
     x = sfile->grid_center_lon
     y = sfile->grid_center_lat
     cx = sfile->grid_corner_lon
     cy = sfile->grid_corner_lat
     x@long_name = "longitude"
     y@long_name = "latitude"
     cx@long_name = "longitude"
     cy@long_name = "latitude"
     printVarSummary(x)
     printVarSummary(cx)

        time="25200"
        f = addfile(RT+"ufs.atmw.ww3.hi.2021-03-22-"+time+".nc","r")
        print(RT+"ufs.atmw.ww3.hi.2021-03-22-"+time+".nc")
        ;vname = "UAX"
        ;levs = (/-20,20,1.0/)

        ;vname = "DW"
        ;levs = (/0,8000.0,500.0/)

        ;vname = "HS"
        ;levs = (/0,.30,.02/)

        vname = "USTX"
        levs = (/-1.,1.,0.1/)

        data = f->$vname$(0,0,:)
        data@lon1d = f->lon(0,:)
        data@lat1d = f->lat(0,:)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="test"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

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
  ;res@cnFillPalette   = "BlWhRe"
  res@cnFillPalette    = "NCV_jet"
  res@tiMainFontHeightF = .010
  res@tiMainString = "test"

 ; res@mpFillOn             = False
 ; res@sfXArray             = x
 ; res@sfYArray             = y
 ; res@SfXCellBounds = cx(:,0:5)
 ; res@SfYCellBounds = cy(:,0:5)
;************************************************
;
;************************************************

    res@gsnAddCyclic         = True

   plot = gsn_csm_contour_map(wks,data,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
