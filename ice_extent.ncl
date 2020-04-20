load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin

 batch = "no"
 ;batch = "yes"
 rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchTest3/"
 ;rtsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchCFSv2/"

 if(batch .eq. "no")then
    Year = 2017
  Region = 19-1
 end if
 
 Dates2Label = (/(/Year,  1, 15,0,0,0/) \
                ,(/Year,  2, 15,0,0,0/) \
                ,(/Year,  3, 15,0,0,0/) \
                ,(/Year,  4, 15,0,0,0/) \
                ,(/Year,  5, 15,0,0,0/) \
                ,(/Year,  6, 15,0,0,0/) \
                ,(/Year,  7, 15,0,0,0/) \
                ,(/Year,  8, 15,0,0,0/) \
                ,(/Year,  9, 15,0,0,0/) \
                ,(/Year, 10, 15,0,0,0/) \
                ,(/Year, 11, 15,0,0,0/) \
                ,(/Year, 12, 15,0,0,0/) \
                ,(/Year+1,1, 15,0,0,0/) \
                ,(/Year+1,2, 15,0,0,0/) \
                /)

   RegNames = (/ "Gulf of Alaska"\   ; 01
                ,"Bering Sea    "\   ; 02
                ,"Chukchi Sea   "\   ; 03
                ,"Beaufort Sea  "\   ; 04
                ,"Baffin Bay    "\   ; 05
                ,"Lincoln Sea   "\   ; 06
                ,"White Sea     "\   ; 07
                ,"EastSib Sea   "\   ; 08
                ,"NW Passages   "\   ; 09
                ,"Central Arctic"\   ; 10
                ,"Barents Sea   "\   ; 11
                ,"Greenland Sea "\   ; 12
                ,"Kara Sea      "\   ; 13
                ,"Laptev Sea    "\   ; 14
                ,"BKLE Seas     "\   ; 15
                ,"CB   Seas     "\   ; 16
                ,"BKLECB Seas   "\   ; 17
                ,"SHEBA         "\   ; 18
                ,"Nocn >50N     "\   ; 19
                ,"Socn <50S     "\   ; 20
                /)

;************************************************
; use the 'all stats' file to set min,max for this
; region
;************************************************

   AllFile=rtsrc+"allstats.nc"
   AllF = addfile(AllFile,"r")
   exobs = AllF->exobs(:,Region)/1.0e6
   exmod = AllF->exmod(:,:,Region)/1.0e6
   
    mmin = min(exmod)
    mmax = max(exmod)
    omin = min(exobs)
    omax = max(exobs)
    print(mmin+" "+mmax+" "+omin+" "+omax)

    if(omin .lt. mmin)then
     mmin = omin
    end if
    if(omax .gt. mmax)then
     mmax = omax
    end if
    print(mmin+" "+mmax)

    delete(exobs)
    delete(exmod)

;************************************************
;
;************************************************

  YrFile = rtsrc + "stats_"+Year+".nc"
  File = addfile(YrFile,"r")
  rnum=Region+1

  wkstitle="IceExtent"+Year+"_region"+rnum
;************************************************
;
;************************************************
  ; timestep to 'mark'
   lstep = 5-1

   exobs = File->exobs/1.0e6
   exmod = File->exmod/1.0e6
    time = File->time

   dims = dimsizes(exmod)
  ntime = dims(0)
   nexp = dims(1)
   nreg = dims(2)
  print("ntime "+ntime+" nexp "+nexp+" nreg "+nreg)

    data = new((/nexp+1,ntime/),float)
   mdata = new((/nexp+1,ntime/),float)
   do ne = 0,nexp-1
    data(ne,:) = exmod(:,ne,Region)
   end do
   ; add the obs
    data(nexp,:) = exobs(:,Region)
  
   ;mdata = data
   ;mdata(:,0:lstep-1) = exobs@_FillValue
   ;mdata(:,lstep+1: ) = exobs@_FillValue
   ;printVarSummary(mdata)

    ;mmax = max(data)
    ;print(exobs(:,Region))

;************************************************
;
;************************************************
  
  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
   ;wkstype="X11"
  end if
  wks =  gsn_open_wks(wkstype, wkstitle)

  ;plot = new(1,graphic)
   ;dum1 = new(nexp,graphic)
   ;dum2 = new(nexp,graphic)

  res = True
  res@vpWidthF          = 0.80
  res@vpHeightF         = 0.30

  res@gsnDraw  = False
  res@gsnFrame = False
  res@gsnPaperOrientation = "auto"
  res@gsnMaximize = True
  res@xyXStyle  = "Time"

;       default Format = "0@*+^sg"
 ;res@tmYLFormat = "0*+^e"       ; use "e" symbol, don't force 0's (see documentation)
 ;res@tmYLMinorOn = False        ; turn the minor tick marks off
 ; res@tmXBPrecision = 2          ; set the precision to 6 significant digits

  res@tiXAxisString = "Date"
  res@tiYAxisString = "Extent (Millions of square kilometers)"
  res@tiYAxisFontHeightF = 0.012
  res@tiXAxisFontHeightF = 0.012

  ; res@trYMinF =  0.0
  ;res@trYMaxF =  3.5
  ;res@trYMinF =  2.0
  ;res@trYMaxF = 15.5
  ;res@trYMaxF = 22.5
  res@trYMinF = 0.95*mmin
  res@trYMaxF = 1.05*mmax
  res@trXMaxF   = max(time)+5*24
  res@trXMinF   = min(time)-5*24

  res@tiMainString      = Year
  res@tiMainFontHeightF = 0.015
;************************************************
;
;************************************************

  restick = True
  restick@ttmFormat = "%N%D"
  res@tmXBLabelFontHeightF = 0.015 ; resize tick labels
  restick@ttmValues = Dates2Label
  time_axis_labels(time,res,restick)

;************************************************
;
;************************************************

 mres                = True                      ; plot mods desired
 ;mres@gsMarkerIndex  = 16                        ; circle
 mres@xyMarkerSizeF  = 0.05

;************************************************
;
;************************************************

 ; obs
  res@xyLineThicknessF  = 5.0
  res@xyLineColor       = "black"
  plot = gsn_csm_xy (wks,time,data(nexp,:),res) ; create plot
  ;plot = gsn_csm_xy (wks,time,data,res) ; create plot

  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "red"
  res@xyMarkLineMode    = "Lines"
  res@xyDashPattern     = 0
  oplot1 = gsn_csm_xy (wks,time, data(0:nexp-1:2,:), res) ; create plot
  ;  dum1 = gsn_csm_xy (wks,time,mdata(0:nexp-1:2,:),mres)
  ;overlay(oplot1,dum1)
  overlay(plot,oplot1)

  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "blue"
 mres@gsMarkerColor     = "blue"
  oplot2 = gsn_csm_xy (wks,time,data(1:nexp-1:2,:),res) ; create plot
  overlay(plot,oplot2)
    dum2 = gsn_csm_xy(wks,time,mdata(1:nexp-1:2,:),mres)
  overlay(plot,dum2)
    ;dum2 = gsn_add_polymarker(wks,plot,time(lstep),data(1:nexp-1:2,lstep),mres)

 ;mres@gsMarkerColor     = "red"
 ; do ii=0,nexp-1,2
 ;  dum1(ii) = gsn_add_polymarker(wks,oplot1,time(lstep),data(ii,lstep),mres)
 ; end do
 ;mres@gsMarkerColor     = "blue"
 ; do ii=1,nexp-1,2
 ;  dum2(ii) = gsn_add_polymarker(wks,oplot2,time(lstep),data(ii,lstep),mres)
 ; end do

  ;do ii=0,nexp-1,2
  ; dum1(ii) = gsn_add_polymarker(wks,plot,time(lstep),data(ii,lstep),mres)
  ;end do
  ;do ii=1,nexp-1,2
  ; dum2(ii) = gsn_add_polymarker(wks,plot,time(lstep),data(ii,lstep),mres)
  ;end do

  draw(plot)
  frame(wks)

  if(batch .eq. "yes")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

exit
end
