begin
function create_sgdata(data:numeric,nx:numeric,ny:numeric)
begin
 sgdata = new((/ny,nx/),float,default_fillvalue("float"))

  iii=0
  istop=71
  do ii = 1,nx-1,7
   if(ii .le. istop) then
      iii = iii+1
      sgdata(:,iii) = data(:,ii)
   end if
  end do
  iii = iii+1
  ii=istop+1
  sgdata(:,iii) = data(:,ii)

  do ii = ii+1,nx-1,7
      iii = iii+1
      sgdata(:,iii) = data(:,ii)
  end do
  iii = iii+1
  sgdata(:,iii) = data(:,nx-1)

  jjj = -1
  do jj = 10,ny,5
   jjj = jjj+1
   sgdata(jjj,:) = sgdata(jj,:)
  end do
  delete(iii)
  delete(jjj)
  delete(ii)

 return(sgdata)
end

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

  xlats = new((/ny,nx/),float)
  xlons = new((/ny,nx/),float)
    ddx = new((/ny,nx/),float)
    ddy = new((/ny,nx/),float)

  xlats = create_sgdata(lats,nx,ny)

  tmp = num(.not.ismissing(xlats(:,1)))
  print(tmp)
  tmp = num(.not.ismissing(xlats(1,:)))
  print(tmp)

  ;xlons = create_sgdata(lons,nx,ny)
  ;  ddx = create_sgdata(dx,nx,ny)
  ;  ddy = create_sgdata(  dy,nx,ny)

  ;print(xlats)
  ;print(xlons)

end
