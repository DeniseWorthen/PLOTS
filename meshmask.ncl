;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

     RT = "/glade/scratch/worthen/FV3_RT/testnew/"
  ;   RT = "/glade/scratch/worthen/FV3_RT/testbob/"
  ;   RT = "/glade/scratch/worthen/FV3_RT/test192/"
   date = "2016-10-03-"

    res = 96
   cres = ""
     dt = 900

  ;  res = 192
  ; cres = "_c192"
  ;   dt = 900

 ;   res = 384
 ;  cres = "_c384"
 ;    dt = 450

   dirs = (/"testbilin/"/)
   ;dirs = (/"testdev/", "testbilin/"/)
   ;fsrc = "af.rgstore.src.atm.ocn.bilnr"
   ;fsrc = "b4.rgstore.dst.ocn.atm.consd"
   fsrc = "rh.fb.ocn.atm.consd.Fioo_q"
   ;fsrc = "rh.fb.ice.atm.consd.Faii_evap"
   ;fsrc = "rh.esmflds.ocn.atm.consd.So_dhdy"
   ;fsrc = "rh.esmflds.ice.atm.consf.Fioi_melth"
   ;fsrc = "rh.fb.ocn.atm.consd.So_v"
   ;fsrc = "dst.atm.ifrac.nc"
   ;fsrc = "dstlat.atm.nc"

  ;vname = "mesh"
  vname = "dststatus"
  ;vname = "ifrac"
  ;vname = "ifrac"
  ;vname = "dstlat"

  ntile = 6
  ndirs = dimsizes(dirs)

;**********************************************************
; retrieve lat/lon from first coupler history file
;**********************************************************

  fname = RT+dirs(0)+"ufs.cpld.cpl.hi."+date+"00900.nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  ;--- read coordinate variables ---
  lat1d = ff->atmImp_lat(0,0,:)
  lon1d = ff->atmImp_lon(0,0,:)
  lat1d@units = "degrees_N"
  lon1d@units = "degrees_E"
  ;printVarSummary(lat1d)
  ;printVarSummary(lon1d)

  ;--- reshape variables---
  lon3d = new((/ ntile, res, res /), typeof(lon1d))
  lat3d = new((/ ntile, res, res /), typeof(lat1d))
  ;printVarSummary(lat3d)

  do i = 0, ntile-1
   istr = (i*res*res)
   iend = istr+res*res-1
   lat3d(i,:,:) = onedtond(lat1d(istr:iend), (/ res, res /))
   lon3d(i,:,:) = onedtond(lon1d(istr:iend), (/ res, res /))
  end do

  delete(ff)
  delete(fname)

;**********************************************************
;
;**********************************************************

do nd = 0,ndirs-1
  dirsrc = RT+dirs(nd)
   ifile = fsrc

  fname = dirsrc+ifile+".nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  var1d = ff->$vname$(:)
  printVarSummary(var1d)

  ; get the index seq to resort
  doffile = dirsrc+"dof.atm.ifrac.nc"
  doff = addfile(doffile,"r")
  dof = doff->dof(:)

  ip = dim_pqsort(dof,1)
  var1d_sort=var1d
  var1d_sort=var1d(ip)

;**********************************************************
; pre-define the output file
;**********************************************************

  do i = 0, ntile-1

    ofile = dirsrc+fsrc+".tile"+sprinti("%d", i+1)+".nc"
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "grid_xt", "grid_yt" /)
    dimSizes = (/ res, res /)
    dimUnlim = (/ False, False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;--- create lat,lon variable ---
    filevardef(fout, "grid_xt", typeof(lon1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat1d), (/ "grid_yt", "grid_xt" /))

    ; Copy attributes associated with each variable to the file
    ;filevarattdef(fout,  "grid_yt",  lat3d)
    ;filevarattdef(fout,  "grid_xt",  lon3d)

    ;--- create variable ---

     filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
  end do

;**********************************************************
; add variables
;**********************************************************

     var3d = new((/ ntile, res, res /), typeof(var1d), default_fillvalue(typeof(var1d)) )
     ;printVarSummary(var3d)

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      ;var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
      var3d(i,:,:) = onedtond(var1d_sort(istr:iend), (/ res, res /))
      print("tile number = "+i+" "+istr+" "+iend)
     end do

     do i = 0, ntile-1
      ofile = dirsrc+fsrc+".tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       ;fout->$vname$ = (/ var3d(i,:,:) /)
       fout->$vname$ = var3d(i,:,:)
       delete(fout)
     end do
    delete(var1d)
    delete(var3d)
end do  ; ndirs

exit
end
