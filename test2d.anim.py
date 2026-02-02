import matplotlib.pyplot as plt
import matplotlib.animation as animation
import xarray as xr
import numpy as np
import cmaps
import geocat.datafiles as gdf
import geocat.viz as gv

# --- 1. CONFIGURATION REGISTRY ---
var_settings = {
    "aice_h": {"range": (0, 1, 0.1), "cmap": cmaps.WhiteBlueGreenYellowRed},
    "hi_h":   {"range": (0, 5, 0.5), "cmap": cmaps.BlAqGrYeOrRe},
    "spd":    {"range": (0, 2, 0.2), "cmap": cmaps.precip2_17lev},
}

# --- 2. USER INPUTS (1-BASED) ---
target_var = "spd"
x_start, x_end = 1, 150   # 1-based indices
y_start, y_end = 1, 150   # 1-based indices

# --- 3. DATA SETUP ---
dirsrc = "path to output"
nfiles = [gdf.get(dirsrc + "file1.nc"), gdf.get(dirsrc + "file2.nc")]

# Open dataset lazily using open_mfdataset
nds = xr.open_mfdataset(nfiles, concat_dim='case', combine='nested')

# AUTOMATIC CHECK: Only calculate spd if requested
if target_var == "spd" and "spd" not in nds:
    nds = nds.assign(spd = np.sqrt(nds['uvel_h']**2 + nds['vvel_h']**2))
    nds.spd.attrs['units'] = 'm/s' # Optional: add metadata

# --- 4. COORDINATE CONVERSION ---
x_slice = slice(x_start - 1, x_end)
y_slice = slice(y_start - 1, y_end)

settings = var_settings[target_var]
vmin, vmax, vstep = settings["range"]
clevels = np.arange(vmin, vmax + vstep, vstep)

# --- 5. ANIMATION LOGIC ---
fig, axs = plt.subplots(1, 2, figsize=(15, 7), constrained_layout=True)

def update(frame):
    for ax in axs: ax.clear()

    for i in range(2):
        data_slice = nds[target_var].isel(case=i, T=frame, X=x_slice, Y=y_slice)

        im = data_slice.plot(ax=axs[i], cmap=settings["cmap"], levels=clevels,
                             extend='both', add_colorbar=False)

        gv.set_titles_and_labels(axs[i],
                                 maintitle=f"Case {i+1}: {target_var}",
                                 lefttitle=f"Time Index: {frame + 1}")
    return axs

ani = animation.FuncAnimation(fig, update, frames=len(nds.T), interval=200)

# Save as GIF
ani.save(f'{target_var}_comparison.gif', writer='pillow', fps=5)
plt.show()
