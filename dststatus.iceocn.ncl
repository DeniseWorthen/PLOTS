;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

     RT = "/glade/scratch/worthen/FV3_RT/testnew/"
     ;RT = "/glade/scratch/worthen/FV3_RT/testdatm/"
     ;RT = "/glade/scratch/worthen/FV3_RT/rt_72321/"

   nflags = 8
   dirs = (/"testdev/"/)
   ;dirs = (/"gefsbilin_nstod/"/)
   ;dirs = (/"testmask/", "testmaskall/"/)
  ;   fsrc = "dststatus.atm.ocn.bilnr.nc"
 ; doffile = "dof.ocn.nc"
 ;    fsrc = "dststatus.atm.ice.bilnr_nstod.nc"
 ; doffile = "dof.ice.nc"
     ;fsrc = "dststatus.atm.ocn.nstod_consf.nc"
     fsrc = "dststatus.atm.ocn.consf.nc"
;    ; fsrc = "unityone.atm.ocn.consf.nc"
  doffile = "dof.ocn.nc"

  ;vname = "unity"
  vname = "dststatus"

  ; mx100
  ni = 360
  nj = 320
  ; mx050
  ;ni = 720
  ;nj = 576

  ndirs = dimsizes(dirs)

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
  ;printVarSummary(var1d)
  do i = 0,nflags-1
   ret = dststatus_counts(var1d,i+1)
  end do

  ; get the index seq to resort
  doff = addfile(dirsrc+doffile,"r")
  dof = doff->dof(:)

  ip = dim_pqsort(dof,1)
  var1d_sort=var1d
  var1d_sort=var1d(ip)

;**********************************************************
; pre-define the output file
;**********************************************************

    ofile = dirsrc+"dst."+fsrc
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "grid_yt", "grid_xt" /)
    dimSizes = (/    nj,      ni /)
    dimUnlim = (/ False, False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;--- create lat,lon variable ---
    ;filevardef(fout, "grid_yt", "integer", (/ "grid_yt" /))
    ;filevardef(fout, "grid_xt", "integer", (/ "grid_xt" /))

    ;--- create variable ---

    filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    ;fout->grid_xt = ispan(1,ni,1)
    ;fout->grid_yt = ispan(1,nj,1)

;**********************************************************
; add variables
;**********************************************************

     var2d = new((/ nj, ni /), typeof(var1d), default_fillvalue(typeof(var1d)) )
     ;printVarSummary(var3d)

      var2d(:,:) = onedtond(var1d_sort(:), (/ nj, ni /))

      fout->$vname$ = var2d(:,:)
      delete(fout)

    delete(var1d)
    delete(var2d)
end do  ; ndirs


exit
end
