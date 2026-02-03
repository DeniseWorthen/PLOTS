1import xarray as xr
#import matplotlib.pyplot as plt
import numpy as np
from matplotlib import pyplot as plt

import geocat.datafiles as gdf
import geocat.viz as gv
#from geocat.viz import get_NCL_colormap

# Load dataset

dirsrc="/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_2379058/"
filename="history/iceh_06h.2011-10-05-43200.nc"
#nfiles=[gdf.get(dirsrc+"base/"+filename), gdf.get(dirsrc+"hfrz/"+filenane)]

#nds = xr.open_mfdataset(
#    nfiles,
#    concat_dim='case',
#    combine='nested',
#)

ds1title="base"
ds1 = xr.open_dataset(dirsrc+"base/"+filename)

ds2title="hfrz"
ds2 = xr.open_dataset(dirsrc+"hfrz/"+filename)

# point location
#ipt=63-1
#jpt=7-1

#lmin=0
#lmax=360


# Panels same figure
nrow=1
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(10, 8), sharex=True)
# Import an NCL colormap
#ncl_cmap_name = 'BlueWhiteOrangeRed'
#newcmp = cmaps.BlueWhiteOrangeRed
pltlevels=np.arange(-0.01,0.01,.001)

# panel 1
ii=0
varname="aice_h"
#varname1="aice_h"
#varname2="aice_h"
#var1=ds1[varname1].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
#var2=ds2[varname2].isel(ni=ipt,nj=jpt,time=slice(lmin,lmax))
#tvals=ds1.time.isel(time=slice(lmin,lmax))
diff=10.0*(ds2[varname].isel(time=0)-ds1[varname].isel(time=0))
p = diff.plot.contourf(
    ax=axs,
    levels=pltlevels
)

#plt.title(dstitle)

#axs[ii].set_title(varname)
#axs[ii].set_ylabel(var1.attrs.get("units", ""))
#axs[ii].set_xlabel("Time")

plt.show()

exit()
