;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

   rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008_io/"
   nemsdir="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
   compset=""
   ; load the grid file
   gf =addfile(nemsdir+"cice_grid_024.nc","r")
   rad2deg=180.d0/acos(-1.0d0)
   tlatname="tlat"
   tlonname="tlon"
   rfactor=rad2deg
   dirname=rtsrc+"history/"
   lon1=74.12
   lon2=-105.88
   lat1=60
   lat2=60

   levs=(/0.70,0.80,.005/)
;************************************************
; ice
;************************************************

  hemisphere = "NH"
  ;hemisphere = "SH"

  year="2015-07-"
  daylist=ispan(2,31,1)
  cday=sprinti("%02i", daylist)

   filelist = dirname+"iceh_inst."+year+cday+"-00000.nc"
  print(filelist)

   icef =addfiles(filelist,"r")

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice")              ; send graphics to X11 window

  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = True
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"

  if(hemisphere .eq. "NH")then
   res@gsnPolar      = "NH"                          ; specify the hemisphere
  ; res@mpMinLatF     =  60                            ; minimum lat to plot
   res@mpMinLatF     =  78                            ; minimum lat to plot
   res@mpCenterLonF  = -45
  else
   res@gsnPolar   = "SH"                          ; specify the hemisphere
   res@mpMaxLatF  = -50                            ; minimum lat to plot
  end if

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette        = "BlWhRe"              ; choose colormap
  ;res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap
  ;res@cnFillPalette        = "NCV_roullet"              ; choose colormap

  res@tiMainFontHeightF = .02

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
;
;************************************************

  icevar=icef[:]->aice_h(:,:,:)
  icevar@lon2d=gf->$tlonname$*rfactor
  icevar@lat2d=gf->$tlatname$*rfactor
  icevar@units=""
  icevar@long_name=""

  plotvar = dim_min_n_Wrap(icevar,0)

    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  
        ii = 0
  ;plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
  plot(ii) = gsn_csm_contour_map_polar(wks,plotvar,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)
exit
end
