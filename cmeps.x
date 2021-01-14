#ncl 'hemi="NH"' 'cdate="20120101"' 'varname= "aice"'  < plot_cice_BM1_CMEPS_4.ncl
#ncl 'hemi="NH"' 'cdate="20120401"' 'varname= "aice"'  < plot_cice_BM1_CMEPS_4.ncl
#ncl 'hemi="NH"' 'cdate="20120701"' 'varname= "aice"'  < plot_cice_BM1_CMEPS_4.ncl
#ncl 'hemi="NH"' 'cdate="20121001"' 'varname= "aice"'  < plot_cice_BM1_CMEPS_4.ncl

ncl 'hemi="NH"' 'model="phyf006."' fldtoplot=0  < fv3_tilefield_2r_v3.ncl
ncl 'hemi="NH"' 'model="phyf006."' fldtoplot=2  < fv3_tilefield_2r_v3.ncl
ncl 'hemi="NH"' 'model="phyf006."' fldtoplot=6  < fv3_tilefield_2r_v3.ncl

ncl 'hemi="NH"' 'model="phyf048."' fldtoplot=0  < fv3_tilefield_2r_v3.ncl
ncl 'hemi="NH"' 'model="phyf048."' fldtoplot=2  < fv3_tilefield_2r_v3.ncl
ncl 'hemi="NH"' 'model="phyf048."' fldtoplot=6  < fv3_tilefield_2r_v3.ncl

ncl 'hemi="none"' 'model="phyf006."' fldtoplot=2  < fv3_tilefield_2r_v3.ncl
ncl 'hemi="none"' 'model="phyf006."' fldtoplot=6  < fv3_tilefield_2r_v3.ncl

ncl 'hemi="none"' 'model="phyf048."' fldtoplot=2  < fv3_tilefield_2r_v3.ncl
ncl 'hemi="none"' 'model="phyf048."' fldtoplot=6  < fv3_tilefield_2r_v3.ncl
