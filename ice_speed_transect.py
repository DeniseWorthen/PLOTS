import os
from collections import deque

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

# Stair-step settings (path along water points)
stair_step = True
water_var = "aice_h"
water_maxice = 0.15  # water where ice concentration <= this

# Which case/time to plot (1-based)
case_index = 1
frame_index = 100

# Time averaging option
time_average = False      # Set True to average over all time steps
minice = 0.15            # Minimum ice concentration threshold for averaging

# Case labels for legend
case_labels = ["Case 1", "Case 2"]

# Velocity components to use for speed
u_name = "uvelN_h"
v_name = "vvelN_h"

# ---------------------


def find_water_path(mask, start_xy, end_xy):
    """Find 4-neighbor shortest path on a boolean water mask."""
    h, w = mask.shape
    sx, sy = start_xy
    ex, ey = end_xy

    if not (0 <= sx < w and 0 <= sy < h and 0 <= ex < w and 0 <= ey < h):
        return None
    if not (mask[sy, sx] and mask[ey, ex]):
        return None

    visited = np.zeros((h, w), dtype=bool)
    prev = np.full((h, w, 2), -1, dtype=int)
    q = deque([(sx, sy)])
    visited[sy, sx] = True

    neighbors = ((1, 0), (-1, 0), (0, 1), (0, -1))
    while q:
        x, y = q.popleft()
        if x == ex and y == ey:
            break
        for dx, dy in neighbors:
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[ny, nx] and mask[ny, nx]:
                visited[ny, nx] = True
                prev[ny, nx] = (x, y)
                q.append((nx, ny))

    if not visited[ey, ex]:
        return None

    path = []
    cx, cy = ex, ey
    while not (cx == sx and cy == sy):
        path.append((cx, cy))
        cx, cy = prev[cy, cx]
    path.append((sx, sy))
    path.reverse()
    return path

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

# Extract and convert time axis
time_values = pd.to_datetime(nds['time'].values)

# Convert to 0-based indices
x1_i, y1_i = x1 - 1, y1 - 1
x2_i, y2_i = x2 - 1, y2 - 1
case_i = case_index - 1
frame_i = frame_index - 1

# Build transect coordinates
if stair_step:
    if time_average:
        aice = nds[water_var].isel(case=case_i).mean(dim="time")
    else:
        aice = nds[water_var].isel(case=case_i, time=frame_i)

    water_mask = (aice.values <= water_maxice) & ~np.isnan(aice.values)
    path = find_water_path(water_mask, (x1_i, y1_i), (x2_i, y2_i))

    if path is None:
        stair_step = False
        x_line = np.linspace(x1_i, x2_i, num_points)
        y_line = np.linspace(y1_i, y2_i, num_points)
    else:
        path = np.array(path, dtype=int)
        path_ij_1based = [(int(x + 1), int(y + 1)) for x, y in path]
        print(f"Water path (i,j) 1-based: {path_ij_1based}")
        x_line = path[:, 0].astype(float)
        y_line = path[:, 1].astype(float)
        num_points = len(path)
else:
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

# Interpolate or sample transect values
pts_transect = np.column_stack([x_line, y_line])
if stair_step:
    transect_values = spd.values[y_line.astype(int), x_line.astype(int)]
else:
    transect_values = griddata(points_valid, values_valid, pts_transect, method='linear')

# Distance along the transect (index-based)
if stair_step:
    dist = np.arange(num_points)
else:
    dist = np.sqrt((x_line - x_line[0])**2 + (y_line - y_line[0])**2)

# Get formatted time string (for single frame mode)
if not time_average:
    time_str = time_values[frame_i].strftime('%Y %m %d %H')
else:
    time_str = "Time averaged"

# Plot both cases
plt.figure(figsize=(10, 4))

for case_i in range(2):
    if time_average:
        # Time-averaged mode with ice concentration threshold
        transect_sum = np.zeros(num_points)
        transect_count = np.zeros(num_points)

        for t_i in range(len(nds.time)):
            # Get speed and ice concentration for this time
            u = nds[u_name].isel(case=case_i, time=t_i)
            v = nds[v_name].isel(case=case_i, time=t_i)
            spd = np.sqrt(u**2 + v**2)
            aice = nds['aice_h'].isel(case=case_i, time=t_i)

            # Interpolate both speed and ice concentration
            yi, xi = np.meshgrid(np.arange(spd.shape[0]), np.arange(spd.shape[1]))
            points = np.column_stack([xi.ravel(), yi.ravel()])

            # Speed interpolation/sampling
            values_spd = spd.values.ravel()
            valid_spd = ~np.isnan(values_spd)
            pts_transect = np.column_stack([x_line, y_line])
            if stair_step:
                transect_spd = spd.values[y_line.astype(int), x_line.astype(int)]
            else:
                transect_spd = griddata(points[valid_spd], values_spd[valid_spd], pts_transect, method='linear')

            # Ice concentration interpolation/sampling
            values_aice = aice.values.ravel()
            valid_aice = ~np.isnan(values_aice)
            if stair_step:
                transect_aice = aice.values[y_line.astype(int), x_line.astype(int)]
            else:
                transect_aice = griddata(points[valid_aice], values_aice[valid_aice], pts_transect, method='linear')

            # Only accumulate where aice > minice
            mask = transect_aice > minice
            transect_sum[mask] += transect_spd[mask]
            transect_count[mask] += 1

        # Compute average (avoid divide by zero)
        transect_values = np.where(transect_count > 0, transect_sum / transect_count, np.nan)
    else:
        # Single time frame mode
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

        # Interpolate or sample transect values
        pts_transect = np.column_stack([x_line, y_line])
        if stair_step:
            transect_values = spd.values[y_line.astype(int), x_line.astype(int)]
        else:
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
