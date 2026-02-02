import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

# Set default linewidth to 0.8 for all lines
plt.rcParams['lines.linewidth'] = 0.8

# Load dataset
#dirsrc="/gpfs/f6/infra-cpu/world-shared/Denise.Worthen/freerun2021/"
dirsrc="/scratch3/NCEPDEV/stmp/Denise.Worthen/residual.ice/"

filename="heaterror"
varname="arwt heat error"
varunits=" "

#filename="icearea"
#varname="total ice area"
#varunits="km^2"

#filename="iceextent"
#varname="total ice extent"
#varunits="km^2"

#filename="icevolume"
#varname="total ice volume"
#varunits="m^3"

runnames = np.array(['base',
                     'zap: dyn_area_min=1.-3, dyn_mass_min=1.e-2',
                     'zap: dyn_area_min=1.-7, dyn_mass_min=1.e-6',
                     'zap: dyn_area_min=1.-11, dyn_mass_min=1.e-10']
                    )
#print(runnames)

data0 = np.loadtxt(dirsrc+filename+".sfs.dev.dat")
data1 = np.loadtxt(dirsrc+filename+".sfs.run1.dat")
data2 = np.loadtxt(dirsrc+filename+".sfs.run2.dat")
data3 = np.loadtxt(dirsrc+filename+".sfs.run3.dat")

#lens=np.array([len(data1),len(data2),len(data3)])
lens=np.array([len(data0),len(data1),len(data2),len(data3)])
minlen=np.min(lens)

#print(minlen)
#print(100.0*(data3[minlen-1,1]-data0[minlen-1,1])/data0[minlen-1,1])

start_date = '2021-05-01 06:00:00'
#end_date = '2021-06-16 00:00:00'

time_axis = xr.date_range(start=start_date, periods=minlen, freq='6h')
#print(time_axis)

ds = xr.Dataset(
   {"valn0": (("time"), data0[0:minlen, 0]),
    "vals0": (("time"), data0[0:minlen, 1]),
    "valn1": (("time"), data1[0:minlen, 0]),
    "vals1": (("time"), data1[0:minlen, 1]),
    "valn2": (("time"), data2[0:minlen, 0]),
    "vals2": (("time"), data2[0:minlen, 1]),
    "valn3": (("time"), data3[0:minlen, 0]),
    "vals3": (("time"), data3[0:minlen, 1])
    },
   coords={"time": time_axis}
)

# Panels same figure
nrow=2
ncol=1
fig, axs = plt.subplots(nrow, ncol, figsize=(10, 8), sharex=True)

# panel 1
ii=0
reg="Arctic"
var0=ds["valn0"]
var1=ds["valn1"]
var2=ds["valn2"]
var3=ds["valn3"]
tvals=ds["time"]

axs[ii].set_title(varname+": "+reg)
axs[ii].plot(tvals, var0)
axs[ii].plot(tvals, var1)
axs[ii].plot(tvals, var2)
axs[ii].plot(tvals, var3)
axs[ii].set_ylabel(varunits)

# panel 2
ii=1
reg="Antarctic"
var0=ds["vals0"]
var1=ds["vals1"]
var2=ds["vals2"]
var3=ds["vals3"]
tvals=ds["time"]
axs[ii].set_title(varname+": "+reg)
axs[ii].plot(tvals, var0, label=runnames[0])
axs[ii].plot(tvals, var1, label=runnames[1])
axs[ii].plot(tvals, var2, label=runnames[2])
axs[ii].plot(tvals, var3, label=runnames[3])
axs[ii].set_ylabel(varunits)
axs[ii].set_xlabel("Time")


# Add grid and legends to subplots
for ax in axs:
    ax.grid(True)
#    ax.legend()

# Collect handles and labels from all subplots
handles, labels = [], []
for ax in axs:
    h, l = ax.get_legend_handles_labels()
    handles.extend(h)
    labels.extend(l)

# Place the legend outside the panel
fig.legend(handles, labels, loc='lower right', bbox_to_anchor=(.98, 0.0))
fig.tight_layout(rect=[0, .15, 1, 1]) # Adjust rect to leave space on the right)

plt.show()

#plt.savefig("test", dpi=150)
exit()
