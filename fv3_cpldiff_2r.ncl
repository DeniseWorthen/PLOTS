;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "tilegrid.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/cmeps/"
 plotlabs = (/"CMEPS"/)
      rts = (/""/)

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
   time = "07200"
  cdate = cyear+"-"+cmon+"-"+cday
; state here is relative to the mediator
; export => sent by mediator
; import => received by mediator
  state = "import"

  ; difference fields have been made "FracF - FracT"
  atmfile=addfile(RT1+rts+"diff-"+time+"."+tile+".nc","r")
  ; grid info can't come from the difference file
       gf=addfile(RT1+rts+"fracT/ufs.cpl.hi-"+time+"."+tile+".nc","r")

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

  plottitle="Mediator "+state+" difference: FracF - FracT at "+time+" on "+tile

;************************************************
;  atmImp fields (these are exported from FV3)
;************************************************

  fv3exportflds = (/"atmImp_Sa_tbot",        \
                    "atmImp_Sa_pbot",        \
                    "atmImp_Sa_shum",        \
                    "atmImp_Faxa_lwdn",      \
                    "atmImp_Faxa_lat",       \
                    "atmImp_Faxa_sen",       \
                    "atmImp_Faxa_tauy",      \
                    "atmImp_Faxa_taux"       \
              /)

  expwgts = (/1.0, \
              1.0, \
              1.e4, \
              1.0, \
              1.0, \
              1.0, \
              1.0e3, \
              1.0e3/)
  nexpflds = dimsizes(fv3exportflds)
  ;print(nexpflds)

  ; plot levels
  exp_plotlevs = new((/nexpflds,3/), float)
  exp_plotlevs( 0,:) = (/  -1.0,  1.0, 0.10/)   ; tlowest
  exp_plotlevs( 1,:) = (/  -0.1,  0.1, 0.01/)   ; plowest
  exp_plotlevs( 2,:) = (/  -1.0, 1.0,  0.1/)    ; qlowest *1e4
  exp_plotlevs( 3,:) = (/ -10.0, 10.0, 1.0/)    ; lw down
  exp_plotlevs( 4,:) = (/ -20.0, 20.0, 1.0/)    ; latent 
  exp_plotlevs( 5,:) = (/ -10.0, 10.0, 0.5/)    ; sensi 
  exp_plotlevs( 6,:) = (/  -1.0,  1.0, 0.10/)   ; merid flx *1e3
  exp_plotlevs( 7,:) = (/  -1.0,  1.0, 0.10/)   ; zonal flx *1e3

;************************************************
;  atmExp fields (these are imported by FV3)
;************************************************

  fv3importflds = (/"atmExp_Si_ifrac",       \
                    "atmExp_Faii_lat",       \
                    "atmExp_Faii_sen",       \
                    "atmExp_Faii_lwup",      \
                    "atmExp_Si_t",           \
                    "atmExp_So_t",           \
                    "atmExp_Faii_tauy",      \
                    "atmExp_Faii_taux"       \
              /)

  nimpflds = dimsizes(fv3importflds)

  impwgts = (/1.0e5, \  ; ice frac
              1.0e2, \    ; latent
              1.0e2, \   ; sensi
              1.0e3, \    ; lw up
              1.0e2, \  ; t ice sfc
              1.0e2, \  ; sst
              1.0e3, \  ; merid flx *1e3
              1.0e3/)   ; zonal flx *1e3
  nimpflds = dimsizes(fv3importflds)
  ;print(nimpflds)

  ; plot levels
  imp_plotlevs = new((/nimpflds,3/), float)
  imp_plotlevs( 0,:) = (/  -0.2,  0.2, 0.02/)   ; ice_frac
  imp_plotlevs( 1,:) = (/ -20.0, 20.0, 1.0/)    ; latent
  imp_plotlevs( 2,:) = (/ -10.0, 10.0, 0.5/)    ; sensi
  imp_plotlevs( 3,:) = (/ -20.0, 20.0, 1.0/)    ; lw up
  imp_plotlevs( 4,:) = (/  -2.0,  2.0, 0.2/)    ; t ice sfc
  imp_plotlevs( 5,:) = (/  -2.0,  2.0, 0.2/)    ; sst
  imp_plotlevs( 6,:) = (/  -1.0,  1.0, 0.10/)   ; merid flx *1e3
  imp_plotlevs( 7,:) = (/  -1.0,  1.0, 0.10/)   ; zonal flx *1e3

  cmap="BlueWhiteOrangeRed"

;************************************************
; state here is relative to the mediator
; the mediator import state = atm export
; the mediator export state = atm import
;************************************************
 
   if(state .eq. "import")then
     fv3flds = fv3exportflds
     atmwgts = expwgts
    plotlevs = exp_plotlevs
        ;flds = ispan(0,nimpflds-1,1)
        flds = (/4,5/)
   else
     fv3flds = fv3importflds
     atmwgts = impwgts
    plotlevs = imp_plotlevs
        flds = ispan(0,nexpflds-1,1)
        ; flds = (/5/)
   end if 
     npanels = dimsizes(flds)

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
  plot = new(npanels,graphic)

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

  ;res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  ;res@gsnCenterStringFontHeightF = 0.030
  res@lbLabelFontHeightF         = 0.025     

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
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
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
    res@gsnCenterStringFontHeightF = 0.025
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

 jj = 0
 do kk = 0,npanels-1
  fldtoplot = flds(kk)
       awgt = atmwgts(fldtoplot)
       levs = plotlevs(fldtoplot,:)
    fldname = fv3flds(fldtoplot)

  do ii = 0,dimsizes(rts)-1
   afld = atmfile->$fldname$(:,:)
   afld = afld*awgt
   afld@lon2d = gf->$tlonname$
   afld@lat2d = gf->$tlatname$
   ;labstr = rts(ii)+" "+fldname
   labstr = fldname
   if(awgt .ne. 1.0)then
    labstr = labstr+"*"+awgt
   end if

   plot(jj) = subplot(kk,labstr,afld,levs,cmap,hemi)
   print(jj+" "+fldname+" "+rts(ii))
   jj = jj+1
  end do
 end do

;************************************************
; make the panel
;************************************************

  if(npanels .eq. 1)then
   gsn_panel(wks,plot,(/1,1/),resP)
  else 
   if(npanels .ge. 8)then
    ncols = 3
    nrows = 3
    gsn_panel(wks,plot,(/3,3/),resP)
   else
    ncols = 2
    nrows = npanels/ncols
    gsn_panel(wks,plot,(/nrows,ncols/),resP)
   end if
  end if

  ;gsn_panel(wks,plot,(/1,2/),resP)
  ;gsn_panel(wks,plot,(/3,3/),resP)

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.015                    ; font smaller. default big

; page coordinates are normalized. go from 0->1 not 0->8" etc.
  ;gsn_text_ndc(wks,rts(0),0.30,0.98,txres)
  ;gsn_text_ndc(wks,rts(1),0.75,0.98,txres)

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
