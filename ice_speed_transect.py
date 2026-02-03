import os
import numpy as np
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd
from scipy.interpolate import griddata

# --- USER SETTINGS ---
dirsrc = "/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen"
files = os.path.join(dirsrc, "hi*.ice.nc")

# Transect endpoints (1-based indices)
x1, y1 = 20, 52
x2, y2 = 35, 32

# Sampling settings
num_points = 100  # number of samples along the transect

# Which case/time to plot (1-based)
case_index = 1
frame_index = 1

# Case labels for legend
case_labels = ["Case 1", "Case 2"]

# Velocity components to use for speed
u_name = "uvelN_h"
v_name = "vvelN_h"

# ---------------------

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

# Extract and convert time axis
time_values = pd.to_datetime(nds['time'].values)

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

# Use scipy's griddata to interpolate, which handles NaN values by interpolating from valid neighbors
# Create grid of all points
yi, xi = np.meshgrid(np.arange(spd.shape[0]), np.arange(spd.shape[1]))
points = np.column_stack([xi.ravel(), yi.ravel()])
values = spd.values.ravel()

# Remove NaN points
valid = ~np.isnan(values)
points_valid = points[valid]
values_valid = values[valid]

# Interpolate transect using linear interpolation on valid points
pts_transect = np.column_stack([x_line, y_line])
transect_values = griddata(points_valid, values_valid, pts_transect, method='linear')

# Distance along the transect (index-based)
dist = np.sqrt((x_line - x_line[0])**2 + (y_line - y_line[0])**2)

# Get formatted time string
time_str = time_values[frame_i].strftime('%Y %m %d %H')

# Plot both cases
plt.figure(figsize=(10, 4))

for case_i in range(2):
    # Get speed field for this case
    u = nds[u_name].isel(case=case_i, time=frame_i)
    v = nds[v_name].isel(case=case_i, time=frame_i)
    spd = np.sqrt(u**2 + v**2)
    
    # Use scipy's griddata to interpolate, which handles NaN values by interpolating from valid neighbors
    # Create grid of all points
    yi, xi = np.meshgrid(np.arange(spd.shape[0]), np.arange(spd.shape[1]))
    points = np.column_stack([xi.ravel(), yi.ravel()])
    values = spd.values.ravel()
    
    # Remove NaN points
    valid = ~np.isnan(values)
    points_valid = points[valid]
    values_valid = values[valid]
    
    # Interpolate transect using linear interpolation on valid points
    pts_transect = np.column_stack([x_line, y_line])
    transect_values = griddata(points_valid, values_valid, pts_transect, method='linear')
    
    # Plot with different markers for each case
    markers = ['o', 's']  # circle, square
    plt.plot(dist, transect_values, lw=1, marker=markers[case_i], 
             markersize=4, markevery=5, label=case_labels[case_i])
plt.xlabel("Distance along transect (grid units)")
plt.ylabel("Ice speed (m/s)")
plt.title(f"Ice speed along transect: ({x1},{y1}) to ({x2},{y2})\nTime: {time_str}")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
