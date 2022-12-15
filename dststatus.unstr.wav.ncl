;**********************************************************
  
load "dststatus_counts.ncl"
;**********************************************************
begin
     RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/"
     
   nl = str_get_nl()
   nflags = 9
   dirs = (/"unstr3PE/"/)
     fsrc = "dststatus.atm.wav.bilnr_nstod.nc"
   ;fsrc = "dststatus.atm.wav.nstod_consf.nc"

  doffile = "dof.wav.nc"
    vname = "dststatus"
     levs = (/0,9,1/)

     scrpfile = "no_land_CardDeck.SCRIP.nc"
     sfile = addfile(RT+"moddefs3/"+scrpfile,"r")
     x = sfile->grid_center_lon
     y = sfile->grid_center_lat
     cx = sfile->grid_corner_lon
     cy = sfile->grid_corner_lat
     x@units = "degrees_east"
     y@units = "degrees_north"
     cx@units = "degrees_east"
     cy@units = "degrees_north"
     ;printVarSummary(x)
     
  ndirs = dimsizes(dirs)

;**********************************************************
;
;**********************************************************

do nd = 0,ndirs-1
  dirsrc = RT+dirs(nd)
   ifile = fsrc

  fname = dirsrc+ifile
  print("input file "+fname)
  ff = addfile(fname,"r")

  var1d = ff->$vname$(:)
  ;printVarSummary(var1d)
  do i = 0,nflags-1
   ret = dststatus_counts(var1d,i)
  end do

  ; get the index seq to resort
  doff = addfile(dirsrc+doffile,"r")
  dof = doff->dof(:)
  print(dof(0:9))

  ip = dim_pqsort(dof,1)
  var1d_sort=var1d
  var1d_sort=var1d(ip)

  ;data = var1d
  data = var1d_sort
  data@lon1d = x
  data@lat1d = y
  printVarSummary(data)
  print(x(0:9)+"   "+y(0:9))

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle=vname
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
  res@cnFillPalette   = "amwg"

  res@tiMainFontHeightF = .010
  res@tiMainString = fsrc

  res@mpOutlineOn          = True
  res@mpFillOn             = False
  res@gsnAddCyclic         = True

  res@sfXCellBounds = cx
  res@sfYCellBounds = cy

;************************************************
;
;************************************************

  ;plot = gsn_csm_contour_map(wks,data,res)    ; create the plot
  plot = gsn_csm_contour(wks,data,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

end do  ; ndirs

exit
end
