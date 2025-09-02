import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

dirsrc="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"

ds1title="base"
ds1 = xr.open_dataset(dirsrc+"ice.dev.nc")

ds2title="floediam"
ds2 = xr.open_dataset(dirsrc+"ice.ec.nc")

varname="aice_h"
icemin=1.0e-6
lmin=0
lmax=360

var1=ds1[varname].isel(time=slice(lmin,lmax))
var2=ds2[varname].isel(time=slice(lmin,lmax))
tvals=ds1.time.isel(time=slice(lmin,lmax))

#print("print var1 max")
#print(var1.max().item())
#print("print var1 values")
#print(var1.sel(nj=120,ni=60))

ice01=xr.where(var1>0.0, 1, 0)
ice02=xr.where(var2>0.0, 1, 0)

icet1=xr.where(var1<=icemin, 1, 0)
icet2=xr.where(var2<=icemin, 1, 0)

tot1=ice01.sum(dim=['ni','nj'])
tot2=ice02.sum(dim=['ni','nj'])

cnt1=(ice01*icet1).sum(dim=['ni','nj'])
cnt2=(ice02*icet2).sum(dim=['ni','nj'])

plt.figure(figsize=(10, 6))
plt.plot(tvals, 100*cnt1/tot1, label="base")
plt.plot(tvals, 100*cnt2/tot2, label="floediam")
plt.title("% of grid points with aice_h>0 and <="+str(icemin))
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.show()
