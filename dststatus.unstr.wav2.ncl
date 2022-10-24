;**********************************************************
;  
load "dststatus_counts.ncl"
;**********************************************************
begin
  RT            = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/"
  ;dirsrc        = "unstrnoland3PE/"
  ;plotlab       = "unstr noland"
  ;dirsrc        = "pdlibnoland3PE/"
  ;plotlab       = "pdlib noland"
  dirsrc        = "tripnoland/"
  plotlab       = "pdlib noland tripole"

   nl		= str_get_nl()
   nflags	= 9
  ;dstfile	= "dststatus.atm.wav.bilnr_nstod.nc"
  dstfile       = "dststatus.ocn.wav.bilnr_nstod.nc"
  fdst		= addfile(RT+dirsrc+dstfile,"r")   
  print("plotting file "+RT+dirsrc+dstfile)
  vname		= "dststatus"
  var1d		= fdst->$vname$(:)
  levs          = (/0,9,1/)

  do i = 0,nflags-1
   ret = dststatus_counts(var1d,i)
  end do

  doffile       = "dof.wav.nc"
    fdof        = addfile(RT+dirsrc+doffile,"r")
    vname       = "dof"
      dof       = fdof->$vname$(:)
       ip       = dim_pqsort(dof,1)

     ;scrpfile  = "with_land_CardDeck.SCRIP.nc"
     ;scrpfile  = "no_land_CardDeck.SCRIP.nc"
     scrpfile   = "trip1deg_noland.SCRIP.nc"
     sfile      = addfile(RT+"moddefs3/"+scrpfile,"r")
     x          = sfile->grid_center_lon
     y          = sfile->grid_center_lat
     cx         = sfile->grid_corner_lon
     cy         = sfile->grid_corner_lat
     ;printVarSummary(x)
     ;printVarSummary(cx)

     var1d_sort = var1d
     var1d_sort = var1d(ip)
     var1d      = var1d_sort
     ;printVarSummary(var1d)

     var1d@lon1d = x
     var1d@lat1d = y

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
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
  res@tiMainString = plotlab+":  "+dstfile

  res@mpOutlineOn          = True
  res@mpFillOn             = False
  res@gsnAddCyclic         = True

  res@sfXCellBounds = cx(:,0:5)
  res@sfYCellBounds = cy(:,0:5)

;************************************************
;
;************************************************

  ;plot = gsn_csm_contour_map(wks,var1d,res)    ; create the plot
  plot = gsn_csm_contour(wks,var1d,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
