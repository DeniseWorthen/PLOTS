;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
 ;batch = "yes"
 batch = "no"

 hemi="NH"
;hemi="SH"

 if(batch .eq. "no")then
  ;model = "hycice"
  model = "m6cice5"
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
   ;botmelt_levs=(/   0.00,     3.00,  0.100/)
   botmelt_levs=(/   0.00,     2.00,  0.050/)
      tsfc_levs=(/ -30.00,     0.00,  1.000/)
   ;    sst_levs=(/   0.00,    16.00,  0.500/)
       sst_levs=(/  -1.80,     0.00,  0.050/)
      snow_levs=(/   0.00,     1.00,  0.050/)
      tair_levs=(/ -20.00,    10.00,  0.500/)
       alb_levs=(/  20.00,    80.00,  5.000/)
   ;    ice_levs=(/   0.00,     1.00,  0.100/)
       ice_levs=(/   0.90,     1.00,  0.005/)
        hi_levs=(/   0.00,     4.00,  0.500/)
   ;  fpond_levs=(/   0.00,     1.00,  0.100/)
     hpond_levs=(/   0.00,     0.50,  0.050/)
     fpond_levs=(/   0.00,     0.50,  0.050/)
   ;  hpond_levs=(/   0.00,     0.20,  0.020/)
     frzmlt_levs=(/ -20.00,  20.00,  2.000/)

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
    cmap = "WhBlGrYeRe"
    levs = fpond_levs
   end if
   if(name .eq. "hpond_ai" .or. name .eq. "hpond")then
    cmap = "WhBlGrYeRe"
    levs = hpond_levs
   end if
   if(name .eq. "sst" .or. name .eq. "Tmix")then
    levs = sst_levs
   end if
   if(name .eq. "frzmlt")then
    levs = frzmlt_levs
    cmap = "ncl_default"
   end if

   ;print(name+"  "+levs)
   ;print(name+"  "+cmap)
   return( [/levs,cmap/])
end

begin
;************************************************
;
;************************************************

  ;Dates2Plt = (/"-04-15", "-05-15" \ 
  ;             ,"-06-15", "-07-15" \ 
  ;             ,"-08-15", "-09-15" \
  ;             ,"-10-15" \
  ;             /)

  ;Dates2Plt = (/"-06-15", "-06-30" \ 
  ;             ,"-07-15", "-07-30" \ 
  ;             ,"-08-15", "-08-30" \
  ;             ,"-09-15", "-09-30" \ 
  ;             ,"-10-15", "-10-30" \ 
  ;             /)

  ;Dates2Plt = (/"-10-04", "-10-14" \ 
  ;             ,"-10-24", "-11-07" \
  ;             /)

  Dates2Plt = (/"-10-04", "-10-05" \ 
               ,"-10-06", "-10-07" \
               /)

  if(model .eq. "m6cice5")then
   Year2Plt = "2016"
  else
   Year2Plt = "2015"
  end if

  ;Dates2Plt = (/"-10-04", "-10-06" \ 
  ;             ,"-10-08", "-10-10" \
  ;             ,"-10-12"               \ 
  ;             /)

   Dates2Plt=Year2Plt+Dates2Plt
   print(Dates2Plt)

   ndates = dimsizes(Dates2Plt)
 
;************************************************
; read in netCDF file
;************************************************
  if(model .eq. "hycice")then
    runname = "CICE008"
   plotname = "GSM-HYCOM-CICE"
     rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"+runname+"/history/"
   nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
   ; load the grid file
   gf =addfile(nemsdir+"cice_grid_024.nc","r")
      rad2deg=180.d0/acos(-1.0d0)

  icefilelist = rtsrc+"iceh_24h."+Dates2Plt+".nc"
     icefiles = addfiles(icefilelist,"r")

   icelonname = "tlon"
   icelatname = "tlat"
      rfactor = rad2deg
  end if
  if(model .eq. "m6cice5")then
    runname = "FV3M6C5_10d"
   plotname = "FV3-MOM6-CICE5"
   ;rtsrc ="/scratch3/NCEPDEV/stmp2/Denise.Worthen/fixfrzmlt_delT_MLD_new/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   ;rtsrc ="/scratch3/NCEPDEV/stmp2/Denise.Worthen/fixfrzmlt_delT_MLD/tmp/cpld_fv3_mom6_cice_35d_atm_flux/"
   rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/rtgen.93619/tmp/cpld_fv3_mom6_cice_2d_atm_flux/"
   ; use ic file for grid
   gf = addfile(rtsrc+"history/iceh_ic.2016-10-03-00000.nc","r")

   icelatname = "TLAT"
   icelonname = "TLON"
      rfactor = 1.0

  icefilelist = rtsrc+"history/iceh_06h."+Dates2Plt+"-00000.nc"
     icefiles = addfiles(icefilelist,"r")
  end if

  if(model .eq. "hycice" .or. model .eq. "m6cice5")then
     aicename = "aice"
       hiname = "hi"
      albname = "albsni"
  topmeltname = "meltt"
  botmeltname = "meltb"
  ; apnd*ai or apnd*alvl*ai ==> ponded ice fraction
   fpondname = "apond_ai"
  ; hpnd*apnd or hpnd*apnd*alvl ==> ponded depth on sea ice (use _ai for ponded depth over grid cell)
  ; hpondname = "hpond"
   hpondname = "hpond_ai"
     socnname = "sss"
     tocnname = "sst"
   frzmltname = "frzmlt"
  end if

  if(model .eq. "hykiss")then
   runname = "KISS019"
    rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"+runname+"/output/"
   nemsdir ="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/kiss_data/mx024/"
   ; load the grid file
   gf =addfile(nemsdir+"kiss_grid_024.nc","r")

  icefilelist = rtsrc+"IceDm."+Dates2Plt+".nc"
     icefiles = addfiles(icefilelist,"r")

   icelonname = "plon"
   icelatname = "plat"
      rfactor = 1.0

   aicename = "Ice_conc"
     hiname = "Ice_thick"
   socnname = "Smix"
   tocnname = "Tmix"
  end if

  ;if(model .eq. "m6cice")then
  ; rtsrc="/scratch3/NCEPDEV/stmp1/Denise.Worthen/mom6_cice5/"
  ; gf =addfile(rtsrc+"history/iceh.2015-01.nc","r")
  ; tlatname="TLAT"
  ; tlonname="TLON"
   ;rfactor=1.0
   ;monlist=ispan(1,7,3)
  ;end if

;************************************************
; load an ice field
;************************************************

  if(batch .eq. "no")then
   ;varname= aicename
   varname = hiname
   ;varname = albname
   ;varname = topmeltname
   ;varname = botmeltname
   ;varname = fpondname
   ;varname = hpondname
   ;varname = tocnname
   ;varname = socnname
   ;varname = frzmltname
  end if
 
  ; array contour levels for variables
      pltlevs = new((/3/),float)
      freturn = setlevsmaps(varname)
   pltlevs(:) = freturn[0]
   colormap   = freturn[1]

  if(model .eq. "hycice" .or. model .eq. "m6cice5")then
    varname = varname+"_h"
   aicename = "aice_h"
  end if
        icevar = icefiles[:]->$varname$(:,:,:)
  icevar@lon2d = gf->$icelonname$*rfactor
  icevar@lat2d = gf->$icelatname$*rfactor

         aivar = icefiles[:]->$aicename$(:,:,:)
   aivar@lon2d = gf->$icelonname$*rfactor
   aivar@lat2d = gf->$icelatname$*rfactor
  
  ;if(model .eq. "hycice")then
   labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
  ;else 
  ; labelstring = "["+varname+"]"
  ;end if

  ;printVarSummary(icevar)
  icevar@units = ""
  icevar@long_name = ""
  icemasked=icevar
  icemasked=mask(icevar, (aivar .eq. 0.0), False)
  icevar=icemasked

  plottitle = plotname
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
  end if

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  if(model .eq. "m6cice5")then
   lon1=  60.00
   lon2=-120.00
  else
   lon1=  74.12
   lon2=-105.88
  end if
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
   ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)
 
  ; a max of ndates panels, not all used
  npanels = ndates
 ; for panels
 if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else 
    ;ncols = 4
    ;nrows = 1+npanels/ncols
    ncols = 2
    nrows = 2
 end if
     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@cnFillMode           = "MeshFill"
  ;res@cnFillMode           = "RasterFill"
  res@mpFillOn             = True

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66                          ; minimum lat to plot
   ;res@mpMinLatF    =  89                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  if(varname .eq. "aice_h" .or. varname .eq. "aice" .or. varname .eq. "Ice_conc")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(varname .eq. "hi_h" .or. varname .eq. "hi" .or. varname .eq. "Ice_thick")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  ; res@lbLabelAlignment     = "InteriorEdges"
  end if
  end if

  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  ;res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  res@gsnCenterStringFontHeightF = 0.040

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

  do ii = 0,ndates-1
    res@gsnCenterString = Dates2Plt(ii)
   
   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@txFontHeightF = .01
  resP@txString = plotname+"  "+labelstring
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot

;************************************************
;
;************************************************

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
