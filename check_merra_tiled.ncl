; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
  load "tilegrid.ncl"

begin
;************************************************

  RT = "/scratch2/NCEPDEV/climate/Denise.Worthen/"
  fdat = "MERRA2/merra2.aerclim.2003-2014.m01.nc"

  ntiles=6
  nx=96
  fsrc = "C96.mx100."
  ;nx=384
  ;fsrc = "C384.mx025."

  lon3d = new((/ ntiles, nx, nx/), "double")
  lat3d = new((/ ntiles, nx, nx/), "double")

  tlonname = "grid_xt"
  tlatname = "grid_yt"

  npts = 6
  xlats = (/20.0, -15.0,  74.0,   33.0,  10.0, -82.0/)
  xlons = (/ 8.0,  80.0, 180.0,  187.0, 297.0, 180.0/)

  k=0
  do k = 0,ntiles-1
   tile="tile"+sprinti("%d",k+1)
   atmfile=addfile(RT+"test/"+fsrc+tile+".nc","r")
   ;print(atmfile)

   atmlons = atmfile->$tlonname$
   atmlats = atmfile->$tlatname$
   tilecorners = tilegrid(atmlons,atmlats,tile)
   minlon = tilecorners[0]
   minlat = tilecorners[1]
   maxlon = tilecorners[2]
   maxlat = tilecorners[3]
   ;print(tile+"  "+minlat+"   "+maxlat)
   ;print(tile+"  "+minlon+"   "+maxlon)

   do kk = 0,npts-1
    lat1=xlats(kk)
    lon1=xlons(kk)

    if(lat1 .ge. minlat .and. lat1 .le. maxlat .and. lon1 .ge. minlon .and. lon1 .le. maxlon)then
    ij = getind_latlon2d(atmlats,atmlons,lat1,lon1)
    ;print("I = "+ij(0,1)+"  J="+ij(0,0))
    if(tile .eq. "tile4" .or. tile .eq. "tile5")then
    ; flip the indices
     ii = ij(0,0)+1
     jj = ij(0,1)+1
    else
     jj = ij(0,0)+1
     ii = ij(0,1)+1
    end if
    print(tile+" indices I = "+ii+"  J="+jj)
    print(lon1+"  "+lat1+" maps to "+tile+" "+atmlons(jj,ii)+"  "+atmlats(jj,ii))
    end if
   end do
  end do
end
