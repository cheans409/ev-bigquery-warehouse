-- Read-only audit of the existing warehouse; does not modify source objects.
SELECT 'raw' AS layer, COUNT(*) AS row_count,
  COUNT(DISTINCT dol_vehicle_id) AS distinct_ids FROM `raw_ev.raw_ev_population`
UNION ALL
SELECT 'staging', COUNT(*), COUNT(DISTINCT dol_vehicle_id) FROM `raw_ev.stg_ev_population`
UNION ALL
SELECT 'old_fact', COUNT(*), COUNT(DISTINCT registration_id) FROM `raw_ev.fct_ev_registrations`
UNION ALL
SELECT 'old_location', COUNT(*), COUNT(DISTINCT location_id_pk) FROM `raw_ev.dim_location`;
