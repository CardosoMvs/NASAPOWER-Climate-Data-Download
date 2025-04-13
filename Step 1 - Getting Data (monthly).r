############################################################
# NASA POWER Climate Data Downloader
# 
# Description:
# This script downloads climate data (e.g., T2M_MIN, T2M_MAX, precipitation) 
# from NASA POWER API for a specified region and time range. 
# Data is saved in parts to avoid API overload.
#
# Author: Cardoso.mvs@gmail.com
# Dependencies: nasapower, writexl, progress
############################################################

# Install and load the necessary packages
if (!require("nasapower")) {
  install.packages("nasapower")
  library(nasapower)
}
if (!require("writexl")) {
  install.packages("writexl")
  library(writexl)
}
if (!require("progress")) {
  install.packages("progress")
  library(progress)
}

# Define the parameter code (e.g., T2M_MAX, T2M_MIN, PRECTOTCORR_SUM)
parameter_code <- "T2M_MIN"

# Define the date range
start_date <- "2019-08-01"
end_date <- "2024-12-31"

# Define the bounding box for Brazil (approx.)
start_latitude <- -34.0   # South (slightly below Chuí/RS)
end_latitude <- 6.0       # North (slightly above Monte Caburaí/RR)
start_longitude <- -75.0  # West (slightly west of Serra do Divisor/AC)
end_longitude <- -34.0    # East (slightly east of Ponta do Seixas/PB)

# Optionally, bounding box for the Cerrado (uncomment if needed)
# start_latitude <- -24.0  # South (e.g., northern PR)
# end_latitude <- -2.0     # North (e.g., southern MA)
# start_longitude <- -60.0 # West (e.g., MT)
# end_longitude <- -45.0   # East (e.g., BA)

# Generate a list of latitude and longitude coordinates
latitude_values <- seq(start_latitude, end_latitude, by = 0.5)
longitude_values <- seq(start_longitude, end_longitude, by = 0.5)

# Total number of points to process
total_points <- length(latitude_values) * length(longitude_values)

# Initialize progress bar
pb <- progress_bar$new(
  format = "Downloading [:bar] :percent | Time: :elapsed | ETA: :eta",
  total = total_points,
  clear = FALSE,
  width = 80
)

# Create an empty list to store data frames
data_frames <- list()

# Set the maximum number of lon-lat pairs per part
lon_lat_per_part <- 100  # Avoid API overload
part_number <- 1
lon_lat_counter <- 0

# Define output directory
output_dir <- "C:/Users/marco/Downloads/nasapower-main/nasapower-main"

# Loop through latitude and longitude values
for (latitude in latitude_values) {
  for (longitude in longitude_values) {
    tryCatch({
      # Download data for the current coordinates
      data <- nasapower::get_power(
        community = "AG",
        lonlat = c(longitude, latitude),
        pars = parameter_code,
        dates = c(start_date, end_date),
        temporal_api = "monthly"
      )
      
      # Add coordinates to the data
      data$Latitude <- latitude
      data$Longitude <- longitude
      
      # Append the data to the list
      data_frames[[lon_lat_counter + 1]] <- data
      lon_lat_counter <- lon_lat_counter + 1
      
      # Update progress bar
      pb$tick()
      
      # Save data in parts
      if (lon_lat_counter == lon_lat_per_part) {
        output_file_name <- paste0("nasa_power_",parameter_code,"_part_", part_number, ".xlsx")
        output_file_path <- file.path(output_dir, output_file_name)
        
        merged_data <- do.call(rbind, data_frames)
        write_xlsx(merged_data, output_file_path)
        
        cat("\nPart", part_number, "saved at", output_file_path, "\n")
        
        # Reset counters
        lon_lat_counter <- 0
        data_frames <- list()
        part_number <- part_number + 1
      }
    }, error = function(e) {
      cat("\nError at lat=", latitude, "lon=", longitude, ":", e$message, "\n")
      pb$tick()  # Progress bar continues even on error
    })
  }
}

# Save remaining data (if any)
if (length(data_frames) > 0) {
  output_file_name <- paste0("nasa_power_",parameter_code,"_part_", part_number, ".xlsx")
  output_file_path <- file.path(output_dir, output_file_name)
  
  merged_data <- do.call(rbind, data_frames)
  write_xlsx(merged_data, output_file_path)
  
  cat("\nFinal part", part_number, "saved at", output_file_path, "\n")
}

cat("\nDownload complete for the entire Brazil region! Check the files in", output_dir)

############################################################
# Auxiliary script to REDOWNLOAD parts with error
############################################################

# # --- BASIC SETTINGS ---
# parts_with_error <- c(30, 46)  # <<< INSERT PART NUMBERS THAT FAILED
# 
# parameter_code <- "PRECTOTCORR_SUM"
# start_date <- "2019-08-01"
# end_date <- "2024-12-31"
# start_latitude <- -34.0
# end_latitude <- 6.0
# start_longitude <- -75.0
# end_longitude <- -34.0
# latitude_values <- seq(start_latitude, end_latitude, by = 0.5)
# longitude_values <- seq(start_longitude, end_longitude, by = 0.5)
# lon_lat_per_part <- 100
# output_dir <- "C:/Users/marco/Downloads/nasapower-main/nasapower-main"
# 
# # Generate all lon-lat combinations
# coords <- expand.grid(Longitude = longitude_values, Latitude = latitude_values)
# 
# # Loop for each part with error
# for (part_to_redo in parts_with_error) {
#   cat("\nRe-downloading part", part_to_redo, "...\n")
#   
#   start_index <- ((part_to_redo - 1) * lon_lat_per_part) + 1
#   end_index <- min(nrow(coords), part_to_redo * lon_lat_per_part)
#   coords_part <- coords[start_index:end_index, ]
#   
#   data_frames <- list()
#   pb <- progress_bar$new(
#     format = paste0("Part ", part_to_redo, " [:bar] :percent | ETA: :eta"),
#     total = nrow(coords_part), clear = FALSE, width = 80
#   )
#   
#   for (i in seq_len(nrow(coords_part))) {
#     lat <- coords_part$Latitude[i]
#     lon <- coords_part$Longitude[i]
#     tryCatch({
#       data <- nasapower::get_power(
#         community = "AG",
#         lonlat = c(lon, lat),
#         pars = parameter_code,
#         dates = c(start_date, end_date),
#         temporal_api = "monthly"
#       )
#       data$Latitude <- lat
#       data$Longitude <- lon
#       data_frames[[i]] <- data
#       pb$tick()
#     }, error = function(e) {
#       cat("\nError at lat=", lat, "lon=", lon, ":", e$message, "\n")
#       pb$tick()
#     })
#   }
#   
#   if (length(data_frames) > 0) {
#     output_file_name <- paste0("nasa_power_cerrado_part_", part_to_redo, "_RETRY.xlsx")
#     output_file_path <- file.path(output_dir, output_file_name)
#     merged_data <- do.call(rbind, data_frames)
#     write_xlsx(merged_data, output_file_path)
#     cat("\nPart", part_to_redo, "successfully redownloaded at", output_file_path, "\n")
#   } else {
#     cat("\nNo data was downloaded for part", part_to_redo, "\n")
#   }
# }
