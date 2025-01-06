; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; based on script written by Ufuk Turuncoglu <turuncu@ucar.edu>
; with modifications to work w/ my mutli-field tile difference
; script
;************************************************


atmres="C24"
ocnres="500"

RT="/scratch1/NCEPDEV/da/George.Gayno/ufs_utils.git/UFS_UTILS/fix/orog.lowres/"+atmres+"/ocean_mask/"+ocnres+"/"
;RT="/scratch1/NCEPDEV/global/glopara/fix/orog/20240917/"+atmres+"/ocean_mask/"+ocnres+"/"

plotlab=atmres+":mx"+ocnres+" land_frac"

;/scratch1/NCEPDEV/da/George.Gayno/ufs_utils.git/UFS_UTILS/fix/orog.lowres/C12/ocean_mask/
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

 tlonname = "grid_xt"
 tlatname = "grid_yt"

 wkstitle = atmres+"mx"+ocnres+"land_frac"
 aname = "land_frac"

  ;palette="BlueWhiteOrangeRed"
  palette="BlWhRe"

  filelist = systemfunc("ls "+RT+atmres+".mx"+ocnres+".tile*.nc")
  print(filelist)
  ofiles = addfiles(filelist,"r")
  ListSetType(ofiles,"join")

;************************************************
;
;************************************************

  ; make 6 tiled plot of given field diff
  ii = 0

   data = ofiles[:]->land_frac

    do kk = 0,ntiles-1
;--- special care for following tiles ---
      if any((kk .eq. (/ 3, 4 /))) then
        data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
        data(kk,:,:) = data(kk,::-1,:)
      end if
      if any((kk .eq. (/ 2 /))) then
        data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
        data(kk,:,:) = data(kk,:,::-1)
      end if
  end do  ; kk

 ; re-arrange tiles that are on their side
 ; do kk = 0,ntiles-1
 ;    if any((kk .eq. (/ 2 /))) then
 ;     data(kk,:,:) = data(kk,:,::-1)
 ;    end if

 ;    if any((kk .eq. (/ 0,1,5 /))) then
 ;     data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
 ;    end if

 ;    if any((kk .eq. (/ 3,4 /))) then
 ;     data(kk,:,:) = data(kk,::-1,:)
 ;    end if
 ; end do

  levs = (/0,1,.1/)
  plottitle=plotlab


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

  kk=2
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
