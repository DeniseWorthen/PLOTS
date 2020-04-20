begin

   ; ocean model output location 
        dirsrc = "/scratch3/NCEPDEV/stmp2/Denise.Worthen/BM1_ocn/"

          idate = "20120101"

   ocnfilelist = systemfunc("ls "+dirsrc+"gfs."+idate+"/00/"+"ocn*.nc")
          ocnf = addfiles(ocnfilelist,"r")
  ; print(ocnfilelist)

    ocnvar = ocnf[0]->temp
       z_l = ocnf[0]->z_l
   dims = dimsizes(ocnvar)
   time = ocnf[0]->time
  ; time = ocnf->time
     nk = dims(1)
     nj = dims(2)
     ni = dims(3)

  ; tlev = (/28.0, 25.0, 20.0, 15.0, 10.0, 5.0, 2.5/)
   tlev = (/20.0/)
    nTd = dimsizes(tlev)
  tlev@units = ocnvar@units
      tlev!0 = "tlev"

  depth = tofloat(conform_dims(dimsizes(ocnvar), z_l, (/1/)))
  copy_VarCoords(ocnvar, depth)
  printVarSummary(depth)
  
  ;dpisoT = tofloat(int2p_n_Wrap(ocnvar,depth,tlev,1,1))
  dpisoT = int2p_n_Wrap(ocnvar,depth,tlev,1,1)
  printVarSummary(dpisoT)

  i1 = 525
  i2 = 535
  j1 = 560
  print(ocnvar(0,:,j1,i1)+"  "+depth(0,:,j1,i1)+"  "+ocnvar(0,:,j1,i2))
  print(tlev+"  "+dpisoT(0,:,j1,i1)+"   "+dpisoT(0,:,j1,i2))

end
