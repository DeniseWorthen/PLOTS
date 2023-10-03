; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; based on script written by Ufuk Turuncoglu <turuncu@ucar.edu>
; with modifications to work w/ my mutli-field tile difference
; script
;************************************************

  ;RT = "/work/noaa/epic-ps/jongkim/butterfly_exp/"
  RT = "/scratch1/NCEPDEV/stmp2/Jong.Kim/FV3_RT/"

  ;plottype = "land"
  ;plottype = "not land"
  plottype = "all"

  rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6

;************************************************
;
;************************************************

  lstep=0
  ntiles=6

 ; in forecast history files
    tlonname = "grid_xt"
    tlatname = "grid_yt"

 wkstitle = "butterfly test"
  runlabs = (/"control","exp"/)
 dirs = (/"develop_control/cpld_control_p8_intel/", "develop_exp/cpld_control_p8_intel/" /)
  time = "f024."
  fsrc = "atm"
 ndirs = dimsizes(dirs)
   nts = dimsizes(time)

  ;palette="BlueWhiteOrangeRed"
  palette="BlWhRe"

  atmflds = (/"tmp"/)
  atmwgts = (/1.0/)
  nflds = dimsizes(atmflds)

  plotlevs = new((/nflds,3/), float)
  plotlevs( 0,:) = (/  -2.0,  2.0, 0.2/) ; tmp@k=76

  ; retrieve orodata file from INPUT directory for getting dims
  ofile = addfile(RT+dirs(0)+"INPUT/oro_data.tile1.nc","r")
  mskname = "slmsk"
  msklonname = "geolon"
  msklatname = "geolat"
  mskvar = ofile->$mskname$(:,:)
  mskvar@lon2d = ofile->$msklonname$
  mskvar@lat2d = ofile->$msklatname$
  ndims = dimsizes(mskvar)
  ny = ndims(0)
  nx = ndims(1)
  delete ([/mskvar,ndims/])

;************************************************
;
;************************************************

  ; make 6 tiled plot of given field diff
  ii = 0
     data = new((/ ntiles, ny, nx/), "double")
  mskdata = new((/ ntiles, ny, nx/), "double")

  do kk = 0,ntiles-1
  ; add history files on tile
   tile="tile"+sprinti("%d",kk+1)
   files=addfiles(RT+dirs+fsrc+time+tile+".nc","r")
   print(files)

   ofile = addfile(RT+dirs(0)+"INPUT/oro_data."+tile+".nc","r")
   ;print(ofile)
   mskname = "slmsk"
   msklonname = "geolon"
   msklatname = "geolat"
   mskvar = ofile->$mskname$(:,:)
   mskvar@lon2d = ofile->$msklonname$
   mskvar@lat2d = ofile->$msklatname$

   aname = atmflds(ii)
     wgt = atmwgts(ii)
   print("variable "+aname+"  weight "+wgt)

   ; vertical level 76
    avar = files[1]->$aname$(0,75,:,:)-files[0]->$aname$(0,75,:,:)
    avar@lon2d = files[0]->$tlonname$
    avar@lat2d = files[0]->$tlatname$
    ;printVarSummary(avar)
    lndonly = avar
    lndonly = mask(avar*wgt,mskvar,1.0)  ; land only
    ocnonly = avar
    ocnonly = mask(avar*wgt,mskvar,0.0)  ; not land only

    if(plottype .eq. "land")then
     avar = lndonly
     msklab = "Land Points Only"
    end if
    if(plottype .eq. "not land")then
     avar = ocnonly
     msklab = "Non-Land Points Only"
    end if
    if(plottype .eq. "all")then
     avar = avar*wgt
     msklab = "All points"
    end if

       data(kk,:,:) = (/avar(:,:)/)
    mskdata(kk,:,:) = (/mskvar(:,:)/)

    ;--- special care for following tiles ---
    if any((kk .eq. (/ 3, 4 /))) then
         data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
         data(kk,:,:) = data(kk,::-1,:)
      mskdata(kk,:,:) = (/ transpose(mskdata(kk,:,:)) /)
      mskdata(kk,:,:) = mskdata(kk,::-1,:)

    end if
    if any((kk .eq. (/ 2 /))) then
         data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
         data(kk,:,:) = data(kk,:,::-1)
      mskdata(kk,:,:) = (/ transpose(mskdata(kk,:,:)) /)
      mskdata(kk,:,:) = mskdata(kk,:,::-1)
    end if
    delete ([/avar,mskvar,lndonly,ocnonly/])
  end do  ; kk
  ;print(data(:,45,45))
  plottitle=runlabs(1)+" - "+runlabs(0)+"  "+aname+",  "+msklab+",  "+time

  levs = plotlevs(ii,:)

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
  ores@cnLineThicknessF = 0.5
  ores@cnLineColor = "green"

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
    plot1 = gsn_csm_contour(wks, data(kk,:,:), res)
    draw(plot1)
    oplot = gsn_csm_contour(wks, mskdata(kk,:,:), ores)
    draw(oplot)

    txres@txPosXF = xpos(kk)+0.01
    txres@txPosYF = ypos(kk)-0.01
    txres@txAngleF = 0
    txres@txFont = 22
    txres@txFontHeightF = 0.015
    txres@txFontColor = "green"
    text = gsn_create_text(wks, sprinti("%d", kk+1), txres)
    draw(text)
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
