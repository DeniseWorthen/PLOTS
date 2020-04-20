;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
;
;************************************************

 ;batch = "yes"
 batch = "no"

  hemi="NH"
  ;hemi="SH"

 if(batch .eq. "no")then
  model = "hycice"
  ;model = "hykiss"
 end if
  
;************************************************
;
;************************************************
function setlevsmaps(name)
begin

         levs = new((/3/),float)
         cmap = new((/1/),string)
    latent_levs=(/ -12.00,    12.00,  0.500/)
     ; sens_levs=(/ -20.00,    20.00,  1.000/) 
      sens_levs=(/   0.00,    40.00,  1.000/) 
      ;evap_levs=(/  -0.2,     0.2,  0.02/) 
      evap_levs=(/  -0.5,     0.5,  0.05/) 
      lwup_levs=(/-300.00,     0.00, 10.000/)
      dswf_levs=(/ 230.00,   380.00,  5.000/)
      dlwf_levs=(/ 200.00,   340.00,  5.000/)
   topmelt_levs=(/   0.00,     5.00,  0.200/)
   botmelt_levs=(/   0.00,     3.00,  0.100/)
      tsfc_levs=(/ -30.00,     0.00,  1.000/)
      snow_levs=(/   0.00,     1.00,  0.050/)
      tair_levs=(/ -20.00,    10.00,  0.500/)
       alb_levs=(/  20.00,    80.00,  5.000/)
       ice_levs=(/   0.00,     1.00,  0.100/)
        hi_levs=(/   0.00,     4.00,  0.500/)
     fpond_levs=(/   0.00,     0.80,  0.100/)
   ;  hpond_levs=(/   0.00,     0.30,  0.020/)
   ;  fpond_levs=(/   0.00,     0.50,  0.050/)
     hpond_levs=(/   0.00,     0.20,  0.020/)
    frzmlt_levs=(/-300.00,   0.00,  20.000/)
    ;frzmlt_levs=(/-50.00,   50.00,  5.000/)

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
    cmap = "WhBlGrYeRe"
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
    cmap = "WhBlGrYeRe"
    levs = ice_levs
   end if
   if(name .eq. "hi" .or. name .eq. "Ice_thick")then
    cmap = "WhBlGrYeRe"
    levs = hi_levs
   end if
   if(name .eq. "apond_ai" .or. name .eq. "apond" .or. name .eq. "apeff_ai")then
    ;cmap = "WhBlGrYeRe"
    levs = fpond_levs
   end if
   if(name .eq. "hpond_ai" .or. name .eq. "hpond")then
    cmap = "WhBlGrYeRe"
    levs = hpond_levs
   end if
   if(name .eq. "frzmlt" )then
    levs = frzmlt_levs
    ;cmap = "BlWhRe"
    cmap = "precip2_17lev"
   end if

   ;print(name+"  "+levs)
   ;print(name+"  "+cmap)
   return( [/levs,cmap/])
end

begin
;************************************************
;
;************************************************

  ;Dates2Plt = (/"2015-06"/)
  ;Dates2Plt = (/"2015-04", "2015-05"/)
  ;Dates2Plt = (/"2015-06", "2015-07"/)
  ;Dates2Plt = (/"2015-05", "2015-06", "2015-07"/)
  ;Dates2Plt = (/"2015-04", "2015-05", "2015-06", "2015-07"/)
  Dates2Plt = (/"2015-04", "2015-05", "2015-06", "2015-07", "2015-08", "2015-09", "2015-10"/)
  ;Dates2Plt = (/"2015-06", "2015-07", "2015-08", "2015-09"/)
  ;Dates2Plt = (/"2015-06", "2015-07", "2015-08"/)
  ndates = dimsizes(Dates2Plt)

;************************************************
; read in netCDF file
;************************************************

  if(model .eq. "hycice")then
   runname = "CICE008"
     rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"+runname+"/history/"
   nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
  ; load the grid file
  gf =addfile(nemsdir+"cice_grid_024.nc","r")

  icefilelist = rtsrc+"iceh."+Dates2Plt+".nc"
     icefiles = addfiles(icefilelist,"r")

   icelonname = "tlon"
   icelatname = "tlat"
      rad2deg = 180.d0/acos(-1.0d0)
      rfactor = rad2deg
  end if

  if(model .eq. "hykiss")then
   runname = "KISS019"
     rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"+runname+"/"
    nemsrc = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/kiss_data/mx024/"
  ; load the grid file
  gf =addfile(nemsrc+"kiss_grid_024.nc","r")

  icefilelist = rtsrc+"IceMm."+Dates2Plt+".nc"
     icefiles = addfiles(icefilelist,"r")

   icelonname = "plon"
   icelatname = "plat"
      rfactor = 1.0
  end if

;************************************************
; load an ice field
;************************************************

   ;varnames = (/"apeff_ai","apond_ai"/)
;   varnames = (/"meltt", "apond_ai", "hpond_ai"/)
   ;varnames = (/"meltt", "apond_ai", "hpond_ai", "albsni"/)
   ;varnames = (/"meltt", "apond", "hpond", "albsni"/)
   ;varnames = (/"meltt", "aice", "hi"/)
   ;varnames = (/"apond_ai"/)
   varnames = (/"frzmlt"/)
  ;print(varnames)

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

  plottitle = runname
   wkstitle = runname

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  74.12
   lon2=-105.88
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)
  ;drawNDCGrid(wks)

  ; panels
  npanels = nvars*ndates
  plot = new(npanels,graphic)
   dum = new(npanels,graphic)
  print("nvars = "+nvars+" ndates = "+ndates+" npanels = "+npanels)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@mpFillOn             = True

  ;res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnFillMode         = "MeshFill"
  res@lbLabelFontHeightF = 0.030
  res@lbLabelBarOn       = False                  ; turn  on individual colorbars
  res@cnLineLabelsOn     = False

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
  pres                   = True           ; polyline mods desired
  pres@gsLineThicknessF  = 2.0            ; line thickness
  pres@gsLineColor       = "black"        ; color of lines
  pres@gsLineDashPattern =  1             ; dashes
  ;pres@tfPolyDrawOrder   = "PostDraw"

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
;function subplot(ii,pltvar,pltlevs)
begin
  if(name .eq. "aice_h" .or. name .eq. "aice" .or. name .eq. "Ice_conc")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(name .eq. "hi_h" .or. name .eq. "hi" .or. name .eq. "Ice_thick")then
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

  plot(ii) = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  delete(res@cnLevels)
  delete(res@lbLabelStrings)
   return(plot(ii))
end
;************************************************
;
;************************************************
  ; a counter for the panels
    lll = 0

  labelstring = new((/nvars/), string)

  ; loop over variables
  do kk = 0,nvars-1
   if(kk .eq. 0)then
    ; top row; add dates to this row
    res@gsnCenterStringFontHeightF = 0.060
    res@gsnCenterStringOrthogonalPosF = 0.40
   end if

  vname = varnames(kk)
  icevar=icefiles[:]->$vname$(:,:,:)
  icevar@lon2d=gf->$icelonname$*rfactor
  icevar@lat2d=gf->$icelatname$*rfactor
  ;icevar@units=""
  ;icevar@long_name=""
  ; in mm/d
  labelstring(kk) = icevar@long_name+" ("+icevar@units+")"

  aice=icefiles[:]->aice(:,:,:)
  icevar = mask(icevar, (aice .lt. 0.05), 0.0)

  icevar@units=""
  icevar@long_name=""
  if(vname .eq. "evap_ai")then
    icevar = 10.0*icevar
  end if

  do ii = 0,ndates-1
   ;if(vname .eq. "meltt")then
    res@gsnCenterString = Dates2Plt(ii)
   ;end if
   plot(lll) = subplot(lll,vname,icevar(ii,:,:),varlevs(kk,:),colormaps(kk))
         lll = lll+1
   ;print("kk = "+kk+"  "+labelstring(kk))
  end do
   if(vname .eq. "meltt")then
    delete(res@gsnCenterString)
   end if
  end do ; kk

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnMaximize      = True
  resP@gsnFrame         = False
  ;resP@gsnPanelLabelBar = False
  resP@gsnPanelLabelBar = True

   ;resP@txString      = plottitle
   resP@txFontHeightF = 0.010

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

 ; gsn_panel(wks,plot,(/nvars,ndates/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/2,4/),resP)               ; now draw as one plot

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.010                     ; font smaller. default big

; page coordinates are normalized. go from 0->1 not 0->8" etc.
   ydel = 0.9/tofloat(nvars)
     yy = new((/nvars/),float)
  do ii = 0,nvars-1
   yy(ii) = 0.90 - tofloat(ii)*ydel
  end do

   gsn_text_ndc(wks,labelstring(0),0.5,yy(0),txres)
   ;gsn_text_ndc(wks,labelstring(1),0.5,yy(1),txres)
   ;gsn_text_ndc(wks,labelstring(2),0.5,yy(2),txres)
   ;gsn_text_ndc(wks,labelstring(3),0.5,yy(3),txres)

  frame(wks)

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
