;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "bmfilelist.ncl"

;************************************************

      hemi = "NH"
     ;hemi = "SH"
 
  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  LSF = "/scratch2/NCEPDEV/climate/Lydia.B.Stefanova/Models/"
   CL = "/scratch2/NCEPDEV/climate/Denise.Worthen/"

  year = "2012" ; mean ice obs are on fake 2012 calendar
   mon = "08"
  iday = "01"
  ; +35d
    day = 35

  format = "%Y%N%D"
  format@century = 1900
  format@units = "hours since 1900-01-01 00:00:00"
  fmd = new(1,string)

  time0 = cd_inv_string(year+mon+iday,format)
  time = time0 + (day-1)*24
  copy_VarAtts(time0,time)
  fdate=cd_string(time,format)
    fmd=str_get_cols(fdate,4,7)

  ; get corresponding obs date
  time0 = cd_inv_string(year+"0101",format)
  ostep = toint((time-time0)/24)
  print("Obs julian day "+ostep)

;************************************************
;
;************************************************

  ; set up to retrieve obs
     icelonname = "longitude"
     icelatname = "latitude"
        obslabs = (/"CDR", "NASA Team"/)
       obsnames = (/"seaice_conc_cdr","goddard_nt_seaice_conc"/)
           nobs = dimsizes(obsnames)

   
  bmlabs = (/"UFS P3.1", "UFS P5"/)
  bmdirs = (/"P31ice/", "P5ice/"/)
     bms = (/"ice.b31.", "ice.p5."/)
   bmsrc = CL+bmdirs
   nruns = dimsizes(bms)

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

   ; varname = "hi_h"
   ;levs = (/0.0,3.0,0.1/)
    varname = "aice_h"
   levs = (/0.0,1.0,0.1/)

   plottitle = "mean "+varname+" after "+day+" days, initial date "+mon+iday
;************************************************
; read in netCDF file
;************************************************

    filelist = bmsrc+"idate."+mon+iday+"/"+bms+fmd+"."+mon+iday+".nc"
    icefiles = addfiles(filelist,"r")
    ListSetType(icefiles,"join")

     avar = icefiles[:]->$varname$(:,0,:,:)
     avar@lon2d = icefiles[:]->$tlonname$(:,:,:)
     avar@lat2d = icefiles[:]->$tlatname$(:,:,:)
     ;printVarSummary(avar)

;************************************************
; retrieve obs
;************************************************

    if(hemi .eq. "NH")then
         ogrid = CL+"IceData/psn25.grid.nc"
     ofilelist = CL+"IceData/ice."+obsnames+".dm.psn.nc"
    else
         ogrid = CL+"IceData/pss25.grid.nc"
     ofilelist = CL+"IceData/ice."+obsnames+".dm.pss.nc"
    end if
 
          gf = addfile(ogrid,"r")
    obsfiles = addfiles(ofilelist,"r")
    ListSetType(obsfiles,"join")

    ovar = obsfiles[:]->ai(:,ostep-1,:,:)
    ovar@lon2d = gf->lon
    ovar@lat2d = gf->lat

    printVarSummary(ovar)

if(1 .eq. 0)then
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
  wkstitle=varname+"_"+imon
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(nruns+nobs,graphic)
   dum = new(nruns+nobs,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.012

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  66.0                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
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
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  ;res@cnFillOn          = False                  ; color fill

  if(varname .eq. "hi_h")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0/)+""
   ;res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
   ;res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
   ;res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
   ;res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  else
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  end if

  ;res@cnFillPalette         = "WhBlGrYeRe"              ; choose colormap
  res@cnFillPalette           = "amwg256"              ; choose colormap
  res@cnMissingValFillColor   = "gray70" ; set color for missing areas
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter

  res@gsnCenterStringFontHeightF = 0.020
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle
;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
;
;************************************************

  ii = 0
  res@gsnCenterString = bmlabs(ii)
  plot(ii) = gsn_csm_contour_map_polar(wks,avar(0,:,:),res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii = 1
  res@gsnCenterString = bmlabs(ii)
  plot(ii) = gsn_csm_contour_map_polar(wks,avar(1,:,:),res)    ; create the plot
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ii = 2
  res@mpFillOn   = True
  res@gsnCenterString = obslabs(0)
  plot(ii) = gsn_csm_contour_map_polar(wks,aobs(0,:,:),res)    ; create the plot

  ii = 3
  res@mpFillOn   = True
  res@gsnCenterString = obslabs(1)
  plot(ii) = gsn_csm_contour_map_polar(wks,aobs(1,:,:),res)    ; create the plot

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,2/),resP)

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

  end if
exit
end
