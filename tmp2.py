import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

dirsrc="/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2670756/"

ds1title="base"
ds1 = xr.open_dataset(dirsrc+"ice.dev.nc")

ds2title="floediam"
ds2 = xr.open_dataset(dirsrc+"ice.ec.nc")


# point location
ii=63-1
jj=7-1


lmin=0
lmax=360

var1=ds1[varname1].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
var2=ds1[varname2].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
tvals=ds1.time.isel(time=slice(lmin,lmax))

# Panels same figure
nrow=2
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(10, 6))




vmin=-.0012
vmax=.0012

varname1="daidtt_h"
varname2="daidtd_h"

# panel 1
axs[0].set_ylim(vmin,vmax)
axs[0].plot(tvals, var1, label=varname1)
axs[0].plot(tvals, var2, label=varname2)
axs[0].set_title(ds1title)
axs[0].set_ylabel(var1.attrs.get("units", ""))
axs[0].set_xlabel("Time")

# panel 2
var1=ds2[varname1].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
var2=ds2[varname2].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
tvals=ds2.time.isel(time=slice(lmin,lmax))

axs[1].set_ylim(vmin,vmax)
axs[1].plot(tvals, var1, label=varname1)
axs[1].plot(tvals, var2, label=varname2)
axs[1].set_title(ds2title)
axs[1].set_ylabel(var1.attrs.get("units", ""))
axs[1].set_xlabel("Time")

# Add grid and legends to subplots
for ax in axs:
    ax.grid(True)
axs[0].legend()
axs[1].legend()

plt.tight_layout()
plt.show()

plt.savefig("test", dpi=150)

#print("Plot saved as min_atmExp_Faii_lwup_tiles3_6.png")
