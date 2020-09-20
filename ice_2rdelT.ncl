;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

     lstep = 1-1
     cyear = "2012"
      cmon = "01"
      cday = "03"
     chour = "00000"
     idate = cyear+cmon+"0100"

 plotlabs = (/"feature/punyswrad","rhoa"/)
      rts = (/"S2S_upcice5/2012_5d/tmp",\
              "S2S_upcice5/rtgen.194255/tmp"/)
    csets = (/"/cpld_fv3_ccpp_384_mom6_cice_5d_"+idate+"/",\
              "/cpld_fv3_ccpp_384_mom6_cice_5d_"+idate+"/"/)

;************************************************
;
;************************************************


   icefiles = addfiles(RT4+rts+csets+"history/iceh_inst."+cyear+"-"+cmon+"-"+cday+"-"+chour+".nc","r")
     iceics = addfiles(RT4+rts+csets+"history/iceh_ic."+cyear+"-"+cmon+"-"+"01-00000.nc","r")
   ;ListSetType(icefiles,"cat")
   ;ListSetType(iceics,"cat")

  ; ice fields
  iceflds = (/"aice",   \
              "hi",     \
              "Tsfc",   \
              "snow",   \
              "flwup",  \
              "flat",   \
              "fsens",  \
              "fswdn",  \
              "flwdn",  \
              "fresh"   \
              /) 
  nflds = dimsizes(iceflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -0.5,  0.5, 0.05/)   ; ai
  plotlevs( 1,:) = (/  -0.2,  0.2, 0.02/)   ; hi
  plotlevs( 2,:) = (/ -20.0, 20.0, 2.00/)   ; tsfc
  plotlevs( 3,:) = (/  -1.0,  1.0, 0.10/)   ; snow fall
  plotlevs( 4,:) = (/-120.0,120.0,10.00/)   ; lwup
  plotlevs( 5,:) = (/ -40.0, 40.0, 2.00/)  ; latent
  plotlevs( 6,:) = (/ -40.0, 40.0, 2.00/)  ; sensible
  plotlevs( 7,:) = (/-240.0,240.0,20.00/)  ; SW
  plotlevs( 8,:) = (/-100.0,100.0,10.00/)  ; LW
  plotlevs( 9,:) = (/  -4.0,  4.0, 0.20/)  ; fresh
  
  cmap="BlueWhiteOrangeRed"

;************************************************
;  Ice lats/lons and mask
;************************************************
  
   ilonname = "TLON"
   ilatname = "TLAT"
  ilandname = "tmask"

    icelons = icefiles[0]->$ilonname$
    icelats = icefiles[0]->$ilatname$
      iland = icefiles[0]->$ilandname$

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot =0
       levs = plotlevs(fldtoplot,:)
    fldname = iceflds(fldtoplot)+"_h"
 icfldname = iceflds(fldtoplot)
   wkstitle = fldname+"_"+idate
 print(wkstitle)

 itmp = iceics[0]->$icfldname$(0,:,:)
 plottitle=itmp@long_name
 delete(itmp)

  ; special settings
      iwgt = 1.0
  if(fldname .eq. "fsalt")then   ; make levels easier
       iwgt = 1.0e-2
  end if

  ;TOD diff from IC
  idiff0 = icefiles[0]->$fldname$(0,:,:) - iceics[0]->$icfldname$(0,:,:)
  idiff0 = idiff0*iwgt
  idiff0@lon2d = icelons
  idiff0@lat2d = icelats
 pltlab0 = plotlabs(0)

  ;update case diff from IC
  idiff1 = icefiles[1]->$fldname$(0,:,:) - iceics[1]->$icfldname$(0,:,:)
  idiff1 = idiff1*iwgt
  idiff1@lon2d = icelons
  idiff1@lat2d = icelats
 pltlab1 = plotlabs(1)
 ;printVarSummary(idiff0)

  if(fldname .eq. "fsalt_h")then   ; make levels easier
   idiff0@units = "g/m2/s"
  end if

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(4,graphic)
  ;drawNDCGrid(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False
  res@lbLabelBarOn  = False                 ; turn off individual colorbars

  res@cnFillOn           = True
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines

  res@gsnStringFontHeightF = 0.01

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette,hemi,lat0,lon0)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

    res@gsnPolar   =  hemi                         ; specify the hemisphere
    res@mpCenterLonF = lon0
   if(hemi .eq. "NH")then
    res@mpMinLatF    = lat0                       ; minimum lat to plot
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = lat0                           ; minimum lat to plot
   end if

  ;res@gsnCenterStringFontHeightF      = 0.020
  ;res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = 0.12

   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
   delete(res@mpMinLatF)
   delete(res@mpMaxLatF)
  return(splot)
end

; ***************************************************
;
; ***************************************************

  ; TOD diffs
    hemi = "NH"
  minlat =  66.0
  midlon = -45.0
  ii = 0
  plot(ii) = subplot(ii,plotlabs(0),idiff0,levs,cmap,hemi,minlat,midlon)

    hemi = "SH"
  maxlat = -50.0
  midlon =   0.0
  ii = 1
  plot(ii) = subplot(ii,plotlabs(0),idiff0,levs,cmap,hemi,maxlat,midlon)

  ; update case diffs
    hemi = "NH"
  minlat =  66.0
  midlon = -45.0
  ii = 2
  plot(ii) = subplot(ii,plotlabs(1),idiff1,levs,cmap,hemi,minlat,midlon)

    hemi = "SH"
  maxlat = -50.0
  midlon =   0.0
  ii = 3
  plot(ii) = subplot(ii,plotlabs(1),idiff1,levs,cmap,hemi,maxlat,midlon)

;************************************************
; Draw text on plot using NDC coordinates
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.02                     ; font smaller. default big

  gsn_text_ndc(wks,plotlabs(0),0.5,0.9,txres) 
  gsn_text_ndc(wks,plotlabs(1),0.5,0.5,txres) 
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle+" difference at 5d from IC at "+cyear+cmon+"01"
;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
