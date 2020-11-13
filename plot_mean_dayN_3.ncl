;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "bmfilelist.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  LSF = "/scratch2/NCEPDEV/climate/Lydia.B.Stefanova/Models/"

  bmlabs = (/"UFS P3.1", "UFS P5"/)
  bms = (/"ufs_b31", "ufs_p5"/)
  bmsrc = LSF+bms+"/SeaIce/"
  nruns = dimsizes(bms)

  ; use first bm to set dates etc
   freturn = bmfilelist(bmsrc(0))
    nvalid = freturn[0]
  datelist = new((/nvalid/),typeof(freturn[1]))
  timelist = new((/nvalid/),typeof(freturn[2]))
  datelist = freturn[1]
  timelist = freturn[2]

   ;print(datelist)
   ;print(timelist)
 
  filelist = new((/nruns,nvalid/),typeof(datelist))
  ;grab integration day iday (in hours) from
  ;runs at month N
  format = "%Y%N%D%H"
    iday = 35
    imon = "0101"
     iii = 0
   do ii = 0,nvalid-1
    cmon = str_get_cols(datelist(ii),4,7)
    if(cmon .eq. imon)then
     ;print(datelist(ii)+"  "+cmon)
     itime = timelist(ii)            ; copy attributes
     itime = itime + (iday-1)*24
   
     idate = cd_string(itime,format) ; date of integration day
     idate = str_get_cols(idate,0,7) ; without the hours
     ifile0 = bmsrc(0)+datelist(ii)+"/ice"+idate+".01."+datelist(ii)+"00.subset.nc"
     ifile1 = bmsrc(1)+datelist(ii)+"/ice"+idate+".01."+datelist(ii)+"00.subset.nc"
     ; assume all files exist in both runs
     if(fileexists(ifile0)) then
       filelist(0,iii) = ifile0
       filelist(1,iii) = ifile1
                   iii = iii + 1
       print(datelist(ii)+"   "+itime+"  "+idate+"  "+ifile0)
     end if
    end if
   end do
   nfiles = iii
    hemi = "NH"
    ;hemi = "SH"

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

   ; varname = "hi_h"
   ;levs = (/0.0,3.0,0.1/)
    varname = "aice_h"
   levs = (/0.0,1.0,0.1/)

   plottitle = "mean "+varname+" after "+iday+" days, initial date "+imon

;************************************************
; read in netCDF file
;************************************************

    ; use as grid file to retrieve 2d latlon later
      gf = addfile(filelist(0,0),"r")
     var = gf->$tlatname$
    dims = dimsizes(var)
      ny = dims(0)
      nx = dims(1)
    delete(var)
    ;print(nx+"  "+ny)
     var = new((/nruns,nfiles,ny,nx/),"float")

    do jj = 0,nruns-1
     do ii = 0,nfiles-1
                   f = addfile(filelist(jj,ii),"r")
       var(jj,ii,:,:) = f->$varname$(0,:,:)
      print("variable added from "+filelist(jj,ii))
       delete(f)
     end do
    end do
    printVarSummary(var)
    
           avar = dim_avg_n(var,1)
     avar@lon2d = gf->$tlonname$
     avar@lat2d = gf->$tlatname$
    printVarSummary(avar)

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

  plot = new(nruns,graphic)
   dum = new(nruns,graphic)

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

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

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

exit
end
