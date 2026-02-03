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
create_animation = True  # Set to True to create animation, False for single frame
frame = 1                 # Which time index to plot (1-based) when create_animation=False
start_frame = 1           # Start frame for animation (1-based) when create_animation=True
end_frame = 10            # End frame for animation (1-based) when create_animation=True (None = last frame)
display_frames = True     # Display frames sequentially when create_animation=True (set False to just save GIF)
case_labels = ["AC", "CC"]  # Descriptive labels for each case
bkgd_fld = None           # Background field to shade (None = speed/magnitude, or set to field name like 'aice_h', 'hi_h')
speed_cmap = cmaps.ncl_default  # Colormap for background shading
bkgd_vmin = 0.0          # Minimum value for colorbar
bkgd_vmax = 0.5          # Maximum value for colorbar

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
    # Remove old artists
    for i in range(2):
        if artists_to_remove['quiver'][i] is not None:
            artists_to_remove['quiver'][i].remove()
        if artists_to_remove['pcolormesh'][i] is not None:
            artists_to_remove['pcolormesh'][i].remove()

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

        # Get background field for shading
        if bkgd_fld is None:
            # Use speed/magnitude by default
            bkgd_data = np.sqrt(u_data**2 + v_data**2)
            bkgd_label = 'Speed (m/s)'
        else:
            # Use specified field
            bkgd_data = nds[bkgd_fld].isel(case=i, time=frame_idx, ni=x_slice, nj=y_slice)
            bkgd_label = bkgd_fld

        bkgd_norm = Normalize(vmin=bkgd_vmin, vmax=bkgd_vmax)
        im = axs[i].pcolormesh(X, Y, bkgd_data.values, cmap=speed_cmap, alpha=0.5, shading='nearest',
                               norm=bkgd_norm)
        artists_to_remove['pcolormesh'][i] = im

        # Add quiver key
        axs[i].quiverkey(q, 0.9, 0.95, 0.1, '0.1 m/s', labelpos='E', coordinates='figure')

    fig_title.set_text(f'Time: {time_str}')
    fig.colorbar(im, ax=axs, orientation='vertical', label=bkgd_label)
    return axs

if create_animation:
    # Create animation by saving individual frames
    if end_frame is None:
        end_frame = len(nds.time)
    frame_range = range(start_frame - 1, end_frame)

    import tempfile
    import os as os_module
    temp_dir = tempfile.mkdtemp()
    frame_files = []

    for frame_idx in frame_range:
        # Create fresh figure for each frame
        fig_temp, axs_temp = plt.subplots(1, 2, figsize=(16, 8))
        fig_temp.subplots_adjust(left=0.08, right=0.92, bottom=0.1, top=0.9, wspace=0.3)
        fig_title_temp = fig_temp.suptitle('', fontsize=14, fontweight='bold')

        time_str = time_values[frame_idx].strftime('%Y %m %d %H')

        for i in range(2):
            # Extract vector components
            u_data = nds['uvelN_h'].isel(case=i, time=frame_idx, ni=x_slice, nj=y_slice)
            v_data = nds['vvelN_h'].isel(case=i, time=frame_idx, ni=x_slice, nj=y_slice)

            # Create coordinate meshgrid
            x_coords = np.arange(u_data.shape[1])
            y_coords = np.arange(u_data.shape[0])
            X, Y = np.meshgrid(x_coords, y_coords)

            # Plot vectors
            q = axs_temp[i].quiver(X[::skip, ::skip], Y[::skip, ::skip],
                                   u_data.values[::skip, ::skip], v_data.values[::skip, ::skip],
                                   scale=0.1, scale_units='xy', angles='xy')

            # Get background field for shading
            if bkgd_fld is None:
                # Use speed/magnitude by default
                bkgd_data = np.sqrt(u_data**2 + v_data**2)
                bkgd_label = 'Speed (m/s)'
            else:
                # Use specified field
                bkgd_data = nds[bkgd_fld].isel(case=i, time=frame_idx, ni=x_slice, nj=y_slice)
                bkgd_label = bkgd_fld
            
            bkgd_norm = Normalize(vmin=bkgd_vmin, vmax=bkgd_vmax)
            im = axs_temp[i].pcolormesh(X, Y, bkgd_data.values, cmap=speed_cmap, alpha=0.5, shading='nearest',
                                        norm=bkgd_norm)

            axs_temp[i].quiverkey(q, 0.9, 0.95, 0.1, '0.1 m/s', labelpos='E', coordinates='figure')
            gv.set_titles_and_labels(axs_temp[i], maintitle=f"{case_labels[i]}: Velocity Vectors")
            axs_temp[i].set_aspect('equal')

        fig_title_temp.set_text(f'Time: {time_str}')
        fig_temp.colorbar(im, ax=axs_temp, orientation='vertical', label=bkgd_label)

        if display_frames:
            # Display frame - wait for click to advance
            plt.waitforbuttonpress()

        # Save frame
        frame_file = os_module.path.join(temp_dir, f'frame_{len(frame_files):04d}.png')
        fig_temp.savefig(frame_file, dpi=100, bbox_inches='tight')
        frame_files.append(frame_file)
        plt.close(fig_temp)

        print(f"Saved time index {frame_idx + 1} ({len(frame_files)}/{len(frame_range)})")

    # Create GIF from frames
    from PIL import Image
    images = [Image.open(f) for f in frame_files]
    images[0].save('velocity_vectors_comparison.gif', save_all=True, append_images=images[1:],
                   duration=200, loop=0)

    # Cleanup temp files
    for f in frame_files:
        os_module.remove(f)
    os_module.rmdir(temp_dir)

    print("Animation saved as velocity_vectors_comparison.gif")
else:
    # Plot single frame
    plot_frame(frame - 1)  # Convert 1-based to 0-based index
    plt.show()
