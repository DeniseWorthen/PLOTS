;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

     RT = "/glade/derecho/scratch/worthen/FV3_RT/rt_26609/"

   date = "2021-03-22-"
  ntile = 6

    res = 96
    cres = ""
    ;comp = "atm"
    comp = "lnd"

    times = (/23760/)
   dirs = (/"lnd.dev.mesh/"/)
   fsrc = "ufs.cpld.cpl.hi."

  ndirs = dimsizes(dirs)
    nts = dimsizes(times)

do nd = 0,ndirs-1
 do nt = 0,nts-1
    time = times(nt)
   ctime = sprinti("%0.5i", time)
  dirsrc = RT+dirs(nd)
   ifile = fsrc + date+ ctime

  fname = dirsrc+ifile+".nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  latvar=comp+"Imp_lat"
  lonvar=comp+"Imp_lon"
  ;--- read coordinate variables ---
  lat1d = ff->$latvar$(0,0,:)
  lon1d = ff->$lonvar$(0,0,:)
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
   ;printVarSummary(lat3d)
   ;printVarSummary(lon3d)

;**********************************************************
; subset variables
;**********************************************************

  vnames = getfilevarnames (ff)
  nvars = dimsizes(vnames)
  valid = new((/nvars/), logical)
  ;print(comp+"Imp")
  ;print("Med_frac_"+comp+"_lat")

  do ii = 0,nvars-1
   tf = isStrSubset(vnames(ii), comp+"Imp") .or. \
        isStrSubset(vnames(ii), comp+"Exp") .or. \
        isStrSubset(vnames(ii), "Med_frac_"+comp)
    valid(ii) = tf
  end do
  do ii = 0,nvars-1
   vname = vnames(ii)
   if(vname .eq. comp+"Imp_lat"       .or. \
      vname .eq. comp+"Imp_lon"       .or. \
      vname .eq. "Med_frac_"+comp+"_lat" .or. \
      vname .eq. "Med_frac_"+comp+"lon" .or. \
      vname .eq. comp+"Exp_lat"       .or. \
      vname .eq. comp+"Exp_lon")then
    valid(ii) = False
   end if
  end do
  do ii = 0,nvars-1
   vname = vnames(ii)
   ;print(ii+" "+vnames(ii)+"  "+valid(ii))
  end do

;**********************************************************
; pre-define the output file
;**********************************************************

  do i = 0, ntile-1

    ofile = dirsrc+fsrc+time+"."+comp+".tile"+sprinti("%d", i+1)+".nc"
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
    do ii = 0,nvars-1
     if(valid(ii)) then
      vname = vnames(ii)
      ;printVarSummary(ff->$vname$(0,0,:))
      var1d = (/ff->$vname$(0,0,:)/)
      ;printVarSummary(var1d)
      filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
     end if
    end do
    setfileoption(fout, "DefineMode", False)

    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
  end do

;**********************************************************
; add variables
;**********************************************************

  do ii = 0,nvars-1
   if(valid(ii)) then
    vname = vnames(ii)
     var1d = (/ff->$vname$(0,0,:)/)
     var3d = new((/ ntile, res, res /), typeof(var1d), default_fillvalue(typeof(var1d)) )

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
     end do

     do i = 0, ntile-1
       ofile = dirsrc+fsrc+time+"."+comp+".tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       fout->$vname$ = (/ var3d(i,:,:) /)
     end do
    delete(var1d)
    delete(var3d)
   end if
  end do
  delete(vnames)
  delete(valid)
end do  ; nts
end do  ; ndirs

exit
end
