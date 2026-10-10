from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.standard.operators.bash import BashOperator
from parts.load_to_stage import load_to_stage
from banking_airflow.dags.parts.load_to_bronze import load_to_bronze
from banking_airflow.dags.parts.dbt_run import dbt_run


with DAG(
    dag_id="final_dag",
    start_date=datetime(2023, 1, 1),
    schedule=None,
    catchup=False,
    tags=["practice", "e2e"],
) as dag:
    
    # dbt_run_task = BashOperator(
    #     task_id="dbt_build",
    #     bash_command="cd /usr/local/airflow/dbt/cricket_models && dbt run --profiles-dir ..",
    # )
    load_to_stage>> load_to_bronze >> dbt_run