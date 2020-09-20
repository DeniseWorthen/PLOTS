;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

   rtname = "S2S_RT"
 plotlabs = (/"NEMS mediator", "CMEPS mediator"/)
      rts = (/"datm_nems/tstrun/",\
              "datm_cmeps/"/)

  ofile = "field_ocn_import_2011-10-01T06:00:00.nc"

  fnems   = addfile(RT2+rtname+"/"+rts(0)+"cpld_datm_mom6_cice5_cold_cfsr/"+ofile,"r")
  fcmeps  = addfile(RT2+rtname+"/"+rts(1)+"cpld_datm_mom6_cice5_cmeps_cold_cfsr/"+ofile,"r")

  print(ofile)

;************************************************
;
;************************************************

  ocnflds = (/"mean_sensi_heat_flx",  \
              "mean_net_lw_flx",\
              "mean_zonal_moment_flx",\
              "mean_merid_moment_flx",\
              "mean_salt_rate", \
              "mean_evap_rate", \
              "mean_net_sw_vis_dir_flx",\
              "mean_prec_rate",\
              "mean_fprec_rate",\
              "inst_pres_height_surface",\
              "mean_fresh_water_to_ocean_rate",\
              "net_heat_flx_to_ocn"/)

  ocnwgts = (/1.0, \     ;sens
              1.0, \     ;net lw
              1.0, \     ; stress
              1.0, \     ; stress
              1.0e6, \   ;salt flux
              1.0e5, \   ;evap
              1.0, \     ;swnet
              1.0e3, \   ;prec
              1.0e5, \   ;fprec
              1.0e-4, \     ; hgt
              1.0e3, \   ;ffresh
              1.0/)      ;fhocn

  ; plot levels
  plotlevs = new((/12,3/), float)
  plotlevs(0,:) = (/-120,120,5/)         ; sensible
  plotlevs(1,:) = (/-150,30,5/)        ; net lw 
  plotlevs(2,:) = (/-0.5,0.5,.05/)       ; stress
  plotlevs(3,:) = (/-0.5,0.5,.05/)       ; stress
  plotlevs(4,:) = (/-1.2,1.2,.1/)            ; salt
  plotlevs(5,:) = (/-10,10,1/)            ; evap
  plotlevs(6,:) = (/0,300,10/)           ; netsw
  plotlevs(7,:) = (/0,2,.1/)            ; prec
  plotlevs(8,:) = (/0,2,.1/)            ; fprec
  plotlevs(9,:) = (/8,10,.1/)            ; hgt
  plotlevs(10,:) = (/-.2,.2,.02/)            ; fresh
  plotlevs(11,:) = (/-30,0,1/)            ; fhocn

 
  ocncmaps = (/"amwg256",\
               "amwg256",\
               "cmp_flux",\
               "cmp_flux",\
               "cmp_flux",\
               "cmp_flux",\
               "amwg256",\
               "amwg256",\
               "amwg256",\
               "amwg256",\
               "cmp_flux",\
               "amwg256"/)
  ;print(plotlevs)


;************************************************
;
;************************************************

  ; pick a field to plot
  ;fldtoplot = 4
       levs = plotlevs(fldtoplot,:)
    fldname = ocnflds(fldtoplot)
        wgt = ocnwgts(fldtoplot)
       cmap = ocncmaps(fldtoplot)
  plottitle = "field to ocn "+fldname
   wkstitle = "fld_to_ocn_"+fldname

;************************************************
; define the map
;************************************************

  ;wkstype="X11"
  wkstype="png"
  if(wkstype .eq. "png")then
   wkstype@wkWidth=2500
   wkstype@wkHeight=2500
  else
   wkstype@wkWidth=800
   wkstype@wkHeight=800
  end if
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@lbLabelBarOn  = True               ; turn off individual colorbars

  res@vpHeightF = 0.50
  res@vpWidthF  = 0.70

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

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

  ;res@tiMainFontHeightF = .010
  ;res@tiMainString = plottitle

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.015           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = ofile

 ; resP@gsnCenterStringFontHeightF      = 0.020
 ; resP@gsnCenterString                 = pltlab0
 ; resP@gsnCenterStringOrthogonalPosF   = 0.12
;************************************************
;
;************************************************

   anems = fnems->$fldname$(0,:,:)
   anems = anems*wgt
   res@gsnCenterString                 = plotlabs(0)+" "+fldname+"*"+sprintf("%6.4g",wgt)
   plot(0) = gsn_csm_contour(wks,anems,res)    ; create the plot

   acmeps = fcmeps->$fldname$(0,:,:)
   acmeps = acmeps*wgt
   res@gsnCenterString                 = plotlabs(1)+" "+fldname+"*"+sprintf("%6.4g",wgt)
   plot(1) = gsn_csm_contour(wks,acmeps,res)    ; create the plot

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/2,1/),resP)

  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
