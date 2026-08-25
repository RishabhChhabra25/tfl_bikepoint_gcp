from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.cloud_run import CloudRunExecuteJobOperator

#---1.confrigeration---

PROJECT_ID = "tfl-bikepointv1"
REGION = "europe-west2"

#---default argument---

default_args = {
    "owner": "rishabh",
    "retries": 2,
    "retry_delay": timedelta(minutes=2)   
}

#---failure call back intitally a place holder, later can be added with slack or email notifications---

def notify_failure(context):
    task_id = context["task_instance"].task_id
    dag_id = context["task_instance"].dag_id
    execution_date = context["execution_date"]
    print(f"[ALERT] TASK '{task_id}' in DAG '{dag_id}'"
          f"failed at '{execution_date}'")
    
#---dag defination---
with DAG(
    dag_id = "tfl_pipeline",
    description = "Ingestion and running DBT jobs and validate with the dbt tests",
    default_args = default_args,
    schedule_interval = timedelta(minutes=15),
    start_date = datetime(2026,7,25),
    catchup = False,
    max_active_runs = 1,
    tags = ["tfl","bikepoint","dbt"]
) as dag:
    #---task 1 ingest data---
    ingest_tfl_date = CloudRunExecuteJobOperator(
        task_id = "ingest_tfl_date",
        project_id= PROJECT_ID,
        region=REGION,
        job_name= "tfl-ingest-job",
        on_failure_callback = notify_failure,
    )
    #---task 2 run dbt models and tests---
    dbt_run = CloudRunExecuteJobOperator (
        task_id = "dbt_run",
        project_id= PROJECT_ID,
        region= REGION,
        job_name = "tfl-dbt-job",
        on_failure_callback = notify_failure,
    )
    
    ingest_tfl_date>>dbt_run