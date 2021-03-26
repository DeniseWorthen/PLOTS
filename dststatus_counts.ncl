undef("dststatus_counts")

function dststatus_counts(var1d:numeric,flagnum:numeric)
begin

   flagdescr  = (/ \
     "The destination location is masked; no regridding " \     ;0
    ,"The destination location is within a masked part of the source grid; no regridding " \ ;1
    ,"The destination location is outside the source grid; no regriding " \ ;2
    ,"The destination cell overlaps a masked source cell, and extends outside the source grid " \ ;3
    ,"The destination location is within the unmasked source grid; regridded " \ ;4
    ,"The destination cell overlaps a masked source cell, and an unmasked source cell; cons mult " \ ;5
    ,"The destination cell overlaps an unmasked source cell, and extends outside the source grid; cons mult " \ ;6
    ,"The destination cell overlaps a masked source cell, an unmasked source cell, and extends outside the source grid; cons mult " \ ;7
    ,"The destination location was not within the unmasked source grid, extrapolation was used; regridded " \ ;8
                /)

   flagname = flagdescr(flagnum)
   tmp = var1d
   tmp = where(tmp .eq. flagnum, 1, 0)
   count = dim_sum(tmp)

   if(count .ne. 0)then
    print("dststatus flag = "+flagnum+" count = "+count+"  "+flagname)
   end if

   delete(tmp)
   delete(count)
   return (0)
end
