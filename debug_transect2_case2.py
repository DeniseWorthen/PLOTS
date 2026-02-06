import os
import numpy as np
import xarray as xr

# --- USER SETTINGS ---
dirsrc = "/scratch4/NCEPDEV/stmp/Denise.Worthen/cgrid/mx100"
files = os.path.join(dirsrc, "hi*.ice.nc")

# Transect 2: single x-value (4), y from 47 to 66 (inclusive), 1-based
points_xy_1based_2 = [(4, y) for y in range(47, 67)]

case_index = 2  # 1-based (case 2)
frame_index = 100  # 1-based

type_stat = "mean"

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

case_i = case_index - 1
frame_i = frame_index - 1

yxs = [(y-1, 4-1) for (x, y) in points_xy_1based_2]  # x=4 for all, y varies

u = nds["uvelE_h"].isel(case=case_i).fillna(0)
v = nds["vvelN_h"].isel(case=case_i).fillna(0)
if type_stat == "instant" and "time" in u.dims:
    u = u.isel(time=frame_i)
    v = v.isel(time=frame_i)
if type_stat == "mean" and "time" in u.dims:
    u = u.mean("time", skipna=True)
    v = v.mean("time", skipna=True)
elif type_stat == "max" and "time" in u.dims:
    u = u.max("time", skipna=True)
    v = v.max("time", skipna=True)

print("Point  i  j  u_left(i-1,j)  u_right(i,j)  u_center  v_top(i,j-1)  v_bottom(i,j)  v_center  speed")
for idx, (y, x) in enumerate(yxs):
    u_left = u.values[y, x-1] if x-1 >= 0 else np.nan
    u_right = u.values[y, x]
    u_center = np.nanmean([u_left, u_right])
    v_top = v.values[y-1, x] if y-1 >= 0 else np.nan
    v_bottom = v.values[y, x]
    v_center = np.nanmean([v_top, v_bottom])
    speed = np.sqrt(u_center**2 + v_center**2)
    print(f"{idx:2d}  {x+1:2d} {y+1:2d}  {u_left:10.5f}  {u_right:10.5f}  {u_center:10.5f}  {v_top:10.5f}  {v_bottom:10.5f}  {v_center:10.5f}  {speed:10.5f}")
