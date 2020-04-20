;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "levscmapCICE.ncl"
;************************************************
begin
  batch="no"
  ;batch="yes"

 minlat = 66.0
 ;minlat = 88.0

 if(batch .eq. "no")then
  initdate="20160701"
     ndays=35
  itime = cd_inv_string(initdate,"%Y%N%D")
  ;print(itime)
  ; in hours
  etime = itime+35*24
  copy_VarMeta(itime,etime)
  enddate = cd_calendar(etime,-2)
  ;print(enddate)
 end if

  syear="2016"
   smon="07"
   sday="01"
  sdate=syear+smon+sday

  eyear="2016"
   emon="07"
   eday="31"
  edate=eyear+emon+eday
 
  Dates2Plt = (/sdate, edate/)
  ndates=dimsizes(Dates2Plt)
  print(Dates2Plt)

;************************************************
; read in netCDF file
;************************************************

  hemi="NH"
  ;hemi="SH"

;/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_test/20161001/COMFV3/c384_test/gfs.20161001/00/OCN/
;/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_test/20161001/COMFV3/c384_test/gfs.20161001/00/ICE/
;ice2016101000.01.2016100100.nc
;ocn2016101000.01.2016100100.nc 

   ;rtsrc="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_test/"
   ;rtsrc="/scratch3/NCEPDEV/stmp2/Jessica.Meixner/BenchmarkTestOutput/"
   ;rtsrc="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_hycom/20160701/COMFV3/
   rtsrc="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_test/" 
   dirsrc=rtsrc+initdate+"/COMFV3/c384_test/gfs."+initdate+"/00/ICE/"
   ; use one file for grid
   icfile="iceic"+initdate+"00.01."+initdate+"00.nc"
   gf =addfile(dirsrc+icfile,"r")
   ;print(gf)

     aicename = "aice"
       hiname = "hi"
      albname = "albsni"
  topmeltname = "meltt"
  botmeltname = "meltb"
  ; apnd*ai or apnd*alvl*ai ==> ponded ice fraction
   fpondname = "apond_ai"
  ; hpnd*apnd or hpnd*apnd*alvl ==> ponded depth on sea ice (use _ai for ponded depth over grid cell)
  ; hpondname = "hpond"
   hpondname = "hpond_ai"
     socnname = "sss"
     tocnname = "sst"
   frzmltname = "frzmlt"

   tlatname="TLAT"
   tlonname="TLON"
   rfactor=1.0

  icefilelist = dirsrc+"ice"+Dates2Plt+"06.01."+initdate+"00.nc"
     icefiles = addfiles(icefilelist,"r")
   
;************************************************
; ice
;************************************************

  if(batch .eq. "no")then
   ;varname= aicename
   ;varname = hiname
   ;varname = albname
   varname = topmeltname
   ;varname = botmeltname
   ;varname = fpondname
   ;varname = hpondname
   ;varname = tocnname
   ;varname = socnname
   ;varname = frzmltname
  end if

  ; array contour levels for variables
      pltlevs = new((/3/),float)
      freturn = levscmapCICE(varname)
   pltlevs(:) = freturn[0]
   colormap   = freturn[1]

    varname = varname+"_h"
   aicename = "aice_h"

        icevar = icefiles[:]->$varname$(:,:,:)
  icevar@lon2d = gf->$tlonname$*rfactor
  icevar@lat2d = gf->$tlatname$*rfactor

   labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"

  icevar@units = ""
  icevar@long_name = ""

  plotname = ""
  runname = "c384"
  plotname = "FV3-MOM6-CICE5"

  plottitle = plotname
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
  end if

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="X11"
   wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ; a max of ndates panels, not all used
  npanels = ndates
 ; for panels
 if(batch .eq. "yes")then
    ncols = ndates
    nrows = 1
 else
    ;ncols = 4
    ;nrows = 1+npanels/ncols
    ;ncols = 2
    ;nrows = 2
    ncols = 1
    nrows = 1
 end if

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  if(varname .eq. "aice_h" .or. varname .eq. "aice")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(varname .eq. "hi_h" .or. varname .eq. "hi")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  end if
  end if

  res@cnFillPalette   = colormap             ; choose colormap

  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  ;res@gsnCenterStringOrthogonalPosF = .15          ; raise the CenterString slightly
  res@gsnCenterStringFontHeightF = 0.040

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
; resources for polymarkers
;************************************************

  mkres               = True
  ;mkres@gsMarkerIndex = 16         ; circle
  mkres@gsMarkerIndex = 15         ; open circle+cross
  ;mkres@gsMarkerIndex = 2         ; cross hair
  mkres@gsMarkerSizeF = 0.020
  mkres@gsMarkerColor = "Red"

;************************************************
;
;************************************************

    ii = 0
    res@gsnCenterString = Dates2Plt(1)

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(1,:,:),res)    ; create the plot
    dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;do ii = 0,ndates-1
  ;  res@gsnCenterString = Dates2Plt(ii)

  ; plot(ii) = gsn_csm_contour_map_polar(wks,icevar(ii,:,:),res)    ; create the plot
  ;  dum(ii)= gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;end do

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  resP@gsnPanelMainString  = plotname+" "+labelstring
  resP@gsnPanelMainFontHeightF = 0.015            ; new resource added in NCL V6.4.0

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/nrows,ncols/),resP)               ; now draw as one plot
;************************************************
;
;************************************************

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

exit
end
