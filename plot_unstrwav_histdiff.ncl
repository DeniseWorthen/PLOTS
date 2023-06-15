; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  scrpfile = "trip1degmask.SCRIP.nc"
  ;MD = "/glade/scratch/worthen/WaveUnstr2/moddefs/"
  MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/cpldsandbox/"

  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

  ; cheyenne
  ;RT1 = "/glade/scratch/worthen/WaveUnstr2/"
  ; hera
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/atmwtrip/"
  RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/cpldsandbox/"

  gridtype  = (/"unstructured", "unstructured"  /)
  plotlabs = (/"Unstr DomainDecomp, 2PE", "Unstr Domain Decomp, 3PE"/)
  rts = (/"base/", "mpi/"/)

  date = "2021-03-22-"
  time = "24480"
  fsrc = "ufs.cpld.ww3.hi."

  fnames = RT1+rts+fsrc+date+time+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"EF", \
           "HS"/)
  fldwgts = (/1.0e11, \
              1.e5/)
  lonname = "lon"
  latname = "lat"

  nflds = dimsizes(flds)
  nplots = dimsizes(gridtype)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    0.5,  0.01/)   ; k=28
  ;plotlevs( 0,:) = (/   0.0,    2.0,  0.20/)   ; k=29
  ;plotlevs( 0,:) = (/   0.0,    1.0,  0.01/)   ; k=30
  plotlevs( 1,:) = (/   -0.1,    0.1,  0.01/)   ; hw

  fdecomp = "emesh.decomp.nc"
  decomps  = addfiles(RT1+rts+fdecomp,"r")
  print(decomps)

  fdof = "dof.wav.nc"
  dofs = addfiles(RT1+rts+fdof,"r")
  print(dofs)

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 1
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  wkstitle = flds(fldtoplot)+"_"+date+time
  ;wkstitle = plotlabs(0)

   cmap = "WhiteBlueGreenYellowRed"
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
  plot = new(2,graphic)
  oplot = new(2,graphic)

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

  if (gtype .eq. "unstructured") then
    res@sfXCellBounds = cx(:,0:5)
    res@sfYCellBounds = cy(:,0:5)
  end if

  res@gsnCenterStringFontHeightF      = 0.012
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = -.05

  pltvar@units = ""
  pltvar@long_name = ""

  if (gtype .eq. "structured") then
    res@mpCenterLonF       = 180
    res@mpFillOn           = False
    res@mpOutlineOn        = False
    splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
    delete(res@mpCenterLonF)
    delete(res@mpFillOn)
    delete(res@mpOutlineOn)
  else
    splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  end if
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""

  ores@cnLineThicknessF = 1.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ores@cnLineLabelsOn   = False
  ores@cnFillOn         = False
  ores@cnLinesOn        = True
  ores@cnInfoLabelOn    = False
  ores@cnLevelSelectionMode = "ExplicitLevels"
  ores@cnLevels = (/1,2,3,4/)
  ;ores@cnMinLevelValF       = 1.               ; min level
  ;ores@cnMaxLevelValF       = 4                ; max level
  ;ores@cnLevelSpacingF      = 1                ; contour interval

; ***************************************************
; panel resources
; **************************************************

  resP                       = True     ; modify the panel plot
  resP@gsnMaximize           = True     ; maximize in frame
  resP@gsnFrame              = False    ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 8
  resP@gsnPanelLabelBar      = True     ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
  resP@gsnMaximize        = True        ; use full page

  resP@gsnPanelFigureStrings = (/date+time,date+time,date+time/)
  resP@amJust = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.008

; ***************************************************
;
; ***************************************************

  ii=0
  ;k = 28
  do ii = 0,nplots-1
    vname = flds(fldtoplot)
    gtype = gridtype(ii)
    ;data = files[1]->$vname$(0,k-1,0,:)-files[0]->$vname$(0,k-1,0,:)
    data = files[1]->$vname$(0,0,:)-files[0]->$vname$(0,0,:)
    data = abs(data)*wgt
    data@lon1d = files[0]->$lonname$(0,:)
    data@lat1d = files[0]->$latname$(0,:)
    plot(ii) = subplot(ii,plotlabs(nplots-1)+" - "+plotlabs(0),gtype,data,levs,cmap)

    ;dcmp = decomps[ii]->decomp(:)
    ;dof = dofs[ii]->dof
    ;  ip = dim_pqsort(dof,1)
    ;  var1d_sort = dcmp
    ;  var1d_sort = dcmp(ip)
    ;  dcmp       = var1d_sort
    ;  dcmp@lon1d = x
    ;  dcmp@lat1d = y
    ;  ores@sfXCellBounds = cx(:,0:5)
    ;  ores@sfYCellBounds = cy(:,0:5)
    ;  oplot(ii) = gsn_csm_contour(wks,dcmp,ores)
    ;  overlay(plot(ii),oplot(ii))
  end do

;************************************************
; make the panel
;************************************************

   ;gsn_panel(wks,plot,(/nplots,1/),resP)
   gsn_panel(wks,plot,(/1,1/),resP)

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
