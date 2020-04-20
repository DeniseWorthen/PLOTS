; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

 plotlabs = (/"Hera-NEMS", "Hera-CMEPS"/)
     runs = (/"nems", "cmeps"/)

;************************************************
; Read in data
;************************************************
 
 allfiles = RT4+runs+".20120101.nc" 
    files = addfiles(allfiles,"r")
   ListSetType(files,"join")

   sst = files[:]->sst
   dims = dimsizes(sst)
   print(dims)
   nruns = dims(0)
   ntime = dims(1)
    nlat = dims(2)
    nlon = dims(3)

   nregs = 2
   nvals = nruns*nregs

   lat = files[0]->geolat
   masklat = conform_dims(dimsizes(sst),lat,(/2,3/))
   printVarSummary(masklat)
   hsst = sst ; copy metadata
   hsst = where(abs(masklat) .le. 50.0, sst, sst@_FillValue)
   ;printVarSummary(sst)
   ;printVarSummary(hsst)
   ;print(sst(0,0:10,220-1,220-1)+" "+sst(1,0:10,220-1,220-1))

   gdata = new((/nruns*nregs,ntime,nlat,nlon/),float)
   ;printVarSummary(gdata)
   ; global mean SSTs
   gdata(0,:,:,:) =  sst(0,:,:,:)
   gdata(1,:,:,:) =  sst(1,:,:,:)
   ; hemi mean SSTs
   gdata(2,:,:,:) = hsst(0,:,:,:)
   gdata(3,:,:,:) = hsst(1,:,:,:)
   ;print(gdata(0,0:10,220-1,220-1)+" "+gdata(1,0:10,220-1,220-1))
   print(gdata(2,10,:,220-1)+" "+gdata(3,10,:,220-1))

   time = files[0]->time
 colors = (/"red", "blue", "red", "blue"/)
 dashes = (/  0.0,   1.0 ,   0.0,   1.0 /)

  data_all = new((/nvals,dimsizes(sst&time)/),float)
  data_all = dim_avg_n_Wrap(gdata, (/2,3/))
  ;printVarSummary(data_all)

  print(data_all(0,0:10)+" "+data_all(1,0:10)+" "+data_all(2,0:10)+" "+data_all(3,0:10))
;************************************************
;
;************************************************

  wkstype="X11"
  wkstitle="test"
  wkstype@wkWidth=1200
  wkstype@wkHeight=1200
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file

  ;drawNDCGrid(wks)

  plot = new(  nregs,graphic)

;************************************************
;---Set plotting parameters
;************************************************

 res                   = True                      ; plot mods desired
 res@vpWidthF          = 0.70
 res@vpHeightF         = 0.30
 res@xyLineThicknessF  = 2.0
 ;res@tiYAxisString     = labelstring

 res@gsnDraw  = False
 res@gsnFrame = False

;       default Format = "0@*+^sg"
 res@tmYLMinorOn = False        ; turn the minor tick marks off
 res@tmXBPrecision = 6          ; set the precision to 6 significant digits

 res@trXMaxF = max(time)
 res@trXMinF = min(time)

 restick = True
 restick@ttmFormat = "%D%C"
 ;restick@ttmValues = Dates2Label
 time_axis_labels(time,res,restick)

 ii = 0
 plot(ii) = gsn_csm_xy (wks,sst&time,data_all(0:1,:),res) ; create plot
 ii = 1
 plot(ii) = gsn_csm_xy (wks,sst&time,data_all(2:3,:),res) ; create plot

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  gsn_panel(wks,plot,(/2,2/),resP)           ; now draw as one plot
end
