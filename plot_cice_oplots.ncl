;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  ;hemi="NH"
  ;hemi="SH"
  hemi = "none"


  minlat = 66.0
  ;minlat = 76.0
  ;minlat = 88.0
  ;minlat = 80.0

  ;minlat =  88.0
  maxlat = -50.0
  ;minlon =  140.0
  ;maxlon =  270.0

  ;RT4 = "/glade/scratch/worthen/MStone/"
  RT="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"
  rtname = "base/"

;************************************************
; read in netCDF file
;************************************************

  lstep=0
  ifile = addfile(RT+rtname+"history/hi.ice.nc","r")

    iname="sst_h"
    oname1="frzmlt_h"
    oname2="aice_h"

    ; jun avg
    lb=124-1
    le=243-1

    icevar=dim_avg_n_Wrap(ifile->$iname$(lb:le,:,:),0)
    ovar1=dim_avg_n_Wrap(ifile->$oname1$(lb:le,:,:),0)
    ovar2=dim_avg_n_Wrap(ifile->$oname2$(lb:le,:,:),0)

    icevar@lon2d=ifile->TLON(:,:)
    icevar@lat2d=ifile->TLAT(:,:)

    ovar1=1.0e-3*ovar1
    ovar1@lon2d=ifile->TLON(:,:)
    ovar1@lat2d=ifile->TLAT(:,:)
    ;printVarSummary(ovar1)

    palette="BlueWhiteOrangeRed"

    levs = (/-2.0, 15.0, 0.5/)

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice5")              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  if (hemi .ne. "none")then
    res@gsnPolar   =  hemi                         ; specify the hemisphere
    if(hemi .eq. "NH")then
      res@mpMinLatF    =  minlat                          ; minimum lat to plot
      res@mpCenterLonF = -45
    end if
    if(hemi .eq. "SH")then
      res@mpMaxLatF    = -50                            ; minimum lat to plot
      res@mpCenterLonF = 0.0
    end if
  else
    ; near tip Greenland
    res@mpMinLatF            =  55.0      ; range to zoom in on
    res@mpMaxLatF            =  71.0
    res@mpMinLonF            =  -70.0
    res@mpMaxLonF            =  -15.0
    res@mpCenterLonF         =  -58.0
  end if

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = True

  ;res@cnFillOn          = False                  ; color fill

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

  res@gsnStringFontHeightF = 0.01
;*;************************************************
; resources for overlay
;************************************************

  ores1                  = True        ; plot mods desired
  ores1@cnLineThicknessF = 3.0            ; line thickness
  ores1@cnLineColor      = "black"        ; line color
  ores1@cnLineLabelsOn   = True
  ores1@cnInfoLabelOn    = False
  ores1@gsnDraw          = False ; don't draw
  ores1@gsnFrame         = False ; don't advance frame
  ores1@gsnLeftString    = ""    ; no titles
  ores1@gsnRightString   = ""
 ;ores1@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores1@gsnContourNegLineDashPattern = 1
  ;ores1@cnLevels = (/-400/)
  ;,0,100/)
  ;,50,25/)

;***********************************************
; resources for overlay
;************************************************

  ores2                  = True        ; plot mods desired
  ores2@cnLineThicknessF = 4.0            ; line thickness
  ores2@cnLineColor      = "green"        ; line color
  ores2@cnLineLabelsOn   = False
  ores2@cnInfoLabelOn    = False
  ores2@gsnDraw          = False ; don't draw
  ores2@gsnFrame         = False ; don't advance frame
  ores2@gsnLeftString    = ""    ; no titles
  ores2@gsnRightString   = ""
  ores2@cnLevelSelectionMode = "ExplicitLevels"     ; set the contour levels with the following 3 resources
  ores2@cnLevels = (/0,1.0,.2/)

;************************************************
;
;************************************************

  if(hemi .eq. "none")then
    plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
    oplot1 = gsn_csm_contour(wks,ovar1,ores1)
    overlay(plot,oplot1)
  else
   plot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  end if
  ;plot = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot
  ;plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;pum= gsn_add_polymarker(wks,plot,center_xlon,center_xlat,mkres)

  draw(plot)
  frame(wks)

exit

end
