############################################################
# NASA POWER Data Merger and Filtering by Brazil Boundary
#
# Description:
# This script merges multiple parts of downloaded NASA POWER 
# data, filters the data points to include only those within 
# Brazil (based on a national shapefile), and exports the 
# filtered results to an Excel file with an optional plot.
#
# Author: Cardoso.mvs@gmail.com
# Dependencies: geopandas, pandas, matplotlib, os
############################################################

import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
import os

# 1. Read Brazil shapefile (ensure correct path)
brasil_shp = gpd.read_file('nasapower-main/BR_Pais_2023/BR_Pais_2023.shp')

# Example parameter to process (change if needed)
parameter = 'PRECTOTCORR_SUM'  
# Alternatives: T2M_MIN, T2M_MAX, PRECTOTCORR_MEAN, etc.

# 2. Initialize empty DataFrame to store combined data
data_combined = pd.DataFrame()

# 3. Automatically determine how many parts are available
data_folder = '/nasapower-main/data'
part_files = [f for f in os.listdir(data_folder) if f.startswith(f'nasa_power_{parameter}_part_') and f.endswith('.xlsx')]
part_files.sort()  # Ensure parts are processed in order

# 4. Loop through all downloaded parts and combine them
for part_file in part_files:
    part_path = os.path.join(data_folder, part_file)
    data_part = pd.read_excel(part_path)
    data_combined = pd.concat([data_combined, data_part], ignore_index=True)

# 5. Convert DataFrame to GeoDataFrame using lat/lon
gdf = gpd.GeoDataFrame(
    data_combined,
    geometry=gpd.points_from_xy(data_combined['Longitude'], data_combined['Latitude']),
    crs=brasil_shp.crs  # Match the coordinate reference system
)

# 6. Filter only points that fall within Brazil
filtered_gdf = gdf[gdf.within(brasil_shp.unary_union)]

# 7. Remove geometry column (optional, for Excel export)
filtered_data = filtered_gdf.drop(columns='geometry')

# 8. Save filtered data to an Excel file
output_path = f'/nasapower-main/nasapower-main/nasa_power_data_{parameter}.xlsx'
filtered_data.to_excel(output_path, index=False)

# 9. Plot the results (optional)
fig, ax = plt.subplots(figsize=(20, 15))
brasil_shp.boundary.plot(ax=ax, linewidth=1, color='black')
filtered_gdf.plot(ax=ax, color='red', markersize=5)
plt.title(f'NASA POWER Data Points - {parameter}')

# 10. Save the plot as a PNG file (optional)
plot_path = f'/nasapower-main/nasa_power_plot_{parameter}.png'
plt.savefig(plot_path, dpi=300, bbox_inches='tight')
plt.show()
plt.close(fig)  # Free memory by closing the figure
