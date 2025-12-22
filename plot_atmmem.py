import os
import glob
import argparse
import xarray as xr
import matplotlib.pyplot as plt
import numpy as np

"""
Plot every 10th single-column file on a shared time axis.

Assumptions:
- All 101 files live under dirsrc/subdir and each has one column.
- All files share the same cadence; we build time axis from the first file's length.
- We plot files with indices 0, 10, 20, ..., up to the last available.
"""

# Configuration
dirsrc = "/scratch4/NCEPDEV/stmp/Denise.Worthen/RT_RUNDIRS/Denise.Worthen/FV3_RT/rt_314651/atmonly_c1152_v17/"

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Plot every 10th single-column file on a shared time axis.")
parser.add_argument("--subdir", default="post_on", help="Subdirectory under dirsrc (default: post_on)")
args = parser.parse_args()

subdir = args.subdir
file_glob = "vmrss.atm.*.dat"
stride = 10

# Discover files
data_dir = os.path.join(dirsrc, subdir)
all_files = sorted([f for f in glob.glob(os.path.join(data_dir, file_glob)) if os.path.isfile(f)])

if not all_files:
    raise FileNotFoundError(f"No files found under {data_dir} matching pattern '{file_glob}'")

# Load first file to establish time axis length
first = np.loadtxt(all_files[0])
if first.ndim != 1:
    raise ValueError(f"Expected single-column files; got shape {first.shape} for {all_files[0]}")

# Known start date and frequency of data
start_date = '2025-01-01 03:02:30'
time_axis = xr.date_range(start=start_date, periods=len(first), freq='2.5min')
tvals = time_axis

# Select every `stride`-th file
indices = list(range(0, len(all_files), stride))
selected_files = [all_files[i] for i in indices]

# Plot
plt.figure(figsize=(10, 6))

for i, fpath in zip(indices, selected_files):
    arr = np.loadtxt(fpath)
    if arr.ndim != 1:
        raise ValueError(f"Expected single-column files; got shape {arr.shape} for {fpath}")
    if len(arr) != len(tvals):
        raise ValueError(f"Length mismatch: {os.path.basename(fpath)} has {len(arr)} points, expected {len(tvals)}")

    label = f"file {i}: {os.path.basename(fpath)}"
    plt.plot(tvals, arr, label=label, linewidth=1)

plt.xlabel("Time")
plt.ylabel("Value")
plt.title("Every 10th file on shared time axis")
plt.grid(True)
plt.legend(ncol=2, fontsize=8)
plt.tight_layout()
plt.show()
