; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  ; theia
  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  ;RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

 ; hemi = "NH"
 ; hemi = "SH"
  hemi = "none"

 rad2deg=180.d0/acos(-1.0d0)

 tlonname = "grid_xt"
 tlatname = "grid_yt"

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile5"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

  rts = (/"FMC_Testing/NEMS_upfv3_2"/)
  ;rts = (/"FMC_Testing/NEMS_Shan"/)
  ;rts = (/"FMC_Testing/NEMS_upfv3"/)
  ;rts = (/"scrub/NEMS_upfv3_minice"/)
  cset = "/2012070100_2d/tmp/cpld_fv3_384_mom6_cice_warm_bm2_nems/"

  filenames = (/"phyf006.","INPUT/oro_data."/)
     vnames = (/"land","slmsk"/)
  files=addfiles(RT1+rts+cset+filenames+tile+".nc","r")
  ;print(files)

  tilecorners = tilegrid(files[0]->$tlonname$*rad2deg,files[0]->$tlatname$*rad2deg,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
   ;minlat = tilecorners[1]
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

     rtname=rts(0)
         ii=str_index_of_substr(rtname,"/",-1)
  ;plottitle=str_get_cols(rtname,ii+1,strlen(rtname))
  plottitle=rtname
  wkstitle=str_get_cols(rtname,ii+1,strlen(rtname))+" "+tile

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle=tile
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    = minlat                          ; minimum lat to plot
    res@mpCenterLonF = midlon
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

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020

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
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")
  resP@gsnPanelMainString = plottitle

;************************************************
;
;************************************************

   colormap = "amwg"
    pltlevs = (/1.0,2.0,1.0/)

        ii = 0
   ; in phyf file
     vname = vnames(ii)
  ;res@gsnCenterString  = vname
        ivar = files[0]->$vname$(lstep,:,:)
  ivar@lon2d = files[0]->$tlonname$*rad2deg
  ivar@lat2d = files[0]->$tlatname$*rad2deg
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap,hemi)
  delete(ivar)

        ii = 1
  ; in oro data
     vname = vnames(ii)
  res@gsnCenterString  = vname
        ivar = files[1]->$vname$(:,:)
  ivar@lon2d = files[0]->$tlonname$*rad2deg
  ivar@lat2d = files[0]->$tlatname$*rad2deg
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap,hemi)

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
