/*
====================================================
 File: 04_fact_tables.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Create fact tables at race + constructor level
   - Aggregate driver-level raw data into team-level metrics
   - Support performance, operations, and reliability analysis
====================================================
*/

-- ==================================================
-- FACT TABLE: RACE PERFORMANCE
-- ==================================================
-- Purpose:
--   - Capture race outcomes at constructor level
--   - Support management KPIs (points, finishing position)
-- ==================================================

CREATE TABLE fact_race_performance AS
SELECT
    r.raceId        AS race_id,
    r.constructorId AS constructor_id,
    SUM(r.points)   AS points_scored,
    MIN(r.positionOrder) AS best_finish_position
FROM raw_results r
JOIN dim_race dr
    ON r.raceId = dr.race_id
GROUP BY r.raceId, r.constructorId;

-- ==================================================
-- FACT TABLE: LAP PERFORMANCE
-- ==================================================
-- Purpose:
--   - Measure car performance and consistency
--   - Used by engineering stakeholders
-- ==================================================

CREATE TABLE fact_lap_performance AS
SELECT
    lt.raceId        AS race_id,
    res.constructorId AS constructor_id,
    AVG(lt.milliseconds)    AS avg_lap_time,
    STDDEV(lt.milliseconds) AS lap_time_stddev
FROM raw_lap_times lt
JOIN raw_results res
    ON lt.raceId = res.raceId
   AND lt.driverId = res.driverId
JOIN dim_race dr
    ON lt.raceId = dr.race_id
GROUP BY lt.raceId, res.constructorId;

-- ==================================================
-- FACT TABLE: OPERATIONS (PIT STOPS)
-- ==================================================
-- Purpose:
--   - Analyze pit stop execution and operational risk
--   - Focus on both speed and consistency
-- ==================================================

CREATE TABLE fact_operations AS
SELECT
    ps.raceId        AS race_id,
    res.constructorId AS constructor_id,
    COUNT(ps.stop)   AS pit_stop_count,
    AVG(ps.milliseconds)    AS avg_pit_time,
    STDDEV(ps.milliseconds) AS pit_time_stddev
FROM raw_pit_stops ps
JOIN raw_results res
    ON ps.raceId = res.raceId
   AND ps.driverId = res.driverId
JOIN dim_race dr
    ON ps.raceId = dr.race_id
GROUP BY ps.raceId, res.constructorId;

-- ==================================================
-- FACT TABLE: RELIABILITY
-- ==================================================
-- Purpose:
--   - Capture race completion vs failure (DNF)
--   - Used to compute reliability and failure rate KPIs
-- ==================================================

CREATE TABLE fact_reliability AS
SELECT
    r.raceId        AS race_id,
    r.constructorId AS constructor_id,
    CASE
        WHEN s.status IN ('Finished', '+1 Lap', '+2 Laps', '+3 Laps') THEN 0
        ELSE 1
    END AS dnf_flag
FROM raw_results r
JOIN raw_status s
    ON r.statusId = s.statusId
JOIN dim_race dr
    ON r.raceId = dr.race_id;

-- ==================================================
-- NOTES
-- ==================================================
-- 1. All fact tables are aggregated at race + constructor level.
-- 2. Driver-level granularity is intentionally removed to align
--    with business and management decision-making.
-- 3. No cost or KPI calculations are performed in this file.
-- 4. These fact tables act as the foundation for downstream
--    business metrics and dashboards.
-- ==================================================
