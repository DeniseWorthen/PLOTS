;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

    ; RT = "/glade/scratch/worthen/FV3_RT/rt_22529/"
    ; RT = "/glade/scratch/worthen/FV3_RT/wave_test/"
     RT = "/glade/scratch/worthen/WaveUnstr/"

   nl = str_get_nl()
   nflags = 9
   dirs = (/"unstr_noland/"/)
  ; dirs = (/"./"/)
  ;   fsrc = "dststatus.atm.ocn.bilnr.nc"
  ;doffile = "dof.ocn.nc"
  ;   fsrc = "dststatus.atm.ice.consf.nc"
     ;fsrc = "dststatus.atm.ocn.nstod_consf.nc"
    ;fsrc = "dststatus.atm.ocn.consf_fnorm.nc"
   ; fsrc = "dststatus.atm.ocn.consf.nc"
  ;   fsrc = "unityone.atm.ocn.consf.nc"
  ;   fsrc = "dststatus.atm.ocn.bilnr_nstod.nc"
  ;   fsrc = "dststatus.atm.ocn.fillv_bilnr.nc"
   ;  fsrc = "dststatus.atm.wav.nstod_consf_2.nc"
   ;  fsrc = "dststatus.atm.wav.consf.nc"
   ;  fsrc = "dststatus.ice.wav.bilnr_nstod.nc"
   ;  fsrc = "dststatus.atm.wav.fillv_bilnr.nc"
     fsrc = "dststatus.atm.wav.bilnr_nstod.nc"
   ;  vname = "mask"
   ;   levs = (/0,2,1/)
   ;  fsrc = "meshmask.nc"
  doffile = "dof.wav.nc"

    vname = "dststatus"
     levs = (/0,9,1/)
  ;   fsrc = "dststatus.atm.ocn.bilnr_nstod.nc"
  ;   fsrc = "dststatus.atm.ocn.consf.nc"
  ;   fsrc = "dststatus.atm.wav.nstod_consf.nc"
     ;fsrc = "dststatus.atm.wav.nstod_consf_2.nc"
  ;   fsrc = "dststatus.wav.ocn.bilnr_nstod.nc"
  ;doffile = "dof.ocn.nc"

  ;   vname = "mask"
  ;    levs = (/0,2,1/)
  ;    fsrc = "dststatus.meshmask.ice.nc"
  ; doffile = "dof.ice.nc"


  ndirs = dimsizes(dirs)

;**********************************************************
;
;**********************************************************

do nd = 0,ndirs-1
  dirsrc = RT+dirs(nd)
   ifile = fsrc

  fname = dirsrc+ifile
  print("input file "+fname)
  ff = addfile(fname,"r")

  var1d = ff->$vname$(:)
  ;printVarSummary(var1d)
  do i = 0,nflags-1
   ret = dststatus_counts(var1d,i)
  end do

  ; get the index seq to resort
  doff = addfile(dirsrc+doffile,"r")
  dof = doff->dof(:)

  ip = dim_pqsort(dof,1)
  var1d_sort=var1d
  var1d_sort=var1d(ip)

;************************************************
; create plot of dststatus
;************************************************

   dirsrc = RT+dirs(nd)
    ofile = dirsrc+fsrc
       ff = addfile(ofile, "r")
     data = ff->$vname$
     flon = addfile(dirsrc+"emesh.x.nc","r")
     flat = addfile(dirsrc+"emesh.y.nc","r")
     data@lon1d = flon->coordx
     data@lat1d = flat->coordy
     ;printVarSummary(data)

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstitle=vname
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"

  res@vpWidthF          = 0.70
  res@vpHeightF         = 0.40

  res@gsnStringFontHeightF = 0.01
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True
  res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res@lbLabelAlignment = "BoxCenters"

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   = "amwg"

  res@tiMainFontHeightF = .010
  res@tiMainString = fsrc

  res@mpOutlineOn          = True
  res@mpFillOn             = False
  res@gsnAddCyclic         = True

;************************************************
;
;************************************************

   plot = gsn_csm_contour_map(wks,data,res)    ; create the plot

  draw(plot)
  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

end do  ; ndirs

exit
end
