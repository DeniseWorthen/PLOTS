;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "levscmapCICE.ncl"
;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

;************************************************

  ;     hemi = "NH"
      hemi = "SH"
  ;varnames = (/"aice", "hi"/)
  varnames = (/"aice_h", "Tsfc_h"/)
  ;varnames = (/"aice", "flwup"/)
  ;varnames = (/"hs", "hi"/)
  ; varnames = (/"hs", "albsni"/)
  ; varnames = (/"meltt", "meltb"/)
    outname = "ice"+hemi
      nvars = dimsizes(varnames)
  ; array contour levels for variables
    varlevs = new((/nvars,3/),float)
  colormaps = new((/nvars/), string)

  if(hemi .eq. "NH")then
    minlat = 66.0
  else
    maxlat = -50.0
  end if

  ; these are in degrees
     rfactor=1.0
   tlatname="TLAT"
   tlonname="TLON"
   ulatname="ULAT"
   ulonname="ULON"

   minice = 1.0e-6
;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "2012"
      cmon = "01"
      cday = "10"
      csec = "00000"
     ; csec = "00450"
     ; csec = "00900"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

      rts = (/"S2S_nems/2012010100_12d","S2S_cmeps/2012010100_11d_fail/"/)
    csets = (/"/tmp/cpld_fv3_384_mom6_cice_2d_bmark/history/", \
              "/tmp/cpld_fv3_384_mom6_cice_2d_cmeps_bmark/history/"/)
     
     files = addfiles(RT4+rts+csets+"iceh_06h."+cdate+".nc","r")
     ;ListSetType(files,"join")

     ;plottitle=rts(1)+" - "+rts(0)
     ;plottitle="cmeps_integration_update (Theia)"

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

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

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"cice_2r2f")

  ;drawNDCGrid(wks)

  plotleft = new(2,graphic)
  plotrght = new(2,graphic)
   dumleft = new(2,graphic)
   dumrght = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  ;res@mpFillOn   = True
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat  
   res@mpCenterLonF = 0.0
  end if

  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF = 0.020           ; change font height of labels
  res@gsnStringFontHeightF     = 0.025
  res@lbLabelFontHeightF       = 0.020     

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

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

  ;print(pltlevs)
  ;print(palette)

  plot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  delete(res@cnLevels)
  delete(res@lbLabelStrings)
  return(plot)
end
;************************************************
; left plot and colorbar, same variable 
; (same field, same timestep, 2 runs)
;************************************************

         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)

   ; 1st variable
          vnum = 0
         vname = varnames(vnum)
       freturn = levscmapCICE(vname,hemi)
    pltlevs(:) = freturn[0]
    colormap   = freturn[1]
  ;       vname = vname+"_h"
  ; override
  ;   vname = "aice"
  ;colormap = "MPL_rainbow"
  ;pltlevs = (/0.7,1.0,.02/)

  ; 1st plot
      ii = 0
  ; 1st run
    fnum = 0

        icevar = files[fnum]->$vname$(0,:,:)
  icevar@lon2d = files[fnum]->$tlonname$*rfactor
  icevar@lat2d = files[fnum]->$tlatname$*rfactor
  labelstrings(vnum) = icevar@long_name+" ("+icevar@units+")  "+"["+vname+"]"
  icevar@long_name = " "
  icevar@units= " "
  plotleft(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   dumleft(ii) = gsn_add_polyline(wks,plotleft(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;print(labelstrings(0))

  ; 2nd plot
      ii = 1
  ; 2nd run
    fnum = 1

        icevar = files[fnum]->$vname$(0,:,:)
  icevar@lon2d = files[fnum]->$tlonname$*rfactor
  icevar@lat2d = files[fnum]->$tlatname$*rfactor
  icevar@long_name = " "
  icevar@units= " "
  plotleft(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   dumleft(ii) = gsn_add_polyline(wks,plotleft(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  ;delete(icevar)

;************************************************
; right plot and colorbar
; (same field, same timestep, 2 runs)
;************************************************

   ; make tcomposit
   ; ai = files[:]->aice(:,lstep,:,:)
   ;sst = files[:]->sst(:,lstep,:,:)
  ;tsfc = files[:]->Tsfc(:,lstep,:,:)
  ;tcomp = tsfc ; copy atts
  ;tcomp = (1.0 - ai)*sst + ai*tsfc
  ;tcomp@long_name="(1-ai)*SST + ai*Tsfc"
 
   ; 2nd variable
          vnum = 1
         vname = varnames(vnum)
       freturn = levscmapCICE(vname,hemi)
    pltlevs(:) = freturn[0]
    colormap   = freturn[1]
  ;       vname = vname+"_h"
  ; override
  ;pltlevs = (/-2,0,.2/)
  pltlevs = (/-30,0,1./)
  colormap = "MPL_rainbow"
  ;   vname = "flwup"
  ;colormap = "MPL_rainbow"
  ;pltlevs = (/300,322,1/)
  ;pltlevs = (/-322,-300,1/)

  ; 1st plot
      ii = 0
  ; 1st run
    fnum = 0

        icevar = files[fnum]->$vname$(0,:,:)
        ;icevar = where(files[fnum]->aice(0,:,:) .lt. minice, icevar@_FillValue, icevar)
  ;icevar = tcomp(ii,:,:)
  icevar@lon2d = files[fnum]->$tlonname$*rfactor
  icevar@lat2d = files[fnum]->$tlatname$*rfactor
  labelstrings(vnum) = icevar@long_name+" ("+icevar@units+")  "+"["+vname+"]"
  icevar@long_name=" "
  icevar@units=" "
  plotrght(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   dumrght(ii) = gsn_add_polyline(wks,plotrght(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

  ; 2nd plot
      ii = 1
  ; 2nd run
    fnum = 1
     ii = 1

        icevar = files[fnum]->$vname$(0,:,:)
        ;icevar = where(files[fnum]->aice(0,:,:) .lt. minice, icevar@_FillValue, icevar)
  ;icevar = tcomp(ii,:,:)
  icevar@long_name = " "
  icevar@units= " "
  plotrght(ii) = subplot(ii,vname,icevar(:,:),pltlevs,colormap)
   dumrght(ii) = gsn_add_polyline(wks,plotrght(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  delete(icevar)

;************************************************
;
;************************************************

 resP1                  = True                ; mods desired
 resP1@gsnFrame         = False               ; save panel until both ready
 resP1@gsnPanelRight    = 0.5                 ; draw from left edge to center
 resP1@gsnPanelLabelBar = True                ; commom label bar

 resP2                  = True                ; mods desired
 resP2@gsnFrame         = False               ; save panel until both ready
 resP2@gsnPanelLeft     = 0.5		      ; draw from center to right edge 
 resP2@gsnPanelLabelBar = True		      ; commom label bar

 resP1@gsnPanelYWhiteSpacePercent = 10
 resP1@gsnPanelXWhiteSpacePercent = 10
 resP2@gsnPanelYWhiteSpacePercent = 10
 resP2@gsnPanelXWhiteSpacePercent = 10

 gsn_panel(wks,plotleft,(/2,1/),resP1)          ; create first panel
 gsn_panel(wks,plotrght,(/2,1/),resP2)          ; create second panel

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.015                     ; font smaller. default big

; page coordinates are normalized. go from 0->1 not 0->8" etc.
  gsn_text_ndc(wks,rts(0)+" "+cdate,0.5,0.98,txres) 
  gsn_text_ndc(wks,rts(1)+" "+cdate,0.5,0.58,txres) 

  gsn_text_ndc(wks,labelstrings(0),0.25,0.03,txres) 
  gsn_text_ndc(wks,labelstrings(1),0.75,0.03,txres) 
 frame(wks)
exit
end
