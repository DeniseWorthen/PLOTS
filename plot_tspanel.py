import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

dirsrc="/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2670756/"

ds1title="base"
ds1 = xr.open_dataset(dirsrc+"ice.dev.nc")

ds2title="floediam"
ds2 = xr.open_dataset(dirsrc+"ice.ec.nc")

varname1="daidtt_h"
varname2="daidtd_h"

# point location
ii=63-1
jj=7-1

vmin=-.0012
vmax=.0012

lmin=0
lmax=360

var1=ds1[varname1].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
var2=ds1[varname2].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
tvals=ds1.time.isel(time=slice(lmin,lmax))

# Plot both on same figure
plt.figure(figsize=(10, 4))
plt.ylim(vmin,vmax)

plt.plot(tvals, var1, label=varname1)
plt.plot(tvals, var2, label=varname2)
plt.title(ds1title)
plt.ylabel(var1.attrs.get("units", ""))

plt.xlabel("Time")
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.show()

plt.savefig(ds1title, dpi=150)

#print("Plot saved as min_atmExp_Faii_lwup_tiles3_6.png")
