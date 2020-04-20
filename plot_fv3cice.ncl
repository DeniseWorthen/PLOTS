; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/scrub/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  ; theia
  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  ;RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

   hemi = "NH"
 ; hemi = "SH"
 ; hemi = "none"

  rad2deg=180.d0/acos(-1.0d0)
  ; fv3min = 1.0e-6
   fv3min = 0.15
  cicemin = 1.0e-11

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile4"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

  cyear = "2012"
   cmon = "07"
   cday = "01"

  ;these are conincident
  tstamps = (/"000:07:30.","00450"/)
  ;tstamps = (/"000:15:00.","00900"/)
  ;tstamps = (/"000:22:30.","01350"/)
  ;tstamps = (/"000:30:00.","01800"/)
  ;tstamps = (/"012:00:00.","43200"/)

  ;these are offset by 1 timestep
  ;tstamps = (/"000:15:00.","00450"/)
  ;tstamps = (/"000:22:30.","00900"/)
  ;tstamps = (/"000:30:00.","01350"/)
  ;tstamps = (/"000:37:30.","01800"/)
  ;tstamps = (/"012:00:00.","42750"/)

  ;for FV3
        model = "phyf"+tstamps(0)
  tilelonname = "grid_xt"
  tilelatname = "grid_yt"
  rfactor=rad2deg

  ;for CICE
        cdate = cyear+"-"+cmon+"-"+cday+"-"+tstamps(1)
  cicelonname = "TLON"
  cicelatname = "TLAT"

      rts = (/"NEMS_upfv3_minice"/)
     ; rts = (/"NEMS_upfv3_fix3"/)
     ; rts = (/"NEMS_Shan_fix"/)
     cset = "/2012070100_2d_iiout/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
     ;cset = "/2012070100_inst/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"
     ; rts = (/"scrub/CMEPS_jun10_2"/)
     ;cset = "/2012070100_1d_inst/tmp/cpld_fv3_384_mom6_cice_warm_bm2/"
     fv3file = addfile(RT2+rts+cset+model+tile+".nc","r")
     icefile = addfile(RT2+rts+cset+"history/iceh_inst."+cdate+".nc","r")

  tilecorners = tilegrid(fv3file->$tilelonname$*rad2deg,fv3file->$tilelatname$*rad2deg,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   ;print(minlat+"   "+maxlat)
   ;print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  ;colormap="MPL_rainbow"
  colormap="amwg256"
  ;varnames = (/"tisfc","Tsfc"/)
  ;varnames = (/"tmpsfc","tcomp"/)
  ;pltlevs=(/-2.0,2.0,.2/)
  varnames = (/"icec","aice"/)
  pltlevs=(/0.8,1.0,.05/)
  ;pltlevs=(/0.1,0.9,.1/)
  ;pltlevs=(/0.0,0.30,.01/)

  plottitle=rts
  wkstitle=rts+"."+tstamps(1)
  ;plottitle="test"
  ;wkstitle="test"
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = True
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                         ; minimum lat to plot
    res@mpCenterLonF =  midlon
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = maxlat                            ; minimum lat to plot
    res@mpCenterLonF = midlon
   end if
  else
   res@mpMinLatF            =  minlat      ; range to zoom in on
   res@mpMaxLatF            =  maxlat
   res@mpMinLonF            =  minlon
   res@mpMaxLonF            =  maxlon
   res@mpCenterLonF         =  midlon
  end if

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,hemi)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

   res@cnMissingValFillColor    = "gray70" ; set color for missing areas
  ;print(pltlevs)
  ;print(palette)

  if(hemi .eq. "none")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle

;************************************************
;
;************************************************

   ; FV3 tile file
          ii = 0
       aname = varnames(ii)
   if(aname .eq. "tmpsfc" .or. aname .eq. "tisfc")then
        avar = (fv3file->$aname$(lstep,:,:)) - 273.15
   else
        avar = fv3file->$aname$(lstep,:,:)
   end if
        avar = where(fv3file->land(lstep,:,:) .eq. 1.0, avar@_FillValue, avar)
  ;      avar = where(fv3file->icec(lstep,:,:) .lt. fv3min, avar@_FillValue, avar)
  ;      avar = where(fv3file->icec(lstep,:,:) .ge. fv3min, avar, avar@_FillValue)
  avar@units = ""
  avar@long_name = ""
  avar@lon2d = fv3file->$tilelonname$*rfactor
  avar@lat2d = fv3file->$tilelatname$*rfactor
  ;res@gsnCenterString  = model+tile+"   "+aname+" (icec>"+sprintf("%6.4g",fv3min)+")"
  res@gsnCenterString  = model+tile+"   "+aname
  plot(ii) = subplot(ii,aname,avar(:,:),pltlevs,colormap,hemi)

   ; CICE file
          ii = 1
       aname = varnames(ii)
   if(aname .eq. "tcomp")then
    ; make tcomposit
       ai = icefile->aice(lstep,:,:)
      sst = icefile->sst(lstep,:,:)
     tsfc = icefile->Tsfc(lstep,:,:)
    tcomp = tsfc ; copy atts
    tcomp = (1.0 - ai)*sst + ai*tsfc
     ivar = tcomp
   else
     ivar = icefile->$aname$(lstep,:,:)
   end if
     ;ivar = where(icefile->aice(lstep,:,:) .ge. cicemin, ivar, ivar@_FillValue)
  ivar@lon2d = icefile->$cicelonname$
  ivar@lat2d = icefile->$cicelatname$
  ivar@units = ""
  ivar@long_name = ""
  ;res@gsnCenterString  = "iceh_inst."+cdate+"   "+aname+"  (aice>"+sprintf("%6.4g",cicemin)+")"
  res@gsnCenterString  = "iceh_inst."+cdate+"   "+aname
  plot(ii) = subplot(ii,aname,ivar(:,:),pltlevs,colormap,hemi)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
