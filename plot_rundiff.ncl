;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  idate = "20120101"
  cyear = "2012"
   cmon = "01"
   cday = "12"

  rt0 = RT2+"BM2_ice/gfs."+idate+"/00/"
  rt1 = RT3+"BM2_rstcpld6/"+"rtgen.78840/tmp/cpld_fv3_384_mom6_cice_2d_bm2/history/"

  fnames = (/"ice"+cyear+cmon+cday+"00.01."+idate+"00.nc", \
             "iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc"/)
  ;fnames = (/"iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc", \
  ;           "iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc"/)

  ;print(fnames)
  print(rt0+fnames(0))
  print(rt1+fnames(1))
;************************************************
;
;************************************************

  iskp = 2
  jskp = 2

;************************************************
;
;************************************************

  vname = "sst_h"
  ; levs = (/-5.0,5.0,0.5/)
   levs = (/-1.0,1.0,0.1/)
  ; levs = (/-0.1,0.1,0.01/)
  ; levs = (/-0.05,0.05,0.005/)
  ; levs = (/-2.0,40.0,1.0/)
  ; levs = (/-2.0,4.0,0.2/)
  lstep = 1-1

  f0=addfile(rt0+fnames(0),"r")
  f1=addfile(rt1+fnames(1),"r")

  ;dvar=f1->$vname$(lstep,jbeg:jend:jskp,ibeg:iend:iskp)
  dvar=f1->$vname$(lstep,::jskp,::iskp) - f0->$vname$(lstep,::jskp,::iskp)
  dvar@lon2d=f0->TLON(::jskp,::iskp)
  dvar@lat2d=f0->TLAT(::jskp,::iskp)

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,vname)              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn = False
  res@cnMissingValFillColor    = "gray70"

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  ;res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette   =  "WhBlReWh"                      ; choose colormap
  ;res@cnFillPalette   =  "BlWhRe"                      ; choose colormap
  res@cnFillPalette   =  "BlueDarkRed18"                      ; choose colormap

  plot = gsn_csm_contour_map(wks,dvar,res)    ; create the plot

  draw(plot)
  frame(wks)

exit
end
