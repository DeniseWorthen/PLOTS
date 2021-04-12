; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
;
;************************************************

  lstep=0

  tlonname = "lonCt"
  tlatname = "latCt"

  res = "mx100"
  rtsrc= "/scratch2/NCEPDEV/climate/Denise.Worthen/grids-20210223/"
  gfile = "tripole"
  afile = addfile(rtsrc+gfile+"."+res+".nc","r")
  plottitle=res+" Area"
  print(rtsrc+gfile+"."+res+".nc")

  palette="amwg256"
  aname = "area"
  levs=(/0.0,140.,5./)

  avar = afile->$aname$(:,:)
  ;avar = avar/1.0d8
  avar@lon2d = afile->$tlonname$(:,:)
  avar@lat2d = afile->$tlatname$(:,:)
  printVarSummary(avar)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="area_"+gfile
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill
  res@cnFillPalette            = palette

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@mpMaxLatF    = -50                            ; minimum lat to plot
  ;res@mpCenterLonF = 0.0

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
;
;************************************************


   plot= gsn_csm_contour_map(wks,avar,res)    ; create the plot

  draw(plot)
  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x20 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if
exit
end
