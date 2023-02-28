; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************

  ;MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_wavunstr/moddefs/"
  MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/addunstr.2acd891b.ww.33d337356/"

  scrpfile   = "trip1degmask.SCRIP.nc"
  sfile      = addfile(MD+scrpfile,"r")
  x          = sfile->grid_center_lon
  y          = sfile->grid_center_lat
  cx         = sfile->grid_corner_lon
  cy         = sfile->grid_corner_lat

  ; cheyenne
  ;RT1 = "/glade/scratch/worthen/WaveUnstr/"
  ; hera
  ;RT1 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_wavunstr2/"
  RT1="/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/addunstr.2acd891b.ww.33d337356/"

  gridtype  = "unstructured"
   ;plotlabs = "Card Deck Unstr 1deg 20PE"
   ; plotlabs = "Domain Decomp Unstr 1deg 3PE, iostyp 0"
  ;plotlabs ="atmw.pdlib.fix1"
  plotlabs = "test"

   ;     rts = "base48.dd30/"
   ;     rts = "base.dd3.iostyp0/"
   ; rts = "atmw.pdlib.fix1/"
  rts = "test/"

  date = "2021-03-22-"
  ;times = (/"59760","64080", "64800", "65520"/)
  ;times = (/"23760", "24480", "25200", "25920"/)
  times = (/"28080", "28800", "29520"/)
  ;fsrc = "ufs.atmw.ww3.hi."
  fsrc = "ufs.cpld.ww3.hi."
  timelabs = date+times

  fnames = RT1+rts+fsrc+date+times+".nc"
  files  = addfiles(fnames,"r")
  print(fnames)

  flds = (/"PHS"  , \
           "EF"   , \
           "HS"   , \
           "CHARN", \
           "USTX" , \
         "TAUWNY"   /)

  fldwgts = (/1.0, \
              1.0, \
              1.0, \
              1.0e2, \
              1.0,   \
              1.0e8  /)

  flddims = (/4, \
              4, \
              3, \
              3, \
              3, \
              3  /)

  lonname = "lon"
  latname = "lat"

  nflds = dimsizes(flds)
  nplots = dimsizes(times)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/   0.0,    0.5,  0.05/)   ; phs
  plotlevs( 1,:) = (/   0.0,    3.0,  0.05/)   ; ef, k=28
  plotlevs( 2,:) = (/   0.0,    1.0,  0.10/)   ; hs
  plotlevs( 3,:) = (/   0.9,    2.0,  0.02/)   ; charn
  plotlevs( 4,:) = (/  -1.0,    1.0,  0.10/)   ; ustx
  plotlevs( 5,:) = (/  -1.0,    1.0,  0.10/)   ; tauwnx

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 4
  levs = plotlevs(fldtoplot,:)
  wgt = fldwgts(fldtoplot)
  ndims = flddims(fldtoplot)
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
						; wkstype="png"
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
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 8
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

     klev=0
     ii = 0
     do ii = 0,nplots-1
          vname = flds(fldtoplot)
          if (gtype .eq. "structured")then
            if (ndims .eq. 4) then
              data = files[ii]->$vname$(0,klev,:,:)
            else
              data = files[ii]->$vname$(0,:,:)
           end if
           data = data*wgt
         else
           if (ndims .eq. 4) then
             data = files[ii]->$vname$(0,klev,0,:)
           else
             data = files[ii]->$vname$(0,0,:)
           end if
           data = data*wgt
           data@lon1d = files[ii]->$lonname$(0,:)
           data@lat1d = files[ii]->$latname$(0,:)
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
