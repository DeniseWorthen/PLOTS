;**********************************************************
; re-write CMEPS dststatus files for atm
;
; adapted from code originally written by
; Ufuk Turuncoglu turuncu@ucar.edu

  load "dststatus_counts.ncl"

;**********************************************************
begin

   makefile = "yes"
   makeplot = "yes"

   nl = str_get_nl()
   nflags = 9
     RT = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/WaveUnstr2/"
   date = "2021-03-22-"

    atmres = 96
 ;   atmres = 192
 ;   atmres = 384

   ;plotlab="unstr noland"
   ;dirs=(/"unstrnoland3PE/"/)

   plotlab="pdlib noland"
   dirs=(/"pdlibnoland3PE/"/)


   ;plotlab="mx050"
   ;plotlab="mx025"
   ;dirs = (/"c384/"+plotlab+"/"/)
   wkstitle="c96"+plotlab

   ;plotlab = (/"atm meshmask"/)
   ;vname = "mask"
   ; levs = (/0,2,1/)
   ;fsrc = "dststatus.meshmask.atm.nc"
   ;fsrc = "fv3.meshmask.nc"

   vname = "dststatus"
   levs = (/0,9,1/)
   ;fsrc = vname+".wav.atm.nstod_consf"
   ;fsrc = vname+".ocn.atm.consd"
   ;fsrc = vname+".ocn.atm.consf"
   fsrc = vname+".wav.atm.bilnr_nstod"

  ntile = 6
  ndirs = dimsizes(dirs)

  ; retrieve orodata file from INPUT directory for masking
  filelist = systemfunc("ls "+RT+dirs(0)+"INPUT/oro_data.tile*.nc")
  print(filelist)
  ofiles = addfiles(filelist,"r")
  ListSetType(ofiles,"join")
  mskname = "slmsk"
  msklonname = "geolon"
  msklatname = "geolat"
  mskvar = ofiles[:]->$mskname$
  mskvar@lon2d = ofiles[0]->$msklonname$
  mskvar@lat2d = ofiles[0]->$msklatname$
  printVarSummary(mskvar)

  if (makefile .eq. "yes") then
;**********************************************************
; retrieve lat/lon from first coupler history file
;**********************************************************

  ;fname = "/glade/scratch/worthen/FV3_RT/wave_test/base/ufs.cpld.cpl.hi.atm."+date+"22320.nc"
  ;fname = RT+dirs(0)+"ufs.cpld.cpl.hi.atm."+date+"22320.nc"
  ;fname = RT+dirs(0)+"ufs.cpld.cpl.hi.atm."+date+"22200.nc"
  fname = RT+dirs(0)+"ufs.atmw.cpl.hi.atm."+date+"22320.nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  ;--- query the number of dims in case the history file is written
  ;    on the tiles
  ndims = dimsizes(dimsizes(ff->atmImp_lat))
  print("file containing dimensions contains ndims = "+ndims)

  ;--- read coordinate variables ---
  if(ndims .eq. 4)then
    lat3d = ff->atmImp_lat(0,:,:,:)
    lon3d = ff->atmImp_lon(0,:,:,:)
    lat3d@units = "degrees_N"
    lon3d@units = "degrees_E"
  else
  ;--- read coordinate variables ---
     lat1d = ff->atmImp_lat(0,0,:)
     lon1d = ff->atmImp_lon(0,0,:)
     lat1d@units = "degrees_N"
     lon1d@units = "degrees_E"
     ;printVarSummary(lat1d)
     ;printVarSummary(lon1d)

     ;--- reshape variables---
     lon3d = new((/ ntile, atmres, atmres /), typeof(lon1d))
     lat3d = new((/ ntile, atmres, atmres /), typeof(lat1d))
     ;printVarSummary(lat3d)

     do i = 0, ntile-1
      istr = (i*atmres*atmres)
      iend = istr+atmres*atmres-1
      lat3d(i,:,:) = onedtond(lat1d(istr:iend), (/ atmres, atmres /))
      lon3d(i,:,:) = onedtond(lon1d(istr:iend), (/ atmres, atmres /))
     end do
  end if
  delete(ff)
  delete(fname)

;**********************************************************
;
;**********************************************************

do nd = 0,ndirs-1
  print(" "+nl)
  dirsrc = RT+dirs(nd)

  ; get the index seq to resort
  doffile = dirsrc+"dof.atm.nc"
  ;doffile = dirsrc+"dof.nc"
  doff = addfile(doffile,"r")
  dof = doff->dof(:)

  fname = dirsrc+fsrc+".nc"
  print("input file "+fname)
  ff = addfile(fname,"r")

  var1d = ff->$vname$(:)
  ;printVarSummary(var1d)

   total = 0
  do i = 0,nflags-1
   total = total+dststatus_counts(var1d,i)
  end do
   print("total count of all dststatus types = "+total+" size of var1d = "+dimsizes(var1d))

  ip = dim_pqsort(dof,1)
  var1d_sort=var1d
  var1d_sort=var1d(ip)

;**********************************************************
; pre-define the output file
;**********************************************************

    ofile = dirsrc+"dst."+fsrc+".nc"
    print("output file "+ofile)
    system("rm -f "+ofile)
    fout = addfile(ofile, "c")
    setfileoption(fout, "DefineMode", True)

    ;--- create dimensions ---
    dimNames = (/ "ntiles", "grid_xt", "grid_yt" /)
    dimSizes = (/ ntile, atmres, atmres /)
    dimUnlim = (/ False,  False,  False /)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    filevardef(fout, "grid_xt", typeof(lon3d(:,:,:)), (/"ntiles", "grid_yt", "grid_xt" /))
    filevardef(fout, "grid_yt", typeof(lat3d(:,:,:)), (/"ntiles", "grid_yt", "grid_xt" /))

    ;--- create variable ---
     filevardef(fout, vname, typeof(var1d), (/"ntiles", "grid_yt", "grid_xt" /))
    setfileoption(fout, "DefineMode", False)

    ;--- write grid variables ---
    fout->grid_xt = (/ lon3d(:,:,:) /)
    fout->grid_yt = (/ lat3d(:,:,:) /)

;**********************************************************
; add variables
;**********************************************************

     var3d = new((/ ntile, atmres, atmres /), typeof(var1d), default_fillvalue(typeof(var1d)) )
     ;printVarSummary(var3d)

     do i = 0, ntile-1
      istr = (i*atmres*atmres)
      iend = istr+atmres*atmres-1
      ;var3d(i,:,:) = onedtond(var1d(istr:iend), (/ res, res /))
      var3d(i,:,:) = onedtond(var1d_sort(istr:iend), (/ atmres, atmres /))
      ;print("tile number = "+i+" "+istr+" "+iend)
     end do

     fout->$vname$ = var3d(:,:,:)
    delete(fout)
    delete(var1d)
    delete(var3d)
end do  ; ndirs
  end if ; make file

if(makeplot .eq. "yes") then
;************************************************
; create spatchcock plot of dststatus on atm tiles
;************************************************

  dirsrc = RT+dirs(0)
    ofile = dirsrc+"dst."+fsrc+".nc"
       ff = addfile(ofile, "r")
     data = ff->$vname$

     ocnonly = data
     ocnonly = mask(data,mskvar,0.0)
     data = ocnonly

    ;if(1.eq.0)then
     ; re-arrange tiles that are on their side
     do kk = 0,ntile-1
       if any((kk .eq. (/ 3, 4 /))) then
         data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
         data(kk,:,:) = data(kk,::-1,:)
       end if
       if any((kk .eq. (/ 2 /))) then
         data(kk,:,:) = (/ transpose(data(kk,:,:)) /)
         data(kk,:,:) = data(kk,:,::-1)
       end if
    end do
    ;end if

    ;palette = "seaice_2"
    palette = "amwg"

    cmap = read_colormap_file(palette)
    ;cmap(1,:) = namedcolor2rgba("white")
    cmap(2,:) = namedcolor2rgba("white")

;************************************************
; define the map
;************************************************

     wkstype="X11"
     ;wkstype="png"
     wkstype@wkWidth=1600
     wkstype@wkHeight=1600
     wks   = gsn_open_wks (wkstype,wkstitle)              ; send graphics to X11 window
     gsn_define_colormap(wks,palette)

     res                      = True        ; plot mods desired
     res@gsnDraw              = False       ; do not draw until the end
     res@gsnFrame             = False       ; do not automatically advance 'frame'

     ;res@cnFillMode = "MeshFill"
     res@cnFillMode = "RasterFill"

     plot = new(ntile,graphic)

     size = 0.22
     res@vpWidthF = size
     res@vpHeightF = size

     res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
     res@cnFillOn          = True                  ; color fill
     res@cnLinesOn         = False                 ; no contour lines
     res@cnLineLabelsOn    = False
     res@cnInfoLabelOn     = False
     res@cnFillPalette     = cmap
     ;res@cnFillColors     = (/2,4,6,7,8,9,12,13,14,15,16,17/)
    ; res@cnFillColors     = (/2,4,9,12,15,16,17,20,23/)

     res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill)
     ;res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

     res@cnLevelSelectionMode = "ManualLevels"     ; set the contour levels with the following 3 resources
     res@cnMinLevelValF  = levs(0)                      ; set the minimum contour level
     res@cnMaxLevelValF  = levs(1)                      ; set the maximum contour level
     res@cnLevelSpacingF = levs(2)                      ; set the interval between contours

     res@tmYROn = False
     res@tmXTOn = False
     res@tmYLOn = False
     res@tmXBOn = False

     res@gsnStringFont = 22
     res@gsnStringFontHeightF = 0.010

     ; text resources
     txres = True
     txres@gsnFrame = False
     txres@txJust = "CenterCenter"

;************************************************
;
;************************************************

     ;--- tile order ---
     ;   2
     ; 4 0 1 3
     ;   5
     xpos = tofloat((/ 1, 2, 1, 3, 0, 1 /))*size+0.05
     ypos = 0.9-tofloat((/ 1, 1, 0, 1, 1, 2 /))*size

     do kk = 0, ntile-1
       ;--- set position ---
       res@vpXF = xpos(kk)
       res@vpYF = ypos(kk)
       ;print(kk+" "+res@vpXF+" "+res@vpYF)

       if (kk .eq. 1) then
        res@lbLabelBarOn = True
        res@pmLabelBarWidthF = size*1.8
        res@pmLabelBarHeightF = 0.03
        res@pmLabelBarParallelPosF = 0.97
        res@cnLabelBarEndStyle = "ExcludeOuterBoxes"
        res@lbLabelAlignment = "BoxCenters"
       else
        res@lbLabelBarOn = False
       end if
       if( kk .eq. 2) then
        res@gsnLeftString = plotlab+":  "+fsrc
       else
        res@gsnLeftString = ""
       end if
       plot1 = gsn_csm_contour(wks, data(kk,:,:), res)
       draw(plot1)

       txres@txPosXF = xpos(kk)+0.01
       txres@txPosYF = ypos(kk)-0.01
       txres@txAngleF = 0
       txres@txFont = 22
       txres@txFontHeightF = 0.015
       text = gsn_create_text(wks, sprinti("%d", kk+1), txres)
       draw(text)
     end do

     frame(wks)

;************************************************
;
;************************************************

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if

end if
exit
end
