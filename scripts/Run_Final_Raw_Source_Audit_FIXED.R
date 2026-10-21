# FINAL RAW-SOURCE REPRODUCTION AUDIT — CORRECTED
# Reprocess the original GFW ZIP, EEZ ZIP and NASA TAR into a new, isolated folder.
# Original research outputs and the earlier failed audit remain untouched.
# This script stops on ANY processing or verification failure; no vacuous PASS.

library(data.table)

project_dir <- file.path(Sys.getenv("OneDrive"), "Desktop", "blue economy")
main_output <- file.path(project_dir, "Blue_Economy_R_Results")
raw_script <- file.path(project_dir, "Final_Raw_Source_Processing_For_Audit.R")
stopifnot(dir.exists(project_dir), dir.exists(main_output), file.exists(raw_script))

required_packages <- c("data.table", "sf", "terra", "ggplot2")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) stop("Missing packages: ", paste(missing_packages, collapse = ", "))

# A distinct folder ensures the previous false-PASS audit is not treated as valid.
audit_root <- file.path(main_output, "Final_Reproducibility_Audit", "Raw_Source_Reproduction_FIXED")
if (dir.exists(audit_root) && length(list.files(audit_root, all.files = TRUE, no.. = TRUE))) {
  stop("Audit folder already has content; preserve it and use a new folder name: ", audit_root)
}
dir.create(audit_root, recursive = TRUE, showWarnings = FALSE)

names_to_compare <- c("ghana_coastal_fishing_grid_monthly.csv",
                      "ghana_coastal_gfw_nasa_spatial_panel.csv")
stopifnot(all(file.exists(file.path(main_output, names_to_compare))))

find_input <- function(name) {
  candidates <- file.path(c(project_dir, file.path(project_dir, "Blue_Economy")), name)
  hits <- candidates[file.exists(candidates)]
  if (!length(hits)) stop("Missing raw source: ", name)
  hits[1L]
}
archive_names <- c(sprintf("fleet-monthly-csvs-10-v3-%d.zip", 2018:2024),
                   "World_EEZ_v12_20231025_LR.zip", "requested_files_1.tar",
                   "capture-fishery-production.csv")
archives <- vapply(archive_names, find_input, character(1))
manifest <- data.table(name = archive_names, path = unname(archives),
                       size_bytes = as.numeric(file.info(archives)$size),
                       md5 = unname(tools::md5sum(archives)))
stopifnot(nrow(manifest) == length(archive_names),
          all(!is.na(manifest$size_bytes)),
          all(nchar(manifest$md5) == 32L))
fwrite(manifest, file.path(audit_root, "raw_source_manifest.csv"))
writeLines(capture.output(sessionInfo()), file.path(audit_root, "source_session_info.txt"))

# Patch the copy ONLY: redirect output and resolve masked unzip function.
source_lines <- readLines(raw_script, warn = FALSE)
original_assignment <- 'output_dir <- file.path(downloads_dir, "Blue_Economy_R_Results")'
assignment_hits <- which(trimws(source_lines) == original_assignment)
if (length(assignment_hits) != 1L) stop("Cannot identify one unique output directory assignment")
source_lines[assignment_hits] <- paste0("output_dir <- ",
  encodeString(normalizePath(audit_root, winslash = "/", mustWork = TRUE), quote = '"'))
# Replace all unqualified unzip() calls, avoiding already namespaced utils::unzip().
source_lines <- gsub("(?<![[:alnum:]_.:])unzip\\(", "utils::unzip(", source_lines, perl = TRUE)
# terra can mask data.table::shift; preserve data.table lag semantics.
source_lines <- gsub("(?<![[:alnum:]_.:])shift\\(", "data.table::shift(", source_lines, perl = TRUE)
if (any(grepl("(?<![[:alnum:]_.:])unzip\\(", source_lines, perl = TRUE))) {
  stop("Unqualified unzip() reference remains")
}
patched_file <- file.path(audit_root, "raw_source_script_isolated_fixed.R")
writeLines(source_lines, patched_file)
parse(file = patched_file)  # Syntax check before executing

cat("\nRUNNING ISOLATED RAW-SOURCE PROCESSING\n", audit_root, "\n")
# An error in source() stops the script immediately. The comparison will NOT run.
source(patched_file, echo = FALSE, chdir = FALSE, local = new.env(parent = globalenv()))

# Check the two outputs were genuinely written, and nonempty.
rebuilt_paths <- file.path(audit_root, names_to_compare)
if (!all(file.exists(rebuilt_paths))) {
  stop("Processing finished without all required outputs: ",
       paste(names_to_compare[!file.exists(rebuilt_paths)], collapse = ", "))
}
if (any(is.na(file.info(rebuilt_paths)$size) | file.info(rebuilt_paths)$size < 100L)) {
  stop("One or more regenerated outputs are empty or unexpectedly small")
}

keys <- c("date", "lat", "lon")
reports <- vector("list", length(names_to_compare))
for (i in seq_along(names_to_compare)) {
  name <- names_to_compare[i]
  original <- fread(file = file.path(main_output, name))
  regenerated <- fread(file = file.path(audit_root, name))
  if (!nrow(original) || !nrow(regenerated)) stop("An input contains no records: ", name)
  if (!all(keys %in% names(original)) || !all(keys %in% names(regenerated))) {
    stop("Missing date/lat/lon key in ", name)
  }
  if (anyDuplicated(original, by = keys) || anyDuplicated(regenerated, by = keys)) {
    stop("Duplicate grid-month key in ", name)
  }
  missing_keys <- nrow(fsetdiff(original[, ..keys], regenerated[, ..keys]))
  extra_keys <- nrow(fsetdiff(regenerated[, ..keys], original[, ..keys]))
  old_only <- setdiff(names(original), names(regenerated))
  new_only <- setdiff(names(regenerated), names(original))
  mismatch_count <- NA_integer_
  largest_delta <- NA_real_
  if (missing_keys == 0L && extra_keys == 0L) {
    setkeyv(original, keys)
    setkeyv(regenerated, keys)
    shared <- setdiff(intersect(names(original), names(regenerated)), keys)
    if (!length(shared)) stop("No measurement columns to compare: ", name)
    mismatches <- integer(length(shared))
    deltas <- rep(NA_real_, length(shared))
    for (j in seq_along(shared)) {
      x <- original[[shared[j]]]
      y <- regenerated[[shared[j]]]
      if (is.numeric(x) && is.numeric(y)) {
        unequal_missing <- xor(is.na(x), is.na(y))
        present <- !is.na(x) & !is.na(y)
        delta <- abs(x[present] - y[present])
        mismatches[j] <- sum(unequal_missing) + sum(!is.finite(delta) | delta > 1e-8)
        deltas[j] <- if (length(delta)) max(delta) else 0
      } else {
        unequal_missing <- xor(is.na(x), is.na(y))
        present <- !is.na(x) & !is.na(y)
        mismatches[j] <- sum(unequal_missing) + sum(x[present] != y[present])
      }
    }
    mismatch_count <- sum(mismatches)
    if (any(is.finite(deltas))) largest_delta <- max(deltas[is.finite(deltas)])
  }
  reports[[i]] <- data.table(file = name,
                             original_rows = nrow(original),
                             regenerated_rows = nrow(regenerated),
                             missing_keys = missing_keys,
                             extra_keys = extra_keys,
                             mismatched_values = mismatch_count,
                             max_numeric_difference = largest_delta,
                             missing_columns = paste(old_only, collapse = "; "),
                             added_columns = paste(new_only, collapse = "; "))
}
report <- rbindlist(reports)
if (nrow(report) != length(names_to_compare)) stop("Incomplete comparison report")
fwrite(report, file.path(audit_root, "raw_source_comparison.csv"))
print(report)

passed <- isTRUE(
  nrow(report) == 2L &&
  all(report$original_rows > 0L) &&
  all(report$original_rows == report$regenerated_rows) &&
  all(report$missing_keys == 0L) &&
  all(report$extra_keys == 0L) &&
  all(!is.na(report$mismatched_values)) &&
  all(report$mismatched_values == 0L) &&
  all(report$missing_columns == "") &&
  all(report$added_columns == "")
)
if (!passed) stop("REVIEW REQUIRED: differences detected. See raw_source_comparison.csv")
writeLines("PASS: Both intermediate source-derived datasets independently regenerated and matched originals (numeric tolerance 1e-8).",
           file.path(audit_root, "RAW_SOURCE_AUDIT_PASS.txt"))
cat("\nPASS: BOTH INTERMEDIATE DATASETS REPRODUCED.\n")