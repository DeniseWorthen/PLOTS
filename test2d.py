import matplotlib.pyplot as plt
import xarray as xr
import numpy as np
import cmaps
import geocat.viz as gv

# 1. Define your variable registry (Pre-defined ranges)
var_settings = {
    "aice_h": {"range": (0, 1, 0.1), "cmap": cmaps.WhiteBlueGreenYellowRed},
    "hi_h":   {"range": (0, 5, 0.5), "cmap": cmaps.BlAqGrYeOrRe},
    "temp":   {"range": (-2, 30, 2), "cmap": cmaps.NCV_jet},
}

# 2. USER SELECTION: Pick one variable name
target_var = "aice_h"
time_idx = 0

# 3. Retrieve settings dynamically
settings = var_settings[target_var]
vmin, vmax, vstep = settings["range"]
selected_cmap = settings["cmap"]

# Create levels (vmax + vstep ensures the max value is included)
clevels = np.arange(vmin, vmax + vstep, vstep)

# 4. Plotting logic
fig, axs = plt.subplots(1, 2, figsize=(15, 7), constrained_layout=True)

for i in range(2):
    # Dynamically select variable from nds
    data_slice = nds[target_var].isel(case=i, T=time_idx)

    im = data_slice.plot(
        ax=axs[i],
        cmap=selected_cmap,
        levels=clevels,
        extend='both',
        add_colorbar=False
    )

    gv.set_titles_and_labels(axs[i], maintitle=f"Case {i+1}: {target_var}")

# Shared colorbar
fig.colorbar(im, ax=axs, orientation='horizontal', shrink=0.5, ticks=clevels)

plt.show()
