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
              ,13-1 \
              /)

;************************************************
; Read in data
;************************************************
 
 rtsrc1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
 rtsrc2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"

 RunNum = (/  "003"/)
 RunDir = (/ rtsrc2/)

 AllFiles = RunDirs + "CICE" + RunNums + "/cice_stats.nc"
  RunLabs =  "CICE" + RunNums

 IceFile = addfiles(RunDir+"cice"+RunNum+"_stats.nc","r")

 varnames = (/"meltt", "meltb", "meltl", "frazil", "congel"/) 

  var = Fall[:]->$varname$
 time = Fall[0]->time
 mval = var@_FillValue
 ;printVarSummary(var)
 ;printVarSummary(time)
 labelstring = var@long_name+" ("+var@units+")"
 ;print(labelstring) 
  nregs = dimsizes(Regs2Plt)
   nvars = dimsizes(varnames)
 colors = (/"red", "green", "blue", "purple"/)

  data_all = new((/nvars,nregs,dimsizes(var&time)/),float)
 do ii = 0,nregs-1
  data_all(:,ii,:) =  IceFile->$varnames$(:,:,Regs2Plt(ii))
 end do

 ;printVarSummary(data_all)

;************************************************
;
;************************************************

  ntot = nvars
 print("ntot = "+ntot)

 legendlabs = new((/ntot/),"string")
 legendcols = new((/ntot/),"string")
 legendthik = new((/ntot/),"float")
 legenddash = new((/ntot/),"integer")
 do ii = 0,ndata-1
  legendlabs(ii) = RunLabs(ii)
  legendcols(ii) =  colors(ii)
  legendthik(ii) =  2.0
  legenddash(ii) =  0
  ;print(ii+" "+RunLabs(ii))
 end do

 ;print(legendlabs)
 ;print(legendcols)

;************************************************
;
;************************************************

  wkstype="X11"
  wkstitle=varname+"_regions"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file
  
  ;drawNDCGrid(wks)

  plot = new(  nregs,graphic)
 oplot = new(ndata-1,graphic)

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
 res@xyLineThicknessF  = 2.0
 res@tiYAxisString     = labelstring

 res@gsnDraw  = False
 res@gsnFrame = False

; 	default Format = "0@*+^sg"
 if(varname .eq. "exmod" .or. varname .eq. "armod")then
 res@tmYLFormat = "0*+^e"	; use "e" symbol, don't force 0's (see documentation)
 end if
 res@tmYLMinorOn = False	; turn the minor tick marks off
 res@tmXBPrecision = 6		; set the precision to 6 significant digits

 res@trXMaxF = max(time)
 res@trXMinF = min(time)
 if(varname .ne. "tsfc")then
  res@trYMinF = 0.0
 end if
 if(varname .eq. "arpond" .or. varname .eq. "arpond_ai")then
  res@trYMaxF = 1.0
  res@trYMinF = 0.0
 end if
 if(varname .eq. "meltt")then
  res@trYMaxF = 6.0
 end if

 restick = True
 restick@ttmFormat = "%D%C"
 restick@ttmValues = Dates2Label
 time_axis_labels(time,res,restick)

;***********************************************
; legend resources
;***********************************************

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.1                   ; width of legend (NDC)
  lgres@vpHeightF            = 0.12                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = ntot
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  lgres@lgLineThicknesses    = legendthik
  lgres@lgLineLabelStrings   = legendlabs
  lgres@lgLabelFontHeightF   = 0.20

  ;lgres@lgMonoLineLabelFontColor = True               ; one label color

;************************************************
;  for simple_legend
;************************************************

  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          =  10.      ; from the bottom
  gres@XPosPercent          =  5.
  gres@ItemSpacePercent     =  10.
  lineres@LineLengthPercent =  5.      ; expressed as %, 0->100, length of line

  textres@lgLabels           = legendlabs
  textres@lgLabelFontHeights = 0.020

  lineres@lgLineColors      = legendcols
  lineres@lgLineThicknesses = legendthik      ; line thicknesses

;************************************************
; Make the plot
;************************************************

 do ii = 0,nregs-1
                nd = 0
               iii = Regs2Plt(ii)
  res@tiMainString = RegNames(iii)       ; add title
  res@xyLineColor  = colors(nd)
 
  ;if(varname .ne. "arpond" .and. varname .ne. "arpond_ai")then
  ; mmax = max(data_all(:,ii,:))
   ;omax = max( obs_all(:,ii,:))
   ;res@trYMaxF = where(mmax .gt. omax, mmax, omax)
  ;end if
  ;if(varname .eq. "himod")then
  ; res@trYMaxF = 3.5
  ;end if

    plot(ii) = gsn_csm_xy (wks,var&time,data_all( nd,ii,:),res) ; create plot
  if(ii .eq. 0)then
  ;  plot(ii) = simple_legend(wks,plot(ii),gres,lineres,textres)
  end if

  do ndd = 1,ndata-1
   res@xyLineColor  = colors(ndd)
   oplot(ndd-1) = gsn_csm_xy (wks,var&time,data_all(ndd,ii,:),res) ; create plot
  end do

  xx = 0.60
  yy = 0.10
  gsn_legend_ndc(wks,ntot,legendlabs,xx,yy,lgres)
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

;************************************************
;
;************************************************

  ;xx = 0.80
  ;yy = 0.10
  ;gsn_legend_ndc(wks,ntot,legendlabs,xx,yy,lgres)

  ;gsn_panel(wks,plot,(/nrows,ncols/),resP)           ; now draw as one plot
  ;simple_legend_ndc(wks, genres, lineres, textres)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
