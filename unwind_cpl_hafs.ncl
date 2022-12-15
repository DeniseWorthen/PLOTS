;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

  RT = "/work/noaa/stmp/dworthen/stmp/dworthen/FV3_RT/rt_88781/"
     ;RT = "/work/noaa/hwrf/scrub/jsteff/hafs_202211_cmeps_check_12hr_v1a_baseline/2022092200/07L/"
     ;dirout = "/work/noaa/stmp/dworthen/stmp/dworthen/"

   ;date = "2022-09-22-"
  date = "2019-08-29-"

  ntile = 1
  ;nax = 1320
  ;nay = 1200
  nax = 720
  nay = 600
     dt = 3600
   ;dirs = (/"forecast/"/)
     dirs = (/"test/"/)
  dirout = RT+dirs

  times = 14400
  ;times = ispan(dt,2*dt,dt)
  ; fsrc = "ufs.hafs.cpl.hi.atm."
  fsrc = "ufs.hafs.cpl.hi."

  ndirs = dimsizes(dirs)
    nts = dimsizes(times)
    rad2deg = 180.d0/3.14

do nd = 0,ndirs-1
 do nt = 0,nts-1
    time = times(nt)
   ctime = sprinti("%0.5i", time)
  dirsrc = RT+dirs(nd)
   ifile = fsrc + date+ ctime

  fname = dirsrc+ifile+".nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  ;--- read coordinate variables ---
  lat1d = ff->atmImp_lat(0,0,:)
  lon1d = ff->atmImp_lon(0,0,:)
  lat1d = lat1d*rad2deg
  lon1d = lon1d*rad2deg
  ;printVarSummary(lat1d)
  ;printVarSummary(lon1d)
  print(lat1d(0:10))

  ;--- reshape variables---
  lon3d = new((/ ntile, nay, nax /), typeof(lon1d))
  lat3d = new((/ ntile, nay, nax /), typeof(lat1d))
  ;printVarSummary(lat3d)

  do i = 0, ntile-1
   istr = (i*nay*nax)
   iend = istr+nay*nax-1
   lat3d(i,:,:) = onedtond(lat1d(istr:iend), (/ nay, nax /))
   lon3d(i,:,:) = onedtond(lon1d(istr:iend), (/ nay, nax /))
  end do
  lat3d@units = "degrees_N"
  lon3d@units = "degrees_E"
  lon3d@long_name = "longitude"
  lat3d@long_name = "latitude"
   ;printVarSummary(lat3d)
   ;printVarSummary(lon3d)

;**********************************************************
; subset variables
;**********************************************************

  vnames = getfilevarnames (ff)
  nvars = dimsizes(vnames)
  valid = new((/nvars/), logical)

  do ii = 0,nvars-1
   tf = isStrSubset(vnames(ii), "atmImp") .or. \
        isStrSubset(vnames(ii), "atmExp") .or. \
        isStrSubset(vnames(ii), "Med_frac_atm")
    valid(ii) = tf
  end do
  do ii = 0,nvars-1
   vname = vnames(ii)
   if(vname .eq. "atmImp_lat"       .or. \
      vname .eq. "atmImp_lon"       .or. \
      vname .eq. "Med_frac_atm_lat" .or. \
      vname .eq. "Med_frac_atm_lon" .or. \
      vname .eq. "atmExp_lat"       .or. \
      vname .eq. "atmExp_lon")then
    valid(ii) = False
   end if
  end do
  do ii = 0,nvars-1
   vname = vnames(ii)
   print(ii+" "+vnames(ii)+"  "+valid(ii))
  end do

;**********************************************************
; pre-define the output file
;**********************************************************

  do i = 0, ntile-1

    ofile = dirout+fsrc+date+time+".2d.nc"
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "grid_xt", "grid_yt" /)
    dimSizes = (/ nax, nay /)
    dimUnlim = (/ False, False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;--- create lat,lon variable ---
    filevardef(fout, "grid_xt", typeof(lon1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat1d), (/ "grid_yt", "grid_xt" /))

    ; Copy grid attributes associated to the file
    filevarattdef(fout,  "grid_yt",  lat3d)
    filevarattdef(fout,  "grid_xt",  lon3d)

    ;--- create variable ---
    do ii = 0,nvars-1
     if(valid(ii)) then
      vname = vnames(ii)
      varf  := ff->$vname$
      vatts := getfilevaratts(ff,varf)
      var1d := varf

      copy_VarAtts(ff->$vname$,var1d)
      filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))

      ;printVarSummary(var1d)
      ;printVarSummary(ff->$vname$)
      print(vname)
      filevarattdef(fout, vname, var1d)
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
     var3d = new((/ ntile, nay, nax /), typeof(var1d), default_fillvalue(typeof(var1d)) )

     do i = 0, ntile-1
      istr = (i*nay*nax)
      iend = istr+nay*nax-1
      var3d(i,:,:) = onedtond(var1d(istr:iend), (/ nay, nax /))
     end do

     do i = 0, ntile-1
      ofile = dirout+fsrc+date+time+".2d.nc"
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
