;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************
begin

  hemi="NH"
  ;hemi="SH"

  minlat = 66.0

  RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************
; read in netCDF file
;************************************************

  ; avail downloads
   Dates = (/"2011-09-01", "2012-07-01"/)
   Names = (/"/scratch3/NCEPDEV/stmp2/Bin.Li/RUNDIRS/c384/2012070100/gfs/fcst/history/",\
             "/scratch4/NCEPDEV/stmp3/Jessica.Meixner/rtgen.63128/tmp/cpld_fv3_384_mom6_cice_2d_bm2/history/"/)

    ndates = dimsizes(Dates)
   tlatname="TLAT"
   tlonname="TLON"
    rfactor=1.0

;************************************************
; ice
;************************************************

  ; ice field
  ;varname="aice_h"
  ;levs=(/0.97,1.0,0.001/)
  ;levs=(/0.87,0.95,0.0010/)
  ;levs=(/0.50,1.00,0.010/)
  ;levs=(/0.0, 1.0, 0.02/)
  ;varname="hi_h"
  ;levs=(/0.0,3.0,0.1/)
  ;levs=(/0.0,2.0,0.1/)
  varname="Tsfc_h"
  ;levs=(/-6.0,0.0,0.1/)
  levs=(/-12.0,0.0,0.1/)
  ;varname="hi_h"
  ;levs=(/0.0,4.0,0.2/)
  ;varname="sst_h"
  ;levs=(/-1.80,-1.00,.02/)
  ;levs=(/-1.72,-1.66,.001/)
  ;levs=(/-1.5,-1.32,.01/)
  ;varname="sss_h"
  ;levs=(/28.4, 35.2, .2/)
  ;varname="fhocn_h"
  ;levs=(/-100.0,100.0,10.0/)
  ;varname="frzmlt_h"
  ;levs=(/-50.0,50.0,5.0/)
  ;levs=(/-20.0,20.0,2.0/)
  ;levs=(/-200.,200,20.0/)
  ;levs=(/-200.,200,20.0/)
  ;levs=(/-1000.,1000,50.0/)
  ;varname="meltt_h"
  ;levs=(/0.,3,0.1/)
  ;levs=(/0.,1,0.02/)
  ;varname="hpond_h"
  ;levs=(/0.,0.5,0.05/)
  ;varname="albsni_h"
  ;levs=(/20.,60.,1./)

  filelist1 = systemfunc("ls "+Names(0)+"iceh_06h*.nc")
  filelist2 = systemfunc("ls "+Names(1)+"iceh_06h*.nc")

   icefiles1 = addfiles(filelist1,"r")
   icefiles2 = addfiles(filelist2,"r")
  ;print(filelist1)
  ;print(filelist2)

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"BM2_"+varname)              ; send graphics to X11 window

  ; a max of ndates panels, not all used
  npanels = 2
    nrows = 1
    ncols = 1
     plot = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.05

  res@gsnPolar     =  "NH"                         ; specify the hemisphere
  res@mpMinLatF    =  minlat                       ; minimum lat to plot
  res@mpCenterLonF = -45

  res@cnFillDrawOrder    = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

  res@cnFillPalette        = "MPL_rainbow"              ; choose colormap
  ;res@cnFillPalette        = "BlWhRe"              ; choose colormap
  ;res@cnFillPalette        = "BlueWhiteOrangeRed"              ; choose colormap
  ;res@cnFillPalette        = "NCV_roullet"              ; choose colormap
  ;res@cnFillPalette        = "WhBlGrYeRe"              ; choose colormap

  res@gsnCenterStringFontHeightF = 0.020
;************************************************
;
;************************************************

  ; first 10 days
  lstep = 4*10 - 1

      ii = 0
    ivar = dim_avg_n_Wrap(icefiles1[:]->$varname$(:lstep,:,:),0)
    imsk = dim_avg_n_Wrap(icefiles1[:]->aice_h(:lstep,:,:),0)
    ivar@lon2d=icefiles1[0]->$tlonname$(:,:)*rfactor
    ivar@lat2d=icefiles1[0]->$tlatname$(:,:)*rfactor
    ivar@units=""
    ivar@long_name=""

    icevar = ivar
    icevar = mask(ivar, (imsk .eq. 0.0), False)
    
    ;res@gsnCenterString = Dates(ii)
    plot(ii) = gsn_csm_contour_map_polar(wks,icevar(:,:),res)    ; create the plot

    delete(ivar)
    delete(imsk)
    delete(icevar)


      ii = 1
    ivar = dim_avg_n_Wrap(icefiles2[:]->$varname$(:lstep,:,:),0)
    imsk = dim_avg_n_Wrap(icefiles2[:]->aice_h(:lstep,:,:),0)
    ivar@lon2d=icefiles2[0]->$tlonname$(:,:)*rfactor
    ivar@lat2d=icefiles2[0]->$tlatname$(:,:)*rfactor
    ivar@units=""
    ivar@long_name=""

    icevar = ivar
    icevar = mask(ivar, (imsk .eq. 0.0), False)

    ;res@gsnCenterString = Dates(ii)
    plot(ii) = gsn_csm_contour_map_polar(wks,icevar(:,:),res)    ; create the plot

    delete(ivar)
    delete(imsk)
    delete(icevar)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller

  ;resP@gsnPanelRowSpec     = True                ; tell panel what order to plot
  ;resP@gsnPanelCenter      = False               ; don't center

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  ;resP@gsnPanelMainString = "RASM output; 10 day means from date shown : "+varname
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

  ;gsn_panel(wks,plot,(/2,2,3/),resP)               ; now draw as one plot
  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot

exit

end
