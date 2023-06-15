  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; this code provides a starting guess for CICE6 decomposition based on
; desired resolution. It was provided as a code snippet from Dave Bailey
; dbailey@ucar.edu
;
; for each PE count, the blkx,blky values are given for slenderX and
; slenderX2 as well as other less-general use choices (which may
; require changes to process_shape and distribution weight also.
;----------------------------------------------------------------------
begin

; mx100 decomps
;nx = 360
;ny = 320
;nx=320
;ny=360
; mx050 decomps
;nx = 720
;ny = 576
; mx025 decomps
nx = 1440
ny = 1080

primesx = (/1,2,2,2,2,3,3,5/)
primesy = (/1,2,5,41/)
factorsx = (/1,2,3,4,5,6,8,9,10,12,15,16,18,20,24,30,36,40,45,48,60,72,80,90,120,144,180,240,360,720/)
factorsy = (/1,2,5,10,41,82,205,410/)

nfx = dimsizes(factorsx)
nfy = dimsizes(factorsy)

do m=0,nfx-1
do n=0,nfy-1
   print(sprinti("%5.0i",nx/factorsx(m))+" " \
       + sprinti("%5.0i",ny/factorsy(n))+" " \
       + sprinti("%5.0i",factorsx(m)*factorsy(n)))
end do
end do

exit
end
