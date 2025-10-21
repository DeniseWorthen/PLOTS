import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset
dirsrc="/Users/toby/GitHub/Lockbox/"

data0 = np.loadtxt(dirsrc+"tst1/rhinit.dat")
data1 = np.loadtxt(dirsrc+"tst1/post_atm.dat")
data2 = np.loadtxt(dirsrc+"tst1/post_ice.dat")
data3 = np.loadtxt(dirsrc+"tst1/post_ocn.dat")
data4 = np.loadtxt(dirsrc+"tst1/post_wav.dat")
tst1dat = np.stack([data0,data1,data2,data3,data4],axis=0)
#print('rhinit data ')
#print(tst1dat[3,:,:])
#print('post_ocn data ')
#print(tst1dat[3,:,1])
#print(tst1dat[3,:,2])
#print(tst1dat[3,:,3])

data0 = np.loadtxt(dirsrc+"tst2/rhinit.dat")
data1 = np.loadtxt(dirsrc+"tst2/post_atm.dat")
data2 = np.loadtxt(dirsrc+"tst2/post_ice.dat")
data3 = np.loadtxt(dirsrc+"tst2/post_ocn.dat")
data4 = np.loadtxt(dirsrc+"tst2/post_wav.dat")
tst2dat = np.stack([data0,data1,data2,data3,data4],axis=0)
#print("tst2")
#print(tst2dat)

# pecnt=tst1dat[0,:,0]
# print(pecnt)
# ds1 = xr.Dataset(
#     {"mean": (("pecnt"), tst1dat[:,:,1]),
#      "min": (("pecnt"),  tst1dat[:,:,2]),
#      "max": (("pecnt"),  tst1dat[:,:,3])},
#     coords={"pecnt": tst1dat[:,:,0]}
# )

# Panels same figure
nrow=5
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(8,10), sharex=True)

# panel 1
ipanel=0; idata=0
dstitle="RHinit"
pecnt=tst1dat[0,:,0]
ds1 = xr.Dataset(
    {"mean": (("pecnt"), tst1dat[idata,:, 1]),
     "min": (("pecnt"),  tst1dat[idata,:, 2]),
     "max": (("pecnt"),  tst1dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), tst2dat[idata,:, 1]),
     "min": (("pecnt"),  tst2dat[idata,:, 2]),
     "max": (("pecnt"),  tst2dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)

axs[ipanel].set_title(dstitle)
axs[ipanel].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ipanel].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ipanel].set_xlabel("PE count")

# panel 2
ipanel=1; idata=1
dstitle="post_atm"
ds1 = xr.Dataset(
    {"mean": (("pecnt"), tst1dat[idata,:, 1]),
     "min": (("pecnt"),  tst1dat[idata,:, 2]),
     "max": (("pecnt"),  tst1dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), tst2dat[idata,:, 1]),
     "min": (("pecnt"),  tst2dat[idata,:, 2]),
     "max": (("pecnt"),  tst2dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)

axs[ipanel].set_title(dstitle)
axs[ipanel].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ipanel].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ipanel].set_xlabel("PE count")

# panel 3
ipanel=2; idata=2
dstitle="post_ice"
ds1 = xr.Dataset(
    {"mean": (("pecnt"), tst1dat[idata,:, 1]),
     "min": (("pecnt"),  tst1dat[idata,:, 2]),
     "max": (("pecnt"),  tst1dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), tst2dat[idata,:, 1]),
     "min": (("pecnt"),  tst2dat[idata,:, 2]),
     "max": (("pecnt"),  tst2dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)

axs[ipanel].set_title(dstitle)
axs[ipanel].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ipanel].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ipanel].set_xlabel("PE count")

# panel 4
ipanel=3; idata=3
dstitle="post_ocn"
ds1 = xr.Dataset(
    {"mean": (("pecnt"), tst1dat[idata,:, 1]),
     "min": (("pecnt"),  tst1dat[idata,:, 2]),
     "max": (("pecnt"),  tst1dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), tst2dat[idata,:, 1]),
     "min": (("pecnt"),  tst2dat[idata,:, 2]),
     "max": (("pecnt"),  tst2dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)

axs[ipanel].set_title(dstitle)
axs[ipanel].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ipanel].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ipanel].set_xlabel("PE count")

# panel 5
ipanel=4; idata=4
dstitle="post_wav"
ds1 = xr.Dataset(
    {"mean": (("pecnt"), tst1dat[idata,:, 1]),
     "min": (("pecnt"),  tst1dat[idata,:, 2]),
     "max": (("pecnt"),  tst1dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), tst2dat[idata,:, 1]),
     "min": (("pecnt"),  tst2dat[idata,:, 2]),
     "max": (("pecnt"),  tst2dat[idata,:, 3])},
    coords={"pecnt": pecnt}
)

axs[ipanel].set_title(dstitle)
axs[ipanel].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ipanel].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
axs[ipanel].set_xlabel("PE count")

# Add grid and legends to subplots
for ax in axs:
    ax.grid(True)
    ax.legend()

plt.tight_layout()
plt.show()
