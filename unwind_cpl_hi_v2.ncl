;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin
     RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/FV3_RT/rt_166074/"
    res = 96
    ;res = 384
  ntile = 6

  ; dirs = (/"test/","test_300/"/)
  ; dirs = (/"test3_300/"/)
   ;dirs = (/"cpld_debugfrac_dt_na/"/)
   dirs = (/"test/"/)
  ;times = (/"2013-04-01-00450", "2013-04-01-00900"/)
  times = (/"2016-10-03-00900"/)
  ;times = (/"2011-05-01-00225"/)
  ;times = (/"2011-05-01-00300"/)
   ;fsrc = "ufs.s2s.cold.cpl.hi."
   ;fsrc = "ufs.s2s.cpl.r."
   fsrc = "ufs.cpld.cpl.hi."
  ndirs = dimsizes(dirs)
    nts = dimsizes(times)

do nd = 0,ndirs-1
 do nt = 0,nts-1
    time = times(nt)
  dirsrc = RT+dirs(nd)
  ;dirout = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  dirout = dirsrc
   ifile = fsrc

  fname = dirsrc+ifile+time+".nc"
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
   ;print(ii+" "+vnames(ii)+"  "+valid(ii))
  end do

;**********************************************************
; pre-define the output file
;**********************************************************

  do i = 0, ntile-1

    ;ofile = dirsrc+fsrc+time+".tile"+sprinti("%d", i+1)+".nc"
    ofile = dirout+fsrc+time+".tile"+sprinti("%d", i+1)+".nc"
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
      ;ofile = dirsrc+fsrc+time+".tile"+sprinti("%d", i+1)+".nc"
      ofile = dirout+fsrc+time+".tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       fout->$vname$ = (/ var3d(i,:,:) /)
     end do
    delete(var1d)
    delete(var3d)
   end if
  end do

  do i = 0, ntile-1
      ofile = dirout+fsrc+time+".tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "r")
       lats = fout->grid_yt
       lons = fout->grid_xt
       zbot = fout->atmImp_Sa_z
      ofrac = fout->Med_frac_atm_ofrac
      ;printVarSummary(zbot)

      ;zbot = mask(zbot,(zbot .lt. 0.0 .and. ofrac .gt. 0.0), True)
      zbot = mask(zbot,(zbot .lt. 0.0 ), True)
      zbot1 = ndtooned(zbot)
      ;printVarSummary(zbot1)
      print(ofile+"  "+num(.not.ismissing(zbot1)))
      nvals = num(.not.ismissing(zbot1))

      if(nvals .gt. 0)then
       ijlocs = ind_resolve(ind(zbot1), (/res,res/) )
       ;print(lats(ijlocs(:,0),ijlocs(:,1)) +"  "+lons(ijlocs(:,0),ijlocs(:,1)) )

       do n = 0,nvals-1
        nn = n+1
        jj = ijlocs(n,0)+1
        ii = ijlocs(n,1)+1
        print("n = "+nn+" i,j "+ii+"  "+jj+"  lat,lon = "+lats(jj-1,ii-1)+", "+lons(jj-1,ii-1)+"  zbot = "+zbot(jj-1,ii-1))
       end do
       delete(ijlocs)
      end if
  end do

end do  ; nts
end do  ; ndirs

exit
end
