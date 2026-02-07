import xarray as xr
import pandas as pd

class FerretStyle:
    def __init__(self, filepath, var_name):
        self.ds = xr.open_dataset(filepath)
        self.data = self.ds[var_name]
        # Common convention for 4D: (Time, Depth, Lat, Lon) -> (l, k, j, i)
        self.dims = self.data.dims

    def list(self, i=(1,1), j=(1,1), k=1, l=1):
        """
        Mimics list/i=1:4/j=1:4/k=5/l=10
        i, j, k, l can be a single int or a tuple (start, end)
        """
        def get_selector(val):
            # If user provides (start, end), return a 0-based slice
            if isinstance(val, tuple):
                return slice(val[0]-1, val[1])
            # If user provides a single int, return 0-based index
            return val - 1

        # Select the data
        # Mapping: dims[0]=l, dims[1]=k, dims[2]=j, dims[3]=i
        subset = self.data.isel({
            self.dims[0]: get_selector(l),
            self.dims[1]: get_selector(k),
            self.dims[2]: get_selector(j),
            self.dims[3]: get_selector(i)
        })

        # Convert to Pandas
        # drop_vars removes coordinate metadata (like lat/lon values) to force index-based view
        df = subset.drop_vars(subset.coords, errors='ignore').to_pandas()

        # Update labels to be 1-based and named i, j
        if isinstance(df, pd.DataFrame):
            df.index = df.index + 1
            df.columns = df.columns + 1
            df.index.name = 'j'
            df.columns.name = 'i'

        return df

# --- Usage Examples ---
# f = FerretStyle('my_data.nc', 'temp')

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
