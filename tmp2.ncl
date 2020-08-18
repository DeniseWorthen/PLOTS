;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  ; orion
  RT1 = "/work/noaa/stmp/dworthen/stmp/dworthen/S2S_RT/"

  cyear = "2013"
   cmon = "07"
   imon = "07"
   cday = "01"
   csec = "25650"
  cdate = cyear+"-"+cmon+"-"+cday+"-"+csec
  idate = cyear+imon+"0100"
 lstep = 1-1

  rts = (/"cice5_1d", "cice6_1d"/)
 cset = "/cpld_fv3_ccpp_384_mom6_cice_cmeps_35d_"+idate+"/"

  hemi = "NH"
  ;hemi = "SH"
  ;hemi = "none"

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   minlon =   0.0
   minlat = -60.0
   maxlon = 360.0
   maxlat =  60.0
   midlon = minlon + 0.5*(maxlon - minlon)
  else 
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if

;************************************************
;
;************************************************

  fldtyp = "iceImp"
    flds = (/"Fioi_swpen_vdf"  \
             /)

  nflds = dimsizes(flds)
  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs(0,:) = (/-15.0 ,15.0, 1.0/)
  ;plotlevs(0,:) = (/0.0 ,150.0, 5.0/)

  ;default
  cmap="BlueWhiteOrangeRed"

;************************************************
;
;************************************************

  rt0 = RT1+rts(0)+cset+"ufs.s2s.cpl.hi."+cdate+".nc"
  rt1 = RT1+rts(1)+cset+"ufs.s2s.cpl.hi."+cdate+".nc"

  f0 = addfile(rt0,"r")
  f1 = addfile(rt1,"r")

  ; pick a field to plot
  fldtoplot = 0
       levs = plotlevs(fldtoplot,:)
    fldname = fldtyp+"_"+flds(fldtoplot)
    latname = fldtyp+"_lat"
    lonname = fldtyp+"_lon"
  plottitle = rts(1)+"-"+rts(0)+" fldtype "+fldname
   wkstitle = "rtdiff_"+fldtyp+"_"+fldname

        fvar = (f1->$fldname$(0,:,:) - f0->$fldname$(0,:,:))
  ;      fvar = f1->$fldname$(0,:,:) 
  fvar@lon2d = f1->$lonname$(0,:,:)
  fvar@lat2d = f1->$latname$(0,:,:)
  
;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window


  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.01
  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF = -45
   end if
   if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
    res@mpCenterLonF = 0.0
   end if
  end if

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   = cmap

  res@tiMainFontHeightF = .010
  res@tiMainString = plottitle
;************************************************
;
;************************************************

  if(hemi .eq. "none")then
   plot = gsn_csm_contour_map(wks,fvar,res)    ; create the plot
  else
   plot = gsn_csm_contour_map_polar(wks,fvar,res)    ; create the plot
  end if

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
