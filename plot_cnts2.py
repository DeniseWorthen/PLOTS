import xarray as xr
#import matplotlib.pyplot as plt
import numpy as np
from matplotlib import pyplot as plt

import geocat.datafiles as gdf
import geocat.viz as gv

# Load dataset
dirsrc="/scratch3/NCEPDEV/stmp/Denise.Worthen/residual.ice/"

print(dirsrc+"ice.dev.nc")

nfiles=[gdf.get(dirsrc+"ice.dev.nc"), gdf.get(dirsrc+"ice.run1.nc"),
        gdf.get(dirsrc+"ice.run2.nc"), gdf.get(dirsrc+"ice.run3.nc")]

#ds1title="base"
#ds1 = xr.open_dataset(dirsrc+"ice.dev.nc")

#ds2title="floediam"
#ds2 = xr.open_dataset(dirsrc+"ice.ec.nc")

nds = xr.open_mfdataset(
    nfiles,
    concat_dim='case',
    combine='nested',
)

varname="aice_h"
icemin=1.0e-6
lmin=0
lmax=348



#var1=ds1[varname].isel(time=slice(lmin,lmax))
#var2=ds2[varname].isel(time=slice(lmin,lmax))
#tvals=ds1.time.isel(time=slice(lmin,lmax))

#print("print var1 max")
#print(var1.max().item())
#print("print var1 values")
#print(var1.sel(nj=120,ni=60))

# ice01=xr.where(var1>0.0, 1, 0)
# ice02=xr.where(var2>0.0, 1, 0)
# icet1=xr.where(var1<=icemin, 1, 0)
# icet2=xr.where(var2<=icemin, 1, 0)

# tot1=ice01.sum(dim=['ni','nj'])
# tot2=ice02.sum(dim=['ni','nj'])

# cnt1=(ice01*icet1).sum(dim=['ni','nj'])
# cnt2=(ice02*icet2).sum(dim=['ni','nj'])

var=nds[varname].isel(time=slice(lmin,lmax))
ice0=xr.where(var>0.0, 1, 0)
ice1=xr.where(var<=icemin, 1, 0)
tot=ice0.sum(dim=['ni','nj'])
cnt=(ice0*ice1).sum(dim=['ni','nj'])
pct=100.*cnt/tot

plt.figure(figsize=(10, 6))
plt.plot(tvals, pct(case=0), label="base")
plt.plot(tvals, pct(case=1), label="floediam")
plt.title("% of grid points with aice_h>0 and <="+str(icemin))
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.show()
