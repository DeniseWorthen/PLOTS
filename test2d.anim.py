import matplotlib.pyplot as plt
import matplotlib.animation as animation
import xarray as xr
import numpy as np
import cmaps
import geocat.viz as gv

# 1. Configuration & Registry
var_settings = {
    "aice_h": {"range": (0, 1, 0.1), "cmap": cmaps.WhiteBlueGreenYellowRed},
    "hi_h":   {"range": (0, 5, 0.5), "cmap": cmaps.BlAqGrYeOrRe},
}

# --- USER SELECTION (1-BASED) ---
target_var = "aice_h"
# User provides 1-based start and end indices
x_start, x_end = 51, 151
y_start, y_end = 21, 101
# --------------------------------

# 2. Conversion to 0-Based for Python
# Python slices are (inclusive, exclusive).
# Subtracting 1 from the start makes it 0-based.
# Leaving the end as-is makes it exclusive in Python (capturing up to x_end-1).
x_slice = slice(x_start - 1, x_end)
y_slice = slice(y_start - 1, y_end)

settings = var_settings[target_var]
vmin, vmax, vstep = settings["range"]
clevels = np.arange(vmin, vmax + vstep, vstep)

# 3. Setup Figure
fig, axs = plt.subplots(1, 2, figsize=(15, 7), constrained_layout=True)

# 4. Update function
def update(frame):
    for ax in axs:
        ax.clear()

    for i in range(2):
        # Select data using converted 0-based slices
        data_slice = nds[target_var].isel(
            case=i,
            T=frame,
            X=x_slice,
            Y=y_slice
        )

        im = data_slice.plot(
            ax=axs[i],
            cmap=settings["cmap"],
            levels=clevels,
            extend='both',
            add_colorbar=False
        )

        gv.set_titles_and_labels(
            axs[i],
            maintitle=f"Case {i+1}: {target_var}",
            lefttitle=f"Time Index: {frame + 1}", # Label as 1-based for the user
            righttitle=f"X:[{x_start},{x_end}] Y:[{y_start},{y_end}]"
        )
    return axs

# 5. Animate and Save
ani = animation.FuncAnimation(fig, update, frames=len(nds.T), interval=200)
ani.save(f'{target_var}_1based_cropped.gif', writer='pillow', fps=5)

plt.show()
