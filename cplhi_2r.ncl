;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  ; orion
  RT1 = "/work/noaa/stmp/dworthen/stmp/dworthen/S2S_RT/"

 cyear = "2013"
  imon = "07"
  cmon = "07"
  cday = "02"
  csec = "00000"
 cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

 plotlabs = (/"cice5", "cice6"/)
      rts = (/"cice5_1d/", "cice6_1d/"/)
     cset = "cpld_fv3_ccpp_384_mom6_cice_cmeps_35d_"+cyear+imon+"0100/"
 pltlab0 = plotlabs(1)+" - "+plotlabs(0)
 print(cset)

  hemi = "NH"
  ;hemi = "SH"
  ; none not workin yet
  ;hemi = "none"

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   minlon =   0.0
   minlat = -60.0
   maxlon = 360.0
   maxlat =  60.0
   midlon = minlon + 0.5*(maxlon - minlon)
  else 
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

;************************************************
;
;************************************************

  fldtyp = "iceImp"
    flds = (/"Fioi_swpen_vdr"  \
             /)

  nflds = dimsizes(flds)
  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs(0,:) = (/0.0, 10.0, 0.50/)

  ;default
  cmap="amwg256"

;************************************************
;
;************************************************

  print(RT1+rts+cset+"ufs.s2s.cpl.hi."+cdate+".nc")
  cplfiles = addfiles(RT1+rts+cset+"ufs.s2s.cpl.hi."+cdate+".nc","r")

   latname = fldtyp+"_lat"
   lonname = fldtyp+"_lon"
      lons = cplfiles[0]->$lonname$(0,:,:)
      lats = cplfiles[0]->$latname$(0,:,:)

   wkstitle = "test"

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False

  res@tiMainFontHeightF = .010
  ;res@tiMainString = plottitle

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
  ;resP@gsnPanelMainString = fldname+"  "+pltlab0+" "+cdate

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

   if(hemi .ne. "none")then
    res@gsnPolar   =  hemi                         ; specify the hemisphere
    if(hemi .eq. "NH")then
     res@mpMinLatF    =  lat0                          ; minimum lat to plot
     res@mpCenterLonF =  lon0
    end if
    if(hemi .eq. "SH")then
    res@mpMaxLatF    = lat0                            ; minimum lat to plot
    res@mpCenterLonF = lon0
    end if
   end if

  if(hemi .eq. "none")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if

   delete(res@mpMinLatF)
   delete(res@mpMaxLatF)
  return(splot)
end
;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = fldtyp+"_"+flds(fldtoplot)
  plottitle = plotlabs(1)+"-"+plotlabs(0)+" fldtype "+fldname

       fvar = cplfiles[0]->$fldname$(0,:,:) 
  fvar@lon2d = lons
  fvar@lat2d = lats
  
  ii = 0
  plot(ii) = subplot(ii,pltlab0,fvar,levs,cmap,hemi,minlat,midlon)

  ii = 1
       fvar = cplfiles[1]->$fldname$(0,:,:)
  fvar@lon2d = lons
  fvar@lat2d = lats

  plot(ii) = subplot(ii,pltlab0,fvar,levs,cmap,hemi,minlat,midlon)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)
  ;gsn_panel(wks,plot,(/1,1/),resP)

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
