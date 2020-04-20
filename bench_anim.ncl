;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "levscmapCICE.ncl"
;************************************************
  batch="no"
  ;batch="yes"

  if(batch .eq. "no")then
     hemi = "NH"
   minlat = 66.0

    ;hemi = "SH"
  ;maxlat = -50.0
  end if
 
  ; these are in degrees
     rfactor=1.0
   tlatname="TLAT"
   tlonname="TLON"
   ulatname="ULAT"
   ulonname="ULON"

  ; make faster for debuggin
   iskp = 3
   jskp = 3

   dirname="/scratch3/NCEPDEV/stmp1/Denise.Worthen/Benchtest/"
begin
;************************************************
; make a list of the files from the run
; this will 'catch' the initial condition file
; until Bin rewrites the workflow to give the 
; initial condition file a more unique name
;************************************************

   icefilelist = systemfunc("ls "+dirname+"ice*.nc")
          icef = addfiles(icefilelist,"r")
        ntimes = dimsizes(icefilelist)
    print("ntimes = "+ntimes)
    print(icefilelist)

   ; use the first file to retrieve grid variables
    tmask = icef[0]->tmask(::jskp,::iskp)
    tarea = icef[0]->tarea(::jskp,::iskp)
    uarea = icef[0]->uarea(::jskp,::iskp)
  ; in radians, on t-grid
   rotang = icef[0]->ANGLET(::jskp,::iskp)

         times = icef[:]->time
     timeUnits = icef[0]->time@units
  timeCalendar = icef[0]->time@calendar

  ;varnames = (/"aice", "hi", "hs", "albsni"/)
  ;varnames = (/"aice"/)
  varnames = (/"aice", "hi"/)
     nvars = dimsizes(varnames)

   runname = "c384"
  plottitle= "test"
   plotname= "test"
  plottitle = plotname
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
  end if

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   wkstype="X11"
  ; wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)

  ; a max of panels, not all used
  npanels = dimsizes(varnames)
 ; for panels
   ncols = 2
   nrows = 2
 ;  ncols = 2
 ;  nrows = 1

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillMode = "MeshFill"
  ;res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  ;res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  ;res@lbLabelBarOn       = True                  ; turn on individual colorbars
  ;res@lbLabelFontHeightF = 0.010
  ;res@gsnPanelLabelBar    = False

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels
  res@gsnStringFontHeightF = 0.025

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
   
  resP@gsnFrame            = False
  resP@gsnPanelLabelBar    = False                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.008                ; make labels smaller
  resP@gsnPanelMainFontHeightF = 0.015            ; new resource added in NCL V6.4.0

  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5

;************************************************
; Create the starting panel for each variable
;************************************************

              nt = 0
    do nv = 0,nvars-1
         varname = varnames(nv)+"_h"
          icevar = icef[:]->$varname$(nt,::jskp,::iskp)
    icevar@lon2d = icef[0]->$tlonname$(::jskp,::iskp)*rfactor
    icevar@lat2d = icef[0]->$tlatname$(::jskp,::iskp)*rfactor
     labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
    icevar@units = ""
    icevar@long_name = ""
    ;print("nv = "+nv+"  "+labelstring)
    ;printVarSummary(icevar)

   ; array contour levels for variables
       varname = varnames(nv)
       pltlevs = new((/3/),float)
       freturn = levscmapCICE(varname)
    pltlevs(:) = freturn[0]
    colormap   = freturn[1]

    if(varname .eq. "aice_h" .or. varname .eq. "aice")then
     res@cnLevelSelectionMode        = "ExplicitLevels"
     res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
     res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
    else if(varname .eq. "hi_h" .or. varname .eq. "hi")then
     res@cnLevelSelectionMode        = "ExplicitLevels"
     res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
     res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
    else
     res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
     res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
     res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
     res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
    end if
    end if

    res@gsnLeftString  = labelstring
    res@gsnLeftStringFontHeightF = 0.015

    resP@gsnPanelMainString = cd_string(times(nt),"%Y%N%D %H")

    plot(nv) = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot
     dum(nv) = gsn_add_polyline(wks,plot(nv),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

     if(varname .eq. "aice_h" .or. varname .eq. "aice" .or. varname .eq. "hi_h" .or. varname .eq. "hi")then
      delete(res@cnLevels)
      delete(res@lbLabelStrings)
     end if
    end do
         print(nt+"  "+cd_string(times(nt),"%Y%N%D %H"))

;************************************************
; loop over files
;************************************************

  do nt=1,ntimes-1,5
    do nv = 0,nvars-1
     varname = varnames(nv)+"_h"
      icevar = icef[:]->$varname$(nt,::jskp,::iskp)
    plot(nv) = gsn_csm_contour_map_polar(wks,icevar,res)    ; create the plot
     dum(nv) = gsn_add_polyline(wks,plot(nv),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
     ;setvalues plot@data
     ; "sfDataArray" : (/icevar/)
     ; "sfDataArray" : (/icef[:]->$varname$(nt,::jskp,::iskp)/)
     ;end setvalues
    end do
    gsn_panel(wks,plot,(/nrows,ncols/),resP)
    resP@gsnPanelMainString = cd_string(times(nt),"%Y%N%D %H")
    frame(wks)
  end do

exit
end
