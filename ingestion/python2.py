import requests
import os
import logging
import json
from datetime import datetime, timezone
from google.cloud import storage, bigquery

base_url = 'https://api.tfl.gov.uk/BikePoint/'

logging.basicConfig(level=logging.INFO)


def fetch_data(timeout: int = 20):
    app_key = os.getenv("TFL_APP_KEY")
    if not app_key:
        raise RuntimeError("Missing APP key")

    resp = requests.get(base_url, params={"app_key": app_key}, timeout=timeout)
    resp.raise_for_status()
    return resp.json(), resp.status_code


def upload_to_gcs(bucket_name: str, object_name: str, data):
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    blob = bucket.blob(object_name)
    blob.content_type = "application/json"
    blob.upload_from_string(
        json.dumps(data, ensure_ascii=False, indent=2),
        content_type="application/json"
    )

    return f"gs://{bucket_name}/{object_name}"


def upload_metadata(dataset: str, table: str, snapshot_ts: str, gcs_url: str, payload):
    client = bigquery.Client()
    project_id = client.project
    table_id = f"{project_id}.{dataset}.{table}"

    rows = [{
        "snapshot_ts": snapshot_ts,
        "gcs_url": gcs_url,
        "payload": json.dumps(payload),
        "ingested_at": datetime.now(timezone.utc).isoformat(),
    }]

    errors = client.insert_rows_json(table_id, rows)
    if errors:
        raise RuntimeError(f"BigQuery insert errors: {errors}")


def main():
    data, status = fetch_data()
    logging.info("HTTP Status: %s", status)
    logging.info("Stations fetched: %s", len(data))

    now = datetime.now(timezone.utc)
    ts = now.strftime("%Y%m%dT%H%M%SZ")
    ts_bq = now.isoformat()

    bucket = os.getenv("GCS_BUCKET", "tfl_bucket01_raw01")
    object_name = f"raw/bikepoint_snapshot_{ts}.json"

    gcs_uri = upload_to_gcs(bucket, object_name, data)
    logging.info("Uploaded: %s", gcs_uri)

    upload_metadata("tfl_raw", "snapshots", ts_bq, gcs_uri, data)
    logging.info("Metadata inserted into BigQuery")


if __name__ == "__main__":
    main()