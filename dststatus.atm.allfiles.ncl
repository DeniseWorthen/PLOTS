;**********************************************************
; re-write CMEPS coupler history fields for Atm
; imports, exports and masks to tiled files for
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

   ; map types which can generate a dststatus file
   maptypes = (/"bilnr",      "consf",       "consd",       "patch",      \
                "nstod",      "nstod_consd", "stod_consf",  "patch_uv3d", \
                "bilnr_uv3d", "fillv_bilnr", "bilnr_nstod", "consf_aofrac"/)
   nmaps = dimsizes(maptypes)
   ; sources for atm as destination
   ;sources = (/"ocn", "ice", "wav"/)
   sources = (/"ocn", "ice"/)
   nsrc = dimsizes(sources)
   maxfiles = nmaps*nsrc

   nl = str_get_nl()
   nflags = 9
   ntile = 6
    res = 96
 ;   res = 192
 ;   res = 384

  ;   RT = "/glade/scratch/worthen/FV3_RT/bilin/"
    RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/bilin/"
    dirs = (/"base/"/)
    date = "2021-03-22-"
   vname = "dststatus"
   ndirs = dimsizes(dirs)

   ; list all possible files in all directories
   allfilelist = NewList("fifo")
   ; a list of the dststatus files
   do nd = 0,dimsizes(dirs)-1
    do nm = 0,dimsizes(maptypes)-1
     do ns = 0,dimsizes(sources)-1
       fname = RT+dirs(nd)+vname+"."+sources(ns)+".atm."+maptypes(nm)+".nc"
       print(fname)
       if (fileexists(fname)) then
        ListPush(allfilelist,fname)
       end if
     end do
    end do
   end do
   nfiles = ListCount(allfilelist)
   print("maximum possible files = "+nfiles)
   ;print(allfilelist)
   ;do nf = 0,nfiles-1
    ;printVarSummary(allfilelist[nf])
   ; fname = ListPop(allfilelist)
   ; print(fname)
   ;end do

   ;filelists = systemfunc("ls "+dirs+vname++date+"*.nc")
   ;print(filelist)

   ;fsrc = vname+".wav.atm.nstod_consf_2"
   ;fsrc = vname+".ocn.atm.consd"
   fsrc = vname+".ocn.atm.consf"
   ;fsrc = vname+".wav.atm.bilnr_nstod"
   ;vname = "meshmask"
   ;fsrc = "mask.ocn.atm.consf"

;**********************************************************
; retrieve lat/lon from first coupler history file
;**********************************************************

  fname = RT+dirs(0)+"ufs.cpld.cpl.hi.atm."+date+"22320.nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  ;--- query the number of dims in case the history file is written
  ;    on the tiles
  ndims = dimsizes(dimsizes(ff->atmImp_lat))
  print("file containing dimensions contains ndims = "+ndims)

  ;--- read coordinate variables ---
  if(ndims .eq. 4)then
    lat3d = ff->atmImp_lat(0,:,:,:)
    lon3d = ff->atmImp_lon(0,:,:,:)
    lat3d@units = "degrees_N"
    lon3d@units = "degrees_E"
  else
    lat1d = ff->atmImp_lat(0,0,:)
    lon1d = ff->atmImp_lon(0,0,:)
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
  end if

  delete(ff)
  delete(fname)

;**********************************************************
;
;**********************************************************

  fname = ListPop(allfilelist)
  print("input file "+fname)
  if (fileexists(fname)) then

if(1.eq.0)then
    ;what does this do?
    print(" "+nl)
    ; get the index seq to resort
    doffile = dirsrc+"dof.atm.nc"
    doff = addfile(doffile,"r")
    dof = doff->dof(:)

    ff = addfile(fname,"r")

    var1d = ff->$vname$(:)
    ;printVarSummary(var1d)

     total = 0
    do i = 0,nflags-1
     total = total+dststatus_counts(var1d,i)
    end do
     print("total count of all dststatus types = "+total+" size of var1d = "+dimsizes(var1d))

    ip = dim_pqsort(dof,1)
    var1d_sort=var1d
    var1d_sort=var1d(ip)
end if

  end if
if(1 .eq. 0)then
;**********************************************************
; pre-define the output file
;**********************************************************

  do i = 0, ntile-1

    ofile = dirsrc+fsrc+".tile"+sprinti("%d", i+1)+".nc"
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "grid_xt", "grid_yt" /)
    dimSizes = (/ res, res /)
    dimUnlim = (/ False, False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    if(ndims .ne. 4) then
    filevardef(fout, "grid_xt", typeof(lon1d), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat1d), (/ "grid_yt", "grid_xt" /))
    else
    ;--- create lat,lon variable ---
    filevardef(fout, "grid_xt", typeof(lon3d(i,:,:)), (/ "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat3d(i,:,:)), (/ "grid_yt", "grid_xt" /))
    end if

    ; Copy attributes associated with each variable to the file
    ;filevarattdef(fout,  "grid_yt",  lat3d)
    ;filevarattdef(fout,  "grid_xt",  lon3d)

    ;--- create variable ---

     filevardef(fout, vname, typeof(var1d), (/ "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
  end do

;**********************************************************
; add variables
;**********************************************************

     var3d = new((/ ntile, res, res /), typeof(var1d), default_fillvalue(typeof(var1d)) )
     ;printVarSummary(var3d)

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      ;var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
      var3d(i,:,:) = onedtond(var1d_sort(istr:iend), (/ res, res /))
      ;print("tile number = "+i+" "+istr+" "+iend)
     end do

     do i = 0, ntile-1
      ofile = dirsrc+fsrc+".tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       ;fout->$vname$ = (/ var3d(i,:,:) /)
       fout->$vname$ = var3d(i,:,:)
       delete(fout)
     end do
    delete(var1d)
    delete(var3d)

end if
exit
end
