;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  hemi="NH"
  ;hemi="SH"
  ;hemi="wedge"

  if(hemi .eq. "wedge")then
   minlat =  62.0
   maxlat =  76.0
   minlon = 240.0
   maxlon = 280.0
   midlon = minlon + (maxlon - minlon)/2.0
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

  RT4 = "/glade/scratch/worthen/hour2/"

;************************************************
; read in netCDF file
;************************************************

   cyear = "2016"
    cmon = "10"
    cday = "03"
   cdate = cyear+"-"+cmon+"-"+cday
   ;rtsrc = RT4+"history/"
   rtsrc = RT4

   ;gf =addfile(rtsrc+"iceh_ic."+cdate+"-00000.nc","r")
   ;tlatname="TLAT"
   ;tlonname="TLON"
   ;varname="aice"
   gf =addfile(rtsrc+"ufs.s2s.00900.tile3.nc","r")
   tlatname="grid_yt"
   tlonname="grid_xt"

   varname="atmExp_Si_ifrac"
   dirname=rtsrc
   rfactor=1.0

;************************************************
; ice
;************************************************

  lstep=1-1
  print("cdate = "+cdate)

  ; ice field
  levs = (/0.0, 1.0, .05/)

  ;icevar = gf->$varname$(lstep,:,:)
  icevar = gf->$varname$(:,:)
  icevar@lon2d=gf->$tlonname$*rfactor
  icevar@lat2d=gf->$tlatname$*rfactor
  icevar@units=""
  icevar@long_name=""

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=  60.00
  lon2=-120.00
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice5")              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  if(hemi .eq. "wedge")then
   res@mpMinLatF          =  minlat      ; range to zoom in on
   res@mpMaxLatF          =  maxlat
   res@mpMinLonF          =  minlon
   res@mpMaxLonF          =  maxlon
   res@mpCenterLonF       =  midlon
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
  end if

  ; Near Yenisei
  ;res@mpMinLatF            =  70      ; range to zoom in on
  ;res@mpMaxLatF            =  80.
  ;res@mpMinLonF            =  60.
  ;res@mpMaxLonF            =  90.

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  
  ;res@cnFillOn          = False                  ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  res@cnMissingValFillColor   = "gray"

  res@tiMainString = rtsrc+" "+cdate+" "+varname
  res@tiMainFontHeightF = .01

;************************************************
;
;************************************************

  if(hemi .eq. "wedge")then
   plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

exit

end
