import xarray as xr
import numpy as np
import matplotlib.pyplot as plt

# Replace with your NetCDF file path
filename = "your_file.nc"

# Open the NetCDF file
ds = xr.open_dataset(filename)

# Extract variables (assume missing/land values are zero)
u = ds['uvelE_h'].fillna(0).values  # shape: (nj, ni)
v = ds['vvelN_h'].fillna(0).values  # shape: (nj, ni)

# Compute u and v at cell centers by averaging adjacent faces
# For Arakawa-C, center u is average of left/right, center v is average of top/bottom
u_center = 0.5 * (u[:, :-1] + u[:, 1:])  # shape: (nj, ni-1)
v_center = 0.5 * (v[:-1, :] + v[1:, :])  # shape: (nj-1, ni)

# To get speed at cell centers, need overlapping region
nj, ni = u_center.shape[0], v_center.shape[1]
speed = np.sqrt(
    u_center[:nj-1, :]**2 + v_center[:, :ni-1]**2
)

# Plotting
plt.figure(figsize=(8, 6))
plt.pcolormesh(speed, cmap='viridis')
plt.colorbar(label='Speed (m/s)')
plt.title('Speed at Grid Centers')
plt.xlabel('i')
plt.ylabel('j')
plt.show()
