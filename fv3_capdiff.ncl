;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "tilegrid.ncl"

;************************************************

  ; cheyenne
  ;RT1 = "/glade/scratch/worthen/cmepsfracColdRuns/"
  RT1 = "/glade/scratch/worthen/nemsfracColdRuns/"

  hemi = "NH"
 ; hemi = "SH"
 ; hemi = "none"

 rad2deg=180.d0/acos(-1.0d0)

 tlonname = "grid_xt"
 tlatname = "grid_yt"

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile2"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

  cyear = "2012"
   cmon = "01"
   cday = "01"
  ; time = "00:07:30"
   time = "02:00:00"
  cdate = cyear+"-"+cmon+"-"+cday
  ; for grid info
  model = "phyf000."
  state = "export"

  ; difference fields have been made "FracF - FracT"
  fatm=addfile(RT1+"fv3_cap_"+state+"_"+cdate+"T"+time+"_"+tile+".nc","r")
  print(fatm)
  gf = addfile(RT1+"fracT/phyf000."+tile+".nc","r")

  tilecorners = tilegrid(gf->$tlonname$,gf->$tlatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
   print(tile)
   print(minlat+"   "+maxlat)
   print(minlon+"   "+maxlon+"  "+midlon+"  "+0.5*(maxlon - minlon))
  else
   if(hemi .eq. "NH")then
    minlat =  40.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  plottitle="FV3 "+state+" difference: FracF - FracT at "+time+" on "+tile

  ; fv3 cap export fields
  fv3exportflds = (/"inst_temp_height_lowest",        \
                    "inst_pres_height_lowest",        \
                    "inst_spec_humid_height_lowest",  \
                    "mean_down_lw_flx",               \
                    "mean_laten_heat_flx",            \
                    "mean_sensi_heat_flx",            \
                    "mean_zonal_moment_flx_atm",      \
                    "mean_merid_moment_flx_atm"       \
              /)

  atmwgts = (/1.0, \
              1.0, \
              1.e4, \
              1.0, \
              1.0, \
              1.0, \
              1.0e3, \
              1.0e3/)

  nflds = dimsizes(fv3exportflds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -2.0,  2.0, 0.20/)   ; tlowest
  plotlevs( 1,:) = (/ -10.0, 10.0, 0.50/)   ; plowest
  plotlevs( 2,:) = (/  -1.0, 1.0,  0.1/)    ; qlowest *1e4
  plotlevs( 3,:) = (/ -20.0, 20.0, 1.0/)    ; lw down
  plotlevs( 4,:) = (/ -20.0, 20.0, 1.0/)    ; latent 
  plotlevs( 5,:) = (/ -10.0, 10.0, 0.5/)    ; sensi 
  plotlevs( 6,:) = (/  -1.0,  1.0, 0.10/)   ; zonal flx *1e3
  plotlevs( 7,:) = (/  -1.0,  1.0, 0.10/)   ; merid flx *1e3

  cmap="BlueWhiteOrangeRed"

  ; which to plot
  flds = (/0,1,2,3,4,5,6,7/)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="fv3_diff_"+tile+"_"+time
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)
  plot = new(nflds,graphic)
   dum = new(nflds,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode  = "RasterFill"
  res@mpFillOn    = False
  res@mpOutlineOn = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
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

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020     

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
; the subplot call
;************************************************
function subplot(ii,vname,pltvar,pltlevs,palette,hemi)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette
    res@gsnCenterStringFontHeightF = 0.030
   if(hemi .eq. "none" .or. hemi .eq. "global")then
    res@gsnCenterStringFontHeightF = 0.025
   end if
   res@gsnCenterString      = vname

  if(hemi .eq. "none" .or. hemi .eq. "global")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  return(splot)
end
;***************************************************
;
;***************************************************

  do kk = 0,dimsizes(flds)-1
  fldtoplot = flds(kk)
       awgt = atmwgts(kk)
       levs = plotlevs(fldtoplot,:)
    fldname = fv3exportflds(fldtoplot)
  print(kk+" "+fldname)

  afld = fatm->$fldname$(:,:)
  afld = afld*awgt
  afld@lon2d = gf->$tlonname$
  afld@lat2d = gf->$tlatname$

  labstr = fldname
  if(awgt .ne. 1.0)then
   labstr = fldname + "*"+awgt
  end if

  plot(kk) = subplot(kk,labstr,afld,levs,cmap,hemi)
  end do

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/3,3/),resP)

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
