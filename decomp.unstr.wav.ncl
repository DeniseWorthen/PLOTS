;**********************************************************
;
;**********************************************************
begin

  RT		= "/glade/scratch/worthen/WaveUnstr2/"
  MD		= "/glade/scratch/worthen/WaveUnstr2/moddefs/"

  dirs		= (/"pdlib2PE/"/)
  doffile	= "dof.wav.nc"
    ndirs	= dimsizes(dirs)
    levs        = (/0,4,1/)

       scrpfile = MD+"trip1degmask.SCRIP.nc"
       ;print(scrpfile)
       sf       = addfile(scrpfile,"r")
       x        = sf->grid_center_lon
       y        = sf->grid_center_lat
       cx       = sf->grid_corner_lon
       cy       = sf->grid_corner_lat
       ;print(x(0:9)+"    "+y(0:9))
;**********************************************************
;
;**********************************************************

do nd			= 0,ndirs-1
  dirsrc		= RT+dirs(nd)

  ; get the index seq to resort
  doff			= addfile(dirsrc+doffile,"r")
  dof			= doff->dof(:)
  print(dof(0:9))
  ip			= dim_pqsort(dof,1)

    vname	= "decomp"
    ofile	= dirsrc+"emesh.decomp.nc"
    ff = addfile(ofile, "r")
    var1d	= ff->$vname$
       ;data@lon1d	= ff->coordx
       ;data@lat1d	= ff->coordy
       ; sort the data using dof
       var1d_sort       = var1d
       var1d_sort       = var1d(ip)
       var1d            = var1d_sort

       var1d@lon1d       = x
       var1d@lat1d       = y

     if (1 .eq. 0)then
                                ;printVarSummary(data)
       var1d_sort	=data
       var1d_sort	=data(ip)
       data		= var1d_sort

       scrpfile		= MD+"no_land_CardDeck.SCRIP.nc"
       print(scrpfile)
       sf			= addfile(scrpfile,"r")
       x			= sf->grid_center_lon
       y			= sf->grid_center_lat
       cx			= sf->grid_corner_lon
       cy			= sf->grid_corner_lat
       printVarSummary(cx)
       cxsort = cx
       cxsort = cx(ip,:)
       cx = cxsort
       cysort = cy
       cysort = cy(ip,:)
       cy = cysort
       xsort = x
       xsort = x(ip)
       x = xsort
       ysort = y
       ysort = y(ip)
       y = ysort
                                ;data@lon1d = x
                                ;data@lat1d = y
     end if

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle=vname
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@trGridType           = "TriangularMesh"  ; This is required to allow

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   = "amwg"

  res@tiMainFontHeightF = .010
  res@tiMainString = vname

  res@gsnAddCyclic         = False

;---These resources define the cell centers and cell vertices
 ; res@sfXArray             = x(0:5)
 ; res@sfYArray             = y(0:5)
 ; res@sfXCellBounds        = cx(0:5)
 ; res@sfYCellBounds        = cy(0:5)
  ;res@sfDataArray          = var1d

;************************************************
;
;************************************************

   plot = gsn_csm_contour(wks,var1d,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

end do  ; ndirs

exit
end
