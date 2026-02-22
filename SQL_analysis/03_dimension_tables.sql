/*
====================================================
 File: 03_dimension_tables.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Create dimension tables for analytical modeling
   - Apply season filtering for relevant analysis period
   - Provide clean reference entities for fact tables
====================================================
*/

-- ==================================================
-- DIMENSION: RACE
-- ==================================================
-- Contains race-level context information.
-- Analysis is limited to seasons 2012–2020.
-- This dimension acts as the time and event filter
-- for all downstream fact tables.
-- ==================================================

CREATE TABLE dim_race AS
SELECT
    raceId AS race_id,
    year AS season,
    name AS track,
    date AS race_date
FROM raw_races
WHERE year BETWEEN 2012 AND 2024;

-- ==================================================
-- DIMENSION: CONSTRUCTOR (TEAM)
-- ==================================================
-- Contains team-level reference information.
-- Used to label and group performance, operations,
-- and reliability metrics at the constructor level.
-- ==================================================

CREATE TABLE dim_constructor AS
SELECT
    constructorId AS constructor_id,
    name AS team_name
FROM raw_constructors;

-- ==================================================
-- ALTER DIMENSION TABLE
-- =================================================

ALTER TABLE dim_constructor
ADD COLUMN is_core_team BOOLEAN;

UPDATE dim_constructor
SET is_core_team = CASE
    WHEN team_name IN (
        'Red Bull',
        'Mercedes',
        'Ferrari',
        'McLaren',
        'Aston Martin',
        'Alpine F1 Team',
        'AlphaTauri',
        'Williams',
        'Haas',
        'Alfa Romeo'
    )
    THEN TRUE
    ELSE FALSE
END;

-- ==================================================
-- VALIDATION CHECKS (OPTIONAL RUN)
-- ==================================================

-- Confirm race coverage by season
-- SELECT season, COUNT(*) AS race_count
-- FROM dim_race
-- GROUP BY season
-- ORDER BY season;

-- Confirm constructor count
-- SELECT COUNT(*) FROM dim_constructor;

-- ==================================================
-- NOTES
-- ==================================================
-- 1. Dimension tables are derived from raw tables
--    without modifying the original data.
-- 2. Season filtering is applied only at the
--    dimension level to ensure consistent scoping.
-- 3. No surrogate keys are introduced to preserve
--    traceability back to raw data sources.
-- ==================================================
