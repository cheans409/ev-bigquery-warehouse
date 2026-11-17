# Scan benchmark

Two statements in BigQuery job `job_ifi8xOJgGZGS4yv-6KHaxGkrr1aa` (US) completed successfully. Both group vehicles by make for King County, WA, model years 2021–2024. The baseline normalizes make, county, and state in the same way as the materialized fact table.

| Query source | Bytes processed shown by console |
|---|---:|
| Existing staging view | 10.05 MB |
| Corrected partitioned fact table | 4.19 MB |

Observed scan reduction: approximately **58.3%**, calculated from the rounded console values as `(10.05 - 4.19) / 10.05`. SQL is in `sql/03_benchmark.sql`.

This is one run on one snapshot. Exact byte counts, bytes billed, cache-hit fields, and slot time were not exported. Do not present this as a 58.3% reduction in the bill, a latency improvement, or an isolated estimate of clustering benefit. Partition pruning and materialization can both affect this comparison. Small table partitions may see limited clustering benefits.

The warehouse's source-row and dimension-join checks passed. A separate cell-by-cell comparison of the two benchmark result sets has not been recorded; use `sql/04_validate_benchmark.sql` when reproducing the benchmark. For a rigorous performance study, disable cached results, verify result equality, repeat runs, and record job metrics with workload and table sizes.
