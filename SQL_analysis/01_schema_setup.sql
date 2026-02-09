/*
====================================================
 File: 01_schema_setup.sql
 Project: Motorsport Operations & Strategy – Business Analysis
 Purpose:
   - Create database schema
   - Define raw tables matching Kaggle CSV structure
   - No data loading or transformations in this file
====================================================
*/

-- ==================================================
-- DATABASE SETUP
-- ==================================================

CREATE DATABASE motorsport_db;

-- Connect to the database manually if using psql:
-- \c motorsport_db;

-- ==================================================
-- RAW TABLES
-- These tables mirror the CSV files exactly.
-- Raw data is treated as read-only.
-- ==================================================

-- --------------------------
-- Races Table
-- --------------------------
CREATE TABLE races (
    raceid INT,
    year INT,
    round INT,
    circuitid INT,
    name TEXT,
    date DATE,
    time TIME,
    url TEXT,
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    quali_date DATE,
    quali_time TIME,
    sprint_date DATE,
    sprint_time TIME
);

-- --------------------------
-- Raw Races Table
-- --------------------------
CREATE TABLE raw_races AS
SELECT
    raceid,
    year,
    round,
    circuitid,
    name,
    date
FROM races;

-- --------------------------
-- Raw Constructors Table
-- --------------------------
CREATE TABLE raw_constructors (
    constructorId INT,
    constructorRef VARCHAR(50),
    name VARCHAR(100),
    nationality VARCHAR(50),
    url TEXT
);

-- --------------------------
-- Raw Results Table
-- --------------------------
CREATE TABLE raw_results (
    resultId INT,
    raceId INT,
    driverId INT,
    constructorId INT,
    number INT,
    grid INT,
    position INT,
    positionText VARCHAR(10),
    positionOrder INT,
    points FLOAT,
    laps INT,
    time VARCHAR(20),
    milliseconds INT,
    fastestLap INT,
    race_rank INT,
    fastestLapTime VARCHAR(10),
    fastestLapSpeed VARCHAR(10),
    statusId INT
);

-- --------------------------
-- Raw Lap Times Table
-- --------------------------
CREATE TABLE raw_lap_times (
    raceId INT,
    driverId INT,
    lap INT,
    position INT,
    time VARCHAR(20),
    milliseconds INT
);

-- --------------------------
-- Raw Pit Stops Table
-- --------------------------
CREATE TABLE raw_pit_stops (
    raceId INT,
    driverId INT,
    stop INT,
    lap INT,
    time TIME,
    duration VARCHAR(10),
    milliseconds INT
);

-- --------------------------
-- Raw Status Table
-- --------------------------
CREATE TABLE raw_status (
    statusId INT,
    status VARCHAR(50)
);

-- ==================================================
-- NOTES
-- ==================================================
-- 1. No primary keys or foreign keys are defined here
--    to preserve raw data fidelity.
-- 2. All constraints, filtering, and aggregations
--    are handled in downstream analytical tables.
-- 3. Raw tables should never be updated or modified.
-- ==================================================
