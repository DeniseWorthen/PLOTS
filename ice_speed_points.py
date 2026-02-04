import os
import numpy as np
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd

# --- USER SETTINGS ---
dirsrc = "/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen"
files = os.path.join(dirsrc, "hi*.ice.nc")

# List of points to sample (1-based indices)
# Replace with your exact list of (x, y) pairs
points_xy_1based = [
    # (x, y),
    (25, 44),
    (26, 42),
    (27, 40),
    (28, 39),
    (29, 38),
    (30, 37),
    (31, 36),
    (32, 35),
    (33, 34),
    (34, 33)
]

# Which case/time to plot (1-based)
case_index = 1
frame_index = 100

# Case labels for legend
case_labels = ["Case 1", "Case 2", "Case 3"]

# Velocity components to use for speed (per case)
u_names = ["uvel_h", "uvelN_h", "uvelN_h"]
v_names = ["vvel_h", "vvelN_h", "vvelN_h"]

# ---------------------

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

# Extract and convert time axis
if "time" in nds:
    time_values = pd.to_datetime(nds["time"].values)
else:
    time_values = None

# Convert to 0-based indices
points = np.array([(x - 1, y - 1) for x, y in points_xy_1based], dtype=int)
xs = points[:, 0]
ys = points[:, 1]
case_i = case_index - 1
frame_i = frame_index - 1

# Distance along point list (index-based)
dist = np.arange(len(points))

# Get formatted time string
if time_values is not None:
    time_str = time_values[frame_i].strftime("%Y %m %d %H")
else:
    time_str = f"Frame {frame_index}"

plt.figure(figsize=(10, 4))

for case_i in range(len(case_labels)):
    u = nds[u_names[case_i]].isel(case=case_i, time=frame_i)
    v = nds[v_names[case_i]].isel(case=case_i, time=frame_i)
    spd = np.sqrt(u ** 2 + v ** 2)

    # Sample only the specified points
    values = spd.values[ys, xs]

    markers = ["o", "s", "^"]
    plt.plot(dist, values, lw=1, marker=markers[case_i],
             markersize=4, markevery=1, label=case_labels[case_i])

plt.xlabel("Point index along list")
plt.ylabel("Ice speed (m/s)")
plt.title(f"Ice speed along specified points\nTime: {time_str}")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
