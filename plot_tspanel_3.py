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
ipt=63-1
jpt=7-1

lmin=0
lmax=360


# Panels same figure
nrow=3
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(10, 8), sharex=True)

# panel 1
ii=0
varname1="aice_h"
varname2="aice_h"
var1=ds1[varname1].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
var2=ds2[varname2].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
tvals=ds1.time.isel(time=slice(lmin,lmax))

axs[ii].set_title(varname1)
axs[ii].plot(tvals, var1, label=ds1title)
axs[ii].plot(tvals, var2, label=ds2title)
axs[ii].set_ylabel(var1.attrs.get("units", ""))
#axs[ii].set_xlabel("Time")

# panels 2,3
varname1="daidtt_h"
varname2="daidtd_h"
vmin=-.0012
vmax=.0012

# panel 2
ii=1
var1=ds1[varname1].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
var2=ds1[varname2].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
tvals=ds1.time.isel(time=slice(lmin,lmax))

axs[ii].set_ylim(vmin,vmax)
axs[ii].plot(tvals, var1, label=varname1)
axs[ii].plot(tvals, var2, label=varname2)
axs[ii].set_title(ds1title)
axs[ii].set_ylabel(var1.attrs.get("units", ""))
#axs[ii].set_xlabel("Time")

# panel 3
ii=2
var1=ds2[varname1].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
var2=ds2[varname2].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
tvals=ds2.time.isel(time=slice(lmin,lmax))

axs[ii].set_ylim(vmin,vmax)
axs[ii].plot(tvals, var1, label=varname1)
axs[ii].plot(tvals, var2, label=varname2)
axs[ii].set_title(ds2title)
axs[ii].set_ylabel(var1.attrs.get("units", ""))
axs[ii].set_xlabel("Time")

# Add grid and legends to subplots
for ax in axs:
    ax.grid(True)
    ax.legend()

#fig.tight_layout()
plt.show()

#plt.savefig("test", dpi=150)
exit()

#print("Plot saved as min_atmExp_Faipt_lwup_tiles3_6.png")
