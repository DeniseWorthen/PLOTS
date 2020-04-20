; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

begin
 
 Dates2Label = (/(/2015, 4, 15,0,0,0/) \
                ,(/2015, 5, 15,0,0,0/) \
                ,(/2015, 6, 15,0,0,0/) \
                ,(/2015, 7, 15,0,0,0/) \
                ,(/2015, 8, 15,0,0,0/) \
                ,(/2015, 9, 15,0,0,0/) \
                ,(/2015,10, 15,0,0,0/) \
                ,(/2015,11, 15,0,0,0/) \
                ,(/2015,12, 15,0,0,0/) \
                /)

 RegNames = (/"Chukchi Sea" \         ;1              
             ,"Beaufort Sea" \        ;2    
             ,"Baffin Bay" \          ;3       
             ,"East Siberian Sea" \   ;4
             ,"NW Passages" \         ;5
             ,"Central Arctic" \      ;6
             ,"Barents Sea" \         ;7
             ,"Greenland Sea" \       ;8
             ,"Kara Sea" \            ;9
             ,"Laptev Sea" \          ;10
             ,"SHEBA" \               ;11
             ,"North of 50N" \        ;12
             ,"South of 50S" \        ;13
             /)

 ; region number w/ ncl indexing
 Regs2Plt = (/  1-1 \
              , 2-1 \
              , 4-1 \
              , 6-1 \
              , 7-1 \
              , 9-1 \
              ,10-1 \
              ,12-1 \
 ;             ,13-1 \
              /)

;************************************************
; Read in data
;************************************************
 
  rtsrc1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  rtsrc2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"

;  RunNum = (/ "008"/)
; RunDesc = (/ " MU71, 50.0e-3" /)
  RunNum = (/ "009"/)
 RunDesc = (/ " Bubbly, 50.0e-3" /)

  RunDir = (/ rtsrc2/)
  RunLab =  "CICE" + RunNum

 print(RunDir+RunLab+"/cice_stats.nc")

 IceFile = addfile(RunDir+RunLab+"/cice_stats.nc","r")

 varnames = (/"congel", "frazil", "meltl", "meltb", "meltt"/) 
   colors = (/"purple",   "blue", "green",   "red", "black"/)

   time = IceFile->time
  nregs = dimsizes(Regs2Plt)
   nvars = dimsizes(varnames)

  vname = varnames(0)
 icevar = IceFile->$vname$
   mval = icevar@_FillValue

 legendlabs = new((/nvars/),"string")
 legendcols = new((/nvars/),"string")
 legendthik = new((/nvars/),"float")
 legenddash = new((/nvars/),"integer")

  data_all = new((/nvars,nregs,dimsizes(icevar&time)/),float)
 do jj = 0,nvars-1
            vname = varnames(jj)
           icevar = IceFile->$vname$
   legendlabs(jj) = icevar@long_name
   legendcols(jj) = colors(jj)
   legendthik(jj) =  2.0
   legenddash(jj) =  0
  do ii = 0,nregs-1
    data_all(jj,ii,:) =  icevar(:,Regs2Plt(ii))
  end do
 end do

;************************************************
;
;************************************************

  wkstype="X11"
  wkstitle="cice"+RunNum+"_igm"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file

 ; drawNDCGrid(wks)

  plot = new(  nregs,graphic)
 oplot = new(nvars-1,graphic)

 npanels = nregs
   ncols = 2
   nrows = 1+npanels/ncols
 print(  nregs+" base plots ")
 print("regions = "+RegNames)

;************************************************
;---Set plotting parameters
;************************************************

 res                   = True                      ; plot mods desired
 res@vpWidthF          = 0.70
 res@vpHeightF         = 0.30

 res@gsnDraw  = False
 res@gsnFrame = False

 res@trYMaxF =  6.5
 res@tiYAxisString = icevar@units
 res@xyLineThicknesses = legendthik
 
 restick = True
 restick@ttmFormat = "%D%C"
 restick@ttmValues = Dates2Label
 time_axis_labels(time,res,restick)

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.20                   ; width of legend (NDC)
  lgres@vpHeightF            = 0.12                  ; height of legend (NDC)

  lgres@lgAutoManage         = False
  ;lgres@lgAutoManage         = True

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = nvars
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  lgres@lgLineThicknesses    = legendthik
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgLabelFontHeightF   = 0.15

;************************************************
; Make the plot
;************************************************

 do ii = 0,nregs-1
               iii = Regs2Plt(ii)
  res@tiMainString = RegNames(iii)       ; add title
  ; make base plot (1st variable) first
                 jj = 0
   res@xyLineColor  = colors(jj)
   plot(ii) = gsn_csm_xy (wks,icevar&time,data_all(jj,ii,:),res) ; create plot
   ; loop over other varialbes
   do jj = 1,nvars-1
    res@xyLineColor  = colors(jj)
    oplot(jj-1) = gsn_csm_xy (wks,icevar&time,data_all(jj,ii,:),res) ; create plot
    overlay(plot(ii),oplot(jj-1))
   end do
 end do

;************************************************
; add legend and title
;************************************************

  xx = 0.60
  yy = 0.05
  gsn_legend_ndc(wks,nvars,legendlabs,xx,yy,lgres)

  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.015                     ; font smaller. default big
  txres@txJust        = "CenterLeft"

; page coordinates are normalized. go from 0->1 not 0->8" etc.
  xx = 0.60
  yy = 0.15
   gsn_text_ndc(wks,"CICE"+RunNum+RunDesc,xx,yy,txres)

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  gsn_panel(wks,plot,(/nrows,ncols/),resP)           ; now draw as one plot
  ;frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
