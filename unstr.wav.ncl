;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin
     RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/"

     ;scrpfile  = "with_land_CardDeck.SCRIP.nc"
     scrpfile   = "no_land_CardDeck.SCRIP.nc"
     sfile      = addfile(RT+"moddefs3/"+scrpfile,"r")
     x          = sfile->grid_center_lon
     y          = sfile->grid_center_lat
     cx         = sfile->grid_corner_lon
     cy         = sfile->grid_corner_lat

    ;dirsrc        = "unstrnoland3PE/"
    ;plotlab       = "unstr noland"
    dirsrc        = "pdlibnoland3PE/"
    plotlab       = "pdlib noland"

     ;filetype="wave history"
     ;fsrc="ufs.atmw.ww3.hi."

     filetype="wave coupler"
     fsrc="ufs.atmw.cpl.hi.wav."

     date="2021-03-22-"
     time="25200"
     fname=RT+dirsrc+fsrc+date+time+".nc"
     f = addfile(fname,"r")

     if (filetype .eq. "wave history") then
        ;vname = "UAX"
        ;levs = (/-20,20,1.0/)

        ;vname = "DW"
        ;levs = (/0,8000.0,500.0/)

        vname = "HS"
        levs = (/0,.50,.02/)

        ;vname = "USTX"
        ;levs = (/-1.,1.,0.1/)

        data = f->$vname$(0,0,:)
        data@lon1d = f->lon(0,:)
        data@lat1d = f->lat(0,:)
     end if

     if (filetype .eq. "wave coupler") then
        vname="wavExp_Sa_u10m"
        data = f->$vname$(0,0,:)
        levs = (/-20,20,1/)

        ;vname="wavExp_Sa_tbot"
        ;data = f->$vname$(0,0,:)
        ;data = data-273.15
        ;levs = (/-40,40,.5/)
        ;levs = (/230,320,1/)

        ;vname="wavImp_Sw_z0"
        ;data = f->$vname$(0,0,:)
        ;data = where(data .lt. 0.0 .or. data .gt. 1.0e3, default_fillvalue(typeof(data)), data*1.0e3)
        ;data = where(abs(data) .ge. 2.0, data@_FillValue, data)
        ;data = data*1.0e3
        ;levs = (/0.0, 1.0, 0.05/)

        data@lon1d = f->wavImp_lon(0,0,:)
        data@lat1d = f->wavImp_lat(0,0,:)
     end if
     print("plotting variable "+vname+" from "+fname)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="test"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                 ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@cnMonoLineColor  = False
  res@lbLabelBarOn      = True
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ;res@cnFillPalette   = "amwg"
  ;res@cnFillPalette   = "MPL_rainbow"
  ;res@cnFillPalette   = "BlWhRe"
  res@cnFillPalette    = "NCV_jet"
  res@tiMainFontHeightF = .010
  res@tiMainString = "test"
  ;res@mpFillOn             = False
  res@mpOutlineOn          = False

  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            = -20.
  ;res@mpMinLonF            = 30.
  ;res@mpMaxLonF            = 40.

  if (filetype .eq. "wave history")then
    res@sfXCellBounds = cx(:,0:5)
    res@sfYCellBounds = cy(:,0:5) 
  end if
;************************************************
;
;************************************************

    ;res@gsnAddCyclic         = False

   plot = gsn_csm_contour_map(wks,data,res)    ; create the plot
   ;plot = gsn_csm_contour(wks,data,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
