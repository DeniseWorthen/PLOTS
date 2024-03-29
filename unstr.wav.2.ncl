;**********************************************************
;
;**********************************************************
begin

     ;RT = "/glade/scratch/worthen/WaveUnstr/str3PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr/unstrnoland3PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr2/pdlib2PE/"
     ;RT = "/glade/scratch/worthen/WaveUnstr/pdlibnoland3PE/"
      RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_18762/cpld_control_pdlib_p8_intel/"

     filetype="wave history"
     ;filetype="wave coupler"

     polar="false"
     ;polar="true"
     ; minlat = 66.0
     ; zoom in
     ;minlat = 88.0
     ;minlat = 80.0

     if (filetype .eq. "wave history") then
       ;time="32400"
       ;fname = "ufs.atmw.ww3.hi.2021-03-22-"+time+".nc"
       fname="20210322.090000.out_grd.ww3.nc"
       f = addfile(RT+fname,"r")
        ;vname = "UAX"
        ;levs = (/-20,20,1.0/)

        ;vname = "DW"
        ;levs = (/0,8000.0,500.0/)

        vname = "HS"
        levs = (/0,5.0,.2/)
        ;levs = (/0,.5,.05/)
        ;levs = (/0.,1.,.1/)
        ;levs = (/0.,2.,0.2/)

       ;vname = "mapsta"
       ;levs = (/-2,2,1/)

        ;vname = "ICE"
        ;levs = (/0.0, 1.0, 0.1/)
        ;vname = "mapsta"
        ;levs = (/-3,3,1/)
        ;vname = "maptmp"
        ;levs = (/-5, 3, 1/)

        ;vname = "USTX"
        ;levs = (/-1.,1.,0.1/)

        data = f->$vname$(0,0,:)
        data@lon1d = f->lon(0,:)
        data@lat1d = f->lat(0,:)
        print("plotting "+vname+" from "+RT+fname)
     end if

     if (filetype .eq. "wave coupler") then
       time = "77040"
       fname = "ufs.atmw.cpl.hi.wav.2021-03-22-"+time+".nc"
        f = addfile(RT+fname,"r")
        ;vname="wavExp_Sa_u10m"
        ;data = f->$vname$(0,0,:)
        ;levs = (/-20,20,1/)

        ;vname="wavExp_Sa_tbot"
        ;data = f->$vname$(0,0,:)
        ;data = data-273.15
        ;levs = (/-40,40,.5/)
        ;levs = (/230,320,1/)

        vname="wavImp_Sw_z0"
        data = f->$vname$(0,0,:)
        ;data = where(data .lt. 0.0 .or. data .gt. 1.0e3, default_fillvalue(typeof(data)), data*1.0e3)
        ;data = where(abs(data) .ge. 2.0, data@_FillValue, data)
        data = data*1.0e3
        levs = (/0.0, 0.5, 0.05/)

        data@lon1d = f->wavImp_lon(0,0,:)
        data@lat1d = f->wavImp_lat(0,0,:)
     end if

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle="unstr.wave"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@gsnStringFontHeightF = 0.01
  ;res@cnMissingValPerimOn     = True            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
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
  res@cnFillPalette   = "WhiteBlueGreenYellowRed"
  ;res@cnFillPalette    = "cb_9step"
  res@tiMainFontHeightF = .010
  res@tiMainString = fname
  if (filetype .eq. "wave history") then
    res@sfElementNodes = f->nconn
    res@sfFirstNodeIndex = 1
    res@mpFillOn             = False
    res@mpOutlineOn          = False
    res@mpFillOn             = False
  else
    res@mpFillOn             = True
    res@mpOutlineOn          = True
  end if

  if(polar .eq. "true")then
    res@mpMinLatF    =  minlat                    ; minimum lat to plot
    res@mpCenterLonF = -45
    res@gsnPolar   =  "NH"                        ; specify the hemisphere
  else
    res@vpWidthF          = 0.70
    res@vpHeightF         = 0.40
  end if
  ;res@mpMinLatF            = -30      ; range to zoom in on
  ;res@mpMaxLatF            =  0.
  ;res@mpMinLonF            = -90.
  ;res@mpMaxLonF            = -70.

;************************************************
; add coord marks
;************************************************

  mkres = True
  mkres@gsMarkerSizeF = 5.
  mkres@gsnFrame        = False
  mkres@gsnDraw         = False
  mkres@gsnCoordsAttach = True

;************************************************
;
;************************************************

    res@gsnAddCyclic         = False

    if(polar .eq. "true")then
      plot = gsn_csm_contour_map_polar(wks,data,res)    ; create the plot
      ;gsn_coordinates(wks,plot,data,mkres)
    else
      plot = gsn_csm_contour_map(wks,data,res)    ; create the plot
    end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
