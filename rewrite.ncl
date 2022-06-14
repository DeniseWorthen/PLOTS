begin

  dirsrc = "/glade/work/mvertens/ctsm.toolchain/tools/mksurfdata_esmf/run/"
  fname = "surfdata_ne120np4_hist_78pfts_CMIP6_2000_c220219.nc"
  print(dirsrc+fname)

  ; fake!
  nx = 388801
  ny = 2

  f     = addfile(dirsrc+fname,"r")
  lat1d = f->LATIXY          ; Pull off lat/lon variable
  lon1d = f->LONGXY

  ; reshape lat and lon
  lon2d = new((/ ny, nx /), typeof(lon1d))
  lat2d = new((/ ny, nx /), typeof(lat1d))

  lon2d = onedtond(lon1d, (/ny,nx/))
  lat2d = onedtond(lat1d, (/ny,nx/))
  ;printVarSummary(lat2d)
  ;printVarSummary(lon2d)

  ; pre-define new file
  setfileoption("nc","preFill",False)
  setfileoption("nc","defineMode",True)
  setfileoption("nc","Format","NetCDF4")

  ;---Open a new NetCDF file to write to
  ffname = "test.nc"
  system("rm -f " + ffname)
  fout = addfile(ffname,"c")

  dimNames = (/"time", "nlevsoi", "nlevurb",  "numurbl", "numrad", "nglcec", "nglcecp1", \
             "lsmpft", "natpft", "cft",    "nlat",     "nlon"/)
  dimSizes = (/    12,        10,         5,          3,        2,       10,         11, \
                   79,       15,    64,        ny,        nx/)
  dimUnlim = (/  True, False, False, False, False, False, False, False, False, False, False, False/)

  filedimdef(fout, dimNames, dimSizes, dimUnlim)

  vnames = getfilevarnames(f)
  nvars = dimsizes(vnames)

  ; identify dimension variables
  valid = new((/nvars/), logical)
  valid = True
  do nv = 0,nvars-1
     vname = vnames(nv)
     if (vname .eq. "natpft" .or. vname .eq. "cft" .or. vname .eq. "time")then
        valid(nv) = False
     end if
  end do
  do nv = 0,nvars-1
     print(nv+" "+vnames(nv)+"  "+valid(nv))
  end do

  do nv = 0,nvars-1
     if (valid(nv)) then
        vname  = vnames(nv)
   
        vtype  = getfilevartypes(f,vnames(nv))
        vatts  := getfilevaratts(f,vnames(nv))       ; The := is important because these
        dnames := getfilevardimnames(f,vnames(nv))   ; variables may be a different size
        dsizes := getfilevardimsizes(f,vnames(nv))   ; the next time through the loop
           var := f->$vname$
         ndims := dimsizes(dnames)
        print(vname+"  "+ndims+"  "+vatts)

        ; create added dimension for reshaping the gridcell dimension
        newdims = new((/ndims+1/), integer)
        newdnms = new((/ndims+1/),  string)
        if (ndims .eq. 1) then
          newdims(0) = ny
          newdims(1) = nx
          newdnms(0) = "nlat"
          newdnms(1) = "nlon"
          newvar = new((/ newdims /), typeof(var))
          filevardef(fout, vname, typeof(var), (/ newdnms(0), newdnms(1) /))
        else if (ndims .eq. 2) then
          newdims(0) = dsizes(0)
          newdims(1) = ny
          newdims(2) = nx
          newdnms(0) = dnames(0)
          newdnms(1) = "nlat"
          newdnms(2) = "nlon"
          newvar = new((/ newdims /), typeof(var))
          filevardef(fout, vname, typeof(var), (/ newdnms(0), newdnms(1), newdnms(2) /))
        else if (ndims .eq. 3) then
          newdims(0) = dsizes(0)
          newdims(1) = dsizes(1)
          newdims(2) = ny
          newdims(3) = nx
          newdnms(0) = dnames(0)
          newdnms(1) = dnames(1)
          newdnms(2) = "nlat"
          newdnms(3) = "nlon"
          newvar = new((/ newdims /), typeof(var))
          filevardef(fout, vname, typeof(var), (/ newdnms(0), newdnms(1), newdnms(2), newdnms(3)/))
        end if
        end if
        end if
        ;filevarattdef(fout, vname, vatts)

        ;newvar = new((/ newdims /), typeof(var))
        ;filevardef(fout, vname, typeof(var), (/ newdnms /))

        ;if (ndims .eq. 1)then
        ;  filevardef(fout, vname, typeof(var), (/ "time", "longxy", "latixy" /))
        ;else if (dimsizes(dnames) .eq. 2) then
        ;end if
        delete([/newdims,newdnms,newvar/])
     end if
  end do
  
  setfileoption(fout, "DefineMode", False)


if(1 .eq. 0)then
  lat1d = f->LATIXY          ; Pull off lat/lon variable
  lon1d = f->LONGXY
  ;var  = f->FMAX            ; Read some data
  var = f->EM_PERROAD(0,:)
  ;printVarSummary(var)

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,"test")              ; send graphics to X11 window

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'


  res@sfXArray            = lon1d        ; Required to tell NCL where to
  res@sfYArray            = lat1d        ; overlay data on globe.

  res@cnFillOn            = True         ; Turn on contour fill
  res@cnFillMode          = "AreaFill"   ; Style of fill. You can also
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels

  contour = gsn_csm_contour(wks,var,res)     ; Draw a contour plot.
  draw(contour)
  frame(wks)
end if
end

