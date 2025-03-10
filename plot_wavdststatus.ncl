;**********************************************************
; re-write CMEPS dststatus files for atm
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

 ;RT="/work2/noaa/stmp/dworthen/stmp/dworthen/FV3_RT/rt_721201/"
 ;RT="/work2/noaa/stmp/dworthen/stmp/dworthen/FV3_RT/rt_443270/"
 ;RT="/work2/noaa/stmp/dworthen/stmp/dworthen/FV3_RT/rt_3728644/"
 RT="/work2/noaa/stmp/dworthen/stmp/dworthen/ultralow.2/"

 nl = str_get_nl()
 nflags = 9
 date = "2021-03-22-22320"
 ;dirs=(/"warm.48/"/)
 dirs = (/"test/"/)
 plotlabs = (/"test"/)

 ; gridtype = "structured"
 ;vname = "dstocn_wav_ocn_bilnr_nstod"

 gridtype = "unstructured"
 ;vname = "dstwav_ocn_wav_bilnr_nstod"
 vname = "dstwav_atm_wav_bilnr_nstod"
 ;vname = "dstwav_wavmask"
 lonname = "dstwav_lon"
 latname = "dstwav_lat"

 levs = (/0,9,1/)

 fsrc = "ufs.cpld.dststatus.nc"
 fname = RT+dirs(0)+fsrc
 print("input file "+fname)
 ff = addfile(fname,"r")

 data = ff->$vname$(0,:)
  if (gridtype .eq. "unstructured") then
   data@lat1d = ff->$latname$(0,:)
   data@lon1d = ff->$lonname$(0,:)
 end if

 printVarSummary(data)

 total = 0
 ;do i = 0,nflags-1
 ;  total = total+dststatus_counts(data,i)
 ;end do
 ;print("total count of all dststatus types = "+total+" size of data = "+dimsizes(data))
  ;palette = "ncv_roullet"
    palette = "amwg"
    ;palette="WhBlGrYeRe"
    ;palette="NCV_jet"
   plotlab = plotlabs(0)

;************************************************
; define the map
;************************************************

     wkstitle="test"
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

     plot = new(1,graphic)

     res@vpWidthF          = 0.70
     res@vpHeightF         = 0.40
     ;size = 0.22
     ;res@vpWidthF = size
     ;res@vpHeightF = size

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

     ;res@tmYROn = False
     ;res@tmXTOn = False
     ;res@tmYLOn = False
     ;res@tmXBOn = False

     res@gsnStringFont = 22
     res@gsnStringFontHeightF = 0.010

;************************************************
;
;************************************************

   plot = gsn_csm_contour(wks,data,res)    ; create the plot
   draw(plot)
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
