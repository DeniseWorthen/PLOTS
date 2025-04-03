;**********************************************************

;**********************************************************
begin

 RT="/work2/noaa/stmp/dworthen/stmp/dworthen/maskchange/"

 dirs = (/"base/cpld_control_gfsv17_intel/", "mask/cpld_control_gfsv17_intel/"/)
 plotlabs = (/"base","mask"/)

 ;gridtype = "unstructured"
  gridtype = "structured"
  vname = "dstocn_atm_ocn_consf"

  fsrc = "ufs.cpld.dststatus.nc"
  fnames = RT+dirs+fsrc
  print("input file "+fnames)
  ff = addfiles(fnames,"r")

  dstdiff = abs(ff[1]->$vname$(:,:) - ff[0]->$vname$(:,:))

  x1d = ndtooned(dstdiff)
  indxs = ind_resolve(ind(x1d .gt. 0.),dimsizes(dstdiff))
  ;printVarSummary(data)
  print(dimsizes(indxs))
  jlocs = indxs(:,0)
  ilocs = indxs(:,1)
  npts = dimsizes(ilocs)

  print(npts)
  print(ilocs+"  "+jlocs)

  delete(fnames)
  delete(ff)
  delete(vname)

  print(indxs)
  vname="iceExp_Sa_tbot"
  fnames = RT+dirs+plotlabs+".hi.ice.nc"
  ff = addfiles(fnames,"r")
  print(fnames)
  time = ff[0]->time

  x1 = ndtooned(ff[0]->$vname$)

  ;pts1 = new((/npts



;   if (gridtype .eq. "unstructured") then
;    data = ff->$vname$(0,:)
;    data@lat1d = ff->$latname$(0,:)
;    data@lon1d = ff->$lonname$(0,:)
;  else
;    ;ib=800
;    ;ie=1400
;    ;jb=400
;    ;je=719
;    ;data = ff->$vname$(jb:je,ib:ie)
;    ;data@lat2d = ff->$latname$(jb:je,ib:ie)
;    ;data@lon2d = ff->$lonname$(jb:je,ib:ie)
;    data = ff->$vname$(:,:)
;    ;data@lat2d = ff->$latname$(:,:)
;    ;data@lon2d = ff->$lonname$(:,:)
;  end if

;  printVarSummary(data)

;  total = 0
;  ;do i = 0,nflags-1
;  ;  total = total+dststatus_counts(data,i)
;  ;end do
;  ;print("total count of all dststatus types = "+total+" size of data = "+dimsizes(data))
;   ;palette = "ncv_roullet"
;     ;palette = "amwg"
;     ;palette="WhBlGrYeRe"
;     ;palette="NCV_jet"

;    plotlab = plotlabs(0)
;    nplots = 1

; ;************************************************
; ; define the map
; ;************************************************

      wkstitle="test"
      wkstype="X11"
;      ;wkstype="png"
      wkstype@wkWidth=800
      wkstype@wkHeight=800

      ;plot = new(nplots,graphic)

      wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window
      ;plot = gsn_csm_contour(wks,data,False)


;      gsn_define_colormap(wks, "amwg_blueyellowred")

;      plot = new(nplots,graphic)
;      res                      = True        ; plot mods desired
;      res@gsnDraw              = False       ; do not draw until the end
;      res@gsnFrame             = False       ; do not automatically advance 'frame'

;      ;res@cnFillMode = "MeshFill"
;      res@cnFillMode = "RasterFill"

;      plot = new(1,graphic)

;   res@vpWidthF          = 0.70
;   res@vpHeightF         = 0.60

;   res@gsnStringFontHeightF = 0.01
;   res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
;   res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
;   res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
;   res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;   res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
;   res@cnFillOn          = True                  ; color fill
;   res@cnLinesOn         = False                 ; no contour lines
;   res@cnLineLabelsOn    = False
;   res@cnInfoLabelOn      = False
;   res@lbLabelBarOn      = True
;   res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
;   res@lbLabelAlignment = "BoxCenters"

;   res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
;   res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
;   res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
;   res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
;   ;res@cnFillPalette   = "amwg"
;   ;res@cnFillPalette   = "sunshine_9lev"
;   ;res@cnFillPalette   = "GMT_paired"
;   res@cnFillColors = (/-1,8,2,6,7,10,12,14,17,16/) ; amwg_blueyellowred
;   ;res@cnFillPalette   = "amwg_blueyellowred"
;   ;cmap = read_colormap_file("amwg_blueyellowred")
;   ;ncolors = dimsizes(cmap(:,0))
;   ;res@cnMaxLevelCount = ncolors-1       ; make sure NCL chooses 15 or fewer contour levels
;   ; cmap(0,:) = namedcolor2rgba("white")
;   ;res@cnFillPalette := cmap      ; Use modified RGB/A array

;   res@tiMainFontHeightF = .010
;   res@tiMainString = plotlabs(0)

; ; ***************************************************
; ; panel resources
; ; **************************************************

;   resP                       = True     ; modify the panel plot
;   resP@gsnMaximize           = True     ; maximize in frame
;   resP@gsnFrame              = False    ; don't advance frame yet
;   resP@gsnPanelYWhiteSpacePercent = 5
;   resP@gsnPanelYWhiteSpacePercent = 8
;   resP@gsnPanelLabelBar      = False     ; turn on a common labelbar for the entire panel plot

;   resP@gsnPanelMainFontHeightF = 0.010  ; new resource added in NCL V6.4.0
;   ;resP@gsnPanelMainString = plottitle
;   resP@gsnMaximize        = True        ; use full page

;   ;resP@gsnPanelFigureStrings = (/plotlabs(0)/)

;   ;resP@gsnPanelFigureStrings = (/plotlabs(0),plotlabs(1),plotlabs(2)/)
;   resP@amJust = "TopLeft"
;   resP@gsnPanelFigureStringsFontHeightF = 0.008

;    ;res@mpMinLatF    =  66.0                          ; minimum lat to plot
;    ;res@mpCenterLonF = -45.0

; ;************************************************
; ;
; ;************************************************

;    if (gridtype .eq. "unstructured") then
;      plot = gsn_csm_contour(wks,data,res)    ; create the plot
;    else
;      ;plot = gsn_csm_contour_map(wks,data,res)
;      plot = gsn_csm_contour(wks,data,res)
;    end if

; ;************************************************
; ; make the panel
; ;************************************************

;    gsn_panel(wks,plot,(/nplots,1/),resP)

    frame(wks)

;   if(wkstype .eq. "png")then
;    imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
;    system(imcmd)
;   end if

; ;************************************************
; ;
; ;************************************************

;   if(wkstype .eq. "png")then
;    imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
;    system(imcmd)
;   end if

 exit
 end
