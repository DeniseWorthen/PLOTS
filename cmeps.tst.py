import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# tests were run for 45hrs (not 48), so convert times from totals to s/day
# dt atm/ice = 150; dt ocn/wav = 1800; time steps/day atm/ice = 576; ow = 48

aifac = 576/1080
owfac = 48/90
print (aifac,owfac)

# Load dataset
dirsrc="/Users/max/GitHub/Lockbox/"

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

data0 = np.loadtxt(dirsrc+"tst3/rhinit.dat")
data1 = np.loadtxt(dirsrc+"tst3/post_atm.dat")
data2 = np.loadtxt(dirsrc+"tst3/post_ice.dat")
data3 = np.loadtxt(dirsrc+"tst3/post_ocn.dat")
data4 = np.loadtxt(dirsrc+"tst3/post_wav.dat")
tst3dat = np.stack([data0,data1,data2,data3,data4],axis=0)

data0 = np.loadtxt(dirsrc+"tst4/rhinit.dat")
data1 = np.loadtxt(dirsrc+"tst4/post_atm.dat")
data2 = np.loadtxt(dirsrc+"tst4/post_ice.dat")
data3 = np.loadtxt(dirsrc+"tst4/post_ocn.dat")
data4 = np.loadtxt(dirsrc+"tst4/post_wav.dat")
tst4dat = np.stack([data0,data1,data2,data3,data4],axis=0)

# Panels same figure
factors=[1.0,1.0,1.0,1.0,1.0,1.0]
#factors = [1.0, aifac, aifac, owfac, owfac]
print(factors)
titles = ['RHinit','post_atm','post_ice','post_ocn','post_wav']
nrow=len(titles)
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(8,10), sharex=True)

for ii, title in enumerate(titles):
    pecnt=tst1dat[0,:,0]
    ds1 = xr.Dataset(
        {"mean": (("pecnt"), factors[ii]*tst1dat[ii,:, 1]),
         "min": (("pecnt"),  factors[ii]*tst1dat[ii,:, 2]),
         "max": (("pecnt"),  factors[ii]*tst1dat[ii,:, 3])},
        coords={"pecnt": pecnt}
    )

    ds2 = xr.Dataset(
        {"mean": (("pecnt"), factors[ii]*tst2dat[ii,:, 1]),
         "min": (("pecnt"),  factors[ii]*tst2dat[ii,:, 2]),
         "max": (("pecnt"),  factors[ii]*tst2dat[ii,:, 3])},
        coords={"pecnt": pecnt}
    )
    ds3 = xr.Dataset(
        {"mean": (("pecnt"), factors[ii]*tst3dat[ii,:, 1]),
         "min": (("pecnt"),  factors[ii]*tst3dat[ii,:, 2]),
         "max": (("pecnt"),  factors[ii]*tst3dat[ii,:, 3])},
        coords={"pecnt": pecnt}
    )

    ds4 = xr.Dataset(
        {"mean": (("pecnt"), factors[ii]*tst4dat[ii,:, 1]),
         "min": (("pecnt"),  factors[ii]*tst4dat[ii,:, 2]),
         "max": (("pecnt"),  factors[ii]*tst4dat[ii,:, 3])},
        coords={"pecnt": pecnt}
    )

    axs[ii].set_title(title)
    axs[ii].plot(pecnt, ds1["mean"],marker='o', label="base")
    #axs[ii].plot(pecnt, ds2["mean"],marker='o', label="mapfiles")
    axs[ii].plot(pecnt, ds3["mean"],marker='o', label="cmeps rhs")
    axs[ii].plot(pecnt, ds4["mean"],marker='o', label="cmeps rhs (rpt)")

    axs[nrow-1].set_xlabel("PE count")

# Add grid and legends to subplots
for ax in axs:
    ax.grid(True)
    ax.legend()

plt.tight_layout()
plt.show()
