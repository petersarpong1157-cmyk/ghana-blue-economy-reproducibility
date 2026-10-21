
# Locate your OneDrive Desktop folder
onedrive <- Sys.getenv("OneDrive")

cat("OneDrive location:", onedrive, "\n")

# Set your Blue Economy project folder
project_dir <- file.path(
  onedrive,
  "Desktop",
  "blue economy"
)

# Check the folder
dir.exists(project_dir)

# Show files inside
list.files(project_dir)


# Create results folder inside your project
output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

# Confirm creation
dir.exists(output_dir)


# Locate all files, including subfolders
research_files <- list.files(
  project_dir,
  recursive = TRUE,
  full.names = TRUE
)

# Display research files
print(research_files)


# BLUE ECONOMY RESEARCH
# Project location - OneDrive Desktop

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

# Input files are stored here
downloads <- project_dir

# Results will be saved here
output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

cat("Project:", project_dir, "\n")
cat("Output:", output_dir, "\n")

stopifnot(dir.exists(project_dir))


required_files <- c(
  paste0(
    "fleet-monthly-csvs-10-v3-",
    2018:2024,
    ".zip"
  ),
  "World_EEZ_v12_20231025_LR.zip",
  "requested_files_1.tar",
  "capture-fishery-production.csv",
  "sst.mnmean.nc"
)

file_check <- data.frame(
  file = required_files,
  exists = file.exists(
    file.path(project_dir, required_files)
  )
)

print(file_check)

if (!all(file_check$exists)) {
  stop("Some required files are missing.")
}


# Execute the corrected research script
source(
  file.path(
    project_dir,
    "run_blue_economy_from_downloads.R"
  ),
  echo = TRUE
)


results <- list.files(
  output_dir,
  full.names = FALSE
)

print(results)

# Confirm the spatial panel exists
panel_path <- file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
)

cat(
  "Spatial panel created:",
  file.exists(panel_path),
  "\n"
)

if (file.exists(panel_path)) {
  panel <- read.csv(panel_path)
  
  cat("Rows:", nrow(panel), "\n")
  cat("Columns:", ncol(panel), "\n")
  print(names(panel))
  print(head(panel))
}




# 1. Locate your Blue Economy project
project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

script_path <- file.path(
  project_dir,
  "run_blue_economy_from_downloads.R"
)

stopifnot(file.exists(script_path))

# 2. Read the original R script
code <- readLines(script_path, warn = FALSE)

# 3. Locate the incorrect Downloads assignment
old_line <- 'downloads_dir <- file.path(Sys.getenv("USERPROFILE"), "Downloads")'

new_line <- 'downloads_dir <- file.path(Sys.getenv("OneDrive"), "Desktop", "blue economy")'

matches <- which(trimws(code) == old_line)

# 4. Replace it with the correct OneDrive path
if (length(matches) != 1) {
  stop("Expected exactly one Downloads assignment. Check the script.")
}

# Save a backup before changing anything
file.copy(
  script_path,
  paste0(script_path, ".backup"),
  overwrite = FALSE
)

code[matches] <- new_line

writeLines(code, script_path)

cat("SUCCESS: Script updated.\n")
cat("Project folder:", project_dir, "\n")


# Read the updated script
code <- readLines(script_path, warn = FALSE)

# Display directory assignments
grep(
  "downloads_dir <-|output_dir <-",
  code,
  value = TRUE
)


source(
  script_path,
  echo = TRUE
)


output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

print(list.files(output_dir))

panel_path <- file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
)

cat(
  "Spatial panel exists:",
  file.exists(panel_path),
  "\n"
)


library(data.table)

# Project location
project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

# Read the successfully created spatial panel
panel_path <- file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
)

stopifnot(file.exists(panel_path))

matched <- fread(panel_path)

# Inspect the real variables
print(names(matched))
print(dim(matched))
print(head(matched))

# Convert date and sort
matched[, date := as.Date(date)]
setorder(matched, date)

# Rebuild the monthly summary
monthly <- matched[, .(
  grid_cells = .N,
  observed_chlorophyll_cells = sum(!is.na(chlorophyll_mg_m3)),
  mean_chlorophyll_mg_m3 = if (
    all(is.na(chlorophyll_mg_m3))
  ) NA_real_ else mean(
    chlorophyll_mg_m3,
    na.rm = TRUE
  ),
  fishing_hours = sum(fishing_hours, na.rm = TRUE)
), by = date]

# Add all expected months
all_dates <- data.table(
  date = seq(
    as.Date("2018-01-01"),
    as.Date("2024-12-01"),
    by = "month"
  )
)

monthly <- merge(
  all_dates,
  monthly,
  by = "date",
  all.x = TRUE
)

setorder(monthly, date)

# Fix: explicitly call data.table::shift
monthly[, chlorophyll_lag1 :=
          data.table::shift(mean_chlorophyll_mg_m3, 1L)
]

monthly[, fishing_hours_lag1 :=
          data.table::shift(fishing_hours, 1L)
]

# Calculate satellite observation coverage
monthly[, chlorophyll_coverage_pct :=
          fifelse(
            grid_cells > 0,
            100 * observed_chlorophyll_cells / grid_cells,
            NA_real_
          )
]

# Save corrected results
fwrite(
  monthly,
  file.path(
    output_dir,
    "ghana_coastal_monthly_quality_and_lags.csv"
  )
)

cat("Monthly summary created successfully.\n")
cat("Months:", nrow(monthly), "\n")
print(head(monthly, 12))



library(data.table)

# Project folder
project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

# Read actual spatial panel
panel_path <- file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
)

matched <- fread(panel_path)

required <- c(
  "date", "lat", "lon",
  "fishing_hours", "presence_hours",
  "chlor_a_mg_m3"
)

stopifnot(all(required %in% names(matched)))

matched[, date := as.Date(date)]

# Build a fresh monthly summary
monthly_new <- matched[, .(
  grid_cells = .N,
  
  observed_chlorophyll_cells =
    sum(!is.na(chlor_a_mg_m3)),
  
  mean_chlorophyll_mg_m3 =
    if (all(is.na(chlor_a_mg_m3))) {
      NA_real_
    } else {
      mean(chlor_a_mg_m3, na.rm = TRUE)
    },
  
  fishing_hours =
    sum(fishing_hours, na.rm = TRUE),
  
  presence_hours =
    sum(presence_hours, na.rm = TRUE)
), by = date]

# Include every month from 2018 to 2024
all_dates <- data.table(
  date = seq(
    as.Date("2018-01-01"),
    as.Date("2024-12-01"),
    by = "month"
  )
)

monthly_new <- merge(
  all_dates,
  monthly_new,
  by = "date",
  all.x = TRUE
)

setorder(monthly_new, date)

# Correct lag calculations
monthly_new[, chlorophyll_lag1 :=
              data.table::shift(mean_chlorophyll_mg_m3, 1L)
]

monthly_new[, fishing_hours_lag1 :=
              data.table::shift(fishing_hours, 1L)
]

# Coverage within observed fishing cells
monthly_new[, chlorophyll_coverage_pct :=
              fifelse(
                grid_cells > 0,
                100 * observed_chlorophyll_cells / grid_cells,
                NA_real_
              )
]

# Validate before saving
stopifnot(nrow(monthly_new) == 84)
stopifnot("fishing_hours_lag1" %in% names(monthly_new))
stopifnot("chlorophyll_lag1" %in% names(monthly_new))

# Save corrected file
fwrite(
  monthly_new,
  file.path(
    output_dir,
    "ghana_coastal_monthly_quality_and_lags.csv"
  )
)

cat("SUCCESS: Corrected monthly dataset saved.\n")
cat("Rows:", nrow(monthly_new), "\n")

print(head(monthly_new, 12))


library(data.table)

# Check actual spatial data
stopifnot(
  all(c(
    "date", "lat", "lon",
    "fishing_hours", "chlor_a_mg_m3"
  ) %in% names(matched))
)

matched[, date := as.Date(date)]

# 1. Overall data quality
quality <- matched[, .(
  observations = .N,
  unique_months = uniqueN(date),
  unique_grid_cells = uniqueN(
    paste(lat, lon)
  ),
  missing_chlorophyll = sum(
    is.na(chlor_a_mg_m3)
  ),
  missing_pct = round(
    mean(is.na(chlor_a_mg_m3)) * 100, 2
  ),
  zero_fishing_pct = round(
    mean(fishing_hours == 0, na.rm = TRUE) * 100,
    2
  )
)]

print(quality)

# 2. Geographic cell coverage
cell_coverage <- matched[, .(
  months_observed = uniqueN(date),
  months_with_chlorophyll = sum(
    !is.na(chlor_a_mg_m3)
  )
), by = .(lat, lon)]

print(summary(cell_coverage$months_observed))

# 3. Count cells with repeated observations
cell_summary <- cell_coverage[, .(
  cells_total = .N,
  cells_at_least_24_months =
    sum(months_observed >= 24),
  cells_at_least_48_months =
    sum(months_observed >= 48),
  cells_at_least_60_months =
    sum(months_observed >= 60)
)]

print(cell_summary)

# 4. Annual data availability
matched[, year := as.integer(
  format(date, "%Y")
)]

annual_quality <- matched[, .(
  observations = .N,
  unique_cells = uniqueN(paste(lat, lon)),
  missing_chlorophyll_pct = round(
    mean(is.na(chlor_a_mg_m3)) * 100, 2
  ),
  total_fishing_hours = sum(
    fishing_hours,
    na.rm = TRUE
  )
), by = year]

setorder(annual_quality, year)
print(annual_quality)

# 5. Save quality reports
data.table::fwrite(
  quality,
  file.path(output_dir, "spatial_quality_summary.csv")
)

data.table::fwrite(
  cell_coverage,
  file.path(output_dir, "grid_cell_coverage.csv")
)

data.table::fwrite(
  annual_quality,
  file.path(output_dir, "annual_spatial_quality.csv")
)

cat("SUCCESS: Spatial quality analysis completed.\n")


library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

# Load the original GFW fishing grid
gfw <- fread(file.path(
  output_dir,
  "ghana_coastal_fishing_grid_monthly.csv"
))

# Load NASA-matched spatial observations
nasa <- fread(file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
))

# Verify actual required columns
stopifnot(all(c(
  "date", "lat", "lon",
  "fishing_hours", "presence_hours"
) %in% names(gfw)))

stopifnot(all(c(
  "date", "lat", "lon", "chlor_a_mg_m3"
) %in% names(nasa)))

gfw[, date := as.Date(date)]
nasa[, date := as.Date(date)]

# Check whether each grid-month is unique
gfw_duplicates <- gfw[, .N,
                      by = .(date, lat, lon)
][N > 1]

cat("Duplicate GFW grid-months:",
    nrow(gfw_duplicates), "\n")

if (nrow(gfw_duplicates) > 0) {
  stop("Resolve duplicate grid-months before continuing.")
}

# Define the geographic cells observed in GFW
cells <- unique(gfw[, .(lat, lon)])

# Define all 84 months
months <- data.table(
  date = seq(
    as.Date("2018-01-01"),
    as.Date("2024-12-01"),
    by = "month"
  )
)

# Create complete grid-month combinations
full_panel <- CJ(
  date = months$date,
  cell_id = seq_len(nrow(cells))
)

cells[, cell_id := .I]

full_panel <- merge(
  full_panel,
  cells,
  by = "cell_id"
)

# Join original fishing observations
gfw[, gfw_record_present := TRUE]

full_panel <- merge(
  full_panel,
  gfw,
  by = c("date", "lat", "lon"),
  all.x = TRUE
)

full_panel[
  is.na(gfw_record_present),
  gfw_record_present := FALSE
]

# Prepare chlorophyll observations
nasa_chl <- unique(
  nasa[, .(
    date, lat, lon, chlor_a_mg_m3
  )]
)

# Validate unique chlorophyll values by key
stopifnot(
  !anyDuplicated(
    nasa_chl,
    by = c("date", "lat", "lon")
  )
)

full_panel <- merge(
  full_panel,
  nasa_chl,
  by = c("date", "lat", "lon"),
  all.x = TRUE
)

# Sort each geographic cell chronologically
setorder(full_panel, cell_id, date)

# Create historical fishing-effort predictors
full_panel[, fishing_lag1 :=
             data.table::shift(fishing_hours, 1L),
           by = cell_id
]

full_panel[, fishing_lag12 :=
             data.table::shift(fishing_hours, 12L),
           by = cell_id
]

# Create lagged chlorophyll predictor
full_panel[, chlorophyll_lag1 :=
             data.table::shift(chlor_a_mg_m3, 1L),
           by = cell_id
]

# Add calendar variables
full_panel[, year := as.integer(
  format(date, "%Y")
)]

full_panel[, month := as.integer(
  format(date, "%m")
)]

# Validate the completed structure
expected_rows <- nrow(cells) * 84L

stopifnot(nrow(full_panel) == expected_rows)

cat("Geographic cells:", nrow(cells), "\n")
cat("Expected rows:", expected_rows, "\n")
cat("Actual rows:", nrow(full_panel), "\n")

cat(
  "GFW records absent:",
  sum(!full_panel$gfw_record_present),
  "\n"
)

# Save the complete panel
fwrite(
  full_panel,
  file.path(
    output_dir,
    "ghana_full_grid_month_panel.csv"
  )
)

cat("SUCCESS: Full spatial calendar created.\n")


library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

# Assign chronological evaluation periods
panel[, period := fifelse(
  date < as.Date("2023-01-01"),
  "Training",
  fifelse(
    date < as.Date("2024-01-01"),
    "Validation",
    "Provisional test"
  )
)]

# Check required predictors
required <- c(
  "fishing_hours",
  "fishing_lag1",
  "fishing_lag12",
  "chlorophyll_lag1"
)

stopifnot(all(required %in% names(panel)))

# Complete-case indicators
panel[, target_available :=
        !is.na(fishing_hours)
]

panel[, historical_ready :=
        !is.na(fishing_lag1) &
        !is.na(fishing_lag12)
]

panel[, environment_ready :=
        !is.na(chlorophyll_lag1)
]

# Compare data availability by period
readiness <- panel[, .(
  grid_months = .N,
  
  observed_targets =
    sum(target_available),
  
  missing_targets =
    sum(!target_available),
  
  historical_ready =
    sum(target_available &
          historical_ready),
  
  environment_ready =
    sum(target_available &
          historical_ready &
          environment_ready),
  
  complete_case_pct = round(
    100 * mean(
      target_available &
        historical_ready &
        environment_ready
    ),
    2
  )
), by = period]

setorder(
  readiness,
  match(
    period,
    c("Training", "Validation",
      "Provisional test")
  )
)

print(readiness)

# Save the validation report
fwrite(
  readiness,
  file.path(
    output_dir,
    "forecast_readiness_by_period.csv"
  )
)

cat("SUCCESS: Forecast readiness verified.\n")


# Correct ordering of evaluation periods
readiness[, period := factor(
  period,
  levels = c(
    "Training",
    "Validation",
    "Provisional test"
  )
)]

data.table::setorder(readiness, period)

print(readiness)

# Save the sorted report
data.table::fwrite(
  readiness,
  file.path(
    output_dir,
    "forecast_readiness_by_period.csv"
  )
)


library(data.table)

# Load verified full panel
panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

# Compare only grid-months with observed fishing targets
observed <- panel[!is.na(fishing_hours)]

# Separate environmental availability groups
observed[, chlorophyll_available :=
           !is.na(chlorophyll_lag1)
]

# Summarize differences
selection_check <- observed[, .(
  observations = .N,
  mean_fishing_hours = mean(fishing_hours),
  median_fishing_hours = median(fishing_hours),
  zero_fishing_pct = round(
    mean(fishing_hours == 0) * 100, 2
  ),
  mean_presence_hours = mean(
    presence_hours,
    na.rm = TRUE
  )
), by = chlorophyll_available]

print(selection_check)

# Compare environmental availability by year
observed[, year := as.integer(
  format(date, "%Y")
)]

availability_year <- observed[, .(
  observations = .N,
  chlorophyll_available_pct = round(
    mean(chlorophyll_available) * 100,
    2
  )
), by = year]

setorder(availability_year, year)

print(availability_year)

# Save the results
fwrite(
  selection_check,
  file.path(
    output_dir,
    "chlorophyll_selection_check.csv"
  )
)

fwrite(
  availability_year,
  file.path(
    output_dir,
    "chlorophyll_availability_by_year.csv"
  )
)

cat("SUCCESS: Missingness selection check completed.\n")


library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

# Identify chronological periods
panel[, period := fifelse(
  date < as.Date("2023-01-01"),
  "Training",
  fifelse(
    date < as.Date("2024-01-01"),
    "Validation",
    "Provisional test"
  )
)]

# Require observed outcome and historical predictors
panel[, historical_eligible :=
        !is.na(fishing_hours) &
        !is.na(fishing_lag1) &
        !is.na(fishing_lag12)
]

# Identical observations for model comparison
panel[, comparison_eligible :=
        historical_eligible &
        !is.na(chlorophyll_lag1)
]

# Compare sample sizes
sample_design <- panel[, .(
  total_grid_months = .N,
  historical_eligible = sum(historical_eligible),
  comparison_eligible = sum(comparison_eligible),
  comparison_pct_of_historical = round(
    100 * sum(comparison_eligible) /
      max(1, sum(historical_eligible)),
    2
  )
), by = period]

sample_design[, order_id := match(
  period,
  c("Training", "Validation", "Provisional test")
)]

setorder(sample_design, order_id)
sample_design[, order_id := NULL]

print(sample_design)

# Save matched comparison sample
comparison <- panel[comparison_eligible == TRUE]

fwrite(
  comparison,
  file.path(
    output_dir,
    "ghana_model_comparison_sample.csv"
  )
)

fwrite(
  sample_design,
  file.path(
    output_dir,
    "ghana_model_sample_design.csv"
  )
)

cat("SUCCESS: Model comparison sample created.\n")


library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Load the matched comparison sample
df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

df[, date := as.Date(date)]

# Confirm model variables
needed <- c(
  "fishing_hours",
  "fishing_lag1",
  "fishing_lag12",
  "chlorophyll_lag1",
  "month",
  "period"
)

stopifnot(all(needed %in% names(df)))

# Model variables
df[, month_factor := factor(month, levels = 1:12)]

# Historical-only model
model_a <- lm(
  log1p(fishing_hours) ~
    log1p(fishing_lag1) +
    log1p(fishing_lag12) +
    month_factor,
  data = df[period == "Training"]
)

# Environmental model
model_b <- lm(
  log1p(fishing_hours) ~
    log1p(fishing_lag1) +
    log1p(fishing_lag12) +
    log1p(chlorophyll_lag1) +
    month_factor,
  data = df[period == "Training"]
)

# Evaluate both on identical rows
evaluate <- function(data, model, label) {
  
  predicted <- expm1(
    predict(model, newdata = data)
  )
  
  predicted <- pmax(0, predicted)
  actual <- data$fishing_hours
  
  data.table(
    model = label,
    n = length(actual),
    MAE = mean(abs(actual - predicted)),
    RMSE = sqrt(mean((actual - predicted)^2)),
    WAPE = if (sum(actual) > 0) {
      100 * sum(abs(actual - predicted)) /
        sum(actual)
    } else {
      NA_real_
    }
  )
}

validation <- rbindlist(list(
  evaluate(
    df[period == "Validation"],
    model_a,
    "Historical only"
  ),
  evaluate(
    df[period == "Validation"],
    model_b,
    "Historical + chlorophyll"
  )
))

cat("2023 validation results:\n")
print(validation)

# Evaluate both models on provisional 2024
test <- rbindlist(list(
  evaluate(
    df[period == "Provisional test"],
    model_a,
    "Historical only"
  ),
  evaluate(
    df[period == "Provisional test"],
    model_b,
    "Historical + chlorophyll"
  )
))

cat("2024 provisional test results:\n")
print(test)

# Save actual results
fwrite(
  validation,
  file.path(output_dir, "linear_validation_2023.csv")
)

fwrite(
  test,
  file.path(output_dir, "linear_test_2024.csv")
)

cat("SUCCESS: Linear forecasting benchmarks completed.\n")


library(data.table)

# Load the existing matched comparison sample
output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

df[, date := as.Date(date)]

# Validate the observed values
stopifnot(
  all(df$fishing_hours >= 0),
  all(df$fishing_lag12 >= 0),
  all(df$fishing_lag1 >= 0),
  all(df$chlorophyll_lag1 >= 0)
)

df[, month_factor := factor(
  month, levels = 1:12
)]

# Refit models using training observations only
train <- df[period == "Training"]

model_a <- lm(
  log1p(fishing_hours) ~
    log1p(fishing_lag1) +
    log1p(fishing_lag12) +
    month_factor,
  data = train
)

model_b <- lm(
  log1p(fishing_hours) ~
    log1p(fishing_lag1) +
    log1p(fishing_lag12) +
    log1p(chlorophyll_lag1) +
    month_factor,
  data = train
)

# Evaluate seasonal and linear predictions
evaluate_year <- function(period_name) {
  
  d <- copy(df[period == period_name])
  
  d[, seasonal := fishing_lag12]
  
  d[, historical := pmax(
    0, expm1(predict(model_a, newdata = d))
  )]
  
  d[, environmental := pmax(
    0, expm1(predict(model_b, newdata = d))
  )]
  
  result <- rbindlist(lapply(
    c("seasonal", "historical", "environmental"),
    function(model_name) {
      
      actual <- d$fishing_hours
      predicted <- d[[model_name]]
      
      data.table(
        period = period_name,
        model = model_name,
        n = length(actual),
        MAE = mean(abs(actual - predicted)),
        RMSE = sqrt(mean(
          (actual - predicted)^2
        )),
        WAPE = 100 *
          sum(abs(actual - predicted)) /
          sum(actual)
      )
    }
  ))
  
  list(metrics = result, predictions = d)
}

# Evaluate without refitting on later years
val <- evaluate_year("Validation")
test <- evaluate_year("Provisional test")

results <- rbindlist(list(
  val$metrics,
  test$metrics
))

print(results)

# Inspect month-level error differences in 2023
monthly_errors <- val$predictions[, .(
  seasonal_MAE = mean(
    abs(fishing_hours - seasonal)
  ),
  historical_MAE = mean(
    abs(fishing_hours - historical)
  ),
  environmental_MAE = mean(
    abs(fishing_hours - environmental)
  )
), by = date]

print(monthly_errors)

# Save the real results
fwrite(
  results,
  file.path(
    output_dir,
    "seasonal_vs_linear_benchmarks.csv"
  )
)

fwrite(
  monthly_errors,
  file.path(
    output_dir,
    "validation_monthly_model_errors.csv"
  )
)

cat("SUCCESS: Seasonal benchmark completed.\n")


packages <- c(
  "data.table",
  "ranger",
  "xgboost",
  "ggplot2"
)

missing <- packages[
  !vapply(
    packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(missing) > 0) {
  install.packages(
    missing,
    repos = "https://cloud.r-project.org"
  )
}

# Confirm package availability
data.frame(
  package = packages,
  installed = vapply(
    packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
)


# PHASE 6: GHANA COASTAL MACHINE LEARNING
# Historical vs environmental forecasting
# Training: 2018-2022
# Validation: 2023
# 2024 intentionally excluded

library(data.table)
library(ranger)
library(xgboost)

set.seed(2026)

# 1. Locate the real research dataset
output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

df[, date := as.Date(date)]

required <- c(
  "date", "month", "period",
  "fishing_hours", "fishing_lag1",
  "fishing_lag12", "chlorophyll_lag1"
)

stopifnot(all(required %in% names(df)))

# 2. Check data validity
variables <- c(
  "fishing_hours", "fishing_lag1",
  "fishing_lag12", "chlorophyll_lag1"
)

stopifnot(
  all(complete.cases(df[, ..variables])),
  all(as.matrix(df[, ..variables]) >= 0),
  all(is.finite(as.matrix(df[, ..variables])))
)

# 3. Create model features
df[, lag1_log := log1p(fishing_lag1)]
df[, lag12_log := log1p(fishing_lag12)]
df[, chl_log := log1p(chlorophyll_lag1)]

df[, month_sin := sin(2 * pi * month / 12)]
df[, month_cos := cos(2 * pi * month / 12)]

df[, target_log := log1p(fishing_hours)]

# Historical predictors
hist_vars <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

# Historical + environmental predictors
env_vars <- c(hist_vars, "chl_log")

# 4. Chronological split
train <- df[period == "Training"]
valid <- df[period == "Validation"]

stopifnot(
  nrow(train) > 0,
  nrow(valid) > 0,
  max(train$date) < min(valid$date)
)

cat("Training observations:", nrow(train), "\n")
cat("Validation observations:", nrow(valid), "\n")

# 5. Random Forest models
rf_hist <- ranger(
  target_log ~ .,
  data = as.data.frame(
    train[, c("target_log", hist_vars), with = FALSE]
  ),
  num.trees = 500,
  mtry = 2,
  min.node.size = 10,
  seed = 2026,
  num.threads = 2
)

rf_env <- ranger(
  target_log ~ .,
  data = as.data.frame(
    train[, c("target_log", env_vars), with = FALSE]
  ),
  num.trees = 500,
  mtry = 2,
  min.node.size = 10,
  seed = 2026,
  num.threads = 2
)

# 6. XGBoost training function
fit_xgb <- function(features) {
  
  x_train <- as.matrix(
    train[, ..features]
  )
  
  dtrain <- xgb.DMatrix(
    data = x_train,
    label = train$target_log
  )
  
  xgb.train(
    params = list(
      objective = "reg:squarederror",
      eta = 0.05,
      max_depth = 4,
      min_child_weight = 10,
      subsample = 1,
      colsample_bytree = 1,
      nthread = 2,
      seed = 2026
    ),
    data = dtrain,
    nrounds = 200,
    verbose = 0
  )
}

xgb_hist <- fit_xgb(hist_vars)
xgb_env <- fit_xgb(env_vars)

# 7. Produce validation predictions
valid <- copy(valid)

from_log <- function(x) {
  pmax(0, expm1(as.numeric(x)))
}

valid[, seasonal := fishing_lag12]

valid[, rf_historical := from_log(
  predict(
    rf_hist,
    data = as.data.frame(
      valid[, ..hist_vars]
    )
  )$predictions
)]

valid[, rf_environmental := from_log(
  predict(
    rf_env,
    data = as.data.frame(
      valid[, ..env_vars]
    )
  )$predictions
)]

valid[, xgb_historical := from_log(
  predict(
    xgb_hist,
    as.matrix(valid[, ..hist_vars])
  )
)]

valid[, xgb_environmental := from_log(
  predict(
    xgb_env,
    as.matrix(valid[, ..env_vars])
  )
)]

# 8. Evaluate identical validation observations
model_names <- c(
  "seasonal",
  "rf_historical",
  "rf_environmental",
  "xgb_historical",
  "xgb_environmental"
)

metrics <- rbindlist(lapply(
  model_names,
  function(model_name) {
    
    actual <- valid$fishing_hours
    predicted <- valid[[model_name]]
    
    stopifnot(all(is.finite(predicted)))
    
    data.table(
      model = model_name,
      n = length(actual),
      MAE = mean(abs(actual - predicted)),
      RMSE = sqrt(mean(
        (actual - predicted)^2
      )),
      WAPE = 100 *
        sum(abs(actual - predicted)) /
        sum(actual)
    )
  }
))

setorder(metrics, MAE)

cat("\n2023 MODEL COMPARISON\n")
print(metrics)

# 9. Examine performance by month
monthly_metrics <- rbindlist(lapply(
  model_names,
  function(model_name) {
    
    valid[, .(
      model = model_name,
      n = .N,
      MAE = mean(
        abs(fishing_hours -
              get(model_name))
      )
    ), by = date]
  }
))

setorder(monthly_metrics, date, model)

# 10. Save real model outputs
fwrite(
  metrics,
  file.path(
    output_dir,
    "phase6_model_metrics_2023.csv"
  )
)

fwrite(
  monthly_metrics,
  file.path(
    output_dir,
    "phase6_monthly_errors_2023.csv"
  )
)

fwrite(
  valid[, c(
    "date", "lat", "lon",
    "fishing_hours", model_names
  ), with = FALSE],
  file.path(
    output_dir,
    "phase6_validation_predictions.csv"
  )
)

saveRDS(
  list(
    rf_hist = rf_hist,
    rf_env = rf_env,
    xgb_hist = xgb_hist,
    xgb_env = xgb_env,
    hist_vars = hist_vars,
    env_vars = env_vars
  ),
  file.path(
    output_dir,
    "phase6_trained_models.rds"
  )
)

cat("\nSUCCESS: Phase 6 models completed.\n")


library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Read actual saved validation predictions
pred <- fread(file.path(
  output_dir,
  "phase6_validation_predictions.csv"
))

pred[, date := as.Date(date)]

required <- c(
  "date", "lat", "lon", "fishing_hours",
  "rf_historical", "rf_environmental"
)

stopifnot(all(required %in% names(pred)))

# Calculate absolute errors for each model
pred[, error_hist :=
       abs(fishing_hours - rf_historical)
]

pred[, error_env :=
       abs(fishing_hours - rf_environmental)
]

# Positive improvement favors chlorophyll
pred[, improvement :=
       error_hist - error_env
]

# Monthly paired error comparison
monthly_comparison <- pred[, .(
  observations = .N,
  historical_MAE = mean(error_hist),
  environmental_MAE = mean(error_env),
  mean_improvement = mean(improvement),
  pct_cells_improved = round(
    100 * mean(improvement > 0), 2
  )
), by = date]

setorder(monthly_comparison, date)

print(monthly_comparison)

# Geographic cell-level comparison
spatial_comparison <- pred[, .(
  observations = .N,
  historical_MAE = mean(error_hist),
  environmental_MAE = mean(error_env),
  mean_improvement = mean(improvement)
), by = .(lat, lon)]

# Summary across geographic cells
spatial_summary <- spatial_comparison[, .(
  cells = .N,
  cells_improved = sum(mean_improvement > 0),
  cells_worsened = sum(mean_improvement < 0),
  pct_cells_improved = round(
    100 * mean(mean_improvement > 0), 2
  ),
  median_cell_improvement =
    median(mean_improvement)
)]

cat("\nSPATIAL ROBUSTNESS SUMMARY\n")
print(spatial_summary)

# Save results
fwrite(
  monthly_comparison,
  file.path(
    output_dir,
    "phase6_monthly_robustness.csv"
  )
)

fwrite(
  spatial_comparison,
  file.path(
    output_dir,
    "phase6_spatial_robustness.csv"
  )
)

fwrite(
  spatial_summary,
  file.path(
    output_dir,
    "phase6_spatial_summary.csv"
  )
)

cat("\nSUCCESS: Phase 6 robustness screening completed.\n")


# PHASE 7A: UNCERTAINTY AND SPATIAL ROBUSTNESS

library(data.table)
set.seed(2026)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

pred <- fread(file.path(
  output_dir,
  "phase6_validation_predictions.csv"
))

pred[, date := as.Date(date)]

stopifnot(all(c(
  "date", "lat", "lon", "fishing_hours",
  "rf_historical", "rf_environmental"
) %in% names(pred)))

# Positive gain means chlorophyll improves accuracy
pred[, gain :=
       abs(fishing_hours - rf_historical) -
       abs(fishing_hours - rf_environmental)
]

stopifnot(all(is.finite(pred$gain)))

cat("Overall mean MAE improvement:",
    mean(pred$gain), "\n")

# 1. Bootstrap entire months
# Retains all observations within a sampled month
monthly <- pred[, .(
  gain_sum = sum(gain),
  n = .N
), by = date]

B <- 2000L

month_boot <- replicate(B, {
  sampled <- sample.int(
    nrow(monthly),
    nrow(monthly),
    replace = TRUE
  )
  
  sum(monthly$gain_sum[sampled]) /
    sum(monthly$n[sampled])
})

# 2. Spatial block bootstrap
# Preliminary 0.5-degree geographic blocks
pred[, block_lat := floor(lat * 2) / 2]
pred[, block_lon := floor(lon * 2) / 2]

blocks <- pred[, .(
  gain_sum = sum(gain),
  n = .N
), by = .(block_lat, block_lon)]

spatial_boot <- replicate(B, {
  sampled <- sample.int(
    nrow(blocks),
    nrow(blocks),
    replace = TRUE
  )
  
  sum(blocks$gain_sum[sampled]) /
    sum(blocks$n[sampled])
})

# 3. Summarize bootstrap distributions
summarize_boot <- function(x, method) {
  data.table(
    method = method,
    estimate = mean(pred$gain),
    lower_95 = unname(quantile(x, 0.025)),
    upper_95 = unname(quantile(x, 0.975)),
    probability_positive_boot = mean(x > 0)
  )
}

bootstrap_results <- rbindlist(list(
  summarize_boot(month_boot, "Monthly blocks"),
  summarize_boot(spatial_boot, "Spatial blocks")
))

cat("\nBOOTSTRAP ROBUSTNESS RESULTS\n")
print(bootstrap_results)

cat("\nSpatial blocks:", nrow(blocks), "\n")
cat("Months:", nrow(monthly), "\n")

fwrite(
  bootstrap_results,
  file.path(
    output_dir,
    "phase7_bootstrap_robustness.csv"
  )
)

cat("\nSUCCESS: Phase 7A completed.\n")


# PHASE 7B: MONTHLY AND SPATIAL SENSITIVITY

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

pred <- fread(file.path(
  output_dir,
  "phase6_validation_predictions.csv"
))

pred[, date := as.Date(date)]

# Paired differences in absolute forecast error
pred[, gain :=
       abs(fishing_hours - rf_historical) -
       abs(fishing_hours - rf_environmental)
]

stopifnot(all(is.finite(pred$gain)))

overall_gain <- mean(pred$gain)

# 1. Leave one month out at a time
months <- sort(unique(pred$date))

monthly_sensitivity <- rbindlist(lapply(
  months,
  function(m) {
    d <- pred[date != m]
    
    data.table(
      excluded_month = m,
      observations = nrow(d),
      mean_gain = mean(d$gain)
    )
  }
))

# 2. Create 0.5-degree geographic blocks
pred[, block_lat := floor(lat * 2) / 2]
pred[, block_lon := floor(lon * 2) / 2]

spatial_blocks <- unique(
  pred[, .(block_lat, block_lon)]
)

# 3. Leave one spatial block out
spatial_sensitivity <- rbindlist(lapply(
  seq_len(nrow(spatial_blocks)),
  function(i) {
    
    b_lat <- spatial_blocks$block_lat[i]
    b_lon <- spatial_blocks$block_lon[i]
    
    d <- pred[
      !(block_lat == b_lat &
          block_lon == b_lon)
    ]
    
    data.table(
      excluded_lat = b_lat,
      excluded_lon = b_lon,
      observations = nrow(d),
      mean_gain = mean(d$gain)
    )
  }
))

# 4. Summary
sensitivity_summary <- data.table(
  test = c("Leave-month-out", "Leave-block-out"),
  overall_gain = overall_gain,
  min_gain = c(
    min(monthly_sensitivity$mean_gain),
    min(spatial_sensitivity$mean_gain)
  ),
  max_gain = c(
    max(monthly_sensitivity$mean_gain),
    max(spatial_sensitivity$mean_gain)
  ),
  pct_positive = c(
    100 * mean(monthly_sensitivity$mean_gain > 0),
    100 * mean(spatial_sensitivity$mean_gain > 0)
  )
)

print(sensitivity_summary)

# Save reproducible results
fwrite(
  monthly_sensitivity,
  file.path(output_dir, "phase7b_month_sensitivity.csv")
)

fwrite(
  spatial_sensitivity,
  file.path(output_dir, "phase7b_spatial_sensitivity.csv")
)

fwrite(
  sensitivity_summary,
  file.path(output_dir, "phase7b_sensitivity_summary.csv")
)

cat("SUCCESS: Phase 7B completed.\n")



# PHASE 8: SPATIALLY HELD-OUT FORECASTING
# Ghana coastal study - exploratory experiment

library(data.table)
library(ranger)

set.seed(2026)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop", "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

df[, date := as.Date(date)]

# Define geographic blocks
df[, block_lat := floor(lat * 2) / 2]
df[, block_lon := floor(lon * 2) / 2]

df[, block_id := paste(block_lat, block_lon)]

# Select held-out blocks independently of outcomes
blocks <- sort(unique(df$block_id))

test_blocks <- sample(
  blocks,
  size = max(1L, floor(length(blocks) * 0.2))
)

# Training excludes held-out geographic blocks
train <- df[
  period == "Training" &
    !block_id %in% test_blocks
]

# Evaluate in 2023 on new blocks
valid <- df[
  period == "Validation" &
    block_id %in% test_blocks
]

cat("Training records:", nrow(train), "\n")
cat("Validation records:", nrow(valid), "\n")
cat("Held-out blocks:", length(test_blocks), "\n")

stopifnot(nrow(train) > 0, nrow(valid) > 0)

# Model variables
for (d in list(train, valid)) {
  d[, lag1_log := log1p(fishing_lag1)]
  d[, lag12_log := log1p(fishing_lag12)]
  d[, chl_log := log1p(chlorophyll_lag1)]
  d[, month_sin := sin(2*pi*month/12)]
  d[, month_cos := cos(2*pi*month/12)]
  d[, target_log := log1p(fishing_hours)]
}

hist_vars <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

env_vars <- c(hist_vars, "chl_log")

# Train the historical model
rf_hist <- ranger(
  target_log ~ .,
  data = as.data.frame(
    train[, c("target_log",hist_vars), with=FALSE]
  ),
  num.trees = 500,
  mtry = 2,
  min.node.size = 10,
  seed = 2026
)

# Train the environmental model
rf_env <- ranger(
  target_log ~ .,
  data = as.data.frame(
    train[, c("target_log",env_vars), with=FALSE]
  ),
  num.trees = 500,
  mtry = 2,
  min.node.size = 10,
  seed = 2026
)

# Predictions
valid[, historical := pmax(
  0, expm1(predict(
    rf_hist,
    data=as.data.frame(valid[, ..hist_vars])
  )$predictions)
)]

valid[, environmental := pmax(
  0, expm1(predict(
    rf_env,
    data=as.data.frame(valid[, ..env_vars])
  )$predictions)
)]

valid[, seasonal := fishing_lag12]

# Compare all three models on identical observations
models <- c(
  "seasonal", "historical", "environmental"
)

results <- rbindlist(lapply(models, function(m) {
  actual <- valid$fishing_hours
  predicted <- valid[[m]]
  
  data.table(
    model = m,
    n = length(actual),
    MAE = mean(abs(actual-predicted)),
    RMSE = sqrt(mean((actual-predicted)^2)),
    WAPE = 100*sum(abs(actual-predicted))/
      sum(actual)
  )
}))

print(results)

# Save outputs
fwrite(
  results,
  file.path(output_dir,"phase8_spatial_metrics.csv")
)

fwrite(
  valid[, .(
    date,lat,lon,block_id,fishing_hours,
    seasonal,historical,environmental
  )],
  file.path(output_dir,"phase8_spatial_predictions.csv")
)

cat("SUCCESS: Spatial validation completed.\n")


# PHASE 8B: REPEATED SPATIAL VALIDATION
# Exploratory robustness analysis
# Uses 2018-2022 for fitting and 2023 for validation

library(data.table)
library(ranger)

set.seed(2026)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

df[, date := as.Date(date)]

# Establish geographic blocks
df[, block_lat := floor(lat * 2) / 2]
df[, block_lon := floor(lon * 2) / 2]
df[, block_id := paste(block_lat, block_lon)]

# Create predictors
df[, lag1_log := log1p(fishing_lag1)]
df[, lag12_log := log1p(fishing_lag12)]
df[, chl_log := log1p(chlorophyll_lag1)]

df[, month_sin := sin(2*pi*month/12)]
df[, month_cos := cos(2*pi*month/12)]
df[, target_log := log1p(fishing_hours)]

hist_vars <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

env_vars <- c(hist_vars, "chl_log")

# Use fixed definitions across all repetitions
all_blocks <- sort(unique(df$block_id))

B <- 20L

results_list <- vector("list", B)

for (i in seq_len(B)) {
  
  held_blocks <- sample(
    all_blocks,
    size = max(1L, floor(0.2 * length(all_blocks)))
  )
  
  train <- df[
    period == "Training" &
      !block_id %in% held_blocks
  ]
  
  valid <- df[
    period == "Validation" &
      block_id %in% held_blocks
  ]
  
  if (nrow(train) == 0 || nrow(valid) == 0) {
    stop("Empty partition in repetition ", i)
  }
  
  fit_rf <- function(features) {
    ranger(
      target_log ~ .,
      data = as.data.frame(
        train[, c("target_log", features),
              with = FALSE]
      ),
      num.trees = 300,
      mtry = 2,
      min.node.size = 10,
      seed = 2026,
      num.threads = 2
    )
  }
  
  model_h <- fit_rf(hist_vars)
  model_e <- fit_rf(env_vars)
  
  pred_h <- pmax(
    0,
    expm1(predict(
      model_h,
      data = as.data.frame(
        valid[, ..hist_vars]
      )
    )$predictions)
  )
  
  pred_e <- pmax(
    0,
    expm1(predict(
      model_e,
      data = as.data.frame(
        valid[, ..env_vars]
      )
    )$predictions)
  )
  
  actual <- valid$fishing_hours
  
  mae_h <- mean(abs(actual - pred_h))
  mae_e <- mean(abs(actual - pred_e))
  
  results_list[[i]] <- data.table(
    repetition = i,
    training_n = nrow(train),
    validation_n = nrow(valid),
    held_blocks = length(held_blocks),
    historical_MAE = mae_h,
    environmental_MAE = mae_e,
    improvement = mae_h - mae_e
  )
  
  cat("Completed repetition", i, "of", B, "\n")
}

spatial_cv <- rbindlist(results_list)

cat("\nREPEATED SPATIAL VALIDATION\n")
print(spatial_cv)

summary_cv <- spatial_cv[, .(
  repetitions = .N,
  avg_historical_MAE = mean(historical_MAE),
  avg_environmental_MAE = mean(environmental_MAE),
  avg_improvement = mean(improvement),
  median_improvement = median(improvement),
  pct_repetitions_improved =
    round(100 * mean(improvement > 0), 2),
  min_improvement = min(improvement),
  max_improvement = max(improvement)
)]

cat("\nSPATIAL VALIDATION SUMMARY\n")
print(summary_cv)

fwrite(
  spatial_cv,
  file.path(
    output_dir,
    "phase8b_repeated_spatial_cv.csv"
  )
)

fwrite(
  summary_cv,
  file.path(
    output_dir,
    "phase8b_spatial_cv_summary.csv"
  )
)

cat("\nSUCCESS: Phase 8B completed.\n")



# PHASE 9: OBSERVATION COVERAGE SENSITIVITY
# Train: 2018-2022
# Evaluate: 2023 only

library(data.table)
library(ranger)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

# Historical eligibility, without requiring chlorophyll
panel <- panel[
  !is.na(fishing_hours) &
    !is.na(fishing_lag1) &
    !is.na(fishing_lag12)
]

stopifnot(
  all(is.finite(panel$fishing_hours)),
  all(is.finite(panel$fishing_lag1)),
  all(is.finite(panel$fishing_lag12)),
  all(panel$fishing_hours >= 0),
  all(panel$fishing_lag1 >= 0),
  all(panel$fishing_lag12 >= 0)
)

# Historical predictors
panel[, lag1_log := log1p(fishing_lag1)]
panel[, lag12_log := log1p(fishing_lag12)]
panel[, month_sin := sin(2*pi*month/12)]
panel[, month_cos := cos(2*pi*month/12)]
panel[, target_log := log1p(fishing_hours)]

panel[, chl_available := !is.na(chlorophyll_lag1)]

features <- c(
  "lag1_log",
  "lag12_log",
  "month_sin",
  "month_cos"
)

train <- panel[
  date >= as.Date("2018-01-01") &
    date < as.Date("2023-01-01")
]

valid <- copy(panel[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01")
])

cat("Training records:", nrow(train), "\n")
cat("Validation records:", nrow(valid), "\n")

# Fit the same historical-only model for all groups
model <- ranger(
  target_log ~ .,
  data = as.data.frame(
    train[, c("target_log", features),
          with = FALSE]
  ),
  num.trees = 500,
  mtry = 2,
  min.node.size = 10,
  seed = 2026,
  num.threads = 2
)

# Predict 2023 fishing effort
valid[, predicted := pmax(
  0,
  expm1(
    predict(
      model,
      data = as.data.frame(
        valid[, ..features]
      )
    )$predictions
  )
)]

valid[, absolute_error :=
        abs(fishing_hours - predicted)
]

valid[, seasonal_error :=
        abs(fishing_hours - fishing_lag12)
]

# Compare availability groups
coverage_results <- valid[, .(
  observations = .N,
  mean_actual_hours = mean(fishing_hours),
  median_actual_hours = median(fishing_hours),
  historical_MAE = mean(absolute_error),
  historical_RMSE = sqrt(mean(
    (fishing_hours - predicted)^2
  )),
  seasonal_MAE = mean(seasonal_error)
), by = chl_available]

setorder(coverage_results, chl_available)

cat("\n2023 COVERAGE SENSITIVITY\n")
print(coverage_results)

# Overall performance on the broader sample
overall_results <- valid[, .(
  observations = .N,
  historical_MAE = mean(absolute_error),
  historical_RMSE = sqrt(mean(
    (fishing_hours - predicted)^2
  )),
  seasonal_MAE = mean(seasonal_error)
)]

cat("\n2023 BROADER-SAMPLE PERFORMANCE\n")
print(overall_results)

# Save results and predictions
fwrite(
  coverage_results,
  file.path(
    output_dir,
    "phase9_coverage_sensitivity.csv"
  )
)

fwrite(
  overall_results,
  file.path(
    output_dir,
    "phase9_broader_sample_metrics.csv"
  )
)

fwrite(
  valid[, .(
    date, lat, lon,
    fishing_hours, chl_available,
    predicted, absolute_error
  )],
  file.path(
    output_dir,
    "phase9_predictions.csv"
  )
)

cat("\nSUCCESS: Phase 9 completed.\n")


# PHASE 9B: COVERAGE AND ERROR DIAGNOSTICS

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

pred <- fread(file.path(
  output_dir,
  "phase9_predictions.csv"
))

pred[, date := as.Date(date)]
pred[, month := as.integer(format(date, "%m"))]

stopifnot(all(c(
  "fishing_hours",
  "chl_available",
  "predicted",
  "absolute_error"
) %in% names(pred)))

# 1. Monthly coverage and prediction errors
monthly <- pred[, .(
  observations = .N,
  mean_actual = mean(fishing_hours),
  MAE = mean(absolute_error)
), by = .(month, chl_available)]

setorder(monthly, month, chl_available)

cat("\nMONTHLY COVERAGE AND ERROR\n")
print(monthly)

# 2. Stratify observations by actual effort
# Descriptive diagnostic only:
# actual fishing effort is NOT used as a predictor.

pred[, effort_group := cut(
  fishing_hours,
  breaks = c(-Inf, 0, 1, 10, 50, Inf),
  labels = c(
    "Zero",
    "Above 0 to 1",
    "Above 1 to 10",
    "Above 10 to 50",
    "Above 50"
  ),
  right = TRUE
)]

effort_check <- pred[, .(
  observations = .N,
  mean_actual = mean(fishing_hours),
  MAE = mean(absolute_error),
  RMSE = sqrt(mean(
    (fishing_hours - predicted)^2
  ))
), by = .(effort_group, chl_available)]

setorder(effort_check, effort_group, chl_available)

cat("\nFISHING INTENSITY AND ERROR\n")
print(effort_check)

# 3. Compare groups within the same month
# Only months with both coverage groups are comparable

monthly_wide <- dcast(
  monthly,
  month ~ chl_available,
  value.var = c("observations", "MAE")
)

cat("\nMONTHLY SIDE-BY-SIDE COMPARISON\n")
print(monthly_wide)

# 4. Save reports
fwrite(
  monthly,
  file.path(output_dir,
            "phase9b_monthly_coverage_errors.csv")
)

fwrite(
  effort_check,
  file.path(output_dir,
            "phase9b_effort_group_errors.csv")
)

fwrite(
  monthly_wide,
  file.path(output_dir,
            "phase9b_monthly_comparison.csv")
)

cat("\nSUCCESS: Phase 9B completed.\n")


# PHASE 10: JOINT COVERAGE-COMPOSITION AUDIT

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop", "blue economy",
  "Blue_Economy_R_Results"
)

pred <- fread(file.path(
  output_dir, "phase9_predictions.csv"
))

pred[, date := as.Date(date)]
pred[, month := as.integer(format(date, "%m"))]

pred[, effort_group := cut(
  fishing_hours,
  breaks = c(-Inf, 0, 1, 10, 50, Inf),
  labels = c(
    "Zero", "0-1", "1-10", "10-50", "Above 50"
  )
)]

# Check every month x effort x coverage combination
joint <- pred[, .(
  observations = .N,
  mean_actual = mean(fishing_hours),
  MAE = mean(absolute_error)
), by = .(
  month, effort_group, chl_available
)]

# Put available and unavailable groups side by side
wide <- dcast(
  joint,
  month + effort_group ~ chl_available,
  value.var = c("observations", "MAE")
)

# Keep strata with both coverage groups
paired <- wide[
  !is.na(observations_FALSE) &
    !is.na(observations_TRUE)
]

# Flag sparse comparisons
paired[, adequate_count :=
         observations_FALSE >= 10 &
         observations_TRUE >= 10
]

# Positive gap = larger error when chlorophyll missing
paired[, MAE_gap :=
         MAE_FALSE - MAE_TRUE
]

cat("\nJOINT STRATA AUDIT\n")
print(paired)

cat("\nSTRATA SUMMARY\n")
strata_summary <- paired[, .(
  matched_strata = .N,
  strata_with_10_each = sum(adequate_count),
  higher_error_when_missing =
    sum(MAE_gap > 0),
  lower_error_when_missing =
    sum(MAE_gap < 0)
)]

print(strata_summary)

# Save reports
fwrite(
  paired,
  file.path(
    output_dir,
    "phase10_joint_strata.csv"
  )
)

fwrite(
  strata_summary,
  file.path(
    output_dir,
    "phase10_strata_summary.csv"
  )
)

cat("\nSUCCESS: Phase 10 completed.\n")


# PHASE 11: RESEARCH OUTPUT INVENTORY

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

required_files <- c(
  "ghana_full_grid_month_panel.csv",
  "ghana_model_comparison_sample.csv",
  "ghana_model_sample_design.csv",
  "seasonal_vs_linear_benchmarks.csv",
  "phase6_model_metrics_2023.csv",
  "phase6_validation_predictions.csv",
  "phase7_bootstrap_robustness.csv",
  "phase7b_sensitivity_summary.csv",
  "phase8_spatial_metrics.csv",
  "phase8b_repeated_spatial_cv.csv",
  "phase8b_spatial_cv_summary.csv",
  "phase9_coverage_sensitivity.csv",
  "phase9_broader_sample_metrics.csv",
  "phase9b_monthly_coverage_errors.csv",
  "phase9b_effort_group_errors.csv",
  "phase10_joint_strata.csv",
  "phase10_strata_summary.csv"
)

inventory <- data.table(
  filename = required_files
)

inventory[, full_path :=
            file.path(output_dir, filename)
]

inventory[, exists := file.exists(full_path)]

inventory[, size_kb := round(
  file.info(full_path)$size / 1024,
  2
)]

cat("\nRESEARCH FILE INVENTORY\n")
print(inventory[, .(
  filename, exists, size_kb
)])

cat("\nMissing files:",
    sum(!inventory$exists), "\n")

fwrite(
  inventory[, .(
    filename, exists, size_kb
  )],
  file.path(
    output_dir,
    "research_output_inventory.csv"
  )
)

if (all(inventory$exists)) {
  cat("\nSUCCESS: All listed outputs found.\n")
} else {
  cat("\nWARNING: Some outputs are missing.\n")
}


# PHASE 12: SCIENTIFIC DATA INTEGRITY AUDIT
# Read-only checks; saves reports only
# No missing data are filled or fabricated

library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

# 1. Read the actual generated datasets
full <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

gfw <- fread(file.path(
  output_dir,
  "ghana_coastal_fishing_grid_monthly.csv"
))

nasa <- fread(file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
))

# 2. Check required columns
stopifnot(all(c(
  "date", "lat", "lon", "cell_id",
  "fishing_hours", "presence_hours",
  "gfw_record_present",
  "chlor_a_mg_m3",
  "fishing_lag1", "fishing_lag12",
  "chlorophyll_lag1"
) %in% names(full)))

stopifnot(all(c(
  "date", "lat", "lon",
  "fishing_hours", "presence_hours"
) %in% names(gfw)))

stopifnot(all(c(
  "date", "lat", "lon",
  "chlor_a_mg_m3"
) %in% names(nasa)))

full[, date := as.Date(date)]
gfw[, date := as.Date(date)]
nasa[, date := as.Date(date)]

# Handle logical column explicitly
if (is.character(full$gfw_record_present)) {
  full[, gfw_record_present :=
         as.logical(gfw_record_present)
  ]
}

stopifnot(
  !anyNA(full$date),
  !anyNA(full$cell_id),
  !anyNA(full$gfw_record_present)
)

# 3. Check unique geographic and temporal keys
full_duplicates <- full[
  , .N, by = .(date, lat, lon)
][N > 1]

gfw_duplicates <- gfw[
  , .N, by = .(date, lat, lon)
][N > 1]

nasa_conflicts <- nasa[
  , .(
    nonmissing_values = uniqueN(
      chlor_a_mg_m3[!is.na(chlor_a_mg_m3)]
    )
  ),
  by = .(date, lat, lon)
][nonmissing_values > 1]

cat("\nKEY INTEGRITY\n")

cat("Full panel duplicate keys:",
    nrow(full_duplicates), "\n")

cat("GFW duplicate keys:",
    nrow(gfw_duplicates), "\n")

cat("NASA conflicting chlorophyll keys:",
    nrow(nasa_conflicts), "\n")

# 4. Verify expected monthly calendar
months <- seq(
  as.Date("2018-01-01"),
  as.Date("2024-12-01"),
  by = "month"
)

cells <- uniqueN(full$cell_id)
expected_rows <- cells * length(months)

cell_calendar <- full[, .(
  months_observed = uniqueN(date),
  rows = .N
), by = cell_id]

calendar_problems <- cell_calendar[
  months_observed != 84 | rows != 84
]

cat("\nCALENDAR INTEGRITY\n")
cat("Unique cells:", cells, "\n")
cat("Unique months:", uniqueN(full$date), "\n")
cat("Expected rows:", expected_rows, "\n")
cat("Actual rows:", nrow(full), "\n")
cat("Cells with incomplete calendar:",
    nrow(calendar_problems), "\n")

# 5. Distinguish missing records from zeros
coverage <- full[, .(
  grid_months = .N,
  
  gfw_present = sum(gfw_record_present),
  
  gfw_absent = sum(!gfw_record_present),
  
  recorded_zero_hours = sum(
    gfw_record_present &
      !is.na(fishing_hours) &
      fishing_hours == 0
  ),
  
  observed_positive_hours = sum(
    gfw_record_present &
      !is.na(fishing_hours) &
      fishing_hours > 0
  ),
  
  present_but_missing_hours = sum(
    gfw_record_present &
      is.na(fishing_hours)
  ),
  
  absent_with_nonmissing_hours = sum(
    !gfw_record_present &
      !is.na(fishing_hours)
  ),
  
  chlorophyll_available = sum(
    !is.na(chlor_a_mg_m3)
  )
), by = year]

setorder(coverage, year)

cat("\nANNUAL GFW AND NASA COVERAGE\n")
print(coverage)

# 6. Verify that GFW values match source aggregation
gfw_reference <- gfw[, .(
  date, lat, lon,
  source_fishing = fishing_hours,
  source_presence = presence_hours
)]

gfw_check <- merge(
  full[, .(
    date, lat, lon,
    gfw_record_present,
    fishing_hours,
    presence_hours
  )],
  gfw_reference,
  by = c("date", "lat", "lon"),
  all.x = TRUE
)

gfw_check[, fishing_mismatch :=
            gfw_record_present &
            (
              xor(is.na(fishing_hours),
                  is.na(source_fishing)) |
                (
                  !is.na(fishing_hours) &
                    !is.na(source_fishing) &
                    abs(fishing_hours -
                          source_fishing) > 1e-6
                )
            )
]

gfw_check[, presence_mismatch :=
            gfw_record_present &
            (
              xor(is.na(presence_hours),
                  is.na(source_presence)) |
                (
                  !is.na(presence_hours) &
                    !is.na(source_presence) &
                    abs(presence_hours -
                          source_presence) > 1e-6
                )
            )
]

# 7. Verify calendar-based lag calculations
setorder(full, cell_id, date)

full[, lag1_expected :=
       data.table::shift(fishing_hours, 1L),
     by = cell_id
]

full[, lag12_expected :=
       data.table::shift(fishing_hours, 12L),
     by = cell_id
]

full[, chl_lag_expected :=
       data.table::shift(chlor_a_mg_m3, 1L),
     by = cell_id
]

same_numeric <- function(a, b) {
  both_missing <- is.na(a) & is.na(b)
  both_equal <- !is.na(a) & !is.na(b) &
    abs(a - b) <= 1e-6
  
  both_missing | both_equal
}

lag_audit <- data.table(
  check = c(
    "Fishing lag 1",
    "Fishing lag 12",
    "Chlorophyll lag 1"
  ),
  
  mismatched_rows = c(
    sum(!same_numeric(
      full$fishing_lag1,
      full$lag1_expected
    )),
    sum(!same_numeric(
      full$fishing_lag12,
      full$lag12_expected
    )),
    sum(!same_numeric(
      full$chlorophyll_lag1,
      full$chl_lag_expected
    ))
  )
)

cat("\nLAG INTEGRITY\n")
print(lag_audit)

# 8. Create the audit overview
audit_summary <- data.table(
  check = c(
    "Full panel duplicate keys",
    "GFW duplicate keys",
    "NASA conflicting chlorophyll keys",
    "Incomplete geographic calendars",
    "GFW fishing value mismatches",
    "GFW presence value mismatches",
    "Calendar lag mismatches"
  ),
  
  issues = c(
    nrow(full_duplicates),
    nrow(gfw_duplicates),
    nrow(nasa_conflicts),
    nrow(calendar_problems),
    sum(gfw_check$fishing_mismatch),
    sum(gfw_check$presence_mismatch),
    sum(lag_audit$mismatched_rows)
  )
)

cat("\nPHASE 12 AUDIT SUMMARY\n")
print(audit_summary)

# 9. Save audit reports
fwrite(
  coverage,
  file.path(output_dir,
            "phase12_annual_coverage.csv")
)

fwrite(
  lag_audit,
  file.path(output_dir,
            "phase12_lag_integrity.csv")
)

fwrite(
  audit_summary,
  file.path(output_dir,
            "phase12_audit_summary.csv")
)

cat("\nSUCCESS: Phase 12 audit completed.\n")


# PHASE 13: SATELLITE SOURCE COVERAGE AUDIT
# Read-only, based on existing processed CSV files

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

full <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

nasa <- fread(file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
))

full[, date := as.Date(date)]
nasa[, date := as.Date(date)]

# A. Calendar and available processed NASA months
calendar <- data.table(
  date = seq(
    as.Date("2018-01-01"),
    as.Date("2024-12-01"),
    by = "month"
  )
)

nasa_months <- nasa[, .(
  nasa_matched_rows = .N,
  chlorophyll_nonmissing = sum(
    !is.na(chlor_a_mg_m3)
  )
), by = date]

month_audit <- merge(
  calendar, nasa_months,
  by = "date", all.x = TRUE
)

month_audit[, processed_nasa_month_present :=
              !is.na(nasa_matched_rows)
]

month_audit[
  is.na(nasa_matched_rows),
  `:=`(
    nasa_matched_rows = 0L,
    chlorophyll_nonmissing = 0L
  )
]

cat("\nPROCESSED NASA MONTHS\n")
print(month_audit[, .(
  months_in_calendar = .N,
  months_with_processed_data =
    sum(processed_nasa_month_present),
  months_without_processed_data =
    sum(!processed_nasa_month_present)
)])

cat("\nMONTHS WITH NO PROCESSED NASA DATA\n")
print(month_audit[
  processed_nasa_month_present == FALSE,
  .(date)
])

# B. Are NASA-matched coordinate keys in GFW panel?
full_keys <- unique(full[, .(date, lat, lon)])

nasa_keys <- unique(
  nasa[, .(date, lat, lon)]
)

unmatched <- fsetdiff(nasa_keys, full_keys)

cat("\nCOORDINATE-MATCH AUDIT\n")
cat("Unique NASA matched keys:",
    nrow(nasa_keys), "\n")

cat("NASA keys absent from full grid:",
    nrow(unmatched), "\n")

# C. Check chlorophyll ranges in processed data
chlor_stats <- nasa[
  !is.na(chlor_a_mg_m3),
  .(
    observations = .N,
    minimum = min(chlor_a_mg_m3),
    median = median(chlor_a_mg_m3),
    maximum = max(chlor_a_mg_m3),
    negative_values = sum(chlor_a_mg_m3 < 0),
    nonfinite_values = sum(
      !is.finite(chlor_a_mg_m3)
    )
  )
]

cat("\nCHLOROPHYLL DATA QUALITY\n")
print(chlor_stats)

# D. Compare chlorophyll availability by year
full[, year := as.integer(format(date, "%Y"))]

annual_nasa <- full[, .(
  grid_months = .N,
  chl_observed = sum(!is.na(chlor_a_mg_m3)),
  coverage_pct = round(
    100 * mean(!is.na(chlor_a_mg_m3)),
    2
  )
), by = year]

setorder(annual_nasa, year)

cat("\nANNUAL CHLOROPHYLL AVAILABILITY\n")
print(annual_nasa)

# E. Save reports
fwrite(
  month_audit,
  file.path(output_dir,
            "phase13_nasa_month_audit.csv")
)

fwrite(
  annual_nasa,
  file.path(output_dir,
            "phase13_nasa_annual_coverage.csv")
)

fwrite(
  chlor_stats,
  file.path(output_dir,
            "phase13_chlorophyll_quality.csv")
)

fwrite(
  unmatched,
  file.path(output_dir,
            "phase13_unmatched_coordinates.csv")
)

cat("\nSUCCESS: Phase 13 completed.\n")



# PHASE 14A: SOURCE PROCESSING INSPECTION

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

# 1. Locate the actual processing script
scripts <- list.files(
  project_dir,
  pattern = "\\.[Rr]$",
  full.names = TRUE,
  recursive = TRUE
)

cat("\nR SCRIPTS FOUND\n")
print(scripts)

# 2. Inspect instructions related to NASA extraction
if (length(scripts) > 0) {
  
  for (script in scripts) {
    
    lines <- readLines(
      script,
      warn = FALSE
    )
    
    hits <- grep(
      "chlor|nasa|terra::|rast\\(|extract\\(|resample|project\\(|shift\\(|netcdf|\\.nc",
      lines,
      ignore.case = TRUE
    )
    
    if (length(hits) > 0) {
      cat("\nSCRIPT:", script, "\n")
      
      # Print nearby lines for context
      indices <- sort(unique(
        unlist(lapply(hits, function(i) {
          seq(
            max(1, i - 2),
            min(length(lines), i + 3)
          )
        }))
      ))
      
      cat(paste(
        sprintf(
          "%4d: %s",
          indices,
          lines[indices]
        ),
        collapse = "\n"
      ), "\n")
    }
  }
}

# 3. Locate extracted NetCDF files
nc_files <- list.files(
  output_dir,
  pattern = "\\.nc$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
)

cat("\nNETCDF FILES FOUND:", length(nc_files), "\n")

if (length(nc_files) > 0) {
  print(head(basename(nc_files), 10))
  
  # Inspect one real NetCDF file
  if (requireNamespace("terra", quietly = TRUE)) {
    
    example_file <- nc_files[1]
    
    cat("\nEXAMPLE NETCDF FILE\n")
    cat(example_file, "\n")
    
    r <- terra::rast(example_file)
    
    print(r)
    
    cat("\nCOORDINATE REFERENCE SYSTEM\n")
    print(terra::crs(r))
    
    cat("\nRASTER EXTENT\n")
    print(terra::ext(r))
    
    cat("\nRASTER RESOLUTION\n")
    print(terra::res(r))
    
    cat("\nRASTER LAYER NAMES\n")
    print(names(r))
  }
} else {
  cat(
    "No extracted .nc files found in output_dir.\n",
    "We may need to inspect the original NASA TAR archive.\n"
  )
}

cat("\nSUCCESS: Source inspection completed.\n")



# PHASE 14B - CORRECTED
# NASA raster and extraction validation

library(data.table)
library(terra)

set.seed(2026)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

nasa_dir <- file.path(output_dir, "nasa_extracted")

nc_files <- sort(list.files(
  nasa_dir,
  pattern = "\\.nc$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
))

matched <- fread(file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
))

matched[, date := as.Date(date)]

cat("NetCDF files found:", length(nc_files), "\n")

stopifnot(length(nc_files) == 80L)

# Start with a fresh results list
results <- vector("list", length(nc_files))

for (i in seq_along(nc_files)) {
  
  filename <- basename(nc_files[i])
  
  date_text <- regmatches(
    filename,
    regexpr("20[0-9]{6}", filename)
  )
  
  if (length(date_text) != 1 ||
      !nzchar(date_text)) {
    stop("Invalid filename: ", filename)
  }
  
  file_date <- as.Date(
    substr(date_text, 1, 8),
    format = "%Y%m%d"
  )
  
  if (is.na(file_date)) {
    stop("Invalid date: ", filename)
  }
  
  # Open the original chlorophyll layer
  r <- tryCatch(
    terra::rast(nc_files[i], subds = "chlor_a"),
    error = function(e) terra::rast(nc_files[i])
  )
  
  stopifnot(terra::nlyr(r) == 1L)
  
  # Match using an explicitly named date variable
  d <- matched[matched$date == file_date]
  
  n_sample <- min(10L, nrow(d))
  mismatches <- 0L
  
  if (n_sample > 0L) {
    
    sample_rows <- d[
      sample.int(nrow(d), n_sample)
    ]
    
    points <- terra::vect(
      as.data.frame(
        sample_rows[, .(lon, lat)]
      ),
      geom = c("lon", "lat"),
      crs = "EPSG:4326"
    )
    
    extracted <- as.numeric(
      terra::extract(
        r, points, ID = FALSE
      )[[1]]
    )
    
    extracted[
      !is.finite(extracted) |
        extracted < 0
    ] <- NA_real_
    
    saved <- sample_rows$chlor_a_mg_m3
    
    equal <- (
      is.na(extracted) & is.na(saved)
    ) | (
      !is.na(extracted) &
        !is.na(saved) &
        abs(extracted - saved) <= 1e-5
    )
    
    mismatches <- sum(!equal)
  }
  
  results[[i]] <- data.table(
    date = file_date,
    file = filename,
    rows = terra::nrow(r),
    cols = terra::ncol(r),
    resolution_x = terra::res(r)[1],
    resolution_y = terra::res(r)[2],
    xmin = terra::xmin(r),
    xmax = terra::xmax(r),
    ymin = terra::ymin(r),
    ymax = terra::ymax(r),
    crs_defined = nzchar(terra::crs(r)),
    crs_lonlat = terra::is.lonlat(r),
    sample_checked = n_sample,
    sample_mismatches = mismatches
  )
  
  cat("Checked", i, "of", length(nc_files), "\n")
}

# Build audit table only after the loop completes
raster_audit <- rbindlist(results)

stopifnot(
  nrow(raster_audit) == length(nc_files),
  !anyDuplicated(raster_audit$date)
)

setorder(raster_audit, date)

summary14 <- raster_audit[, .(
  raster_files = .N,
  unique_months = uniqueN(date),
  all_crs_defined = all(crs_defined),
  all_lonlat = all(crs_lonlat),
  unique_resolutions = uniqueN(
    paste(resolution_x, resolution_y)
  ),
  sampled_grid_points = sum(sample_checked),
  extraction_mismatches = sum(sample_mismatches)
)]

cat("\nPHASE 14B SUMMARY\n")
print(summary14)

geometry14 <- raster_audit[, .(
  minimum_rows = min(rows),
  maximum_rows = max(rows),
  minimum_cols = min(cols),
  maximum_cols = max(cols),
  xmin_range = paste(range(round(xmin, 5)),
                     collapse = " to "),
  xmax_range = paste(range(round(xmax, 5)),
                     collapse = " to "),
  ymin_range = paste(range(round(ymin, 5)),
                     collapse = " to "),
  ymax_range = paste(range(round(ymax, 5)),
                     collapse = " to ")
)]

cat("\nRASTER GEOMETRY RANGES\n")
print(geometry14)

# Replace the empty audit file with verified results
fwrite(
  raster_audit,
  file.path(
    output_dir,
    "phase14b_raster_audit.csv"
  )
)

fwrite(
  summary14,
  file.path(
    output_dir,
    "phase14b_audit_summary.csv"
  )
)

cat("\nSUCCESS: Phase 14B completed.\n")


script_path <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "run_blue_economy_from_downloads.R"
)

lines <- readLines(script_path, warn = FALSE)

cat("\nGFW EXTRACTION AND GEOGRAPHIC FILTERING\n")

selected <- 50:min(94, length(lines))

cat(
  paste(
    sprintf(
      "%3d: %s",
      selected,
      lines[selected]
    ),
    collapse = "\n"
  ),
  "\n"
)


# PHASE 15B - GFW SOURCE AND SPATIAL AUDIT

library(data.table)
library(sf)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

quality <- fread(file.path(
  output_dir,
  "gfw_month_file_quality.csv"
))

quality[, date := as.Date(date)]

cat("\nGFW MONTHLY FILE QUALITY\n")

print(quality[, .(
  source_files = .N,
  unique_dates = uniqueN(date),
  total_source_rows = sum(rows),
  missing_fishing_hours = sum(missing_hours),
  negative_fishing_hours = sum(negative_hours)
)])

cat("\nFILES PER MONTH\n")

month_counts <- quality[, .N, by = date]
setorder(month_counts, date)

print(month_counts[N != 1])

cat("\nGFW FILE DATE RANGE\n")
print(range(quality$date))

# Examine saved EEZ boundary files
boundary_dir <- file.path(output_dir, "boundary")

boundary_files <- list.files(
  boundary_dir,
  recursive = TRUE,
  full.names = TRUE
)

cat("\nBOUNDARY FILES\n")
print(basename(boundary_files))

# Locate spatial files suitable for sf
spatial_files <- boundary_files[
  grepl("\\.(gpkg|shp)$",
        boundary_files,
        ignore.case = TRUE)
]

if (length(spatial_files) > 0) {
  
  cat("\nBOUNDARY LAYER INFORMATION\n")
  
  print(sf::st_layers(spatial_files[1]))
  
  boundary <- sf::st_read(
    spatial_files[1],
    quiet = TRUE
  )
  
  cat("\nBOUNDARY CRS\n")
  print(sf::st_crs(boundary))
  
  cat("\nBOUNDARY GEOMETRY TYPES\n")
  print(table(sf::st_geometry_type(boundary)))
  
  cat("\nBOUNDARY VALIDITY\n")
  print(table(sf::st_is_valid(boundary)))
  
} else {
  
  cat(
    "\nNo GPKG/SHP file found inside boundary directory.\n"
  )
}

cat("\nSUCCESS: Phase 15B inspection completed.\n")



library(sf)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

# Search the entire project directory
boundary_files <- list.files(
  project_dir,
  pattern = "eez_v12_lowres\\.gpkg$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
)

cat("\nEEZ FILES FOUND\n")
print(boundary_files)

cat("\nNumber found:", length(boundary_files), "\n")

stopifnot(length(boundary_files) >= 1L)

# Use the existing file
boundary_path <- boundary_files[1]

cat("\nUSING THIS FILE:\n")
print(boundary_path)

# Load it
eez <- sf::st_read(
  boundary_path,
  quiet = TRUE
)

cat("\nSUCCESS: EEZ file loaded.\n")
cat("Features:", nrow(eez), "\n")
print(names(eez))


# PHASE 15C - CORRECTED GHANA EEZ AUDIT

library(sf)

# Identify the MRGID column
id_candidates <- names(eez)[
  tolower(names(eez)) == "mrgid"
]

if (length(id_candidates) != 1L) {
  stop(
    "MRGID column not found uniquely. ",
    "Check names(eez)."
  )
}

id_col <- id_candidates[1]

# Select Ghana by MRGID
ghana <- eez[
  !is.na(eez[[id_col]]) &
    as.character(eez[[id_col]]) == "8400",
]

cat("\nGHANA EEZ RECORDS\n")
print(nrow(ghana))

stopifnot(nrow(ghana) == 1L)

cat("\nGHANA GEOMETRY VALIDITY\n")
print(st_is_valid(ghana))

cat("\nGHANA GEOMETRY REASON\n")
print(st_is_valid(ghana, reason = TRUE))

cat("\nGHANA COORDINATE SYSTEM\n")
print(st_crs(ghana)$input)

cat("\nGHANA BOUNDING BOX\n")
print(st_bbox(ghana))

# Investigate invalid world geometries
invalid <- eez[
  !st_is_valid(eez),
]

cat("\nINVALID WORLD EEZ FEATURES\n")

print(
  st_drop_geometry(invalid)[
    , id_col, drop = FALSE
  ]
)

cat("\nINVALIDITY REASONS\n")
print(st_is_valid(invalid, reason = TRUE))

cat("\nSUCCESS: Ghana boundary audit completed.\n")


library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

# Illustrate the predictors for the 2023 period
forecast_audit <- panel[
  year == 2023 &
    !is.na(fishing_hours) &
    !is.na(fishing_lag1) &
    !is.na(fishing_lag12),
  .(
    forecast_month = date,
    preceding_month = seq(
      as.Date("2022-12-01"),
      as.Date("2023-11-01"),
      by = "month"
    )[match(date, sort(unique(
      panel[year == 2023]$date
    )))],
    observations = .N,
    historical_lag1_available =
      sum(!is.na(fishing_lag1)),
    historical_lag12_available =
      sum(!is.na(fishing_lag12)),
    chlorophyll_lag1_available =
      sum(!is.na(chlorophyll_lag1))
  ),
  by = date
]

print(forecast_audit)

cat("\nSUCCESS: Forecast timing audit completed.\n")


# PHASE 17A
# Fixed longitude-band validation protocol
# No model fitting or performance testing

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

df[, date := as.Date(date)]

stopifnot(all(c(
  "date", "lat", "lon", "period",
  "fishing_hours", "fishing_lag1",
  "fishing_lag12", "chlorophyll_lag1"
) %in% names(df)))

# Confirm matched data are complete
stopifnot(
  !anyNA(df[, .(
    fishing_hours,
    fishing_lag1,
    fishing_lag12,
    chlorophyll_lag1
  )])
)

# Fixed settings — do not adjust after viewing errors
n_folds <- 4L
buffer_degrees <- 0.20

# Construct longitudinal bands independently of outcomes
unique_lon <- sort(unique(df$lon))

lon_lookup <- data.table(
  lon = unique_lon,
  band = pmin(
    n_folds,
    1L + floor(
      (seq_along(unique_lon) - 1L) *
        n_folds / length(unique_lon)
    )
  )
)

df <- merge(
  df,
  lon_lookup,
  by = "lon",
  all.x = TRUE
)

stopifnot(!anyNA(df$band))

# Record one row per geographic cell
cell_folds <- unique(
  df[, .(lat, lon, band)]
)

# Create training and validation memberships
fold_memberships <- list()
fold_summary <- list()

for (k in seq_len(n_folds)) {
  
  # Geographic locations reserved for validation
  held_lons <- lon_lookup[
    band == k, lon
  ]
  
  west <- min(held_lons)
  east <- max(held_lons)
  
  # Training cells must be outside the held-out
  # band AND its longitude buffer
  train <- df[
    period == "Training" &
      (
        lon < west - buffer_degrees |
          lon > east + buffer_degrees
      )
  ]
  
  valid <- df[
    period == "Validation" &
      band == k
  ]
  
  # Geographic cell-key overlap is forbidden
  train_cells <- unique(
    train[, .(lat, lon)]
  )
  
  valid_cells <- unique(
    valid[, .(lat, lon)]
  )
  
  overlap <- merge(
    train_cells,
    valid_cells,
    by = c("lat", "lon")
  )
  
  stopifnot(nrow(overlap) == 0)
  
  # Check chronology
  if (nrow(train) > 0 && nrow(valid) > 0) {
    stopifnot(
      max(train$date) < min(valid$date)
    )
  }
  
  # Save exact membership keys
  train_keys <- train[, .(
    fold = k,
    role = "training",
    date, lat, lon
  )]
  
  valid_keys <- valid[, .(
    fold = k,
    role = "validation",
    date, lat, lon
  )]
  
  fold_memberships[[k]] <- rbindlist(
    list(train_keys, valid_keys)
  )
  
  fold_summary[[k]] <- data.table(
    fold = k,
    west_lon = west,
    east_lon = east,
    buffer_degrees = buffer_degrees,
    training_n = nrow(train),
    validation_n = nrow(valid),
    training_cells = nrow(train_cells),
    validation_cells = nrow(valid_cells),
    validation_months = uniqueN(valid$date),
    shared_cells = nrow(overlap)
  )
}

fold_design <- rbindlist(fold_summary)

membership <- rbindlist(fold_memberships)

setorder(fold_design, fold)
setorder(membership, fold, role, date, lat, lon)

cat("\nPHASE 17A GEOGRAPHIC DESIGN\n")
print(fold_design)

cat("\nDESIGN CHECKS\n")

cat(
  "Total fold validation records:",
  fold_design[, sum(validation_n)],
  "\n"
)

cat(
  "Original 2023 matched records:",
  df[period == "Validation", .N],
  "\n"
)

cat(
  "Cells shared within folds:",
  sum(fold_design$shared_cells),
  "\n"
)

cat(
  "Folds with no training records:",
  sum(fold_design$training_n == 0),
  "\n"
)

cat(
  "Folds with no validation records:",
  sum(fold_design$validation_n == 0),
  "\n"
)

# Save exact geographic membership
fwrite(
  cell_folds,
  file.path(
    output_dir,
    "phase17a_geographic_cell_bands.csv"
  )
)

fwrite(
  fold_design,
  file.path(
    output_dir,
    "phase17a_fold_design.csv"
  )
)

fwrite(
  membership,
  file.path(
    output_dir,
    "phase17a_fold_memberships.csv"
  )
)

cat("\nSUCCESS: Phase 17A design saved.\n")


# PHASE 17B: FIXED GEOGRAPHIC VALIDATION
# Ghana Blue Economy research
# Do not use 2024 for model selection

library(data.table)
library(ranger)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# 1. Load existing data and frozen fold assignments
df <- fread(file.path(
  output_dir,
  "ghana_model_comparison_sample.csv"
))

membership <- fread(file.path(
  output_dir,
  "phase17a_fold_memberships.csv"
))

fold_design <- fread(file.path(
  output_dir,
  "phase17a_fold_design.csv"
))

df[, date := as.Date(date)]
membership[, date := as.Date(date)]

stopifnot(
  nrow(fold_design) == 4L,
  !anyDuplicated(df, by = c("date", "lat", "lon")),
  !anyDuplicated(
    membership,
    by = c("fold", "role", "date", "lat", "lon")
  )
)

# 2. Construct the same predictor definitions
df[, lag1_log := log1p(fishing_lag1)]
df[, lag12_log := log1p(fishing_lag12)]
df[, chl_log := log1p(chlorophyll_lag1)]

df[, month_sin := sin(2 * pi * month / 12)]
df[, month_cos := cos(2 * pi * month / 12)]
df[, target_log := log1p(fishing_hours)]

hist_vars <- c(
  "lag1_log",
  "lag12_log",
  "month_sin",
  "month_cos"
)

env_vars <- c(hist_vars, "chl_log")

stopifnot(
  all(is.finite(as.matrix(
    df[, c(hist_vars, "chl_log",
           "target_log"), with = FALSE]
  )))
)

# 3. Join saved memberships to model data
fold_data <- merge(
  membership,
  df,
  by = c("date", "lat", "lon"),
  all.x = TRUE,
  sort = FALSE
)

stopifnot(
  nrow(fold_data) == nrow(membership),
  !anyNA(fold_data$target_log)
)

# 4. Evaluation helper
score_predictions <- function(actual, predicted) {
  
  stopifnot(
    length(actual) == length(predicted),
    all(is.finite(predicted))
  )
  
  data.table(
    n = length(actual),
    MAE = mean(abs(actual - predicted)),
    RMSE = sqrt(mean(
      (actual - predicted)^2
    )),
    WAPE = if (sum(actual) > 0) {
      100 * sum(abs(actual - predicted)) /
        sum(actual)
    } else {
      NA_real_
    }
  )
}

metrics_list <- list()
predictions_list <- list()

# 5. Train and evaluate each frozen fold
for (k in sort(unique(fold_design$fold))) {
  
  train <- copy(fold_data[
    fold == k & role == "training"
  ])
  
  valid <- copy(fold_data[
    fold == k & role == "validation"
  ])
  
  stopifnot(
    nrow(train) == fold_design[
      fold == k, training_n
    ],
    nrow(valid) == fold_design[
      fold == k, validation_n
    ],
    max(train$date) < min(valid$date)
  )
  
  # Identical training observations for both models
  fit_rf <- function(features) {
    
    ranger(
      target_log ~ .,
      data = as.data.frame(
        train[, c("target_log", features),
              with = FALSE]
      ),
      num.trees = 500,
      mtry = 2,
      min.node.size = 10,
      seed = 2026,
      num.threads = 2
    )
  }
  
  model_h <- fit_rf(hist_vars)
  model_e <- fit_rf(env_vars)
  
  # Convert fitted log predictions to hours
  valid[, historical := pmax(
    0,
    expm1(
      predict(
        model_h,
        data = as.data.frame(
          valid[, ..hist_vars]
        )
      )$predictions
    )
  )]
  
  valid[, environmental := pmax(
    0,
    expm1(
      predict(
        model_e,
        data = as.data.frame(
          valid[, ..env_vars]
        )
      )$predictions
    )
  )]
  
  valid[, seasonal := fishing_lag12]
  
  # Paired evaluation on identical observations
  fold_metrics <- rbindlist(lapply(
    c("seasonal", "historical",
      "environmental"),
    function(model_name) {
      
      cbind(
        data.table(
          fold = k,
          model = model_name
        ),
        score_predictions(
          valid$fishing_hours,
          valid[[model_name]]
        )
      )
    }
  ))
  
  metrics_list[[k]] <- fold_metrics
  
  predictions_list[[k]] <- valid[, .(
    fold = k,
    date, lat, lon,
    fishing_hours,
    seasonal,
    historical,
    environmental
  )]
  
  cat("Completed fold", k, "of 4\n")
}

# 6. Combine results
fold_metrics <- rbindlist(metrics_list)
predictions <- rbindlist(predictions_list)

stopifnot(
  nrow(predictions) == 5000L,
  !anyDuplicated(
    predictions,
    by = c("date", "lat", "lon")
  )
)

cat("\nPHASE 17B FOLD RESULTS\n")
print(fold_metrics)

# 7. Overall metrics:
# Pool predictions so every grid-month has equal weight
pooled_metrics <- rbindlist(lapply(
  c("seasonal", "historical",
    "environmental"),
  function(model_name) {
    
    cbind(
      data.table(model = model_name),
      score_predictions(
        predictions$fishing_hours,
        predictions[[model_name]]
      )
    )
  }
))

cat("\nPOOLED GEOGRAPHIC VALIDATION\n")
print(pooled_metrics)

# 8. Paired chlorophyll improvement
fold_gain <- dcast(
  fold_metrics,
  fold ~ model,
  value.var = "MAE"
)

fold_gain[, chlorophyll_gain :=
            historical - environmental
]

cat("\nENVIRONMENTAL IMPROVEMENT BY FOLD\n")
print(fold_gain[, .(
  fold,
  historical,
  environmental,
  chlorophyll_gain
)])

cat("\nOVERALL MAE IMPROVEMENT\n")
print(
  pooled_metrics[
    model == "historical", MAE
  ] -
    pooled_metrics[
      model == "environmental", MAE
    ]
)

# 9. Save final exploratory evaluation outputs
fwrite(
  fold_metrics,
  file.path(
    output_dir,
    "phase17b_fold_metrics.csv"
  )
)

fwrite(
  pooled_metrics,
  file.path(
    output_dir,
    "phase17b_pooled_metrics.csv"
  )
)

fwrite(
  fold_gain,
  file.path(
    output_dir,
    "phase17b_fold_gain.csv"
  )
)

fwrite(
  predictions,
  file.path(
    output_dir,
    "phase17b_geographic_predictions.csv"
  )
)

cat("\nSUCCESS: Phase 17B completed.\n")


# PHASE 18A: JOURNAL FIGURES
# Uses only saved empirical outputs

library(data.table)
library(ggplot2)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

figure_dir <- file.path(
  output_dir,
  "Manuscript_Figures"
)

dir.create(
  figure_dir,
  showWarnings = FALSE,
  recursive = TRUE
)

# Read verified outputs
temporal <- fread(file.path(
  output_dir,
  "phase6_model_metrics_2023.csv"
))

geographic <- fread(file.path(
  output_dir,
  "phase17b_pooled_metrics.csv"
))

folds <- fread(file.path(
  output_dir,
  "phase17b_fold_gain.csv"
))

coverage <- fread(file.path(
  output_dir,
  "phase9_coverage_sensitivity.csv"
))

# Ensure expected columns exist
stopifnot(
  all(c("model", "MAE") %in% names(temporal)),
  all(c("model", "MAE") %in% names(geographic)),
  all(c("fold", "chlorophyll_gain") %in% names(folds)),
  all(c("chl_available", "historical_MAE")
      %in% names(coverage))
)

# FIGURE 1: Temporal vs geographic performance
figure1_data <- rbindlist(list(
  temporal[
    model %in% c(
      "rf_historical",
      "rf_environmental"
    ),
    .(
      evaluation = "Temporal validation",
      model = fifelse(
        model == "rf_historical",
        "Historical RF",
        "RF + chlorophyll"
      ),
      MAE
    )
  ],
  geographic[
    model %in% c(
      "historical",
      "environmental"
    ),
    .(
      evaluation = "Geographic validation",
      model = fifelse(
        model == "historical",
        "Historical RF",
        "RF + chlorophyll"
      ),
      MAE
    )
  ]
))

stopifnot(nrow(figure1_data) == 4L)

figure1_data[
  , model := factor(
    model,
    levels = c(
      "Historical RF",
      "RF + chlorophyll"
    )
  )
]

p1 <- ggplot(
  figure1_data,
  aes(x = evaluation, y = MAE, fill = model)
) +
  geom_col(
    position = position_dodge(width = 0.7),
    width = 0.62
  ) +
  geom_text(
    aes(label = sprintf("%.3f", MAE)),
    position = position_dodge(width = 0.7),
    vjust = -0.4,
    size = 3.5
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.13))
  ) +
  labs(
    title = "Environmental predictors across evaluation designs",
    x = NULL,
    y = "Mean absolute error (fishing hours)",
    fill = "Model"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom"
  )

# FIGURE 2: Geographic performance differences
folds[, band := factor(
  fold,
  levels = 1:4,
  labels = c(
    "Western",
    "West-central",
    "East-central",
    "Eastern"
  )
)]

p2 <- ggplot(
  folds,
  aes(
    x = band,
    y = chlorophyll_gain
  )
) +
  geom_col(
    fill = "#317F79",
    width = 0.65
  ) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "Chlorophyll contribution by geographic band",
    subtitle = "Positive values favor the environmental model",
    x = "Geographic validation band",
    y = "Historical MAE - environmental MAE"
  ) +
  theme_minimal(base_size = 12)

# FIGURE 3: Data availability and prediction error
coverage[, availability := fifelse(
  chl_available,
  "Chlorophyll available",
  "Chlorophyll unavailable"
)]

p3 <- ggplot(
  coverage,
  aes(
    x = availability,
    y = historical_MAE
  )
) +
  geom_col(
    fill = "#477E93",
    width = 0.55
  ) +
  geom_text(
    aes(
      label = sprintf(
        "MAE %.2f\nn = %s",
        historical_MAE,
        format(observations, big.mark = ",")
      )
    ),
    vjust = -0.35,
    size = 3.6
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.22))
  ) +
  labs(
    title = "Prediction error and chlorophyll availability",
    subtitle = "Historical-only RF; 2023 broader eligible sample",
    x = NULL,
    y = "Mean absolute error (fishing hours)"
  ) +
  theme_minimal(base_size = 12)

# Save raster and vector copies
plots <- list(
  Figure_1_Temporal_vs_Geographic = p1,
  Figure_2_Geographic_Bands = p2,
  Figure_3_Coverage_and_Error = p3
)

for (name in names(plots)) {
  ggsave(
    file.path(figure_dir, paste0(name, ".png")),
    plot = plots[[name]],
    width = 8,
    height = 5,
    dpi = 300,
    bg = "white"
  )
  
  ggsave(
    file.path(figure_dir, paste0(name, ".pdf")),
    plot = plots[[name]],
    width = 8,
    height = 5
  )
}

cat("\nFIGURES CREATED\n")
print(list.files(
  figure_dir,
  full.names = FALSE
))

cat("\nSUCCESS: Phase 18A completed.\n")


# PHASE 18B: REPRODUCIBILITY MANIFEST

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Save installed R environment details
writeLines(
  capture.output(sessionInfo()),
  file.path(
    output_dir,
    "R_session_info.txt"
  )
)

# Create a manifest of existing research outputs
research_files <- list.files(
  output_dir,
  pattern = "\\.(csv|rds)$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
)

manifest <- data.table(
  relative_path = substring(
    normalizePath(
      research_files,
      winslash = "/"
    ),
    nchar(normalizePath(
      output_dir,
      winslash = "/"
    )) + 2L
  ),
  bytes = file.info(research_files)$size,
  md5 = unname(tools::md5sum(research_files))
)

setorder(manifest, relative_path)

# Store the manifest outside the included file list
fwrite(
  manifest,
  file.path(
    output_dir,
    "phase18_reproducibility_manifest.csv"
  )
)

cat("\nFILES IN MANIFEST:", nrow(manifest), "\n")
cat("MISSING CHECKSUMS:",
    sum(is.na(manifest$md5)), "\n")

cat("\nSUCCESS: Reproducibility manifest saved.\n")


# PHASE 19A: OBSERVATION-QUALITY FRAMEWORK
# Ghana Blue Economy research
# Uses the verified 99,204-row spatial calendar
# Does not replace missing values or fit models

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

needed <- c(
  "date", "lat", "lon", "cell_id",
  "gfw_record_present",
  "fishing_hours",
  "fishing_lag1",
  "fishing_lag12",
  "chlorophyll_lag1"
)

stopifnot(all(needed %in% names(panel)))
stopifnot(nrow(panel) == 99204L)
stopifnot(!anyDuplicated(
  panel,
  by = c("date", "lat", "lon")
))

# Annual and monthly identifiers
panel[, year := as.integer(format(date, "%Y"))]
panel[, month := as.integer(format(date, "%m"))]

# Original outcome observation
panel[, target_observed :=
        gfw_record_present == TRUE &
        !is.na(fishing_hours)
]

# Historical features are available
panel[, history_available :=
        !is.na(fishing_lag1) &
        !is.na(fishing_lag12)
]

# Environmental feature is available
panel[, environment_available :=
        !is.na(chlorophyll_lag1)
]

# Mutually exclusive observation-status groups
# Priority is outcome, then history, then environment

panel[, observation_status := fcase(
  !target_observed,
  "01_No_observed_target",
  
  target_observed & !history_available,
  "02_Target_observed_history_missing",
  
  target_observed &
    history_available &
    !environment_available,
  "03_Historical_eligible_chlorophyll_missing",
  
  target_observed &
    history_available &
    environment_available,
  "04_Fully_eligible",
  
  default = "CHECK_UNCLASSIFIED"
)]

stopifnot(
  !anyNA(panel$observation_status),
  !any(panel$observation_status ==
         "CHECK_UNCLASSIFIED")
)

# Overall classification
overall <- panel[, .(
  observations = .N
), by = observation_status]

overall[, pct_full_calendar :=
          round(
            100 * observations / nrow(panel),
            2
          )
]

setorder(overall, observation_status)

cat("\nOVERALL OBSERVATION STATUS\n")
print(overall)

# Annual classification
annual <- panel[, .(
  observations = .N
), by = .(year, observation_status)]

annual[, annual_total :=
         panel[year == .BY$year, .N],
       by = year
]

annual[, pct_annual_calendar :=
         round(100 * observations / annual_total, 2)
]

setorder(annual, year, observation_status)

cat("\n2023 OBSERVATION STATUS\n")
print(annual[year == 2023])

cat("\n2024 OBSERVATION STATUS\n")
print(annual[year == 2024])

# Separate missing-feature mechanisms
feature_audit <- panel[
  target_observed == TRUE,
  .(
    target_records = .N,
    
    lag1_missing =
      sum(is.na(fishing_lag1)),
    
    lag12_missing =
      sum(is.na(fishing_lag12)),
    
    either_historical_missing =
      sum(!history_available),
    
    chlorophyll_missing =
      sum(!environment_available),
    
    history_complete =
      sum(history_available),
    
    fully_eligible =
      sum(history_available &
            environment_available)
  ),
  by = year
]

setorder(feature_audit, year)

cat("\nFEATURE AVAILABILITY BY YEAR\n")
print(feature_audit)

# Monthly data-quality audit for 2023
monthly_2023 <- panel[year == 2023, .(
  grid_months = .N,
  target_observed = sum(target_observed),
  historical_eligible =
    sum(target_observed & history_available),
  fully_eligible =
    sum(target_observed &
          history_available &
          environment_available)
), by = date]

setorder(monthly_2023, date)

cat("\n2023 MONTHLY ELIGIBILITY\n")
print(monthly_2023)

# Save all reports
fwrite(
  overall,
  file.path(
    output_dir,
    "phase19_overall_observation_status.csv"
  )
)

fwrite(
  annual,
  file.path(
    output_dir,
    "phase19_annual_observation_status.csv"
  )
)

fwrite(
  feature_audit,
  file.path(
    output_dir,
    "phase19_feature_availability.csv"
  )
)

fwrite(
  monthly_2023,
  file.path(
    output_dir,
    "phase19_monthly_2023_eligibility.csv"
  )
)

cat("\nSUCCESS: Phase 19A completed.\n")


# PHASE 19B: PREDICTOR COVERAGE AUDIT
# No model fitting or imputation

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]
panel[, year := as.integer(format(date, "%Y"))]

# Target known only for retrospective evaluation
panel[, target_known := !is.na(fishing_hours)]

# Readiness determined from predictors only
panel[, hist_ready :=
        is.finite(fishing_lag1) &
        is.finite(fishing_lag12)
]

panel[, env_ready :=
        hist_ready &
        is.finite(chlorophyll_lag1)
]

# A coverage-aware strategy falls back to historical
# when chlorophyll is absent.
# Therefore its predictor coverage equals hist_ready.

coverage19b <- panel[, .(
  calendar_rows = .N,
  
  known_targets = sum(target_known),
  
  hist_predictable = sum(hist_ready),
  
  env_predictable = sum(env_ready),
  
  hist_evaluable = sum(
    hist_ready & target_known
  ),
  
  env_evaluable = sum(
    env_ready & target_known
  ),
  
  hist_predictable_target_unknown = sum(
    hist_ready & !target_known
  ),
  
  env_predictable_target_unknown = sum(
    env_ready & !target_known
  )
), by = year]

coverage19b[, `:=`(
  hist_predictable_pct =
    round(100 * hist_predictable / calendar_rows, 2),
  
  env_predictable_pct =
    round(100 * env_predictable / calendar_rows, 2)
)]

setorder(coverage19b, year)

cat("\nPREDICTOR READINESS BY YEAR\n")
print(coverage19b)

# Focus on the established validation years
cat("\n2023 AND 2024 READINESS\n")
print(coverage19b[year %in% c(2023, 2024)])

# Confirm retrospective outcome eligibility
stopifnot(
  coverage19b[year == 2023, hist_evaluable] == 6139L,
  coverage19b[year == 2023, env_evaluable] == 5000L,
  coverage19b[year == 2024, hist_evaluable] == 4631L,
  coverage19b[year == 2024, env_evaluable] == 2862L
)

fwrite(
  coverage19b,
  file.path(
    output_dir,
    "phase19b_predictor_readiness.csv"
  )
)

cat("\nSUCCESS: Phase 19B completed.\n")



# PHASE 20: COVERAGE-AWARE HYBRID
# Retrospective exploratory evaluation, 2023
# Fixed model specifications; no 2024 testing

library(data.table)
library(ranger)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

# Predictors, not target values, define readiness
panel[, hist_ready :=
        is.finite(fishing_lag1) &
        is.finite(fishing_lag12)
]

panel[, env_ready :=
        hist_ready &
        is.finite(chlorophyll_lag1)
]

# Historical-ready universe
df <- copy(panel[hist_ready == TRUE])

stopifnot(
  all(df$fishing_lag1 >= 0),
  all(df$fishing_lag12 >= 0)
)

# Model features
df[, lag1_log := log1p(fishing_lag1)]
df[, lag12_log := log1p(fishing_lag12)]
df[, month_sin := sin(2 * pi * month / 12)]
df[, month_cos := cos(2 * pi * month / 12)]
df[, target_log := log1p(fishing_hours)]

df[, chl_log := fifelse(
  env_ready,
  log1p(chlorophyll_lag1),
  NA_real_
)]

hist_vars <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

env_vars <- c(hist_vars, "chl_log")

# Train only on records with known outcomes
train_h <- df[
  date < as.Date("2023-01-01") &
    !is.na(fishing_hours)
]

train_e <- train_h[env_ready == TRUE]

# Evaluate only on known outcomes
valid <- copy(df[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01") &
    !is.na(fishing_hours)
])

stopifnot(
  nrow(train_h) == 27926L,
  nrow(train_e) == 21605L,
  nrow(valid) == 6139L,
  sum(valid$env_ready) == 5000L
)

# Fit two pre-specified models
fit_rf <- function(data, features) {
  ranger(
    target_log ~ .,
    data = as.data.frame(
      data[, c("target_log", features),
           with = FALSE]
    ),
    num.trees = 500,
    mtry = 2,
    min.node.size = 10,
    seed = 2026,
    num.threads = 2
  )
}

model_h <- fit_rf(train_h, hist_vars)
model_e <- fit_rf(train_e, env_vars)

# Historical prediction for every eligible row
valid[, historical := pmax(
  0,
  expm1(predict(
    model_h,
    data = as.data.frame(
      valid[, ..hist_vars]
    )
  )$predictions)
)]

# Hybrid starts with historical predictions
valid[, hybrid := historical]

# Replace with environmental predictions only
# where lagged chlorophyll exists
env_rows <- which(valid$env_ready)

valid[env_rows, hybrid := pmax(
  0,
  expm1(predict(
    model_e,
    data = as.data.frame(
      valid[env_rows, ..env_vars]
    )
  )$predictions)
)]

# Pairwise evaluation
evaluate <- function(d, model_name) {
  actual <- d$fishing_hours
  estimated <- d[[model_name]]
  
  data.table(
    model = model_name,
    n = length(actual),
    MAE = mean(abs(actual - estimated)),
    RMSE = sqrt(mean(
      (actual - estimated)^2
    )),
    WAPE = if (sum(actual) > 0) {
      100 * sum(abs(actual - estimated)) /
        sum(actual)
    } else NA_real_
  )
}

overall20 <- rbindlist(list(
  evaluate(valid, "historical"),
  evaluate(valid, "hybrid")
))

cat("\n2023 BROADER-SAMPLE MODEL COMPARISON\n")
print(overall20)

# Evaluate separately by environmental availability
coverage20 <- rbindlist(lapply(
  c(FALSE, TRUE),
  function(available) {
    d <- valid[env_ready == available]
    
    ans <- rbindlist(list(
      evaluate(d, "historical"),
      evaluate(d, "hybrid")
    ))
    
    ans[, chlorophyll_available := available]
    ans
  }
))

cat("\nCOVERAGE-GROUP MODEL COMPARISON\n")
print(coverage20)

# Check that fallback is exact
stopifnot(all(
  valid[env_ready == FALSE, historical] ==
    valid[env_ready == FALSE, hybrid]
))

# Paired improvement, positive favors hybrid
valid[, gain :=
        abs(fishing_hours - historical) -
        abs(fishing_hours - hybrid)
]

cat("\nOVERALL MAE GAIN\n")
print(mean(valid$gain))

# Save all outputs
fwrite(
  overall20,
  file.path(output_dir,
            "phase20_hybrid_overall.csv")
)

fwrite(
  coverage20,
  file.path(output_dir,
            "phase20_hybrid_by_coverage.csv")
)

fwrite(
  valid[, .(
    date, lat, lon, fishing_hours,
    env_ready, historical, hybrid, gain
  )],
  file.path(output_dir,
            "phase20_hybrid_predictions.csv")
)

cat("\nSUCCESS: Phase 20 completed.\n")


# PHASE 21A: CONTROLLED TRAINING-SAMPLE COMPARISON
# Retrospective exploratory analysis, 2023

library(data.table)
library(ranger)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, month := as.integer(format(date, "%m"))]

df[, hist_ready :=
     is.finite(fishing_lag1) &
     is.finite(fishing_lag12)
]

df[, env_ready :=
     hist_ready &
     is.finite(chlorophyll_lag1)
]

df <- df[hist_ready == TRUE]

df[, `:=`(
  lag1_log = log1p(fishing_lag1),
  lag12_log = log1p(fishing_lag12),
  month_sin = sin(2 * pi * month / 12),
  month_cos = cos(2 * pi * month / 12),
  chl_log = log1p(chlorophyll_lag1),
  target_log = log1p(fishing_hours)
)]

hist_features <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

env_features <- c(hist_features, "chl_log")

train_all <- df[
  date < as.Date("2023-01-01") &
    is.finite(fishing_hours)
]

train_cc <- train_all[env_ready == TRUE]

test_cc <- df[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01") &
    env_ready == TRUE &
    is.finite(fishing_hours)
]

stopifnot(
  nrow(train_all) == 27926L,
  nrow(train_cc) == 21605L,
  nrow(test_cc) == 5000L
)

train_rf <- function(d, features) {
  ranger(
    target_log ~ .,
    data = as.data.frame(
      d[, c("target_log", features),
        with = FALSE]
    ),
    num.trees = 500,
    mtry = 2,
    min.node.size = 10,
    seed = 2026,
    num.threads = 2
  )
}

models <- list(
  Historical_CC = train_rf(
    train_cc, hist_features
  ),
  Environmental_CC = train_rf(
    train_cc, env_features
  ),
  Historical_Expanded = train_rf(
    train_all, hist_features
  )
)

predict_hours <- function(model, d, features) {
  raw <- predict(
    model,
    data = as.data.frame(d[, ..features])
  )$predictions
  
  pmax(0, expm1(raw))
}

test_cc[, Historical_CC := predict_hours(
  models$Historical_CC,
  test_cc,
  hist_features
)]

test_cc[, Environmental_CC := predict_hours(
  models$Environmental_CC,
  test_cc,
  env_features
)]

test_cc[, Historical_Expanded := predict_hours(
  models$Historical_Expanded,
  test_cc,
  hist_features
)]

metrics <- function(pred, label) {
  y <- test_cc$fishing_hours
  p <- test_cc[[pred]]
  
  data.table(
    model = label,
    n = length(y),
    MAE = mean(abs(y - p)),
    RMSE = sqrt(mean((y - p)^2)),
    WAPE = 100 * sum(abs(y - p)) / sum(y)
  )
}

results21 <- rbindlist(list(
  metrics("Historical_CC", "Historical_CC"),
  metrics("Environmental_CC", "Environmental_CC"),
  metrics("Historical_Expanded",
          "Historical_Expanded")
))

cat("\nCONTROLLED MODEL COMPARISON\n")
print(results21)

# Positive gain indicates lower MAE
# for the second model in the comparison.

comparison21 <- data.table(
  comparison = c(
    "Environmental_CC vs Historical_CC",
    "Historical_Expanded vs Historical_CC",
    "Environmental_CC vs Historical_Expanded"
  ),
  mean_MAE_gain = c(
    mean(abs(test_cc$fishing_hours -
               test_cc$Historical_CC) -
           abs(test_cc$fishing_hours -
                 test_cc$Environmental_CC)),
    
    mean(abs(test_cc$fishing_hours -
               test_cc$Historical_CC) -
           abs(test_cc$fishing_hours -
                 test_cc$Historical_Expanded)),
    
    mean(abs(test_cc$fishing_hours -
               test_cc$Historical_Expanded) -
           abs(test_cc$fishing_hours -
                 test_cc$Environmental_CC))
  )
)

cat("\nPAIRED MAE COMPARISONS\n")
print(comparison21)

fwrite(
  results21,
  file.path(output_dir,
            "phase21_controlled_model_results.csv")
)

fwrite(
  comparison21,
  file.path(output_dir,
            "phase21_paired_MAE_comparisons.csv")
)

fwrite(
  test_cc[, .(
    date, lat, lon, fishing_hours,
    Historical_CC, Environmental_CC,
    Historical_Expanded
  )],
  file.path(output_dir,
            "phase21_predictions.csv")
)

cat("\nSUCCESS: Phase 21A completed.\n")



# PHASE 21B: TRAINING-SAMPLE SENSITIVITY
# Exploratory repeated experiments, 2023
# No 2024 outcome evaluation

library(data.table)
library(ranger)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, month := as.integer(format(date, "%m"))]

df[, hist_ready :=
     is.finite(fishing_lag1) &
     is.finite(fishing_lag12)
]

df[, env_ready :=
     hist_ready &
     is.finite(chlorophyll_lag1)
]

df <- df[hist_ready == TRUE]

df[, `:=`(
  lag1_log = log1p(fishing_lag1),
  lag12_log = log1p(fishing_lag12),
  month_sin = sin(2 * pi * month / 12),
  month_cos = cos(2 * pi * month / 12),
  target_log = log1p(fishing_hours)
)]

features <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

train_all <- df[
  date < as.Date("2023-01-01") &
    is.finite(fishing_hours)
]

train_cc <- train_all[env_ready == TRUE]
train_missing <- train_all[env_ready == FALSE]

test <- df[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01") &
    env_ready == TRUE &
    is.finite(fishing_hours)
]

stopifnot(
  nrow(train_all) == 27926L,
  nrow(train_cc) == 21605L,
  nrow(train_missing) == 6321L,
  nrow(test) == 5000L
)

fit_and_score <- function(train_data, seed) {
  
  model_data <- as.data.frame(
    train_data[, c("target_log", features),
               with = FALSE]
  )
  
  fit <- ranger(
    target_log ~ .,
    data = model_data,
    num.trees = 300,
    mtry = 2,
    min.node.size = 10,
    seed = seed,
    num.threads = 2
  )
  
  pred_log <- predict(
    fit,
    data = as.data.frame(
      test[, ..features]
    )
  )$predictions
  
  pred <- pmax(0, expm1(pred_log))
  actual <- test$fishing_hours
  
  data.table(
    MAE = mean(abs(actual - pred)),
    RMSE = sqrt(mean((actual - pred)^2)),
    WAPE = 100 * sum(abs(actual - pred)) /
      sum(actual)
  )
}

reps <- 12L

# Reference complete-case model, one fixed fit
reference <- fit_and_score(train_cc, 2026L)
reference[, `:=`(
  experiment = "Complete_case_reference",
  repetition = 0L
)]

# Expanded-training reference
expanded <- fit_and_score(train_all, 2026L)
expanded[, `:=`(
  experiment = "Expanded_reference",
  repetition = 0L
)]

results <- list(reference, expanded)

set.seed(202621)

for (r in seq_len(reps)) {
  
  # A: Same training size, sampled from entire pool
  index_a <- sample(
    seq_len(nrow(train_all)),
    nrow(train_cc),
    replace = FALSE
  )
  
  sample_a <- train_all[index_a]
  
  score_a <- fit_and_score(
    sample_a,
    3000L + r
  )
  
  score_a[, `:=`(
    experiment = "Size_matched_all_pool",
    repetition = r
  )]
  
  # B: Replace exactly 6,321 complete-case
  # records with chlorophyll-missing records.
  retained_cc <- train_cc[
    sample(
      seq_len(nrow(train_cc)),
      nrow(train_cc) - nrow(train_missing),
      replace = FALSE
    )
  ]
  
  sample_b <- rbindlist(
    list(retained_cc, train_missing),
    use.names = TRUE
  )
  
  stopifnot(
    nrow(sample_a) == nrow(train_cc),
    nrow(sample_b) == nrow(train_cc)
  )
  
  score_b <- fit_and_score(
    sample_b,
    4000L + r
  )
  
  score_b[, `:=`(
    experiment = "Composition_replacement",
    repetition = r
  )]
  
  results[[length(results) + 1L]] <- score_a
  results[[length(results) + 1L]] <- score_b
  
  cat("Completed repetition", r, "of", reps, "\n")
}

results21b <- rbindlist(
  results,
  fill = TRUE
)

summary21b <- results21b[, .(
  runs = .N,
  mean_MAE = mean(MAE),
  min_MAE = min(MAE),
  max_MAE = max(MAE),
  mean_RMSE = mean(RMSE),
  mean_WAPE = mean(WAPE)
), by = experiment]

setorder(summary21b, experiment)

cat("\nPHASE 21B SUMMARY\n")
print(summary21b)

cat("\nPHASE 21B ALL RUNS\n")
print(results21b)

fwrite(
  results21b,
  file.path(
    output_dir,
    "phase21b_all_runs.csv"
  )
)

fwrite(
  summary21b,
  file.path(
    output_dir,
    "phase21b_summary.csv"
  )
)

cat("\nSUCCESS: Phase 21B completed.\n")



# PHASE 21C: TRAINING-SAMPLE COMPOSITION AUDIT
# Descriptive analysis only; no models fitted

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, year := as.integer(format(date, "%Y"))]
df[, month := as.integer(format(date, "%m"))]

# Replicate the Phase 21 training population
train <- df[
  date < as.Date("2023-01-01") &
    is.finite(fishing_hours) &
    is.finite(fishing_lag1) &
    is.finite(fishing_lag12)
]

train[, chlorophyll_available :=
        is.finite(chlorophyll_lag1)
]

stopifnot(
  nrow(train) == 27926L,
  sum(train$chlorophyll_available) == 21605L,
  sum(!train$chlorophyll_available) == 6321L
)

# Descriptive outcome categories
# These are for retrospective diagnostics only.
train[, high_effort_50 :=
        fishing_hours > 50
]

# 1. Summary of training-record composition
composition <- train[, .(
  n = .N,
  unique_cells = uniqueN(cell_id),
  mean_effort = mean(fishing_hours),
  median_effort = median(fishing_hours),
  pct_zero_effort =
    100 * mean(fishing_hours == 0),
  pct_above_50 =
    100 * mean(high_effort_50),
  mean_latitude = mean(lat),
  mean_longitude = mean(lon)
), by = chlorophyll_available]

cat("\nTRAINING COMPOSITION SUMMARY\n")
print(composition)

# 2. Month-by-month availability
monthly <- train[, .N,
                 by = .(month, chlorophyll_available)
]

monthly_wide <- dcast(
  monthly,
  month ~ chlorophyll_available,
  value.var = "N",
  fill = 0
)

setnames(
  monthly_wide,
  c("FALSE", "TRUE"),
  c("chlorophyll_missing", "chlorophyll_available")
)

monthly_wide[, total :=
               chlorophyll_missing + chlorophyll_available
]

monthly_wide[, missing_pct :=
               round(100 * chlorophyll_missing / total, 2)
]

cat("\nMONTHLY TRAINING COMPOSITION\n")
print(monthly_wide)

# 3. Year-by-year availability
yearly <- train[, .(
  n = .N,
  mean_effort = mean(fishing_hours),
  median_effort = median(fishing_hours)
), by = .(year, chlorophyll_available)]

setorder(yearly, year, chlorophyll_available)

cat("\nYEARLY TRAINING COMPOSITION\n")
print(yearly)

# 4. Geographical distribution by half-degree bin
train[, lon_band := floor(lon * 2) / 2]
train[, lat_band := floor(lat * 2) / 2]

spatial <- train[, .N,
                 by = .(
                   lon_band, lat_band,
                   chlorophyll_available
                 )
]

spatial_wide <- dcast(
  spatial,
  lon_band + lat_band ~ chlorophyll_available,
  value.var = "N",
  fill = 0
)

setnames(
  spatial_wide,
  c("FALSE", "TRUE"),
  c("chlorophyll_missing", "chlorophyll_available")
)

spatial_wide[, total :=
               chlorophyll_missing + chlorophyll_available
]

spatial_wide[, missing_pct :=
               100 * chlorophyll_missing / total
]

setorder(spatial_wide, lon_band, lat_band)

cat("\nGEOGRAPHIC TRAINING COMPOSITION\n")
print(spatial_wide)

# Save all tables
fwrite(
  composition,
  file.path(output_dir,
            "phase21c_training_composition.csv")
)

fwrite(
  monthly_wide,
  file.path(output_dir,
            "phase21c_monthly_composition.csv")
)

fwrite(
  yearly,
  file.path(output_dir,
            "phase21c_yearly_composition.csv")
)

fwrite(
  spatial_wide,
  file.path(output_dir,
            "phase21c_spatial_composition.csv")
)

cat("\nSUCCESS: Phase 21C completed.\n")


# PHASE 21D: MONTHLY MODEL PERFORMANCE
# Reuses existing Phase 21A predictions
# No model retraining

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

pred <- fread(file.path(
  output_dir,
  "phase21_predictions.csv"
))

pred[, date := as.Date(date)]
pred[, month := as.integer(format(date, "%m"))]

needed <- c(
  "fishing_hours",
  "Historical_CC",
  "Environmental_CC",
  "Historical_Expanded"
)

stopifnot(
  all(needed %in% names(pred)),
  nrow(pred) == 5000L,
  all(format(pred$date, "%Y") == "2023"),
  all(vapply(pred[, ..needed], function(x) {
    all(is.finite(x))
  }, logical(1)))
)

# Monthly errors calculated on identical observations
monthly_results <- pred[, .(
  n = .N,
  
  MAE_Historical_CC =
    mean(abs(fishing_hours - Historical_CC)),
  
  MAE_Environmental_CC =
    mean(abs(fishing_hours - Environmental_CC)),
  
  MAE_Historical_Expanded =
    mean(abs(fishing_hours - Historical_Expanded)),
  
  mean_actual_effort = mean(fishing_hours)
), by = month]

# Positive = environmental model has lower MAE
monthly_results[, env_gain_same_training :=
                  MAE_Historical_CC - MAE_Environmental_CC
]

# Positive = expanded historical model has lower MAE
monthly_results[, expanded_gain :=
                  MAE_Historical_CC - MAE_Historical_Expanded
]

setorder(monthly_results, month)

cat("\n2023 MONTHLY MODEL COMPARISON\n")
print(monthly_results)

# Identify observed month-specific validation sample
monthly_coverage <- pred[, .N, by = month]
setnames(monthly_coverage, "N", "validation_n")

monthly_coverage[, validation_pct :=
                   round(100 * validation_n / 5000, 2)
]

cat("\n2023 VALIDATION MONTH DISTRIBUTION\n")
print(monthly_coverage[order(month)])

# Confirm recomposed overall paired gains
stopifnot(
  abs(
    weighted.mean(
      monthly_results$env_gain_same_training,
      monthly_results$n
    ) - 0.04130955
  ) < 1e-5,
  
  abs(
    weighted.mean(
      monthly_results$expanded_gain,
      monthly_results$n
    ) - 0.17213247
  ) < 1e-5
)

fwrite(
  monthly_results,
  file.path(
    output_dir,
    "phase21d_monthly_model_comparison.csv"
  )
)

fwrite(
  monthly_coverage,
  file.path(
    output_dir,
    "phase21d_validation_month_distribution.csv"
  )
)

cat("\nSUCCESS: Phase 21D completed.\n")


# PHASE 21E: SEASONAL COVERAGE AND MODEL ACCURACY
# Uses existing Phase 20 predictions
# No model retraining

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

panel <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

pred <- fread(file.path(
  output_dir,
  "phase20_hybrid_predictions.csv"
))

panel[, date := as.Date(date)]
pred[, date := as.Date(date)]

panel[, year := as.integer(format(date, "%Y"))]
panel[, month := as.integer(format(date, "%m"))]
pred[, month := as.integer(format(date, "%m"))]

stopifnot(
  nrow(pred) == 6139L,
  all(format(pred$date, "%Y") == "2023"),
  all(c("env_ready", "historical",
        "hybrid", "fishing_hours") %in% names(pred))
)

# Predictor availability and observed outcomes
p23 <- panel[year == 2023]

p23[, hist_ready :=
      is.finite(fishing_lag1) &
      is.finite(fishing_lag12)
]

p23[, env_ready :=
      hist_ready &
      is.finite(chlorophyll_lag1)
]

p23[, target_known :=
      is.finite(fishing_hours)
]

coverage <- p23[, .(
  calendar_n = .N,
  observed_targets = sum(target_known),
  history_ready = sum(hist_ready),
  environment_ready = sum(env_ready),
  history_evaluable =
    sum(hist_ready & target_known),
  environment_evaluable =
    sum(env_ready & target_known)
), by = month]

coverage[, environment_share_of_history :=
           100 * environment_evaluable /
           pmax(1, history_evaluable)
]

# Same 6,139 observations for both methods
pred[, `:=`(
  error_historical =
    abs(fishing_hours - historical),
  error_hybrid =
    abs(fishing_hours - hybrid)
)]

monthly_errors <- pred[, .(
  evaluated_n = .N,
  historical_MAE = mean(error_historical),
  hybrid_MAE = mean(error_hybrid),
  hybrid_gain =
    mean(error_historical - error_hybrid),
  chlorophyll_available_n = sum(env_ready)
), by = month]

results <- merge(
  coverage,
  monthly_errors,
  by = "month",
  all = TRUE
)

setorder(results, month)

stopifnot(
  sum(results$evaluated_n) == 6139L,
  sum(results$environment_evaluable) == 5000L,
  abs(
    weighted.mean(results$hybrid_gain,
                  results$evaluated_n) +
      0.1065507
  ) < 1e-5
)

cat("\nPHASE 21E MONTHLY COVERAGE AND ERRORS\n")
print(results)

# Predefined broad seasonal summaries
# These are calendar groups, not biological seasons.
pred[, period := fcase(
  month %in% 1:3, "Jan-Mar",
  month %in% 4:5, "Apr-May",
  month %in% 6:12, "Jun-Dec"
)]

period_results <- pred[, .(
  n = .N,
  env_available_n = sum(env_ready),
  historical_MAE = mean(error_historical),
  hybrid_MAE = mean(error_hybrid),
  hybrid_gain =
    mean(error_historical - error_hybrid)
), by = period]

period_results[, environmental_share :=
                 100 * env_available_n / n
]

setorder(period_results, period)

cat("\nPHASE 21E PERIOD COMPARISON\n")
print(period_results)

fwrite(
  results,
  file.path(
    output_dir,
    "phase21e_monthly_coverage_errors.csv"
  )
)

fwrite(
  period_results,
  file.path(
    output_dir,
    "phase21e_period_comparison.csv"
  )
)

cat("\nSUCCESS: Phase 21E completed.\n")



# PHASE 22A: CHLOROPHYLL MISSINGNESS PROVENANCE
# Diagnostic only. No imputation or model fitting.

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, year := as.integer(format(date, "%Y"))]

# Required chlorophyll observation comes from
# the preceding month.
df[, lag_date := as.Date(
  format(date - 1, "%Y-%m-01")
)]

# Previously verified missing NASA source months
missing_source_months <- as.Date(c(
  "2018-01-01",
  "2020-01-01",
  "2020-02-01",
  "2022-03-01"
))

study_start <- as.Date("2018-01-01")

df[, source_status := fcase(
  lag_date < study_start,
  "Outside_study_period",
  
  lag_date %in% missing_source_months,
  "Source_file_absent",
  
  default = "Source_month_in_inventory"
)]

df[, chlorophyll_ready :=
     is.finite(chlorophyll_lag1)
]

# Historical predictors available
df[, hist_ready :=
     is.finite(fishing_lag1) &
     is.finite(fishing_lag12)
]

# Observed target
df[, target_known :=
     is.finite(fishing_hours)
]

# Audit all grid-months, by source-month status
source_audit <- df[, .(
  grid_months = .N,
  chlorophyll_ready_n = sum(chlorophyll_ready),
  chlorophyll_missing_n = sum(!chlorophyll_ready)
), by = .(year, source_status)]

source_audit[, missing_pct :=
               round(
                 100 * chlorophyll_missing_n / grid_months,
                 2
               )
]

setorder(source_audit, year, source_status)

cat("\nSOURCE-STATUS AUDIT\n")
print(source_audit)

# Monthly profile among historically evaluable
# 2023 observations.
eval23 <- df[
  year == 2023 &
    hist_ready &
    target_known
]

monthly22 <- eval23[, .(
  historical_evaluable = .N,
  chlorophyll_available = sum(chlorophyll_ready),
  chlorophyll_missing = sum(!chlorophyll_ready),
  source_file_absent =
    sum(source_status == "Source_file_absent"),
  source_month_in_inventory =
    sum(source_status == "Source_month_in_inventory")
), by = .(date, lag_date)]

monthly22[, available_pct :=
            round(
              100 * chlorophyll_available /
                historical_evaluable,
              2
            )
]

setorder(monthly22, date)

stopifnot(
  nrow(eval23) == 6139L,
  sum(eval23$chlorophyll_ready) == 5000L,
  sum(!eval23$chlorophyll_ready) == 1139L
)

cat("\n2023 SOURCE AND AVAILABILITY AUDIT\n")
print(monthly22)

# Important consistency check:
# A missing source file should not generate
# valid lagged chlorophyll observations.
contradictions <- df[
  source_status %in%
    c("Outside_study_period", "Source_file_absent") &
    chlorophyll_ready
]

cat("\nCONTRADICTORY OBSERVATIONS\n")
print(nrow(contradictions))

if (nrow(contradictions) > 0L) {
  print(contradictions[
    1:min(.N, 10L),
    .(date, lat, lon, lag_date,
      chlorophyll_lag1, source_status)
  ])
  warning(
    "Source inventory and lagged values disagree. Investigate."
  )
}

fwrite(
  source_audit,
  file.path(
    output_dir,
    "phase22a_source_status_audit.csv"
  )
)

fwrite(
  monthly22,
  file.path(
    output_dir,
    "phase22a_2023_source_availability.csv"
  )
)

cat("\nPhase 22A audit completed.\n")


# PHASE 22B: TRACE LAGGED CHLOROPHYLL MISSINGNESS
# Descriptive provenance audit; no model fitting

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, year := as.integer(format(date, "%Y"))]

needed <- c(
  "cell_id", "date",
  "gfw_record_present",
  "fishing_hours",
  "fishing_lag1",
  "fishing_lag12",
  "chlor_a_mg_m3",
  "chlorophyll_lag1"
)

stopifnot(all(needed %in% names(df)))
stopifnot(!anyDuplicated(df, by = c("cell_id", "date")))

# Create previous-month lookup from original full panel
previous <- df[, .(
  cell_id,
  source_date = date,
  previous_gfw_record = gfw_record_present,
  previous_chlorophyll = chlor_a_mg_m3
)]

# Move previous-month rows forward one calendar month
previous[, date := as.Date(
  paste0(
    as.integer(format(source_date, "%Y")) +
      as.integer(format(source_date, "%m")) %/% 12,
    "-",
    sprintf(
      "%02d",
      as.integer(format(source_date, "%m")) %% 12 + 1
    ),
    "-01"
  )
)]

# Correct the month-advance calculation using a
# calendar-safe approach, including December
previous[, date := as.Date(
  format(seq(
    as.Date("2018-01-01"),
    as.Date("2025-01-01"),
    by = "month"
  )[match(
    source_date,
    seq(
      as.Date("2018-01-01"),
      as.Date("2024-12-01"),
      by = "month"
    )
  ) + 1L], "%Y-%m-%d")
)]

# Exclude unused original source date
previous[, source_date := NULL]

audit <- merge(
  df,
  previous,
  by = c("cell_id", "date"),
  all.x = TRUE,
  sort = FALSE
)

audit[, hist_ready :=
        is.finite(fishing_lag1) &
        is.finite(fishing_lag12)
]

audit[, target_known := is.finite(fishing_hours)]

audit[, lagged_chl_ready :=
        is.finite(chlorophyll_lag1)
]

# Focus on historically evaluable 2023 cases
test23 <- audit[
  year == 2023 &
    hist_ready &
    target_known
]

test23[, provenance_group := fcase(
  lagged_chl_ready,
  "01_Lagged_chlorophyll_available",
  
  !lagged_chl_ready &
    (is.na(previous_gfw_record) |
       previous_gfw_record == FALSE),
  "02_Previous_GFW_record_absent",
  
  !lagged_chl_ready &
    previous_gfw_record == TRUE &
    !is.finite(previous_chlorophyll),
  "03_Previous_GFW_present_chl_missing",
  
  !lagged_chl_ready &
    is.finite(previous_chlorophyll),
  "04_Lag_transfer_disagreement",
  
  default = "05_Investigate"
)]

result22b <- test23[, .N, by = provenance_group]

result22b[, pct_of_evaluation :=
            round(100 * N / nrow(test23), 2)
]

setorder(result22b, provenance_group)

cat("\nPHASE 22B PROVENANCE CLASSIFICATION\n")
print(result22b)

# Direct validation of previous-month lag transfer
lag_checks <- audit[
  date >= as.Date("2018-02-01") &
    is.finite(previous_chlorophyll),
  .(
    source_values_present = .N,
    lag_missing = sum(!lagged_chl_ready),
    lag_mismatch = sum(
      lagged_chl_ready &
        abs(chlorophyll_lag1 -
              previous_chlorophyll) > 1e-8,
      na.rm = TRUE
    )
  )
]

cat("\nPHASE 22B LAG CONSISTENCY\n")
print(lag_checks)

# Monthly provenance classification
monthly22b <- test23[, .N,
                     by = .(date, provenance_group)
]

setorder(monthly22b, date, provenance_group)

cat("\nPHASE 22B MONTHLY PROVENANCE\n")
print(monthly22b)

stopifnot(
  nrow(test23) == 6139L,
  sum(test23$lagged_chl_ready) == 5000L
)

fwrite(
  result22b,
  file.path(
    output_dir,
    "phase22b_provenance_classification.csv"
  )
)

fwrite(
  monthly22b,
  file.path(
    output_dir,
    "phase22b_monthly_provenance.csv"
  )
)

cat("\nPhase 22B completed.\n")


# FIND FEBRUARY 2023 NASA CHLOROPHYLL NETCDF

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

# Locations to search
search_folders <- unique(c(
  project_dir,
  file.path(Sys.getenv("USERPROFILE"), "Downloads"),
  file.path(Sys.getenv("USERPROFILE"), "Desktop"),
  file.path(Sys.getenv("OneDrive"), "Desktop"),
  file.path(Sys.getenv("USERPROFILE"), "Documents")
))

search_folders <- search_folders[
  dir.exists(search_folders)
]

# Find all NetCDF files
nc_files <- unique(unlist(lapply(
  search_folders,
  function(folder) {
    list.files(
      folder,
      pattern = "\\.(nc|nc4|cdf)$",
      recursive = TRUE,
      full.names = TRUE,
      ignore.case = TRUE
    )
  }
), use.names = FALSE))

cat("\nTOTAL NETCDF FILES FOUND:\n")
print(length(nc_files))

# February 2023 monthly MODIS Aqua chlorophyll
feb_2023 <- nc_files[
  grepl("202302|2023.?02", basename(nc_files)) &
    grepl("CHL", basename(nc_files), ignore.case = TRUE)
]

cat("\nFEBRUARY 2023 CHLOROPHYLL FILES:\n")
print(feb_2023)

# Save the file path if an unambiguous match exists
if (length(feb_2023) == 1L) {
  nc_file <- feb_2023[1]
  cat("\nFILE FOUND:\n", nc_file, "\n")
} else if (length(feb_2023) > 1L) {
  cat("\nMultiple matches. Inspect filenames before selecting.\n")
} else {
  cat("\nNo matching extracted NetCDF found.\n")
  cat("The file may still be inside the NASA TAR archive.\n")
}


# SEARCH FOR NASA TAR ARCHIVE

tar_files <- unique(unlist(lapply(
  search_folders,
  function(folder) {
    list.files(
      folder,
      pattern = "\\.(tar|tar\\.gz|tgz)$",
      recursive = TRUE,
      full.names = TRUE,
      ignore.case = TRUE
    )
  }
), use.names = FALSE))

cat("\nTAR ARCHIVES FOUND:\n")
print(tar_files)

# Prefer the previously used NASA archive
nasa_tar <- tar_files[
  grepl("requested_files", basename(tar_files),
        ignore.case = TRUE)
]

if (length(nasa_tar) > 0L) {
  
  for (archive in nasa_tar) {
    
    cat("\nCHECKING ARCHIVE:\n", archive, "\n")
    
    contents <- utils::untar(archive, list = TRUE)
    
    matches <- contents[
      grepl("202302|2023.?02", contents) &
        grepl("CHL", contents, ignore.case = TRUE)
    ]
    
    print(matches)
  }
  
} else {
  cat("\nNo requested_files TAR archive found.\n")
}


# PHASE 22C: DIRECT NASA RASTER VERIFICATION
# February 2023 chlorophyll -> March 2023 fishing effort
# Read-only: does not modify original datasets

library(data.table)
library(terra)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Exact file confirmed by your search
nc_file <- file.path(
  output_dir,
  "nasa_extracted",
  "requested_files",
  paste0(
    "AQUA_MODIS.20230201_20230228.",
    "L3m.MO.CHL.x_chlor_a.nc"
  )
)

stopifnot(file.exists(nc_file))

# Read the existing spatial panel
df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]

march <- df[
  date == as.Date("2023-03-01") &
    is.finite(fishing_hours) &
    is.finite(fishing_lag1) &
    is.finite(fishing_lag12)
]

stopifnot(
  nrow(march) == 134L,
  sum(is.finite(march$chlorophyll_lag1)) == 6L
)

# Inspect raster metadata
cat("\nNETCDF SUBDATASETS\n")
print(terra::sds(nc_file))

chl <- terra::rast(
  nc_file,
  subds = "chlor_a"
)

stopifnot(terra::nlyr(chl) == 1L)

cat("\nRASTER METADATA\n")
print(chl)

# Extract using original grid-cell center coordinates
pts <- terra::vect(
  as.data.frame(march[, .(lon, lat)]),
  geom = c("lon", "lat"),
  crs = "EPSG:4326"
)

raw <- terra::extract(
  chl,
  pts,
  method = "simple"
)

march[, raw_chlorophyll := raw[[2]]]

# Physical validity criteria
march[, raw_valid :=
        is.finite(raw_chlorophyll) &
        raw_chlorophyll >= 0
]

march[, panel_valid :=
        is.finite(chlorophyll_lag1)
]

# Classify the comparisons
march[, comparison := fcase(
  !panel_valid & !raw_valid,
  "Both_missing",
  
  !panel_valid & raw_valid,
  "Raw_valid_panel_missing",
  
  panel_valid & !raw_valid,
  "Panel_valid_raw_missing",
  
  panel_valid & raw_valid &
    abs(chlorophyll_lag1 -
          raw_chlorophyll) <= 1e-6,
  "Both_valid_agree",
  
  panel_valid & raw_valid,
  "Both_valid_disagree",
  
  default = "Investigate"
)]

audit_summary <- march[, .N, by = comparison]
setorder(audit_summary, comparison)

cat("\nPHASE 22C RAW-RASTER COMPARISON\n")
print(audit_summary)

cat("\nRAW AND PANEL AVAILABILITY\n")
print(march[, .(
  evaluation_records = .N,
  raw_valid = sum(raw_valid),
  panel_valid = sum(panel_valid),
  raw_missing = sum(!raw_valid),
  panel_missing = sum(!panel_valid)
)])

cat("\nDISAGREEMENT EXAMPLES\n")
print(march[
  comparison %in% c(
    "Raw_valid_panel_missing",
    "Panel_valid_raw_missing",
    "Both_valid_disagree"
  ),
  .(
    cell_id, lat, lon,
    chlorophyll_lag1,
    raw_chlorophyll,
    comparison
  )
][1:15])

# Save audit reports
fwrite(
  audit_summary,
  file.path(
    output_dir,
    "phase22c_raw_raster_summary.csv"
  )
)

fwrite(
  march[, .(
    date, cell_id, lat, lon,
    chlorophyll_lag1,
    raw_chlorophyll,
    comparison
  )],
  file.path(
    output_dir,
    "phase22c_raw_raster_cell_audit.csv"
  )
)

cat("\nSUCCESS: Phase 22C completed.\n")



# PHASE 22D: FULL 2023 NASA RASTER AUDIT
# Directly verify all historical-evaluable 2023 cases
# Read-only: existing panel remains unchanged

library(data.table)
library(terra)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop", "blue economy",
  "Blue_Economy_R_Results"
)

nasa_dir <- file.path(
  output_dir, "nasa_extracted", "requested_files"
)

panel <- fread(file.path(
  output_dir, "ghana_full_grid_month_panel.csv"
))

panel[, date := as.Date(date)]

test <- copy(panel[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01") &
    is.finite(fishing_hours) &
    is.finite(fishing_lag1) &
    is.finite(fishing_lag12)
])

stopifnot(
  nrow(test) == 6139L,
  sum(is.finite(test$chlorophyll_lag1)) == 5000L
)

# Previous calendar month
test[, lag_date := as.Date(
  format(date - 1L, "%Y-%m-01")
)]

test[, source_month := format(lag_date, "%Y%m")]

nc_files <- list.files(
  nasa_dir,
  pattern = "\\.nc$",
  recursive = TRUE,
  full.names = TRUE
)

stopifnot(length(nc_files) > 0L)

test[, raw_chlorophyll := NA_real_]

for (m in unique(test$source_month)) {
  
  matching <- nc_files[
    grepl(
      paste0("\\.", m, "01_"),
      basename(nc_files)
    ) &
      grepl(
        "L3m\\.MO\\.CHL",
        basename(nc_files)
      )
  ]
  
  if (length(matching) != 1L) {
    stop(
      "Expected exactly one NetCDF for ",
      m, "; found ", length(matching)
    )
  }
  
  chl <- terra::rast(
    matching[1],
    subds = "chlor_a"
  )
  
  rows <- which(test$source_month == m)
  
  pts <- terra::vect(
    as.data.frame(test[rows, .(lon, lat)]),
    geom = c("lon", "lat"),
    crs = "EPSG:4326"
  )
  
  values <- terra::extract(
    chl, pts, method = "simple"
  )[[2]]
  
  # Apply same validity criteria
  values[!is.finite(values) | values < 0] <- NA_real_
  
  set(
    test,
    i = rows,
    j = "raw_chlorophyll",
    value = values
  )
  
  cat("Verified source month:", m, "\n")
}

test[, panel_valid :=
       is.finite(chlorophyll_lag1)
]

test[, raw_valid :=
       is.finite(raw_chlorophyll)
]

test[, comparison := fcase(
  !panel_valid & !raw_valid,
  "Both_missing",
  
  panel_valid & raw_valid &
    abs(chlorophyll_lag1 -
          raw_chlorophyll) <= 1e-6,
  "Both_valid_agree",
  
  !panel_valid & raw_valid,
  "Raw_valid_panel_missing",
  
  panel_valid & !raw_valid,
  "Panel_valid_raw_missing",
  
  default = "Both_valid_disagree"
)]

overall <- test[, .N, by = comparison]
setorder(overall, comparison)

monthly <- test[, .N,
                by = .(date, comparison)
]

setorder(monthly, date, comparison)

cat("\nPHASE 22D OVERALL COMPARISON\n")
print(overall)

cat("\nPHASE 22D MONTHLY COMPARISON\n")
print(monthly)

disagreements <- test[
  !comparison %in%
    c("Both_missing", "Both_valid_agree")
]

cat("\nTOTAL DISAGREEMENTS\n")
print(nrow(disagreements))

# All source observations must be accounted for
stopifnot(sum(overall$N) == 6139L)

fwrite(
  overall,
  file.path(
    output_dir,
    "phase22d_overall_nasa_verification.csv"
  )
)

fwrite(
  monthly,
  file.path(
    output_dir,
    "phase22d_monthly_nasa_verification.csv"
  )
)

fwrite(
  disagreements,
  file.path(
    output_dir,
    "phase22d_disagreements.csv"
  )
)

cat("\nPhase 22D completed.\n")



# PHASE 23: PUBLICATION FIGURE
# Verified environmental observation coverage
# No model training or data modification

library(data.table)
library(ggplot2)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

audit <- fread(file.path(
  output_dir,
  "phase22d_monthly_nasa_verification.csv"
))

audit[, date := as.Date(date)]

# Convert verified classification to monthly counts
fig_data <- dcast(
  audit,
  date ~ comparison,
  value.var = "N",
  fill = 0
)

stopifnot(
  all(c("Both_missing", "Both_valid_agree") %in%
        names(fig_data))
)

fig_data[, `:=`(
  total = Both_missing + Both_valid_agree,
  available_pct = 100 * Both_valid_agree /
    (Both_missing + Both_valid_agree),
  month_label = factor(
    format(date, "%b"),
    levels = month.abb
  )
)]

setorder(fig_data, date)

stopifnot(
  sum(fig_data$total) == 6139L,
  sum(fig_data$Both_missing) == 1139L,
  sum(fig_data$Both_valid_agree) == 5000L
)

p <- ggplot(
  fig_data,
  aes(x = month_label, y = available_pct)
) +
  geom_col(
    fill = "#217A73",
    width = 0.72
  ) +
  geom_text(
    aes(label = sprintf("%.1f%%", available_pct)),
    vjust = -0.4,
    size = 3.2
  ) +
  scale_y_continuous(
    limits = c(0, 108),
    breaks = seq(0, 100, 20),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Availability of lagged satellite chlorophyll",
    subtitle = paste(
      "Ghanaian waters, 2023;",
      "6,139 historically evaluable grid-months"
    ),
    x = "Target month",
    y = "Valid lagged chlorophyll (%)",
    caption = paste(
      "Original Aqua MODIS NetCDF verification:",
      "5,000 valid matches; 1,139 matching gaps;",
      "zero disagreements."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(size = 10),
    axis.text.x = element_text(size = 9),
    panel.grid.major.x = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8
    )
  )

print(p)

fig_dir <- file.path(output_dir, "Manuscript_Figures")
dir.create(fig_dir, showWarnings = FALSE,
           recursive = TRUE)

ggsave(
  file.path(fig_dir,
            "Figure_4_Verified_Satellite_Coverage.png"),
  p,
  width = 9,
  height = 5.5,
  dpi = 300
)

ggsave(
  file.path(fig_dir,
            "Figure_4_Verified_Satellite_Coverage.pdf"),
  p,
  width = 9,
  height = 5.5
)

fwrite(
  fig_data,
  file.path(output_dir,
            "phase23_verified_coverage_data.csv")
)

cat("\nPHASE 23 MONTHLY VERIFIED COVERAGE\n")
print(fig_data)

cat("\nSUCCESS: Figure 4 saved.\n")






















# PHASE 22C: RAW NASA CHLOROPHYLL AUDIT
# Focus: February 2023 source -> March 2023 target
# Read-only: no changes to the existing panel

library(data.table)
library(terra)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]

# Identify March 2023 historically evaluable cells
march <- df[
  date == as.Date("2023-03-01") &
    is.finite(fishing_hours) &
    is.finite(fishing_lag1) &
    is.finite(fishing_lag12)
]

stopifnot(
  nrow(march) == 134L,
  sum(is.finite(march$chlorophyll_lag1)) == 6L
)

cat("\nSelect your ORIGINAL February 2023")
cat(" NASA chlorophyll NetCDF file.\n")

nc_file <- file.choose()

cat("\nSELECTED FILE:\n")
print(basename(nc_file))

# Discover chlorophyll subdataset
sources <- terra::sds(nc_file)

cat("\nNETCDF SUBDATASETS:\n")
print(sources)

# Read the chlor_a variable explicitly
chl <- terra::rast(nc_file, subds = "chlor_a")

stopifnot(terra::nlyr(chl) == 1L)

cat("\nRASTER INFORMATION:\n")
print(chl)
print(terra::ext(chl))
print(terra::crs(chl))

# Extract at the GFW grid-cell center coordinates
pts <- terra::vect(
  as.data.frame(march[, .(lon, lat)]),
  geom = c("lon", "lat"),
  crs = "EPSG:4326"
)

raw <- terra::extract(chl, pts)

march[, raw_chlorophyll := raw[[2]]]

march[, raw_valid :=
        is.finite(raw_chlorophyll) &
        raw_chlorophyll >= 0
]

march[, panel_valid :=
        is.finite(chlorophyll_lag1)
]

# Compare the original raster with existing lag
march[, comparison := fcase(
  !panel_valid & !raw_valid,
  "Both_missing",
  
  !panel_valid & raw_valid,
  "Raw_valid_panel_missing",
  
  panel_valid & !raw_valid,
  "Panel_valid_raw_missing",
  
  panel_valid & raw_valid &
    abs(chlorophyll_lag1 - raw_chlorophyll) < 1e-6,
  "Both_valid_agree",
  
  panel_valid & raw_valid,
  "Both_valid_disagree",
  
  default = "Investigate"
)]

audit_summary <- march[, .N, by = comparison]
setorder(audit_summary, comparison)

cat("\nPHASE 22C RAW-RASTER COMPARISON\n")
print(audit_summary)

cat("\nEXAMPLES OF DISAGREEMENTS\n")
print(
  march[
    comparison %in% c(
      "Raw_valid_panel_missing",
      "Panel_valid_raw_missing",
      "Both_valid_disagree"
    ),
    .(
      lat, lon,
      chlorophyll_lag1,
      raw_chlorophyll,
      comparison
    )
  ][1:min(.N, 15L)]
)

# Preserve diagnostics
fwrite(
  audit_summary,
  file.path(
    output_dir,
    "phase22c_raw_raster_summary.csv"
  )
)

fwrite(
  march[, .(
    date, cell_id, lat, lon,
    chlorophyll_lag1,
    raw_chlorophyll,
    comparison
  )],
  file.path(
    output_dir,
    "phase22c_raw_raster_cell_audit.csv"
  )
)

cat("\nPhase 22C completed.\n")



library(terra)

# Ghana Blue Economy project location
output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Automatically locate the February 2023 NASA file
nasa_dir <- file.path(
  output_dir,
  "nasa_extracted",
  "requested_files"
)

nc_files <- list.files(
  nasa_dir,
  pattern = "\\.nc$",
  recursive = TRUE,
  full.names = TRUE
)

# Exact February 2023 chlorophyll filename
feb_file <- nc_files[
  grepl(
    "AQUA_MODIS\\.20230201_20230228\\.L3m\\.MO\\.CHL",
    basename(nc_files)
  )
]

# Prevent accidentally loading the wrong file
stopifnot(length(feb_file) == 1L)
stopifnot(file.exists(feb_file))

# Load directly from your computer
nc_file <- feb_file[1]

chl <- terra::rast(
  nc_file,
  subds = "chlor_a"
)

# Verify correct satellite month
stopifnot(
  grepl("20230201_20230228", basename(nc_file)),
  terra::nlyr(chl) == 1L
)

cat("\nCORRECT FEBRUARY 2023 NASA FILE:\n")
print(nc_file)

cat("\nRASTER INFORMATION:\n")
print(chl)

cat("\nSUCCESS: Correct NetCDF loaded automatically.\n")


library(data.table)

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]

march <- copy(df[
  date == as.Date("2023-03-01") &
    is.finite(fishing_hours) &
    is.finite(fishing_lag1) &
    is.finite(fishing_lag12)
])

stopifnot(nrow(march) == 134L)

pts <- terra::vect(
  as.data.frame(march[, .(lon, lat)]),
  geom = c("lon", "lat"),
  crs = "EPSG:4326"
)

# Extract directly from the correct raster
march[, raw_chlorophyll :=
        terra::extract(chl, pts)[[2]]
]

march[, comparison := fcase(
  !is.finite(chlorophyll_lag1) &
    !is.finite(raw_chlorophyll),
  "Both_missing",
  
  is.finite(chlorophyll_lag1) &
    is.finite(raw_chlorophyll) &
    abs(chlorophyll_lag1 - raw_chlorophyll) <= 1e-6,
  "Both_valid_agree",
  
  default = "Disagreement"
)]

cat("\nVERIFICATION RESULTS:\n")
print(march[, .N, by = comparison][order(comparison)])

cat("\nTOTAL DISAGREEMENTS:\n")
print(march[comparison == "Disagreement", .N])

# Save corrected audit, replacing the earlier incorrect one
fwrite(
  march[, .(
    date, cell_id, lat, lon,
    chlorophyll_lag1,
    raw_chlorophyll,
    comparison
  )],
  file.path(
    output_dir,
    "phase22c_raw_raster_cell_audit.csv"
  )
)

fwrite(
  march[, .N, by = comparison],
  file.path(
    output_dir,
    "phase22c_raw_raster_summary.csv"
  )
)


# PHASE 24 — CORRECTED GEOGRAPHIC VALIDATION
# Ghana Blue Economy research
# Four longitude bands, three Random Forest models
# 2019–2022 training / 2023 evaluation

library(data.table)
library(ranger)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# 1. Reload original data
df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, month := as.integer(format(date, "%m"))]

# 2. Identify eligible observations
df[, hist_ready :=
     is.finite(fishing_lag1) &
     is.finite(fishing_lag12)
]

df[, env_ready :=
     hist_ready &
     is.finite(chlorophyll_lag1)
]

# CORRECTED FILTER
df <- df[hist_ready == TRUE]

# 3. Create predictors
df[, `:=`(
  lag1_log = log1p(fishing_lag1),
  lag12_log = log1p(fishing_lag12),
  chl_log = log1p(chlorophyll_lag1),
  month_sin = sin(2 * pi * month / 12),
  month_cos = cos(2 * pi * month / 12),
  target_log = log1p(fishing_hours)
)]

hist_vars <- c(
  "lag1_log", "lag12_log",
  "month_sin", "month_cos"
)

env_vars <- c(hist_vars, "chl_log")

# 4. Established exploratory geographic folds
bands <- data.table(
  fold = c(
    "West",
    "West-central",
    "East-central",
    "East"
  ),
  lon_min = c(-3.45, -2.05, -0.65, 0.75),
  lon_max = c(-2.15, -0.75, 0.65, 1.95)
)

buffer <- 0.20

# 5. Training and evaluation pools
train_pool <- df[
  date < as.Date("2023-01-01") &
    is.finite(fishing_hours)
]

test_pool <- df[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01") &
    env_ready == TRUE &
    is.finite(fishing_hours)
]

cat("\nTRAINING AND TEST COUNTS\n")
print(data.table(
  training = nrow(train_pool),
  training_complete_case =
    train_pool[env_ready == TRUE, .N],
  evaluation = nrow(test_pool)
))

stopifnot(
  nrow(train_pool) == 27926L,
  train_pool[env_ready == TRUE, .N] == 21605L,
  nrow(test_pool) == 5000L
)

# Check predictors and outcome
stopifnot(
  all(is.finite(train_pool$target_log)),
  all(is.finite(train_pool$lag1_log)),
  all(is.finite(train_pool$lag12_log)),
  all(is.finite(test_pool$chl_log))
)

# 6. Model functions
fit_rf <- function(d, features) {
  
  ranger(
    target_log ~ .,
    data = as.data.frame(
      d[, c("target_log", features),
        with = FALSE]
    ),
    num.trees = 500,
    mtry = 2,
    min.node.size = 10,
    seed = 2026,
    num.threads = 2
  )
}

predict_rf <- function(model, d, features) {
  
  predicted_log <- predict(
    model,
    data = as.data.frame(
      d[, ..features]
    )
  )$predictions
  
  pmax(0, expm1(predicted_log))
}

# 7. Geographic validation
scores <- list()
predictions <- list()

for (k in seq_len(nrow(bands))) {
  
  b <- bands[k]
  
  # Geographic test observations
  test <- copy(test_pool[
    lon >= b$lon_min - 1e-8 &
      lon <= b$lon_max + 1e-8
  ])
  
  # Training observations outside geographic
  # test region and longitudinal buffer
  train_all <- train_pool[
    lon < b$lon_min - buffer - 1e-8 |
      lon > b$lon_max + buffer + 1e-8
  ]
  
  # CORRECTED COMPLETE-CASE FILTER
  train_cc <- train_all[
    env_ready == TRUE
  ]
  
  # Stop if design is inconsistent
  stopifnot(
    nrow(test) > 0L,
    nrow(train_all) > 0L,
    nrow(train_cc) > 0L,
    !any(test$cell_id %in% train_all$cell_id),
    all(is.finite(train_cc$chl_log))
  )
  
  cat(
    "\nTRAINING FOLD:", b$fold,
    "\nTest records:", nrow(test),
    "\nHistorical training:", nrow(train_all),
    "\nEnvironmental training:", nrow(train_cc),
    "\n"
  )
  
  # Train models
  model_hist_cc <- fit_rf(
    train_cc, hist_vars
  )
  
  model_env_cc <- fit_rf(
    train_cc, env_vars
  )
  
  model_hist_expanded <- fit_rf(
    train_all, hist_vars
  )
  
  # Predict all three on identical test records
  test[, Historical_CC := predict_rf(
    model_hist_cc, test, hist_vars
  )]
  
  test[, Environmental_CC := predict_rf(
    model_env_cc, test, env_vars
  )]
  
  test[, Historical_Expanded := predict_rf(
    model_hist_expanded, test, hist_vars
  )]
  
  # Evaluate
  for (model_name in c(
    "Historical_CC",
    "Environmental_CC",
    "Historical_Expanded"
  )) {
    
    actual <- test$fishing_hours
    predicted <- test[[model_name]]
    
    score <- data.table(
      fold = b$fold,
      model = model_name,
      n_test = nrow(test),
      n_train = if (
        model_name == "Historical_Expanded"
      ) nrow(train_all) else nrow(train_cc),
      MAE = mean(abs(actual - predicted)),
      RMSE = sqrt(mean(
        (actual - predicted)^2
      )),
      WAPE = if (sum(actual) > 0) {
        100 * sum(abs(actual - predicted)) /
          sum(actual)
      } else NA_real_
    )
    
    scores[[length(scores) + 1L]] <- score
  }
  
  test[, fold := b$fold]
  
  predictions[[k]] <- test[, .(
    fold,
    date,
    cell_id,
    lat,
    lon,
    fishing_hours,
    Historical_CC,
    Environmental_CC,
    Historical_Expanded
  )]
  
  cat("COMPLETED:", b$fold, "\n")
}

# 8. Combine results
results24 <- rbindlist(scores)
pred24 <- rbindlist(predictions)

# 9. Final verification
stopifnot(
  nrow(results24) == 12L,
  nrow(pred24) == 5000L,
  !anyDuplicated(
    pred24,
    by = c("cell_id", "date")
  ),
  all(is.finite(
    as.matrix(pred24[, .(
      Historical_CC,
      Environmental_CC,
      Historical_Expanded
    )])
  ))
)

# 10. Pooled comparison
model_names <- c(
  "Historical_CC",
  "Environmental_CC",
  "Historical_Expanded"
)

pooled24 <- rbindlist(lapply(
  model_names,
  function(m) {
    
    actual <- pred24$fishing_hours
    predicted <- pred24[[m]]
    
    data.table(
      model = m,
      n = length(actual),
      MAE = mean(abs(actual - predicted)),
      RMSE = sqrt(mean(
        (actual - predicted)^2
      )),
      WAPE = 100 * sum(abs(actual - predicted)) /
        sum(actual)
    )
  }
))

stopifnot(
  all(pooled24$n == 5000L),
  all(is.finite(pooled24$MAE)),
  all(is.finite(pooled24$RMSE))
)

# 11. Display verified results
cat("\nPHASE 24 GEOGRAPHIC MODEL RESULTS\n")
print(results24)

cat("\nPHASE 24 POOLED COMPARISON\n")
print(pooled24)

# 12. Save only after all checks pass
fwrite(
  results24,
  file.path(
    output_dir,
    "phase24_geographic_model_results.csv"
  )
)

fwrite(
  pooled24,
  file.path(
    output_dir,
    "phase24_geographic_pooled_results.csv"
  )
)

fwrite(
  pred24,
  file.path(
    output_dir,
    "phase24_geographic_predictions.csv"
  )
)

cat("\nSUCCESS: Phase 24 completed and verified.\n")


# PHASE 25: SPATIAL-BLOCK BOOTSTRAP
# Reuses completed Phase 24 predictions
# Positive MAE gain means the second model is better

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

d <- fread(file.path(
  output_dir,
  "phase24_geographic_predictions.csv"
))

stopifnot(
  nrow(d) == 5000L,
  all(c(
    "lat", "lon", "fishing_hours",
    "Historical_CC", "Environmental_CC",
    "Historical_Expanded"
  ) %in% names(d))
)

# Create half-degree spatial blocks
d[, block_id := paste(
  floor(lon * 2) / 2,
  floor(lat * 2) / 2,
  sep = "_"
)]

# Paired absolute-error differences
d[, gain_env :=
    abs(fishing_hours - Historical_CC) -
    abs(fishing_hours - Environmental_CC)
]

d[, gain_expanded :=
    abs(fishing_hours - Historical_CC) -
    abs(fishing_hours - Historical_Expanded)
]

d[, gain_expanded_vs_env :=
    abs(fishing_hours - Environmental_CC) -
    abs(fishing_hours - Historical_Expanded)
]

# Aggregate all observations within each block
blocks <- d[, .(
  n = .N,
  gain_env_sum = sum(gain_env),
  gain_expanded_sum = sum(gain_expanded),
  gain_expanded_vs_env_sum =
    sum(gain_expanded_vs_env)
), by = block_id]

cat("\nNUMBER OF GEOGRAPHIC BLOCKS\n")
print(nrow(blocks))

# Original pooled paired differences
observed <- data.table(
  comparison = c(
    "Environmental vs Historical_CC",
    "Expanded vs Historical_CC",
    "Expanded vs Environmental"
  ),
  MAE_gain = c(
    mean(d$gain_env),
    mean(d$gain_expanded),
    mean(d$gain_expanded_vs_env)
  )
)

# Resample geographic blocks
set.seed(202625)
B <- 2000L

boot <- matrix(NA_real_, nrow = B, ncol = 3)

for (i in seq_len(B)) {
  
  idx <- sample.int(
    nrow(blocks),
    size = nrow(blocks),
    replace = TRUE
  )
  
  sampled <- blocks[idx]
  
  total_n <- sum(sampled$n)
  
  boot[i, 1] <-
    sum(sampled$gain_env_sum) / total_n
  
  boot[i, 2] <-
    sum(sampled$gain_expanded_sum) / total_n
  
  boot[i, 3] <-
    sum(sampled$gain_expanded_vs_env_sum) /
    total_n
}

# Descriptive percentile intervals
intervals <- data.table(
  comparison = observed$comparison,
  lower_95 = apply(
    boot, 2, quantile,
    probs = 0.025
  ),
  upper_95 = apply(
    boot, 2, quantile,
    probs = 0.975
  )
)

results25 <- merge(
  observed,
  intervals,
  by = "comparison"
)

cat("\nPHASE 25 SPATIAL UNCERTAINTY\n")
print(results25)

fwrite(
  results25,
  file.path(
    output_dir,
    "phase25_spatial_uncertainty.csv"
  )
)

cat("\nSUCCESS: Phase 25 completed.\n")


# GHANA BLUE ECONOMY
# FINAL LINKEDIN AND WHATSAPP GRAPHIC

library(ggplot2)
library(patchwork)
library(grid)

# 1. Verified research observations
available <- 5000
missing <- 1139
total <- available + missing

pct <- 100 * available / total

stopifnot(total == 6139L)

# 2. Donut chart data
chart_data <- data.frame(
  category = factor(
    c("Valid", "Missing"),
    levels = c("Valid", "Missing")
  ),
  value = c(available, missing)
)

# Use a polar bar chart ONLY for the doughnut.
# Labels are placed using separate grid text layers.
donut <- ggplot(
  chart_data,
  aes(x = 2, y = value, fill = category)
) +
  geom_col(
    width = 0.72,
    color = "white",
    linewidth = 1.3
  ) +
  coord_polar(theta = "y", start = 0) +
  xlim(0.5, 2.5) +
  scale_fill_manual(
    values = c(
      Valid = "#0B827D",
      Missing = "#E4A348"
    )
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.margin = margin(0, 0, 0, 0)
  )

# Center percentage as a separate overlay,
# independent of the polar coordinate system
center_label <- wrap_elements(
  full = textGrob(
    sprintf("%.1f%%", pct),
    gp = gpar(
      fontsize = 32,
      fontface = "bold",
      col = "#0B827D"
    )
  )
)

donut_with_label <- donut +
  inset_element(
    center_label,
    left = 0.36,
    bottom = 0.40,
    right = 0.64,
    top = 0.60,
    align_to = "full"
  )

# 3. Heading
header <- wrap_elements(
  full = textGrob(
    paste(
      "CAN SATELLITES TELL THE FULL STORY",
      "OF FISHING IN GHANA?",
      sep = "\n"
    ),
    gp = gpar(
      fontsize = 23,
      fontface = "bold",
      col = "#0B2E4F",
      lineheight = 1.25
    )
  )
)

subtitle <- wrap_elements(
  full = textGrob(
    "A Ghana Blue Economy research finding | 2023",
    gp = gpar(
      fontsize = 13,
      col = "#536675"
    )
  )
)

# 4. Verified counts
result_text <- wrap_elements(
  full = textGrob(
    "5,000 VALID MEASUREMENTS  |  1,139 MISSING",
    gp = gpar(
      fontsize = 16,
      fontface = "bold",
      col = "#0B2E4F"
    )
  )
)

# 5. Explanation
explanation <- wrap_elements(
  full = textGrob(
    paste(
      "Previous-month satellite chlorophyll measurements",
      "among 6,139 historically evaluable",
      "Ghanaian coastal grid-month observations in 2023.",
      sep = "\n"
    ),
    gp = gpar(
      fontsize = 12,
      lineheight = 1.4,
      col = "#536675"
    )
  )
)

source_text <- wrap_elements(
  full = textGrob(
    "Data: Global Fishing Watch and NASA Aqua MODIS",
    gp = gpar(
      fontsize = 10,
      col = "#536675"
    )
  )
)

# 6. Your name and qualification
author_text <- wrap_elements(
  full = textGrob(
    "Peter Sarpong | Master of Science in Business Analytics and AI",
    gp = gpar(
      fontsize = 13,
      fontface = "bold",
      col = "#0B2E4F"
    )
  )
)

# 7. Combine all sections
final_chart <- (
  header /
    subtitle /
    donut_with_label /
    result_text /
    explanation /
    source_text /
    author_text
) +
  plot_layout(
    heights = c(
      0.85,
      0.30,
      3.1,
      0.50,
      0.85,
      0.35,
      0.48
    )
  ) &
  theme(
    plot.background = element_rect(
      fill = "white",
      color = NA
    )
  )

print(final_chart)

# 8. Save automatically
social_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results",
  "Social_Media_Research_Charts"
)

dir.create(
  social_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  file.path(
    social_dir,
    "Ghana_Blue_Economy_Peter_Sarpong_LinkedIn.png"
  ),
  final_chart,
  width = 9,
  height = 9,
  dpi = 300,
  bg = "white"
)

ggsave(
  file.path(
    social_dir,
    "Ghana_Blue_Economy_Peter_Sarpong_WhatsApp.png"
  ),
  final_chart,
  width = 8,
  height = 8,
  dpi = 300,
  bg = "white"
)

cat("\nSUCCESS: Charts saved to:\n")
cat(social_dir, "\n")
cat("Valid percentage:", sprintf("%.1f%%", pct), "\n")

# FIX CENTER PERCENTAGE WITHOUT CLIPPING

library(patchwork)
library(grid)

center_label <- wrap_elements(
  full = textGrob(
    sprintf("%.1f%%", 100 * 5000 / 6139),
    x = unit(0.5, "npc"),
    y = unit(0.5, "npc"),
    gp = gpar(
      fontsize = 28,
      fontface = "bold",
      col = "#0B827D"
    )
  )
)

donut_with_label <- donut +
  inset_element(
    center_label,
    left = 0.38,
    bottom = 0.38,
    right = 0.62,
    top = 0.62,
    align_to = "full"
  )

# Rebuild the completed chart
final_chart <- (
  header /
    subtitle /
    donut_with_label /
    result_text /
    explanation /
    source_text /
    author_text
) +
  plot_layout(
    heights = c(
      0.85, 0.30, 3.1,
      0.50, 0.85, 0.35, 0.48
    )
  )

print(final_chart)




# FIX THE DOUGHNUT PERCENTAGE PERMANENTLY

# Install cowplot if needed
if (!requireNamespace("cowplot", quietly = TRUE)) {
  install.packages("cowplot")
}

library(cowplot)
library(ggplot2)
library(patchwork)

# Correct percentage
pct <- 100 * 5000 / 6139

# Rebuild doughnut without previous text overlays
donut_clean <- ggplot(
  chart_data,
  aes(x = 2, y = value, fill = category)
) +
  geom_col(
    width = 0.72,
    color = "white",
    linewidth = 1.3
  ) +
  coord_polar(theta = "y", start = 0) +
  xlim(0.5, 2.5) +
  scale_fill_manual(
    values = c(
      Valid = "#0B827D",
      Missing = "#E4A348"
    )
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.margin = margin(0, 0, 0, 0)
  )

# Overlay percentage on the complete doughnut panel
donut_fixed <- cowplot::ggdraw() +
  cowplot::draw_plot(donut_clean) +
  cowplot::draw_label(
    sprintf("%.1f%%", pct),
    x = 0.5,
    y = 0.5,
    size = 25,
    fontface = "bold",
    color = "#0B827D"
  )

# Rebuild social media graphic
final_chart <- (
  header /
    subtitle /
    wrap_elements(full = donut_fixed) /
    result_text /
    explanation /
    source_text /
    author_text
) +
  plot_layout(
    heights = c(
      0.85, 0.30, 3.1,
      0.50, 0.85, 0.35, 0.48
    )
  )

print(final_chart)

# Save updated chart
ggsave(
  file.path(
    social_dir,
    "Ghana_Blue_Economy_Peter_Sarpong_CORRECTED.png"
  ),
  final_chart,
  width = 9,
  height = 9,
  dpi = 300,
  bg = "white"
)

cat("SUCCESS: Corrected chart saved.\n")

main_stat_line <- "5,000 VALID CHLOROPHYLL VALUES  |  1,139 MISSING"
annotate(
  "text",
  x = 0,
  y = -1.15,
  label = main_stat_line,
  size = 7,
  fontface = "bold",
  colour = "#0B2E59",
  family = "sans"
)

main_stat_line <- "5,000 VALID CHLOROPHYLL VALUES  |  1,139 MISSING"
sub_line1 <- "Previous-month satellite chlorophyll measurements"
sub_line2 <- "among 6,139 historically evaluable"
sub_line3 <- "Ghanaian coastal grid-month observations in 2023."
sub_line4 <- "Data: Global Fishing Watch and NASA Aqua MODIS"

p +
  annotate("text", x = 0, y = -1.15,
           label = main_stat_line,
           size = 7, fontface = "bold",
           colour = "#0B2E59") +
  annotate("text", x = 0, y = -1.38,
           label = sub_line1,
           size = 5.2, colour = "#3F5D7D") +
  annotate("text", x = 0, y = -1.58,
           label = sub_line2,
           size = 5.2, colour = "#3F5D7D") +
  annotate("text", x = 0, y = -1.78,
           label = sub_line3,
           size = 5.2, colour = "#3F5D7D") +
  annotate("text", x = 0, y = -2.00,
           label = sub_line4,
           size = 4.3, colour = "#3F5D7D")
label = "5,000 VALID MEASUREMENTS  |  1,139 MISSING"
label = "5,000 VALID CHLOROPHYLL VALUES  |  1,139 MISSING"

# FIX THE MAIN RESEARCH LABEL

result_text <- patchwork::wrap_elements(
  full = grid::textGrob(
    "5,000 VALID CHLOROPHYLL VALUES  |  1,139 MISSING",
    gp = grid::gpar(
      fontsize = 14,
      fontface = "bold",
      col = "#0B2E4F"
    )
  )
)

# Rebuild using the EXISTING clean sections
final_chart <- (
  header /
    subtitle /
    donut_fixed /
    result_text /
    explanation /
    source_text /
    author_text
) +
  patchwork::plot_layout(
    heights = c(
      0.85, 0.30, 3.1,
      0.55, 0.85, 0.35, 0.48
    )
  )

print(final_chart)

library(stringr)

extra_note <- str_wrap(
  "Chlorophyll helps researchers study ocean conditions; missing observations can affect environmental prediction models.",
  width = 70
)

p <- p +
  annotate(
    "text",
    x = 0,
    y = -1.78,   # move up/down if needed
    label = extra_note,
    size = 4.6,
    color = "#4F6478",
    fontface = "plain",
    lineheight = 1.15,
    family = "sans"
  ) +
  coord_cartesian(clip = "off") +
  theme(
    plot.margin = margin(t = 25, r = 25, b = 95, l = 25)
  )

extra_note <- paste(
  "Chlorophyll helps researchers study ocean conditions;",
  "missing observations can affect environmental prediction models.",
  sep = "\n"
)

p <- p +
  annotate(
    "text",
    x = 0,
    y = -1.78,
    label = extra_note,
    size = 4.6,
    color = "#4F6478",
    fontface = "plain",
    lineheight = 1.15,
    family = "sans"
  ) +
  coord_cartesian(clip = "off") +
  theme(
    plot.margin = margin(t = 25, r = 25, b = 95, l = 25)
  )


# GHANA BLUE ECONOMY RESEARCH
# SOCIAL MEDIA GRAPHIC — FINAL VERSION
# LinkedIn and WhatsApp | 2023

library(ggplot2)
library(patchwork)
library(cowplot)
library(grid)

# ----------------------------------
# 1. VERIFIED RESEARCH DATA
# ----------------------------------

available <- 5000
missing <- 1139
total <- available + missing

pct <- 100 * available / total

stopifnot(total == 6139)

chart_data <- data.frame(
  category = factor(
    c("Valid", "Missing"),
    levels = c("Valid", "Missing")
  ),
  value = c(available, missing)
)

# ----------------------------------
# 2. DOUGHNUT CHART
# ----------------------------------

donut <- ggplot(
  chart_data,
  aes(x = 2, y = value, fill = category)
) +
  geom_col(
    width = 0.72,
    color = "white",
    linewidth = 1.3
  ) +
  coord_polar(theta = "y", start = 0) +
  xlim(0.5, 2.5) +
  scale_fill_manual(
    values = c(
      Valid = "#0B827D",
      Missing = "#E4A348"
    )
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.margin = margin(0, 0, 0, 0)
  )

# Put percentage in center using cowplot
donut_fixed <- cowplot::ggdraw() +
  cowplot::draw_plot(donut) +
  cowplot::draw_label(
    sprintf("%.1f%%", pct),
    x = 0.5,
    y = 0.5,
    size = 25,
    fontface = "bold",
    color = "#0B827D"
  )

# ----------------------------------
# 3. TITLE AND SUBTITLE
# ----------------------------------

header <- patchwork::wrap_elements(
  full = grid::textGrob(
    paste(
      "CAN SATELLITES TELL THE FULL STORY",
      "OF FISHING IN GHANA?",
      sep = "\n"
    ),
    gp = grid::gpar(
      fontsize = 23,
      fontface = "bold",
      col = "#0B2E4F",
      lineheight = 1.2
    )
  )
)

subtitle <- patchwork::wrap_elements(
  full = grid::textGrob(
    "A Ghana Blue Economy research finding | 2023",
    gp = grid::gpar(
      fontsize = 13,
      col = "#536675"
    )
  )
)

# ----------------------------------
# 4. MAIN VERIFIED COUNTS
# ----------------------------------

result_text <- patchwork::wrap_elements(
  full = grid::textGrob(
    "5,000 VALID CHLOROPHYLL VALUES  |  1,139 MISSING",
    gp = grid::gpar(
      fontsize = 14,
      fontface = "bold",
      col = "#0B2E4F"
    )
  )
)

# ----------------------------------
# 5. RESEARCH EXPLANATION
# ----------------------------------

explanation <- patchwork::wrap_elements(
  full = grid::textGrob(
    paste(
      "Previous-month satellite chlorophyll measurements",
      "among 6,139 historically evaluable",
      "Ghanaian coastal grid-month observations in 2023.",
      sep = "\n"
    ),
    gp = grid::gpar(
      fontsize = 12,
      lineheight = 1.4,
      col = "#536675"
    )
  )
)

# ----------------------------------
# 6. NEW PLAIN-LANGUAGE EXPLANATION
# ----------------------------------

extra_note <- patchwork::wrap_elements(
  full = grid::textGrob(
    paste(
      "Chlorophyll helps researchers study ocean conditions;",
      "missing observations can affect environmental prediction models.",
      sep = "\n"
    ),
    gp = grid::gpar(
      fontsize = 11,
      lineheight = 1.35,
      col = "#375A70"
    )
  )
)

# ----------------------------------
# 7. DATA SOURCES
# ----------------------------------

source_text <- patchwork::wrap_elements(
  full = grid::textGrob(
    "Data: Global Fishing Watch and NASA Aqua MODIS",
    gp = grid::gpar(
      fontsize = 10,
      col = "#536675"
    )
  )
)

# ----------------------------------
# 8. AUTHOR CREDIT
# ----------------------------------

author_text <- patchwork::wrap_elements(
  full = grid::textGrob(
    paste(
      "Peter Sarpong",
      "Master of Science in Business Analytics and AI",
      sep = " | "
    ),
    gp = grid::gpar(
      fontsize = 12,
      fontface = "bold",
      col = "#0B2E4F"
    )
  )
)

# ----------------------------------
# 9. COMBINE ALL SECTIONS
# ----------------------------------

final_chart <- (
  header /
    subtitle /
    patchwork::wrap_elements(full = donut_fixed) /
    result_text /
    explanation /
    extra_note /
    source_text /
    author_text
) +
  patchwork::plot_layout(
    heights = c(
      0.90,  # Title
      0.30,  # Subtitle
      3.10,  # Doughnut
      0.52,  # Counts
      0.90,  # Research explanation
      0.75,  # Plain-language explanation
      0.35,  # Data sources
      0.52   # Author
    )
  ) &
  theme(
    plot.background = element_rect(
      fill = "white",
      color = NA
    )
  )

print(final_chart)

# ----------------------------------
# 10. SAVE AUTOMATICALLY TO YOUR PC
# ----------------------------------

social_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results",
  "Social_Media_Research_Charts"
)

dir.create(
  social_dir,
  showWarnings = FALSE,
  recursive = TRUE
)

# LinkedIn
ggplot2::ggsave(
  filename = file.path(
    social_dir,
    "Ghana_Blue_Economy_LinkedIn_Peter_Sarpong_FINAL.png"
  ),
  plot = final_chart,
  width = 9,
  height = 9,
  dpi = 300,
  bg = "white"
)

# WhatsApp
ggplot2::ggsave(
  filename = file.path(
    social_dir,
    "Ghana_Blue_Economy_WhatsApp_Peter_Sarpong_FINAL.png"
  ),
  plot = final_chart,
  width = 8,
  height = 8,
  dpi = 300,
  bg = "white"
)

cat("\nSUCCESS: Both charts saved.\n")
cat("Location:", social_dir, "\n")
cat("Valid chlorophyll:", available, "\n")
cat("Missing chlorophyll:", missing, "\n")
cat("Percentage:", sprintf("%.1f%%", pct), "\n")

# CORRECTED RESEARCH EXPLANATION

explanation <- patchwork::wrap_elements(
  full = grid::textGrob(
    paste(
      "Previous-month satellite chlorophyll measurements",
      "among 6,139 historically evaluable",
      "Ghanaian coastal Grid-month observations in 2023.",
      sep = "\n"
    ),
    gp = grid::gpar(
      fontsize = 12,
      lineheight = 1.4,
      col = "#536675"
    )
  )
)

final_chart <- (
  header /
    subtitle /
    patchwork::wrap_elements(full = donut_fixed) /
    result_text /
    explanation /
    extra_note /
    source_text /
    author_text
) +
  patchwork::plot_layout(
    heights = c(
      0.90, 0.30, 3.10, 0.52,
      0.90, 0.75, 0.35, 0.52
    )
  )

print(final_chart)

ggplot2::ggsave(
  file.path(
    social_dir,
    "Ghana_Blue_Economy_Peter_Sarpong_FINAL_CORRECTED.png"
  ),
  plot = final_chart,
  width = 9,
  height = 9,
  dpi = 300,
  bg = "white"
)

# Locate your Windows Downloads folder
downloads_dir <- file.path(
  Sys.getenv("USERPROFILE"),
  "Downloads"
)

# Save the final chart as a high-quality PNG
ggplot2::ggsave(
  filename = file.path(
    downloads_dir,
    "Ghana_Blue_Economy_Peter_Sarpong_FINAL.png"
  ),
  plot = final_chart,
  width = 9,
  height = 9,
  units = "in",
  dpi = 300,
  bg = "white"
)

cat("\nSUCCESS! Chart saved to Downloads.\n")
cat("Location:", downloads_dir, "\n")

shell.exec(file.path(
  downloads_dir,
  "Ghana_Blue_Economy_Peter_Sarpong_FINAL.png"
))





# PHASE 29: FORMAL VALIDATION-DESIGN CONTRAST
# Paired temporal versus geographic chlorophyll gain
# Retrospective exploratory inference, 2023

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Load predictions, not summary tables
temporal <- fread(file.path(
  output_dir, "phase21_predictions.csv"
))

geographic <- fread(file.path(
  output_dir, "phase24_geographic_predictions.csv"
))

temporal[, date := as.Date(date)]
geographic[, date := as.Date(date)]

# Both datasets should contain the same evaluation cases.
keys <- c("date", "lat", "lon")

stopifnot(
  nrow(temporal) == 5000L,
  nrow(geographic) == 5000L,
  !anyDuplicated(temporal, by = keys),
  !anyDuplicated(geographic, by = keys)
)

# Keep distinct prediction columns
t <- temporal[, .(
  date, lat, lon,
  actual_t = fishing_hours,
  hist_t = Historical_CC,
  env_t = Environmental_CC
)]

g <- geographic[, .(
  date, lat, lon, fold,
  actual_g = fishing_hours,
  hist_g = Historical_CC,
  env_g = Environmental_CC
)]

# Pair predictions by identical grid location and month.
d <- merge(
  t, g,
  by = keys,
  all = FALSE,
  sort = FALSE
)

stopifnot(
  nrow(d) == 5000L,
  all(is.finite(d$actual_t)),
  all(is.finite(d$actual_g)),
  max(abs(d$actual_t - d$actual_g)) < 1e-8
)

# Check model outputs
pred_cols <- c("hist_t", "env_t", "hist_g", "env_g")

stopifnot(all(vapply(
  d[, ..pred_cols],
  function(z) all(is.finite(z)),
  logical(1)
)))

# Same outcome for all four predictions
d[, actual := actual_t]

# Chlorophyll's error reduction in each design
d[, gain_temporal :=
    abs(actual - hist_t) -
    abs(actual - env_t)
]

d[, gain_geographic :=
    abs(actual - hist_g) -
    abs(actual - env_g)
]

# Primary paired contrast
d[, design_contrast :=
    gain_temporal - gain_geographic
]

observed <- mean(d$design_contrast)

cat("\nPHASE 29 OBSERVED DESIGN CONTRAST\n")
print(data.table(
  n = nrow(d),
  temporal_gain = mean(d$gain_temporal),
  geographic_gain = mean(d$gain_geographic),
  difference_in_gains = observed
))

# Verify agreement with Phases 21A and 24
stopifnot(
  abs(mean(d$gain_temporal) - 0.04130955) < 1e-5,
  abs(mean(d$gain_geographic) + 0.05579011) < 1e-5
)

# Spatial bootstrap sensitivity
set.seed(202629)

B <- 5000L
sizes <- c(0.25, 0.5, 1.0)
outputs <- list()

for (s in sizes) {
  
  d[, block_id := paste(
    floor(lon / s),
    floor(lat / s),
    sep = "_"
  )]
  
  blocks <- d[, .(
    n = .N,
    contrast_sum = sum(design_contrast)
  ), by = block_id]
  
  n_blocks <- nrow(blocks)
  boot <- numeric(B)
  
  for (b in seq_len(B)) {
    
    idx <- sample.int(
      n_blocks, n_blocks,
      replace = TRUE
    )
    
    boot[b] <- sum(blocks$contrast_sum[idx]) /
      sum(blocks$n[idx])
  }
  
  ci <- as.numeric(quantile(
    boot,
    probs = c(0.025, 0.975),
    names = FALSE
  ))
  
  # Exploratory centered-bootstrap test approximation.
  # Retains within-block paired prediction differences.
  centered <- boot - observed
  p_approx <- mean(
    abs(centered) >= abs(observed)
  )
  
  outputs[[length(outputs) + 1L]] <-
    data.table(
      block_degrees = s,
      blocks = n_blocks,
      observations = nrow(d),
      observed_contrast = observed,
      lower_95 = ci[1],
      upper_95 = ci[2],
      includes_zero = ci[1] <= 0 &&
        ci[2] >= 0,
      approximate_p = p_approx
    )
}

results29 <- rbindlist(outputs)

cat("\nPHASE 29 SPATIAL DESIGN-CONTRAST TEST\n")
print(results29)

# Additional diagnostic: observed fold-level contrasts
fold29 <- d[, .(
  n = .N,
  temporal_gain = mean(gain_temporal),
  geographic_gain = mean(gain_geographic),
  contrast = mean(design_contrast)
), by = fold]

cat("\nPHASE 29 GEOGRAPHIC FOLD DIAGNOSTIC\n")
print(fold29)

# Save only after checks pass
fwrite(
  results29,
  file.path(
    output_dir,
    "phase29_design_contrast_bootstrap.csv"
  )
)

fwrite(
  fold29,
  file.path(
    output_dir,
    "phase29_fold_diagnostics.csv"
  )
)

fwrite(
  d[, .(
    date, lat, lon, fold,
    actual, gain_temporal,
    gain_geographic, design_contrast
  )],
  file.path(
    output_dir,
    "phase29_paired_design_contrasts.csv"
  )
)

cat("\nSUCCESS: Phase 29 completed.\n")



# PHASE 29B — CORRECTED FIGURE 1
# Direct comparison of temporal and geographic
# chlorophyll prediction benefits
# Uses actual saved Phase 29 results

library(data.table)
library(ggplot2)

output_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy",
  "Blue_Economy_R_Results"
)

# Read original Phase 29 statistical results
results <- fread(file.path(
  output_dir,
  "phase29_design_contrast_bootstrap.csv"
))

required <- c(
  "block_degrees",
  "blocks",
  "observed_contrast",
  "lower_95",
  "upper_95"
)

stopifnot(all(required %in% names(results)))
stopifnot(nrow(results) == 3L)

# Confirm values match the Phase 29 analysis
stopifnot(
  all(abs(results$observed_contrast -
            0.09709966) < 1e-5),
  all(results$lower_95 < 0),
  all(results$upper_95 > 0)
)

# Prepare labels
results[, block_label := factor(
  sprintf("%.2f° (%d blocks)",
          block_degrees, blocks),
  levels = rev(sprintf(
    "%.2f° (%d blocks)",
    block_degrees, blocks
  ))
)]

# Create figure
fig1 <- ggplot(
  results,
  aes(
    x = observed_contrast,
    y = block_label
  )
) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed",
    color = "gray45"
  ) +
  geom_errorbarh(
    aes(
      xmin = lower_95,
      xmax = upper_95
    ),
    height = 0.15,
    linewidth = 0.85,
    color = "#256F83"
  ) +
  geom_point(
    size = 3.5,
    color = "#256F83"
  ) +
  scale_x_continuous(
    limits = c(-0.18, 0.55),
    breaks = seq(-0.1, 0.5, 0.1)
  ) +
  labs(
    title = paste(
      "Does chlorophyll's predictive benefit",
      "differ by validation design?"
    ),
    subtitle = paste(
      "Temporal minus geographic MAE benefit;",
      "5,000 matched 2023 grid-months"
    ),
    x = paste(
      "Difference in chlorophyll MAE benefit",
      "(fishing hours per grid-month)"
    ),
    y = "Spatial bootstrap block size",
    caption = paste(
      "Points: paired differences in mean absolute",
      "error benefit. Bars: 95% spatial-block",
      "bootstrap percentile intervals (5,000 resamples).",
      "All intervals include zero.",
      "Exploratory analysis; training partitions differ."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8
    )
  )

# Display figure in RStudio
print(fig1)

# Save in manuscript figures directory
fig_dir <- file.path(
  output_dir,
  "Manuscript_Figures"
)

dir.create(
  fig_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  filename = file.path(
    fig_dir,
    "Figure_1_Corrected_Phase29.png"
  ),
  plot = fig1,
  width = 9,
  height = 5.5,
  dpi = 300
)

ggsave(
  filename = file.path(
    fig_dir,
    "Figure_1_Corrected_Phase29.pdf"
  ),
  plot = fig1,
  width = 9,
  height = 5.5
)

cat("\nCORRECTED FIGURE 1 SAVED SUCCESSFULLY\n")
cat("Folder:", fig_dir, "\n")




# FINAL JOURNAL FORMATTING — FIGURE 1
# Uses existing verified fig1 and Phase 29 results

library(ggplot2)

fig1_final <- fig1 +
  labs(
    title = paste(
      "Difference in chlorophyll-associated",
      "prediction benefit"
    ),
    subtitle = paste(
      "Temporal minus geographic validation;",
      "5,000 matched grid-months (2023)"
    ),
    x = paste(
      "Difference in paired MAE benefit",
      "(fishing hours per grid-month)"
    ),
    y = "Spatial bootstrap block size",
    caption = NULL
  ) +
  theme(
    plot.title = element_text(
      size = 13,
      face = "bold"
    ),
    plot.subtitle = element_text(size = 10),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank()
  )

print(fig1_final)

ggsave(
  file.path(
    fig_dir,
    "Figure_1_Final_Journal.png"
  ),
  fig1_final,
  width = 9,
  height = 5,
  dpi = 300
)

ggsave(
  file.path(
    fig_dir,
    "Figure_1_Final_Journal.pdf"
  ),
  fig1_final,
  width = 9,
  height = 5
)

cat("\nFINAL FIGURE 1 SAVED.\n")





# FINAL REPRODUCIBILITY AUDIT — STEP 1

library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

stopifnot(
  dir.exists(project_dir),
  dir.exists(output_dir)
)

# Locate research scripts
r_scripts <- list.files(
  project_dir,
  pattern = "\\.[Rr]$",
  recursive = TRUE,
  full.names = TRUE
)

# Locate analytical datasets and model outputs
research_files <- list.files(
  output_dir,
  pattern = "\\.(csv|rds|RDS)$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
)

cat("\nR SCRIPTS FOUND:", length(r_scripts), "\n")
print(r_scripts)

cat("\nRESEARCH OUTPUT FILES:",
    length(research_files), "\n")

# Confirm key analytical files
required <- c(
  "ghana_full_grid_month_panel.csv",
  "phase21_predictions.csv",
  "phase24_geographic_predictions.csv",
  "phase25_spatial_uncertainty.csv",
  "phase26_block_size_sensitivity.csv",
  "phase29_design_contrast_bootstrap.csv"
)

file_check <- data.table(
  file = required,
  exists = file.exists(
    file.path(output_dir, required)
  )
)

print(file_check)

# Record checksums and file sizes
inventory <- data.table(
  file = research_files,
  size_bytes = file.info(research_files)$size,
  md5 = unname(tools::md5sum(research_files))
)

audit_dir <- file.path(
  output_dir,
  "Final_Reproducibility_Audit"
)

dir.create(
  audit_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

fwrite(
  inventory,
  file.path(audit_dir, "file_inventory.csv")
)

writeLines(
  capture.output(sessionInfo()),
  file.path(audit_dir, "R_session_info.txt")
)

cat("\nINITIAL INVENTORY COMPLETED\n")




# FINAL REPRODUCIBILITY AUDIT — STEP 2
# Inspect existing scripts and saved R history

library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

audit_dir <- file.path(
  output_dir,
  "Final_Reproducibility_Audit"
)

dir.create(audit_dir, recursive = TRUE,
           showWarnings = FALSE)

# 1. Inspect the five existing R scripts
r_scripts <- list.files(
  project_dir,
  pattern = "\\.[Rr]$",
  recursive = TRUE,
  full.names = TRUE
)

script_audit <- rbindlist(lapply(
  r_scripts,
  function(f) {
    lines <- readLines(f, warn = FALSE)
    
    data.table(
      script = basename(f),
      lines = length(lines),
      size_kb = round(file.info(f)$size / 1024, 1),
      mentions_phase = any(grepl(
        "phase[0-9]+|PHASE [0-9]+",
        lines,
        ignore.case = TRUE
      )),
      uses_ranger = any(grepl(
        "ranger", lines,
        ignore.case = TRUE
      )),
      uses_terra = any(grepl(
        "terra", lines,
        ignore.case = TRUE
      ))
    )
  }
))

cat("\nSCRIPT AUDIT\n")
print(script_audit)

# 2. Check standard locations for R history
history_paths <- unique(c(
  file.path(project_dir, ".Rhistory"),
  file.path(getwd(), ".Rhistory"),
  file.path(path.expand("~"), ".Rhistory"),
  file.path(Sys.getenv("USERPROFILE"), ".Rhistory")
))

history_found <- history_paths[
  file.exists(history_paths)
]

cat("\nR HISTORY FILES FOUND\n")
print(history_found)

# 3. Search saved history for later phases
history_audit <- rbindlist(
  lapply(history_found, function(f) {
    lines <- readLines(f, warn = FALSE)
    
    data.table(
      file = f,
      total_lines = length(lines),
      phase19_to_29_mentions = sum(grepl(
        "phase(19|2[0-9])",
        lines,
        ignore.case = TRUE
      ))
    )
  }),
  fill = TRUE
)

cat("\nHISTORY AUDIT\n")
print(history_audit)

# 4. Save audit reports
fwrite(
  script_audit,
  file.path(audit_dir, "script_audit.csv")
)

fwrite(
  history_audit,
  file.path(audit_dir, "history_audit.csv")
)

# Save current interactive history, if available
try(
  savehistory(
    file.path(audit_dir, "current_R_history.Rhistory")
  ),
  silent = TRUE
)

cat("\nSTEP 2 COMPLETED\n")



# FINAL REPRODUCIBILITY AUDIT — STEP 3
# Inspect the 8,418-line main research script

library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

audit_dir <- file.path(
  output_dir,
  "Final_Reproducibility_Audit"
)

main_script <- file.path(
  project_dir,
  "Ghana blue economy Data Research.R"
)

stopifnot(file.exists(main_script))

code <- readLines(main_script, warn = FALSE)

# 1. Locate phase headings or comments
phase_pattern <- paste0(
  "(?i)\\bphase\\s*",
  "(?:[1-9]|1[0-9]|2[0-9])",
  "(?:[a-z])?\\b"
)

phase_hits <- grep(
  phase_pattern,
  code,
  perl = TRUE
)

phase_index <- data.table(
  line_number = phase_hits,
  text = trimws(code[phase_hits])
)

cat("\nPHASE REFERENCES IN MAIN SCRIPT\n")
print(phase_index, nrows = 100)

# 2. Identify known output filenames
targets <- c(
  "ghana_full_grid_month_panel.csv",
  "phase21_predictions.csv",
  "phase24_geographic_predictions.csv",
  "phase25_spatial_uncertainty.csv",
  "phase26_block_size_sensitivity.csv",
  "phase29_design_contrast_bootstrap.csv"
)

target_audit <- rbindlist(lapply(
  targets,
  function(f) {
    hits <- grep(f, code, fixed = TRUE)
    
    data.table(
      output = f,
      occurrences = length(hits),
      lines = paste(hits, collapse = ", ")
    )
  }
))

cat("\nOUTPUT FILE REFERENCES\n")
print(target_audit)

# 3. Check Phase 29 methods
methods <- c(
  "design_contrast",
  "gain_temporal",
  "gain_geographic",
  "block_degrees",
  "sample.int",
  "ranger",
  "terra::extract"
)

method_audit <- rbindlist(lapply(
  methods,
  function(term) {
    hits <- grep(term, code, fixed = TRUE)
    
    data.table(
      method = term,
      occurrences = length(hits),
      first_line = if (length(hits)) {
        hits[1]
      } else NA_integer_
    )
  }
))

cat("\nMETHOD REFERENCES\n")
print(method_audit)

# 4. Syntax check without executing the script
parse_result <- tryCatch(
  {
    parse(file = main_script)
    "PASS"
  },
  error = function(e) {
    paste("FAIL:", conditionMessage(e))
  }
)

cat("\nMAIN SCRIPT PARSE CHECK\n")
print(parse_result)

# 5. Save audit
fwrite(
  phase_index,
  file.path(audit_dir, "phase_index.csv")
)

fwrite(
  target_audit,
  file.path(audit_dir, "script_output_references.csv")
)

fwrite(
  method_audit,
  file.path(audit_dir, "method_references.csv")
)

writeLines(
  parse_result,
  file.path(audit_dir, "main_script_parse_check.txt")
)

cat("\nSTEP 3 COMPLETED\n")



# FINAL REPRODUCIBILITY AUDIT — STEP 4
# Reproduce Phases 26 and 29
# Does not overwrite original research outputs

library(data.table)

output_dir <- file.path(
  Sys.getenv("OneDrive"), "Desktop",
  "blue economy", "Blue_Economy_R_Results"
)

audit_dir <- file.path(
  output_dir, "Final_Reproducibility_Audit"
)

dir.create(audit_dir, recursive = TRUE,
           showWarnings = FALSE)

geo <- fread(file.path(
  output_dir, "phase24_geographic_predictions.csv"
))

temp <- fread(file.path(
  output_dir, "phase21_predictions.csv"
))

stopifnot(nrow(geo) == 5000L,
          nrow(temp) == 5000L)

geo[, date := as.Date(date)]
temp[, date := as.Date(date)]

keys <- c("date", "lat", "lon")

stopifnot(
  !anyDuplicated(geo, by = keys),
  !anyDuplicated(temp, by = keys)
)

# Join on the same evaluation observations
d <- merge(
  temp[, .(
    date, lat, lon,
    actual_t = fishing_hours,
    hist_t = Historical_CC,
    env_t = Environmental_CC
  )],
  geo[, .(
    date, lat, lon,
    actual_g = fishing_hours,
    hist_g = Historical_CC,
    env_g = Environmental_CC,
    hist_exp = Historical_Expanded
  )],
  by = keys
)

stopifnot(
  nrow(d) == 5000L,
  max(abs(d$actual_t - d$actual_g)) < 1e-8
)

d[, actual := actual_t]

stopifnot(all(is.finite(as.matrix(
  d[, .(actual, hist_t, env_t,
        hist_g, env_g, hist_exp)]
))))

# Paired MAE gain; positive favors second model
d[, `:=`(
  gain_env_geo =
    abs(actual - hist_g) -
    abs(actual - env_g),
  
  gain_exp_hist =
    abs(actual - hist_g) -
    abs(actual - hist_exp),
  
  gain_exp_env =
    abs(actual - env_g) -
    abs(actual - hist_exp),
  
  gain_temporal =
    abs(actual - hist_t) -
    abs(actual - env_t)
)]

d[, design_contrast :=
    gain_temporal - gain_env_geo
]

cat("\nVERIFIED POINT ESTIMATES\n")

point_check <- data.table(
  metric = c(
    "Temporal chlorophyll gain",
    "Geographic chlorophyll gain",
    "Expanded vs historical gain",
    "Expanded vs environmental gain",
    "Temporal-geographic contrast"
  ),
  regenerated = c(
    mean(d$gain_temporal),
    mean(d$gain_env_geo),
    mean(d$gain_exp_hist),
    mean(d$gain_exp_env),
    mean(d$design_contrast)
  ),
  expected = c(
    0.04130955,
    -0.05579011,
    0.02203974,
    0.07782985,
    0.09709966
  )
)

point_check[, absolute_difference :=
              abs(regenerated - expected)
]

print(point_check)

stopifnot(
  all(point_check$absolute_difference < 1e-5)
)

# Resample entire geographic blocks
bootstrap_blocks <- function(data, width,
                             vars, B = 5000L,
                             seed = 202629L) {
  
  x <- copy(data)
  
  x[, block_id := paste(
    floor(lon / width),
    floor(lat / width),
    sep = "_"
  )]
  
  blocks <- x[, c(
    list(n = .N),
    lapply(.SD, sum)
  ), by = block_id, .SDcols = vars]
  
  K <- nrow(blocks)
  set.seed(seed)
  
  out <- vector("list", length(vars))
  
  # Shared draws for all comparisons
  boot <- matrix(
    NA_real_, nrow = B,
    ncol = length(vars)
  )
  
  for (b in seq_len(B)) {
    ids <- sample.int(K, K, replace = TRUE)
    denom <- sum(blocks$n[ids])
    
    for (j in seq_along(vars)) {
      boot[b, j] <-
        sum(blocks[[vars[j]]][ids]) / denom
    }
  }
  
  for (j in seq_along(vars)) {
    q <- quantile(
      boot[, j], c(0.025, 0.975),
      names = FALSE
    )
    
    out[[j]] <- data.table(
      block_degrees = width,
      blocks = K,
      metric = vars[j],
      estimate = mean(x[[vars[j]]]),
      lower_95 = q[1],
      upper_95 = q[2],
      includes_zero = q[1] <= 0 & q[2] >= 0
    )
  }
  
  rbindlist(out)
}

# Phase 26 and Phase 29 sensitivity analyses
sizes <- c(0.25, 0.50, 1.00)

all_results <- rbindlist(lapply(
  sizes,
  function(s) {
    bootstrap_blocks(
      d, s,
      vars = c(
        "gain_env_geo",
        "gain_exp_hist",
        "gain_exp_env",
        "design_contrast"
      ),
      B = 5000L,
      seed = 202629L
    )
  }
))

cat("\nREGENERATED SPATIAL BOOTSTRAP RESULTS\n")
print(all_results)

# Verify the conclusion, not exact bootstrap
# endpoints (random draws may differ).
stopifnot(
  nrow(all_results) == 12L,
  all(all_results$includes_zero),
  all(is.finite(all_results$lower_95)),
  all(is.finite(all_results$upper_95))
)

# Compare with original saved intervals.
original26 <- fread(file.path(
  output_dir, "phase26_block_size_sensitivity.csv"
))

original29 <- fread(file.path(
  output_dir, "phase29_design_contrast_bootstrap.csv"
))

map26 <- c(
  Environmental_vs_Historical = "gain_env_geo",
  Expanded_vs_Historical = "gain_exp_hist",
  Expanded_vs_Environmental = "gain_exp_env"
)

original26[, metric := unname(
  map26[comparison]
)]

check26 <- merge(
  original26,
  all_results[metric != "design_contrast"],
  by.x = c("block_size_degrees", "metric"),
  by.y = c("block_degrees", "metric"),
  suffixes = c("_original", "_new")
)

check29 <- merge(
  original29,
  all_results[metric == "design_contrast"],
  by.x = "block_degrees",
  by.y = "block_degrees",
  suffixes = c("_original", "_new")
)

stopifnot(nrow(check26) == 9L)
stopifnot(nrow(check29) == 3L)

check26[, conclusion_matches :=
          includes_zero_original == includes_zero_new
]

check29[, conclusion_matches :=
          includes_zero_original == includes_zero_new
]

cat("\nPHASE 26 CONCLUSION CHECK\n")
print(check26[, .(
  block_size_degrees, metric,
  conclusion_matches
)])

cat("\nPHASE 29 CONCLUSION CHECK\n")
print(check29[, .(
  block_degrees, conclusion_matches
)])

stopifnot(
  all(check26$conclusion_matches),
  all(check29$conclusion_matches)
)

# Save new reproducibility outputs
fwrite(point_check, file.path(
  audit_dir, "reproduced_point_estimates.csv"
))

fwrite(all_results, file.path(
  audit_dir, "reproduced_bootstrap_results.csv"
))

fwrite(check26, file.path(
  audit_dir, "phase26_reproduction_comparison.csv"
))

fwrite(check29, file.path(
  audit_dir, "phase29_reproduction_comparison.csv"
))

cat("\nSUCCESS: PHASES 26 AND 29 REPRODUCED\n")


# FINAL REPRODUCIBILITY AUDIT
# STEP 5: INDEPENDENT PHASE 24 MODEL RE-RUN
# Do not execute the old 8,418-line script

library(data.table)
library(ranger)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

output_dir <- file.path(
  project_dir,
  "Blue_Economy_R_Results"
)

audit_dir <- file.path(
  output_dir,
  "Final_Reproducibility_Audit",
  "Phase24_Reproduction"
)

dir.create(
  audit_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

# --------------------------------------------------
# 1. Load original model panel
# --------------------------------------------------

df <- fread(file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
))

df[, date := as.Date(date)]
df[, month := as.integer(format(date, "%m"))]

stopifnot(
  nrow(df) == 99204L,
  !anyDuplicated(df, by = c("cell_id", "date"))
)

df[, hist_ready :=
     is.finite(fishing_lag1) &
     is.finite(fishing_lag12)
]

df[, env_ready :=
     hist_ready &
     is.finite(chlorophyll_lag1)
]

# Explicit logical filter for data.table
df <- df[hist_ready == TRUE]

stopifnot(
  all(fishing_lag1 >= 0, na.rm = TRUE),
  all(df$fishing_lag12 >= 0)
)

# --------------------------------------------------
# 2. Reconstruct model features
# --------------------------------------------------

df[, `:=`(
  lag1_log = log1p(fishing_lag1),
  lag12_log = log1p(fishing_lag12),
  chl_log = log1p(chlorophyll_lag1),
  month_sin = sin(2 * pi * month / 12),
  month_cos = cos(2 * pi * month / 12),
  target_log = log1p(fishing_hours)
)]

hist_vars <- c(
  "lag1_log",
  "lag12_log",
  "month_sin",
  "month_cos"
)

env_vars <- c(hist_vars, "chl_log")

# --------------------------------------------------
# 3. Define original training and evaluation
# --------------------------------------------------

train_pool <- df[
  date < as.Date("2023-01-01") &
    is.finite(fishing_hours)
]

test_pool <- df[
  date >= as.Date("2023-01-01") &
    date < as.Date("2024-01-01") &
    env_ready == TRUE &
    is.finite(fishing_hours)
]

stopifnot(
  nrow(train_pool) == 27926L,
  train_pool[env_ready == TRUE, .N] == 21605L,
  nrow(test_pool) == 5000L
)

# Geographic partitions
bands <- data.table(
  fold = c(
    "West",
    "West-central",
    "East-central",
    "East"
  ),
  lon_min = c(-3.45, -2.05, -0.65, 0.75),
  lon_max = c(-2.15, -0.75, 0.65, 1.95)
)

buffer <- 0.20

# --------------------------------------------------
# 4. Reproduce the original model specifications
# --------------------------------------------------

fit_rf <- function(data, variables) {
  
  model_data <- as.data.frame(
    data[, c("target_log", variables),
         with = FALSE]
  )
  
  ranger(
    target_log ~ .,
    data = model_data,
    num.trees = 500,
    mtry = 2,
    min.node.size = 10,
    seed = 2026,
    num.threads = 2
  )
}

predict_rf <- function(model, data, variables) {
  
  z <- predict(
    model,
    data = as.data.frame(
      data[, ..variables]
    )
  )$predictions
  
  pmax(0, expm1(z))
}

# --------------------------------------------------
# 5. Refit all twelve geographic models
# --------------------------------------------------

scores <- list()
predictions <- list()

for (k in seq_len(nrow(bands))) {
  
  b <- bands[k]
  
  test <- copy(test_pool[
    lon >= b$lon_min - 1e-8 &
      lon <= b$lon_max + 1e-8
  ])
  
  train_all <- train_pool[
    lon < b$lon_min - buffer - 1e-8 |
      lon > b$lon_max + buffer + 1e-8
  ]
  
  train_cc <- train_all[
    env_ready == TRUE
  ]
  
  stopifnot(
    nrow(test) > 0L,
    nrow(train_all) > 0L,
    nrow(train_cc) > 0L,
    !any(test$cell_id %in% train_all$cell_id)
  )
  
  # Check expected training and evaluation sizes
  expected_test <- c(584L, 1646L, 2039L, 731L)
  
  expected_hist <- c(
    22511L, 17543L, 14546L, 21894L
  )
  
  expected_cc <- c(
    17454L, 13822L, 11104L, 16753L
  )
  
  stopifnot(
    nrow(test) == expected_test[k],
    nrow(train_all) == expected_hist[k],
    nrow(train_cc) == expected_cc[k]
  )
  
  model_h_cc <- fit_rf(train_cc, hist_vars)
  model_e_cc <- fit_rf(train_cc, env_vars)
  model_h_exp <- fit_rf(train_all, hist_vars)
  
  test[, Historical_CC :=
         predict_rf(model_h_cc, test, hist_vars)
  ]
  
  test[, Environmental_CC :=
         predict_rf(model_e_cc, test, env_vars)
  ]
  
  test[, Historical_Expanded :=
         predict_rf(model_h_exp, test, hist_vars)
  ]
  
  for (m in c(
    "Historical_CC",
    "Environmental_CC",
    "Historical_Expanded"
  )) {
    
    y <- test$fishing_hours
    p <- test[[m]]
    
    scores[[length(scores) + 1L]] <-
      data.table(
        fold = b$fold,
        model = m,
        n_test = nrow(test),
        MAE = mean(abs(y - p)),
        RMSE = sqrt(mean((y - p)^2)),
        WAPE = 100 * sum(abs(y - p)) / sum(y)
      )
  }
  
  test[, fold := b$fold]
  
  predictions[[k]] <- test[, .(
    fold, date, cell_id, lat, lon,
    fishing_hours,
    Historical_CC,
    Environmental_CC,
    Historical_Expanded
  )]
  
  cat("Reproduced:", b$fold, "\n")
}

# --------------------------------------------------
# 6. Calculate fresh results
# --------------------------------------------------

new_scores <- rbindlist(scores)
new_predictions <- rbindlist(predictions)

stopifnot(
  nrow(new_scores) == 12L,
  nrow(new_predictions) == 5000L,
  !anyDuplicated(
    new_predictions,
    by = c("cell_id", "date")
  )
)

model_names <- c(
  "Historical_CC",
  "Environmental_CC",
  "Historical_Expanded"
)

new_pooled <- rbindlist(lapply(
  model_names,
  function(m) {
    
    y <- new_predictions$fishing_hours
    p <- new_predictions[[m]]
    
    data.table(
      model = m,
      n = length(y),
      MAE = mean(abs(y - p)),
      RMSE = sqrt(mean((y - p)^2)),
      WAPE = 100 * sum(abs(y - p)) / sum(y)
    )
  }
))

# --------------------------------------------------
# 7. Compare regenerated models with originals
# --------------------------------------------------

original_scores <- fread(file.path(
  output_dir,
  "phase24_geographic_model_results.csv"
))

original_pooled <- fread(file.path(
  output_dir,
  "phase24_geographic_pooled_results.csv"
))

original_predictions <- fread(file.path(
  output_dir,
  "phase24_geographic_predictions.csv"
))

new_predictions[, date := as.Date(date)]
original_predictions[, date := as.Date(date)]

# Match by grid cell and month, never row position
key_cols <- c("cell_id", "date")

comparison <- merge(
  original_predictions[, c(
    key_cols, model_names
  ), with = FALSE],
  new_predictions[, c(
    key_cols, model_names
  ), with = FALSE],
  by = key_cols,
  suffixes = c("_original", "_new")
)

stopifnot(
  nrow(comparison) == 5000L,
  !anyDuplicated(comparison, by = key_cols)
)

prediction_check <- rbindlist(lapply(
  model_names,
  function(m) {
    
    old <- comparison[[paste0(m, "_original")]]
    new <- comparison[[paste0(m, "_new")]]
    
    data.table(
      model = m,
      max_absolute_difference =
        max(abs(new - old)),
      mean_absolute_difference =
        mean(abs(new - old))
    )
  }
))

pooled_check <- merge(
  original_pooled,
  new_pooled,
  by = "model",
  suffixes = c("_original", "_new")
)

pooled_check[, `:=`(
  MAE_difference =
    MAE_new - MAE_original,
  RMSE_difference =
    RMSE_new - RMSE_original,
  WAPE_difference =
    WAPE_new - WAPE_original
)]

cat("\nPHASE 24 PREDICTION REPRODUCTION\n")
print(prediction_check)

cat("\nPHASE 24 POOLED METRIC REPRODUCTION\n")
print(pooled_check)

# Note: Floating-point/model-library differences
# may occur across computers or package versions.
# Do not force equality by changing results.

# --------------------------------------------------
# 8. Save only new audit outputs
# --------------------------------------------------

fwrite(
  prediction_check,
  file.path(
    audit_dir, "prediction_comparison.csv"
  )
)

fwrite(
  pooled_check,
  file.path(
    audit_dir, "pooled_metric_comparison.csv"
  )
)

fwrite(
  new_predictions,
  file.path(
    audit_dir, "reproduced_predictions.csv"
  )
)

fwrite(
  new_scores,
  file.path(
    audit_dir, "reproduced_fold_results.csv"
  )
)

fwrite(
  new_pooled,
  file.path(
    audit_dir, "reproduced_pooled_results.csv"
  )
)

writeLines(
  capture.output(sessionInfo()),
  file.path(
    audit_dir, "reproduction_session_info.txt"
  )
)

cat("\nPHASE 24 RE-RUN COMPLETED.\n")




# STEP 6 — UPSTREAM PIPELINE INSPECTION
# Read-only: does not execute research scripts

library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop", "blue economy"
)

output_dir <- file.path(
  project_dir, "Blue_Economy_R_Results"
)

audit_dir <- file.path(
  output_dir, "Final_Reproducibility_Audit"
)

main_script <- file.path(
  project_dir, "Ghana blue economy Data Research.R"
)

code <- readLines(main_script, warn = FALSE)

# Find the creation of the main analytical panel
terms <- c(
  "ghana_full_grid_month_panel.csv",
  "fwrite(",
  "saveRDS(",
  "read_ncdf",
  "rast(",
  "terra::extract",
  "fishing_lag1",
  "chlorophyll_lag1"
)

results <- rbindlist(lapply(terms, function(term) {
  hits <- grep(term, code, fixed = TRUE)
  
  data.table(
    search_term = term,
    occurrences = length(hits),
    line_numbers = paste(hits, collapse = ", ")
  )
}))

print(results, width = Inf)

# Export the early data-construction section
# for inspection, without running it.
upstream_file <- file.path(
  audit_dir, "upstream_pipeline_for_review.R"
)

writeLines(
  code[seq_len(min(1276L, length(code)))],
  upstream_file
)

cat("\nUpstream code exported:\n",
    upstream_file, "\n")






# FINAL REPRODUCIBILITY AUDIT — STEP 6
# Rebuild the analytical panel from GFW and NASA
# intermediate files.
# Original research files are never overwritten.

library(data.table)

project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop", "blue economy"
)

output_dir <- file.path(
  project_dir, "Blue_Economy_R_Results"
)

audit_dir <- file.path(
  output_dir,
  "Final_Reproducibility_Audit",
  "Panel_Reproduction"
)

dir.create(audit_dir, recursive = TRUE,
           showWarnings = FALSE)

gfw_path <- file.path(
  output_dir,
  "ghana_coastal_fishing_grid_monthly.csv"
)

nasa_path <- file.path(
  output_dir,
  "ghana_coastal_gfw_nasa_spatial_panel.csv"
)

original_path <- file.path(
  output_dir,
  "ghana_full_grid_month_panel.csv"
)

stopifnot(all(file.exists(c(
  gfw_path, nasa_path, original_path
))))

# 1. Load intermediate research datasets
gfw <- fread(gfw_path)
nasa <- fread(nasa_path)
original <- fread(original_path)

required_gfw <- c(
  "date", "lat", "lon",
  "fishing_hours", "presence_hours"
)

required_nasa <- c(
  "date", "lat", "lon", "chlor_a_mg_m3"
)

stopifnot(
  all(required_gfw %in% names(gfw)),
  all(required_nasa %in% names(nasa))
)

gfw[, date := as.Date(date)]
nasa[, date := as.Date(date)]
original[, date := as.Date(date)]

keys <- c("date", "lat", "lon")

stopifnot(
  !anyNA(gfw[, ..keys]),
  !anyNA(original[, ..keys]),
  !anyDuplicated(gfw, by = keys),
  !anyDuplicated(original, by = keys)
)

# 2. Reconstruct original geographic cells
cells <- unique(gfw[, .(lat, lon)])
cells[, cell_id := .I]

months <- seq(
  as.Date("2018-01-01"),
  as.Date("2024-12-01"),
  by = "month"
)

rebuilt <- CJ(
  date = months,
  cell_id = seq_len(nrow(cells))
)

rebuilt <- merge(
  rebuilt, cells, by = "cell_id"
)

# 3. Attach GFW observations
gfw[, gfw_record_present := TRUE]

rebuilt <- merge(
  rebuilt,
  gfw,
  by = keys,
  all.x = TRUE
)

rebuilt[
  is.na(gfw_record_present),
  gfw_record_present := FALSE
]

# 4. Attach chlorophyll observations
nasa_chl <- unique(
  nasa[, .(
    date, lat, lon, chlor_a_mg_m3
  )]
)

stopifnot(
  !anyDuplicated(nasa_chl, by = keys)
)

rebuilt <- merge(
  rebuilt,
  nasa_chl,
  by = keys,
  all.x = TRUE
)

# 5. Rebuild lagged predictors
setorder(rebuilt, cell_id, date)

rebuilt[, fishing_lag1 :=
          shift(fishing_hours, 1L),
        by = cell_id
]

rebuilt[, fishing_lag12 :=
          shift(fishing_hours, 12L),
        by = cell_id
]

rebuilt[, chlorophyll_lag1 :=
          shift(chlor_a_mg_m3, 1L),
        by = cell_id
]

rebuilt[, year := as.integer(
  format(date, "%Y")
)]

rebuilt[, month := as.integer(
  format(date, "%m")
)]

# 6. Verify structure
stopifnot(
  nrow(rebuilt) == 99204L,
  uniqueN(rebuilt$cell_id) == 1181L,
  length(months) == 84L,
  !anyDuplicated(rebuilt, by = keys)
)

cat("\nREBUILT PANEL SUMMARY\n")
print(data.table(
  rows = nrow(rebuilt),
  cells = uniqueN(rebuilt$cell_id),
  months = uniqueN(rebuilt$date),
  GFW_present = sum(rebuilt$gfw_record_present),
  GFW_absent = sum(!rebuilt$gfw_record_present)
))

# 7. Match original and rebuilt records
# Compare observations by date/latitude/longitude,
# not by row position.

setkeyv(original, keys)
setkeyv(rebuilt, keys)

stopifnot(
  nrow(original) == nrow(rebuilt),
  nrow(fsetdiff(
    original[, ..keys],
    rebuilt[, ..keys]
  )) == 0L,
  nrow(fsetdiff(
    rebuilt[, ..keys],
    original[, ..keys]
  )) == 0L
)

shared <- intersect(
  names(original), names(rebuilt)
)

compare_cols <- setdiff(shared, keys)

checks <- rbindlist(lapply(
  compare_cols,
  function(nm) {
    
    old <- original[[nm]]
    new <- rebuilt[[nm]]
    
    if (is.numeric(old) && is.numeric(new)) {
      
      both_missing <- is.na(old) & is.na(new)
      both_present <- !is.na(old) & !is.na(new)
      
      delta <- abs(old[both_present] -
                     new[both_present])
      
      failures <- sum(
        !(both_missing | both_present)
      ) + sum(!is.finite(delta) |
                delta > 1e-8)
      
      max_diff <- if (length(delta)) {
        max(delta, na.rm = TRUE)
      } else {
        0
      }
      
    } else {
      
      failures <- sum(
        !(old == new |
            (is.na(old) & is.na(new))),
        na.rm = TRUE
      )
      
      # Explicitly count one-sided missingness
      failures <- failures + sum(
        xor(is.na(old), is.na(new))
      )
      
      max_diff <- NA_real_
    }
    
    data.table(
      variable = nm,
      mismatched_rows = failures,
      max_abs_difference = max_diff
    )
  }
))

# Check whether either file has additional columns
only_original <- setdiff(
  names(original), names(rebuilt)
)

only_rebuilt <- setdiff(
  names(rebuilt), names(original)
)

cat("\nPANEL COLUMN COMPARISON\n")
print(checks)

cat("\nColumns only in original:\n")
print(only_original)

cat("\nColumns only in rebuilt:\n")
print(only_rebuilt)

cat("\nTOTAL MISMATCHES:",
    sum(checks$mismatched_rows), "\n")

# 8. Preserve complete audit evidence
fwrite(
  rebuilt,
  file.path(
    audit_dir, "rebuilt_full_panel.csv"
  )
)

fwrite(
  checks,
  file.path(
    audit_dir, "panel_comparison.csv"
  )
)

writeLines(
  capture.output(sessionInfo()),
  file.path(
    audit_dir, "panel_reproduction_session.txt"
  )
)

if (sum(checks$mismatched_rows) == 0 &&
    length(only_original) == 0 &&
    length(only_rebuilt) == 0) {
  
  cat("\nSUCCESS: FULL PANEL REPRODUCED\n")
  
} else {
  
  cat("\nREVIEW REQUIRED: PANEL DIFFERENCES FOUND\n")
}


project_dir <- file.path(
  Sys.getenv("OneDrive"),
  "Desktop",
  "blue economy"
)

file.copy(
  file.path(
    project_dir,
    "run_blue_economy_from_downloads.R"
  ),
  file.path(
    project_dir,
    "Final_Raw_Source_Processing_For_Audit.R"
  ),
  overwrite = FALSE
)

# Ghana Blue Economy | Isolated raw-source reproduction audit
# Place this file beside Final_Raw_Source_Processing_For_Audit.R in your
# OneDrive/Desktop/blue economy folder and run this script in RStudio.
# It NEVER writes into the original Blue_Economy_R_Results outputs.

library(data.table)
project_dir <- file.path(Sys.getenv("OneDrive"), "Desktop", "blue economy")
main_output <- file.path(project_dir, "Blue_Economy_R_Results")
audit_root <- file.path(main_output, "Final_Reproducibility_Audit", "Raw_Source_Reproduction")
raw_script <- file.path(project_dir, "Final_Raw_Source_Processing_For_Audit.R")
stopifnot(dir.exists(project_dir), dir.exists(main_output), file.exists(raw_script))

# Prevent accidental execution of the source script with missing libraries.
needed <- c("data.table", "sf", "terra", "ggplot2")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install required packages before rerunning: ", paste(missing, collapse = ", "))

# Only start with a NEW audit folder; previous audits are retained.
if (dir.exists(audit_root) && length(list.files(audit_root, all.files = TRUE, no.. = TRUE))) {
  stop("Audit directory is not empty; preserve previous evidence and rename/move it before rerunning: ", audit_root)
}
dir.create(audit_root, recursive = TRUE, showWarnings = FALSE)

# Check archives and originals before beginning an expensive rerun.
original_files <- c("ghana_coastal_fishing_grid_monthly.csv",
                    "ghana_coastal_gfw_nasa_spatial_panel.csv")
stopifnot(all(file.exists(file.path(main_output, original_files))))
find_input <- function(name) {
  choices <- file.path(c(project_dir, file.path(project_dir, "Blue_Economy")), name)
  found <- choices[file.exists(choices)]
  if (!length(found)) stop("Missing raw source: ", name)
  found[1]
}
archive_names <- c(sprintf("fleet-monthly-csvs-10-v3-%d.zip", 2018:2024),
                   "World_EEZ_v12_20231025_LR.zip", "requested_files_1.tar",
                   "capture-fishery-production.csv")
archives <- vapply(archive_names, find_input, character(1))
manifest <- data.table(name = archive_names, path = archives,
                       size_bytes = as.numeric(file.info(archives)$size),
                       md5 = unname(tools::md5sum(archives)))
fwrite(manifest, file.path(audit_root, "raw_source_manifest.csv"))
writeLines(capture.output(sessionInfo()), file.path(audit_root, "source_session_info.txt"))

# Patch ONLY the hard-coded output directory assignment in a fresh copy.
source_lines <- readLines(raw_script, warn = FALSE)
old <- 'output_dir <- file.path(downloads_dir, "Blue_Economy_R_Results")'
match_line <- which(trimws(source_lines) == old)
if (length(match_line) != 1L) stop("The original output directory assignment was not uniquely located. No script executed.")
# Audited absolute path, encoded safely as an R string literal.
audit_path_literal <- encodeString(normalizePath(audit_root, winslash = "/", mustWork = TRUE), quote = '"')
source_lines[match_line] <- paste0("output_dir <- ", audit_path_literal)
patched_script <- file.path(audit_root, "raw_source_script_isolated.R")
writeLines(source_lines, patched_script)
stopifnot(grepl("Raw_Source_Reproduction", source_lines[match_line], fixed = TRUE))

cat("\nPRE-FLIGHT PASSED. Running source pipeline in isolated folder:\n", audit_root, "\n")
cat("This can take significant time and temporary disk space. Original outputs are not overwritten.\n")

# Run same pipeline. An error stops before any 'verified' label is written.
source(patched_script, echo = FALSE, chdir = FALSE)

keys <- c("date", "lat", "lon")
comparison <- list()
for (name in original_files) {
  a <- fread(file.path(main_output, name))
  b <- fread(file.path(audit_root, name))
  stopifnot(all(keys %in% names(a)), all(keys %in% names(b)))
  if (anyDuplicated(a, by = keys) || anyDuplicated(b, by = keys)) {
    stop("Duplicate date-lat-lon keys found in ", name, "; stop and investigate")
  }
  original_n <- nrow(a)
  rebuilt_n <- nrow(b)
  missing_in_rebuilt <- nrow(fsetdiff(a[, ..keys], b[, ..keys]))
  extra_in_rebuilt <- nrow(fsetdiff(b[, ..keys], a[, ..keys]))
  shared <- intersect(names(a), names(b))
  missing_cols <- setdiff(names(a), names(b))
  new_cols <- setdiff(names(b), names(a))
  setkeyv(a, keys)
  setkeyv(b, keys)
  if (missing_in_rebuilt || extra_in_rebuilt) {
    mismatch <- NA_integer_
    max_delta <- NA_real_
  } else {
    # Equal keys and unique order: data.table keyed sorting aligns rows.
    bad <- integer(length(setdiff(shared, keys)))
    diffs <- numeric(length(bad))
    for (i in seq_along(bad)) {
      col <- setdiff(shared, keys)[i]
      x <- a[[col]]
      y <- b[[col]]
      if (is.numeric(x) && is.numeric(y)) {
        missing_different <- xor(is.na(x), is.na(y))
        both <- !is.na(x) & !is.na(y)
        delta <- abs(x[both] - y[both])
        bad[i] <- sum(missing_different) + sum(!is.finite(delta) | delta > 1e-8)
        diffs[i] <- if (length(delta)) max(delta, na.rm = TRUE) else 0
      } else {
        bad[i] <- sum(xor(is.na(x), is.na(y))) +
          sum(x[!is.na(x) & !is.na(y)] != y[!is.na(x) & !is.na(y)])
        diffs[i] <- NA_real_
      }
    }
    mismatch <- sum(bad)
    max_delta <- if (all(is.na(diffs))) NA_real_ else max(diffs, na.rm = TRUE)
  }
  comparison[[length(comparison) + 1L]] <- data.table(
    file = name, original_rows = original_n, regenerated_rows = rebuilt_n,
    missing_keys = missing_in_rebuilt, extra_keys = extra_in_rebuilt,
    mismatched_values = mismatch,
    max_numeric_difference = max_delta,
    missing_columns = paste(missing_cols, collapse = "; "),
    added_columns = paste(new_cols, collapse = "; ")
  )
}
report <- rbindlist(comparison)
fwrite(report, file.path(audit_root, "raw_source_comparison.csv"))
print(report)
passed <- all(report$missing_keys == 0L & report$extra_keys == 0L &
                report$mismatched_values == 0L &
                report$original_rows == report$regenerated_rows &
                report$missing_columns == "" & report$added_columns == "")
if (passed) {
  writeLines("PASS: Intermediate GFW and NASA-matched files reproduced from raw archives within stated numeric tolerance (1e-8).",
             file.path(audit_root, "RAW_SOURCE_AUDIT_PASS.txt"))
  cat("\nPASS: BOTH INTERMEDIATE DATASETS REPRODUCED.\n")
} else {
  cat("\nREVIEW REQUIRED: DIFFERENCES FOUND. Inspect raw_source_comparison.csv.\n")
}
