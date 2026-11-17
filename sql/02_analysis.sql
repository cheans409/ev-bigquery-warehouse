-- Washington-only reporting. Model-year cohorts are not annual sales.
SELECT * FROM `raw_ev.portfolio_mart_make_cohort`
WHERE model_year BETWEEN 2020 AND 2025 AND make_rank <= 5
ORDER BY model_year, make_rank, make;

SELECT * FROM `raw_ev.portfolio_mart_county`
ORDER BY vehicles DESC;

SELECT * FROM `raw_ev.portfolio_mart_range_coverage`
ORDER BY model_year, ev_type;

-- Utility labels may contain multiple providers. Keep each full label intact;
-- these are vehicle counts, not measured electricity demand or service assignments.
SELECT COALESCE(electric_utility, 'Unknown') AS utility_label,
  COUNT(*) AS vehicles, COUNTIF(ev_type='BEV') AS bev_vehicles
FROM `raw_ev.portfolio_fct_ev_population`
WHERE state='WA' GROUP BY utility_label ORDER BY vehicles DESC;
