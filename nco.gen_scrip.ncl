begin
if(1 .eq. 0)then
  ;--- read list of the files ---
  lst = asciiread("list.txt", -1, "string")
  nlst = dimsizes(lst)
  
  ;--- remove commented ones ---
  removed = str_match_ind_regex(lst, "^#")
  if (any(.not. ismissing(removed))) then
    nremoved = dimsizes(removed)
    lst_new = new((/ nlst-nremoved /), "string")
    j = 0
    do i = 0, nlst-1
      if (.not. any(i .eq. removed)) then
        lst_new(j) = lst(i)
        j = j+1
      end if
    end do
    delete(lst)
    lst = lst_new
    delete(lst_new)
    nlst = dimsizes(lst)
  end if
end if

  gridsrc = "/glade/work/worthen/genscrip/"
 ; the output directory for the generated SCRIP file
   dirout = "/glade/work/worthen/genscrip/"

  nlst = 1
 ; the file containing the grid center grid lat,lons
 ; TODO: loop over list of files
  lst = new((/nlst/),"string")
  lst(0) = "aerosoldep_WACCM.ensmean_monthly_hist_1849-2015_0.9x1.25_CMIP6_c180926.nc"
  ;--- loop over files ---
  do i = 0, nlst-1
   print(i+" "+lst(i))

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
    grd_file = addfile(gridsrc+lst(i), "r")

    ;--- list of dimensions ---
    dNames = getfiledimnames(grd_file)
    dSizes = getfiledimsizes(grd_file)
    ndims = dimsizes(dNames)
    print (dNames+"   "+dSizes)
    
    ; retrieve spatial dimensions from named dimensions
    lat_name = ""
    lon_name = ""
    do n = 0,ndims-1
      if (isStrSubset(str_lower(dNames(n)), "lon") .or. \
          isStrSubset(str_lower(dNames(n)), "xc")) then
          lon_name = dNames(n)
          lon = grd_file->$lon_name$
          nx = dimsizes(lon)
      end if
      if (isStrSubset(str_lower(dNames(n)), "lat") .or. \
          isStrSubset(str_lower(dNames(n)), "yc")) then
          lat_name = dNames(n)
          lat = grd_file->$lat_name$
          ny = dimsizes(lat)
      end if
    end do
    print("lon_name = "+lon_name+"; lat_name = "+lat_name)

    if(str_is_blank(lat_name) .or. str_is_blank(lon_name))
     print("aborting: un-recognized spatial dimension name")
     exit()
    end if
    delete([/dNames, dSizes/])

    ;--- list of variables ---
    lst_var = getfilevarnames(grd_file)
    ;print(lst_var)

    msk_name = ""
    mask_present = False
    ;--- check for mask variable
    do j = 0, dimsizes(lst_var)-1
      if (isStrSubset(str_lower(lst_var(j)), "mask")) then
          msk = ndtooned(grd_file->$lst_var$(j))
          mask_present = True
          print("mask found")
      end if
    end do
 
    ;--- get date and create output file ---
    date = systemfunc("date -u '+%d%m%y'")
    dumm = str_split(lst(i), ".")
    if (dimsizes(dumm) .le. 2) then
      ofile = str_sub_str(lst(i), ".nc", ".SCRIP."+date+".nc")
    else
      ofile = str_join(dumm(0:dimsizes(dumm)-3), ".")+".SCRIP."+date+".nc"
    end if
    print(ofile)
    ;ofile = systemfunc("basename "+ofile)
    delete(dumm)
  
    ; create the SCRIP file with the magic command
    ; TODO: generalize for lat_typ (cap, gss etc)
    nckscmd = "ncks -O --rgr skl="+fskl+" --rgr scrip="+ofile+" --rgr latlon="+ny+","+nx+"#lat_typ=cap "+lst(i)+"  out.nc"
    ;print(nckscmd)
    system(nckscmd)

    if(mask_present)then
     ; add the grid_imask array
        gf = addfile(ofile,"w")
     ; retrieve the current mask
     imask = gf->grid_imask
     ; replace and rewrite
     imask := oned_imask
     gf->grid_imask = (/imask/)
     delete(gf)
    end if

    ; retrieve grid values and print
    gf = addfile(ofile,"r")
    loncenter = gf->grid_center_lon
    latcenter = gf->grid_center_lat
    loncorner = gf->grid_corner_lon
    latcorner = gf->grid_corner_lat
   
    print(" SCRIP grid lon centers  "+ min(loncenter)+" : "+max(loncenter))
    print(" SCRIP grid lat centers  "+ min(latcenter)+" : "+max(latcenter))
    print(" SCRIP grid lon corners  "+ min(loncorner)+" : "+max(loncorner))
    print(" SCRIP grid lat corners  "+ min(latcorner)+" : "+max(latcorner))

    ;--- delete temporary variables ---
    delete([/ lst_var, ofile, fskl, gf /])
    if (isdefined("lon")) then
      delete(lon)
    end if
    if (isdefined("lat")) then
      delete(lat)
    end if
    if (isdefined("msk")) then
      delete(msk)
    end if
  end do  ; list of files

end
