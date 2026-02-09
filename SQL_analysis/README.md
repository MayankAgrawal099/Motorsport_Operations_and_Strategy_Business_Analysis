# SQL Analysis 

This folder contains all SQL scripts used to transform raw motorsport data into
business-ready analytical tables and KPIs.

The SQL layer is treated as the **single source of truth** for all calculations.
Dashboards and visualizations consume only the outputs of this layer.

---

## Folder Structure

```
SQL_analysis/
├── 01_schema_setup.sql
├── 02_raw_data_import.sql
├── 03_dimension_tables.sql
├── 04_fact_tables.sql
├── 05_cost_assumptions.sql
├── 06_kpi_views.sql
├── 07_final_checks.sql
└── README.md
```

Each file has a **single responsibility** and must be executed in sequence.

---

## Execution Sequence (IMPORTANT)

Scripts **must be run in numeric order**:

1. `01_schema_setup.sql`
2. `02_raw_data_import.sql`
3. `03_dimension_tables.sql`
4. `04_fact_tables.sql`
5. `05_cost_assumptions.sql`
6. `06_kpi_views.sql`
7. `07_final_checks.sql`

Skipping or reordering scripts may result in broken dependencies.

---

## Data Loading Process

### Source Data
Raw CSV files are sourced from the Kaggle dataset:
**Formula 1 World Championship (1950–2020)**  
(derived from the Ergast Motor Racing Database)

Required files:
- `races.csv`
- `results.csv`
- `lap_times.csv`
- `pit_stops.csv`
- `constructors.csv`
- `status.csv`

---

### How CSVs Are Loaded

CSV files are imported using the **Import/Export feature of pgAdmin**.

Steps:
1. Create raw tables using `01_schema_setup.sql`
2. In pgAdmin:
   - Right-click each `raw_*` table
   - Select **Import/Export Data**
   - Choose the corresponding CSV file
   - Enable **Header**
   - Format: CSV
   - Encoding: UTF-8
3. Verify row counts after import

No data transformation or cleaning is performed during import.

---

## Script Descriptions

### 01_schema_setup.sql
**Purpose:**
- Creates the database schema
- Defines all `raw_*` tables

**Key points:**
- Raw tables mirror CSV structure exactly
- No constraints, filters, or transformations
- Raw data is treated as read-only

---

### 02_raw_data_import.sql
**Purpose:**
- Documents the data ingestion process

**Key points:**
- CSVs are loaded via pgAdmin Import/Export
- SQL `COPY` commands are intentionally omitted to avoid environment-specific paths
- Serves as documentation, not execution logic

---

### 03_dimension_tables.sql
**Purpose:**
- Creates analytical dimension tables

**Tables created:**
- `dim_race` (filtered to seasons 2012–2020)
- `dim_constructor`

**Why this matters:**
- Dimensions define analysis scope and context
- All fact tables depend on these dimensions

---

### 04_fact_tables.sql
**Purpose:**
- Creates core fact tables at race + constructor level

**Tables created:**
- `fact_race_performance`
- `fact_lap_performance`
- `fact_operations`
- `fact_reliability`

**Design principles:**
- Driver-level data is aggregated to team-level
- Focus on performance, operations, and reliability
- No cost or KPI logic included

---

### 05_cost_assumptions.sql
**Purpose:**
- Introduces standardized business assumptions
- Translates race events into estimated cost impact

**Tables created:**
- `cost_assumptions`
- `fact_pit_cost`
- `fact_failure_cost`
- `fact_upgrade_cost`
- `fact_total_cost`
- `fact_cost_efficiency`

**Important note:**
- Cost values are **assumptions**, not real financial data
- Used for comparative efficiency and trade-off analysis

---

### 06_kpi_views.sql
**Purpose:**
- Creates presentation-ready KPI views for dashboards

**Views created:**
- `vw_management_kpis`
- `vw_engineering_kpis`
- `vw_operations_kpis`
- `vw_decision_tradeoffs`

**Key rule:**
- Dashboards must consume these views
- KPI logic must not be reimplemented in Power BI

---

### 07_final_checks.sql
**Purpose:**
- Performs final audit and validation
- Confirms dimensional integrity and KPI sanity

**Checks include:**
- Missing dimension references
- KPI range validation
- Join explosion detection
- Null and edge-case detection

Passing this script indicates the model is **frozen**.

---

## Design Philosophy

- Raw data is never modified
- All transformations are explicit and documented
- Business logic is centralized in SQL
- Assumptions are transparent and defensible
- Dashboards are purely a visualization layer

---

## How This Folder Is Used

1. Run scripts in order to build the analytical model
2. Connect BI tools (Power BI) to KPI views
3. Build stakeholder-specific dashboards
4. Use documentation and assumptions to support decisions

This structure mirrors how analytics pipelines are built in real organizations.
