begin
  ;-------------------------------------------------------------------------------
  ; to run from your own directory, set gridsrc and dirout to either "./" or
  ; the full path name. I set it up this way so I can read from your directory
  ; but write to my own.
  ; there are two files it can read at this point, the original aerosol and the
  ; new Solr file. The srcfile and srcgrdtype have to both be set correctly
  ;-------------------------------------------------------------------------------

  gridsrc = "~mvertens/src/meshes/"
  ;gridsrc = "/glade/work/worthen/genscrip/"
  ;the output directory for the generated SCRIP file
   dirout = "/glade/work/worthen/genscrip/"

  ;srcfile = "aerosoldep_WACCM.ensmean_monthly_hist_1849-2015_0.9x1.25_CMIP6_c180926.nc"
  ;srcgrdtype = "cap"

  srcfile = "clmforc.GSWP3.c2011.0.5x0.5.Solr.1991-01.nc"
  srcgrdtype = "uni"

    ; temporary name
    fskl = "temp.fskl.nc"
    ;Remove the files if exist
    if (isfilepresent(fskl)) then
      system("rm " + fskl)
    end if
    if (isfilepresent("out.nc")) then
      system("rm out.nc")
    end if

    ;--- add the source grid file ---
    grd_file = addfile(gridsrc+srcfile, "r")
    ;print(grd_file)

    ;--- list of dimensions ---
    dNames = getfiledimnames(grd_file)
    dSizes = getfiledimsizes(grd_file)
    ndims = dimsizes(dNames)
    print (dNames+"   "+dSizes)
    
    ; retrieve spatial dimensions from named dimensions
    latdim = ""
    londim = ""
    do n = 0,ndims-1
      if (isStrSubset(str_lower(dNames(n)), "lon") .or. \
          isStrSubset(str_lower(dNames(n)), "xc")) then
          londim = dSizes(n)
          nx = londim
      end if
     if (isStrSubset(str_lower(dNames(n)), "lat") .or. \
          isStrSubset(str_lower(dNames(n)), "yc")) then
          latdim = dSizes(n)
          ny = latdim
      end if
    end do
    print("londim = "+londim+"; latdim = "+latdim)
    delete([/dNames, dSizes/])

    ;--- list of variables ---
    varNames = getfilevarnames(grd_file)
    ;print(varNames)

    lon_name = ""
    lat_name = ""
    msk_name = ""
    mask_present = False

    ;--- check for mask variable and find lat and lon name
    do j = 0, dimsizes(varNames)-1
      vname = varNames(j)
      if (isStrSubset(str_lower(vname), "mask")) then
          msk = ndtooned(grd_file->$vname$)
          mask_present = True
          print("mask found")
      end if
      if (isStrSubset(str_lower(vname), "lon") .or. \
          isStrSubset(str_lower(str_get_cols(vname,0,2)), "lon") .or. \
          isStrSubset(str_lower(vname), "xc")) then
          lon_name = vname
      end if
      if (isStrSubset(str_lower(vname), "lat") .or. \
          isStrSubset(str_lower(str_get_cols(vname,0,2)), "lat") .or. \
          isStrSubset(str_lower(vname), "yc")) then
          lat_name = vname
      end if
    end do
    print("lon_name = "+lon_name+"; lat_name = "+lat_name)

    if(str_is_blank(lat_name) .or. str_is_blank(lon_name))
      print("aborting: un-recognized spatial dimension name")
     exit()
    end if

    ; retrieve lat and lon values
    ndims = dimsizes(dimsizes(grd_file->$lon_name$))
    ;print(ndims)
    if(ndims .gt. 1)then
     lon = ndtooned(grd_file->$lon_name$)
     lat = ndtooned(grd_file->$lat_name$)
    else
     lon = grd_file->$lon_name$
     lat = grd_file->$lat_name$
    end if
    print(dimsizes(lon))
    print(dimsizes(lat))
    printVarSummary(lat)
    printVarSummary(lon)

    ;--- get date and create output file ---
    date = systemfunc("date -u '+%d%m%y'")
    dumm = str_split(srcfile, ".")
    if (dimsizes(dumm) .le. 2) then
      ofile = str_sub_str(srcfile, ".nc", ".SCRIP."+date+".nc")
    else
      ofile = str_join(dumm(0:dimsizes(dumm)-3), ".")+".SCRIP."+date+".nc"
    end if
    print("ofile name = "+ofile)
    ;ofile = systemfunc("basename "+ofile)
    delete(dumm)
    print("source name = "+gridsrc+srcfile)

    ; create the SCRIP file with the magic command
    nckscmd = "ncks -O --rgr skl="+fskl+" --rgr scrip="+dirout+ofile+" --rgr latlon="+ny+","+nx+"#lat_typ="+srcgrdtype+" "+gridsrc+srcfile+"  out.nc"
    print(nckscmd)
    system(nckscmd)

    if(mask_present)then
     ; add the grid_imask array
        gf = addfile(dirout+ofile,"w")
     ; retrieve the current mask
     imask = gf->grid_imask
     ; replace and rewrite
     imask := oned_imask
     gf->grid_imask = (/imask/)
     delete(gf)
    end if

    ; retrieve grid values and print
    gf = addfile(dirout+ofile,"r")
    loncenter = gf->grid_center_lon
    latcenter = gf->grid_center_lat
    loncorner = gf->grid_corner_lon
    latcorner = gf->grid_corner_lat
   
    print(" SCRIP grid lon centers  "+ min(loncenter)+" : "+max(loncenter))
    print(" SCRIP grid lat centers  "+ min(latcenter)+" : "+max(latcenter))
    print(" SCRIP grid lon corners  "+ min(loncorner)+" : "+max(loncorner))
    print(" SCRIP grid lat corners  "+ min(latcorner)+" : "+max(latcorner))

    ;--- delete temporary variables ---
    delete([/ varNames, ofile, fskl, gf /])
    if (isdefined("lon")) then
      delete(lon)
    end if
    if (isdefined("lat")) then
      delete(lat)
    end if
    if (isdefined("msk")) then
      delete(msk)
    end if

end
