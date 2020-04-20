load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin

 batch = "no"
 ;batch = "yes"
 bench = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchTest3/"
 cfsv2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchCFSv2/"

 if(batch .eq. "no")then
    Year = 2013
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

   AllFile1=bench+"allstats.nc"
   AllFile2=cfsv2+"allstats.nc"
   AllF = addfile(AllFile1,"r")
   exobs = AllF->exobs(:,Region)/1.0e6
   exmod = AllF->exmod(:,:,Region)/1.0e6
   
    mmin1 = min(exmod)
    mmax1 = max(exmod)
    omin1 = min(exobs)
    omax1 = max(exobs)

    if(omin1 .lt. mmin1)then
     mmin1 = omin
    end if
    if(omax1 .gt. mmax1)then
     mmax1 = omax
    end if
    print("bench min,max = "+mmin1+" "+mmax1)

   AllF = addfile(AllFile2,"r")
   exobs = AllF->exobs(:,Region)/1.0e6
   exmod = AllF->exmod(:,:,Region)/1.0e6

    mmin2 = min(exmod)
    mmax2 = max(exmod)
    print("cfsv2 min,max = "+mmin2+" "+mmax2)

    if(mmin2 .lt. mmin1)then
     mmin1 = mmin2
    end if
    if(mmax2 .gt. mmax1)then
     mmax1 = mmax2
    end if
    print(mmin1+" "+mmax1)

    delete(exobs)
    delete(exmod)

;************************************************
;
;************************************************

  YrFile1 = bench + "stats_"+Year+".nc"
  File1 = addfile(YrFile1,"r")
  YrFile2 = cfsv2 + "stats_"+Year+".nc"
  File2 = addfile(YrFile2,"r")
  rnum=Region+1

  wkstitle="IceExtent"+Year+"_region"+rnum
;************************************************
;
;************************************************
  ; timestep to 'mark'
   lstep = 5-1

   exobs = File1->exobs/1.0e6
   exmod = File1->exmod/1.0e6
    time = File1->time

   dims = dimsizes(exmod)
  ntime = dims(0)
   nexp = dims(1)
   nreg = dims(2)
  print("ntime "+ntime+" nexp "+nexp+" nreg "+nreg)

    benchdata = new((/nexp+1,ntime/),float)
   do ne = 0,nexp-1
    benchdata(ne,:) = exmod(:,ne,Region)
   end do
   ; add the obs
    benchdata(nexp,:) = exobs(:,Region)

    mbench = new((/nexp+1,ntime/),float)
    mbench = exobs@_FillValue
   do ne = 0,nexp-1
    mbench(ne,lstep) = exmod(lstep,ne,Region)
   end do
   ; add the obs
   ; mbench(nexp,lstep) = exobs(lstep,Region)
   print(mbench(:,lstep))

    delete(exobs)
    delete(exmod)

   exobs = File2->exobs/1.0e6
   exmod = File2->exmod/1.0e6

    cfsv2data = new((/nexp+1,ntime/),float)
   do ne = 0,nexp-1
    cfsv2data(ne,:) = exmod(:,ne,Region)
   end do
   ; add the obs
    cfsv2data(nexp,:) = exobs(:,Region)

    delete(exobs)
    delete(exmod)

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
  res@trYMinF = 0.98*mmin1
  res@trYMaxF = 1.02*mmax1
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

  res@xyMarkLineMode    = "Lines"
 ; obs
  res@xyLineThicknessF  = 5.0
  res@xyLineColor       = "black"
  plot = gsn_csm_xy (wks,time,benchdata(nexp,:),res) ; create plot

  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "red"
  res@xyDashPattern     = 0
  res@xyLineOpacityF    = 1.0
  oplot1 = gsn_csm_xy (wks,time, benchdata(0:nexp-1:2,:), res) ; create plot
  res@xyMarkLineModes   = "Markers"
  overlay(plot,oplot1)
  mplot1 = gsn_csm_xy (wks,time, mbench(0:nexp-1,2,:),res)
  overlay(plot,mplot1)
  res@xyLineColor       = "red"
  res@xyDashPattern     = 2
  res@xyLineOpacityF    = 0.5
  oplot2 = gsn_csm_xy (wks,time, cfsv2data(0:nexp-1:2,:), res) ; create plot
  overlay(plot,oplot2)

  res@xyLineThicknessF  = 3.0
  res@xyLineColor       = "blue"
  res@xyDashPattern     = 0
  res@xyLineOpacityF    = 1.0
  oplot3 = gsn_csm_xy (wks,time, benchdata(1:nexp-1:2,:),res) ; create plot
  overlay(plot,oplot3)
  res@xyLineColor       = "blue"
  res@xyDashPattern     = 2
  res@xyLineOpacityF    = 0.5
  oplot4 = gsn_csm_xy (wks,time, cfsv2data(1:nexp-1:2,:), res) ; create plot
  overlay(plot,oplot4)

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
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x20 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)

  end if

exit
end
