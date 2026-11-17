# Source contract and modeling decisions

Input: `raw_ev.stg_ev_population`, an existing cleaned view over the uploaded source.

| Field | Expected BigQuery type | Use |
|---|---|---|
| dol_vehicle_id | INT64 | Unique non-null snapshot vehicle identifier |
| model_year | INT64 | Vehicle cohort and partition key |
| county, city, state | STRING | Geography; trim blanks and uppercase state |
| postal_code | STRING | Preserve existing string ZIP representation |
| make, model | STRING | Trim and uppercase for consistent grouping |
| ev_type | STRING | Existing BEV/PHEV classification |
| electric_range_cleaned | INT64 | Positive values retained; otherwise NULL |
| cafv_eligibility | STRING | Preserve supplied classification |
| electric_utility | STRING | Preserve complete supplied utility label |

The upstream view also contains `vin`, which this project does not copy into the new warehouse. The build asserts vehicle-ID uniqueness and non-nullness before creating the fact table. It does not silently deduplicate conflicting rows.

Vehicle configuration grain: make + model + EV type. Model year and range remain fact attributes; a configuration key is not a unique trim/battery specification.

Location grain: county + city + state + postal code + complete electric-utility label. This is a location/utility combination, not a unique ZIP code or validated utility service territory. Empty county/city strings become NULL. Null values are retained in structured key serialization.

The fact table contains all source states. All three reporting marts filter to WA. The source includes 789 rows outside the WA filter, which must not enter Washington-only denominators.

Limitations: no registration event timestamp, historical stock series, population denominator, gasoline fleet denominator, charger inventory, energy consumption, or charging behavior is modeled. Utility labels may list multiple providers and cannot be summed as individual-provider service counts without an explicit attribution rule. CAFV eligibility is a supplied label, not personalized tax advice. The build depends on the existing staging view; it does not recreate ingestion or establish the original snapshot extraction date.
