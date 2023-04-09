;***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ;MD="/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/addunstr.2acd891b.ww.33d337356/moddefs/"
  MD="/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/"

  scrpfile   = "trip1degmask.SCRIP.nc"
  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

  ; cheyenne
 ;RT1 = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/"
  RT1 = "/glade/scratch/worthen/FV3_RT/"
  ; hera
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/addunstr.2acd891b.ww.33d337356/"

  cpltype = "ufs.atmw."
  ;cpltype = "ufs.cpld."

 gridtype  = "unstructured"
 plotlabs = "Domain Decomp Unstr 1deg 30PE, explicit"
 rts = "wisepr/base/"

 ;gridtype  = "unstructured"
 ;plotlabs = "Card Deck Unstr 1deg 30PE"
 ;rts = "ATMW/cd.base/"

 ;gridtype = "structured"
 ;plotlabs = "Card Deck Str 1deg 30PE"
 ;rts = "ATMW/str/"

  date = "2021-03-22-"
  ;times = (/"22320", "23040", "23760"/)
  ;times = (/"24480", "25200", "25920"/)  ; hour 7
  ;times = (/"28080", "28800", "29520"/) ; hour 8
  ;times = (/"38880", "39600", "40320"/) ; hour 11

  dt=720
  dtrest=3600
  time0=21600
  trest=time0+2*dtrest
  itimes = (/trest-dt, trest, trest+dt/)
  times = sprinti("%d", itimes)
  ;print(times)
  fsrc = cpltype+"cpl.hi.wav."

  timelabs = date+times

  fnames = RT1+rts+fsrc+date+times+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"wavImp_Sw_z0" ,  \
           "wavExp_Sa_u10m", \
           "wavExp_Sa_v10m"/)

  fldwgts = (/1.e3, \
              1., \
              1./)
  lonname = "wavImp_lon"
  latname = "wavImp_lat"

  nflds = dimsizes(flds)
  nplots = dimsizes(times)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/   0.0,    1.00,  0.01/)   ; z0
  plotlevs( 0,:) = (/   0.0,    0.5,  0.05/)   ; z0
  plotlevs( 1,:) = (/ -20.0,   20.0,  0.50/)   ; u10m
  plotlevs( 2,:) = (/ -20.0,   20.0,  0.50/)   ; v10m

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)
  gtype = gridtype
  ;wkstitle = plotlabs(0)

   cmap = "WhBlGrYeRe"
   ;cmap = "WhiteBlueGreenYellowRed"
   plottitle=flds(fldtoplot)+";  "+plotlabs

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"						; wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)       ; send graphics to X11 window
  ; drawNDCGrid(wks)
  plot = new(nplots,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  ;res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label

  ;res@mpFillOn           = False
  ;res@mpOutlineOn        = False
  ; res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; the subplot call
;************************************************
function subplot(ii,gtype,pltvar,pltlevs,palette)
begin
  res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
  res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
  res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
  res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  res@cnFillPalette        = palette

 if (gtype .eq. "unstructured") then
    res@sfXCellBounds = cx(:,0:5)
    res@sfYCellBounds = cy(:,0:5)
  end if

  pltvar@units = ""
  pltvar@long_name = ""

  splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  ;resP@gsnPanelYWhiteSpacePercent = 5
  ;resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  resP@gsnPanelFigureStrings = timelabs
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

; ***************************************************
;
; ***************************************************

     ii = 0
     do ii = 0,nplots-1
          vname = flds(fldtoplot)
          if (gtype .eq. "structured")then
           data = files[ii]->$vname$(0,:,:)
           data = data*wgt
         else
           data = files[ii]->$vname$(0,0,:)
           data = data*wgt
           data@lon1d = files[ii]->$lonname$(0,0,:)
           data@lat1d = files[ii]->$latname$(0,0,:)
         end if
         if (vname .eq. "wavImp_Sw_z0")then
           data = where(data .lt. 0.0 .or. data .gt. 1.0, default_fillvalue(typeof(data)), data)
         end if
          plot(ii) = subplot(ii,gtype,data,levs,cmap)
        delete(data)
     end do

;************************************************
; make the panel
;************************************************

   gsn_panel(wks,plot,(/nplots,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
