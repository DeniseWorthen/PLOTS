;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  hemi="NH"
  ;hemi="SH"

  model = "m6c5"
  minlat = 66.0
  ;minlat = 76.0
  ;minlat = 88.0
  ;minlat = 80.0

  ;minlat =  88.0
  maxlat = -50.0
  ;minlon =  140.0
  ;maxlon =  270.0

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************

   idate = "2021010100"
   cyear = "2021"
    cmon = "08"
    cday = "24"
   cdate = cyear+"-"+cmon+"-"+cday
   rtsrc = RT2+"testpr1/pdlib270k/"

   ; use one file for grid
   ;gf =addfile(rtsrc+"iceic"+idate+"00.01."+idate+"00.nc","r")
   gf =addfile(rtsrc+"history/iceh_inst."+cyear+"-"+cmon+"-24-21600.nc","r")
   ;print(gf)
   tlatname="TLAT"
   tlonname="TLON"
   rfactor=1.0
   ;dirname=rtsrc+"history/"
   dirname=rtsrc

;************************************************
; ice
;************************************************

  lstep=1-1
  print("cdate = "+cdate)

  ; ice field
  varname="aice_h"
  ;levs=(/0.97,1.0,0.001/)
  ;levs=(/0.87,0.95,0.0010/)
  ;levs=(/0.50,1.00,0.010/)
  ;levs=(/0.0, 1.0, 0.02/)
  ;varname="hi_h"
  ;levs=(/0.0,3.0,0.1/)
  ;levs=(/0.0,2.0,0.1/)
  ;varname="Tsfc_h"
  ;levs=(/-40.0,5.0,1.0/)
  ;varname="hi_h"
  ;levs=(/0.0,4.0,0.2/)
  ;varname="sst_h"
  ;levs=(/-1.80,-1.00,.02/)
  ;levs=(/-1.72,-1.66,.001/)
  ;levs=(/-1.5,-1.32,.01/)
  ;varname="sss_h"
  ;levs=(/28.4, 35.2, .2/)
  ;levs=(/33.0, 34.8, .05/)
  ;varname="fhocn_h"
  ;levs=(/-100.0,100.0,10.0/)
  ;varname="frzmlt_h"
  ;levs=(/-50.0,50.0,5.0/)
  ;levs=(/-20.0,20.0,2.0/)
  ;levs=(/-200.,200,20.0/)
  ;levs=(/-200.,200,20.0/)
  ;levs=(/-1000.,1000,50.0/)
  ;varname="meltt_h"
  ;levs=(/0.,3,0.1/)
  ;levs=(/0.,1,0.02/)
  ;varname="hpond_h"
  ;levs=(/0.,0.5,0.05/)
  ;varname="albsni_h"
  ;   levs=(/0.10,0.70,0.05/)
  ;varname="hs_h"
  ;levs=(/0.0,0.42,0.02/)

   icef =addfile(rtsrc+"history/iceh_inst."+cyear+"-"+cmon+"-24-21600.nc","r")
  ;  icef = addfile(rtsrc+"history/iceh_06h."+cdate+"-00000.nc","r")
  icevar = icef->$varname$(lstep,:,:)
  ;icevar = icevar/100.0
  icevar@lon2d=gf->$tlonname$*rfactor
  icevar@lat2d=gf->$tlatname$*rfactor
  printVarSummary(icevar)
  icevar@units=""
  icevar@long_name=""

  ;       aivar = icef->aice_h(lstep,:,:)
  ; aivar@lon2d = gf->$tlonname$*rfactor
  ; aivar@lat2d = gf->$tlatname$*rfactor
  ; icemasked=icevar
  ; icemasked=mask(icevar, (aivar .eq. 0.0), False)
  ; icevar=icemasked

  ;times= icef->time

; Get the time units and set the first and last times that we want
  ;timeUnits = icef->time@units
  ;timeCalendar = icef->time@calendar

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=  60.00
  lon2=-120.00
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice5")              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

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

  ; Near Yenisei
  ;res@mpMinLatF            =  70      ; range to zoom in on
  ;res@mpMaxLatF            =  80.
  ;res@mpMinLonF            =  60.
  ;res@mpMaxLonF            =  90.

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  ;res@cnFillOn          = False                  ; color fill

  ;res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ;res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  ;res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  ;res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ; res@cnLevelSelectionMode        = "ExplicitLevels"
  ; res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
  ; res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette        = "BlWhRe"              ; choose colormap
  ;res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap
  ;res@cnFillPalette        = "NCV_roullet"              ; choose colormap
  ;res@cnFillPalette        = "WhBlGrYeRe"              ; choose colormap

  ;res@tiMainString = dirname+" "+cday
  res@tiMainString = rtsrc+" "+cdate+" "+varname
  res@tiMainFontHeightF = .01

  ;res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  ;res@gsnStringFontHeightF = 0.01
  ;res@gsnCenterString = cd_string(times(lstep),"%d %F")

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

  plot = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot
  ;plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;pum= gsn_add_polymarker(wks,plot,center_xlon,center_xlat,mkres)

  draw(plot)
  frame(wks)

exit

end
