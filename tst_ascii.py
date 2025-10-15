import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset
dirsrc="/scratch3/NCEPDEV/stmp/Denise.Worthen/residual.ice/"

data = np.loadtxt(dirsrc+"heaterror.sfs.dev.dat")
#print(data.shape[0])

# known start date and frequency of data
start_date = '2021-05-01 06:00:00'
time_axis = xr.date_range(start=start_date, periods=len(data), freq='6h')
#print(time_axis)

# create a dataset from the two data columns and the time axis
ds = xr.Dataset(
    {"hen": (("time"), data[:, 0]),
     "hes": (("time"), data[:, 1])},
    coords={"time": time_axis}
)

var1=ds["hen"]
var2=ds["hes"]
tvals=ds["time"]
#print(ds)

# plot the data vs time and label the lines
plt.figure(figsize=(10, 6))
plt.plot(tvals,var1,label="arwt heat error: Arctic")
plt.plot(tvals,var2,label="arwt heat error: Antarctic")

plt.xlabel("Time")
plt.grid(True)
plt.legend()

plt.tight_layout()
plt.show()
