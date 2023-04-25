;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

  MD = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/moddefs/"
 ;scrpfile = MD+"trip1degmask.SCRIP.nc"
 ;scrpfile = MD+"exp.wise.tnx1v4.100k.SCRIP.nc"
 ;scrpfile = MD+"exp.wise.tnx1v4p.100k.SCRIP.nc"
       ;sf       = addfile(scrpfile,"r")
       ;x        = sf->grid_center_lon
       ;y        = sf->grid_center_lat
       ;cx       = sf->grid_corner_lon(:,0:5)
       ;cy       = sf->grid_corner_lat(:,0:5)
       ;cx@units = "degrees_east"
       ;cy@units = "degress_north"
       ;printVarSummary(cx)

    ;   RT = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/CPLD/base/"
    ;   RT = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/OPT/base/"

       RT = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/base/"
       title="global_270k.msh"

       ;RT = "/glade/scratch/worthen/addunstr.2acd891b.ww.33d337356/ATMW/base.noresmP/"
       ;title="GLOBAL_100k_with_tnx1v4maskP.msh"
     filetype="wave history"
     ;filetype="wave coupler"
     ;filetype="meshdecomp"

     ; minlat = 66.0
     ; zoom in
     minlat = 88.0
     ;minlat = 80.0

     if (filetype .eq. "wave history") then
        date="2021-03-22-"
        time="26640"
        fname="ufs.atmw.ww3.hi."+date+time+".nc"
        ;fname="ufs.cpld.ww3.hi."+date+time+".nc"
        f = addfile(RT+fname,"r")
        ;vname = "UAX"
        ;levs = (/-20,20,1.0/)

        ;vname = "DW"
        ;levs = (/0,8000.0,500.0/)

        vname = "HS"
        levs = (/0,.50,.05/)
        ;levs = (/0,1.0,0.01/)
        ;levs = (/0.,5.0,.5/)

        ;vname = "ICE"
        ;levs = (/0.0, 1.0, 0.1/)

        ;vname = "USTX"
        ;levs = (/-1.,1.,0.1/)

        data = f->$vname$(0,0,:)
        ;lons = f->lon(0,:)
        ;lats = f->lat(0,:)
        data@lon1d = f->lon(0,:)
        data@lat1d = f->lat(0,:)
        ;cx = transpose(f->clon(:,0,:))
        ;cy = transpose(f->clat(:,0,:))
        ;cx = f->clo
        ;f2=addfile(RT+"mesh.with_land_CardDeck.nc","r")
        ;lats = f2->wavExp_lat(0,0,:)
        ;DW
        ;mdata = data
        ;data = where(mdata .lt. 9.0, mdata@_FillValue, mdata)
        ;printVarSummary(data)

     end if

     if (filetype .eq. "wave coupler") then
       date="2021-03-22-"
       time="43200"
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
  res@mpFillOn   = False
  res@mpOutlineOn = False

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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
  res@tiMainFontHeightF = .010
  res@tiMainString = title
  res@gsnPolar   =  "NH"                         ; specify the hemisphere
  res@mpMinLatF  =  minlat                   ; minimum lat to plot
  res@mpCenterLonF = -45

  res@sfElementNodes = f->nconn
  res@sfFirstNodeIndex = 1
  ; polar plots are distorted with these included
   if (filetype .eq. "wave history")then
;    res@sfXCellBounds = cx
;    res@sfYCellBounds = cy
   end if
    res@gsnLeftString = date+time

;************************************************
;
;************************************************

    res@gsnAddCyclic         = False

 plot = gsn_csm_contour_map_polar(wks,data,res)    ; create the plot
 ;plot = gsn_csm_contour(wks,data,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
