import os
import numpy as np
import matplotlib.pyplot as plt
import xarray as xr

# --- USER SETTINGS ---
dirsrc = "/scratch4/NCEPDEV/stmp/Denise.Worthen/cgrid/mx100"
files = os.path.join(dirsrc, "hi*.ice.nc")

# List of points to sample (1-based indices)
points_xy_1based = [
    (25, 44), (26, 42), (27, 40), (28, 39), (29, 38),
    (30, 37), (31, 36), (32, 35), (33, 34), (34, 33)
]

case_index = 1  # 1-based
frame_index = 100  # 1-based
speed_stat = "mean"

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

case_i = case_index - 1
frame_i = frame_index - 1

u = nds["uvel_h"].isel(case=case_i).fillna(0)
v = nds["vvel_h"].isel(case=case_i).fillna(0)
if speed_stat == "instant" and "time" in u.dims:
    u = u.isel(time=frame_i)
    v = v.isel(time=frame_i)
if speed_stat == "mean" and "time" in u.dims:
    u = u.mean("time", skipna=True)
    v = v.mean("time", skipna=True)
elif speed_stat == "max" and "time" in u.dims:
    u = u.max("time", skipna=True)
    v = v.max("time", skipna=True)

# Average four corners to get center value
u_center = 0.25 * (u[:-1, :-1] + u[1:, :-1] + u[:-1, 1:] + u[1:, 1:])
v_center = 0.25 * (v[:-1, :-1] + v[1:, :-1] + v[:-1, 1:] + v[1:, 1:])
speed = np.sqrt(u_center**2 + v_center**2)

# Convert points to 0-based indices
points = np.array([(x - 1, y - 1) for x, y in points_xy_1based], dtype=int)
xs = points[:, 0]
ys = points[:, 1]
dist = np.arange(len(points))


# Extract speed at each transect point as a 1D array
values = np.array([speed.values[y, x] for x, y in zip(xs, ys)])
print("values.shape:", values.shape)
print("values:", values)

plt.figure(figsize=(8, 6))
plt.plot(dist, values, lw=2, marker="o", color="tab:blue", label="A:B")
plt.xlabel("Transect Point")
plt.ylabel("Ice speed (m/s)")
plt.title("Ice speed along specified points (A:B)")
plt.legend(["A:B"])
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
