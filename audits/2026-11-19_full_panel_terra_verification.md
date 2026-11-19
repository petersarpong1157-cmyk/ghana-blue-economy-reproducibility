# Full-panel MODIS-Aqua / R-terra extraction verification — 19 November 2026

## Status and provenance
This document records a researcher-executed audit in RStudio on Windows, reported in the saved console output on 19 November 2026. It is **not** a GitHub Actions run, an independently audited external replication, or a Turnitin report.

## Verified collection and panel
- Source observations: Ghana AIS–NASA spatial panel, `ghana_coastal_gfw_nasa_spatial_panel.csv`.
- R source collection: **80 unique monthly MODIS-Aqua NetCDF files**. Another **80 byte-identical file copies** were found and excluded by MD5 hash.
- Extractor: `terra::extract()` at the archived fishing grid-cell center points, using the current R/terra environment.
- Months audited: **80 / 80**.
- Archived source-panel records compared: **65,258**.
- Numeric discrepancies exceeding `1e-5` mg/m³: **0**.
- Differences in present/missing classification: **0**.
- Diagnostic file `terra_neighbor_pixel_diagnostics.csv` was empty because no mismatches were identified.

## Why the check matters
An exploratory Python raster extraction using a different pixel-selection convention had produced 1,177 numeric disagreements and 107 present/missing differences near the 3.25°W and 2.75°W longitude boundaries. The 80-month full-panel R/terra rerun instead reproduced the **archived** values and missingness exactly within the specified tolerance. The independent Python method should therefore be treated as an *alternative pixel-addressing sensitivity*, not as evidence that the R-derived archive is erroneous.

## Scientific limits
- This confirms consistency with **the current R/terra extraction procedure**; it does not independently identify the historical R/terra package version.
- A center-point extraction is not equivalent to chlorophyll spatial aggregation over a 0.1° grid cell. The separate within-cell-average and lag comparisons are **exploratory** and use a different evaluation design from the paper's primary geographically held-out R models.
- The outcome is **AIS-derived apparent fishing hours**, not catch, biomass, or complete fishing activity.
- Original geographically held-out estimates and uncertainty statements were not recomputed by this audit.
- Source NASA, Global Fishing Watch and Marine Regions data remain governed by their providers' distribution terms.

## Original RStudio evidence
The verification script wrote files in:
`C:/Users/peter/OneDrive/Desktop/blue economy/Terra_Pixel_Reconciliation_2026/`

- `terra_verification_summary.csv`
- `terra_monthly_comparison.csv`
- `terra_all_mismatched_records.csv` (no mismatches)
- `netcdf_discovered_files.csv`
- `netcdf_duplicate_month_audit.csv`
- `netcdf_selected_80_files.csv`
- `R_terra_session_info.txt`

The numerical summary and these filenames come from the user's executed RStudio transcript. This Markdown record does **not** stand in for depositing all machine-generated evidence.

## Manuscript version
The coauthor has approved the revised manuscript entitled **"Satellite Data Availability and Spatial Validation of AIS-Derived Fishing Effort Models: Evidence from Ghanaian Waters"** for further submission preparation to *Applied Environmental Research*. Coauthor approval is not journal acceptance, and this record does not certify an official similarity score. Please cite the specific frozen Zenodo release used for analysis rather than treating an untagged `main` branch update as an archival DOI.

Last verified: 2026-11-19.
