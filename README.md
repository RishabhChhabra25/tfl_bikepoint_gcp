# TfL BikePoint GCP Data Pipeline

A production-grade data engineering pipeline that ingests live Transport for London (TfL) BikePoint availability data, transforms it using dbt, orchestrates it with Apache Airflow on Cloud Composer, and visualises it in a Looker Studio dashboard — all running on Google Cloud Platform.


## Architecture

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
├── tfl_flatten (table) — parse raw JSON, extract station fields
├── tfl_current (view) — latest snapshot per station
├── tfl_kpis (view) — summary KPIs for dashboard
└── tfl_trend (view) — hourly availability trend
│
▼
Looker Studio Dashboard
└── Live KPIs, station map, trend charts

Orchestrated by **Cloud Composer (Airflow)** — DAG runs every 15 minutes, triggering ingestion then dbt in sequence.
