;======================================================================
; geo_1.ncl
;
; Concepts illustrated:
;   - Plotting data on a geodesic mesh
;   - Setting the cell bounds for an unstructured mesh
;   - Drawing the geodesic mesh and cell centers using gsn_polyline and gsn_polymarker
;======================================================================
; See geo_1_660.ncl for an example on how gsn_coordinates can be used
; in NCL V6.6.0 to draw unstructured meshes.
;======================================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; This grid came to us via Dave Randall, Todd Ringler, and Ross Heikes
; of CSU. The data for this mesh were originally downloaded from:
; http://kiwi.atmos.colostate.edu/BUGS/geodesic/interpolate.html
;
  RT            = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/"
  ;dirsrc        = "unstr3PE/"
  dirsrc        = "unstrnoland3PE/"

  dcmpfile      = "emesh.decomp.nc"
  fdcmp         = addfile(RT+dirsrc+dcmpfile,"r")
  vname         = "decomp"
  data          = fdcmp->$vname$
  data@lon1d   = fdcmp->coordx
  data@lat1d   = fdcmp->coordy
  levs          = (/0,4,1/)

  doffile       = "dof.wav.nc"
    fdof        = addfile(RT+dirsrc+doffile,"r")
    vname       = "dof"
      dof       = fdof->$vname$(:)
       ip       = dim_pqsort(dof,1)

     ;scrpfile  = "with_land_CardDeck.SCRIP.nc"
     scrpfile   = "no_land_CardDeck.SCRIP.nc"
     sfile      = addfile(RT+"moddefs3/"+scrpfile,"r")
     x          = sfile->grid_center_lon
     y          = sfile->grid_center_lat
     cx         = sfile->grid_corner_lon
     cy         = sfile->grid_corner_lat
     ; x@units  = "degrees_east"
     ; y@units  = "degrees_north"
     ; cx@units = "degrees_east"
     ; cy@units = "degrees_north"

     var1d_sort = data
     var1d_sort = data(ip)
     ;data       = var1d_sort

     ;data@lon1d = x
     ;data@lat1d = y
     ;printVarSummary(data)

  dims  = dimsizes(cx)
  ncell = dims(0)          ; 2562
  nvert = dims(1)          ; 6

  wks = gsn_open_wks("X11","geo")            ; send graphics to PNG file

  res                      = True            ; plot mods desired
  res@gsnMaximize          = True            ; largest plot possible
  res@gsnDraw              = False           ; do not draw until the end
  res@gsnFrame             = False           ; do not automatically advance 'frame'

  ;res@cnFillDrawOrder      = "PreDraw"       ; draw contours first
  res@cnFillOn             = True            ; turn on color
  res@cnFillPalette        = "gui_default"   ; set color map
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnLineLabelsOn       = False           ; turn off line labels

  res@mpFillOn             = False
  
  ;res@sfDataArray = data
;---These resources define the cell centers and cell vertices
  ;res@sfXArray             = x
  ;res@sfYArray             = y
  ;res@sfXCellBounds        = cx
  ;res@sfYCellBounds        = cy

  res@lbTitleString        = "test"
  res@lbTitleFontHeightF   = 0.018
  res@lbLabelFontHeightF   = 0.008
  res@lbLabelAutoStride    = False
  res@pmLabelBarHeightF    = 0.08

  map = gsn_csm_contour_map(wks,data,res)
  draw(map)
  frame(wks)
end