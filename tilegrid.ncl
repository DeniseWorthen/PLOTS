undef("tilegrid")

function tilegrid(lons:numeric,lats:numeric,tile:string)
begin

  dims = dimsizes(lats)
    ny = dims(0)
    nx = dims(1)
  delete(dims)

  ; lower left, upper right
  latcorners = (/lats(0,0), lats(ny-1,nx-1)/)
  loncorners = (/lons(0,0), lons(ny-1,nx-1)/)

  minlat = min(latcorners)
  maxlat = max(latcorners)
  minlon = min(loncorners)
  maxlon = max(loncorners)

  if(tile .eq. "tile1")then
   tmplon = minlon
   minlon = maxlon - 360.0
   maxlon = tmplon
  end if
  return( [/minlon,minlat,maxlon,maxlat/])
end
