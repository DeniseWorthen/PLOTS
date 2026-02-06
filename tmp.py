import os
import numpy as np
import xarray as xr
import xgcm
import argparse

# --- USER SETTINGS ---
dirsrc = "/scratch4/NCEPDEV/stmp/Denise.Worthen/cgrid/mx100"
files = os.path.join(dirsrc, "hi*.ice.nc")

# Open dataset
nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

# Replace _FillValue with 0 for all relevant variables (land treatment)
for vname in ['uvel_h', 'vvel_h', 'uvelE_h', 'vvelN_h']:
    if vname in nds:
        fill_value = nds[vname].attrs.get('_FillValue', None)
        if fill_value is not None:
            nds[vname] = nds[vname].where(nds[vname] != fill_value, 0)
        nds[vname] = nds[vname].fillna(0)

# Set up xgcm grid for Arakawa C/F grid with only 'center' locations (since all variables are on (nj, ni))
coords = {
    'X': {'center': 'ni'},
    'Y': {'center': 'nj'}
}
grid = xgcm.Grid(nds, periodic=False, coords=coords, autoparse_metadata=False)

# --- Argument parsing for debug ---
parser = argparse.ArgumentParser(description="Debug center value calculation for u/v fields.")
parser.add_argument('--i', type=int, help='1-based i index (ni)')
parser.add_argument('--j', type=int, help='1-based j index (nj)')
parser.add_argument('--t', type=int, help='1-based time index')
parser.add_argument('--case', type=int, help='1-based case index')
args = parser.parse_args()

def print_debug_case1(i, j, t, case):
    # 1-based to 0-based
    i0, j0, t0, c0 = i-1, j-1, t-1, case-1
    # uvel_h, vvel_h on corners, need 4 points for each (simulate corners by averaging 4 adjacent points)
    uvals = []
    vvals = []
    for dj in [0,1]:
        for di in [0,1]:
            uval = nds['uvel_h'].isel(ni=i0+di, nj=j0+dj, time=t0, case=c0).values
            vval = nds['vvel_h'].isel(ni=i0+di, nj=j0+dj, time=t0, case=c0).values
            uvals.append(uval)
            vvals.append(vval)
    print(f"Case 1 center at (i={i}, j={j}, t={t}, case={case}):")
    print("  uvel_h corners:", uvals)
    print("  vvel_h corners:", vvals)
    print("  u_center =", np.mean(uvals))
    print("  v_center =", np.mean(vvals))

def print_debug_case23(i, j, t, case):
    # 1-based to 0-based
    i0, j0, t0, c0 = i-1, j-1, t-1, case-1
    # uvelE_h: need (i-1,j) and (i,j)
    u_left = nds['uvelE_h'].isel(ni=i0-1, nj=j0, time=t0, case=c0).values if i0-1 >= 0 else np.nan
    u_right = nds['uvelE_h'].isel(ni=i0, nj=j0, time=t0, case=c0).values
    u_center = np.nanmean([u_left, u_right])
    # vvelN_h: top = (i,j), bottom = (i,j-1)
    v_top = nds['vvelN_h'].isel(ni=i0, nj=j0, time=t0, case=c0).values
    v_bottom = nds['vvelN_h'].isel(ni=i0, nj=j0-1, time=t0, case=c0).values if j0-1 >= 0 else np.nan
    v_center = np.nanmean([v_top, v_bottom])
    print(f"Case 2/3 center at (i={i}, j={j}, t={t}, case={case}):")
    print(f"  uvelE_h: left (i-1,j)={u_left}, right (i,j)={u_right}")
    print(f"  vvelN_h: top (i,j)={v_top}, bottom (i,j-1)={v_bottom}")
    print(f"  u_center = {u_center}")
    print(f"  v_center = {v_center}")

if args.i and args.j and args.t and args.case:
    print_debug_case1(args.i, args.j, args.t, args.case)
    print_debug_case23(args.i, args.j, args.t, args.case)

# --- CASE 1: Corners to Center (uvel_h, vvel_h on corners) ---
# For plotting, you may want to average 4 adjacent points to simulate corners
# --- CASE 2/3: East/North Faces to Center (uvelE_h, vvelN_h) ---
# For plotting, use the simple average as above