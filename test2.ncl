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
   CL = "/scratch2/NCEPDEV/climate/Denise.Worthen/IceData/"

  bmsrc = LSF+"ufs_b31/SeaIce/"
  nruns = 1

  yrbeg = 2011
  yrend = 2018
   nmon = 12
  ndays = 35
  idays = (/"01","15"/)

  ; use first bm to set dates etc
   freturn = bmfilelist(bmsrc(0))
    nvalid = freturn[0]
  datelist = new((/nvalid/),typeof(freturn[1]))
  timelist = new((/nvalid/),typeof(freturn[2]))
  datelist = freturn[1]
  timelist = freturn[2]

   ;print(datelist)
   ;print(timelist)
 
  nfiles = dimsizes(datelist)

 format = "%Y%N%D"
 format@century = 1900
 format@units = "hours since 1900-01-01 00:00:00"

  nd = 0
 ; do nd = 0,dimsizes(idays)-1
    idy = idays(nd)
   do nm = 1,2
     month = sprinti("%0.2i", nm)
    do ny = yrbeg,yrend
     year = sprinti("%0.4i", ny)
     date = year+month+idy
     time0 = cd_inv_string(date,format)

       iii = 0
        ii = 1
     ;do ii = 1,ndays
     do ii = 1,3
      time = time0+(ii-1)*24
      copy_VarAtts(time0,time)
      fdate = cd_calendar(time,0)
      cdate = sprinti("%0.4i",toint(fdate(0,0)))+sprinti("%0.2i",toint(fdate(0,1)))+sprinti("%0.2i",toint(fdate(0,2)))
        iii = iii+1
      print(iii+" "+date+"  "+time+" "+cdate)
     end do
     print(" ")

    end do
   end do
  ;end do


  ;do ii = 0,nfiles-1
  do ii = 0,10
   cmon = str_get_cols(datelist(ii),4,7)
   do ny = yrbeg,yrend
    year = sprinti("%0.4i", ny)
    date = year+cmon
    ;print(date)
     ;if(monthday .eq. cmon)then
     ; print(ii+" "+monthday)
     ;end if
   end do
  end do

;  filelist = new((/nruns,nvalid/),typeof(datelist))
;   obslist = new((/maxyears/),typeof(datelist))
;  ;grab integration day iday (in hours) from
;  ;runs at month N
;  format = "%Y%N%D%H"
;    iday = 35
;    imon = "0801"
;     iii = 0
;   do ii = 0,nvalid-1
;    cmon = str_get_cols(datelist(ii),4,7)
;   cyear = str_get_cols(datelist(ii),0,3)
;    if(cmon .eq. imon)then
;     ;print(datelist(ii)+"  "+cmon)
;     itime = timelist(ii)            ; copy attributes
;     itime = itime + (iday-1)*24
;
;     idate = cd_string(itime,format) ; date of integration day
;     idate = str_get_cols(idate,0,7) ; without the hours
;    end if
;   end do
;   nfiles = iii

exit
end
