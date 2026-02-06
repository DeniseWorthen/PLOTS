import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import xarray as xr
import pandas as pd

# --- USER SETTINGS ---
dirsrc = "/scratch4/NCEPDEV/stmp/Denise.Worthen/cgrid/mx100"
files = os.path.join(dirsrc, "hi*.ice.nc")

# List of points to sample (1-based indices)
# Replace with your exact list of (x, y) pairs
points_xy_1based = [
    # (x, y),
    (25, 44),
    (26, 42),
    (27, 40),
    (28, 39),
    (29, 38),
    (30, 37),
    (31, 36),
    (32, 35),
    (33, 34),
    (34, 33)
]

# Second transect: single x-value (4), y from 43 to 67 (inclusive), 1-based
points_xy_1based_2 = [(4, y) for y in range(47, 67)]

# Third transect
points_xy_1based_3 = [
    # (x, y),
    (43, 41),
    (45, 42),
    (49, 43),
    (50, 44),
    (52, 45),
    (54, 46),
    (56, 47),
    (59, 48),
]

# Which case/time to plot (1-based)
case_index = 1
frame_index = 100

# Speed statistic to plot: "instant", "mean", or "max"
speed_stat = "mean"

# Case labels for legend
case_labels = ["A:B", "A:C", "C:C"]

# Global index offsets for tmask plot
i_offset = 200
j_offset = 250

# ---------------------

nds = xr.open_mfdataset(files, concat_dim="case", combine="nested")

# Extract and convert time axis
if "time" in nds:
    time_values = pd.to_datetime(nds["time"].values)
else:
    time_values = None

# Convert to 0-based indices
case_i = case_index - 1
frame_i = frame_index - 1

# Get formatted time string
if time_values is not None:
    time_str = time_values[frame_i].strftime("%Y %m %d %H")
    time_start_str = time_values[0].strftime("%Y %m %d %H")
    time_end_str = time_values[-1].strftime("%Y %m %d %H")
    time_range_str = f"{time_start_str} : {time_end_str}"
else:
    time_str = f"Frame {frame_index}"
    time_range_str = "all available times"

if speed_stat not in {"instant", "mean", "max"}:
    raise ValueError("speed_stat must be one of: 'instant', 'mean', 'max'")


def plot_transect(points_xy_1based, transect_label):
    points = np.array([(x - 1, y - 1) for x, y in points_xy_1based], dtype=int)
    xs = points[:, 0]
    ys = points[:, 1]
    dist = np.arange(len(points))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Define colors and markers for each case
    colors = ["tab:blue", "tab:orange", "tab:green"]
    markers = ["o", "s", "^"]

    for case_i in range(len(case_labels)):
        if case_i == 0:
            # Case 1: Calculate speed at cell centers from F-grid (corners)
            # Assume variables: 'uvel_h', 'vvel_h'
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
            values = speed.values[ys, xs]
            axes[0].plot(dist, values, lw=1, marker=markers[case_i],
                         markersize=4, markevery=1, label=case_labels[case_i], color=colors[case_i])
        else:
            # Cases 2 and 3: Calculate speed at cell centers from C-grid (faces)
            # Assume variables: 'uvelE_h' (east face), 'vvelN_h' (north face)
            u = nds["uvelE_h"].isel(case=case_i).fillna(0)
            v = nds["vvelN_h"].isel(case=case_i).fillna(0)
            if speed_stat == "instant" and "time" in u.dims:
                u = u.isel(time=frame_i)
                v = v.isel(time=frame_i)
            if speed_stat == "mean" and "time" in u.dims:
                u = u.mean("time", skipna=True)
                v = v.mean("time", skipna=True)
            elif speed_stat == "max" and "time" in u.dims:
                u = u.max("time", skipna=True)
                v = v.max("time", skipna=True)
            # Average adjacent faces to get center value
            u_center = 0.5 * (u[:, :-1] + u[:, 1:])
            v_center = 0.5 * (v[:-1, :] + v[1:, :])
            nj, ni = u_center.shape[0], v_center.shape[1]
            speed = np.sqrt(u_center[:nj-1, :]**2 + v_center[:, :ni-1]**2)
            values = speed.values[ys, xs]
            axes[0].plot(dist, values, lw=1, marker=markers[case_i],
                         markersize=4, markevery=1, label=case_labels[case_i], color=colors[case_i])

    axes[0].set_xlabel("Transect Point")
    axes[0].set_ylabel("Ice speed (m/s)")
    if speed_stat == "instant":
        title_suffix = f"Time: {time_str}"
    elif speed_stat == "mean":
        title_suffix = f"Time-mean over {time_range_str}"
    else:
        title_suffix = f"Time-maximum over {time_range_str}"

    axes[0].set_title(f"Ice speed along specified points ({transect_label})\n{title_suffix}")
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # --- Plot points over tmask for Case 3 ---
    case3_i = 2
    if "tmask" in nds:
        tmask = nds["tmask"].isel(case=case3_i)
        if "time" in tmask.dims:
            tmask = tmask.isel(time=frame_i)

        axes[1].set_facecolor("0.8")
        axes[1].pcolormesh(tmask, cmap="Greys_r", shading="nearest")
        if len(xs) > 1:
            ptcolors = ["green"] + ["yellow"] * (len(xs) - 2) + ["red"]
        elif len(xs) == 1:
            ptcolors = ["green"]
        else:
            ptcolors = []
        axes[1].scatter(xs, ys, c=ptcolors, s=20, edgecolors="black", linewidths=0.5)
        axes[1].set_xlabel("i")
        axes[1].set_ylabel("j")
        axes[1].xaxis.set_major_formatter(
            mticker.FuncFormatter(lambda x, pos: f"{int(round(x)) + i_offset}")
        )
        axes[1].yaxis.set_major_formatter(
            mticker.FuncFormatter(lambda y, pos: f"{int(round(y)) + j_offset}")
        )
        axes[1].set_aspect("equal")
    else:
        axes[1].text(0.5, 0.5, "tmask not found\n(skipping plot)",
                     ha="center", va="center")
        axes[1].set_axis_off()

    plt.tight_layout()
    return fig


if __name__ == "__main__":
    import argparse
    from matplotlib.backends.backend_pdf import PdfPages

    parser = argparse.ArgumentParser(description="Plot and save ice speed points.")
    parser.add_argument('--no-display', action='store_true', help='Do not display the figure, only save it.')
    parser.add_argument('--outfile', type=str, default=None, help='Filename to save the figure (default: no save).')
    parser.add_argument('--list-values', action='store_true', help='Print the values being plotted for each transect and case.')
    parser.add_argument('--list-var', type=str, default=None, help='Variable name to print raw values used for center calculation.')
    parser.add_argument('--list-time', type=int, default=None, help='Time index to print raw values for (1-based, 1=first time).')
    args = parser.parse_args()

    # Store values for listing if requested
    values_by_transect = []
    def plot_transect_with_values(points_xy_1based, transect_label):
        points = np.array([(x - 1, y - 1) for x, y in points_xy_1based], dtype=int)
        xs = points[:, 0]
        ys = points[:, 1]
        dist = np.arange(len(points))
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        colors = ["tab:blue", "tab:orange", "tab:green"]
        markers = ["o", "s", "^"]
        values_list = []
        for case_i in range(len(case_labels)):
            if case_i == 0:
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
                u_center = 0.25 * (u[:-1, :-1] + u[1:, :-1] + u[:-1, 1:] + u[1:, 1:])
                v_center = 0.25 * (v[:-1, :-1] + v[1:, :-1] + v[:-1, 1:] + v[1:, 1:])
                speed = np.sqrt(u_center**2 + v_center**2)
            else:
                u = nds["uvelE_h"].isel(case=case_i).fillna(0)
                v = nds["vvelN_h"].isel(case=case_i).fillna(0)
                if speed_stat == "instant" and "time" in u.dims:
                    u = u.isel(time=frame_i)
                    v = v.isel(time=frame_i)
                if speed_stat == "mean" and "time" in u.dims:
                    u = u.mean("time", skipna=True)
                    v = v.mean("time", skipna=True)
                elif speed_stat == "max" and "time" in u.dims:
                    u = u.max("time", skipna=True)
                    v = v.max("time", skipna=True)
                # Center value: average of (i-1,j) and (i,j) for uvelE_h, (i,j-1) and (i,j) for vvelN_h
                u_center = np.full(u.shape, np.nan)
                u_center[:, 1:] = 0.5 * (u[:, :-1] + u[:, 1:])
                v_center = np.full(v.shape, np.nan)
                v_center[1:, :] = 0.5 * (v[:-1, :] + v[1:, :])
                speed = np.sqrt(u_center * u_center + v_center * v_center)
            # Extract speed at each transect point as a 1D array
            # Use .values if speed is xarray, else use directly (numpy)
            if hasattr(speed, 'values'):
                arr = speed.values
            else:
                arr = speed
            values = np.array([arr[y, x] for x, y in zip(xs, ys)])
            values_list.append((case_labels[case_i], values))
            axes[0].plot(dist, values, lw=1, marker=markers[case_i],
                         markersize=4, markevery=1, label=case_labels[case_i], color=colors[case_i])
        axes[0].set_xlabel("Transect Point")
        axes[0].set_ylabel("Ice speed (m/s)")
        if speed_stat == "instant":
            title_suffix = f"Time: {time_str}"
        elif speed_stat == "mean":
            title_suffix = f"Time-mean over {time_range_str}"
        else:
            title_suffix = f"Time-maximum over {time_range_str}"
        axes[0].set_title(f"Ice speed along specified points ({transect_label})\n{title_suffix}")
        axes[0].legend()
        axes[0].grid(True, alpha=0.3)
        # --- Plot points over tmask for Case 3 ---
        case3_i = 2
        if "tmask" in nds:
            tmask = nds["tmask"].isel(case=case3_i)
            if "time" in tmask.dims:
                tmask = tmask.isel(time=frame_i)
            axes[1].set_facecolor("0.8")
            axes[1].pcolormesh(tmask, cmap="Greys_r", shading="nearest")
            if len(xs) > 1:
                ptcolors = ["green"] + ["yellow"] * (len(xs) - 2) + ["red"]
            elif len(xs) == 1:
                ptcolors = ["green"]
            else:
                ptcolors = []
            axes[1].scatter(xs, ys, c=ptcolors, s=20, edgecolors="black", linewidths=0.5)
            axes[1].set_xlabel("i")
            axes[1].set_ylabel("j")
            axes[1].xaxis.set_major_formatter(
                mticker.FuncFormatter(lambda x, pos: f"{int(round(x)) + i_offset}")
            )
            axes[1].yaxis.set_major_formatter(
                mticker.FuncFormatter(lambda y, pos: f"{int(round(y)) + j_offset}")
            )
            axes[1].set_aspect("equal")
        else:
            axes[1].text(0.5, 0.5, "tmask not found\n(skipping plot)",
                         ha="center", va="center")
            axes[1].set_axis_off()
        plt.tight_layout()
        values_by_transect.append((transect_label, values_list))
        return fig

    figs = []
    figs.append(plot_transect_with_values(points_xy_1based, "Transect 1"))
    figs.append(plot_transect_with_values(points_xy_1based_2, "Transect 2"))
    figs.append(plot_transect_with_values(points_xy_1based_3, "Transect 3"))

    if args.list_values:
        for transect_label, values_list in values_by_transect:
            print(f"\nValues for {transect_label}:")
            for case_label, values in values_list:
                print(f"  {case_label}: {values}")

    # Deeper debugging: print raw values used for center calculation
    if args.list_var is not None:
                # Special debug for transect 2, cases 2 and 3: print uvelE_h, vvelN_h, and speed at each point
                if args.list_var is None and "Transect 2" in transect_points_dict:
                    print("\n--- Debug: Transect 2, Cases 2 and 3 ---")
                    points_raw = transect_points_dict["Transect 2"]
                    for case_i in [1, 2]:
                        print(f"\nCase {case_labels[case_i]}:")
                        u = nds["uvelE_h"].isel(case=case_i).fillna(0)
                        v = nds["vvelN_h"].isel(case=case_i).fillna(0)
                        if "time" in u.dims:
                            u = u.isel(time=time_idx)
                            v = v.isel(time=time_idx)
                        for i, (x1, y1) in enumerate(points_raw):
                            x = x1 - 1
                            y = y1 - 1
                            # Center value for uvelE_h: average of (i-1, j) and (i, j)
                            u_left = u.values[y, x-1] if x-1 >= 0 else np.nan
                            u_right = u.values[y, x]
                            u_center = np.nanmean([u_left, u_right])
                            # Center value for vvelN_h: average of (i, j-1) and (i, j)
                            v_top = v.values[y-1, x] if y-1 >= 0 else np.nan
                            v_bottom = v.values[y, x]
                            v_center = np.nanmean([v_top, v_bottom])
                            speed = np.sqrt(u_center**2 + v_center**2)
                            print(f"  Point {i} (x={x1}, y={y1}): u_left(i-1,j)={u_left}, u_right(i,j)={u_right}, u_center={u_center}; v_top(i,j-1)={v_top}, v_bottom(i,j)={v_bottom}, v_center={v_center}; speed={speed}")
        varname = args.list_var
        # Make list_time 1-based for user, convert to 0-based for Python
        if args.list_time is not None:
            time_idx = args.list_time - 1
        else:
            time_idx = 0
        print(f"\nRaw values for variable '{varname}' at time index {time_idx}:")
        # Map transect labels to points
        transect_points_dict = {
            "Transect 1": points_xy_1based,
            "Transect 2": points_xy_1based_2,
            "Transect 3": points_xy_1based_3,
        }
        for transect_label, values_list in values_by_transect:
            print(f"\nTransect: {transect_label}")
            points_raw = transect_points_dict.get(transect_label, [])
            # points_raw is already 1-based
            for case_i, (case_label, case_values) in enumerate(values_list):
                var = nds[varname].isel(case=case_i).fillna(0)
                if "time" in var.dims:
                    var = var.isel(time=time_idx)
                print(f"  Case {case_label}:")
                for i, (x1, y1) in enumerate(points_raw):
                    x = x1 - 1
                    y = y1 - 1
                    if varname.endswith('E_h'):
                        left = var.values[y, x-1] if x-1 >= 0 else np.nan
                        right = var.values[y, x]
                        avg = np.nanmean([left, right])
                        print(f"    Point {i} (x={x1}, y={y1}): left(i-1,j)={left}, right(i,j)={right}, average={avg}")
                    elif varname.endswith('N_h'):
                        top = var.values[y-1, x] if y-1 >= 0 else np.nan
                        bottom = var.values[y, x]
                        avg = np.nanmean([top, bottom])
                        print(f"    Point {i} (x={x1}, y={y1}): top(i,j-1)={top}, bottom(i,j)={bottom}, average={avg}")
                    else:
                        ul = var.values[y, x]
                        ur = var.values[y, x+1] if x+1 < var.shape[1] else np.nan
                        ll = var.values[y+1, x] if y+1 < var.shape[0] else np.nan
                        lr = var.values[y+1, x+1] if (y+1 < var.shape[0] and x+1 < var.shape[1]) else np.nan
                        avg = np.nanmean([ul, ur, ll, lr])
                        print(f"    Point {i} (x={x1}, y={y1}): ul={ul}, ur={ur}, ll={ll}, lr={lr}, average={avg}")

    # Save all figures to a multipage PDF if requested
    if args.outfile:
        with PdfPages(args.outfile) as pdf:
            for fig in figs:
                pdf.savefig(fig)
                plt.close(fig)
    # Show all figures unless --no-display is set
    if not args.no_display:
        plt.show()
