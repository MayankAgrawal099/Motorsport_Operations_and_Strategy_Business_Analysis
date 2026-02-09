# Data Folder

This folder contains the raw datasets used for the Motorsport Operations & Strategy Business Analysis project.

## Data Source

The data is sourced from the publicly available **Formula 1 World Championship dataset** published on Kaggle.  
The dataset is based on the Ergast Motor Racing Database and contains historical race, performance, and operational data.

**Source:**  
https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020

## Data Scope

For this project, the analysis is limited to races from **2012 to 2024** to reflect a more modern era of motorsport operations while maintaining sufficient historical depth.

## Folder Structure

```
Dataset/
├── races.csv
├── results.csv
├── lap_times.csv
├── pit_stops.csv
├── constructors.csv
├── status.csv
└── README.md
```

### raw/
- Contains **unmodified raw CSV files** downloaded directly from Kaggle.
- No cleaning, filtering, or transformation is performed in this folder.
- These files serve as the single source of truth for the project.

### processed/
- This folder is intentionally kept empty.
- All data transformation, aggregation, and KPI logic is implemented in **SQL**, not in spreadsheets or intermediate files.

## Data Integrity Approach

- Raw data is treated as read-only.
- Basic sanity checks (row counts, null checks, value ranges) are performed prior to analysis.
- All business logic and calculations are implemented downstream in SQL fact and dimension tables.

## Notes

- The dataset does not include proprietary cost or budget information.
- Cost-related values used in the project are defined separately as documented assumptions and are not part of the raw data.
