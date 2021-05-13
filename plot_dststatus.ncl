;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  hemi="NH"

  minlat = 85.0

  RT4 = "/glade/scratch/worthen/FV3_RT/testdatm/"

;************************************************
; read in netCDF file
;************************************************

  ;mapname="bilnr"
  mapname="bilnr_nstod"
  
   rtsrc = RT4+"gefs"+mapname+"/"

   gf =addfile(rtsrc+"MOM6_OUTPUT/ocean_geometry.nc","r")
   ;print(gf)
   tlatname="geolat"
   tlonname="geolon"

;************************************************
; ice
;************************************************

  varname="dststatus"
  levs=(/1.0, 8.0, 1.0/)

    icef = addfile(rtsrc+"dst.dststatus.atm.ice."+mapname+".nc","r")
  dstfld = icef->$varname$(:,:)
  dstfld@lon2d=gf->$tlonname$
  dstfld@lat2d=gf->$tlatname$

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,mapname)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillPalette        = "amwg256"              ; choose colormap

  res@tiMainString = mapname

;************************************************
;
;************************************************

  plot = gsn_csm_contour_map_polar(wks,dstfld,res)    ; create the plot

  draw(plot)
  frame(wks)

exit

end
