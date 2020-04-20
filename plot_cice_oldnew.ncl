;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************
function setlevsmaps(name)
begin

         levs = new((/3/),float)
         cmap = new((/1/),string)
    latent_levs=(/ -30.00,    30.00,  2.000/)
     ; sens_levs=(/ -20.00,    20.00,  1.000/) 
      sens_levs=(/   0.00,    40.00,  1.000/) 
      ;evap_levs=(/  -0.2,     0.2,  0.02/) 
      evap_levs=(/  -0.5,     0.5,  0.05/) 
      lwup_levs=(/-300.00,     0.00, 10.000/)
      dswf_levs=(/ 220.00,   400.00,  5.000/)
      dlwf_levs=(/ 200.00,   300.00,  5.000/)
   topmelt_levs=(/   0.00,     6.50,  0.100/)
   botmelt_levs=(/   0.00,     4.00,  0.100/)
      tsfc_levs=(/ -30.00,     0.00,  1.000/)
      snow_levs=(/   0.00,     1.00,  0.050/)
      tair_levs=(/ -20.00,    10.00,  0.500/)
       alb_levs=(/  10.00,    60.00,  2.000/)
       ice_levs=(/   0.90,     1.00,  0.005/)
        hi_levs=(/   0.00,     4.00,  0.500/)
   ;     hi_levs=(/   2.00,     4.00,  0.200/)
    ; fpond_levs=(/   0.00,     1.00,  0.100/)
     fpond_levs=(/   0.00,     0.10,  0.010/)
     ;hpond_levs=(/   0.00,     0.30,  0.020/)
     ;hpond_levs=(/   0.00,     0.10,  0.010/)
     hpond_levs=(/   0.00,     0.05,  0.005/)
    frzmlt_levs=(/  -2.00,     2.00,  0.200/)
       sst_levs=(/  -1.80,    -1.20,  0.010/)

   ; default
    cmap = "MPL_rainbow"

   if(name .eq. "Evapi" .or. name .eq. "evap_ai")then
    levs = evap_levs
    cmap = "BlWhRe"
   end if
   if(name .eq. "Lhflxi" .or. name .eq. "flat_ai")then
    levs = latent_levs
    cmap = "BlWhRe"
   end if
   if(name .eq. "Shflxi" .or. name .eq. "fsens_ai")then
    levs = sens_levs
    ;cmap = "BlWhRe"
   end if
   if(name .eq. "Lwupice" .or. name .eq. "flwup_ai")then
    levs = lwup_levs
    cmap = "MPL_rainbow"
   end if
   if(name .eq. "Dswrf" .or. name .eq. "fswdn")then
    levs = dswf_levs
   end if
   if(name .eq. "Dlwrf" .or. name .eq. "flwdn")then
    levs = dlwf_levs
   end if
   if(name .eq. "meltt" .or. name .eq. "Ai_water")then 
    levs = topmelt_levs
   end if
   if(name .eq. "meltb" .or. name .eq. "Io_water")then 
    levs = botmelt_levs
   end if
   if(name .eq. "Tsfc" .or. name .eq. "Sfc_temp")then
    levs = tsfc_levs
   end if
   if(name .eq. "hs" .or. name .eq. "Snow_thick")then
    levs = snow_levs
   end if
   if(name .eq. "Tair" .or. name .eq. "T2m")then
    levs = tair_levs
   end if
   if(name .eq. "albsni" .or. name .eq. "Sfcalb")then
    levs = alb_levs
   end if
   if(name .eq. "aice" .or. name .eq. "Ice_conc")then
    levs = ice_levs
    cmap = "WhBlGrYeRe"
   end if
   if(name .eq.   "hi" .or. name .eq. "Ice_thick")then
    levs = hi_levs
    cmap = "WhBlGrYeRe"
   end if
   if(name .eq. "apond_ai" .or. name .eq. "apeff_ai")then
    cmap = "NCV_jet"
    levs = fpond_levs
   end if
   if(name .eq. "hpond_ai")then
    cmap = "WhBlGrYeRe"
    levs = hpond_levs
   end if
   if(name .eq. "frzmlt")then
    levs = frzmlt_levs
    cmap = "BlWhRe"
   end if
   if(name .eq. "sst")then
    levs = sst_levs
   end if

   ;print(name+"  "+levs)
   print(name+"  "+levs)
   return( [/levs,cmap/])
end

begin
;************************************************
; read in netCDF file
;************************************************

  hemi = "NH"

  m6cice = "no"
  hycice = "yes"

  if(hycice .eq. "yes")then
     rtsrc1 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
    rtname1 = "CICE008/cice_20151001/"
   ;compset1 = "cfsr%20150401_30days_nems_gsm%slg%T574_cice%0.24_hycom%0.24/"
   compset1 = "cfsr%20151001_31days_nems_gsm%slg%T574_cice%0.24_hycom%0.24/"
   
     rtsrc2 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"
    rtname2 = "rtgen.113161/tmp/"
   compset2 = "cfsr_20150401_30days_nems_gsm_slg_T574_cice_0.24_hycom_0.24/"

   nemsdir="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
   ; load the grid file
   gr =addfile(nemsdir+"cice_grid_024.nc","r")
   rad2deg=180.d0/acos(-1.0d0)
   tlatname="tlat"
   tlonname="tlon"
   rfactor=rad2deg
   dir1=rtsrc1+rtname1+compset1+"history/"
   dir2=rtsrc2+rtname2+compset2+"history/"

   lon1=74.12
   lon2=-105.88
   lat1=60
   lat2=60
  end if

;************************************************
; ice
;************************************************

  hemisphere = "NH"
  ;hemisphere = "SH"

  cyear=2015
  lstep=1-1
  cday=cyear+"-04-28"
  ;cday=cyear+"-06"
  print("day = "+cday)

      dirs = (/dir1,dir2/)
  print(dirs)
  ;varnames = (/"aice", "hi"/)
  ;varnames = (/"meltt", "meltb"/)
  ;varnames = (/"meltt", "albsni"/)
  ;varnames = (/"apond_ai", "hpond_ai"/)
  ;varnames = (/"evap_ai", "flat_ai"/)
  varnames = (/"aice", "frzmlt"/)

      nvars = dimsizes(varnames)
  ; array contour levels for variables
    varlevs = new((/nvars,3/),float)
  colormaps = new((/nvars/), string)
  do ii = 0,nvars-1
           vname = varnames(ii)
         freturn = setlevsmaps(vname)
   varlevs(ii,:) = freturn[0]
   colormaps(ii) = freturn[1]
  end do
  ;print(varlevs)
  ;print(colormaps)
  varnames = varnames+"_h"

     fnames = new((/2/),string)
  ;fnames(0) = dirs(0)+"iceh_24h."+cday+".nc"
  ;fnames(1) = dirs(1)+"iceh_24h."+cday+".nc"
  ;fnames(0) = dirs(0)+"iceh."+cday+".nc"
  ;fnames(1) = dirs(1)+"iceh."+cday+".nc"
  fnames(0) = dirs(0)+"iceh_24h."+cday+"-00000.nc"
  fnames(1) = dirs(1)+"iceh_24h."+cday+"-00000.nc"
  ;print(fnames)

  filelist = addfiles(fnames,"r")
  ;print(filelist)
;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice2run")              ; send graphics to X11 window

  ;drawNDCGrid(wks)

  plotleft = new(2,graphic)
  plotrght = new(2,graphic)
   dumleft = new(2,graphic)
   dumrght = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnFillMode         = "MeshFill"
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn       = False                  ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.030

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@gsnPolarLabelFontHeightF = .030              ; change font height of labels
  res@gsnStringFontHeightF     = .080
  res@gsnLeftString = " "

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
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
  if(name .eq. "aice_h" .or. name .eq. "aice")then
   ;res@cnLevelSelectionMode        = "ExplicitLevels"
   ;res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   ;res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  else if(name .eq. "hi_h" .or. name .eq. "hi")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@lbLabelAlignment     = "InteriorEdges"
  end if
  end if
   res@cnFillPalette        = palette

  plot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  delete(res@cnLevels)
  delete(res@lbLabelStrings)
  return(plot)
end
;************************************************
; left plot and colorbar, same variable 
; (same field, same timestep, 2 runs)
;************************************************

      ii = 0
  ; 1st run
    fnum = 0
  ; 1st variable
    vnum = 0
   vname = varnames(vnum)

  icevar = filelist[fnum]->$vname$(0,:,:)
  icevar@lon2d=gr->$tlonname$*rfactor
  icevar@lat2d=gr->$tlatname$*rfactor
  icevar@long_name=" "
  icevar@units=" "
  plotleft(ii) = subplot(ii,vname,icevar(:,:),varlevs(vnum,:),colormaps(vnum))
   dumleft(ii) = gsn_add_polyline(wks,plotleft(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

     ii = 1
  ; 2nd run
    fnum = 1
  ; 1st variable
    vnum = 0

  icevar = filelist[fnum]->$vname$(0,:,:)
  icevar@lon2d=gr->$tlonname$*rfactor
  icevar@lat2d=gr->$tlatname$*rfactor
  icevar@long_name=" "
  icevar@units=" "
  plotleft(ii) = subplot(ii,vname,icevar(:,:),varlevs(vnum,:),colormaps(vnum))
   dumleft(ii) = gsn_add_polyline(wks,plotleft(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  delete(icevar)

;************************************************
; right plot and colorbar
; (same field, same timestep, 2 runs)
;************************************************

      ii = 0
  ; 1st run
    fnum = 0
  ; 2nd variable
    vnum = 1
   vname = varnames(vnum)

  icevar = filelist[fnum]->$vname$(0,:,:)
  icevar@lon2d=gr->$tlonname$*rfactor
  icevar@lat2d=gr->$tlatname$*rfactor
  icevar@long_name=" "
  icevar@units=" "
  plotrght(ii) = subplot(ii,vname,icevar(:,:),varlevs(vnum,:),colormaps(vnum))
   dumrght(ii) = gsn_add_polyline(wks,plotrght(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

     ii = 1
  ; 2nd run
    fnum = 1
  ; 2nd variable
    vnum = 1

  icevar = filelist[fnum]->$vname$(0,:,:)
  icevar@lon2d=gr->$tlonname$*rfactor
  icevar@lat2d=gr->$tlatname$*rfactor
  icevar@long_name=" "
  icevar@units=" "
  plotrght(ii) = subplot(ii,vname,icevar(:,:),varlevs(vnum,:),colormaps(vnum))
   dumrght(ii) = gsn_add_polyline(wks,plotrght(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
;
;************************************************

 resP1                  = True                ; mods desired
 resP1@gsnFrame         = False               ; save panel until both ready
 resP1@gsnPanelRight    = 0.5                 ; draw from left edge to center
 resP1@gsnPanelLabelBar = True                ; commom label bar

 resP2                  = True                ; mods desired
 resP2@gsnFrame         = False               ; save panel until both ready
 resP2@gsnPanelLeft     = 0.5		      ; draw from center to right edge 
 resP2@gsnPanelLabelBar = True		      ; commom label bar

 resP1@gsnPanelYWhiteSpacePercent = 10
 resP1@gsnPanelXWhiteSpacePercent = 10
 resP2@gsnPanelYWhiteSpacePercent = 10
 resP2@gsnPanelXWhiteSpacePercent = 10

 gsn_panel(wks,plotleft,(/2,1/),resP1)          ; create first panel
 gsn_panel(wks,plotrght,(/2,1/),resP2)          ; create second panel

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.010                     ; font smaller. default big

; page coordinates are normalized. go from 0->1 not 0->8" etc.
  gsn_text_ndc(wks,rtname1+" "+compset1+" "+cday,0.5,0.98,txres) 
  gsn_text_ndc(wks,rtname2+" "+compset2+" "+cday,0.5,0.58,txres) 

  gsn_text_ndc(wks,varnames(0),0.25,0.95,txres) 
  gsn_text_ndc(wks,varnames(1),0.75,0.95,txres) 
 frame(wks)
exit
end
