begin
  ;--- parameters ---
  res = 384
  ntile = 6
  ;vname = "atmExp_Faxx_taux"
  vname = "atmImp_Faxa_lwdn"
  ifile = "ufs.s2s.c384_t025.jan.jul02.cpl.hi.2016-10-03-10800.nc"

  ;--- open file ---
  nc = addfile(ifile, "r")

  ;--- read variable ---
  var1d = nc->$vname$(0,0,:)

  ;--- read coordinate variables ---
  lat1d = nc->atmImp_lat(0,0,:)
  lon1d = nc->atmImp_lon(0,0,:)

  ;--- reshape variables---
  lon3d = new((/ ntile, res, res /), typeof(lon1d))
  lat3d = new((/ ntile, res, res /), typeof(lat1d))
  var3d = new((/ ntile, res, res /), typeof(var1d))

  do i = 0, ntile-1
    istr = (i*res*res)
    iend = istr+res*res-1
    var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
    lat3d(i,:,:) = onedtond(lat1d(istr:iend), (/ res, res /))
    lon3d(i,:,:) = onedtond(lon1d(istr:iend), (/ res, res /))
  end do

  ;--- write each tile to a file ---
  do i = 0, ntile-1
    ;--- create file ---
    ofile = str_sub_str(ifile, ".nc", ".tile"+sprinti("%d", i)+".nc")
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "grid_xt", "grid_yt" /)
    dimSizes = (/ res, res /)
    dimUnlim = (/ False, False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;--- create variable ---
    filevardef(fout, "grid_xt", typeof(lon1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    ;--- fill with data ---
    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
    fout->$vname$ = (/ var3d(i,:,:) /)
  end do
end
