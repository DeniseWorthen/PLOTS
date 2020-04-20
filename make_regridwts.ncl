
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Interpolation methods
    methods        = (/"bilinear" ,"conserve"/)

        nemsrc     = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"
;---Input file
    srcDirName     = "/scratch4/NCEPDEV/ocean/save/Denise.Worthen/NEMS_INPUT0.1/"
    srcFileName    = "mom6_data/ocn_2011_09_01_03.nc"
    varName        = "temp"
    srcLatName     = "geolat"
    srcLonName     = "geolon"

;---Get data and lat/lon grid from source Grid; uses surface level and initial time
    sfile          = addfile(srcDirName+srcFileName,"r")
    x              = sfile->$varName$(0,0,:,:)
    x@lat2d        = sfile->$srcLatName$
    x@lon2d        = sfile->$srcLonName$
    x@units = ""
    x@long_name = ""

;---Specify a name for the destination regridded variable (no spaces)
    DstGridName    = (/"0.5x0.5","1x1"/)
    DstScrpName    = (/"Global_0.5deg_SCRIP.nc", \
                       "Global_1.0deg_SCRIP.nc"/)
    ;DstGridName    = (/"0.5x0.5"/)
    ;DstScrpName    = (/"Global_0.5deg_SCRIP.nc"/)

    npx = (/720, 360/)
    npy = (/360, 180/)

    LatMins = (/-89.75, -89.50/)
    LatMaxs = (/ 89.75,  89.50/)
    LonMins = (/  0.25,   0.50/)
    LonMaxs = (/359.75, 359.50/)

;---Specify name of weight file(s) to be generated; name of destination grid; dst directory
    WgtFileDir     = nemsrc
    WgtFileName    = "mom6_0.25_to_"+DstGridName+"."+methods+".nc"

    Opt                  = True
    Opt@SrcFileName      = nemsrc+"mom6_data/mom6.scrip.nc"   ; source grid description file name
    Opt@SrcGridLon       = 
    Opt@ForceOverwrite   = True

    Opt@SrcMask2D        = where(.not.ismissing(x),1,0)  ; land/ocean mask
    Opt@Debug            = True

;----------------------------------------------------------------------
; Loop over desired resolutions
;----------------------------------------------------------------------

  do n = 0,dimsizes(DstGridName)-1

     print(LatMins(n)+" "+LatMaxs(n))
     print(LonMins(n)+" "+LonMaxs(n))
     print(npx(n)+"  "+npy(n))

;---Create the destination rectilinear lat/lon
     lat = fspan(LatMins(n),LatMaxs(n),npy(n))
     lon = fspan(LonMins(n),LonMaxs(n),npx(n))

    ;print(lat(0:10))
    ;print(lon(0:10))

    Opt@DstGridLat   = lat
    Opt@DstGridLon   = lon
    Opt@DstFileName  = WgtFileDir+DstScrpName(n)       ; destination grid description file name
    Opt@DstTitle     = "Global Grid "+DstGridName(n)+" degree Resolution"

;----------------------------------------------------------------------
; Loop across each method and generate interpolation weights for
; MOM6 Grid to World Grid
;----------------------------------------------------------------------

    do i=0,dimsizes(methods)-1
      print("Generating interpolation weights from MOM6 to")
      print("Global grid using the " + methods(i) + " method.")

      Opt@WgtFileName  = WgtFileDir+WgtFileName(i)

      Opt@InterpMethod = methods(i)

      x_regrid = ESMF_regrid(x,Opt)

      print(WgtFileDir+DstScrpName(n))
      print(WgtFileDir+WgtFileName(i))

      delete(x_regrid)
    end do
      delete(lat)
      delete(lon)
  ; nres
  end do
end

