/*
====================================================
 File: 07_final_checks.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Perform final validation before dashboarding
   - Detect anomalies, exploding joins, or broken KPIs
   - Formally freeze the analytical model
====================================================
*/

-- ==================================================
-- BASIC DATA PRESENCE CHECKS
-- ==================================================

SELECT 'dim_race' AS table_name, COUNT(*) AS row_count FROM dim_race;
SELECT 'dim_constructor' AS table_name, COUNT(*) AS row_count FROM dim_constructor;

SELECT 'fact_race_performance' AS table_name, COUNT(*) AS row_count FROM fact_race_performance;
SELECT 'fact_lap_performance' AS table_name, COUNT(*) AS row_count FROM fact_lap_performance;
SELECT 'fact_operations' AS table_name, COUNT(*) AS row_count FROM fact_operations;
SELECT 'fact_reliability' AS table_name, COUNT(*) AS row_count FROM fact_reliability;
SELECT 'fact_cost_efficiency' AS table_name, COUNT(*) AS row_count FROM fact_cost_efficiency;

-- Expectation:
-- All tables should return non-zero row counts.

-- ==================================================
-- DIMENSION CONSISTENCY CHECKS
-- ==================================================

-- Every fact race_id should exist in dim_race
SELECT COUNT(*) AS missing_race_refs
FROM fact_race_performance frp
LEFT JOIN dim_race dr
    ON frp.race_id = dr.race_id
WHERE dr.race_id IS NULL;

-- Every fact constructor_id should exist in dim_constructor
SELECT COUNT(*) AS missing_constructor_refs
FROM fact_race_performance frp
LEFT JOIN dim_constructor dc
    ON frp.constructor_id = dc.constructor_id
WHERE dc.constructor_id IS NULL;

-- Expectation:
-- Both counts should be 0.

-- ==================================================
-- KPI RANGE SANITY CHECKS
-- ==================================================

-- Points scored sanity
SELECT
    MIN(points_scored) AS min_points,
    MAX(points_scored) AS max_points
FROM fact_race_performance;

-- Cost per point sanity
SELECT
    MIN(cost_per_point) AS min_cost_per_point,
    MAX(cost_per_point) AS max_cost_per_point
FROM fact_cost_efficiency
WHERE cost_per_point IS NOT NULL;

-- Lap time sanity (milliseconds)
SELECT
    MIN(avg_lap_time_ms) AS min_avg_lap_time,
    MAX(avg_lap_time_ms) AS max_avg_lap_time
FROM fact_lap_performance;

-- Pit stop time sanity (milliseconds)
SELECT
    MIN(avg_pit_time_ms) AS min_avg_pit_time,
    MAX(avg_pit_time_ms) AS max_avg_pit_time
FROM fact_operations;

-- ==================================================
-- RELIABILITY & FAILURE CHECKS
-- ==================================================

-- DNF flag distribution
SELECT
    dnf_flag,
    COUNT(*) AS count
FROM fact_reliability
GROUP BY dnf_flag;

-- Reliability score range (from management view)
SELECT
    MIN(reliability_score) AS min_reliability,
    MAX(reliability_score) AS max_reliability
FROM vw_management_kpis;

-- Expectation:
-- Reliability scores should fall between 0 and 1.

-- ==================================================
-- JOIN EXPLOSION CHECK
-- ==================================================

-- Ensure views do not multiply rows unexpectedly
SELECT COUNT(*) FROM vw_management_kpis;
SELECT COUNT(*) FROM vw_engineering_kpis;
SELECT COUNT(*) FROM vw_operations_kpis;
SELECT COUNT(*) FROM vw_decision_tradeoffs;

-- Row counts should be within reasonable bounds
-- relative to fact table sizes.

-- ==================================================
-- NULL & EDGE CASE CHECKS
-- ==================================================

-- Check for unexpected nulls in key KPIs
SELECT COUNT(*) AS null_cost_per_point
FROM fact_cost_efficiency
WHERE points_scored > 0
  AND cost_per_point IS NULL;

SELECT COUNT(*) AS null_avg_lap_time
FROM fact_lap_performance
WHERE avg_lap_time_ms IS NULL;

-- ==================================================
-- FINAL FREEZE CONFIRMATION
-- ==================================================
-- If all checks above:
--   - return expected ranges
--   - show no missing dimension references
--   - show no join explosions
--
-- Then the data model is considered FINAL and
-- ready for dashboard consumption.
-- ==================================================
