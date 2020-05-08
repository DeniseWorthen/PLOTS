;*************************************************
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  forcingname = "CFSR"
      runname = "cfsr"
  ;forcingname = "GEFS"
  ;    runname = "gefs"
  rtsrc= "/scratch2/NCEPDEV/climate/Denise.Worthen/WORK/DATM_SA/DATM/"
  
  ;datmflds = (/"Dusfc",     \
  ;             "Dvsfc",     \
  ;             "Tlowest",   \
  ;             "Qlowest",   \
  ;             "Dswrf",     \
  ;             "Dlwrf",     \
  ;             "Shtfl",     \
  ;             "Lhtfl",     \
  ;             "Prate",     \
  ;             "Snwrate"    \ 
  ;            /)
  datmflds = (/"mean_zonal_moment_flx_atm", \
               "mean_merid_moment_flx_atm", \
               "inst_height_lowest",        \
               "inst_temp_height_lowest",   \
               "mean_down_sw_flx",          \
               "mean_down_lw_flx",          \
               "mean_sensi_heat_flx",       \
               "mean_laten_heat_flx",       \
               "mean_prec_rate",            \
               "mean_fprec_rate"            \ 
              /)

  nflds = dimsizes(datmflds)

  forcflds = (/"dusfc",         \
               "dvsfc",         \
               "tmp_hyblev1",   \
               "spfh_hyblev1",  \
               "DSWRF",         \
               "DLWRF",         \
               "shtfl_ave",     \
               "lhtfl_ave",     \
               "precp",         \
               "fprecp"         \
              /)

  ; plot levels
  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.00,    1.00,  0.050/)   ; dusfc
  plotlevs( 1,:) = (/  -1.00,    1.00,  0.050/)   ; dvsfc
  plotlevs( 2,:) = (/ 220.00,  320.00,  2.000/)   ; tmp lev1
  plotlevs( 3,:) = (/   0.00,    0.02,  0.002/)   ; sph lev1
  plotlevs( 4,:) = (/   0.00, 1000.00, 20.000/)   ; dswrf
  plotlevs( 5,:) = (/   0.00,  460.00, 10.000/)   ; dlwrf
  plotlevs( 6,:) = (/-120.00,  120.00, 10.000/)   ; latent
  plotlevs( 7,:) = (/ -20.00,  300.00, 10.000/)   ; sensible
  plotlevs( 8,:) = (/   0.00,    1.00,  0.050/)     ; lprec*3600 mm/hr
  plotlevs( 9,:) = (/   0.00,    0.10,  0.005/)     ; fprec*3600 mm/hr

  cmap="BlueWhiteOrangeRed"

;************************************************
; time step
;************************************************

  lstep = 1-1
  year="2011"
  month="10"
  day="02"
  hour="18"
  timestamp = year+"-"+month+"-"+day+"T"+hour+":00:00"
       date = year+month+day+hour
  
    atmexp="DATM_OUTPUT/"+runname+"/field_atm_exporta_"+timestamp
  ;  atmexp="DATM_OUTPUT/"+runname+"_clockori/field_atm_exporta_"+timestamp
   forcing="DATM_INPUT/"+runname+"."+date

  ; atm grid coords in mediator
  gmedx_a = addfile(rtsrc+"DATM_OUTPUT/"+runname+"/atmlonc.nc","r")
  gmedy_a = addfile(rtsrc+"DATM_OUTPUT/"+runname+"/atmlatc.nc","r")
  ; atm coords
  atmlon=gmedx_a->atmlonc
  atmlat=gmedy_a->atmlatc

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 6
       levs = plotlevs(fldtoplot,:)
    fldname = forcflds(fldtoplot)
   dfldname = datmflds(fldtoplot)
   wkstitle = runname+"_"+fldname+"_"+date
 
  ; special settings
       wgt = 1.0
  if(fldname .eq. "precp" .or. fldname .eq. "fprecp")then   ; make levels easier
       wgt = 3600.0
  end if

  ; atm forcing
   fatm = addfile(rtsrc+forcing+".nc","r")
   aatm = fatm->$fldname$(lstep,:,:)
   aatm = wgt*aatm
  if(fldname .eq. "precp" .or. fldname .eq. "fprecp")then   ; make levels easier
     aatm@units = "mm/hr"
  end if

  ; field exported by datm
   fexp = addfile(rtsrc+atmexp+".nc","r")
   aexp = fexp->$dfldname$(lstep,:,:)
   aexp = wgt*aexp
   aexp@lat2d=atmlat
   aexp@lon2d=atmlon

;************************************************
; create plot
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file
  plot = new(2,graphic)

  res            = True                          ; plot mods desired
  ;res@gsnPolar   = "NH"                          ; specify the hemisphere
  ;res@mpMinLatF  = 45                            ; minimum lat to plot
  ;res@mpMinLatF  = 85                            ; minimum lat to plot
  ;res@mpMinLatF  = 66                            ; minimum lat to plot
  res@mpFillOn   = False
  res@cnFillMode = "MeshFill"

  res@gsnDraw = False
  res@gsnFrame = False
  ;res@gsnMaximize=True

  res@cnFillDrawOrder    = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  ;res@cnLevelSpacingF   = 3.                    ; interval spacing
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn      = False                 ; turn off individual cb's

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@tiMainFontHeightF    = 0.015
  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterStringOrthogonalPosF = .15

;************************************************

   res@gsnCenterString = forcingname+" forcing"
  plot(0) = gsn_csm_contour_map(wks,aatm,res)    ; create the plot

   res@gsnCenterString = "DATM export"
  plot(1) = gsn_csm_contour_map(wks,aexp,res)    ; create the plot

;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0

  resP@gsnMaximize           = True              ; maximize in frame
  resP@gsnFrame              = False             ; don't advance frame yet
  resP@gsnPanelLabelBar      = True              ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = timestamp

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   print(imcmd)
   system(imcmd)
  end if

end
