;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

     RT = "/glade/scratch/worthen/WaveUnstr/moddefs/"

     mskfile = "globa_1deg.msh.SCRIP.nc"
     fmsk = addfile(RT+mskfile,"r")
     vname="grid_imask"
     data = fmsk->$vname$
     vname="grid_center_lat"
     lats = fmsk->$vname$
     vname="grid_center_lon"
     lons = fmsk->$vname$
     data = toint(lons)
     levs = (/0,360,5/)
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
  res@mpFillOn             = True

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ;res@cnFillPalette   = "amwg"

  res@tiMainFontHeightF = .010
  res@tiMainString = "test"

  res@trGridType           = "TriangularMesh"  ; This is required to allow
                                               ; missing coordinates.
;************************************************
;
;************************************************

    res@sfXArray             = lons
    res@sfYArray             = lats
    res@gsnAddCyclic         = False

   plot = gsn_csm_contour(wks,data,res)    ; create the plot
   ;plot = gsn_csm_contour(wks,var1d_sort,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
