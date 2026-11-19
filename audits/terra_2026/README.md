# Terra full-panel verification: supporting files

This folder contains a CSV summary transcribed from the researcher's **19 November 2026 RStudio console output**. It accompanies:

- [Verification R code](../../scripts/Verify_Original_Terra_Pixel_Extraction_FIXED.R)
- [Dated methods and limitations](../2026-11-19_full_panel_terra_verification.md)

## Result
80 monthly source NetCDF files were selected after byte-identical copies were deduplicated. The R/terra extraction reproduced 65,258 archived observations, with no numeric discrepancies above the 1e-5 mg/m³ tolerance and no presence/missingness mismatches.

## Data and evidence provenance
`verification_summary_from_console.csv` is **transcribed from the user's executed console output**, not represented as an uploaded original result file.

The original machine-generated files remain on the researcher's Windows computer under:
`C:/Users/peter/OneDrive/Desktop/blue economy/Terra_Pixel_Reconciliation_2026/`

Original files that can be deposited in a future follow-up (after removing user-specific absolute paths where necessary):
- `terra_verification_summary.csv`
- `terra_monthly_comparison.csv`
- `netcdf_selected_80_files.csv` (contains local paths; redact before public release)
- `R_terra_session_info.txt`
- `netcdf_duplicate_month_audit.csv` (contains local paths; redact before public release)
- `terra_all_mismatched_records.csv` (no mismatches)
- `terra_neighbor_pixel_diagnostics.csv` (empty because zero mismatches)

No raw NASA, Global Fishing Watch, or Marine Regions source data have been added. The manuscript and new EEZ figure have **not** been uploaded in this change. The R script is specific to the original researcher's directory and requires locally obtained licensed source data.

This is a repository update, **not a new versioned Zenodo release**.
