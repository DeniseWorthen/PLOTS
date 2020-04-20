; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
   ;date="20120101"
   dirname = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchCFSv2/"
   icefile = dirname+"cfs."+date+"/cfsv2."+date+"00.nc"
      icef = addfile(icefile,"r")
       ice = icef->aice_h

   nemsrc  = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"
   wgtsrc  = nemsrc+"regrids/"
   wgtfile = "cfsr_cice5.nc"
      wgts = wgtsrc + wgtfile

   grdsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BenchIce/gfs.20120101/"
   grdfile = addfile(grdsrc+"ice2012010112.01.2012010100.subset.nc","r")
     lat2d = grdfile->TLAT
     lon2d = grdfile->TLON
     tarea = grdfile->tarea

   outfile = dirname+"cfs."+date+"/cfsv2."+date+"00.cice5grid.nc"
   ; get output file ready
   system("/bin/rm -f "+outfile)

        df = addfile(outfile,"c")
   ;filedimdef(df,"time",-1,True)
   print("regridded files will be written to "+outfile)
   rgice = ESMF_regrid_with_weights(ice, wgts, True)

   ;aice_h@lon2d = lon2d
   ;aice_h@lat2d = lat2da
   ;rgice!0 = "ni"
   ;rgice!1 = "nj"
   df->lat2d = lat2d
   df->lon2d = lon2d
   df->tarea = tarea
   df->aice_h = rgice

   ncocmd = "ncatted -a lon2d,aice_h,d,, "+outfile
   system(ncocmd)
   ncocmd = "ncatted -a lat2d,aice_h,d,, "+outfile
   system(ncocmd)
   ncocmd = "ncrename -v lat2d,TLAT -v lon2d,TLON "+outfile
   system(ncocmd)

   ;df->aice_h = ESMF_regrid_with_weights(ice, wgts, True)
end
