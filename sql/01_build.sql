-- Run in project project-55002890-8a80-4708-ad0, location US.
-- New portfolio_* objects preserve the existing warehouse.
ASSERT (SELECT COUNT(*) = COUNT(DISTINCT dol_vehicle_id)
  FROM `raw_ev.stg_ev_population`) AS 'Source vehicle IDs must be unique and non-null';

CREATE OR REPLACE TABLE `raw_ev.portfolio_fct_ev_population`
PARTITION BY RANGE_BUCKET(model_year, GENERATE_ARRAY(1990, 2040, 1))
CLUSTER BY state, county, make
OPTIONS(description='Current EV population snapshot; one row per DOL vehicle ID. Model year is not registration year.') AS
SELECT dol_vehicle_id AS vehicle_id, model_year,
  NULLIF(TRIM(county), '') AS county, NULLIF(TRIM(city), '') AS city,
  UPPER(TRIM(state)) AS state, postal_code,
  UPPER(TRIM(make)) AS make, UPPER(TRIM(model)) AS model, ev_type,
  IF(electric_range_cleaned > 0, electric_range_cleaned, NULL) AS electric_range_miles,
  cafv_eligibility, electric_utility,
  TO_HEX(SHA256(TO_JSON_STRING(STRUCT(UPPER(TRIM(make)) AS make,
    UPPER(TRIM(model)) AS model, ev_type AS ev_type)))) AS vehicle_config_key,
  TO_HEX(SHA256(TO_JSON_STRING(STRUCT(NULLIF(TRIM(county),'') AS county,
    NULLIF(TRIM(city),'') AS city, UPPER(TRIM(state)) AS state,
    postal_code AS postal_code, electric_utility AS electric_utility)))) AS location_key
FROM `raw_ev.stg_ev_population`;

CREATE OR REPLACE TABLE `raw_ev.portfolio_dim_vehicle` AS
SELECT DISTINCT vehicle_config_key, make, model, ev_type
FROM `raw_ev.portfolio_fct_ev_population`;

CREATE OR REPLACE TABLE `raw_ev.portfolio_dim_location` AS
SELECT DISTINCT location_key, county, city, state, postal_code, electric_utility
FROM `raw_ev.portfolio_fct_ev_population`;

ASSERT (SELECT COUNT(*) = COUNT(DISTINCT vehicle_id) FROM `raw_ev.portfolio_fct_ev_population`)
  AS 'Fact grain must be one vehicle';
ASSERT (SELECT COUNT(*) FROM `raw_ev.portfolio_fct_ev_population`) =
  (SELECT COUNT(*) FROM `raw_ev.stg_ev_population`) AS 'All source rows preserved';
ASSERT (SELECT COUNT(*) = COUNT(DISTINCT location_key) FROM `raw_ev.portfolio_dim_location`)
  AS 'Location keys must be unique';
ASSERT (SELECT COUNT(*) = COUNT(DISTINCT vehicle_config_key) FROM `raw_ev.portfolio_dim_vehicle`)
  AS 'Vehicle configuration keys must be unique';
ASSERT (SELECT COUNT(*) FROM `raw_ev.portfolio_fct_ev_population` f
  JOIN `raw_ev.portfolio_dim_location` l USING(location_key)
  JOIN `raw_ev.portfolio_dim_vehicle` v USING(vehicle_config_key)) =
  (SELECT COUNT(*) FROM `raw_ev.portfolio_fct_ev_population`) AS 'Dimension joins preserve grain';

CREATE OR REPLACE VIEW `raw_ev.portfolio_mart_make_cohort` AS
WITH counts AS (
  SELECT model_year, make, COUNT(*) AS vehicles
  FROM `raw_ev.portfolio_fct_ev_population` WHERE state='WA'
  GROUP BY model_year, make
)
SELECT *, SUM(vehicles) OVER(PARTITION BY model_year) AS cohort_vehicles,
  ROUND(100 * SAFE_DIVIDE(vehicles, SUM(vehicles) OVER(PARTITION BY model_year)), 2) AS cohort_share_pct,
  DENSE_RANK() OVER(PARTITION BY model_year ORDER BY vehicles DESC) AS make_rank
FROM counts;

CREATE OR REPLACE VIEW `raw_ev.portfolio_mart_county` AS
SELECT COALESCE(county, 'Unknown') AS county, COUNT(*) AS vehicles,
  COUNTIF(ev_type='BEV') AS bev_vehicles, COUNTIF(ev_type='PHEV') AS phev_vehicles,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ev_type='BEV'),COUNT(*)),2) AS bev_share_pct,
  ROUND(100 * SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER()),2) AS wa_fleet_share_pct
FROM `raw_ev.portfolio_fct_ev_population` WHERE state='WA' GROUP BY county;

CREATE OR REPLACE VIEW `raw_ev.portfolio_mart_range_coverage` AS
SELECT model_year, ev_type, COUNT(*) AS vehicles,
  COUNT(electric_range_miles) AS known_range_vehicles,
  ROUND(100 * SAFE_DIVIDE(COUNT(electric_range_miles),COUNT(*)),2) AS range_coverage_pct,
  ROUND(AVG(electric_range_miles),1) AS mean_known_range_miles
FROM `raw_ev.portfolio_fct_ev_population` WHERE state='WA' GROUP BY model_year, ev_type;

SELECT 'PASS: warehouse built and all five integrity assertions passed' AS status,
  COUNT(*) AS vehicles FROM `raw_ev.portfolio_fct_ev_population`;
