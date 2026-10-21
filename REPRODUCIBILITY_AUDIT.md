# Reproduction audit record

The following results were reported from executed reruns in RStudio on Windows 11, R 4.5.2. They are not results of a fresh execution in this GitHub environment.

| Stage | Compared items | Result |
| --- | --- | --- |
| Source GFW aggregated intermediate | 67,310 records | 0 missing/extra keys; 0 value mismatches |
| Source GFW–NASA intermediate | 65,258 records | 0 missing/extra keys; 0 value mismatches |
| Fixed grid-month panel | 99,204 rows × 13 columns | 0 mismatches over 10 compared columns |
| Geographic Phase 24 models | 5,000 records × 3 model predictions | maximum error < 5e-13 |
| Geographic Phase 24 pooled MAE/RMSE/WAPE | 3 models | numerically identical within machine precision |
| Phase 26 sensitivity | 9 comparisons | 9/9 bootstrap intervals include zero in both original and recomputed results |
| Phase 29 direct comparison | 3 block widths | 3/3 bootstrap intervals include zero in both original and recomputed results |

**Original script correction:** An isolated raw-source rerun originally stopped due to a masked `unzip()` and later a `data.table` single-symbol filter. These were corrected in an audit runner; the source-derived intermediate outputs were compared only after verifying that both files existed and that a two-row comparison table had nonzero input records. An earlier empty-table PASS was invalid and must not be used as evidence.

**Statistical qualification:** Spatial bootstrap intervals are exploratory and do not confirm model equivalence. Chronological and geographic validation use different training partitions, so the difference between validation procedures is descriptive, not a causal effect of spatial separation.

**Evidence status:** Audit logs and scripts should be added under `audits/` and `scripts/` before designating a final reproducibility archive. File inventories are not a substitute for executable code.
