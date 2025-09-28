import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Load dataset

#dirsrc="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"
dirsrc="/scratch3/NCEPDEV/stmp/Denise.Worthen/residual.ice/"

#filename="heaterror"
#varname="arwt heat error"
#varunits=" "

#filename="icearea"
#varname="total ice area"
#varunits="km^2"

#filename="iceextent"
#varname="total ice extent"
#varunits="km^2"

filename="icevolume"
varname="total ice volume"
varunits="m^3"

runnames = np.array(['base',
                     'zap: dyn_area_min=1.-3, dyn_mass_min=1.e-2',
                     'zap: dyn_area_min=1.-7, dyn_mass_min=1.e-6'])
#print(runnames)

data1 = np.loadtxt(dirsrc+filename+".sfs.dev.dat")
data2 = np.loadtxt(dirsrc+filename+".sfs.run1.dat")
data3 = np.loadtxt(dirsrc+filename+".sfs.run2.dat")

lens=np.array([len(data1),len(data2),len(data3)])
minlen=np.min(lens)
#print(minlen)

start_date = '2021-05-01 06:00:00'
#end_date = '2021-06-16 00:00:00'

time_axis = xr.date_range(start=start_date, periods=minlen, freq='6h')
#print(time_axis)

ds = xr.Dataset(
   {"valn1": (("time"), data1[0:minlen, 0]),
    "vals1": (("time"), data1[0:minlen, 1]),
    "valn2": (("time"), data2[0:minlen, 0]),
    "vals2": (("time"), data2[0:minlen, 1]),
    "valn3": (("time"), data3[0:minlen, 0]),
    "vals3": (("time"), data3[0:minlen, 1])},
   coords={"time": time_axis}
)

#reg="Arctic"
#var1=ds["valn1"]
#var2=ds["valn2"]
#var3=ds["valn3"]

reg="Antarctic"
var1=ds["vals1"]
var2=ds["vals2"]
var3=ds["vals3"]
tvals=ds["time"]

plt.figure(figsize=(10, 6))
plt.plot(tvals,var1,label=runnames[0])
plt.plot(tvals,var2,label=runnames[1])
plt.plot(tvals,var3,label=runnames[2])

plt.title(varname+": "+reg)
plt.ylabel(varunits)
plt.xlabel("Time")
plt.grid(True)
plt.legend()

plt.tight_layout()
#ds.plot()
#plt.show()
#ds.plot()
plt.show()
