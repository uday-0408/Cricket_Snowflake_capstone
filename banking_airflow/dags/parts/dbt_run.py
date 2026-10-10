from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.standard.operators.bash import BashOperator


with DAG(
    dag_id="dbt_run_dag",
    start_date=datetime(2023, 1, 1),
    schedule=None,
    catchup=False,
    tags=["practice", "e2e"],
) as dag:
    
    dbt_run_task = BashOperator(
        task_id="dbt_run",
        bash_command="cd /usr/local/airflow/dbt/cricket_models && dbt run --profiles-dir ..",
    )
    dbt_run_task