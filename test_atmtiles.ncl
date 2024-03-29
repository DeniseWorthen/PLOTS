;**********************************************************
; re-write CMEPS dststatus files for atm
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

   RT="/scratch1/NCEPDEV/nems/emc.nemspara/RT/NEMSfv3gfs/develop-20221220/INTEL/cpld_bmark_p8/"
   nl = str_get_nl()
   nflags = 9
   date = "2021-03-22-"
   ;time = "64080"
   ;time = "64800"
   time = 65520
   ; atmres = 96

 ;   atmres = 192
    atmres = 384

   ;dirs = (/"unstrnoland3PE/"/)
    dirs = (/"RESTART/"/)
   ; dirs = (/"tripnoland/"/)
   wkstitle="new"

  ntile = 6
  ndirs = dimsizes(dirs)

  ; retrieve orodata file from INPUT directory for masking
  filelist = systemfunc("ls /scratch1/NCEPDEV/nems/emc.nemspara/RT/NEMSfv3gfs/input-data-20221101/FV3_input_data384/INPUT/oro_data.tile*.nc")
  print(filelist)
  ofiles = addfiles(filelist,"r")
  ListSetType(ofiles,"join")
  mskname = "slmsk"
  msklonname = "geolon"
  msklatname = "geolat"
  mskvar = ofiles[:]->$mskname$
  mskvar@lon2d = ofiles[0]->$msklonname$
  mskvar@lat2d = ofiles[0]->$msklatname$
  printVarSummary(mskvar)
;************************************************
; create spatchcock plot of a field on atm tiles
;************************************************

  dirsrc = RT+dirs(0)
  restlist=systemfunc("ls "+RT+dirs(0)+"sfc_data.tile*.nc")
  print(restlist)
  rfiles = addfiles(restlist,"r")
  ListSetType(ofiles,"join")
  varname="albdifnir_lnd"
  avar = rfiles[:]->$varname$
  ; use orodata
  avar@lon2d = ofiles[0]->$msklonname$
  avar@lat2d = ofiles[0]->$msklatname$
  printVarSummary(avar)

    ;if(1.eq.0)then
     ; re-arrange tiles that are on their side
     do kk = 0,ntile-1
       if any((kk .eq. (/ 3, 4 /))) then
         data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
         data(kk,:,:) = data(kk,::-1,:)
       end if
       if any((kk .eq. (/ 2 /))) then
         data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
         data(kk,:,:) = data(kk,:,::-1)
       end if
    end do
    ;end if

    ;palette = "ncv_roullet"
    ;palette = "amwg"
    palette="WhBlGrYeRe"
    ;palette="NCV_jet"
   plotlab = vname

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

     plot = new(ntile,graphic)

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
     ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

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

     do kk = 0, ntile-1
       ;--- set position ---
       res@vpXF = xpos(kk)
       res@vpYF = ypos(kk)
       ;print(kk+" "+res@vpXF+" "+res@vpYF)

       if (kk .eq. 1) then
        res@lbLabelBarOn = True
        res@pmLabelBarWidthF = size*1.8
        res@pmLabelBarHeightF = 0.03
        res@pmLabelBarParallelPosF = 0.97
        res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
        res@lbLabelAlignment = "BoxCenters"
       else
        res@lbLabelBarOn = False
       end if
       if( kk .eq. 2) then
        res@gsnLeftString = plotlab+":  "+date+time
       else
        res@gsnLeftString = ""
       end if
       plot1 = gsn_csm_contour(wks, data(kk,:,:), res)
       draw(plot1)

       txres@txPosXF = xpos(kk)+0.01
       txres@txPosYF = ypos(kk)-0.01
       txres@txAngleF = 0
       txres@txFont = 22
       txres@txFontHeightF = 0.015
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
