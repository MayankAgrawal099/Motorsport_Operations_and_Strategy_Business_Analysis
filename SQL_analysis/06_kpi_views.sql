/*
====================================================
 File: 06_kpi_views.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Create presentation-ready KPI views
   - Lock KPI definitions for dashboards
   - Separate stakeholder-specific metrics cleanly
====================================================
*/

-- ==================================================
-- MANAGEMENT KPIs VIEW
-- ==================================================
-- Audience: Team Principal / Senior Management
-- Focus: Results, efficiency, reliability
-- ==================================================

CREATE VIEW vw_management_kpis AS
SELECT
    dr.season,
    dr.race_id,
    dr.track,
    frp.constructor_id,
    dc.team_name,

    frp.points_scored,
    fce.total_cost,
    fce.cost_per_point,

    -- Reliability score per race (1 = finished, 0 = DNF)
    1 - AVG(fr.dnf_flag)::NUMERIC AS reliability_score

FROM dim_race dr
JOIN fact_race_performance frp
    ON dr.race_id = frp.race_id
JOIN fact_cost_efficiency fce
    ON frp.race_id = fce.race_id
   AND frp.constructor_id = fce.constructor_id
JOIN fact_reliability fr
    ON frp.race_id = fr.race_id
   AND frp.constructor_id = fr.constructor_id
JOIN dim_constructor dc
    ON frp.constructor_id = dc.constructor_id
GROUP BY
    dr.season, dr.race_id, dr.track,
    frp.constructor_id, dc.team_name,
    frp.points_scored, fce.total_cost, fce.cost_per_point;

-- ==================================================
-- ENGINEERING KPIs VIEW
-- ==================================================
-- Audience: Race Engineering Team
-- Focus: Speed, consistency, performance trends
-- ==================================================

CREATE VIEW vw_engineering_kpis AS
SELECT
    dr.season,
    dr.race_id,
    dr.track,
    flp.constructor_id,
    dc.team_name,

    flp.avg_lap_time,
    flp.lap_time_stddev,

    -- Performance gain (negative delta = improvement)
    flp.avg_lap_time
      - LAG(flp.avg_lap_time)
        OVER (PARTITION BY flp.constructor_id ORDER BY dr.season, dr.race_id)
        AS lap_time_delta_ms

FROM dim_race dr
JOIN fact_lap_performance flp
    ON dr.race_id = flp.race_id
JOIN dim_constructor dc
    ON flp.constructor_id = dc.constructor_id;

-- ==================================================
-- OPERATIONS KPIs VIEW
-- ==================================================
-- Audience: Operations Manager
-- Focus: Execution speed, consistency, failures
-- ==================================================

CREATE VIEW vw_operations_kpis AS
SELECT
    dr.season,
    dr.race_id,
    dr.track,
    fo.constructor_id,
    dc.team_name,

    fo.pit_stop_count,
    fo.avg_pit_time,
    fo.pit_time_stddev,

    -- Failure rate per race
    AVG(fr.dnf_flag)::NUMERIC AS failure_rate

FROM dim_race dr
JOIN fact_operations fo
    ON dr.race_id = fo.race_id
JOIN fact_reliability fr
    ON fo.race_id = fr.race_id
   AND fo.constructor_id = fr.constructor_id
JOIN dim_constructor dc
    ON fo.constructor_id = dc.constructor_id
GROUP BY
    dr.season, dr.race_id, dr.track,
    fo.constructor_id, dc.team_name,
    fo.pit_stop_count, fo.avg_pit_time, fo.pit_time_stddev;

-- ==================================================
-- DECISION & TRADE-OFF VIEW
-- ==================================================
-- Audience: Cross-functional decision-making
-- Focus: Explicit KPI conflicts and trade-offs
-- ==================================================

CREATE VIEW vw_decision_tradeoffs AS
SELECT
    dr.season,
    dr.race_id,
    dr.track,
    frp.constructor_id,
    dc.team_name,

    frp.points_scored,
    fce.cost_per_point,
    flp.avg_lap_time,
    flp.lap_time_stddev,
    fo.avg_pit_time,
    fo.pit_time_stddev,
    AVG(fr.dnf_flag)::NUMERIC AS failure_rate

FROM dim_race dr
JOIN fact_race_performance frp
    ON dr.race_id = frp.race_id
JOIN fact_cost_efficiency fce
    ON frp.race_id = fce.race_id
   AND frp.constructor_id = fce.constructor_id
JOIN fact_lap_performance flp
    ON frp.race_id = flp.race_id
   AND frp.constructor_id = flp.constructor_id
JOIN fact_operations fo
    ON frp.race_id = fo.race_id
   AND frp.constructor_id = fo.constructor_id
JOIN fact_reliability fr
    ON frp.race_id = fr.race_id
   AND frp.constructor_id = fr.constructor_id
JOIN dim_constructor dc
    ON frp.constructor_id = dc.constructor_id
GROUP BY
    dr.season, dr.race_id, dr.track,
    frp.constructor_id, dc.team_name,
    frp.points_scored, fce.cost_per_point,
    flp.avg_lap_time, flp.lap_time_stddev,
    fo.avg_pit_time, fo.pit_time_stddev;

-- ==================================================
-- NOTES
-- ==================================================
-- 1. Views act as the single source of truth for dashboards.
-- 2. KPI logic is centralized here to prevent duplication.
-- 3. Dashboards should consume views, not raw or fact tables.
-- ==================================================
