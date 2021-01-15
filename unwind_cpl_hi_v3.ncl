;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

     RT = "/glade/scratch/worthen/FV3_RT/rt_28678/"

   date = "2016-10-03-"
  ntile = 6

    res = 96
   cres = ""
     dt = 900

  ;  res = 192
  ; cres = "_c192"
  ;   dt = 900

 ;   res = 384
 ;  cres = "_c384"
 ;    dt = 450

     dir = "cpld_controlfrac"+cres+"_prod/"
    fsrc = "ufs.cpld.cpl.hi."
  dirsrc = RT+dir
  
  filelist = systemfunc("ls "+dirsrc+fsrc+date+"*.nc")
      fcpl = addfiles(filelist,"r")
       nts = dimsizes(filelist)
  print(filelist)

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
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "time", "grid_xt", "grid_yt" /)
    dimSizes = (/     -1,       res,       res /)
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
     var3d = new((/ ntile, nts, res, res /), typeof(var1d), default_fillvalue(typeof(var1d)) )

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      var3d(i,:,:,:) = onedtond(var1d(:,istr:iend), (/nts, res, res /))
     end do

     do i = 0, ntile-1
      ofile = dirsrc+fsrc+"tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       fout->$vname$ = (/ var3d(i,:,:,:) /)
     end do
    delete(var1d)
    delete(var3d)
   end if
  end do
  delete(vnames)
  delete(valid)

exit
end