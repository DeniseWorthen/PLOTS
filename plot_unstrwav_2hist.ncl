; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/"
  ; hera
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/atmwtrip/"

  ;polar="false"
  polar="true"
   minlat = 66.0
  ; zoom in
  ;minlat = 88.0
  ;minlat = 85.0

  gridtype = (/"unstructured" , "structured" /)
  plotlabs = (/"Unstr DomainDecomp", "Structured" /)
  rts =      (/"base.noresmP/", "base.mx100/"  /)

  date = "2021-03-25-"
  time = "21600"
  fsrc = "ufs.atmw.ww3.hi."

  fnames = RT1+rts+fsrc+date+time+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"EF"   , \
           "USSPX", \
           "ICE"  , \
           "USTX" , \
           "UAX"  , \
           "HS"/)

 fldwgts = (/1.0e10, \
             1.0e2,  \
             1.0e0,  \
             1.0e0,  \
             1.0e0,  \
             1.0e0   /)
  lonname = "lon"
  latname = "lat"

  nflds = dimsizes(flds)
  nplots = dimsizes(gridtype)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    3.0,  0.05/)   ; k=28
  ;plotlevs( 0,:) = (/   0.0,    2.0,  0.20/)   ; k=29
  ;plotlevs( 0,:) = (/   0.0,    1.0,  0.01/)   ; k=30
  plotlevs( 1,:) = (/   -2.0,    2.0,  0.02/)   ; k=3 stokes
  plotlevs( 2,:) = (/   0.0,    1.0,  0.1/)   ; ice
  plotlevs( 3,:) = (/  -1.0,    1.0,  0.1/)   ; ustx
  plotlevs( 4,:) = (/ -20.0,    20.0,  2./)   ; uax
  plotlevs( 5,:) = (/  0.0,    5.0,  0.5/)   ; hs
;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 5
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time

   cmap = "WhiteBlueGreenYellowRed"
 ;  cmap = "BlueWhiteOrangeRed"

   plottitle=flds(fldtoplot)

;************************************************
; define the map
;************************************************

  wkstype="X11"
 ; wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)       ; send graphics to X11 window
  ; drawNDCGrid(wks)
  plot = new(nplots,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label

  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  if(polar .eq. "true")then
    res@mpMinLatF    =  minlat                    ; minimum lat to plot
    res@mpCenterLonF = -45
    res@gsnPolar   =  "NH"                        ; specify the hemisphere
  else
    res@vpWidthF          = 0.70
    res@vpHeightF         = 0.40
  end if

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,gtype,pltvar,pltlevs,palette)
begin
  res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
  res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
  res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
  res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  res@cnFillPalette        = palette

  res@gsnCenterStringFontHeightF      = 0.012
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  if (gtype .eq. "unstructured") then
    res@sfElementNodes = files[ii]->nconn
    res@sfFirstNodeIndex = 1
    res@mpFillOn             = False
  else
    res@mpFillOn             = True
  end if
  res@mpOutlineOn          = False

  pltvar@units = ""
  pltvar@long_name = ""

  splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  ;resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015  ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

; ***************************************************
;
; ***************************************************

      ;k = 28
      do ii = 0,nplots-1
        vname = flds(fldtoplot)
        gtype = gridtype(ii)
        if (gtype .eq. "structured")then
        data = files[ii]->$vname$(0,:,:)
        data = data*wgt
        data@lon2d = files[ii]->$lonname$(:,:)
        data@lat2d = files[ii]->$latname$(:,:)
      else
        ;data = files[ii]->$vname$(0,k-1,0,:)
        data = files[ii]->$vname$(0,0,:)
        data = data*wgt
        data@lon1d = files[ii]->$lonname$(0,:)
        data@lat1d = files[ii]->$latname$(0,:)
      end if
      plot(ii) = subplot(ii,plotlabs(ii),gtype,data,levs,cmap)
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
