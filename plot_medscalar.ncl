;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  rtname = "DATM"
  rtsrc= RT2+rtname+"/rtgen.142036/tmp/cpld_datm_mom6_cice_cold/"

;************************************************
;
;************************************************

  grid  = "ocn"
  ;field = "_grid_corner2"
  ;fname = "lat_corner"
 ;  levs = (/-100.0,100.0,2.0/)
  ; levs = (/88.0,90.0,0.1/)

  lonfile=addfile(rtsrc+"array_med_"+grid+"_grid_coord1.nc","r")
  latfile=addfile(rtsrc+"array_med_"+grid+"_grid_coord2.nc","r")
  ;lonfile=addfile(RT2+rtsrc+"array_med_"+grid+"_grid_corner1.nc","r")
  ;latfile=addfile(RT2+rtsrc+"array_med_"+grid+"_grid_corner2.nc","r")
  ; mediator field
  field = "med_to_ocn"
  fname = "mean_net_sw_vis_dif_flx"
   levs = (/0.0,200.0,20.0/)
  tfile=addfile(rtsrc+"field_"+field+"_"+fname+".nc","r")

  ; pick time step; arrays are 0 based
  lstep=3-1

  ;tvar=tfile->$fname$(:,:)
  tvar=tfile->$fname$(lstep,:,:)
  printVarSummary(tvar)
  tvar@lon2d=lonfile->lon_center
  tvar@lat2d=latfile->lat_center
  ;tvar@lon2d=lonfile->lon_corner
  ;tvar@lat2d=latfile->lat_corner

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,field+"_"+fname)              ; send graphics to X11 window

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

  ;res@gsnPolar   =  "NH"
  ;res@mpMinLatF    =  88                          ; minimum lat to plot
  ;res@mpCenterLonF = -45
 
  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette   =  "WhBlReWh"                      ; choose colormap
  ;res@cnFillPalette   =  "BlWhRe"                      ; choose colormap
  res@cnFillPalette   =  "BlueDarkRed18"                      ; choose colormap

  plot = gsn_csm_contour_map(wks,tvar,res)    ; create the plot
 ; plot = gsn_csm_contour_map_polar(wks,tvar,res)    ; create the plot

  draw(plot)
  frame(wks)
exit
end
