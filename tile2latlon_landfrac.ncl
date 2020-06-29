load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  path0 = "/home/Shan.Sun/prep_fv3/fix_fv3/"
  orodata = "oro_data.tile1.nc"
  fin = addfile(path0+orodata,"r")
  x=fin->land_frac
  dims=dimsizes(x)
  imax=dims(0)*dims(1)*6
  var=new((/imax/),typeof(x))
  lonn=new((/imax/),typeof(x))
  latn=new((/imax/),typeof(x))
  print(dims)

  in=0
  do tile=1,6
  fv3 = "oro_data.tile"+tile+".nc"
  fin=addfile(path0+fv3,"r")

  x=fin->land_frac
  lon=fin->geolon
  lat=fin->geolat

  do ii=0,dims(0)-1
  do jj=0,dims(1)-1
  var(in)=x(ii,jj)
  lonn(in)=lon(ii,jj)
  latn(in)=lat(ii,jj)
  in=in+1
  end do
  end do

  end do  ; do tile=1,6

; wks = gsn_open_wks("x11", "contour_map")
  wks = gsn_open_wks("png", "landfrac")

;-- set resources
  res                   = True
  res@gsnMaximize       = True     ; maximize plot in frame
  res@cnFillOn          = True     ; turn on contour fill
  res@cnFillPalette     = "ncl_default"   ; define color map for contours
  res@cnLinesOn         = False    ; turn off contour lines
  res@cnLineLabelsOn    = False    ; turn off line labels
  res@sfXArray          = lonn     ; Only necessary if x doesn't 
  res@sfYArray          = latn     ; contain 1D coordinate arrays
  res@tiMainString      = "land_frac"

  res@cnLevelSelectionMode = "ManualLevels" ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF        = .1            ;-- minimum contour level
  res@cnMaxLevelValF        = .9            ;-- maximum contour level
  res@cnLevelSpacingF       = .1 

  res@mpOutlineBoundarySets = "NoBoundaries"

;-- draw the contour map
  plot = gsn_csm_contour_map(wks,var,res)

  end
