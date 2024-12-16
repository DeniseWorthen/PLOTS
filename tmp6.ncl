;**********************************************************
;
load "dststatus_counts.ncl"
;**********************************************************
begin
   RT = "/work2/noaa/stmp/dworthen/stmp/dworthen/ww3pio/datm.270k/"
   nl		= str_get_nl()
   nflags	= 9
   fdst = addfile(RT+"datm.gefs.dststatus.nc","r")
   ;fmsh = addfile("/work2/noaa/stmp/dworthen/stmp/dworthen/dststat/exp.global_270k.SCRIP.nc","r")
   ;fmsh = addfile("/work/noaa/nems/dworthen/msh2scrip/global_270k_with_mom6mask.msh.SCRIP.nc","r")
   ;fmsh = addfile(RT+"emesh.decomp.nc","r")
   fmsh = addfile(RT+"datm.gefs.ww3.hi.2011-10-01-03600.nc","r")

  lonname = "dstwav_lon"
  latname = "dstwav_lat"
  vname = "dstwav_ocn_wav_bilnr_nstod"
  var1d = fdst->$vname$(0,:)
  printVarSummary(var1d)
  var1d@lon1d = fdst->$lonname$(0,:)
  var1d@lat1d = fdst->$latname$(0,:)

levs = (/0,9,1/)
  plotlab="test"
  do i = 0,nflags-1
   ret = dststatus_counts(var1d,i)
  end do

    ; x          = fmsh->grid_center_lon
    ; y          = fmsh->grid_center_lat
    ; cx         = fmsh->grid_corner_lon
    ; cy         = fmsh->grid_corner_lat
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
  res@tiMainString = plotlab

  res@mpOutlineOn          = True
  res@mpFillOn             = False
  res@gsnAddCyclic         = True

  ;res@sfXCellBounds = cx(:,0:5)
  ;res@sfYCellBounds = cy(:,0:5)

  ;res@sfXCellBounds = cx
  ;res@sfYCellBounds = cy

  res@sfElementNodes = fmsh->nconn
  res@sfFirstNodeIndex = 1

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
