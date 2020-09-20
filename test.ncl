; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

begin

;************************************************
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  runname = "cfsr"
  rtsrc= "/scratch1/NCEPDEV/stmp2/Denise.Worthen/DATM/rtgen.105323/tmp/cpld_datm_mom6_cice5_2d_"+runname+"/"

;************************************************
; create an 'hour-minute' time axis
;************************************************

  atmlist=systemfunc("ls "+rtsrc+"field_atm_exporta_*.nc")
  print(atmlist)
  nfiles = dimsizes(atmlist)

  fdates = str_get_cols(atmlist, -22,-13)
  ftimes = str_get_cols(atmlist, -11, -4)
  print(fdates+" "+ftimes)
  
   years = stringtointeger(str_get_cols(fdates,0,3))
  months = stringtointeger(str_get_cols(fdates,5,6))
    days = stringtointeger(str_get_cols(fdates,8,9))
   hours = stringtointeger(str_get_cols(ftimes,0,1))
  minuts = stringtointeger(str_get_cols(ftimes,3,4))
    secs = stringtointeger(str_get_cols(ftimes,6,7))

   syear =  years(0)
  smonth = months(0)
    sday =   days(0)

     units = "hours since "+syear+"-"+smonth+"-"+sday+" 00:00:00"
  time = cd_inv_calendar(years,months,days,hours,minuts,secs,units,0)
  time!0 = "time"
  nsteps = dimsizes(time)
  ;print("nsteps = "+nsteps)
  print(time)
exit
end
