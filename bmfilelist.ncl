;************************************************
; create a list of files from a benchmark output
; directory
;************************************************

undef("bmfilelist")

function bmfilelist(bmsrc:string)
begin

  format = "%Y%N%D%H"
  format@century = 2000
  format@units = "hours since "+format@century+"-01-01 00:00:00"

    yrbeg = 2011
    yrend = 2018
    nmons = 12
    ndays = 2         ; 1st and 15th
   nyears = (yrend-yrbeg)+1
  maxdirs = nyears*nmons*ndays
  ;print(maxdirs)

  bmdatelist = new((/maxdirs/),"string",default_fillvalue("string"))
  bmtimelist = new((/maxdirs/),"double",default_fillvalue("double"))

     ii = 0
  do yr = yrbeg,yrend
   do mn = 1,nmons
    do dy = 1,15,14
     cdate = sprinti("%0.4i",yr)+sprinti("%0.2i",mn)+sprinti("%0.2i",dy)
     ; check that directory exists, if yes then add to list and create time value
     rc = systemfunc("test -d "+bmsrc+cdate+"; echo $?")
     if(rc .eq. 0)then
      bmdatelist(ii) = cdate
      bmtimelist(ii) = cd_inv_string(cdate+"00",format)
                  ii = ii+1
      ;print(cdate)
     end if
    end do
   end do
  end do
  nvalid = ii

  ;print(bmdatelist(0:nvalid-1))
  ;print(bmtimelist(0:nvalid-1))
  return( [/nvalid,bmdatelist(0:nvalid-1),bmtimelist(0:nvalid-1)/])

end
