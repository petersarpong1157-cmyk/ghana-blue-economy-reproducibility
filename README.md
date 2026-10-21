# Ghana Blue Economy: Reproducibility materials

**Research:** Satellite observation gaps, training-sample selection, and geographic reliability of AIS-derived apparent fishing-effort prediction in Ghanaian waters.

**Authors:** Peter Sarpong (independent researcher, Gaithersburg, Maryland, USA) and Monica Verma (Associate Professor, Karnavati University, Gujarat, India).

## Research scope

The analysis is restricted to Ghana's EEZ intersected with the NASA extraction rectangle (3–6° N; 4° W–2° E), rather than the entire Ghana EEZ. The data are Global Fishing Watch v3 AIS-derived *apparent fishing hours*, not measured fish catch, complete fishing activity, or evidence of causal ecological effects.

Monthly period: January 2018 to December 2024. The primary retrospective evaluation uses 2023; the 2024 analysis was inspected and is not an untouched independent holdout.

## Main results

- Fixed calendar: 99,204 grid-months (1,181 grid cells × 84 months).
- Observed GFW grid-months: 67,310; absent GFW observations: 31,894 (absence is **not** interpreted as zero fishing).
- GFW–NASA spatially matched source rows: 65,258.
- Common 2023 model comparison set: 5,000 observations.
- Geographic validation with 0.20° exclusion buffer: historical complete-case MAE 7.413474, environmental complete-case MAE 7.469264, expanded-history MAE 7.391434.
- Temporal chlorophyll-associated paired MAE gain: +0.04130955 hours/grid-month; geographic gain: -0.05579011; contrast: +0.09709966. Paired spatial-block bootstrap confidence intervals for the contrast include zero at 0.25°, 0.5°, and 1.0° block widths.

**Interpretation:** No reliably detectable improvement attributable to the additional chlorophyll predictor under the examined protocols, nor a reliably detectable difference between the temporal and geographic chlorophyll-associated gains. Non-significance does not establish equivalence, the absence of ecological relationships, or that model configurations have identical performance.

## Reproducibility checks performed

1. Reprocessed original seven annual GFW source ZIPs and 80 available NASA monthly NetCDF files in an isolated output directory. Both resulting intermediate CSVs matched the original rows, keys, columns and values: GFW 67,310; GFW–NASA 65,258.
2. Rebuilt the 99,204-row fixed panel from the intermediate files; zero discrepancies across ten compared variables.
3. Refit all twelve Phase 24 geographic Random Forest model-fold combinations and matched the 15,000 saved predictions to numerical precision (maximum absolute discrepancy < 5e-13).
4. Recomputed Phase 26 and Phase 29 paired statistics and bootstraps from saved predictions; five point estimates matched within 4e-9 and uncertainty conclusions agreed in 12/12 sensitivity comparisons.

These are **reruns in the researcher's Windows/R environment**, not independently run on another institution's computer. Some later-phase scripts and large source archives are not yet deposited here; this repository must not be described as a complete one-command reproduction until all dependencies and executable code are present.

## Data provenance and availability

- Global Fishing Watch fleet v3 monthly CSV archives, 2018–2024 (AIS-derived activity).
- Marine Regions World EEZ v12 boundary, Ghana MRGID 8400.
- NASA Aqua MODIS monthly Level-3 chlorophyll (80 NetCDF files in the supplied order; four source months missing).
- Missing NASA raster values are retained as missing; no filling or zero imputation.

Consult the data providers' applicable licensing and redistribution rules before publishing original or derived data files. Do not redistribute the full archives via this repository by default.

## Software

Recorded audit environment: Windows 11; R 4.5.2; data.table 1.17.8; ranger 0.18.0; sf and terra were also used for spatial preprocessing. See scripts and audit records as they are added.

## Publication and citation

The manuscript is being prepared for journal submission. Do **not** infer that journal acceptance or publication has occurred. The archived GitHub release **v3.7.8** is available on Zenodo: https://doi.org/10.5281/zenodo.23542637. This DOI identifies the **v3.7.8 snapshot**, not subsequent changes on `main`. Future revisions should be cited using their own archived version when available.

## License

The repository's original software code and project-authored documentation are distributed under the [MIT License](LICENSE), to the extent the contributors hold the necessary rights. This license does **not** grant rights to any third-party Global Fishing Watch, NASA, Marine Regions, or other externally sourced datasets or materials. Their original terms remain applicable.
