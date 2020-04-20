;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
; This file still has to be loaded manually
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*************************************************
begin

 batch = "yes"
;************************************************
;
;************************************************

  model = "hycice"

 ; Dates2Plt = (/"2015-06-15", "2015-08-15"/)
 ; Dates2Plt = (/"2015-06-15", "2015-07-15", "2015-08-15", "2015-09-15"/)
 ; Dates2Plt = (/"2015-06-15", "2015-07-15", "2015-08-15"/)
  Dates2Plt = (/"2015-07-15"/)
  ndates = dimsizes(Dates2Plt) 

;************************************************
; read in netCDF file
;************************************************

  if(model .eq. "hycice")then
   runname = "CICE008"
   ;runname = "CICE003"
     rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"+runname+"/history/"
   nemsdir = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/cice_data/mx024/"
  ; load the grid file
  gf =addfile(nemsdir+"cice_grid_024.nc","r")

  icefilelist = rtsrc+"iceh_24h."+Dates2Plt+".nc"
     icefiles = addfiles(icefilelist,"r")
  ;print(icefiles)

   icelonname = "tlon"
   icelatname = "tlat"
      rad2deg = 180.d0/acos(-1.0d0)
      rfactor = rad2deg
  end if

;************************************************
; load an ice field
;************************************************

   yb = 10.e3
   ;quicker for debuggin
   ;xb = fspan(0,1,11)
   xb = fspan(0,1,101)
   ;print(xb)

   jmin =  800-1
   jmax = 1099-1
   albo = 6.00

   aname = "albsni_h"
   ;aname = "apond_h"
   iname = "aice_h"

  plottitle = runname
   wkstitle = "test"

  ; panels
  npanels = ndates
 ; for panels
 ;   ncols = 2
 ;   nrows = 1+npanels/ncols
    ncols = ndates
    nrows = 1


;************************************************
;
;************************************************

  albvar=icefiles[:]->$aname$(:,:,:)
  albvar@lon2d=gf->$icelonname$*rfactor
  albvar@lat2d=gf->$icelatname$*rfactor
  labelstring = albvar@long_name
  albvar@units=""
  albvar@long_name=""
  ;print(labelstring)

  icevar=icefiles[:]->$iname$(:,:,:)
  icevar@lon2d=gf->$icelonname$*rfactor
  icevar@lat2d=gf->$icelatname$*rfactor
  icevar@units=""

  ;albvar = albedo
  ;albedo = icevar*albvar + (1.0 - icevar)*albo
  albedo = albvar
  albedo = mask(albvar, (icevar .lt. 0.05), 0.0)
  ;albedo = albvar
  albedo = albedo/100.0

;************************************************
; create plot
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks   = gsn_open_wks (wkstype,wkstitle)
  gsn_define_colormap(wks,"MPL_rainbow")

  ; use to help position text
  ;drawNDCGrid(wks)

    plot = new(npanels,graphic)

  res               = True

  res@gsnDraw       = False ; don't draw or advance the frame
  res@gsnFrame      = False 
  ;res@gsEdgesOn     = False

  res@trYMaxF = yb

  res@gsnHistogramClassIntervals = xb
  res@tmXBLabelStride =  10
  res@tiXAxisString = " "

  ;res@tmXBMinorOn = True
;************************************************
; panel resources
;************************************************

  resP               = True                ; modify the panel plot
  resP@gsnMaximize   = True
  ;resP@txString      = runname+": "+labelstring    
  resP@txFontHeightF = .012
  ;resP@gsnPanelFigureStrings= Dates2Plt
  ;resP@amJust   = "TopLeft"
  ;resP@amJust   = "TopRight"

  ;Add some extra space between plots since they are too close together
  resP@gsnPanelXWhiteSpacePercent = 3
  resP@gsnPanelYWhiteSpacePercent = 3
  ;Leave some room for the leftmost and rightmost tickmark labels.
  ;resP@gsnPanelLeft               = 0.1
  ;resP@gsnPanelRight              = 0.9


;************************************************
;
;************************************************

     ii = 0
  do ii = 0,npanels-1
   res@tiMainString = Dates2Plt(ii)
   plot(ii) = gsn_histogram(wks,ndtooned(albedo(ii,jmin:jmax,:)),res)       ; create just axis to draw on
  end do

  gsn_panel(wks,plot,(/nrows,ncols/),resP)

exit
end
