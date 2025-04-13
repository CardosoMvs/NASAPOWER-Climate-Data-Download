# NASA POWER Climate Data Downloader

This repository contains a script to download climate data from the **NASA POWER** (Prediction of Worldwide Energy Resources) API for a specified region and time range. The data includes variables such as minimum and maximum air temperature (T2M_MIN, T2M_MAX), precipitation, and other climate-related information on a monthly basis. The goal is to provide an easy way to access these data for climate analysis and environmental studies.

## Features

- **Climate Data Download**: Downloads monthly climate data for selected variables from the NASA POWER API for a defined region.
- **Prevents API Overload**: To avoid overloading the API, data is downloaded in parts, with a limit on the number of coordinates per request.
- **Supports Custom Regions**: The script can be configured to download data for any geographic area, with Brazil as a pre-configured example.
- **Excel Export**: Downloaded data is saved in `.xlsx` files for easy further analysis.
- **Filtering by National Borders**: For data related to Brazil, the script filters data points that fall within the national boundaries using a shapefile.

## Technologies and Dependencies

- **R**: The R script requires the following packages: `nasapower`, `writexl`, and `progress`.
- **Python**: A secondary Python script is used for processing the downloaded data, using libraries like `geopandas`, `pandas`, and `matplotlib`.

## How to Use

### Prerequisites

1. **Install Dependencies**:
   - For the R script, install the required packages with the following code:
     ```r
     if (!require("nasapower")) install.packages("nasapower")
     if (!require("writexl")) install.packages("writexl")
     if (!require("progress")) install.packages("progress")
     ```

2. **Obtain Brazil Shapefiles**: For the Python script, you will need a shapefile of Brazil to correctly filter the data.

### Running the Script

1. **Download Climate Data**:
   - Modify the region (latitude and longitude range) and parameters (e.g., T2M_MIN, T2M_MAX, etc.) in the R script, then run it to begin downloading the data. Data will be saved in parts in `.xlsx` format.

2. **Process and Filter Data (Optional)**:
   - After downloading, you can use the Python script to merge multiple downloaded parts, filter the data to include only points within Brazil’s boundaries, and save the results to a new Excel file.

## Example Workflow

1. **Download Data**: Configure the region and parameters, then run the R script to download climate data.
2. **Process and Merge Data**: Use the Python script to combine the parts, filter by the Brazilian border, and export the results to an Excel file.
3. **Visualization (Optional)**: Generate a plot of the filtered data with the option to save it as a PNG file.

## Contributing

Feel free to fork the repository and submit pull requests with improvements or fixes. Contributions are always welcome!

## License

This project is licensed under the [MIT License](LICENSE).
