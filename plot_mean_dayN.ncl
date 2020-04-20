;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "bmfilelist.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  ; theia
  ;RT1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
  ;RT2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
  ;RT3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
  ;RT4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

  bmname = "BM2"
   bmsrc = RT3+bmname+"_ice/"

   freturn = bmfilelist(bmsrc)
    nvalid = freturn[0]
  datelist = new((/nvalid/),typeof(freturn[1]))
  timelist = new((/nvalid/),typeof(freturn[2]))
  datelist = freturn[1]
  timelist = freturn[2]

   ;print(datelist)
   ;print(timelist)
 
  filelist = new((/nvalid/),typeof(datelist))
  ;grab integration day iday (in hours) from 
  ;runs at month N
  format = "%Y%N%D%H"
    iday = 35
    imon = "08"
     iii = 0
   do ii = 0,nvalid-1
    cmon = str_get_cols(datelist(ii),4,5)
    print(cmon +"  "+imon)
    if(cmon .eq. imon)then
     ;print(datelist(ii)+"  "+cmon)
     itime = timelist(ii)            ; copy attributes
     itime = itime + (iday-1)*24
   
     idate = cd_string(itime,format) ; date of integration day
     idate = str_get_cols(idate,0,7) ; without the hours
     ifile = bmsrc+datelist(ii)+"/ice"+idate+".01."+datelist(ii)+"00.nc"

     filelist(iii) = ifile
               iii = iii + 1
     ;print(datelist(ii)+"   "+itime+"  "+idate+"  "+ifile)
    end if
   end do 
   nfiles = iii
    hemi = "NH"
  minlat = 66.0

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

    varname = "hi_h"
   levs = (/0.0,4.0,0.2/)

   plottitle = bmname+": mean "+varname+" after "+iday+" days, initial month "+imon+", all runs" 

;************************************************
; read in netCDF file
;************************************************

    ; basic check
    fvalid = isfilepresent(filelist(0))
if(.not.fvalid)then
  print("can't find first file ")
  print("check file names or directories")
else
    ; use as grid file to retrieve 2d latlon later
      gf = addfile(filelist(0),"r")
     var = gf->$tlatname$
    dims = dimsizes(var)
      ny = dims(0)
      nx = dims(1)
    delete(var)
    ;print(nx+"  "+ny)
     var = new((/nfiles,ny,nx/),"float")

     do ii = 0,nfiles-1
         f = addfile(filelist(ii),"r")
       var(ii,:,:) = f->$varname$(0,:,:)
      print("variable added from "+filelist(ii))
     end do
     ;printVarSummary(var)
    
           avar = dim_avg_n_Wrap(var,0)
     avar@lon2d = gf->$tlonname$
     avar@lat2d = gf->$tlatname$

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=  60.00
  lon2=-120.00
  lat1 = 60.00
  lat2 = 60.00

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wkstitle="mean_hi"+"_"+imon
  wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window

  ;gsn_define_colormap(wks,"MPL_Blues")
  ;gsn_reverse_colormap(wks)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn   = False

  res@gsnStringFontHeightF = 0.012

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  ; Near Yenisei
  ;res@mpMinLatF            =  70      ; range to zoom in on
  ;res@mpMaxLatF            =  80.
  ;res@mpMinLonF            =  60.
  ;res@mpMaxLonF            =  90.

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

  ; res@cnLevelSelectionMode        = "ExplicitLevels"
  ; res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
  ; res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  res@cnFillPalette        = "WhBlGrYeRe"              ; choose colormap
  res@cnMissingValFillColor    = "gray70" ; set color for missing areas
  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter

  ;res@tiMainString = dirname+" "+cday
  res@tiMainString = plottitle
  ;res@tiMainFontHeightF = .01

  ;res@gsnCenterStringOrthogonalPosF = .15	    ; raise the CenterString slightly
  ;res@gsnStringFontHeightF = 0.01
  ;res@gsnCenterString = plottitle

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
;
;************************************************

  plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  ;plot = gsn_csm_contour_map(wks,icevar,res)    ; create the plot
  dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;pum= gsn_add_polymarker(wks,plot,center_xlon,center_xlat,mkres)

  draw(plot)
  frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
   imcmd = "convert -bordercolor white -border 0x10 "+wkstitle+".jpg "+wkstitle+".jpg"
   ;print(imcmd)
   system(imcmd)
  end if

end if
exit
end
