begin
; create the SCRIP file ncremap -g e5.oper.an.SCRIP.nc -G latlon=721,1440#lat_typ=cap#lat_drc=n2s

  fdir="/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  ffile="sstk.ll025sc.2021030100_2021033123.nc"

  sstfile=addfile(fdir+ffile,"r")

  vname="SSTK"
  sst = sstfile->$vname$(0,:,:)
  printVarSummary(sst)
  dims=dimsizes(sst)
  print(dims)

  vmask = new((/dims(0),dims(1)/),integer)
  vmask = 0
  vmask = where(sst .eq. sst@_FillValue, 0, 1)
  ;printVarSummary(vmask)
  mask1d = ndtooned(vmask)

  delete(mask1d@_FillValue)
  printVarSummary(mask1d)

  imask = where(mask1d .lt. 0, 0, 1)

  scripFile = addfile(fdir+"e5.oper.an.SCRIP.nc", "w")

  scripFile->grid_imask = (/ imask /)
  exit

  end
