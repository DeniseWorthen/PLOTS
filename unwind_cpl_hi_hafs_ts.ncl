;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

     RT = "/glade/scratch/worthen/FV3_RT/wave_hafs/"
   date = "2019-08-29-"

  ntile = 1
  nax = 720
  nay = 600

     dt = 360
   dirs = (/"test/"/)
   fsrc = "ufs.hafs.cpl.hi.atm."
  ndirs = dimsizes(dirs)
  dirsrc = RT+dirs(0)

  nfbeg = 0
  nfend = 3*12 - 1
  nfiles= (nfend-nfbeg)
  ;filelist = systemfunc("ls "+dirsrc+fsrc+date+"0*.nc")
  filelist = systemfunc("ls "+dirsrc+fsrc+date+"*.nc")
  print(filelist)
      fcpl = addfiles(filelist(nfbeg:nfend),"r")
       nts = dimsizes(filelist(nfbeg:nfend))
  print(filelist(nfbeg:nfend))

;if(1.eq.0)then
  ;--- read time variable ---
          time = fcpl[:]->time
     timeUnits = fcpl[0]->time@units
  timeCalendar = fcpl[0]->time@calendar
  ;printVarSummary(time)

  ;--- read coordinate variables ---
  lat1d = fcpl[0]->atmImp_lat(0,0,:)
  lon1d = fcpl[0]->atmImp_lon(0,0,:)
  lat1d@units = "degrees_N"
  lon1d@units = "degrees_E"
  ;printVarSummary(lat1d)
  ;printVarSummary(lon1d)

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
   ;printVarSummary(lat3d)
   ;printVarSummary(lon3d)

;**********************************************************
; subset variables
;**********************************************************

  vnames = getfilevarnames (fcpl[0])
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

    ofile = dirsrc+fsrc+"tile"+sprinti("%d", i+1)+".nc"
    print("output file "+ofile)
    if(isfilepresent(ofile))then
     system("rm -f "+ofile)
    end if
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "time", "grid_yt", "grid_xt" /)
    dimSizes = (/     -1,       nay,       nax /)
    dimUnlim = (/   True,     False,     False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;--- create lat,lon variable ---
    filevardef(fout, "grid_xt", typeof(lon1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout,  "time", typeof(time),  getvardims(time))

    ; Copy attributes associated with each variable to the file
    filevarattdef(fout,     "time",   time)
    ;filevarattdef(fout,  "grid_yt",  lat3d)
    ;filevarattdef(fout,  "grid_xt",  lon3d)

    ;--- create variable ---
    do ii = 0,nvars-1
     if(valid(ii)) then
      vname = vnames(ii)
      ;printVarSummary(fcpl[:]->$vname$(:,0,:))
      var1d = (/fcpl[:]->$vname$(:,0,:)/)
      ;printVarSummary(var1d)
      filevardef(fout, vname, typeof(var1d), (/ "time", "grid_yt", "grid_xt" /))
     end if
    end do
    setfileoption(fout, "DefineMode", False)

    ; write the dimensions to the file
    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
    fout->time    = (/ time /)
  end do

;**********************************************************
; add variables
;**********************************************************

  do ii = 0,nvars-1
   if(valid(ii)) then
    vname = vnames(ii)
     var1d = (/fcpl[:]->$vname$(:,0,:)/)
     var3d = new((/ ntile, nts, nay, nax /), typeof(var1d), default_fillvalue(typeof(var1d)) )

     do i = 0, ntile-1
      istr = (i*nay*nax)
      iend = istr+nay*nax-1
      var3d(i,:,:,:) = onedtond(var1d(:,istr:iend), (/nts, nay, nax /))
     end do

     do i = 0, ntile-1
      ofile = dirsrc+fsrc+"tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       fout->$vname$ = (/ var3d(i,:,:,:) /)
     end do
     print("done with variable "+vname)

    delete(var1d)
    delete(var3d)
   end if
  end do
  delete(fout)
  delete(vnames)
  delete(valid)
;end if
;**********************************************************
;
;atmImp_Sa_ofrac = mask(fout->atmImp_Sa_ofrac, fout->atmImp_Sa_ofrac .lt. 1.0, True)
;atmExp_Si_ifrac = fout->atmExp_Si_ifrac
;**********************************************************

     ; tile 3
   ;     i = 2
   ; ofile = dirsrc+fsrc+"tile"+sprinti("%d", i+1)+".nc"
   ;  fout = addfile(ofile, "r")

   ;atmExp_Si_ifrac = mask(fout->atmExp_Si_ifrac, fout->atmExp_Si_ifrac .gt. 0.0, True)
   ;atmImp_Sa_ofrac = 1.0 - fout->atmImp_Sa_ofrac
   ;atmImp_Sa_ofrac = mask(atmImp_Sa_ofrac, atmImp_Sa_ofrac .gt. 0.0, True)
   ;print("minval Si_ifrac "+dim_min_n(atmExp_Si_ifrac, (/1,2/))+"  max val Sa_ofrac "+dim_min_n(atmImp_Sa_ofrac, (/1,2/)))

   ;med_frac_atm_ofrac = mask(fout->Med_frac_atm_ofrac, fout->Med_frac_atm_ofrac .gt. 0.0, True)
   ;atmImp_Sa_ofrac = mask(fout->atmImp_Sa_ofrac, fout->atmImp_Sa_ofrac .gt. 0.0, True)
   ;print("minval med_frac_atm_ofrac "+dim_min_n(med_frac_atm_ofrac, (/1,2/))+"  min val Sa_ofrac "+dim_min_n(atmImp_Sa_ofrac, (/1,2/)))
   ;med_frac_atm_ofrac = mask(fout->Med_frac_atm_ofrac, fout->Med_frac_atm_ofrac .gt. 0.0, True)
   ;med_frac_atm_onorm = mask(fout->Med_frac_atm_onorm, fout->Med_frac_atm_onorm .gt. 0.0, True)
   ;print("minval med_frac_atm_ofrac "+dim_min_n(med_frac_atm_ofrac, (/1,2/))+"  min val Sa_ofrac "+dim_min_n(med_frac_atm_onorm, (/1,2/)))

exit
end