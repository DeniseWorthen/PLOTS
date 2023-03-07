;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

  ;RT		= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/atmwtrip/"
  ;MD            = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/moddefs3/"
  RT            = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/"
  MD            = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/"
  dirsrc        = "ATMW/base/"
  ;dirsrc = "CPLD/cd/"

  plotlab = (/"Unstr DomainDecomp, 5PE"/)

  dcmpfile = "emesh.decomp.nc"
  fdcmp = addfile(RT+dirsrc+dcmpfile,"r")
  vname = "decomp"
  var1d = fdcmp->$vname$
  vname = "dof"
  dof	= fdcmp->$vname$(:)
  ip	= dim_pqsort(dof,1)
  dmax  = max(var1d)
  ;var1d@lon1d   = fdcmp->coordx
  ;var1d@lat1d   = fdcmp->coordy
  levs		= (/1,1+dmax,1/)
  ;print(fdcmp)

  scrpfile   = "trip1degmask.SCRIP.nc"
     sfile	= addfile(MD+scrpfile,"r")
     x		= sfile->grid_center_lon
     y		= sfile->grid_center_lat
     cx		= sfile->grid_corner_lon
     cy		= sfile->grid_corner_lat
     ;printVarSummary(x)
     ;printVarSummary(cx)
     ;print(sfile)
     var1d_sort = var1d
     var1d_sort = var1d(ip)
     var1d      = var1d_sort
     ;printVarSummary(var1d)

     var1d@lon1d = x
     var1d@lat1d = y
     ;printVarSummary(var1d)

;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstitle="emesh.decomp"
  wkstype@wkWidth=1000
  wkstype@wkHeight=1000
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.35

  res@cnFillOn             = True            ; turn on color
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnLineLabelsOn       = False           ; turn off line labels
  ;res@cnLevelSpacingF      = 1               ; NCL chose 50 for this particular data
  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tiMainString         = dirsrc
  res@tiMainFont           = "helvetica"     ; default is helvetica-bold
  res@tiMainFontHeightF    = 0.02
  res@gsnLeftString        = ""
  res@gsnRightString       = ""

  ; ;res@cnFillMode = "MeshFill"
   res@cnFillMode = "RasterFill"

   res@gsnStringFontHeightF = 0.01
   res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
   ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
   ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
   ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  ;  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
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
   ;res@cnFillPalette    = "circular_2"
   res@cnFillPalette    = "cb_9step"

   res@tiMainFontHeightF = .010
   res@tiMainString = plotlab
   res@mpFillOn             = False

   res@cnFillPatterns       = (/17,17,17/) ; the patterns

  ; res@mpMinLatF            = -30      ; range to zoom in on
  ; res@mpMaxLatF            =  30.
  ; res@mpMinLonF            = -60.
  ; res@mpMaxLonF            =  30.

  res@sfXCellBounds = cx(:,0:5)
  res@sfYCellBounds = cy(:,0:5)

;************************************************
;
;************************************************

   res@gsnAddCyclic         = False

   plot = gsn_csm_contour(wks,var1d,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
