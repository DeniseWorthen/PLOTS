;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "bmfilelist.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"
  LSF = "/scratch2/NCEPDEV/climate/Lydia.B.Stefanova/Models/"

  bmname = "b31"
   bmsrc = LSF+"ufs_"+bmname+"/SeaIce/"
   nruns = 1
   print(bmsrc)
   CL = "/scratch2/NCEPDEV/climate/Denise.Worthen/P31ice/"

  cyears = (/"2011","2012","2013","2014","2015","2016","2017","2018"/)
   cmons = (/"04", "05", "06", "07", "08", "09", "10", "11", "12", "01", "02", "03"/)
   idays = (/"01","15"/)
 ; cyears = (/"2011","2012"/)
 ;  cmons = (/"04", "05"/)
 ;  idays = (/"01"/)

   nyears = dimsizes(cyears)
     nmon = dimsizes(cmons)
    niday = dimsizes(idays)
    ndays = 35

   format = "%Y%N%D"
   format@century = 1900
   format@units = "hours since 1900-01-01 00:00:00"

   idates = new((/nyears/),string)
    flist = new((/nyears,ndays/),string)
    dlist = new((/nyears,ndays/),string)

    do nm = 0,nmon-1
     do nd = 0,niday-1
      fout = CL+"ice."+bmname+"."
     ;print(fout)

     ; make a list of initial dates
         ii = 0
      do ny = 0,nyears-1
       idates(ii) = cyears(ny)+cmons(nm)+idays(nd)
         ii = ii +1
      end do
      ;print(idates)
      ;print(dimsizes(idates))

      flist = " "
      dlist = " "
      do jj = 0,dimsizes(idates)-1
       idate = idates(jj)
       time0 = cd_inv_string(idate,format)
        fstr = ".01."+idate+"00.subset.nc"

       do ndd = 0,ndays-1
          time = time0+ndd*24
        copy_VarAtts(time0,time)
         fdate = cd_calendar(time,0)
         cdate = sprinti("%0.4i",toint(fdate(0,0)))+sprinti("%0.2i",toint(fdate(0,1)))+sprinti("%0.2i",toint(fdate(0,2)))
         fname = bmsrc+idate+"/"+"ice"+cdate+fstr
      ;   print(fname)
         if(fileexists(fname))then
          flist(jj,ndd) = fname
          dlist(jj,ndd) = sprinti("%0.2i",toint(fdate(0,1)))+sprinti("%0.2i",toint(fdate(0,2)))
         end if
       end do
       ;print(dlist(jj,:))
      end do
      ;print(dlist)
      ;print(" ")

      do ndd = 0,ndays-1
       f0 = flist(0,ndd)
       f1 = flist(1,ndd)
       f2 = flist(2,ndd)
       f3 = flist(3,ndd)
       f4 = flist(4,ndd)
       f5 = flist(5,ndd)
       f6 = flist(6,ndd)
       f7 = flist(7,ndd)
       cday = dlist(7,ndd)
       ncocmd = "ncra -O "+f0+" "+f1+" "+f2+" "+f3+" "+f4+" "+f5+" "+f6+" "+f7+"   "+fout+cday+"."+cmons(nm)+idays(nd)+".nc"
       ;ncocmd = "ncra -O "+f0+" "+f1+"   "+fout+dy+"."+cmons(nm)+idays(nd)+".nc"
       system(ncocmd)
       ;print(ncocmd)
      end do ;ndd

     end do ;nd
    end do ;nm

exit
end
