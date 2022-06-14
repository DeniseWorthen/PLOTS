;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  ; cheyenne
  RT2 = "/glade/scratch/worthen/FV3_RT/cgridtests/"
  ;RT2 = "/glade/scratch/tcraig/FV3_RT/cgridtests/cgrid/"

    hemi = "NH"
 ;   hemi = "SH"
 if(hemi .eq. "NH")then
  minlat =  70.0
  midlon = -45.0
 else
  maxlat = -50.0
  midlon =   0.0
 end if

  ; these are in degrees
    rfactor = 1.0
   tlatname = "iceExp_lat"
   tlonname = "iceExp_lon"

;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "2021"
      cmon = "03"
      cday = "22"
      csec = "22320"
      ;csec = "29520"
      ;csec = "32400"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

  runname = (/"cice6-develop", "cice6-Cgrid branch"/)
      rts = (/"dev/base.new/","cgrid/base.new/"/)
  ;runname = (/"rundir.base", "rundir.base.blockall"/)
  ;    rts = (/"rundir.base/","rundir.base.blockall/"/)

     ;files = addfiles(RT2+rts+cset+"history/iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc","r")
     ;files = addfiles(RT2+rts+cset+"ufs.cpld.cpl.hi.ice."+cyear+"-"+cmon+"-"+cday+"-"+csec+".nc","r")
     files = addfiles(RT2+rts+"ufs.cpld.cpl.hi.ice."+cyear+"-"+cmon+"-"+cday+"-"+csec+".nc","r")
     fland = addfile(RT2+rts(0)+"kmtu_cice_NEMS_mx100.nc","r")
     print(files)
     print(rts(1)+" - "+rts(0))
     plottitle=runname(1)+" - "+runname(0)

  ; ice fields
  iceflds = (/"iceImp_Fioi_taux",   \
              "iceImp_Fioi_tauy",   \
              "iceImp_Fioi_taux",   \
              "iceImp_Fioi_tauy"    \
              /)
  ;iceflds = (/"iceImp_Si_ifrac",   \
  ;            "iceImp_Si_vice",   \
  ;            "iceImp_Fioi_taux",  \
  ;            "iceImp_Fioi_tauy"   \
  ;            /)
  nflds = dimsizes(iceflds)

  ; easier plots
  icewgts = (/1.e0, \
              1.e0, \
  ;            1.e11, \
  ;            1.e16  \
              1.e0, \
              1.e0  \
              /)

  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.0,  1.0, 0.1/) ;
  plotlevs( 1,:) = (/  -1.0,  1.0, 0.1/) ;
  plotlevs( 2,:) = (/  -1.0,  1.0, 0.1/) ;
  plotlevs( 3,:) = (/  -1.0,  1.0, 0.1/) ;

  imask = tofloat(fland->kmt)
  colormap = "BlueDarkRed18"

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  wkstitle="ice_diff"
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  ;wkstype@wkWidth=800
  ;wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)
   plot = new(nflds,graphic)
    dum = new(nflds,graphic)
 
  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat
   res@mpCenterLonF = 0.0
  end if

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  ;print(pltlevs)
  ;print(palette)

  splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
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
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")+"@ "+csec+" secs "
  resP@gsnPanelMainString = plottitle

    ;labelstrings = new((/2/),string)
;************************************************
;
;************************************************
 
  do ii = 0,nflds-1
   if (ii .ge. 2)then
     minlat =  84.0
     res@mpMinLatF    =  minlat                    ; minimum lat to plot
   end if
   iname = iceflds(ii)
     wgt = icewgts(ii)
    levs = plotlevs(ii,:)
   res@gsnCenterString  = iname
   print("variable "+iname+"  weight "+wgt)

    ivar = files[1]->$iname$(lstep,:,:)-files[0]->$iname$(lstep,:,:)
    ivar = ivar*wgt
    ivar = mask(ivar, (imask .eq. 1.0), default_fillvalue(typeof(files[0]->$iname$)))
    ivar@lon2d = files[0]->$tlonname$(lstep,:,:)*rfactor
    ivar@lat2d = files[0]->$tlatname$(lstep,:,:)*rfactor

    plot(ii) = subplot(ii,iname,ivar(:,:),levs,colormap)
     dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  end do

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if
exit
end
