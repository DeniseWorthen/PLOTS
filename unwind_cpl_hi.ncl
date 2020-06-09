begin
  ;--- parameters ---
 
   time = "00450"
  dirsrc = ""
  ifile = "ufs.s2s.c384_t025.jan.jul02.cold.cpl.hi.2012-01-01-"
  print(ifile)

    res = 384
  ntile = 6

  fname = dirsrc+ifile+time+".nc"
  ff = addfile(fname,"r")

  ;--- read coordinate variables ---
  lat1d = ff->atmImp_lat(0,0,:)
  lon1d = ff->atmImp_lon(0,0,:)

  ;--- reshape variables---
  lon3d = new((/ ntile, res, res /), typeof(lon1d))
  lat3d = new((/ ntile, res, res /), typeof(lat1d))

  do i = 0, ntile-1
   istr = (i*res*res)
   iend = istr+res*res-1
   lat3d(i,:,:) = onedtond(lat1d(istr:iend), (/ res, res /))
   lon3d(i,:,:) = onedtond(lon1d(istr:iend), (/ res, res /))
  end do

  vnames = getfilevarnames (ff)
  nvars = dimsizes(vnames)

  ; pre-define the output file
  do i = 0, ntile-1

    ofile = "cpl.hi-"+time+".tile"+sprinti("%d", i+1)+".nc"
    print(ofile)
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

    ; variables
    do ii = 0,nvars-1
     tf = isStrSubset(vnames(ii), "atmImp") .or. isStrSubset(vnames(ii), "atmExp") 
     if(tf) then
      vname = vnames(ii)
      if(vname .ne. "atmImp_lat" .and. vname .ne. "atmImp_lon" .and. vname .ne. "atmExp_lat" .and. vname .ne. "atmExp_lon")then
      var1d = (/ff->$vname$(0,0,:)/)
      ;printVarSummary(var1d)
      filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
      end if
     end if
    end do
    setfileoption(fout, "DefineMode", False)

    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
  end do 

  ; add variables
  do ii = 0,nvars-1

   tf = isStrSubset(vnames(ii), "atmImp") .or. isStrSubset(vnames(ii), "atmExp")
   if(tf) then
    vname = vnames(ii)
    if(vname .ne. "atmImp_lat" .and. vname .ne. "atmImp_lon" .and. vname .ne. "atmExp_lat" .and. vname .ne. "atmExp_lon")then
     var1d = (/ff->$vname$(0,0,:)/)
     var3d = new((/ ntile, res, res /), typeof(var1d))

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
     end do

     do i = 0, ntile-1
      ofile = "cpl.hi-"+time+".tile"+sprinti("%d", i+1)+".nc"
      fout = addfile(ofile, "w")
      fout->$vname$ = (/ var3d(i,:,:) /)
     end do
    delete(var1d)
    delete(var3d)
    end if
   end if
  end do

exit
end
