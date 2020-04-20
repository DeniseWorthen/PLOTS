function setlevsmaps(name)
begin

         levs = new((/3/),float)
         cmap = new((/1/),string)
    latent_levs=(/ -12.00,    12.00,  0.500/)
     ; sens_levs=(/ -20.00,    20.00,  1.000/) 
      sens_levs=(/   0.00,    40.00,  1.000/) 
      ;evap_levs=(/  -0.2,     0.2,  0.02/) 
      evap_levs=(/  -0.5,     0.5,  0.05/) 
      lwup_levs=(/-300.00,     0.00, 10.000/)
      dswf_levs=(/ 230.00,   380.00,  5.000/)
      dlwf_levs=(/ 200.00,   340.00,  5.000/)
   topmelt_levs=(/   0.00,     5.00,  0.200/)
   ;botmelt_levs=(/   0.00,     3.00,  0.100/)
   botmelt_levs=(/   0.00,     2.00,  0.050/)
      tsfc_levs=(/ -30.00,     0.00,  1.000/)
   ;    sst_levs=(/   0.00,    16.00,  0.500/)
       sst_levs=(/  -1.80,     0.00,  0.050/)
      snow_levs=(/   0.00,     1.00,  0.050/)
      tair_levs=(/ -20.00,    10.00,  0.500/)
       alb_levs=(/  20.00,    80.00,  5.000/)
   ;    ice_levs=(/   0.00,     1.00,  0.100/)
       ice_levs=(/   0.90,     1.00,  0.005/)
        hi_levs=(/   0.00,     4.00,  0.500/)
   ;  fpond_levs=(/   0.00,     1.00,  0.100/)
     hpond_levs=(/   0.00,     0.50,  0.050/)
     fpond_levs=(/   0.00,     0.50,  0.050/)
   ;  hpond_levs=(/   0.00,     0.20,  0.020/)
     frzmlt_levs=(/ -20.00,  20.00,  2.000/)

   ; default
    cmap = "MPL_rainbow"

   if(name .eq. "Evapi" .or. name .eq. "evap_ai")then
    levs = evap_levs
    cmap = "BlWhRe"
   end if
   if(name .eq. "Lhflxi" .or. name .eq. "flat_ai")then
    levs = latent_levs
    cmap = "BlWhRe"
   end if
   if(name .eq. "Shflxi" .or. name .eq. "fsens_ai")then
    levs = sens_levs
    ;cmap = "BlWhRe"
   end if
   if(name .eq. "Lwupice" .or. name .eq. "flwup_ai")then
    levs = lwup_levs
    cmap = "MPL_rainbow"
   end if
   if(name .eq. "Dswrf" .or. name .eq. "fswdn")then
    levs = dswf_levs
   end if
   if(name .eq. "Dlwrf" .or. name .eq. "flwdn")then
    levs = dlwf_levs
   end if
   if(name .eq. "meltt" .or. name .eq. "Ai_water")then 
    levs = topmelt_levs
    cmap = "WhBlGrYeRe"
   end if
   if(name .eq. "meltb" .or. name .eq. "Io_water")then 
    levs = botmelt_levs
   end if
   if(name .eq. "Tsfc" .or. name .eq. "Sfc_temp")then
    levs = tsfc_levs
   end if
   if(name .eq. "hs" .or. name .eq. "Snow_thick")then
    levs = snow_levs
   end if
   if(name .eq. "Tair" .or. name .eq. "T2m")then
    levs = tair_levs
   end if
   if(name .eq. "albsni" .or. name .eq. "Sfcalb")then
    levs = alb_levs
   end if
   if(name .eq. "aice" .or. name .eq. "Ice_conc")then
    cmap = "WhBlGrYeRe"
    levs = ice_levs
   end if
   if(name .eq. "hi" .or. name .eq. "Ice_thick")then
    cmap = "WhBlGrYeRe"
    levs = hi_levs
   end if
   if(name .eq. "apond_ai" .or. name .eq. "apond" .or. name .eq. "apeff_ai")then
    cmap = "WhBlGrYeRe"
    levs = fpond_levs
   end if
   if(name .eq. "hpond_ai" .or. name .eq. "hpond")then
    cmap = "WhBlGrYeRe"
    levs = hpond_levs
   end if
   if(name .eq. "sst" .or. name .eq. "Tmix")then
    levs = sst_levs
   end if
   if(name .eq. "frzmlt")then
    levs = frzmlt_levs
    cmap = "ncl_default"
   end if

   ;print(name+"  "+levs)
   ;print(name+"  "+cmap)
   return( [/levs,cmap/])
end
