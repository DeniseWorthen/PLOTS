import xarray as xr
import pandas as pd

class ferlist:
    def __init__(self, filepath, var_name):
        self.ds = xr.open_dataset(filepath, engine='netcdf4', cache=False)
        self.data = self.ds[var_name]
        # Common convention for 4D: (Time, Depth, Lat, Lon) -> (l, k, j, i)
        self.dims = self.data.dims

    def list(self, i=(1,1), j=(1,1), k=1, l=1):
        """
        Mimics list/i=1:4/j=1:4/k=5/l=10
        Handles variables with 2, 3, or 4 dimensions.
        """
        def get_selector(val):
            if isinstance(val, tuple):
                return slice(val[0]-1, val[1])
            return val - 1

        # Build selector dict based on number of dims, always mapping last two dims to i/j
        selectors = {}
        dims = self.dims
        # Map last two dims to i/j
        if len(dims) >= 2:
            # Build selectors for all dims, defaulting to full range if not specified
            sel_list = [None] * len(dims)
            # Assign selectors for i and j (last two dims)
            sel_list[-1] = get_selector(i)
            sel_list[-2] = get_selector(j)
            # If 3rd and 4th dims exist, assign k and l
            if len(dims) == 3:
                sel_list[0] = get_selector(l)
            if len(dims) == 4:
                sel_list[0] = get_selector(l)
                sel_list[1] = get_selector(k)
            # Build selector dict
            selectors = {dim: sel for dim, sel in zip(dims, sel_list) if sel is not None}
        else:
            raise ValueError(f"Unsupported number of dimensions: {len(dims)}")

        subset = self.data.isel(selectors)
        df = subset.drop_vars(subset.coords, errors='ignore').to_pandas()

        # Update labels to reflect actual i/j values requested, if DataFrame
        if isinstance(df, pd.DataFrame):
            # Determine i/j values from selectors for last two dims
            i_sel = sel_list[-1]
            j_sel = sel_list[-2]
            if isinstance(i_sel, slice):
                i_start = i_sel.start + 1 if i_sel.start is not None else 1
                i_stop = i_sel.stop
                i_vals = list(range(i_start, i_stop+1)) if i_stop is not None else df.columns + 1
            else:
                i_vals = [i_sel + 1]
            if isinstance(j_sel, slice):
                j_start = j_sel.start + 1 if j_sel.start is not None else 1
                j_stop = j_sel.stop
                j_vals = list(range(j_start, j_stop+1)) if j_stop is not None else df.index + 1
            else:
                j_vals = [j_sel + 1]
            if len(j_vals) == len(df.index):
                df.index = j_vals
            else:
                df.index = df.index + 1
            if len(i_vals) == len(df.columns):
                df.columns = i_vals
            else:
                df.columns = df.columns + 1
            df.index.name = 'j'
            df.columns.name = 'i'

        return df

# --- Usage Examples ---
## Example usage:
# fs = ferlist('my_data.nc', 'temp')
# print(fs.list(i=(1,4), j=(1,4), k=5, l=10))

# 1. List i=1:4, j=1:4 at a specific depth (k=5) and time (l=10)
# print(f.list(i=(1,4), j=(1,4), k=5, l=10))

# 2. List i=1:4, j=1:4 for the very first k and l (defaults)
# print(f.list(i=(1,4), j=(1,4)))


#To use the FerretStyle class in any arbitrary script, you should save the class definition in its own .py file
#and then import it. This keeps your plotting scripts clean and professional.

#Save the following code as a file named ferretools.py in your working directory:

# in plotting script
#import matplotlib.pyplot as plt
#from ferretools import FerretStyle  # Import your custom class

# 1. Initialize the Ferret-style helper
#fs = FerretStyle('data.nc', 'temp')

# 2. Quickly check values (Ferret style)
#print("--- Data Values at k=5, l=10 ---")
#print(fs.list(i=(1,4), j=(1,4), k=5, l=10))

# Same Folder: The easiest way is to keep ferretools.py in the same folder as your scripts.

# PYTHONPATH: If you want to use it across different projects without copying the file, move ferretools.py to
# a specific folder and add that folder to your PYTHONPATH environment variable.

# Interactive Use: You can also do this in a Jupyter Notebook by running %run ferretools.py in the first cell.
