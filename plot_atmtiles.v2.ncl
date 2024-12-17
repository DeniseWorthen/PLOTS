;**********************************************************
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

  RT="/glade/derecho/scratch/worthen/testfix/"

  nl = str_get_nl()
  nflags = 9
  date = "2021-03-22-22800"
  atmres = 48

  dirs = (/"base.c48/", "fix.c48/"/)

  ntile = 6
  ndirs = dimsizes(dirs)
  vname = "atmExp_So_t"
  wkstitle = "test"
 ; retrieve orodata file from INPUT directory for masking
  mskfilelist = systemfunc("ls "+RT+dirs(0)+"INPUT/oro_data.tile*.nc")
 ;print(mskfilelist)
  ofiles = addfiles(mskfilelist,"r")
  ListSetType(ofiles,"join")
  mskname = "slmsk"
  msklonname = "geolon"
  msklatname = "geolat"
  mskvar = ofiles[:]->$mskname$
  mskvar@lon2d = ofiles[0]->$msklonname$
  mskvar@lat2d = ofiles[0]->$msklatname$
 ;printVarSummary(mskvar)

;**********************************************************
; retrieve lat/lon from first coupler history file
;**********************************************************

  fname = "ufs.cpld.cpl.hi.atm.2021-03-22-22800.nc"
  files = addfiles(RT+dirs+"ufs.cpld.cpl.hi.atm.2021-03-22-22800.nc","r")

  ;--- read coordinate variables ---
  lat3d = files[0]->atmImp_lat(0,:,:,:)
  lon3d = files[0]->atmImp_lon(0,:,:,:)
  lat3d@units = "degrees_N"
  lon3d@units = "degrees_E"
  levs=(/-1,1,.05/)

  ;print(files)
  var3d = files[1]->$vname$(0,:,:,:) - files[0]->$vname$(0,:,:,:)
  var3d = 1.0e13*var3d
  var3d = mask(var3d,mskvar,0.0)

  build="v8.8.0b03:  "
  plotlab=build+dirs(1)+"-"+dirs(0)+"  "+vname
;************************************************
; create spatchcock plot of a field on atm tiles
;************************************************

 ; re-arrange tiles that are on their side
 do kk = 0,ntile-1
   if any((kk .eq. (/ 3, 4 /))) then
    var3d(kk,:,:) = (/ transpose(var3d(kk,:,:)) /)
    var3d(kk,:,:) = var3d(kk,::-1,:)
   end if
   if any((kk .eq. (/ 2 /))) then
    var3d(kk,:,:) = (/ transpose(var3d(kk,:,:)) /)
    var3d(kk,:,:) = var3d(kk,:,::-1)
   end if
 end do

 palette="BlueWhiteOrangeRed"

;************************************************
; define the map
;************************************************

     wkstype="X11"
     ;wkstype="png"
     wkstype@wkWidth=800
     wkstype@wkHeight=800
     wks   = gsn_open_wks (wkstype,wkstitle)    ; send graphics to X11 window

     res                      = True		; plot mods desired
     res@gsnDraw              = False		; do not draw until the end
     res@gsnFrame             = False		; do not automatically advance 'frame'

     ;res@cnFillMode = "MeshFill"
     res@cnFillMode = "RasterFill"

     plot = new(ntile,graphic)

     size = 0.22
     res@vpWidthF = size
     res@vpHeightF = size

     res@cnFillDrawOrder   = "PreDraw"          ; draw contours first
     res@cnFillOn          = True               ; color fill
     res@cnLinesOn         = False              ; no contour lines
     res@cnLineLabelsOn    = False
     res@cnInfoLabelOn     = False
     res@cnFillPalette     = palette

     res@cnMissingValFillPattern = 0            ; choose fill pattern 0 (solid fill)
     res@cnMissingValFillColor   = "gray"       ; color fill missing areas blue

     res@cnLevelSelectionMode = "ManualLevels"  ; set the contour levels with the following 3 resources
     res@cnMinLevelValF  = levs(0)              ; set the minimum contour level
     res@cnMaxLevelValF  = levs(1)              ; set the maximum contour level
     res@cnLevelSpacingF = levs(2)              ; set the interval between contours

     res@tmYROn = False
     res@tmXTOn = False
     res@tmYLOn = False
     res@tmXBOn = False

     res@gsnStringFont = 22
     res@gsnStringFontHeightF = 0.02

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
       else
        res@lbLabelBarOn = False
       end if
       if( kk .eq. 2) then
         res@gsnLeftString = plotlab
       else
        res@gsnLeftString = ""
       end if
       plot1 = gsn_csm_contour(wks, var3d(kk,:,:), res)
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
