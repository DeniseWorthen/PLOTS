;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu
;**********************************************************
begin

     RT = "/glade/scratch/worthen/FV3_RT/"

   date = "2016-10-03-0"

     dir = "test_dev/cpld_controlfrac_test/"
    ; dir = "cpld_controlfrac"+cres+"_prod/"
    ; dir = "cpld_control"+cres+"_prod/"
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
  lat2d = fcpl[0]->iceImp_lat(0,:,:)
  lon2d = fcpl[0]->iceImp_lon(0,:,:)
  lat2d@units = "degrees_N"
  lon2d@units = "degrees_E"
  ;printVarSummary(lat2d)
  ;printVarSummary(lon2d)

  ;--- read mask variable ---
  imask = fcpl[0]->iceImp_Si_imask(0,:,:)
  omask = fcpl[0]->ocnImp_So_omask(0,:,:)

  dims = dimsizes(imask)
    ny = dims(0)
    nx = dims(1)

;**********************************************************
; subset variables
;**********************************************************

  vnames = getfilevarnames (fcpl[0])
  nvars = dimsizes(vnames)
  valid = new((/nvars/), logical)

  do ii = 0,nvars-1
   tf = isStrSubset(vnames(ii), "ocnImp") .or. \
        isStrSubset(vnames(ii), "ocnExp") .or. \
        isStrSubset(vnames(ii), "iceImp") .or. \
        isStrSubset(vnames(ii), "iceExp")
    valid(ii) = tf
  end do
  do ii = 0,nvars-1
   vname = vnames(ii)
   if(vname .eq. "ocnImp_lat"       .or. \
      vname .eq. "ocnImp_lon"       .or. \
      vname .eq. "Med_frac_ocn_lat" .or. \
      vname .eq. "Med_frac_ocn_lon" .or. \
      vname .eq. "ocnExp_lat"       .or. \
      vname .eq. "ocnExp_lon")then
    valid(ii) = False
   end if
  end do
  do ii = 0,nvars-1
   vname = vnames(ii)
   if(vname .eq. "iceImp_lat"       .or. \
      vname .eq. "iceImp_lon"       .or. \
      vname .eq. "Med_frac_ice_lat" .or. \
      vname .eq. "Med_frac_ice_lon" .or. \
      vname .eq. "iceExp_lat"       .or. \
      vname .eq. "iceExp_lon")then
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


    ofile = dirsrc+fsrc+"ice.ocn.nc"
    print("output file "+ofile)
    if(isfilepresent(ofile))then
     system("rm -f "+ofile)
     print("rm "+ofile)
    end if
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "time",  "grid_yt", "grid_xt" /)
    dimSizes = (/     -1,         ny,       nx  /)
    dimUnlim = (/   True,      False,     False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;--- create lat,lon variable ---
    filevardef(fout, "grid_xt", typeof(lon2d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat2d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout,    "time", typeof(time),  getvardims(time))
    filevarattdef(fout, "time", time)

    ;--- create variable ---
    do ii = 0,nvars-1
     if(valid(ii)) then
      vname = vnames(ii)
      ;printVarSummary(fcpl[:]->$vname$(:,:,:))
      var2d = fcpl[:]->$vname$(:,:,:)
      ;printVarSummary(var2d)
      filevardef(fout, vname, typeof(var2d), (/ "time", "grid_yt", "grid_xt" /))
      filevarattdef(fout, vname, var2d)
      delete(var2d)
     end if
    end do
    setfileoption(fout, "DefineMode", False)

    ; write the dimensions to the file
    fout->grid_xt = (/ lon2d(:,:) /)
    fout->grid_yt = (/ lat2d(:,:) /)
    fout->time    = (/ time /)

;**********************************************************
; add variables
;**********************************************************

  do ii = 0,nvars-1
   if(valid(ii)) then
    vname = vnames(ii)
     var2d = fcpl[:]->$vname$(:,:,:)

     fout->$vname$ = (/ var2d(:,:,:) /)
     delete(var2d)
   end if
  end do
  delete(fout)
  delete(vnames)
  delete(valid)

exit
end
