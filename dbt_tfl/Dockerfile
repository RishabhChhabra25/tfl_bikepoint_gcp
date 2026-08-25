FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir dbt-bigquery==1.8.3

COPY profiles.yml /root/.dbt/profiles.yml

COPY tfl_bikepoint_dbt /app/tfl_bikepoint_dbt

WORKDIR /app/tfl_bikepoint_dbt

ENTRYPOINT ["dbt", "run", "--profiles-dir", "/root/.dbt"]