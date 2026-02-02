import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

#dirsrc="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"
dirsrc="/scratch3/NCEPDEV/stmp/Denise.Worthen/residual.ice/"

ds0 = xr.open_dataset(dirsrc+"ice.dev.nc")
ds1 = xr.open_dataset(dirsrc+"ice.run1.nc")
ds2 = xr.open_dataset(dirsrc+"ice.run2.nc")
ds3 = xr.open_dataset(dirsrc+"ice.run3.nc")

runnames = np.array(['base',
                     'zap: dyn_area_min=1.e-3, dyn_mass_min=1.e-2',
                     'zap: dyn_area_min=1.e-7, dyn_mass_min=1.e-6',
                     'zap: dyn_area_min=1.e-11, dyn_mass_min=1.e-10']
                    )

varname="aice_h"
icemin=1.0e-6

lmin=0
lmax=348

var0=ds0[varname].isel(time=slice(lmin,lmax))
var1=ds1[varname].isel(time=slice(lmin,lmax))
var2=ds2[varname].isel(time=slice(lmin,lmax))
var3=ds3[varname].isel(time=slice(lmin,lmax))
tvals=ds0.time.isel(time=slice(lmin,lmax))

#print("print var1 max")
#print(var1.max().item())
#print("print var1 values")
#print(var1.sel(nj=120,ni=60))

ice00=xr.where(var0>0.0, 1, 0)
ice01=xr.where(var1>0.0, 1, 0)
ice02=xr.where(var2>0.0, 1, 0)
ice03=xr.where(var3>0.0, 1, 0)

icet0=xr.where(var0<=icemin, 1, 0)
icet1=xr.where(var1<=icemin, 1, 0)
icet2=xr.where(var2<=icemin, 1, 0)
icet3=xr.where(var3<=icemin, 1, 0)

#tot1=ice01.sum(dim=['ni','nj'])
#tot2=ice02.sum(dim=['ni','nj'])

cnt0=(ice00*icet0).sum(dim=['ni','nj'])
cnt1=(ice01*icet1).sum(dim=['ni','nj'])
cnt2=(ice02*icet2).sum(dim=['ni','nj'])
cnt3=(ice03*icet3).sum(dim=['ni','nj'])

plt.figure(figsize=(10, 6))
plt.plot(tvals, cnt0, label=runnames[0])
plt.plot(tvals, cnt1, label=runnames[1])
plt.plot(tvals, cnt2, label=runnames[2])
plt.plot(tvals, cnt3, label=runnames[3])

plt.title("# of grid points with aice_h>0 and <="+str(icemin))
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.show()
