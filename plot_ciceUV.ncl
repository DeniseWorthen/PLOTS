;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

  load "unstaggerCICE5.ncl"
  load "levscmapCICE.ncl"

;************************************************
;
;************************************************

   hemi="NH"
   batch="no"

        mean="no"
  plotstress="no"
  print("mean = "+mean+" stresses = "+plotstress)

  ;minlat = 89.0
  minlat = 76.0
  ;minlat = 70.0
  ;minlat = 85.0
  ;minlat = 66.0

   ;vmag = 0.20
   ;vthn = 0.012
   ;vmag = 0.500
   ;vthn = 0.012
   vmag = 0.20
   vthn = 0.020

  usegrid = "T"
  ;usegrid = "U"

   rad2deg=180.d0/acos(-1.0d0)
begin
;************************************************
; read in netCDF file
;************************************************

   rt1 = "/scratch3/NCEPDEV/stmp1/Denise.Worthen/"
   rt2 = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/"
   rt3 = "/scratch4/NCEPDEV/stmp3/Denise.Worthen/"
   rt4 = "/scratch4/NCEPDEV/stmp4/Denise.Worthen/"

   ;runtyp="emc"
   ;runtyp="moa"
   ;runtyp="fmc_unify_20d"
   runtyp="cmeps"

   ;runname = "FV3M6C5 prepforbench"
   ;rtsrc =  rt2+"frzmlt_35d_july_bubbly_dp1/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/"
   ;rtsrc =  rt4+"rtgen.54883/tmp/cpld_datm_mom6_cice_5d/"
   ;rtsrc =  rt4+runtyp+"_1d_uvatm_only/tmp/cpld_datm_mom6_cice_5d/"
   ;rtsrc =  rt4+runtyp+"/tmp/cpld_fv3_384_mom6_cice_2d_atm_flux/"
   rtsrc =  "/scratch4/NCEPDEV/stmp3/Anthony.Craig/cimecases/ufs.s2s.c384_t025.ens03b/run/"
   ;plotname = "FV3-MOM6-CICE5"
   plotname = runtyp

   ; use one file for grid
   ; these contain the grid in degrees!
   ;gf =addfile(rtsrc+"history/iceh_ic.2016-10-03-00000.nc","r")
   gf =addfile(rtsrc+"ufs.s2s.c384_t025.ens03b.cice.h2_06h.2012-07-03-00000.nc","r")
   ; no coversion between radians and degrees
   rfactor = 1.0
   ;rfactor = rad2deg
   ;print(gf)

   ;dirname=rtsrc+"history/"
   dirname=rtsrc

     aicename = "aice"
       hiname = "hi"
      albname = "albsni"
  topmeltname = "meltt"
  botmeltname = "meltb"
  ; apnd*ai or apnd*alvl*ai ==> ponded ice fraction
  ; fpondname = "apond_ai"
   fpondname = "apond"
  ; hpnd*apnd or hpnd*apnd*alvl ==> ponded depth on sea ice (use _ai for ponded depth over grid cell)
  ; hpondname = "hpond"
   hpondname = "hpond_ai"
     socnname = "sss"
     tocnname = "sst"
   frzmltname = "frzmlt"
     tairname = "Tair"
 if(plotstress .eq. "yes")then
  ;stressxname = "strtltx"
  ;stressyname = "strtlty"
  stressxname = "strairx"
  stressyname = "strairy"
  ;stressxname = "strocnx"
  ;stressyname = "strocny"
  plottitle=rtsrc+"~C~"+stressxname+"  "+stressyname
 else 
     uicename = "uvel"
     vicename = "vvel"
  ;   uicename = "uocn"
  ;   vicename = "vocn"
  plottitle=rtsrc+"~C~"+uicename+"  "+vicename
 end if

   iceulonname="ULON"
   iceulatname="ULAT"
   icetlonname="TLON"
   icetlatname="TLAT"

;************************************************
; ice
;************************************************

  if(batch .eq. "no")then
   varname= aicename
   ;varname = hiname
   ;varname = albname
   ;varname = topmeltname
   ;varname = botmeltname
   ;varname = fpondname
   ;varname = hpondname
   ;varname = tocnname
   ;varname = socnname
   ;varname = frzmltname
   ;varname= tairname
  end if

  ; array contour levels for variables
      pltlevs = new((/3/),float)
      freturn = levscmapCICE(varname,hemi)
   pltlevs(:) = freturn[0]
   colormap   = freturn[1]

    varname =  varname+"_h"
  if(plotstress .eq. "yes")then
   uicename = stressxname+"_h"
   vicename = stressyname+"_h"
  else 
   uicename = uicename+"_h"
   vicename = vicename+"_h"
  end if

  if(mean .eq. "no")then
   lstep = 1-1
   cyear = 2012
    ;cday = cyear+"-10-23-00000"
    cday = cyear+"-07-03-00000"
   ;print("day = "+cday)
  ; icefilelist = (dirname+"iceh_06h."+cday+".nc")
   icefilelist = (dirname+"ufs.s2s.c384_t025.ens03b.cice.h2_06h."+cday+".nc")
   ;print(icefilelist)
          icef = addfiles(icefilelist,"r")
   avar = icef[0]->$varname$(lstep,:,:)
   uvar = icef[0]->$uicename$(lstep,:,:)
   vvar = icef[0]->$vicename$(lstep,:,:)
  else
   icefilelist = systemfunc("ls "+dirname+"iceh_06h.*.nc")
   print("averaging over "+dimsizes(icefilelist)+" files")
          icef = addfiles(icefilelist,"r")
   avar = dim_avg_n_Wrap(icef[:]->$varname$(:,:,:),0)
   uvar = dim_avg_n_Wrap(icef[:]->$uicename$(:,:,:),0)
   vvar = dim_avg_n_Wrap(icef[:]->$vicename$(:,:,:),0)
  end if

    tarea = icef[0]->tarea
    uarea = icef[0]->uarea
  ; in radians, on t-grid
  if(usegrid .eq. "U")then
   rotang = icef[0]->ANGLE
  else
   rotang = icef[0]->ANGLET
  end if

  avar@units=" "
  uvar@units=" "
  vvar@units=" "
  avar@long_name=" "

  avar@lon2d=icef[0]->$icetlonname$*rfactor
  avar@lat2d=icef[0]->$icetlatname$*rfactor
  uvar@lon2d=icef[0]->$iceulonname$*rfactor
  uvar@lat2d=icef[0]->$iceulatname$*rfactor
  vvar@lon2d=icef[0]->$iceulonname$*rfactor
  vvar@lat2d=icef[0]->$iceulatname$*rfactor

  if(usegrid .eq. "T")then
  print("unstaggering velocities ")
  ; unstagger
   uvar = where(ismissing(uvar),0.0,uvar)
   vvar = where(ismissing(vvar),0.0,vvar)
  print("uvar min = "+min(uvar)+" uvar max = "+max(uvar))
  print("vvar min = "+min(vvar)+" vvar max = "+max(vvar))
     ut = unstaggerCICE5(uvar,uarea,tarea)
     vt = unstaggerCICE5(vvar,uarea,tarea)

   ut@lon2d=icef[0]->$icetlonname$*rfactor
   ut@lat2d=icef[0]->$icetlatname$*rfactor
   vt@lon2d=icef[0]->$icetlonname$*rfactor
   vt@lat2d=icef[0]->$icetlatname$*rfactor
  else 
  ; copy metadata
   ut = uvar
   vt = vvar
  end if

  ; copy metadata
  urot = ut
  vrot = vt
  urot = cos(rotang)*ut - sin(rotang)*vt
  vrot = sin(rotang)*ut + cos(rotang)*vt
  ;printVarSummary(urot)

  urot = where(urot@lat2d .ge. minlat, urot, uvar@_FillValue)
  vrot = where(vrot@lat2d .ge. minlat, vrot, vvar@_FillValue)
  print("urot min = "+min(urot)+" urot max = "+max(urot))
  print("vrot min = "+min(vrot)+" vrot max = "+max(vrot))

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=60.00
   lon2=-120.00
   lat1=60
   lat2=60

;************************************************
; define the map
;************************************************
  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice_uv")              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False
  ;res@cnFillMode         = "RasterFill"
  res@cnFillMode         = "MeshFill"

  res@lbLabelBarOn       = True                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010
  res@gsnScalarContour  = True                  ; vectors over scalars

  res@vcRefMagnitudeF       = vmag              ; vec magnitude
  res@vcRefLengthF          = 0.10              ; size of ref vector
  ;res@vcMonoLineArrowColor  = True             ; multiple colors desired
  res@vcMinDistanceF        = vthn              ; thins arrows near pole
  ;res@vcLineArrowThicknessF = 1.5
  ;res@vcGlyphStyle          = "CurlyVector"
  ;res@vcPositionMode = "ArrowTail"

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
  res@cnMinLevelValF  = pltlevs(0)                      ; set the minimum contour level
  res@cnMaxLevelValF  = pltlevs(1)                      ; set the maximum contour level
  res@cnLevelSpacingF = pltlevs(2)                      ; set the interval between contours
  res@cnFillPalette               = "WhBlGrYeRe"             ; choose colormap

  ;res@cnLevelSelectionMode        = "ExplicitLevels"
  ;res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
  ;res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  ;res@cnFillPalette               = "WhBlGrYeRe"             ; choose colormap

  res@tiMainString = plottitle
  res@tiMainFontHeightF = .010

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

  plot = gsn_csm_vector_scalar_map_polar(wks,urot,vrot,avar,res)    ; create the plot
  ;plot = gsn_csm_vector_map_polar(wks,urot,vrot,res)    ; create the plot
  ;plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;draw(plot)
  ;frame(wks)

  ;plot = gsn_csm_contour_map_polar(wks,vvar,res)    ; create the plot
  ;dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;draw(plot)
  ;frame(wks)

  ;plot = gsn_csm_contour_map_polar(wks,avar,res)    ; create the plot
  dum= gsn_add_polyline(wks,plot,(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  draw(plot)
  frame(wks)

exit
end
