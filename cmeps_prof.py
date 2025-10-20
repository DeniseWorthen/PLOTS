import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

#dirsrc="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"
dirsrc="/Users/max/Github/PLOTS/"

#start_date = '2021-05-01 06:00:00'
#end_date = '2021-08-16 00:00:00'

#time_axis = xr.date_range(start=start_date, end=end_date, freq='6H')
#print(time_axis)

data = np.loadtxt(dirsrc+"fakedat.dat")
#print(data.shape[0])
#print(data)

#print(data)
#hen="arwt heat error"

pecnt=data[:,0]

print(data)
#print(pecnt)

ds = xr.Dataset(
    {"mean": (("pecnt"), data[:, 1]),
     "min": (("pecnt"),  data[:, 2]),
     "max": (("pecnt"),  data[:, 4])},
    coords={"pecnt": pecnt}
)

var1=ds["mean"]
varmin=ds["min"]
varmax=ds["max"]
#var2=ds["hes"]
#tvals=ds["time"]
print(var1)
print(varmin)
print(varmax)

#print(ds)
plt.figure(figsize=(10, 6))
#plt.plot(pecnt,var1,label="arwt heat error: Antarctic")
#plt.fill_between(var1,varmin,varmax)
plt.scatter(pecnt,var1,label="arwt heat error: Arctic")
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
