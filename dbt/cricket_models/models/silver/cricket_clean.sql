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
        upper(trim(delivery_id)) as delivery_id
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
        ,upper(trim(extra_type)) as extra_type
        ,TO_NUMBER(extra_runs) as extra_runs
        ,TO_NUMBER(total_runs) as total_runs
        ,upper(trim(is_wicket)) as is_wicket
        ,upper(trim(dismissal_type)) as dismissal_type
        ,TO_DOUBLE(ball_speed_kmph) as ball_speed_kmph
        ,upper(trim(non_striker_id)) as non_striker_id
        ,upper(trim(shot_type)) as shot_type
        ,upper(trim(shot_region)) as shot_region
        ,upper(trim(match_id)) as match_id
        ,COALESCE(
            TRY_TO_DATE(match_date),
            TRY_TO_DATE(match_date,'DD-MM-YYYY')
        ) AS match_date
        ,upper(trim(match_format)) as match_format
        ,upper(trim(tournament_name)) as tournament_name
        ,upper(trim(season)) as season
        ,upper(trim(match_stage))  as match_stage
        ,upper(trim(toss_decision)) as toss_decision
        ,upper(trim(venue_id)) as venue_id
        ,upper(trim(venue_name)) as venue_name
        ,upper(trim(venue_city)) as venue_city
        ,upper(trim(venue_country)) as venue_country
        ,upper(trim(batting_team_id)) as batting_team_id
        ,upper(trim(batting_team_name)) as batting_team_name
        ,upper(trim(bowling_team_id)) as bowling_team_id
        ,upper(trim(bowling_team_name)) as bowling_team_name
        ,upper(trim(batsman_id)) as batsman_id
        ,upper(trim(batsman_name)) as batsman_name
        ,COALESCE(
            TRY_TO_DATE(batsman_dob),
            TRY_TO_DATE(batsman_dob,'DD-MM-YYYY')
        ) AS batsman_dob
        ,upper(trim(batsman_nationality)) as batsman_nationality
        ,upper(trim(batting_hand)) as batting_hand
        ,upper(trim(batsman_role)) as batsman_role
        ,upper(trim(batsman_email)) as batsman_email
        ,upper(trim(batsman_phone)) as batsman_phone
        ,TO_NUMBER(batsman_icc_rating) as batsman_icc_rating
        ,upper(trim(bowler_id)) as bowler_id
        ,upper(trim(bowler_name)) as bowler_name
        ,upper(trim(bowler_nationality)) as bowler_nationality
        ,upper(trim(bowling_style)) as bowling_style
        ,TO_NUMBER(bowler_icc_rating) as bowler_icc_rating
        ,upper(trim(contract_id)) as contract_id
        ,upper(trim(contract_grade)) as contract_grade
        ,TO_DOUBLE(annual_retainer_usd) as annual_retainer_usd
        ,upper(trim(contract_status)) as contract_status
        ,upper(trim(drs_review_id)) as drs_review_id
        ,upper(trim(drs_reviewed_by))as drs_reviewed_by
        ,upper(trim(drs_original_decision)) as drs_original_decision
        ,upper(trim(drs_outcome)) as drs_outcome    
    from 
        raw_data
)
select * from cleaned