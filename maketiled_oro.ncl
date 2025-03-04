;**********************************************************
; write oro_data tiled masks
;**********************************************************
begin

   ;RT="/work2/noaa/stmp/dworthen/stmp/dworthen/dststat/"
   fixdir="/work/noaa/global/glopara/fix/orog/20240917/"
   ;RT="/work2/noaa/stmp/dworthen/stmp/dworthen/negdvice/rest.2d/INPUT/"

    ;ares = "C96"
    ;adim = 96
 ;   ares = C192
 ;   ares = C384

ares = (/"C192"/)
adim = (/192/)
ores = (/"mx025"/)

;ares = (/"C96", "C192", "C384"/)
;adim = (/96, 192, 384/)
;ores = (/"mx025", "mx050", "mx100"/)
ntile=6

  ; retrieve orodata file from fix directory
  do m = 0,dimsizes(ares)-1
   do n = 0,dimsizes(ores)-1
     filename = ares(m)+"."+ores(n)+"_oro_data.tile*nc"
     filelist = systemfunc("ls "+fixdir+ares(m)+"/"+filename)
     print(filelist)
     ofiles = addfiles(filelist,"r")
     ListSetType(ofiles,"join")

     lndfrac = ofiles[:]->land_frac
     lakfrac = ofiles[:]->lake_frac

     total = lndfrac+lakfrac
     lmask = where(total .eq. 1.0, 1.0, 0.0)

;**********************************************************
;
;**********************************************************

    ofile = ares(m)+"."+ores(n)+".orodata.nc"
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "ntiles", "grid_xt", "grid_yt" /)
    dimSizes = (/ ntile, adim(m), adim(m) /)
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

    fout->land_frac = (/lndfrac(:,:,:)/)
    fout->lake_frac = (/lakfrac(:,:,:)/)
    fout->mask = (/lmask(:,:,:)/)

    delete ([/filelist,ofiles,lndfrac,lakfrac,lmask,total/])
   end do
  end do
exit
end
