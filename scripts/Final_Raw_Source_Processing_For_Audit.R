# U.S.–Ghana Blue Economy: direct-from-laptop Ghana coastal spatial pilot
# Verified against uploaded GFW fleet README (v3) and supplied archive names.
# Inputs remain on your computer. This script DOES NOT download data or fabricate values.
# Set downloads_dir below if your files are in a different folder.

options(timeout = 600)
downloads_dir <- file.path(Sys.getenv("OneDrive"), "Desktop", "blue economy")
output_dir <- file.path(downloads_dir, "Blue_Economy_R_Results")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

packages <- c("data.table", "sf", "terra", "ggplot2")
missing_pkg <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_pkg)) {
  message("Installing missing packages: ", paste(missing_pkg, collapse = ", "))
  install.packages(missing_pkg, repos = "https://cloud.r-project.org")
}
library(data.table)
library(sf)
library(terra)
library(ggplot2)

find_input <- function(filename) {
  locations <- c(file.path(downloads_dir, filename),
                 file.path(downloads_dir, "Blue_Economy", filename))
  paths <- locations[file.exists(locations)]
  if (!length(paths)) stop("Missing input: ", filename, "\nLooked in: ", paste(locations, collapse = "; "))
  paths[[1]]
}

# --- 1. Confirm local source archives before extracting ---
gfw_zips <- vapply(2018:2024, function(y) find_input(sprintf("fleet-monthly-csvs-10-v3-%d.zip", y)), character(1))
eez_zip <- find_input("World_EEZ_v12_20231025_LR.zip")
nasa_tar <- find_input("requested_files_1.tar")
production_csv <- find_input("capture-fishery-production.csv")
message("All essential source files located.")

# --- 2. Extract just the marine GeoPackage from the EEZ archive ---
geo_member <- grep("\\.gpkg$", unzip(eez_zip, list = TRUE)$Name, value = TRUE)[1]
if (is.na(geo_member)) stop("No GeoPackage found in EEZ ZIP.")
geo_dir <- file.path(output_dir, "boundary")
dir.create(geo_dir, recursive = TRUE, showWarnings = FALSE)
unzip(eez_zip, files = geo_member, exdir = geo_dir)
geo_file <- file.path(geo_dir, geo_member)
eez <- st_read(geo_file, quiet = TRUE)
if (!("MRGID" %in% names(eez))) stop("Boundary field MRGID not present; inspect names(eez).")
ghana_eez <- eez[as.character(eez$MRGID) == "8400", ]
if (nrow(ghana_eez) != 1) stop("Expected exactly one Ghana EEZ polygon (MRGID 8400).")
ghana_eez <- st_transform(st_make_valid(ghana_eez), 4326)
rm(eez)

# --- 3. Read each ZIP one month at a time; keep only Ghana coastal cells ---
# The NASA order covers N 6, S 3, W -4, E 2. These are NOT Ghana's complete EEZ.
# GFW coordinates are southwest grid corners. Add 0.05 for grid-cell center.
coastal_months <- list()
file_checks <- list()
tmp <- file.path(output_dir, "temporary_month")
dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
for (archive in gfw_zips) {
  members <- grep("\\.csv$", unzip(archive, list = TRUE)$Name, value = TRUE)
  for (member in sort(members)) {
    unzip(archive, files = member, exdir = tmp, overwrite = TRUE)
    path <- file.path(tmp, member)
    x <- fread(path, select = c("date", "cell_ll_lat", "cell_ll_lon", "fishing_hours", "hours", "geartype"), showProgress = FALSE)
    unlink(path)
    d <- as.Date(x$date[1])
    checks <- data.table(date = d, rows = nrow(x), missing_hours = sum(is.na(x$fishing_hours)),
                         negative_hours = sum(x$fishing_hours < 0, na.rm = TRUE))
    file_checks[[length(file_checks) + 1L]] <- checks
    x[, `:=`(lat = cell_ll_lat + 0.05, lon = cell_ll_lon + 0.05)]
    x <- x[lat >= 3 & lat <= 6 & lon >= -4 & lon <= 2]
    if (!nrow(x)) next
    # Spatial membership by center-point. Check boundary sensitivity in a later phase.
    cells <- unique(x[, .(lat, lon)])
    pts <- st_as_sf(cells, coords = c("lon", "lat"), crs = 4326, remove = FALSE)
    inside <- lengths(st_intersects(pts, ghana_eez)) > 0L
    cells <- cells[inside]
    x <- merge(x, cells, by = c("lat", "lon"), all = FALSE)
    if (nrow(x)) {
      a <- x[, .(fishing_hours = sum(fishing_hours, na.rm = TRUE),
                 presence_hours = sum(hours, na.rm = TRUE)), by = .(lat, lon)]
      a[, date := d]
      coastal_months[[length(coastal_months) + 1L]] <- a
    }
    message("Processed ", basename(member), ": ", nrow(x), " Ghana-coastal fleet records")
    rm(x)
    gc(verbose = FALSE)
  }
}
if (!length(coastal_months)) stop("No GFW cells matched Ghana's EEZ inside NASA rectangle. Inspect EEZ and coordinates.")
fishing <- rbindlist(coastal_months)
setcolorder(fishing, c("date", "lat", "lon", "fishing_hours", "presence_hours"))
fwrite(fishing, file.path(output_dir, "ghana_coastal_fishing_grid_monthly.csv"))
fwrite(rbindlist(file_checks), file.path(output_dir, "gfw_month_file_quality.csv"))

# --- 4. Extract NASA TAR using Windows-friendly utils::untar ---
nasa_dir <- file.path(output_dir, "nasa_extracted")
dir.create(nasa_dir, recursive = TRUE, showWarnings = FALSE)
utils::untar(nasa_tar, exdir = nasa_dir)
nc_files <- list.files(nasa_dir, pattern = "\\.nc$", recursive = TRUE, full.names = TRUE)
if (!length(nc_files)) stop("No NetCDF files found in NASA TAR.")
message("NASA NetCDF files: ", length(nc_files))

# Read monthly satellite chlorophyll at GFW cell centers.
# terra reads the raster's georeferencing; no fabricated interpolation or filling.
results <- list()
for (nc in nc_files) {
  label <- basename(nc)
  month_text <- regmatches(label, regexpr("20[0-9]{6}", label))
  if (!length(month_text) || !nzchar(month_text)) stop("Cannot read month from NetCDF name: ", label)
  date <- as.Date(paste0(substr(month_text, 1, 4), "-", substr(month_text, 5, 6), "-01"))
  target_date <- date
  grid <- fishing[date == target_date]
  if (!nrow(grid)) next
  raster <- tryCatch(terra::rast(nc, subds = "chlor_a"), error = function(e) terra::rast(nc))
  if (terra::nlyr(raster) != 1) stop("Expected one chlorophyll raster layer in ", label, "; inspect subdatasets.")
  points <- terra::vect(as.data.frame(grid[, .(lon, lat)]), geom = c("lon", "lat"), crs = "EPSG:4326")
  values <- terra::extract(raster, points, ID = FALSE)[[1]]
  grid[, chlor_a_mg_m3 := as.numeric(values)]
  grid[!is.finite(chlor_a_mg_m3) | chlor_a_mg_m3 < 0, chlor_a_mg_m3 := NA_real_]
  results[[length(results) + 1L]] <- grid
}
if (!length(results)) stop("No NASA/GFW overlap was found.")
matched <- rbindlist(results)
fwrite(matched, file.path(output_dir, "ghana_coastal_gfw_nasa_spatial_panel.csv"))

# --- 5. Honest monthly quality and descriptive summaries ---
monthly <- matched[, .(
  grid_cells = .N,
  observed_chlorophyll_cells = sum(!is.na(chlor_a_mg_m3)),
  chlorophyll_coverage_pct = 100 * mean(!is.na(chlor_a_mg_m3)),
  mean_chlorophyll_mg_m3 = if (all(is.na(chlor_a_mg_m3))) NA_real_ else mean(chlor_a_mg_m3, na.rm = TRUE),
  median_chlorophyll_mg_m3 = if (all(is.na(chlor_a_mg_m3))) NA_real_ else median(chlor_a_mg_m3, na.rm = TRUE),
  fishing_hours_all_cells = sum(fishing_hours),
  fishing_hours_cells_with_chlorophyll = sum(fishing_hours[!is.na(chlor_a_mg_m3)])
), by = date][order(date)]
all_dates <- data.table(date = seq(as.Date("2018-01-01"), as.Date("2024-12-01"), by = "month"))
monthly <- merge(all_dates, monthly, by = "date", all.x = TRUE)
monthly[, nasa_file_available := !is.na(grid_cells)]
monthly[, chlorophyll_lag1 := shift(mean_chlorophyll_mg_m3)]
# Lag1 only valid if previous calendar month is observed; missing NASA months remain NA.
fwrite(monthly, file.path(output_dir, "ghana_coastal_monthly_quality_and_lags.csv"))
fwrite(monthly[!nasa_file_available, .(date)], file.path(output_dir, "missing_nasa_months.csv"))

p <- ggplot(monthly, aes(x = date, y = fishing_hours_all_cells)) +
  geom_line(na.rm = TRUE) + labs(title = "Ghana coastal subset: AIS-derived apparent fishing effort",
  x = "Month", y = "Fishing hours, GFW cells matched to NASA rectangle") + theme_minimal()
ggsave(file.path(output_dir, "ghana_coastal_fishing_effort.png"), p, width = 9, height = 5, dpi = 180)

# --- 6. Country-level production data (separate scale; DO NOT join as monthly catch) ---
prod <- fread(production_csv)
country_prod <- prod[Code %in% c("GHA", "USA")]
fwrite(country_prod, file.path(output_dir, "country_capture_production_annual.csv"))

report <- c("BLUE ECONOMY: GHANA COASTAL DIRECT-EXTRACTION REPORT",
  paste("GFW months:", length(unique(fishing$date))),
  paste("NASA files:", length(nc_files)),
  paste("Spatially matched rows:", nrow(matched)),
  paste("Months with NASA/GFW overlap:", sum(monthly$nasa_file_available)),
  "GFW apparent fishing effort is AIS-derived and not actual catch.",
  "Region is Ghana EEZ INTERSECT NASA rectangle N6/S3/W-4/E2; not complete Ghana EEZ.",
  "Spatial matching uses 0.1-degree grid centers, not area-weighted intersections.",
  "NASA no-data values remain NA; missing calendar months are not zero-filled.",
  "Lagged environmental data must be checked for release timing before true forecasts.",
  "2024 observations and vessel classifications are provisional; AIS reception changes may bias year trends.",
  "This is QA and descriptive integration, NOT evidence of causal effect or novelty.")
writeLines(report, file.path(output_dir, "METHODS_AND_LIMITATIONS.txt"))
message("COMPLETE. Outputs at: ", output_dir)
print(monthly[, .(date, chlorophyll_coverage_pct, fishing_hours_all_cells)][1:min(10, .N)])