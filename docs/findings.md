# Findings from the uploaded EV snapshot

## Geographic concentration

| County | Vehicles | Share of WA EVs | BEV share within county |
|---|---:|---:|---:|
| King | 144,257 | 48.26% | 82.80% |
| Snohomish | 37,818 | 12.65% | 84.37% |
| Pierce | 25,042 | 8.38% | 78.75% |
| Clark | 18,782 | 6.28% | 77.23% |
| Thurston | 10,985 | 3.67% | 77.47% |

King, Snohomish, and Pierce together account for approximately 69.29% of the Washington fleet. These counts can guide where to investigate charging needs first. Choosing charger locations would additionally require existing charger capacity, utilization, travel patterns, and home-charging access. Counts alone are not per-capita adoption rates or proof of unmet demand.

## Manufacturer composition

| Model-year cohort | Tesla vehicles | Tesla cohort share |
|---|---:|---:|
| 2020 | 6,811 | 56.03% |
| 2021 | 11,360 | 54.64% |
| 2022 | 14,044 | 46.56% |
| 2023 | 27,607 | 44.94% |
| 2024 | 15,287 | 31.03% |
| 2025 | 9,739 | 26.37% |

Tesla represents a smaller share of the 2025 cohort than the 2020 cohort, a difference of 29.66 percentage points. The denominator is all Washington EVs in each model-year cohort, including PHEVs. These are current-snapshot cohort shares, not historical market shares, annual sales, or a causal estimate of competitive losses.

## Range reporting is a data-quality finding

195,774 of 298,916 Washington vehicles have no positive cleaned electric-range value: 65.49%. A mean based only on the remaining records describes reported ranges, and can be strongly affected by which models were researched. The range-coverage mart therefore exposes both the count of known values and coverage percentage alongside the mean.

## Engineering finding

The old fact table had 413,338 excess rows relative to the unique vehicle count. The corrected fact table contains 299,705 rows, and joining both corrected dimensions preserves that count. This is a stronger demonstrated outcome than simply producing charts from an unvalidated table.

Source: `results/findings_export.json`, downloaded from the executed BigQuery findings job. CSVs and `findings.json` are lossless reformattings of that export.
