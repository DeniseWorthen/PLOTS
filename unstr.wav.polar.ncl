;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

  hemi = "wedge"
  ;     hemi = "NH"
  ;    hemi = "SH"
  varnames = (/"HS"/)
  plotlevs = (/0.0,4.0,.05/)

  if(hemi .eq. "wedge")then
   minlat =  60.0
   maxlat =  88.0
   minlon = 20.0
   maxlon = 90.0
  else
    if(hemi .eq. "NH")then
      minlat = 70.0
    else
      maxlat = -50.0
    end if
  end if

  MD = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/testpr1/moddefs/"
  scrpfile = MD+"trip1degmask.SCRIP.nc"
       sf       = addfile(scrpfile,"r")
       x        = sf->grid_center_lon
       y        = sf->grid_center_lat
       cx       = sf->grid_corner_lon(:,:)
       cy       = sf->grid_corner_lat(:,:)
       cx@units = "degrees_east"
       cy@units = "degress_north"
       ;printVarSummary(cx)

       RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/testpr1/unstr.hiice/"
    ;   RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/testpr1/base_usp/"

     filetype="wave history"
     ;filetype="wave coupler"
     ;filetype="meshdecomp"

     if (filetype .eq. "wave history") then
        date="20210824."
        time="060000"
        ;fname="ufs.cpld.ww3.hi."+date+time+".nc"
        fname=date+time+".out_grd.ww3.nc"
        f = addfile(RT+fname,"r")
        ;vname = "UAX"
        ;levs = (/-20,20,1.0/)

        ;vname = "DW"
        ;levs = (/0,8000.0,500.0/)

        vname = "HS"
        levs = (/0,4.0,.05/)

        ;vname = "ICE"
        ;levs = (/0.0, 1.0, 0.1/)

        ;vname = "USTX"
        ;levs = (/-1.,1.,0.1/)

        ;vname = "USSPX"
        ;levs = (/-.05,.05,.005/)
        ;data = f->$vname$(0,1,0,:)

        data = f->$vname$(0,0,:)
        data@units=""
        data@long_name=""
        ;lons = f->lon(0,:)
        ;lats = f->lat(0,:)
        data@lon1d = f->lon(0,:)
        data@lat1d = f->lat(0,:)

        ;f2=addfile(RT+"mesh.with_land_CardDeck.nc","r")
        ;lats = f2->wavExp_lat(0,0,:)
        ;DW
        ;mdata = data
        ;data = where(mdata .lt. 9.0, mdata@_FillValue, mdata)
        ;printVarSummary(data)

        mskvar = f->ICE(0,0,:)
        mskvar@lon1d = f->lon(0,:)
        mskvar@lat1d = f->lat(0,:)
     end if

     if (filetype .eq. "wave coupler") then
       date="2021-03-22-"
       time="25200"
       fname="ufs.cpld.cpl.hi.wav."+date+time+".nc"
       f = addfile(RT+fname,"r")
        ;vname="wavExp_Sa_u10m"
        ;data = f->$vname$(0,0,:)
        ;levs = (/-20,20,1/)

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
        ;levs = (/0.0, 0.5, 0.05/)

        vname = "wavExp_Si_ifrac"
        data = f->$vname$(0,0,:)
        data@lon1d = f->wavExp_lon(0,0,:)
        data@lat1d = f->wavExp_lat(0,0,:)
        levs = (/0.0, 1.0, 0.1/)
     end if

     print("plotting "+vname+" from "+RT+fname)
;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  wkstitle=vname
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  res@mpFillDrawOrder = "PostDraw"

  ;res@vpWidthF          = 0.70
  ;res@vpWidthF          = 0.50
  ;res@vpHeightF         = 0.50

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "white"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                 ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@cnMonoLineColor  = False
  res@lbLabelBarOn      = True
  ;res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  ;res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  ;res@cnFillPalette   = "amwg"
  ;res@cnFillPalette   = "MPL_rainbow"
  res@cnFillPalette   = "WhiteBlueGreenYellowRed"
  res@tiMainFontHeightF = .010
  res@tiMainString = vname

  if(hemi .eq. "wedge")then
   res@mpMinLatF          =  minlat      ; range to zoom in on
   res@mpMaxLatF          =  maxlat
   res@mpMinLonF          =  minlon
   res@mpMaxLonF          =  maxlon
  else
    res@gsnPolar   =  hemi                         ; specify the hemisphere
    if(hemi .eq. "NH")then
      res@mpMinLatF    =  minlat                    ; minimum lat to plot
      res@mpCenterLonF = -45
    end if
    if(hemi .eq. "SH")then
      res@mpMaxLatF    = maxlat
      res@mpCenterLonF = 0.0
    end if
    res@gsnPolarLabelFontHeightF = 0.020           ; change font height of labels
  end if

  ;res@gsnPolar   =  "NH"                         ; specify the hemisphere
  ;res@mpMinLatF  =  66.0                    ; minimum lat to plot
 ;  res@mpMinLatF  =  80.0                    ; minimum lat to plot
  ;res@mpCenterLonF = -45

  ; polar plots are distorted with these included
  ; if (filetype .eq. "wave history")then
 ;   res@sfXCellBounds = cx
 ;   res@sfYCellBounds = cy
   ;end if
    res@gsnLeftString = date+time

;************************************************
; resources for overlay
;************************************************

  ores                  = True
  ores@cnLineThicknessF = 2.0            ; line thickness
  ores@cnLineColor      = "black"        ; line color
  ;ores@cnFillOn         = True
  ;ores@cnFillPalette    = "black"
  ores@cnLineLabelsOn   = False
  ores@cnInfoLabelOn    = False
  ores@gsnDraw          = False ; don't draw
  ores@gsnFrame         = False ; don't advance frame
  ores@gsnLeftString    = ""    ; no titles
  ores@gsnRightString   = ""
  ;ores@lbLabelBarOn       = False                 ; turn off individual colorbars
  ores@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores@cnLevels         = (/0.85/)

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

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
;
;************************************************

    res@gsnAddCyclic         = False
    if ( hemi .eq. "wedge") then
      plot = gsn_csm_contour_map(wks,data,res)    ; create the plot
    else
      plot = gsn_csm_contour_map_polar(wks,data,res)    ; create the plot
    end if
      oplot = gsn_csm_contour(wks,mskvar,ores)
   overlay(plot,oplot)
   dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
