from datetime import datetime
from pathlib import Path

from airflow import DAG
from airflow.decorators import task
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook

SCHEMA_CREATION_SQL="""
         CREATE SCHEMA IF NOT EXISTS CAPSTONE_EXAM.BRONZE ;
"""
TABLE_CREATION_SQL="""

    CREATE TABLE IF NOT EXISTS CAPSTONE_EXAM.BRONZE.CRICKET_DATA(
        delivery_id      VARCHAR
        ,delivery_timestamp        VARCHAR
        ,innings_no        VARCHAR
        ,over_no        VARCHAR
        ,ball_in_over        VARCHAR
        ,runs_off_bat        VARCHAR
        ,extra_type        VARCHAR
        ,extra_runs        VARCHAR
        ,total_runs        VARCHAR
        ,is_wicket        VARCHAR
        ,dismissal_type        VARCHAR
        ,ball_speed_kmph        VARCHAR
        ,non_striker_id        VARCHAR
        ,shot_type        VARCHAR
        ,shot_region        VARCHAR
        ,match_id        VARCHAR
        ,match_date        VARCHAR
        ,match_format        VARCHAR
        ,tournament_name        VARCHAR
        ,season        VARCHAR
        ,match_stage        VARCHAR
        ,toss_decision        VARCHAR
        ,venue_id        VARCHAR
        ,venue_name        VARCHAR
        ,venue_city        VARCHAR
        ,venue_country        VARCHAR
        ,batting_team_id        VARCHAR
        ,batting_team_name        VARCHAR
        ,bowling_team_id        VARCHAR
        ,bowling_team_name        VARCHAR
        ,batsman_id        VARCHAR
        ,batsman_name        VARCHAR
        ,batsman_dob        VARCHAR
        ,batsman_nationality        VARCHAR
        ,batting_hand        VARCHAR
        ,batsman_role        VARCHAR
        ,batsman_email        VARCHAR
        ,batsman_phone        VARCHAR
        ,batsman_icc_rating        VARCHAR
        ,bowler_id        VARCHAR
        ,bowler_name        VARCHAR
        ,bowler_nationality        VARCHAR
        ,bowling_style        VARCHAR
        ,bowler_icc_rating        VARCHAR
        ,contract_id        VARCHAR
        ,contract_grade        VARCHAR
        ,annual_retainer_usd        VARCHAR
        ,contract_status        VARCHAR
        ,drs_review_id        VARCHAR
        ,drs_reviewed_by        VARCHAR
        ,drs_original_decision        VARCHAR
        ,drs_outcome        VARCHAR
        ,_source   VARCHAR
        ,_loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
        )
    """
COPY_INTO_SQL = """
    COPY INTO CAPSTONE_EXAM.BRONZE.CRICKET_DATA (
        delivery_id,delivery_timestamp,innings_no,over_no,ball_in_over,runs_off_bat,extra_type,extra_runs,total_runs,is_wicket,dismissal_type,
        ball_speed_kmph,non_striker_id,shot_type,shot_region,match_id,match_date,match_format,tournament_name,season,match_stage,toss_decision,
        venue_id,venue_name,venue_city,venue_country,batting_team_id,batting_team_name,bowling_team_id,bowling_team_name,batsman_id,batsman_name,
        batsman_dob,batsman_nationality,batting_hand,batsman_role,batsman_email,batsman_phone,batsman_icc_rating,bowler_id,bowler_name,
        bowler_nationality,bowling_style,bowler_icc_rating,contract_id,contract_grade,annual_retainer_usd,contract_status,drs_review_id,
        drs_reviewed_by,drs_original_decision,drs_outcome
        ,_source
        
    )
    FROM (
        SELECT 
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
            $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
            $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
            $31, $32, $33, $34, $35, $36, $37, $38, $39, $40,
            $41, $42, $43, $44, $45, $46, $47,$48, $49, $50,
            $51, $52,
            METADATA$FILENAME
        FROM @CAPSTONE_EXAM.PRACTICE.PRAC_STAGE
    )
    FILE_FORMAT = (TYPE=CSV 
                   SKIP_HEADER=1
                   FIELD_OPTIONALLY_ENCLOSED_BY= '"'
                   )
    """
SNOWFLAKE_CONN_ID = "snowflake_conn"
with DAG(
    dag_id="load_to_bronze",
    start_date=datetime(2026, 10, 10),
    schedule='@hourly',
    catchup=False,
) as dag:
    @task
    def bronze_loading():
        hook=SnowflakeHook(
            snowflake_conn_id=SNOWFLAKE_CONN_ID
        )
        conn = hook.get_conn()
        cursor = conn.cursor()
        try:
            cursor.execute(SCHEMA_CREATION_SQL)

            result = cursor.fetchall()
            print("Schema creation output: ",result)
            cursor.execute(TABLE_CREATION_SQL)

            result = cursor.fetchall()
            print("Table creation output: ",result)

            cursor.execute(COPY_INTO_SQL)

            result = cursor.fetchall()
            print("Copy Statement output: ",result)
        finally:
            cursor.close()
            conn.close()
    bronze_loading()
