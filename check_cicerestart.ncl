;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;************************************************

begin
;************************************************
; read in netCDF file
;************************************************

   ncat = 5

   ;rtsrc="/scratch4/NCEPDEV/nems/noscrub/Bin.Li/FROM_HPSS/"
   ;restartlist = systemfunc("ls "+rtsrc+"20*/cice5_model*.nc") 

   rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE5_RESTARTS/"
   restartlist = systemfunc("ls "+rtsrc+"20*/mom6_da/cice5_model*.nc") 

   ;rtsrc="/scratch3/NCEPDEV/stmp2/Denise.Worthen/CICE5_RESTARTS_VICEN/"
   ;restartlist = systemfunc("ls "+rtsrc+"20*/mom6_da/cice5_model*.nc") 

  print(restartlist)
  nfiles = dimsizes(restartlist)

  cicerestarts=addfiles(restartlist,"r")

  do jj = 0,nfiles-1
      icec=dim_sum_n(cicerestarts[jj]->aicen(:,:,:),0)
   ;icutoff=where(icec .gt. 0.0, icec, default_fillvalue(typeof(icec)))
   imask=where(icec .gt. 0.0, 1, default_fillvalue(typeof(icec)))
   qice = cicerestarts[jj]->qice001
   do k = 0,ncat-1
    qice(k,:,:) = imask(:,:)*qice(k,:,:)
    print(restartlist(jj)+ "   "+k+"   "+min(qice(k,:,:))+"   "+max(qice(k,:,:)))
   end do
 ;  varname = "vicen"
   ;icevar=dim_sum_n(cicerestarts[jj]->$varname$(:,:,:),0)
 ;  icevar=cicerestarts[jj]->$varname$(:,:,:)
 ;  do k = 0,ncat-1
 ;   icevar(k,:,:)=where(icevar(k,:,:) .gt. 0.0,icevar(k,:,:),default_fillvalue(typeof(icec)))
 ;   print(restartlist(jj)+ "   "+k+"   "+min(icutoff)+"   "+min(icevar(k,:,:)))
 ;  end do
 ;  hice=dim_sum_n(icevar,0)
 ;  hice=where(hice .gt. 0.0,hice,default_fillvalue(typeof(icec)))
 ;  print(min(hice))

 end do
exit
end
