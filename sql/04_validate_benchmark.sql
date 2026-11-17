-- Read-only equality check. Expected result: zero difference rows.
WITH baseline AS (
  SELECT UPPER(TRIM(make)) AS make, COUNT(*) AS vehicles
  FROM `raw_ev.stg_ev_population`
  WHERE model_year BETWEEN 2021 AND 2024
    AND NULLIF(TRIM(county),'')='King' AND UPPER(TRIM(state))='WA'
  GROUP BY make
), optimized AS (
  SELECT make, COUNT(*) AS vehicles
  FROM `raw_ev.portfolio_fct_ev_population`
  WHERE model_year BETWEEN 2021 AND 2024 AND county='King' AND state='WA'
  GROUP BY make
)
SELECT * FROM (SELECT * FROM baseline EXCEPT DISTINCT SELECT * FROM optimized)
UNION ALL
SELECT * FROM (SELECT * FROM optimized EXCEPT DISTINCT SELECT * FROM baseline);
