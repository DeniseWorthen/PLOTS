;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/glade/scratch/worthen/nocold/"

  runnames = (/"ori cold start", "fixed cold start", "no cold start (ocean lag)"/)
       rts = (/"cmeps_cold2", "cmeps_cold2_fix", "cmeps_nocold"/)

;************************************************
;  Ocn initial condition
;************************************************
  
      ofile = addfile(RT1+rts(0)+"/INPUT/MOM.res.nc","r")
      tinit = ofile->Temp(0,0,:,:)
      delete(tinit&lonh)
      delete(tinit&lath)

;************************************************
; Ice inst sst_h at hour6
;************************************************

  cyear = "2012"
   cmon = "01"
  ; cday = "01"
  ;csecs = "21600"
   cday = "03"
  csecs = "00000"
  cdate = cyear+"-"+cmon+"-"+cday+"-"+csecs

  icefiles = addfiles(RT1+rts+"/history/iceh_inst."+cdate+".nc","r")
  ;print(icefiles)
  ;ListSetType(icefiles,"cat")
  levs = (/-0.5,0.5,0.05/)
  
  ;default
  cmap="cmp_flux"

;************************************************
; define the map
;************************************************

  wkstitle = "sst_diffs_48h"
  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  plot = new(3,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@vpWidthF  = 0.8
  res@vpHeightF = 0.4

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@cnInfoLabelOn = False

  res@gsnStringFontHeightF = 0.01
  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@lbLabelBarOn      = False

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = levs(2)                      ; set the interval between contours
  res@cnFillPalette   = cmap

  res@tiMainFontHeightF = .010
  ;res@tiMainString = plottitle

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  res@gsnCenterStringFontHeightF      = 0.020
  res@gsnCenterString                 = name
  ;res@gsnCenterStringOrthogonalPosF   = 0.12

   splot = gsn_csm_contour(wks,pltvar,res)    ; create the plot
  return(splot)
end

;************************************************
;
;************************************************

;     cold = icefiles[0]->sst_h(0,:,:) - tinit(:,:)
;      fix = icefiles[1]->sst_h(0,:,:) - tinit(:,:)
;   nocold = icefiles[2]->sst_h(0,:,:) - tinit(:,:)

;  print(cold(400,400))
;  print(fix(400,400))
;  print(nocold(400,400))

;  ii = 0
;  plot(ii) = subplot(ii,runnames(ii),cold,levs,cmap)
;  ii = 1
;  plot(ii) = subplot(ii,runnames(ii),fix,levs,cmap)
;  ii = 2
;  plot(ii) = subplot(ii,runnames(ii),nocold,levs,cmap)

;************************************************
;
;************************************************

   nocold = icefiles[2]->sst_h(0,:,:) -  icefiles[0]->sst_h(0,:,:)

  print(cold(400,400))
  print(fix(400,400))
  print(nocold(400,400))

  ii = 0
  plotname = runnames(2)+"-"+runnames(0)
  plot(ii) = subplot(ii,plotname,nocold,levs,cmap)

; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelLabelBar      = True                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.020           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = cdate

;************************************************
; make the panel
;************************************************

  ;gsn_panel(wks,plot,(/3,1/),resP)
  gsn_panel(wks,plot,(/1,1/),resP)

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
