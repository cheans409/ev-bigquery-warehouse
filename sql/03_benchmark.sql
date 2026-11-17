-- Run these separately with cached results disabled. Compare equal results first.
-- Record actual bytes processed, bytes billed, cache_hit, and total_slot_ms.
-- Small tables may show little billing benefit due to minimum billed bytes.
-- Baseline uses the same cleaned source and normalizations as the fact table.
SELECT UPPER(TRIM(make)) AS make, COUNT(*) AS vehicles
FROM `raw_ev.stg_ev_population`
WHERE model_year BETWEEN 2021 AND 2024
  AND NULLIF(TRIM(county),'')='King' AND UPPER(TRIM(state))='WA'
GROUP BY make ORDER BY make;

SELECT make, COUNT(*) AS vehicles
FROM `raw_ev.portfolio_fct_ev_population`
WHERE model_year BETWEEN 2021 AND 2024 AND county='King' AND state='WA'
GROUP BY make ORDER BY make;
