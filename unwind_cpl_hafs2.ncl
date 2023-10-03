;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

  RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_2185/"
  dirout = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_2185/"
  date = "2019-08-29-"

  ntile = 1
  nax = 720
  nay = 600
  dir = (/"base/"/)

  time = 10080
  fsrc = "ufs.hafs.cpl.hi.atm."

  ndirs = dimsizes(dir)
    rad2deg = 180.d0/3.14

    dirsrc = RT+dir
    ifile = fsrc + date+ time
      fname = dirsrc+ifile+".nc"
;print("input file "+fname)
      ff = addfile(fname,"r")

;--- subset variables---
      vnames = getfilevarnames (ff)
      nvars = dimsizes(vnames)
      valid = new((/nvars/), logical)

      do ii = 0,nvars-1
        tf = isStrSubset(vnames(ii), "atmImp") .or. isStrSubset(vnames(ii), "atmExp")
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

;--- read coordinate variables ---
      lat1d = ff->atmImp_lat(0,0,:)
      lon1d = ff->atmImp_lon(0,0,:)
      lat1d = lat1d*rad2deg
      lon1d = lon1d*rad2deg
;printVarSummary(lat1d)
;printVarSummary(lon1d)
;print(lat1d(0:10))

;--- reshape variables ---
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

;--- open a new NetCDF file to write to ---
      ffname = dirout+dir+fsrc+date+time+".2d.nc"
      system("rm -f " + ffname)
      fout = addfile(ffname,"c")

;--- create dimensions ---
    dimNames = (/ "grid_xt", "grid_yt" /)
    dimSizes = (/ nax, nay /)
    dimUnlim = (/ False, False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

;--- create lat,lon variable ---
    filevardef(fout, "grid_xt", typeof(lon1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat1d), (/ "grid_yt", "grid_xt" /))

;--- copy grid attributes associated to the file ---
    filevarattdef(fout,  "grid_yt",  lat3d)
    filevarattdef(fout,  "grid_xt",  lon3d)

  do nv = 0,nvars-1
     if (valid(nv)) then
       vname  = vnames(nv)
       vtype  = getfilevartypes(ff,vname)
       vatts  := getfilevaratts(ff,vname)       ; The := is important because these
       dnames := getfilevardimnames(ff,vname)   ; variables may be a different size
       dsizes := getfilevardimsizes(ff,vname)   ; the next time through the loop
       var1d  := ff->$vname$(0,0,:)
       ndims := dimsizes(dnames)
       print(vname+"  "+ndims+"  "+vatts+"  "+dimsizes(vatts))
;--- create new variable ---
       filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
       filevarattdef(fout, vname, var1d)
       delete(var1d)
     end if
   end do
   setfileoption(fout, "DefineMode", False)

   do i = 0,ntile-1
     fout->grid_xt = (/ lon3d(i,:,:) /)
     fout->grid_yt = (/ lat3d(i,:,:) /)
   end do

;**********************************************************
; add variables
;**********************************************************

  do ii = 0,nvars-1
   if(valid(ii)) then
    vname = vnames(ii)
     var1d := ff->$vname$(0,0,:)
     var3d = new((/ ntile, nay, nax /), typeof(var1d), default_fillvalue(typeof(var1d)) )

     do i = 0, ntile-1
      istr = (i*nay*nax)
      iend = istr+nay*nax-1
      var3d(i,:,:) = onedtond(var1d(istr:iend), (/ nay, nax /))
     end do
     ;print(vname+"  "+var3d(0,10,10))

     do i = 0, ntile-1
       ffname = dirout+dir+fsrc+date+time+".2d.nc"
       fout = addfile(ffname, "w")
       fout->$vname$ = (/ var3d(i,:,:) /)
     end do
    delete(var1d)
    delete(var3d)
   end if
  end do
  delete(vnames)
  delete(valid)

exit
end
