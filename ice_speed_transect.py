import os
import numpy as np
import matplotlib.pyplot as plt
import xarray as xr

# --- USER SETTINGS ---
dirsrc = "/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen"
files = os.path.join(dirsrc, "hi*.ice.nc")

# Transect endpoints (1-based indices)
x1, y1 = 1, 1
x2, y2 = 66, 71

# Sampling settings
num_points = 100  # number of samples along the transect

# Which case/time to plot (1-based)
case_index = 1
frame_index = 1

# Velocity components to use for speed
u_name = "uvelN_h"
v_name = "vvelN_h"

# ---------------------

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

# Convert to 0-based indices
x1_i, y1_i = x1 - 1, y1 - 1
x2_i, y2_i = x2 - 1, y2 - 1
case_i = case_index - 1
frame_i = frame_index - 1

# Build transect coordinates
x_line = np.linspace(x1_i, x2_i, num_points)
y_line = np.linspace(y1_i, y2_i, num_points)

# Get speed field for the selected case/time
u = nds[u_name].isel(case=case_i, time=frame_i)
v = nds[v_name].isel(case=case_i, time=frame_i)
spd = np.sqrt(u**2 + v**2)

# Interpolate speed along the transect
transect = spd.interp(ni=("points", x_line), nj=("points", y_line))

# Distance along the transect (index-based)
dist = np.sqrt((x_line - x_line[0])**2 + (y_line - y_line[0])**2)

# Plot
plt.figure(figsize=(10, 4))
plt.plot(dist, transect.values, lw=2)
plt.xlabel("Distance along transect (grid units)")
plt.ylabel("Ice speed (m/s)")
plt.title(f"Ice speed along transect: ({x1},{y1}) to ({x2},{y2})\nCase {case_index}, Time {frame_index}")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
