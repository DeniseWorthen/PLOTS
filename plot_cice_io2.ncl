;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  batch = "no"
  ;batch = "yes"

  hemi="NH"
  ;hemi="SH"

  simplelevs="yes"
  ;simplelevs="no"

;************************************************
;
;************************************************

  Dates2Plt = (/"2015-07-15"/)
  Hours2Plt = (/"00000", "21600", "43200", "64800"/)
  ;Hours2Plt = (/"00000"/)
  ;Hours2Plt = (/"21600"/)
  ;Hours2Plt = (/"42320"/)
  ;Hours2Plt = (/"64800"/)

  nhours = dimsizes(Hours2Plt)

;************************************************
; read in netCDF file
;************************************************

   rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE008_io/"
   nemsdir="/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
   compset=""
   ; load the grid file
   gf =addfile(nemsdir+"cice_grid_024.nc","r")
   rad2deg=180.d0/acos(-1.0d0)
   icelatname="tlat"
   icelonname="tlon"
   rfactor=rad2deg

   dirname=rtsrc+"history/"
   filelist = dirname+"iceh_inst."+Dates2Plt+"-"+Hours2Plt+".nc"
   icefiles = addfiles(filelist,"r")

;************************************************
; ice
;************************************************

     aicename = "aice_h"
       hiname = "hi_h"
   ;      levs = (/0.0,1.0,0.05/)
         levs = (/0.75,0.90,0.005/)

        icevar = icefiles[:]->$aicename$
  icevar@lon2d = gf->$icelonname$*rad2deg
  icevar@lat2d = gf->$icelatname$*rad2deg
  ;icevar@lon2d = icefiles[0]->$icelonname$
  ;icevar@lat2d = icefiles[0]->$icelatname$
  icevar@long_name=""
  icevar@units=""

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice_io")

  ; a max of nhours panels
  npanels = nhours
 ; for panels
 if(npanels .le. 4)then
   nrows = 2
   ncols = 2
 else if(batch .eq. "yes")then
    ncols = nhours
    nrows = 1
 else
    ncols = 4
    nrows = 1+npanels/ncols
 end if
 end if
 print("npanels = "+npanels+" nrows = "+nrows+" ncols = "+ncols)

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  ;res@cnFillMode           = "MeshFill"
  res@cnFillMode           = "RasterFill"
  ;res@mpFillOn             = True

  ;res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; 
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
  ; res@mpMinLatF    =  66                          ; minimum lat to plot
  ; res@mpMinLatF    =  88                          ; minimum lat to plot
   res@mpMinLatF    =  80                          ; minimum lat to plot
  ; res@mpMinLatF    =  72                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

   if(simplelevs .eq. "yes")then
    res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
    res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
    res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
    res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
   else
    res@cnLevelSelectionMode        = "ExplicitLevels"
    res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
    res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
   end if

  ;res@cnFillPalette   = "NCV_jet"               ; choose colormap
  res@cnFillPalette   = "WhBlGrYeRe"               ; choose colormap
  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  ;res@gsnCenterStringOrthogonalPosF = .15          ; raise the CenterString slightly
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

  do ii = 0,nhours-1
    res@gsnCenterString = Hours2Plt(ii)

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
   ; dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   if(ii .eq. 0)then
   ; dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
   end if
  end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  ;resP@txFontHeightF = .01
  ;resP@txString = runname+"  "+labelstring
  ;resP@gsnPanelMainString  = runname+"  "+Dates2Plt
  resP@gsnPanelMainString  = aicename
  resP@gsnPanelMainFontHeightF = 0.012            ; new resource added in NCL V6.4.0

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot
 ; gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

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

;exit
end
