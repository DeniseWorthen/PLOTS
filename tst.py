import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

dirsrc="/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2670756/"
dstitle="base"
ds = xr.open_dataset(dirsrc+"ice.dev.nc")

time = ds.time
# Get the variable
tt = ds["daidtt_h"]
td = ds["daidtd_h"]
print(time)

ii=63-1
jj=7-1

vmin=-.0012
vmax=.0012

lmin=0
lmax=360

ptt=tt.isel(ni=ii,nj=jj,time=slice(lmin,lmax))
ptd=td.isel(ni=ii,nj=jj,time=slice(lmin,lmax))
pttime=time.isel(time=slice(lmin,lmax))

# Plot both on same figure
plt.figure(figsize=(10, 4))
plt.ylim(vmin,vmax)

plt.plot(pttime, ptt, label="daitt_h")
plt.plot(pttime, ptd, label="daitd_h")
plt.title(dstitle)
plt.ylabel(ptt.attrs.get("units", ""))

plt.xlabel("Time")
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.show()

plt.savefig("min_atmExp_Faii_lwup_tiles3_6.png", dpi=150)

print("Plot saved as min_atmExp_Faii_lwup_tiles3_6.png")
