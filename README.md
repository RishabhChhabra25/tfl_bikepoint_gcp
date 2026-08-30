# TFL BikePoint GCP Data Pipeline

A production-grade data engineering pipeline that ingests live Transport for London (TfL) BikePoint availability data, transforms it using dbt, orchestrates it with Apache Airflow on Cloud Composer, and visualises it in a Looker Studio dashboard — all running on Google Cloud Platform.

## Overview 

The TfL BikePoint API exposes real-time availability data for all ~800 cycle hire stations across London — how many bikes are available, how many docks are empty, how many are ebikes, and the station's GPS coordinates. This project:

Ingests a full snapshot of all 800 stations every 15 minutes

Stores raw JSON in Google Cloud Storage as an immutable audit trail

Transforms raw data into clean, analytics-ready BigQuery tables using dbt

Validates data quality on every run using dbt singular tests

Orchestrates the full pipeline automatically using Apache Airflow

Visualises live KPIs, a geographic station map, and hourly trend charts in Looker Studio



## Architecture


```
TfL BikePoint API
      │
      ▼
Cloud Run (Ingestion Job)
  └── python2.py
      ├── Raw JSON → Google Cloud Storage
      └── Metadata row → BigQuery (tfl_raw.snapshots)
            │
            ▼
Cloud Run (dbt Job)
  └── dbt run
      ├── tfl_flatten   (table)  — parse raw JSON, extract station fields
      ├── tfl_current   (view)   — latest snapshot per station
      ├── tfl_kpis      (view)   — summary KPIs for dashboard
      └── tfl_trend     (view)   — hourly availability trend
            │
            ▼
Looker Studio Dashboard
  └── Live KPIs, station map, trend charts
```



Orchestrated by **Cloud Composer (Airflow)** — DAG runs every 15 minutes, triggering ingestion then dbt in sequence.


<img width="1430" height="1056" alt="image" src="https://github.com/user-attachments/assets/159e20d0-96ff-4178-9c86-875d4f08a9d1" />




**Looker Dashboard**

<img width="1368" height="1020" alt="image" src="https://github.com/user-attachments/assets/c2158055-0c01-4e82-acaf-6bc8ab7d8087" />
