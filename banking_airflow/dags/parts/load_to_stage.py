from datetime import datetime
from pathlib import Path

from airflow import DAG
from airflow.decorators import task
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.sensors.filesystem import FileSensor


DATA_DIR = Path("/usr/local/airflow/data/raw")
SNOWFLAKE_CONN_ID = "snowflake_conn"
FILESYSTEM_CONN_ID = "fs_default"
SNOWFLAKE_STAGE = "CAPSTONE_EXAM.PRACTICE.PRAC_STAGE"


with DAG(
    dag_id="load_to_stage",
    start_date=datetime(2026, 10, 10),
    schedule='@hourly',
    catchup=False,
) as dag:
    wait_for_file=FileSensor(
        task_id='file_arrival',
        filepath=str(DATA_DIR),
        fs_conn_id=FILESYSTEM_CONN_ID,
        poke_interval=30 ,
        timeout=3600,
        mode='reschedule'
    )
    @task
    def file_upload():
        files=sorted(DATA_DIR.glob("*.csv"))
        if not files:
            return "No data found"

        hook=SnowflakeHook(
            snowflake_conn_id=SNOWFLAKE_CONN_ID
        )
        conn = hook.get_conn()
        cursor = conn.cursor()

        try:
            for file_path in files:
                file_uri = f"file://{file_path.resolve().as_posix()}"
                print("File url: ",file_uri) 

                put_sql = (
                    f"PUT '{file_uri}' "
                    f"@{SNOWFLAKE_STAGE} "
                    "AUTO_COMPRESS=TRUE "
                    "OVERWRITE=FALSE"
                )

                cursor.execute(put_sql)

                result = cursor.fetchall()

                print(
                    f"Upload result for {file_path.name}: {result}"
                )

        finally:
            cursor.close()
            conn.close()

    wait_for_file>> file_upload()