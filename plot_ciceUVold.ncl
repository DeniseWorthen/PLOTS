;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

  load "unstaggerCICE5.ncl"
;************************************************
;
;************************************************

   hemi="NH"
   batch="no"

  model = "m6c5"
  ;model = "hycice5"

   rad2deg=180.d0/acos(-1.0d0)
   ;vmag = 0.80
   vmag = 0.12
   ;vthn = 0.01
   ;vmag = 0.20
   ;vthn = 0.005

;************************************************
; like CICE_CAP
;************************************************
function rot2ew(u,v,ang,mode)
begin
  if(mode .eq. 1)then
   ;uvrot=u
   uvrot=tofloat( cos(ang)*u - sin(ang)*v)
  end if
  if(mode .eq. 2)then
   ;uvrot=v
   uvrot=tofloat( sin(ang)*u + cos(ang)*v)
  end if
  return(uvrot)
end
;************************************************
; read in netCDF file
;************************************************

  if(model .eq. "hycice5")then
     rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/CICE002/"
   nemsdir="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
   ; dirsrc1="history/iceh."
    dirsrc="history/iceh_24h."
   ; load the grid file
   gf =addfile(nemsdir+"cice_grid_024.nc","r")
  end if

  if(model .eq. "m6c5")then
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Bin.Li/post400/rtgen.11643/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/nofixfrzmlt_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/fixfrzmlt_delT_MLD/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/fixfrzmlt_delT_MLD_new/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/nofixfrzmlt_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_MLD_35d/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/no_mods_on_lons/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
   rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.29029/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"

   ; use one file for grid

   ; these contain the grid in degrees!
   gf =addfile(rtsrc+"history/iceh_ic.2016-10-03-00000.nc","r")
   ; no coversion between radians and degrees
   rfactor = 1.0
   ;print(gf)

   dirname=rtsrc+"history/"
   print(dirname)
  end if

   iceulonname="ULON"
   iceulatname="ULAT"
   icetlonname="TLON"
   icetlatname="TLAT"
      aicename="aice_h"
      uicename="uvel_h"
      vicename="vvel_h"

  plottitle=rtsrc+"~C~"+uicename+"  "+vicename
;************************************************
; ice
;************************************************
  lstep=1-1

  ;cyear=2015
  ;cday=cyear+"-10-30"

  cyear=2016
  ;cday=cyear+"-11-07-00000"
  ;cday=cyear+"-10-16-00000"
  ;cday=cyear+"-10-03-64800"
  ;cday=cyear+"-07"
  cday=cyear+"-10-05-00000"
  ;cday=cyear+"-04-01-21600"
  ;cday=cyear+"-04-01-43200"
  print("day = "+cday)

  ; load the file and the variable
  icef =addfile(dirname+"iceh_06h."+cday+".nc","r")
  ;icef =addfile(dirname+"iceh."+cday+".nc","r")

  tarea = icef->tarea
  uarea = icef->uarea
  ; in radians, on t-grid
  rotang = icef->ANGLET

  uvar=icef->$uicename$(lstep,:,:)
  vvar=icef->$vicename$(lstep,:,:)
  avar=icef->$aicename$(lstep,:,:)

  ;avar@units=" "
  ;uvar@units=" "
  ;vvar@units=" "
  ;avar@long_name=" "

  avar@lon2d=icef->$icetlonname$*rfactor
  avar@lat2d=icef->$icetlatname$*rfactor
  uvar@lon2d=icef->$iceulonname$*rfactor
  uvar@lat2d=icef->$iceulatname$*rfactor
  vvar@lon2d=icef->$iceulonname$*rfactor
  vvar@lat2d=icef->$iceulatname$*rfactor

  ut = unstaggerCICE5(uvar,uarea,tarea)
  vt = unstaggerCICE5(vvar,uarea,tarea)
  ut@lon2d = icef->$icetlonname$*rfactor
  ut@lat2d = icef->$icetlatname$*rfactor
  vt@lon2d = icef->$icetlonname$*rfactor
  vt@lat2d = icef->$icetlatname$*rfactor

  urot = ut
  vrot = vt
  urot = rot2ew(ut,vt,rotang,1)
  vrot = rot2ew(ut,vt,rotang,2)
 
  levs = (/-0.1,0.1,0.01/)
  ;levs = (/0.85,0.95,0.005/)
;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

 if(model .eq. "m6c5")then
   lon1=60.00
   lon2=-120.00
   lat1=60
   lat2=60
  end if
  if(model .eq. "hycice")then
   lon1=74.12
   lon2=-105.88
   lat1=60
   lat2=60
  end if

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice_uv")              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@cnFillMode         = "RasterFill"

  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010
  res@gsnScalarContour  = True                  ; vectors over scalars

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10             ; size of ref vector
  ;res@vcMonoLineArrowColor  = True             ; multiple colors desired
  ;res@vcMinDistanceF        = 0.01              ; thins arrows near pole
  ;res@vcMinDistanceF        = vthn              ; thins arrows near pole
  ;res@vcGlyphStyle          = "CurlyVector"
  ;res@vcPositionMode = "ArrowTail"

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   ;res@mpMinLatF    =  66                          ; minimum lat to plot
   ;res@mpMinLatF    =  70                          ; minimum lat to plot
   res@mpMinLatF    =  89.2                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnLevelSelectionMode        = "ExplicitLevels"
  ;res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
  ;res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  ;res@cnFillPalette               = "WhBlGrYeRe"             ; choose colormap

  res@tiMainString = plottitle
  res@tiMainFontHeightF = .010

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

  plot = gsn_csm_vector_scalar_map_polar(wks,urot,vrot,avar,res)    ; create the plot
  plot = gsn_csm_vector_map_polar(wks,ut,vt,res)    ; create the plot
  ;plot = gsn_csm_contour_map_polar(wks,vrot,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)

exit
end
