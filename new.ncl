; read in netCDF file
;************************************************

  RT1 = "/glade/scratch/worthen/nocold/"

  runnames = (/"ori cold start", "fixed cold start", "no cold start (ocean lag)"/)
       rts = (/"cmeps_cold2", "cmeps_cold2_fix", "cmeps_nocold"/)

;************************************************
;  Ocn initial condition
;************************************************

      ofile = addfile(RT1+rts(0)+"/INPUT/MOM.res.nc","r")
      tinit = ofile->Temp(0,0,:,:)

;************************************************
; Ice inst sst_h at hour6
;************************************************

  cyear = "2012"
   cmon = "01"
   cday = "01"
  csecs = "21600"
  cdate = cyear+"-"+cmon+"-"+cday+"-"+csecs

  icefiles = addfiles(RT1+rts+"/history/iceh_inst."+cdate+".nc","r")
  print(icefiles)
  ;ListSetType(icefiles,"cat")
  levs = (/-0.5,0.5,0.05/)

  ;default
  cmap="cmp_flux"

;************************************************
;
;************************************************

     cold = icefiles[0]->sst_h(0,:,:) - tinit(:,:)
      fix = icefiles[1]->sst_h(0,:,:) - tinit(:,:)
   nocold = icefiles[2]->sst_h(0,:,:) - tinit(:,:)

   printVarSummary(nocold)

