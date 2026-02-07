import os
import glob
import numpy as np
import xarray as xr
import os
from ferretlist import ferlist

# --- USER SETTINGS ---
#dirsrc = "/scratch4/NCEPDEV/stmp/Denise.Worthen/cgrid/mx100"
dirsrc= "/Users/toby"

files_stg=glob.glob(os.path.join(dirsrc, "hi*.ice.nc"))
files_cen = glob.glob(os.path.join(dirsrc, "centered*.ice.nc"))
# Set i and j index ranges here for easy control
i_range = (10,20)
j_range = (10,20)

fs = ferlist(files_stg[0], 'uvel_h')
fc = ferlist(files_cen[0], 'u_center')

print(fs.list(i=i_range, j=j_range, k=1, l=1))
print(fc.list(i=i_range, j=j_range, k=1, l=1))

# # Open dataset
# nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")
# # Replace _FillValue with 0 for all relevant variables (land treatment)
# for vname in ['uvel_h', 'vvel_h', 'uvelE_h', 'vvelN_h']:
#     if vname in nds:
#         fill_value = nds[vname].attrs.get('_FillValue', None)
#         if fill_value is not None:
#             nds[vname] = nds[vname].where(nds[vname] != fill_value, 0)
#         nds[vname] = nds[vname].fillna(0)

# # Set up xgcm grid for Arakawa C/F grid with only 'center' locations
# coords = {
#     'X': {'center': 'ni'},
#     'Y': {'center': 'nj'}
# }
# grid = xgcm.Grid(nds, periodic=False, coords=coords, autoparse_metadata=False)

# # Prepare output directory
# outdir = os.path.join(dirsrc, "center_velocities")
# os.makedirs(outdir, exist_ok=True)

# for case_i in range(nds.case.size):
#     u_center = np.zeros((nds.time.size, nds.nj.size, nds.ni.size))
#     v_center = np.zeros((nds.time.size, nds.nj.size, nds.ni.size))
#     for t_i in range(nds.time.size):
#         for j in range(nds.nj.size):
#             for i in range(nds.ni.size):
#                 i0, j0, t0, c0 = i, j, t_i, case_i
#                 # CASE 1: Corners to Center (uvel_h, vvel_h on corners)
#                 if case_i == 0:
#                     uvals = []
#                     vvals = []
#                     for dj in [0,1]:
#                         for di in [0,1]:
#                             ni = i0 + di
#                             nj = j0 + dj
#                             if (0 <= ni < nds['uvel_h'].shape[-1]) and (0 <= nj < nds['uvel_h'].shape[-2]):
#                                 uval = nds['uvel_h'].isel(ni=ni, nj=nj, time=t0, case=c0).values
#                                 vval = nds['vvel_h'].isel(ni=ni, nj=nj, time=t0, case=c0).values
#                             else:
#                                 uval = np.nan
#                                 vval = np.nan
#                             uvals.append(uval)
#                             vvals.append(vval)
#                     u_center[t_i, j, i] = np.nanmean(uvals)
#                     v_center[t_i, j, i] = np.nanmean(vvals)
#                 # CASE 2/3: East/North Faces to Center (uvelE_h, vvelN_h)
#                 else:
#                     u_left = nds['uvelE_h'].isel(ni=i0-1, nj=j0, time=t0, case=c0).values if i0-1 >= 0 else np.nan
#                     u_right = nds['uvelE_h'].isel(ni=i0, nj=j0, time=t0, case=c0).values
#                     u_center[t_i, j, i] = np.nanmean([u_left, u_right])
#                     v_top = nds['vvelN_h'].isel(ni=i0, nj=j0, time=t0, case=c0).values
#                     v_bottom = nds['vvelN_h'].isel(ni=i0, nj=j0-1, time=t0, case=c0).values if j0-1 >= 0 else np.nan
#                     v_center[t_i, j, i] = np.nanmean([v_top, v_bottom])
#     # Save tmask for this case
#     tmask = nds['tmask'].isel(case=case_i)
#     # Create xarray Dataset for this case
#     ds_out = xr.Dataset({
#         'u_center': (['time', 'nj', 'ni'], u_center.astype(np.float32)),
#         'v_center': (['time', 'nj', 'ni'], v_center.astype(np.float32)),
#         'tmask': (['nj', 'ni'], tmask)
#     }, coords={
#         'time': nds.time,
#         'nj': nds.nj,
#         'ni': nds.ni
#     })
#     # Set _FillValue attribute for u_center and v_center
#     ds_out['u_center'].attrs['_FillValue'] = 1.e+30
#     ds_out['v_center'].attrs['_FillValue'] = 1.e+30
#     # Save to netcdf
#     outpath = os.path.join(outdir, f"center_velocities_case{case_i+1}.nc")
#     ds_out.to_netcdf(outpath, encoding={
#         'u_center': {'_FillValue': 1.e+30, 'dtype': 'float32'},
#         'v_center': {'_FillValue': 1.e+30, 'dtype': 'float32'}
#     })
#     print(f"Saved: {outpath}")

# # Replace _FillValue with 0 for all relevant variables (land treatment)
# for vname in ['uvel_h', 'vvel_h', 'uvelE_h', 'vvelN_h']:
#     if vname in nds:
#         fill_value = nds[vname].attrs.get('_FillValue', None)
#         if fill_value is not None:
#             nds[vname] = nds[vname].where(nds[vname] != fill_value, 0)
#         nds[vname] = nds[vname].fillna(0)

# # Set up xgcm grid for Arakawa C/F grid with only 'center' locations (since all variables are on (nj, ni))
# coords = {
#     'X': {'center': 'ni'},
#     'Y': {'center': 'nj'}
# }
# grid = xgcm.Grid(nds, periodic=False, coords=coords, autoparse_metadata=False)

# # --- Argument parsing for debug ---
# parser = argparse.ArgumentParser(description="Debug center value calculation for u/v fields.")
# parser.add_argument('--i', type=int, help='1-based i index (ni)')
# parser.add_argument('--j', type=int, help='1-based j index (nj)')
# parser.add_argument('--t', type=int, help='1-based time index')
# parser.add_argument('--case', type=int, help='1-based case index')
# args = parser.parse_args()

# def print_debug_case1(i, j, t, case):
#     # 1-based to 0-based
#     i0, j0, t0, c0 = i-1, j-1, t-1, case-1
#     # uvel_h, vvel_h on corners, need 4 points for each (simulate corners by averaging 4 adjacent points)
#     uvals = []
#     vvals = []
#     for dj in [0,1]:
#         for di in [0,1]:
#             uval = nds['uvel_h'].isel(ni=i0+di, nj=j0+dj, time=t0, case=c0).values
#             vval = nds['vvel_h'].isel(ni=i0+di, nj=j0+dj, time=t0, case=c0).values
#             uvals.append(uval)
#             vvals.append(vval)
#     print(f"Case 1 center at (i={i}, j={j}, t={t}, case={case}):")
#     print("  uvel_h corners:", uvals)
#     print("  vvel_h corners:", vvals)
#     print("  u_center =", np.mean(uvals))
#     print("  v_center =", np.mean(vvals))

# def print_debug_case23(i, j, t, case):
#     # 1-based to 0-based
#     i0, j0, t0, c0 = i-1, j-1, t-1, case-1
#     # uvelE_h: need (i-1,j) and (i,j)
#     u_left = nds['uvelE_h'].isel(ni=i0-1, nj=j0, time=t0, case=c0).values if i0-1 >= 0 else np.nan
#     u_right = nds['uvelE_h'].isel(ni=i0, nj=j0, time=t0, case=c0).values
#     u_center = np.nanmean([u_left, u_right])
#     # vvelN_h: top = (i,j), bottom = (i,j-1)
#     v_top = nds['vvelN_h'].isel(ni=i0, nj=j0, time=t0, case=c0).values
#     v_bottom = nds['vvelN_h'].isel(ni=i0, nj=j0-1, time=t0, case=c0).values if j0-1 >= 0 else np.nan
#     v_center = np.nanmean([v_top, v_bottom])
#     print(f"Case 2/3 center at (i={i}, j={j}, t={t}, case={case}):")
#     print(f"  uvelE_h: left (i-1,j)={u_left}, right (i,j)={u_right}")
#     print(f"  vvelN_h: top (i,j)={v_top}, bottom (i,j-1)={v_bottom}")
#     print(f"  u_center = {u_center}")
#     print(f"  v_center = {v_center}")

# if args.i and args.j and args.t and args.case:
#     print_debug_case1(args.i, args.j, args.t, args.case)
#     print_debug_case23(args.i, args.j, args.t, args.case)

# # --- CASE 1: Corners to Center (uvel_h, vvel_h on corners) ---
# # For plotting, you may want to average 4 adjacent points to simulate corners
# # --- CASE 2/3: East/North Faces to Center (uvelE_h, vvelN_h) ---
# # For plotting, use the simple average as above
