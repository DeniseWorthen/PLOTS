;**********************************************************
; write oro_data tiled masks
;**********************************************************
begin

   RT="/work2/noaa/stmp/dworthen/stmp/dworthen/dststat/"

    atmres = 96
 ;   atmres = 192
 ;   atmres = 384

   dirs = (/"test/"/)
  ntile = 6

  ; retrieve orodata file from INPUT directory for masking
  filelist = systemfunc("ls "+RT+dirs(0)+"INPUT/oro_data.tile*.nc")
  print(filelist)
  ofiles = addfiles(filelist,"r")
  ListSetType(ofiles,"join")

  lndfrac = ofiles[:]->land_frac
  lakfrac = ofiles[:]->lake_frac
  ;total = la
  ;total = 0.0
  total = lndfrac+lakfrac
  lmask = where(total .eq. 1.0, 1.0, 0.0)

;**********************************************************
;
;**********************************************************

    ofile = RT+dirs(0)+"orodata.nc"
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "ntiles", "grid_xt", "grid_yt" /)
    dimSizes = (/ ntile, atmres, atmres /)
    dimUnlim = (/ False,  False,  False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    ;vname = "land_frac"
    filevardef(fout, "grid_xt", typeof(lndfrac), (/"ntiles", "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lndfrac), (/"ntiles", "grid_yt", "grid_xt" /))

    ;--- create variable ---
    filevardef(fout, "land_frac", typeof(lndfrac), (/"ntiles", "grid_yt", "grid_xt" /))
    filevardef(fout, "lake_frac", typeof(lndfrac), (/"ntiles", "grid_yt", "grid_xt" /))
    filevardef(fout,      "mask", typeof(lndfrac), (/"ntiles", "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    ;--- write grid variables ---
    ;fout->grid_xt = (/ lon3d(:,:,:) /)
    ;fout->grid_yt = (/ lat3d(:,:,:) /)

    fout->land_frac = (/lndfrac(:,:,:)/)
    fout->lake_frac = (/lakfrac(:,:,:)/)
    fout->mask = (/lmask(:,:,:)/)
exit
end
