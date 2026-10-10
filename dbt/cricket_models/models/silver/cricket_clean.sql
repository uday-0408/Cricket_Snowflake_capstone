{{ config(
    materialized='view',
    schema='silver'
) }}
with raw_data as(
    SELECT
        *
    FROM
        {{source('bronze','cricket_data')}}
),
cleaned as (
    select 
        delivery_id
        ,COALESCE( 
            TRY_TO_TIMESTAMP(delivery_timestamp)
            ,TRY_TO_TIMESTAMP(delivery_timestamp,'YYYY-MM-DD HH:MM:SS')
            ,TRY_TO_TIMESTAMP(delivery_timestamp,'DD/MM/YYYY HH:MM:SS')
            ,TRY_TO_TIMESTAMP(delivery_timestamp,'DD-MM-YYYY HH:MM')
            ,TRY_TO_TIMESTAMP(delivery_timestamp,'DD-MM-YYYY HH:MM')
        ) AS delivery_timestamp
        ,TO_NUMBER(innings_no ) as innings_no
        ,TO_NUMBER(over_no) as over_no
        ,TO_NUMBER(ball_in_over) as ball_in_over
        ,TO_NUMBER(runs_off_bat) as runs_off_bat
        ,extra_type
        ,TO_NUMBER(extra_runs) as extra_runs
        ,TO_NUMBER(total_runs) as total_runs
        ,is_wicket
        ,dismissal_type
        ,TO_DOUBLE(ball_speed_kmph) as ball_speed_kmph
        ,non_striker_id
        ,shot_type
        ,shot_region
        ,match_id
        ,COALESCE(
            TRY_TO_DATE(match_date),
            TRY_TO_DATE(match_date,'DD-MM-YYYY')
        ) AS match_date
        ,match_format
        ,tournament_name
        ,season
        ,match_stage
        ,toss_decision
        ,venue_id
        ,venue_name
        ,venue_city
        ,venue_country
        ,batting_team_id
        ,batting_team_name
        ,bowling_team_id
        ,bowling_team_name
        ,batsman_id
        ,batsman_name
        ,COALESCE(
            TRY_TO_DATE(batsman_dob),
            TRY_TO_DATE(batsman_dob,'DD-MM-YYYY')
        ) AS batsman_dob
        ,batsman_nationality
        ,batting_hand
        ,batsman_role
        ,batsman_email
        ,batsman_phone
        ,TO_NUMBER(batsman_icc_rating) as batsman_icc_rating
        ,bowler_id
        ,bowler_name
        ,bowler_nationality
        ,bowling_style
        ,TO_NUMBER(bowler_icc_rating) as bowler_icc_rating
        ,contract_id
        ,contract_grade
        ,TO_DOUBLE(annual_retainer_usd) as annual_retainer_usd
        ,contract_status
        ,drs_review_id
        ,drs_reviewed_by
        ,drs_original_decision
        ,drs_outcome
    from 
        raw_data
)
select * from cleaned