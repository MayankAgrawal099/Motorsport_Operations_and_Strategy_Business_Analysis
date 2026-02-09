/*
====================================================
 File: 02_data_validation.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Validate raw data after import
   - Perform sanity checks on row counts, nulls, and value ranges
   - Ensure data is safe to use for analytical modeling
====================================================
*/

-- ==================================================
-- ROW COUNT CHECKS
-- ==================================================

SELECT 'raw_races' AS table_name, COUNT(*) AS row_count FROM raw_races;
SELECT 'raw_results' AS table_name, COUNT(*) AS row_count FROM raw_results;
SELECT 'raw_lap_times' AS table_name, COUNT(*) AS row_count FROM raw_lap_times;
SELECT 'raw_pit_stops' AS table_name, COUNT(*) AS row_count FROM raw_pit_stops;
SELECT 'raw_constructors' AS table_name, COUNT(*) AS row_count FROM raw_constructors;
SELECT 'raw_status' AS table_name, COUNT(*) AS row_count FROM raw_status;

-- Expectation:
-- All tables should return non-zero row counts.

-- ==================================================
-- KEY NULL CHECKS
-- ==================================================

-- Races should always have a raceId and year
SELECT COUNT(*) AS null_race_id
FROM raw_races
WHERE raceId IS NULL;

SELECT COUNT(*) AS null_year
FROM raw_races
WHERE year IS NULL;

-- Results must reference race, constructor, and status
SELECT COUNT(*) AS missing_core_refs
FROM raw_results
WHERE raceId IS NULL
   OR constructorId IS NULL
   OR statusId IS NULL;

-- ==================================================
-- VALUE RANGE SANITY CHECKS
-- ==================================================

-- Year range sanity
SELECT MIN(year) AS min_year, MAX(year) AS max_year
FROM raw_races;

-- Lap time sanity (milliseconds)
SELECT
    MIN(milliseconds) AS min_lap_time_ms,
    MAX(milliseconds) AS max_lap_time_ms
FROM raw_lap_times;

-- Pit stop time sanity (milliseconds)
SELECT
    MIN(milliseconds) AS min_pit_time_ms,
    MAX(milliseconds) AS max_pit_time_ms
FROM raw_pit_stops;

-- ==================================================
-- POINTS & POSITION CHECKS
-- ==================================================

-- Points should never be negative
SELECT COUNT(*) AS negative_points_count
FROM raw_results
WHERE points < 0;

-- Position order should be positive when present
SELECT COUNT(*) AS invalid_position_order
FROM raw_results
WHERE positionOrder <= 0
  AND positionOrder IS NOT NULL;

-- ==================================================
-- STATUS DISTRIBUTION CHECK
-- ==================================================

-- Review status categories for DNF logic
SELECT status, COUNT(*) AS occurrences
FROM raw_status
GROUP BY status
ORDER BY occurrences DESC;

-- Expect to see values like:
-- 'Finished', '+1 Lap', 'Accident', 'Engine', etc.

-- ==================================================
-- NOTES
-- ==================================================
-- 1. Minor nulls or extreme values are expected due to DNFs.
-- 2. No rows are deleted or modified at this stage.
-- 3. If results appear unreasonable, data import should be reviewed
--    before proceeding to dimension and fact table creation.
-- ==================================================
