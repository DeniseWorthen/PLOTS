;***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

   RT1 = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/"
  ; hera
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/atmwtrip/"

     ;polar="false"
     polar="true"
      minlat = 66.0
     ; zoom in
     ;minlat = 80.0
     ;minlat = 89.4

   gridtype = (/"structured" , "unstructured" /)
  plotlabs = (/"MOM6 1deg-Tripole Grid ", "Unstructured 100K Nodes" /)
  rts =      (/"base.mx100/" , "base.noresm89.5/"  /)

  ;gridtype = (/"unstructured" , "unstructured" /)
  ;plotlabs = (/"89.7 ", "89.0" /)
  ;rts =      (/"base.noresmP/", "base.noresm89.5/"  /)

  date = "2021-03-26-"
  time = "21600"
  fsrc = "ufs.atmw.ww3.hi."

  fnames = RT1+rts+fsrc+date+time+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"EF"   , \
           "USSPY", \
           "ICE"  , \
           "USTX" , \
           "UAX"  , \
           "HS"   /)

 fldwgts = (/1.0e0, \
             1.0e2,  \
             1.0e0,  \
             1.0e0,  \
             1.0e0,  \
             1.0e0  /)
  lonname = "lon"
  latname = "lat"

  nflds = dimsizes(flds)
  nplots = dimsizes(gridtype)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    2.0,  0.05/)   ; k=28
  ;plotlevs( 0,:) = (/   0.0,    2.0,  0.20/)   ; k=29
  ;plotlevs( 0,:) = (/   0.0,    1.0,  0.01/)   ; k=30
  plotlevs( 1,:) = (/   -2.0,    2.0,  0.02/)   ; k=3 stokes
  plotlevs( 2,:) = (/   0.0,    1.0,  0.1/)   ; ice
  plotlevs( 3,:) = (/  -1.0,    1.0,  0.1/)   ; ustx
  plotlevs( 4,:) = (/ -20.0,    20.0,  2./)   ; uax
  plotlevs( 5,:) = (/ 0.0,    5.0,  0.2/)   ; hs
  ;plotlevs( 5,:) = (/ 0.0,    1.0,  0.01/)   ; hs
  ;plotlevs( 5,:) = (/0.0, 2.0, .02/); hs
;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 5
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time
  ;wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
 ;  cmap = "BlueWhiteOrangeRed"

   plottitle=flds(fldtoplot)

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=60.00
  lon2=-120.00
  lat1=60
  lat2=60

;************************************************
; Resources for the polyline
;************************************************
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  pres@tfPolyDrawOrder = "PreDraw"
  pres@mpGreatCircleLinesOn = True

;************************************************
; define the map
;************************************************

 ; wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)       ; send graphics to X11 window
  ; drawNDCGrid(wks)
  plot = new(nplots,graphic)
  dum = new(nplots,graphic)

  res                      = True		; plot mods desired
  res@gsnDraw              = False		; do not draw until the end
  res@gsnFrame             = False		; do not automatically advance 'frame'

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                 ; color fill
  res@cnLinesOn          = False                ; no contour lines
  res@cnLineLabelsOn     = False                ; no contour lines
  res@lbLabelBarOn       = False                ; turn off individual colorbars
  res@cnInfoLabelOn      = False		; turn off cn info label

  ;res@mpFillOn           = False
  ;res@mpOutlineOn        = False
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"
  if(gtype .eq. "unstructured") then
    res@sfElementNodes = files[ii]->nconn
    res@sfFirstNodeIndex = 1
  end if
  res@mpFillOn             = False
  res@mpOutlineOn          = False
  res@mpFillOn             = False

  if(polar .eq. "true")then
    res@mpMinLatF    =  minlat                    ; minimum lat to plot
    res@mpCenterLonF = -45
    res@gsnPolar   =  "NH"                        ; specify the hemisphere
  else
    res@vpWidthF          = 0.70
    res@vpHeightF         = 0.40
  end if

  res@gsnCenterStringFontHeightF      = 0.012
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  pltvar@units = ""
  pltvar@long_name = ""

  if(polar .eq. "true")then
    splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
    ;gsn_coordinates(wks,plot,data,mkres)
    if(gtype .eq. "structured")then
      dum = gsn_add_polyline(wks,splot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
    end if
  else
    splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  end if

;  if (gtype .eq. "structured") then
;    res@mpCenterLonF       = 180
;    res@mpFillOn           = False
;    res@mpOutlineOn        = False
;    splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
;    delete(res@mpCenterLonF)
;    delete(res@mpFillOn)
;    delete(res@mpOutlineOn)
;  else
 ;   splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
;  end if
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
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
  ;resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

;************************************************
; add coord marks
;************************************************

  mkres = True
  mkres@gsMarkerSizeF = 2.
  mkres@gsnFrame        = False
  mkres@gsnDraw         = False
  mkres@gsnCoordsAttach = True

; ***************************************************
;
; ***************************************************

      k = 28
      do ii = 0,nplots-1
        vname = flds(fldtoplot)
        gtype = gridtype(ii)
        if (gtype .eq. "structured")then
        data = files[ii]->$vname$(0,:,:)
        data = data*wgt
        data@lon2d = files[ii]->$lonname$(:,:)
        data@lat2d = files[ii]->$latname$(:,:)
      else
        ;printVarSummary(files[ii]->$vname$)
        ;data = files[ii]->$vname$(0,k-1,0,:)
        data = files[ii]->$vname$(0,0,:)
        data = data*wgt
        data@lon1d = files[ii]->$lonname$(0,:)
        data@lat1d = files[ii]->$latname$(0,:)
        mdata = data
        data = where(mdata@lat1d .ge. 89.0, mdata@_FillValue, mdata)
      end if
      plot(ii) = subplot(ii,plotlabs(ii),gtype,data,levs,cmap)
;      gsn_coordinates(wks,plot(ii),data,mkres)
;      if(gtype .eq. "structured")then
;        dum = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
;      end if

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
