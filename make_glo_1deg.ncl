; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

begin
;************************************************

  RT = "/scratch2/NCEPDEV/climate/Denise.Worthen/test/"

  fmask = addfile(RT+"w3mask.nc","r")
  fscrp = addfile(RT+"SCRIP_glo_1deg.nc","w")
  
  mval = fmask->w3mask
  mask1d=ndtooned(toint(mval))

  fscrp->grid_imask = mask1d
end
