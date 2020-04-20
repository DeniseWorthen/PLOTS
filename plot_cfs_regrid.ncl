; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
    f = addfile("/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchCFSv2/cfs.20120815/cfsv2.2012081500.nc","r")

    lstep=35-1
    ice=f->aice_h(lstep,:,:)
   ;icemask=f->lsmask(:,:)
   ; ice=ice*icemask

   nemsrc  = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"
   wgtsrc  = nemsrc+"regrids/"
   wgtfile = "cfsr_cice5.nc"
      wgts = wgtsrc + wgtfile

    ice_regrid = ESMF_regrid_with_weights(ice,wgts,False)
    ;printVarSummary(ice_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("X11","ESMF_wgts")       ; send graphics to PNG file

    res                     = True              ; Plot mods desired.
    res@gsnMaximize         = True              ; Maximize plot

    res@gsnDraw             = False
    res@gsnFrame            = False
    res@mpFillOn = False
    res@mpOutlineOn = False

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "amwg"            ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    ;res@cnFillMode          = "RasterFill"      ; turn raster on       

   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""

  res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

    ;res@cnLevelSelectionMode= "ExplicitLevels" ; set explicit contour levels
    ;res@cnLevels            = (/-300,-250,-200,-150,-100,   \
    ;                            0,1,5,10,25,100,200,300,400/)

    res@lbLabelBarOn        = False              ; turn on in panel


    res@gsnPolar            = "NH"               ; specify the hemisphere
    res@mpMinLatF           = 66
    res@mpCenterLonF = -45

;---Plot original data.
    plot_orig   = gsn_csm_contour_map_polar(wks,ice,res)     

;---Plot regridded data.

    plot_regrid = gsn_csm_contour_map_polar(wks,ice_regrid,res)     

;---Compare the plots in a panel
    pres                    = True
    pres@gsnMaximize        = True
    pres@gsnPanelLabelBar   = True
    pres@lbLabelFontHeightF = 0.01
    pres@pmLabelBarWidthF   = 0.8

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)
end
