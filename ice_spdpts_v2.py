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

# Velocity components to use for speed (per case)
u_names_default = ["uvel_h", "uvelN_h", "uvelN_h"]
v_names_default = ["vvel_h", "vvelN_h", "vvelN_h"]

# Velocity components for third transect (per case)
u_names_transect3 = ["uvel_h", "uvelE_h", "uvelE_h"]
v_names_transect3 = ["vvel_h", "vvelE_h", "vvelE_h"]

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


def plot_transect(points_xy_1based, transect_label, u_names, v_names):
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
            # Case 1: use icespd_h only
            spd = nds["icespd_h"].isel(case=case_i)
            if speed_stat == "instant" and "time" in spd.dims:
                spd = spd.isel(time=frame_i)
            if speed_stat == "mean" and "time" in spd.dims:
                spd = spd.mean("time", skipna=True)
            elif speed_stat == "max" and "time" in spd.dims:
                spd = spd.max("time", skipna=True)
            values = spd.values[ys, xs]
            axes[0].plot(dist, values, lw=1, marker=markers[case_i],
                         markersize=4, markevery=1, label=case_labels[case_i], color=colors[case_i])
        else:
            # Cases 2 and 3: plot both N and E
            spdN = nds["icespdN_h"].isel(case=case_i)
            spdE = nds["icespdE_h"].isel(case=case_i)
            if speed_stat == "instant" and "time" in spdN.dims:
                spdN = spdN.isel(time=frame_i)
                spdE = spdE.isel(time=frame_i)
            if speed_stat == "mean" and "time" in spdN.dims:
                spdN = spdN.mean("time", skipna=True)
                spdE = spdE.mean("time", skipna=True)
            elif speed_stat == "max" and "time" in spdN.dims:
                spdN = spdN.max("time", skipna=True)
                spdE = spdE.max("time", skipna=True)
            valuesN = spdN.values[ys, xs]
            valuesE = spdE.values[ys, xs]
            # N: solid, E: dotted, same color/marker
            axes[0].plot(dist, valuesN, lw=1, marker=markers[case_i],
                         markersize=4, markevery=1, label=f"{case_labels[case_i]} N", color=colors[case_i])
            axes[0].plot(dist, valuesE, lw=1, marker=markers[case_i],
                         markersize=4, markevery=1, label=f"{case_labels[case_i]} E", color=colors[case_i], linestyle=':')

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
    args = parser.parse_args()

    figs = []
    figs.append(plot_transect(points_xy_1based, "Transect 1"))
    figs.append(plot_transect(points_xy_1based_2, "Transect 2"))
    figs.append(plot_transect(points_xy_1based_3, "Transect 3"))

    # Save all figures to a multipage PDF if requested
    if args.outfile:
        with PdfPages(args.outfile) as pdf:
            for fig in figs:
                pdf.savefig(fig)
                plt.close(fig)
    # Show all figures unless --no-display is set
    if not args.no_display:
        for fig in figs:
            fig.show()
