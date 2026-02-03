import os
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.colors import Normalize
import xarray as xr
import numpy as np
import cmaps
import pandas as pd
import geocat.datafiles as gdf
import geocat.viz as gv

dirsrc = "/gpfs/f6/infra-cpu/proj-shared/Denise.Worthen"
files = os.path.join(dirsrc, 'hi*.ice.nc')

nds = xr.open_mfdataset(files, concat_dim='case', combine='nested')

# --- 1. USER INPUTS (1-BASED) ---
x_start, x_end = 1, 66   # 1-based indices
y_start, y_end = 1, 71   # 1-based indices
skip = 2                  # Plot every Nth vector (to avoid overcrowding)

# Animation control
create_animation = False  # Set to True to create animation, False for single frame
frame = 1                 # Which time index to plot (1-based) when create_animation=False
start_frame = 1           # Start frame for animation (1-based) when create_animation=True
end_frame = None          # End frame for animation (1-based) when create_animation=True (None = last frame)
case_labels = ["AC", "CC"]  # Descriptive labels for each case
speed_cmap = cmaps.ncl_default  # Colormap for speed shading
speed_vmin = 0.0         # Minimum speed for colorbar
speed_vmax = 0.5         # Maximum speed for colorbar

# --- 2. COORDINATE CONVERSION ---
x_slice = slice(x_start - 1, x_end)
y_slice = slice(y_start - 1, y_end)

# Extract and convert time axis
time_values = pd.to_datetime(nds['time'].values)

# --- 3. PLOTTING LOGIC ---
fig, axs = plt.subplots(1, 2, figsize=(16, 8))
fig.subplots_adjust(left=0.08, right=0.92, bottom=0.1, top=0.9, wspace=0.3)

# Create persistent figure title
fig_title = fig.suptitle('', fontsize=14, fontweight='bold')

# Store artists for cleanup
artists_to_remove = {'quiver': [None, None], 'pcolormesh': [None, None]}

def plot_frame(frame_idx):
    """Plot vectors for a given frame index"""
    for ax in axs: ax.clear()

    # Get formatted time string for this frame
    time_str = time_values[frame_idx].strftime('%Y %m %d %H')

    for i in range(2):
        # Extract vector components
        u_data = nds['uvelN_h'].isel(case=i, time=frame_idx, ni=x_slice, nj=y_slice)
        v_data = nds['vvelN_h'].isel(case=i, time=frame_idx, ni=x_slice, nj=y_slice)

        # Create coordinate meshgrid
        x_coords = np.arange(u_data.shape[1])
        y_coords = np.arange(u_data.shape[0])
        X, Y = np.meshgrid(x_coords, y_coords)

        # Plot vectors (quiver plot)
        q = axs[i].quiver(X[::skip, ::skip], Y[::skip, ::skip],
                          u_data.values[::skip, ::skip], v_data.values[::skip, ::skip],
                          scale=0.1, scale_units='xy', angles='xy')
        artists_to_remove['quiver'][i] = q

        # Add colorbar showing magnitude
        magnitude = np.sqrt(u_data**2 + v_data**2)
        speed_norm = Normalize(vmin=speed_vmin, vmax=speed_vmax)
        im = axs[i].pcolormesh(X, Y, magnitude.values, cmap=speed_cmap, alpha=0.5, shading='nearest',
                               norm=speed_norm)
        artists_to_remove['pcolormesh'][i] = im

        # Add quiver key
        axs[i].quiverkey(q, 0.9, 0.95, 0.1, '0.1 m/s', labelpos='E', coordinates='figure')

    fig.colorbar(im, ax=axs, orientation='vertical', label='Speed (m/s)')
    return axs

if create_animation:
    # Create animation
    if end_frame is None:
        end_frame = len(nds.time)
    frame_range = range(start_frame - 1, end_frame)  # Convert to 0-based indices
    ani = animation.FuncAnimation(fig, plot_frame, frames=frame_range, interval=200)
    ani.save('velocity_vectors_comparison.gif', writer='pillow', fps=5)
    print("Animation saved as velocity_vectors_comparison.gif")
else:
    # Plot single frame
    plot_frame(frame - 1)  # Convert 1-based to 0-based index

plt.show()
