#! /bin/csh -f

set CDATE="20160101"
set dirname="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/benchmark_test/$CDATE/COMFV3/c384_test/gfs.$CDATE/00/ICE/"
set hemi="NH"
#echo $dirname
#echo $outname

set outname=".ice."$hemi
ncl dirname=\"{$dirname}\"  'varnames = (/"aice", "hi", "hs", "albsni"/)' hemi=\"{$hemi}\" outname=\"{$outname}\" bench_anim3.ncl

set outname=".melt.pond."$hemi
ncl dirname=\"{$dirname}\"  'varnames = (/"meltt", "meltb", "apond", "hpond"/)' hemi=\"{$hemi}\" outname=\"{$outname}\" bench_anim3.ncl

#ncl 'dirname="/scratch3/NCEPDEV/stmp1/Denise.Worthen/Benchtest2/"' 'varnames = (/"aice", "hi", "hs", "albsni"/)' 'hemi = "NH"' 'outname=".ice"' bench_anim3.ncl
#ncl 'dirname="/scratch3/NCEPDEV/stmp1/Denise.Worthen/Benchtest2/"' 'varnames = (/"meltt", "meltb", "apond", "hpond"/)' 'hemi = "NH"' 'outname=".melt.pond"' bench_anim3.ncl

#ncl 'dirname="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_35d_july_bubbly_dp1/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/history/"' 'varnames = (/"aice", "hi", "hs", "albsni"/)' 'hemi = "NH"' 'outname=".ice.nh."' bench_anim3.ncl
#ncl 'dirname="/scratch3/NCEPDEV/stmp2/Denise.Worthen/frzmlt_35d_july_bubbly_dp1/tmp/cpld_fv3_384_mom6_cice_35d_atm_flux/history/"' 'varnames = (/"meltt", "meltb", "apond", "hpond"/)' 'hemi = "NH"' 'outname=".melt.pond.nh."' bench_anim3.ncl
