import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset
dirsrc="/Users/toby/GitHub/Lockbox/"

#data1 = np.loadtxt(dirsrc+"tst1/rhinit.dat")
#data2 = np.loadtxt(dirsrc+"tst2/rhinit.dat")

data1 = np.loadtxt(dirsrc+"tst1/post_ocn.dat")
data2 = np.loadtxt(dirsrc+"tst2/post_ocn.dat")

pecnt=data1[:,0]

#print(data1)
#print(pecnt)

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

#var1=ds["mean"]
#varmin=ds["min"]
#varmax=ds["max"]

#print(ds)
plt.figure(figsize=(10, 6))

plt.plot(pecnt,ds1["mean"],marker='o',label="RHinit")
plt.plot(pecnt,ds2["mean"],marker='o',label="RHinit, mapfiles")
#plt.fill_between(var1,varmin,varmax)
#plt.scatter(pecnt,var1,label="arwt heat error: Arctic")
#plt.plot(pecnt,var2,label="arwt heat error: Antarctic")

#plt.title(ds1title)
#plt.ylabel(var1.attrs.get("units", ""))

plt.xlabel("PE Count")
plt.ylabel("Mean time")
plt.grid(True)
plt.legend()

plt.tight_layout()
#ds.plot()
#plt.show()
#ds.plot()
plt.show()
