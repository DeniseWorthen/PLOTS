#ncl 'model="hykiss"' 'varnames="Lhflxi"' < plot_monfld_new.ncl
#ncl 'model="hykiss"' 'varnames="Shflxi"' < plot_monfld_new.ncl
#ncl 'model="hykiss"' 'varnames="Lwupice"' < plot_monfld_new.ncl
#ncl 'model="hykiss"' 'varnames="Evapi"' < plot_monfld_new.ncl
#ncl 'model="hykiss"' 'varnames="Dswrf"' < plot_monfld_new.ncl
#ncl 'model="hykiss"' 'varnames="Dlwrf"' < plot_monfld_new.ncl

#./adjoin.x -m V kiss_Dswrf.jpg kiss_Dlwrf.jpg kiss_Lwupice.jpg kiss_rad.jpg
#./adjoin.x -m V kiss_Lhflxi.jpg kiss_Shflxi.jpg kiss_Evapi.jpg kiss_flx.jpg

ncl 'model="hycice"' 'varnames="flat_ai"' < plot_monfld_new.ncl
ncl 'model="hycice"' 'varnames="fsens_ai"' < plot_monfld_new.ncl
ncl 'model="hycice"' 'varnames="flwup_ai"' < plot_monfld_new.ncl
ncl 'model="hycice"' 'varnames="evap_ai"' < plot_monfld_new.ncl
ncl 'model="hycice"' 'varnames="fswdn"' < plot_monfld_new.ncl
ncl 'model="hycice"' 'varnames="flwdn"' < plot_monfld_new.ncl

./adjoin.x -m V cice_fswdn.jpg cice_flwdn.jpg cice_flwup_ai.jpg cice_rad.jpg
./adjoin.x -m V cice_flat_ai.jpg cice_fsens_ai.jpg cice_evap_ai.jpg cice_flx.jpg

