;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  ;rtsrc = "RTs/rtgen.39967/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
  ;rtsrc = "BM2_bm2/allfixed_12hr_async/tmp/cpld_fv3_384_mom6_cice_2d_bm2/"
  rtsrc = "BM2_bm2/rtgen.103674/tmp/cpld_fv3_384_mom6_cice_2d_bm2/"

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"

  if(hemi .eq. "none")then
   minlon = 120.0
   maxlon = 240.0
   minlat =  -30.0
   maxlat =   30.0
  end if

;************************************************
;
;************************************************

  model = "fv3_cap_export_"
  field = "mean_prec_rate"

  lon = fspan(0.0,360.0,1440)
  lat = fspan(-90.0,90.0,721)
  lon@units = "degrees_east"
  lat@units = "degrees_north"
  ;lat!0 = "lat"
  ;lon!1 = "lon"

  afile=addfile(RT4+rtsrc+model+field+".nc","r")
  print(rtsrc+model+field)

  lbeg=49-1
  lend=96-1
  avar=dim_avg_n_Wrap(afile->$field$(lbeg:lend,:,:),0)
  avar!0 = "lat"
  avar!1 = "lon"
  avar&lat = lat
  avar&lon = lon
 
  ;prate
  avar = avar*3600.0 ;(prate unit = kg/m2 s; equiv to mm/s; mult by 3600 mm/hr))
  avar@long_name = "prate_ave*3600.0"
  ;avar = avar*3600.0*1000.0 ;(prate unit = kg/m2 s; equiv to mm/s; mult by 3600 mm/hr))
  ;avar@long_name = "mean_prec_rate*3600*1000.0"
  ;avar@units = "mm/hr"
  levs = (/0.0,2.00,.10/)

  plottitle=rtsrc+model+field+".nc  "

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,model+field)              ; send graphics to X11 window


  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF = -45
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = -50                            ; minimum lat to plot
    res@mpCenterLonF = 0.0
   end if
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         = (maxlon - minlon)/2.0
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,avar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

exit
end
