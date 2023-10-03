; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; based on script written by Ufuk Turuncoglu <turuncu@ucar.edu>
; with modifications to work w/ my mutli-field tile difference
; script
;************************************************

  RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/mean2inst/"

  ;plottype = "land"
  ;plottype = "not land"
  ;plottype = "all"

  rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6

;************************************************
;
;************************************************

  lstep=0
  ntiles=6

 ; in coupler history files
  tlonname = "Med_frac_atm_lon"
  tlatname = "Med_frac_atm_lat"

 wkstitle = "mean2inst"
 dirs = (/"base/"/)
  time = "2021-03-22-36000.nc"
  fsrc = "ufs.cpld.cpl.hi.atm."
 ndirs = dimsizes(dirs)
   nts = dimsizes(time)

  ;palette="BlueWhiteOrangeRed"
  palette="BlWhRe"

  ; mean fields
  meanflds = (/ "atmImp_Faxa_taux" , \
                "atmImp_Faxa_tauy" , \
                "atmImp_Faxa_sen"  , \
                "atmImp_Faxa_evap" , \
                "atmImp_Faxa_lwdn" , \
                "atmImp_Faxa_lwnet", \
                "atmImp_Faxa_swnet", \
                "atmImp_Faxa_swndr", \
                "atmImp_Faxa_swvdr"  \
             /)

  ; inst fields
  instflds = (/ "atmImp_inst_zonal_moment_flx",   \
                "atmImp_inst_merid_moment_flx",   \
                "atmImp_inst_sensi_heat_flx"  ,   \
                "atmImp_inst_evap_rate"       ,   \
                "atmImp_inst_down_lw_flx"     ,   \
                "atmImp_inst_net_lw_flx"      ,   \
                "atmImp_inst_net_sw_flx"      ,   \
                "atmImp_inst_down_sw_ir_dir_flx", \
                "atmImp_inst_down_sw_ir_dir_flx"  \
                /)
  nflds = dimsizes(meanflds)

  ; easier plots
  atmwgts = (/1.e16, \
              1.e16, \
              1.e14, \
              1.e14, \
              1.e14, \
              1.e14, \
              1.e14, \
              1.e14, \
              1.e14  \
            /)

  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 1,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 2,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 3,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 4,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 5,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 6,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 7,:) = (/  -1.0,  1.0, 0.1/)
  plotlevs( 8,:) = (/  -1.0,  1.0, 0.1/)

;************************************************
;
;************************************************

  ; make 6 tiled plot of given field diff
  fld2plot = 0

  fname=fsrc+time
  files=addfiles(RT+dirs+fname,"r")
  print(fname)

   mname = meanflds(fld2plot)
   iname = instflds(fld2plot)
     wgt = atmwgts(fld2plot)
   print("variable "+mname+"  "+iname+"  weight "+wgt)

   mdata = files[0]->$mname$(0,:,:,:)
   mdata = where(abs(mdata) .gt. 1.0e35, 0.0, mdata)
   idata = files[0]->$iname$(0,:,:,:)
   idata = where(abs(idata) .gt. 1.0e35, 0.0, idata)

   data = idata
   data = mdata - idata
   data = data*wgt

    do kk = 0,ntiles-1
;--- special care for following tiles ---
      if any((kk .eq. (/ 3, 4 /))) then
        data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
        data(kk,:,:) = data(kk,::-1,:)

      end if
      if any((kk .eq. (/ 2 /))) then
        data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
        data(kk,:,:) = data(kk,::-1,:)
      end if
  end do  ; kk
  plottitle=mname+" -  "+iname+"  "+data@units
  data@units = ""

  levs = plotlevs(fld2plot,:)
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

  plot = new(ntiles,graphic)
  oplot = new(ntiles,graphic)

  size = 0.22
  res@vpWidthF = size
  res@vpHeightF = size

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@cnFillPalette     = palette

  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@tmYROn = False
  res@tmXTOn = False
  res@tmYLOn = False
  res@tmXBOn = False

  res@gsnStringFont = 22
  res@gsnStringFontHeightF = 0.010

  ; over-lay (land contour)
  ores = res
  ores@cnFillOn = False
  ores@cnLinesOn = True
  ores@cnLineLabelsOn = False
  ores@cnLevels = (/ 0.999999 /)
  ores@cnInfoLabelOn = False
  ores@cnLineThicknessF = 0.1

  ; text resources
  txres = True
  txres@gsnFrame = False
  txres@txJust = "CenterCenter"

;************************************************
;
;************************************************

  ;--- tile order ---
  ;   2
  ; 4 0 1 3
  ;   5
  xpos = tofloat((/ 1, 2, 1, 3, 0, 1 /))*size+0.05
  ypos = 0.9-tofloat((/ 1, 1, 0, 1, 1, 2 /))*size

  do kk = 0, ntiles-1
    ;--- set position ---
     res@vpXF = xpos(kk)
     res@vpYF = ypos(kk)
    ores@vpXF = xpos(kk)
    ores@vpYF = ypos(kk)
    ;print(kk+" "+res@vpXF+" "+res@vpYF)

    if (kk .eq. 1) then
     res@lbLabelBarOn = True
     res@pmLabelBarWidthF = size*1.8
     res@pmLabelBarHeightF = 0.03
     res@pmLabelBarParallelPosF = 0.97
    else
     res@lbLabelBarOn = False
    end if
    if( kk .eq. 2) then
     res@gsnLeftString = plottitle
    else
     res@gsnLeftString = ""
    end if
    ;printVarSummary(data(kk,:,:))
    plot1 = gsn_csm_contour(wks, data(kk,:,:), res)
    draw(plot1)

    if (kk .eq. 2) then
    txres@txPosXF = xpos(kk)+0.01
    txres@txPosYF = ypos(kk)-0.01
    txres@txAngleF = 0
    txres@txFont = 22
    txres@txFontHeightF = 0.015
    text = gsn_create_text(wks, sprinti("%d", kk+1), txres)
    draw(text)
    end if
  end do

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
