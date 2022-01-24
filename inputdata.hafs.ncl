;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

;**********************************************************
begin

     ;RT = "/glade/scratch/worthen/FV3_RT/wave_hafs2/test/"
     ;RT = "/glade/scratch/worthen/FV3_RT/hafs_newold/newcap/"
     RT = "/glade/scratch/worthen/FV3_RT/wave_test/test/"

   nl = str_get_nl()
   nflags = 9
  ; vnames = (/"wxdata","wydata","wx0","wy0", "import_mask"/)
   vnames = (/"wx0","wy0"/)
  doffile = "dof.wav.nc"
  ;doffile = "/glade/scratch/worthen/FV3_RT/wave_hafs/test/dof.wav.nc"
  date = "2021-03-22-"
  times = (/"25200"/)
  ;times = (/"00360", "00720", "01080"/)

  ; waves
  ;ni = 901
  ;nj = 441
  ni = 360
  nj = 320

  nfiles = dimsizes(vnames)
  ntimes = dimsizes(times)

;**********************************************************
;
;**********************************************************

do nt = 0,ntimes-1
do nf = 0,nfiles-1
  dirsrc = RT
   vname = vnames(nf)
   ifile = vname+"."+date+times(nt)

  fname = dirsrc+ifile+".nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  var1d = ff->$vname$(:)
  ;printVarSummary(var1d)

  ; get the index seq to resort
  doff = addfile(dirsrc+doffile,"r")
  ;doff = addfile(doffile,"r")
  dof = doff->dof(:)
  delete(doff)

  ip = dim_pqsort(dof,1)
  var1d_sort=var1d
  var1d_sort=var1d(ip)

;**********************************************************
; pre-define the output file
;**********************************************************

    ofile = dirsrc+"dst."+ifile+".nc"
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
    delete(var1d_sort)
    delete(var2d)
    delete(dof)
end do  ; nfiles
end do  ; ntimes


exit
end
