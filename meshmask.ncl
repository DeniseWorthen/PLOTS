;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

     RT = "/glade/scratch/worthen/FV3_RT/testnew/"

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
   ;fsrc = "rgstore.src.atm.ocn.bilnr"
   fsrc = "test.atm"
  ntile = 6
  ndirs = dimsizes(dirs)

do nd = 0,ndirs-1
  dirsrc = RT+dirs(nd)
   ifile = fsrc

  fname = dirsrc+ifile+".nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

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
    filevardef(fout, "grid_xt", "integer", (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", "integer", (/ "grid_yt", "grid_xt" /))

    ; Copy attributes associated with each variable to the file
    ;filevarattdef(fout,  "grid_yt",  lat3d)
    ;filevarattdef(fout,  "grid_xt",  lon3d)

    ;--- create variable ---
      vname = "mesh"
      filevardef(fout, vname, "integer", (/ "grid_yt", "grid_xt" /))
     setfileoption(fout, "DefineMode", False)

    ;fout->grid_xt = (/ lon3d(i,:,:) /)
    ;fout->grid_yt = (/ lat3d(i,:,:) /)
  end do

;**********************************************************
; add variables
;**********************************************************

     var1d = ff->mesh(:)
     printVarSummary(var1d)
     var3d = new((/ ntile, res, res /), typeof(var1d), default_fillvalue(typeof(var1d)) )

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
     end do

     do i = 0, ntile-1
      ofile = dirsrc+fsrc+".tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       fout->$vname$ = (/ var3d(i,:,:) /)
       delete(fout)
     end do
    delete(var1d)
    delete(var3d)
end do  ; ndirs

exit
end
