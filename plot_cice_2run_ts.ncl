;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "levscmapCICE.ncl"

;************************************************

  fancylevs = "no"
       hemi = "NH"
  ;    hemi = "SH"
  ;varnames = (/"aice", "hi"/)
  ; varnames = (/"hs", "albsni"/)
  ; varnames = (/"meltt"/)
   varnames = (/"Tsfc"/)
  ; icespd needs to be first
  ; varnames = (/"icespd", "apond"/)
  ; varnames = (/"icespd","hs"/)
    outname = "ice"+hemi
      nvars = dimsizes(varnames)
  ; array contour levels for variables
    varlevs = new((/nvars,3/),float)
  colormaps = new((/nvars/), string)

  if(hemi .eq. "NH")then
    minlat = 66.0
  else
    maxlat = -50.0
  end if

  ; these are in degrees
     rfactor=1.0
   tlatname="TLAT"
   tlonname="TLON"
   ulatname="ULAT"
   ulonname="ULON"

   cday1 = "2011090100.01.2011090100.nc"

;************************************************
; read in netCDF file
;************************************************

   ;rtname1 = "FV3_MOM6_CICE5 BM1"
   ; rtsrc1 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/Bench201109/gfs.20110901/00/"
   rtname1 = "2012-07-01"
    rtsrc1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/BM2TstOutJul2012/"
   rtname2 = "2011-09-01"
    rtsrc2 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/BM2TstOutSep2011/"
 
   ; use one file for grid
        gf = addfile(rtsrc1+"aice.nc","r")

   ;print(gf)

       dir1 = rtsrc1
       dir2 = rtsrc2
       dirs = (/dir1,dir2/)

     fnames = new((/2/),string)
  fnames(0) = dirs(0)+varnames(0)+".nc"
  fnames(1) = dirs(1)+varnames(0)+".nc"
  ;fnames(0) = dirs(0)+"tsfc.nc"
  ;fnames(1) = dirs(1)+"tsfc.nc"
  print(fnames(0))
  print(fnames(1))

  filelist = addfiles(fnames,"r")
  ;print(filelist)
  ;wkstitle = "cice2run"
  wkstitle = varnames(0)

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

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)

  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = True
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat  
   res@mpCenterLonF = 0.0
  end if

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020     

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  ;res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
 if(fancylevs .eq. "yes")then
  if(name .eq. "aice_h" .or. name .eq. "aice")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(name .eq. "hi_h" .or. name .eq. "hi")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   ;res@lbLabelAlignment     = "InteriorEdges"
  end if
  end if
 else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
 end if

   res@cnFillPalette        = palette

  ;print(pltlevs)
  ;print(palette)

  splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
;************************************************
; left plot and colorbar, same variable 
; (same field, same timestep, 2 runs)
;************************************************

    lstep = 100-1

         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)

   ; 1st variable
          vnum = 0
         vname = varnames(vnum)
       freturn = levscmapCICE(vname,hemi)
    pltlevs(:) = freturn[0]
    colormap   = freturn[1]
  ;print(pltlevs)

  ; 1st plot
      ii = 0
  ; 1st run
    fnum = 0

         vname = vname+"_h"
  ;      icevar = dim_max_n_Wrap(filelist[fnum]->$vname$(:lstep,:,:),0)
        icevar = dim_avg_n_Wrap(filelist[fnum]->$vname$(:lstep,:,:),0)
  icevar@lon2d = gf->$tlonname$*rfactor
  icevar@lat2d = gf->$tlatname$*rfactor
  labelstrings(vnum) = icevar@long_name+" ("+icevar@units+")  "+"["+vname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = rtname1
  plot(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;print(labelstrings(0))
  delete(icevar)

  ; 2nd plot
      ii = 1
  ; 2nd run
    fnum = 1
    ;    icevar = filelist[fnum]->$vname$(lstep,:,:)
    ;    icevar = dim_max_n_Wrap(filelist[fnum]->$vname$(:lstep,:,:),0)
        icevar = dim_avg_n_Wrap(filelist[fnum]->$vname$(:lstep,:,:),0)
  icevar@lon2d = gf->$tlonname$*rfactor
  icevar@lat2d = gf->$tlatname$*rfactor
  labelstrings(vnum) = icevar@long_name+" ("+icevar@units+")  "+"["+vname+"]"
  icevar@long_name = " "
  icevar@units= " "
  res@gsnCenterString = rtname2
  plot(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString  = "BM2 output: 10 day means from date shown : "+varnames(0)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

exit
end
