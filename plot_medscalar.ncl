;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ;rtname = "mx025cfsr_nstod"
  ;plottitle = "mapconsf_nstod"

  ;rtname = "mx025cfsr_bilin_nstod"
  ;plottitle = "mapbilin_nstod"

  rtname = "mx025cfsr_bilin"
  plottitle = "mapbilin"

  rtsrc = RT2+"FV3_RT/datm_bilin/"+rtname
  grsrc = "/scratch2/NCEPDEV/climate/Denise.Worthen/grids-20210223/"
;************************************************
;
;************************************************

   grfile = addfile(grsrc+"tripole.mx025.nc","r")
  latname = "latCt"
  lonname = "lonCt"
  ; mediator field
  field = "iceExp_Sa_tbot"
  fname = "DATM_CFSR.cpl.hi.2011-10-01-03600.nc"
  levs = (/250.0,270.0,0.5/)
;   levs = (/220.0,280.0,2.0/)
  tfile=addfile(rtsrc+"/"+fname,"r")
  print(rtsrc+"/"+fname)

  tvar=tfile->$field$(0,:,:)
  ;printVarSummary(tvar)
  tvar@lon2d=grfile->$lonname$
  tvar@lat2d=grfile->$latname$

;************************************************
; define the map
;************************************************
  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wkstitle=plottitle+"_"+field
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn = False

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  res@gsnPolar   =  "NH"
  res@mpMinLatF    =  88                          ; minimum lat to plot
  res@mpCenterLonF = -45
 
  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette   =  "WhBlReWh"                      ; choose colormap
  ;res@cnFillPalette   =  "BlWhRe"                      ; choose colormap
  ;res@cnFillPalette   =  "BlueDarkRed18"                      ; choose colormap
  ;res@cnFillPalette   =  "BlueWhiteOrangeRed"
  res@cnFillPalette   =  "amwg256"

  ;cmap = read_colormap_file("amwg256")
  ;ncolors =
  ;colors = gsn_retrieve_colormap(wks)
  ;print(colors)
  ;colors(2,:) = (/ .80, .80, .80 /)
  ;gsn_draw_colormap(wks)

  ;gsn_define_colormap(wks,colors)
  res@tiMainString = plottitle
 ; plot = gsn_csm_contour_map(wks,tvar,res)    ; create the plot
  plot = gsn_csm_contour_map_polar(wks,tvar,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if
exit
end
