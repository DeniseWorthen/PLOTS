; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;**********************************************************
;**********************************************************
begin

     RT = "/glade/scratch/worthen/testland/"
    res = 96
  ntile = 6
   ores = "mx066"
   ares = "C"+res

   wgtsfile = RT+"c96_mx066.nc"
   ocngrd = addfile(RT+"tx0.66v1_SCRIP_190314.nc","r")

  ff = addfile(wgtsfile,"r")
  lat1d = ff->yc_b
  lon1d = ff->xc_b
  lat1d@units = "degrees_N"
  lon1d@units = "degrees_E"
  ;printVarSummary(lat1d)

     col = ff->col
     row = ff->row
       S = ff->S
     n_s = dimsizes(S)
  dst_field = new(dimsizes(lat1d),double,"No_FillValue")
  dst_field = 0.0
  ;print(dimsizes(row))
  ;print(dimsizes(col))
  ;print(dimsizes(S))
  ;print(n_s)
  ;print(dimsizes(dst_field))

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

  i1d = ocngrd->grid_imask
  src_field = new(dimsizes(i1d),double,"No_FillValue")
  src_field = todouble(i1d)
  ;printVarSummary(src_field)
  ;print(dimsizes(src_field))

  print(n_s+"  "+dimsizes(dst_field)+"  "+dimsizes(row))
  print(dimsizes(src_field)+"  "+dimsizes(col))

  do i = 0,n_s-1
  ;do i = 1,n_s
  ;print(i+"  "+row(i)+"  "+col(i))
    ii = row(i)-1
    jj = col(i)
   ;if(jj .eq. 0)then
   ; print(i+"  "+row(i)+"  "+col(i))
   ;end if 
   dst_field(ii) = dst_field(ii) + S(i)*src_field(jj)
  end do
  
  ;dst_field = ESMF_regrid_with_weights(src_field,wgtsfile,False)
  ;printVarSummary(dst_field)
;**********************************************************
; pre-define the output file
;**********************************************************

  do i = 0, ntile-1

    ofile = RT+"dst_field.tile"+sprinti("%d", i+1)+".nc"
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
    filevarattdef(fout,  "grid_yt",  lat3d)
    filevarattdef(fout,  "grid_xt",  lon3d)

    ;--- create variable ---
    ;  vname = "dst_field"
    ;  filevardef(fout, vname, typeof(dst_field), (/ "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    fout->grid_xt = (/ lon3d(i,:,:) /)
    fout->grid_yt = (/ lat3d(i,:,:) /)
  end do

;if(1 .eq. 0)then
;**********************************************************
; add variables
;**********************************************************

     vname = "dst_field"
     var3d = new((/ ntile, res, res /), typeof(dst_field), default_fillvalue(typeof(dst_field)) )

     do i = 0, ntile-1
      istr = (i*res*res)
      iend = istr+res*res-1
      var3d(i,:,:) = onedtond(dst_field(istr:iend), (/ res, res /))
     end do

     do i = 0, ntile-1
      ofile = RT+"dst_field.tile"+sprinti("%d", i+1)+".nc"
       fout = addfile(ofile, "w")
       fout->$vname$ = (/ var3d(i,:,:) /)
     end do

;end if
exit
end
