;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "tilegrid.ncl"

;************************************************
; read in netCDF file
;************************************************

  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  ;rtname = "S2S_tod"
  rtname = "S2S_names"
  ;rtsrc = rtname+"/2012010100_06hr/tmp/cpld_fv3_384_mom6_cice_2d_bmark/"
  rtsrc = rtname+"/2012010100_06hr_aofld/tmp/cpld_fv3_384_mom6_cice_2d_bmark/"

  hemi = "NH"
  ;hemi = "SH"
  ;hemi = "none"

 rad2deg=180.d0/acos(-1.0d0)
  icemin = 1.0e-6
 const_lhvap = 2.501e6

;************************************************
;
;************************************************

  lstep=0
  if(hemi .eq. "none")then
    tile = "tile4"
  else
   if(hemi .eq. "NH")then
    tile = "tile3"
  end if
  if(hemi .eq. "SH")then
    tile = "tile6"
  end if
 end if

;************************************************
;  Atm lats/lons and mask
;************************************************

       gf = addfile(RT2+rtsrc+"phyf000:07:30."+tile+".nc","r")
    tlonname = "grid_xt"
    tlatname = "grid_yt"
 atmlandname = "land"
   rfactor = rad2deg
  tilecorners = tilegrid(gf->$tlonname$,gf->$tlatname$,tile)
  if(hemi .eq. "none")then
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   midlon = minlon + 0.5*(maxlon - minlon)
  else
   if(hemi .eq. "NH")then
    minlat =  66.0
    midlon = -45.0
   else
    maxlat = -50.0
    midlon =   0.0
   end if
  end if
        atmlons = olon->$tlonname$
        atmlats = olat->$tlatname$
          aland = amask->$atmlandname$
  atmlons@units = "degrees_E"
  atmlats@units = "degrees_N"
    aland@lon2d = atmlons
    aland@lat2d = atmlats

;************************************************
;  Ocn lats/lons and mask
;************************************************
  
       olon = addfile(RT2+rtsrc+"array_med_ocn_grid_coord1.nc","r")
       olat = addfile(RT2+rtsrc+"array_med_ocn_grid_coord2.nc","r")
      omask = addfile(RT2+rtsrc+"array_med_ocn_grid_mask.nc","r")
   olonname = "lon_center"
   olatname = "lat_center"
  olandname = "mask"

        ocnlons = olon->$olonname$
        ocnlats = olat->$olatname$
          oland = omask->$olandname$
  ocnlons@units = "degrees_E"
  ocnlats@units = "degrees_N"
    oland@lon2d = ocnlons
    oland@lat2d = ocnlats

;************************************************
;
;************************************************

  ocnstp = 5
  atmstp = (ocnstp-1) + 3*(ocnstp-2)
  lbeg = atmstp
  lend = atmstp+3
  print("lbeg:lend = "+lbeg+"  "+lend)

  ; from atm fields
  ffr_atm = "field_med_from_atm_0000"
  atmflds = (/"mean_sensi_heat_flx",  \
              "mean_laten_heat_flx",  \
              "mean_zonal_moment_flx",\
              "mean_merid_moment_flx",\
              "mean_net_lw_flx"/)

  atmsgns = (/-1.0, \
              -1.0/const_lhvap,\
              -1.0, \
              -1.0, \
               1.0/)
 
  ; mediator aoflux fields
  f_aoflx = "field_aofield_to_ocn"
   aoflds = (/"mean_sensi_heat_flx_atm_into_ocn", \
              "mean_evap_rate_atm_into_ocn",      \
              "stress_on_air_ocn_zonal",          \
              "stress_on_air_ocn_merid",          \
              "mean_up_lw_flx_ocn"/)
      
   aosgns = (/ 1.0, \
               1.0, \
               1.0, \
               1.0, \
               1.0 /)

  ; to ocn fields
  fto_ocn = "field_med_to_ocn"
  ocnflds = (/"mean_sensi_heat_flx",  \
              "mean_evap_rate",       \
              "mean_zonal_moment_flx",\
              "mean_merid_moment_flx",\
              "mean_net_lw_flx"/) 

  fto_atm = "field_med_to_atm_0000"
   icefld = "ice_fraction"

  ; plot levels
  plotlevs = new((/5,3/), float)
  plotlevs(0,:) = (/-40,40,2/)
  plotlevs(1,:) = (/-1.,1.,.05/)
  plotlevs(2,:) = (/-0.8,0.8,.05/)
  plotlevs(3,:) = (/-0.8,0.8,.05/)
  plotlevs(4,:) = (/-150,150,10/)
  
  ;print(plotlevs)

  ;default
  cmap="cmp_flux"

;************************************************
;
;************************************************

  ; get atmflds...steps are in different files
  fr_atmlist = systemfunc("ls "+RT2+rtsrc+ffr_atm+"*"+tile+".nc")
  atmfiles = addfiles(fr_atmlist,"r")
  ListSetType(atmfiles,"join")

  ; get aofields...steps in single file
  aofiles = addfiles(RT2+rtsrc+f_aoflx+"_"+aoflds+".nc","r")
  ;print(aofiles)

  ; get ocnflds...steps in single file
  ocnfiles = addfiles(RT2+rtsrc+fto_ocn+"_"+ocnflds+".nc","r")
  ;print(ocnfiles)

exit
end
