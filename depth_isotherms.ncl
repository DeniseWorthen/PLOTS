begin

   ; ocean model output location 
        dirsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BM1_ocn/"

          idate = "20120101"

   ocnfilelist = systemfunc("ls "+dirsrc+"gfs."+idate+"/00/"+"ocn*.nc")
          ocnf = addfiles(ocnfilelist,"r")
   ;print(ocnfilelist)

    ocnvar = ocnf[0]->temp
       z_l = ocnf[0]->z_l
   ;print(ocnvar(0,:,500,500))
   dims = dimsizes(ocnvar)
   time = ocnf[0]->time
     nj = dims(2)
     ni = dims(3)

   z_T = (/28.0, 25.0, 20.0, 15.0, 10.0, 5.0, 2.5/)
    nTd = dimsizes(z_T)
  z_T@units = ocnvar@units
      z_T!0 = "z_T"

  depth = conform_dims(dimsizes(ocnvar), z_l, (/1/))
  ;print(dimsizes(depth))
  ;print(depth(0,:,500,500))

  ;copy_VarCoords(ocnvar, depth)
  ;printVarSummary(depth)
  ;do ni = 0,nisoTd-1
   disot = tofloat(int2p_n_Wrap(ocnvar,depth,z_T,0,1))
   ;print(disot(0,500,500))
  ; printVarSummary(disot)
  ;end do

   varname = "dpisoT_sfc"
   varname@long_name = "depth of the isothermal surface"
   varname@units="m"
   outfile = "test.nc"
   system("/bin/rm -f "+outfile) 
   outcdf  = addfile (outfile, "c")  ; open output file

   setfileoption(outcdf,"DefineMode",True)

    ; predefine the coordinate variables and their dimensionality
    dimNames = (/"time", "z_T",    "nj",   "ni"/)
    dimSizes = (/ -1   ,     nTd,      nj,    ni/)
    dimUnlim = (/ True ,   False,   False, False/)
    filedimdef(outcdf,dimNames,dimSizes,dimUnlim)

    ; predefine the the dimensionality of the variables to be written out
    filevardef(outcdf, "time", typeof(time), getvardims(time))
    filevardef(outcdf, "z_T",  typeof(z_T), getvardims(z_T))

    ; Copy attributes associated with each variable to the file
    filevarattdef(outcdf, "time", time)
    filevarattdef(outcdf,  "z_T", z_T )

    odims = (/"time", "z_T", "nj", "ni"/)
    filevardef(outcdf, "dpisoT_sfc", "float", odims)

    setfileoption(outcdf,"DefineMode",False)

    ; write the dimensions to the file
    outcdf->time   = (/time/)
    outcdf->z_T  = (/z_T/)
    outcdf->$varname$ = (/disot/)

   ;df = addfile("test.nc","c")
   ;df->isot=isot
end
