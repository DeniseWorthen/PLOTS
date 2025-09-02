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

lmin=0
lmax=360

var1=ds1[varname].isel(time=slice(lmin,lmax))
var2=ds2[varname].isel(time=slice(lmin,lmax))
tvals=ds1.time.isel(time=slice(lmin,lmax))

#var1=ds1[varname]
#var2=ds2[varname]
#tvals=ds1.time
#print("print var1 max")
#print(var1.max().item())
#print("print var1 values")
#print(var1.sel(nj=120,ni=60))

ice01=xr.where(var1>0.0, 1, 0)
ice02=xr.where(var2>0.0, 1, 0)
#print("print ice01 values")
#print(ice01.sel(nj=120,ni=60))

icet1=xr.where(var1<=1.0e-6, 1, 0)
icet2=xr.where(var2<=1.0e-6, 1, 0)

#print("print icet1 values")
#print(icet1.sel(nj=120,ni=60))
#print(icet1.max().item())

tot1=ice01.sum(dim=['ni','nj'])
tot2=ice02.sum(dim=['ni','nj'])
#print("print tot1 values")
#print(tot1)

cnt1=(ice01*icet1).sum(dim=['ni','nj'])
cnt2=(ice02*icet2).sum(dim=['ni','nj'])
#print("print cnt1 values")
#print(cnt1)


# # Plot both on same figure
# nrow=2
# ncol=1
plt.figure(figsize=(10, 6))
plt.plot(tvals, cnt1, label="daitt_h")
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.show()

# # panel 1
# sub1 = fig.add_subplot(nrow,ncol,1)
# sub1.set_ylim(vmin,vmax)
# sub1.plot(tvals, var1, label=varname1)
# sub1.plot(tvals, var2, label=varname2)
# sub1.set_title(ds1title)
# sub1.set_ylabel(var1.attrs.get("units", ""))
# sub1.set_xlabel("Time")

# # panel 2
# var1=ds2[varname1].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
# var2=ds2[varname2].isel(ni=ii,nj=jj,time=slice(lmin,lmax))
# tvals=ds2.time.isel(time=slice(lmin,lmax))

# sub2 = fig.add_subplot(nrow,ncol,2)
# sub2.set_ylim(vmin,vmax)
# sub2.plot(tvals, var1, label=varname1)
# sub2.plot(tvals, var2, label=varname2)
# sub2.set_title(ds2title)
# sub2.set_ylabel(var1.attrs.get("units", ""))
# sub2.set_xlabel("Time")


# plt.grid(True)
# plt.legend()
# plt.tight_layout()
# plt.show()

# plt.savefig("test", dpi=150)

# #print("Plot saved as min_atmExp_Faii_lwup_tiles3_6.png")
