; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ; cheyenne
  RT1 = "/glade/scratch/worthen/WaveUnstr/"

 ;makediff = "yes"
 makediff = "no"
 ;plotlabs = (/"Unstr CardDeck 2PE","Unstr CardDeck 3PE"/)
 ;     rts = (/"unstr2PE/","unstr3PE/"/)
 plotlabs = (/"Unstr land DD 2PE","Unstr no land DD 2PE"/)
      rts = (/"pdlib2PE/","pdlibnoland2PE/"/)
 ;plotlabs = (/"Unstr CardDeck 3PE","Str CardDeck 3PE"/)
 ;     rts = (/"unstr3PE/","str3PE/"/)

  ; structured grid
  ;ndims = 3
  ; unstructured meshes
  ndims = 2

  date = "2021-03-22-"
  time = "25200"
  fsrc = "ufs.atmw.cpl.hi.wav."

  fname0 = RT1+rts(0)+fsrc+date+time+".nc"
  fname1 = RT1+rts(1)+fsrc+date+time+".nc"
  files0 = addfile(fname0,"r")
  files1 = addfile(fname1,"r")
  print(fname0)
  print(fname1)

  flds = (/"wavImp_Sw_z0"/)
  fldwgts = (/1.e3/)
  lonname = "wavImp_lon"
  latname = "wavImp_lat"

  nflds = dimsizes(flds)

  ; plot levels
  plotlevs = new((/nflds,3/), float)

  if (makediff .eq. "yes") then
    plotlevs( 0,:) = (/   -1.0,    1.0,  0.01/)   ; z0 diff
  else
    plotlevs( 0,:) = (/   0.0,    0.5,  0.005/)   ; z0
  end if

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 0
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time
  ;wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
   ;plottitle="Exported "+flds(fldtoplot)+"(*"+sprintf("%5.0e", wgt)+")"
   plottitle=flds(fldtoplot)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;drawNDCGrid(wks)
  if (makediff .eq. "yes")then
    plot = new(1,graphic)
    oplot = new(1,graphic)
  else
    plot = new(2,graphic)
  end if

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@cnInfoLabelOn      = False           ; turn off cn info label

  res@mpFillOn           = True
  res@mpOutlineOn        = False

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue


  ;res@mpMinLatF            = -40      ; range to zoom in on
  ;res@mpMaxLatF            = -30.
  ;res@mpMinLonF            = -95.
  ;res@mpMaxLonF            = -80.

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            = 0.
  ;res@mpMinLonF            = 30.
  ;res@mpMaxLonF            = 60.

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            = 0.
  ;res@mpMinLonF            = -90.
  ;res@mpMaxLonF            = 60.
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

  res@cnMissingValFillColor    = "gray70" ; set color for missing areas

  res@gsnCenterStringFontHeightF      = 0.010
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  return(splot)
end
;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 1.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ores@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/1,5,1/)
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = True                  ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True                   ; use full page

  resP@gsnPanelFigureStrings = (/date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.01
; ***************************************************
;
; ***************************************************

    if (makediff .eq. "yes") then
      cmap = "BlWhRe"
      ii = 0
      name = flds(fldtoplot)
      if (ndims .eq. "2")then        ; (nx,ny=1,time)
        f3 = 1.0e12*(files1->$name$(0,0,:) - files0->$name$(0,0,:))
        f3@lon1d =  files1->$lonname$(0,0,:)
        f3@lat1d =  files1->$latname$(0,0,:)
      end if
      plot(ii) = subplot(ii,plotlabs(1)+" - "+plotlabs(0),wgt*f3,levs,cmap)

      oplot(ii) = gsn_csm_contour(wks,fdecomp,ores)
      overlay(plot(ii),oplot(ii))
    else
      ii = 0
      name = flds(fldtoplot)
      print("variable "+name+" containing dimensions contains ndims = "+ndims)
      if (ndims .eq. 3) then
        f0 = files0->$name$(0,:,:)
        f0 = f0*wgt
        f0@lon2d = files0->$lonname$(:,:)
        f0@lat2d = files0->$latname$(:,:)
      else
        f0 = files0->$name$(0,0,:)
        f0 = f0*wgt
        f0@lon1d = files0->$lonname$(0,0,:)
        f0@lat1d = files0->$latname$(0,0,:)
      end if
      ;printVarSummary(files0->lat)
      plot(ii) = subplot(ii,plotlabs(ii),f0,levs,cmap)

      ii = 1
      dims = dimsizes(files1->$name$)
      print("variable "+name+" containing dimensions contains ndims = "+ndims)
      if (ndims .eq. 3) then
        f1 = files1->$name$(0,:,:)
        f1 = f1*wgt
        f1@lon2d = files1->$lonname$(:,:)
        f1@lat2d = files1->$latname$(:,:)
      ;printVarSummary(files1->lat)
      else
        f1 = files1->$name$(0,0,:)
        f1 = f1*wgt
        f1@lon1d = files1->$lonname$(0,0,:)
        f1@lat1d = files1->$latname$(0,0,:)
      end if
      plot(ii) = subplot(ii,plotlabs(ii),f1,levs,cmap)
    end if

;************************************************
; make the panel
;************************************************

  if (makediff .eq. "yes") then
   gsn_panel(wks,plot,(/1,1/),resP)
  else
   gsn_panel(wks,plot,(/2,1/),resP)
  end if
  ;gsn_panel(wks,plot,(/1,1/),resP)

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
