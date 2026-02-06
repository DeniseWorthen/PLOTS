import xarray as xr
import numpy as np
import matplotlib.pyplot as plt

# Replace with your NetCDF file path
filename = "your_file.nc"

# Open the NetCDF file
ds = xr.open_dataset(filename)

# Assume corner velocities are named 'uvelF' and 'vvelF' (update if needed)
u = ds['uvel_h'].fillna(0).values  # shape: (nj, ni)
v = ds['vvel_h'].fillna(0).values  # shape: (nj, ni)

# To get speed at cell centers, average the four surrounding corners for each cell
# Center indices: 1..nj-1, 1..ni-1
u_center = 0.25 * (u[:-1, :-1] + u[1:, :-1] + u[:-1, 1:] + u[1:, 1:])
v_center = 0.25 * (v[:-1, :-1] + v[1:, :-1] + v[:-1, 1:] + v[1:, 1:])

speed = np.sqrt(u_center**2 + v_center**2)

# Plotting
plt.figure(figsize=(8, 6))
plt.pcolormesh(speed, cmap='viridis')
plt.colorbar(label='Speed (m/s)')
plt.title('Speed at Grid Centers (Arakawa F)')
plt.xlabel('i')
plt.ylabel('j')
plt.show()
