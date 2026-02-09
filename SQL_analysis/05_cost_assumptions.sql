/*
====================================================
 File: 05_cost_assumptions.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Define standardized cost assumptions
   - Translate race events into estimated cost impact
   - Enable cost-efficiency and trade-off analysis
====================================================
*/

-- ==================================================
-- COST ASSUMPTIONS TABLE
-- ==================================================
-- NOTE:
-- These values are NOT real Formula 1 costs.
-- They are standardized assumptions used to
-- evaluate relative efficiency and trade-offs.
-- ==================================================

CREATE TABLE cost_assumptions (
    cost_type     TEXT PRIMARY KEY,
    cost_value    NUMERIC,
    justification TEXT
);

-- --------------------------------------------------
-- INSERT STANDARDIZED COST ASSUMPTIONS
-- --------------------------------------------------

INSERT INTO cost_assumptions VALUES
('pit_stop', 10000,
 'Estimated operational cost per pit stop including crew, tyres, and equipment'),

('dnf', 150000,
 'Estimated cost impact of a race failure including repairs, logistics, and lost opportunity'),

('upgrade', 500000,
 'Estimated cost of a performance upgrade package amortized per race');

-- ==================================================
-- PIT STOP COST FACT
-- ==================================================
-- Purpose:
--   - Convert pit stop counts into operational cost
-- ==================================================

CREATE TABLE fact_pit_cost AS
SELECT
    fo.race_id,
    fo.constructor_id,
    fo.pit_stop_count,
    fo.pit_stop_count * ca.cost_value AS pit_stop_cost
FROM fact_operations fo
JOIN cost_assumptions ca
    ON ca.cost_type = 'pit_stop';

-- ==================================================
-- FAILURE (DNF) COST FACT
-- ==================================================
-- Purpose:
--   - Convert DNFs into estimated failure cost
-- ==================================================

CREATE TABLE fact_failure_cost AS
SELECT
    fr.race_id,
    fr.constructor_id,
    SUM(fr.dnf_flag) AS dnf_count,
    SUM(fr.dnf_flag) * ca.cost_value AS failure_cost
FROM fact_reliability fr
JOIN cost_assumptions ca
    ON ca.cost_type = 'dnf'
GROUP BY fr.race_id, fr.constructor_id, ca.cost_value;

-- ==================================================
-- UPGRADE COST FACT (SCENARIO MODEL)
-- ==================================================
-- Assumption:
--   - One major upgrade is introduced every 4 races
--     per constructor.
-- ==================================================

CREATE TABLE fact_upgrade_cost AS
SELECT
    frp.race_id,
    frp.constructor_id,
    CASE
        WHEN MOD(ROW_NUMBER() OVER (
            PARTITION BY frp.constructor_id
            ORDER BY frp.race_id
        ), 4) = 0
        THEN ca.cost_value
        ELSE 0
    END AS upgrade_cost
FROM fact_race_performance frp
JOIN cost_assumptions ca
    ON ca.cost_type = 'upgrade';

-- ==================================================
-- TOTAL COST FACT
-- ==================================================
-- Purpose:
--   - Consolidate all estimated cost components
-- ==================================================

CREATE TABLE fact_total_cost AS
SELECT
    rp.race_id,
    rp.constructor_id,
    COALESCE(pc.pit_stop_cost, 0) +
    COALESCE(fc.failure_cost, 0) +
    COALESCE(uc.upgrade_cost, 0) AS total_cost
FROM fact_race_performance rp
LEFT JOIN fact_pit_cost pc
    ON rp.race_id = pc.race_id
   AND rp.constructor_id = pc.constructor_id
LEFT JOIN fact_failure_cost fc
    ON rp.race_id = fc.race_id
   AND rp.constructor_id = fc.constructor_id
LEFT JOIN fact_upgrade_cost uc
    ON rp.race_id = uc.race_id
   AND rp.constructor_id = uc.constructor_id;

-- ==================================================
-- COST EFFICIENCY FACT
-- ==================================================
-- Purpose:
--   - Enable management-level cost efficiency KPIs
-- ==================================================

CREATE TABLE fact_cost_efficiency AS
SELECT
    ftc.race_id,
    ftc.constructor_id,
    ftc.total_cost,
    frp.points_scored,
    CASE
        WHEN frp.points_scored = 0 THEN NULL
        ELSE ftc.total_cost / frp.points_scored
    END AS cost_per_point
FROM fact_total_cost ftc
JOIN fact_race_performance frp
    ON ftc.race_id = frp.race_id
   AND ftc.constructor_id = frp.constructor_id;

-- ==================================================
-- NOTES
-- ==================================================
-- 1. Cost values are standardized assumptions, not
--    real-world financial disclosures.
-- 2. The objective is comparative efficiency, not
--    absolute budget estimation.
-- 3. All assumptions are documented and transparent.
-- ==================================================
