# Geographic exclusion-buffer sensitivity (2026 update)

This folder was added to the repository **after** Zenodo release v3.7.8 (DOI: 10.5281/zenodo.23542637). The archived v3.7.8 release does not contain these results.

Files here are model summary results and **R-computed** spatial-cell bootstrap limits supplied by the researcher. The pooled and fold metrics were independently recomputed from the separately supplied 45,000-row prediction CSV in a previous research audit; the exact R bootstrap random draws were not independently reproduced. The original prediction file and all fold-level records are not yet deposited in this GitHub subfolder.

Three exclusion buffers (0.10°, 0.20°, 0.30°), four geographic folds, three model configurations, 5,000 matched test observations and 1,042 spatial cells per comparison.

Chlorophyll-associated MAE gain is Historical_CC MAE minus Environmental_CC MAE. Reported gains:
- 0.10°: -0.03911023; 95% cell-cluster bootstrap CI [-0.11262220, 0.02708234]
- 0.20°: -0.05579011; 95% cell-cluster bootstrap CI [-0.13173773, 0.01344908]
- 0.30°: -0.05304758; 95% cell-cluster bootstrap CI [-0.12708727, 0.01807021]

All intervals include zero. These are sensitivity checks, not a new independent external validation, nor evidence of an ecological absence of effect. Neighboring-cell spatial dependence may not be completely captured by cell-level bootstrap intervals. Refer to earlier spatial-block bootstrap sensitivity results for complementary assessment. Full source input provenance from the interactive R session still requires an explicit execution manifest.
