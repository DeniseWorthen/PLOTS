; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "tilegrid.ncl"

;************************************************

  RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/imprint.devfix/"

  ;hemi = "NH"
  ;hemi = "SH"
  hemi = "none"

 ;plottype = "unmasked"
 ;plottype = "land"
  plottype = "ocean"

  if(hemi .eq. "NH")then
    minlat =  60.0
    midlon = -45.0
   else
    maxlat = -60.0
    midlon =   0.0
  end if

  rad2deg=180.d0/acos(-1.0d0)
  ;compname = "ice"
  ;compname = "ocn"
  compname = "wav"

;************************************************
;
;************************************************

  lstep=0

 ; in coupler history files
  tlonname = compname+"Exp_lon"
  tlatname = compname+"Exp_lat"

  runlabs = (/"develop","vector regridding"/)
  dirs = (/"cpld.dev/", "cpld.imp/"/)

  time=43200
  fsrc="ufs.cpld.cpl.hi."+compname+".2021-03-22-"+time+".nc"
  ndirs = dimsizes(dirs)

  ; add cpl history files on tile
  files=addfiles(RT+dirs+fsrc+".nc","r")
  print(files)

  palette="BlueWhiteOrangeRed"
  ;palette="BlWhRe"

  ;flds = (/"iceExp_Sa_u", "iceExp_Sa_tbot"/)
  ;maskname = "iceImp_Si_imask"

  ;flds = (/"ocnExp_Foxx_taux"/)
  ;maskname = "ocnImp_So_omask"

 flds = (/"wavExp_Sa_u10m"/)
 maskname = "ocnImp_So_omask"

  nflds = dimsizes(flds)

  plotlevs = new((/nflds,3/), float)
  ;plotlevs( 0,:) = (/  -20.0,  20.0, 2.0/) ; Sa_u
  ;plotlevs( 1,:) = (/  230.0, 280.0, 1.0/); Sa_tbot

  ;plotlevs( 0,:) = (/  -1.0,  1.0, 0.05/) ; Foxx_taux

  plotlevs( 0,:) = (/  -20.0,  20.0, 2.0/) ; Sa_u10m

  variable_to_plot=0
  lstep=0
  aname = flds(variable_to_plot)
  print("variable "+aname)

  wkstitle = "devimp."+compname+"."+flds(variable_to_plot)
  ;plottitle=runlabs(1)+" - "+runlabs(0)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  plot = new(3,graphic)

  if(hemi .ne. "none")then
   res@gsnPolar   =  hemi                         ; specify the hemisphere
   if(hemi .eq. "NH")then
    res@mpMinLatF    =  minlat                          ; minimum lat to plot
    res@mpCenterLonF =  midlon
   end if
   if(hemi .eq. "SH")then
    res@mpMaxLatF    = maxlat                            ; minimum lat to plot
    res@mpCenterLonF = midlon
   end if
 end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  res@cnFillPalette     = palette

  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
function subplot(ii,name,pltvar,pltlevs)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  res@gsnCenterStringFontHeightF      = 0.020
  ;res@gsnCenterString                 = name
  res@gsnCenterStringOrthogonalPosF   = 0.12

  if(hemi .eq. "none")then
   splot = gsn_csm_contour_map(wks,pltvar,res)    ; create the plot
  else
   splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  return(splot)
end
;************************************************
;
;************************************************


  ;maskvar = files[0]->$maskname$(lstep,:,:)
  ;maskvar@lon2d = files[0]->$tlonname$(0,:,:)
  ;maskvar@lat2d = files[0]->$tlatname$(0,:,:)
  ; first plot, control values
  ii = 0
  var = files[ii]->$aname$(lstep,:,:)
  ;mvar = where(maskvar .eq. 0.0, var@_FillValue, var)
  ;var = mvar
  levs = plotlevs(variable_to_plot,:)
  var@lon2d = files[ii]->$tlonname$(0,:,:)
  var@lat2d = files[ii]->$tlatname$(0,:,:)
  plot(ii) = subplot(ii,aname,var,levs)

 ; imprint fix
  ii = 1
  var = files[ii]->$aname$(lstep,:,:)
  ;mvar = where(maskvar .eq. 0.0, var@_FillValue, var)
  ;var = mvar
  levs = plotlevs(variable_to_plot,:)
  var@lon2d = files[ii]->$tlonname$(0,:,:)
  var@lat2d = files[ii]->$tlatname$(0,:,:)
  plot(ii) = subplot(ii,aname,var,levs)

 ; difference
  ii=2
  var = files[0]->$aname$(lstep,:,:) - files[1]->$aname$(lstep,:,:)
  ;mvar = where(maskvar .eq. 0.0, var@_FillValue, var)
  ;var = mvar
 levs = (/-2, 2, .2/)
 ; levs = (/-.02,.02,.002/)
  var@lon2d = files[0]->$tlonname$(0,:,:)
  var@lat2d = files[0]->$tlatname$(0,:,:)
  plot(ii) = subplot(ii,aname,var,levs)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  ;resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = plottitle + ",  "+msklab
  ;resP@gsnPanelMainString = plottitle
;************************************************
; make the panel
;************************************************

  if (hemi .eq. "none") then
    gsn_panel(wks,plot,(/3,1/),resP)
  else
    gsn_panel(wks,plot,(/1,3/),resP)
  end if

  ;gsn_panel(wks,plot,(/1,1/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
