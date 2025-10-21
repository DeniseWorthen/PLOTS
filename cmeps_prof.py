import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset
dirsrc="/Users/toby/GitHub/Lockbox/"


#ds1title="post_atm"
#data1 = np.loadtxt(dirsrc+"tst1/post_atm.dat")
#data2 = np.loadtxt(dirsrc+"tst2/post_atm.dat")

#ds2title="post_ice"
#data1 = np.loadtxt(dirsrc+"tst1/post_ice.dat")
#data2 = np.loadtxt(dirsrc+"tst2/post_ice.dat")

#ds3title="post_ocn"
#data1 = np.loadtxt(dirsrc+"tst1/post_ocn.dat")
#data2 = np.loadtxt(dirsrc+"tst2/post_ocn.dat")

# pecnt=data1[:,0]
# ds = xr.Dataset(
#     {"mean": (("pecnt"), data[:, 1]),
#      "min": (("pecnt"),  data[:, 2]),
#      "max": (("pecnt"),  data[:, 3])},
#     coords={"pecnt": pecnt}
# )

# Panels same figure
nrow=4
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(10, 8), sharex=True)

# panel 1
ii=0
dstitle="RHinit"
data1 = np.loadtxt(dirsrc+"tst1/rhinit.dat")
data2 = np.loadtxt(dirsrc+"tst2/rhinit.dat")
pecnt=data1[:,0]
ds1 = xr.Dataset(
    {"mean": (("pecnt"), data1[:, 1]),
     "min": (("pecnt"),  data1[:, 2]),
     "max": (("pecnt"),  data1[:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), data2[:, 1]),
     "min": (("pecnt"),  data2[:, 2]),
     "max": (("pecnt"),  data2[:, 3])},
    coords={"pecnt": pecnt}
)

axs[ii].set_title(dstitle)
axs[ii].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ii].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
axs[ii].set_xlabel("PE count")

# panel 2
ii=1
dstitle="post_atm"
data1 = np.loadtxt(dirsrc+"tst1/post_atm.dat")
data2 = np.loadtxt(dirsrc+"tst2/post_atm.dat")
pecnt=data1[:,0]
ds1 = xr.Dataset(
    {"mean": (("pecnt"), data1[:, 1]),
     "min": (("pecnt"),  data1[:, 2]),
     "max": (("pecnt"),  data1[:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), data2[:, 1]),
     "min": (("pecnt"),  data2[:, 2]),
     "max": (("pecnt"),  data2[:, 3])},
    coords={"pecnt": pecnt}
)
axs[ii].set_title(dstitle)
axs[ii].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ii].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ii].set_xlabel("PE count")

# panel 3
ii=2
dstitle="post_ice"
data1 = np.loadtxt(dirsrc+"tst1/post_ice.dat")
data2 = np.loadtxt(dirsrc+"tst2/post_ice.dat")
pecnt=data1[:,0]
ds1 = xr.Dataset(
    {"mean": (("pecnt"), data1[:, 1]),
     "min": (("pecnt"),  data1[:, 2]),
     "max": (("pecnt"),  data1[:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), data2[:, 1]),
     "min": (("pecnt"),  data2[:, 2]),
     "max": (("pecnt"),  data2[:, 3])},
    coords={"pecnt": pecnt}
)
axs[ii].set_title(dstitle)
axs[ii].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ii].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ii].set_xlabel("PE count")


# panel 4
ii=3
dstitle="post_ocn"
data1 = np.loadtxt(dirsrc+"tst1/post_ocn.dat")
data2 = np.loadtxt(dirsrc+"tst2/post_ocn.dat")
pecnt=data1[:,0]
ds1 = xr.Dataset(
    {"mean": (("pecnt"), data1[:, 1]),
     "min": (("pecnt"),  data1[:, 2]),
     "max": (("pecnt"),  data1[:, 3])},
    coords={"pecnt": pecnt}
)
ds2 = xr.Dataset(
    {"mean": (("pecnt"), data2[:, 1]),
     "min": (("pecnt"),  data2[:, 2]),
     "max": (("pecnt"),  data2[:, 3])},
    coords={"pecnt": pecnt}
)
axs[ii].set_title(dstitle)
axs[ii].plot(pecnt, ds1["mean"],marker='o', label="base")
axs[ii].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
#axs[ii].set_xlabel("PE count")



# Add grid and legends to subplots
for ax in axs:
    ax.grid(True)
    ax.legend()

plt.tight_layout()
plt.show()



# plt.plot(pecnt,ds1["mean"],marker='o',label="RHinit")
# plt.plot(pecnt,ds2["mean"],marker='o',label="RHinit, mapfiles")
# #plt.fill_between(var1,varmin,varmax)
# #plt.scatter(pecnt,var1,label="arwt heat error: Arctic")
# #plt.plot(pecnt,var2,label="arwt heat error: Antarctic")

# #plt.title(ds1title)
# #plt.ylabel(var1.attrs.get("units", ""))

# plt.xlabel("PE Count")
# plt.ylabel("Mean time")
# plt.grid(True)
# plt.legend()

# plt.tight_layout()
# #ds.plot()
# #plt.show()
# #ds.plot()
# plt.show()
