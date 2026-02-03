import os
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import xarray as xr
import numpy as np
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
case_labels = ["Case 1", "Case 2"]  # Descriptive labels for each case

# --- 2. COORDINATE CONVERSION ---
x_slice = slice(x_start - 1, x_end)
y_slice = slice(y_start - 1, y_end)

# --- 3. PLOTTING LOGIC ---
fig, axs = plt.subplots(1, 2, figsize=(15, 7), constrained_layout=True)

def plot_frame(frame_idx):
    """Plot vectors for a given frame index"""
    for ax in axs: ax.clear()
    
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
        
        # Add colorbar showing magnitude
        magnitude = np.sqrt(u_data**2 + v_data**2)
        im = axs[i].pcolormesh(X, Y, magnitude.values, cmap='viridis', alpha=0.5, shading='nearest')
        fig.colorbar(im, ax=axs[i], orientation='vertical', label='Speed (m/s)')
        
        gv.set_titles_and_labels(axs[i],
                     maintitle=f"{case_labels[i]}: Velocity Vectors",
                                 lefttitle=f"Time Index: {frame_idx + 1}")
        axs[i].set_aspect('equal')
        
        # Add quiver key
        axs[i].quiverkey(q, 0.9, 0.95, 0.1, '0.1 m/s', labelpos='E', coordinates='figure')
    
    return axs

if create_animation:
    # Create animation
    ani = animation.FuncAnimation(fig, plot_frame, frames=len(nds.time), interval=200)
    ani.save('velocity_vectors_comparison.gif', writer='pillow', fps=5)
    print("Animation saved as velocity_vectors_comparison.gif")
else:
    # Plot single frame
    plot_frame(frame - 1)  # Convert 1-based to 0-based index

plt.show()
