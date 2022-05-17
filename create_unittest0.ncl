begin

  dirsrc="/scratch2/NCEPDEV/climate/Denise.Worthen/soca/test/Data/72x35x25/INPUT/"
  fname = "ocean_hgrid.nc"
    sgf = addfile(dirsrc+fname,"r")

  lats = tofloat(sgf->y)
  lons = tofloat(sgf->x)
    dx = tofloat(sgf->dx)
    dy = tofloat(sgf->dy)

  dims = dimsizes(lats)
    ny = dims(0)
    nx = dims(1)
  print(nx+"  "+ny)

  xlats = new((/ny,32/),float)
  xlons = new((/ny,32/),float)
    ddx = new((/ny,32/),float)
    ddy = new((/ny,32/),float)

  xlats = -99.0
    iii = -1

 ;do ii = 0,nx-1
 ; print(ii+"  "+tofloat(lats(ny-1,ii)))
 ;end do

  istop=71
  do ii = 1,nx-1,5
   if(ii .le. istop) then
      iii = iii+1
      xlats(:,iii) = lats(:,ii)
      print(ii+"   "+iii+"   "+xlats(ny-1,iii))
   end if
  end do
  iii = iii+1
  ii=istop+1
  xlats(:,iii) = lats(:,ii)
 
  do ii = ii+1,nx-1,5
      iii = iii+1
      xlats(:,iii) = lats(:,ii)
      ;print(ii+"   "+iii+"   "+xlats(ny-1,iii))
  end do

  iii = iii+1
  xlats(:,iii) = lats(:,nx-1)

  do ii = 0,32-1
   print(ii+"  "+xlats(ny-1,ii))
  end do
  print("end of try 1")
  print("  ")
  ;------------------------------------

  xlats = -99.0
  iii=0
  istop=71
  do ii = 1,nx-1,7
   if(ii .le. istop) then
      iii = iii+1
      xlats(:,iii) = lats(:,ii)
   ;   print(ii+"   "+iii+"   "+xlats(ny-1,iii))
   end if
  end do
  iii = iii+1
  ii=istop+1
  xlats(:,iii) = lats(:,ii)
  ;print(ii+"   "+iii+"   "+xlats(ny-1,iii))

  do ii = ii+1,nx-1,7
      iii = iii+1
      xlats(:,iii) = lats(:,ii)
  ;    print(ii+"   "+iii+"   "+xlats(ny-1,iii))
  end do

  iii = iii+1
  xlats(:,iii) = lats(:,nx-1)

  do ii = 0,25-1
   print(ii+"  "+xlats(ny-1,ii))
  end do

  print("end of try 2")
  print("  ")

  ;------------------------------------

  do jj = 0,ny-1
  ; print(jj+"  "+lats(jj,36))
  end do

  jjj = -1
  do jj = 10,ny,5
   jjj = jjj+1
   print(jj+"   "+jjj+"  "+lats(jj,36))
  end do
end
