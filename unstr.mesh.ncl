;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

  RT		= "/glade/derecho/scratch/worthen/ptout/"
  dirsrc        = "base.pdlib/"

  dcmpfile	= "emesh.decomp.nc"
  fdcmp		= addfile(RT+dirsrc+dcmpfile,"r")
  vname		= "decomp"
  var1d		= fdcmp->$vname$
  ;var1d@lon1d	= fdcmp->coordx
  ;var1d@lat1d	= fdcmp->coordy
  levs		= (/1,30,1/)

      dof	= fdcmp->$vname$(:)
       ip	= dim_pqsort(dof,1)

     scrpfile	= "exp.wise.global_270k.SCRIP.nc"
     sfile	= addfile(RT+"mod_defs/"+scrpfile,"r")
     x		= sfile->grid_center_lon
     y		= sfile->grid_center_lat
     cx		= sfile->grid_corner_lon(:,0::2)
     cy		= sfile->grid_corner_lat(:,0::2)
     ;printVarSummary(cx)
     ; x@units	= "degrees_east"
     ; y@units	= "degrees_north"
     ; cx@units	= "degrees_east"
     ; cy@units	= "degrees_north"

     var1d@lon1d = x
     var1d@lat1d = y

     var1d_sort = var1d
     var1d_sort = var1d(ip)
     var1d      = var1d_sort
     printVarSummary(var1d)

     ;var1d@lon1d = x
     ;var1d@lat1d = y

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="test"
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
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
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
  res@tiMainString = dirsrc
  res@mpFillOn             = False

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            =  30.
  ;res@mpMinLonF            = -60.
  ;res@mpMaxLonF            =  30.

  res@SfXCellBounds = cx
  res@SfYCellBounds = cy

;************************************************
;
;************************************************

   res@gsnAddCyclic         = False

   plot = gsn_csm_contour_map(wks,var1d,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
