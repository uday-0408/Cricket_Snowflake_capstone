-- depends_on: {{ ref('cricket_clean') }}
{{ config(
    materialized='incremental',
    schema='gold',
    unique_key=['player_id','name']
) }}
with source as(
    select 
        *
    from
        {{ ref('cricket_clean')}}
        
),
batsman_data as (
    select
        batsman_id
        ,batsman_name
        ,batsman_dob
        ,batsman_nationality
        ,batting_hand
        ,batsman_role
        ,batsman_email
        ,batsman_phone
        ,batsman_icc_rating
        ,contract_id
    from source
    qualify row_number() over(
                            partition by batsman_name,batsman_nationality
                            order by batsman_dob)=1
),
bowler_data as (
    select 
        bowler_id
        ,bowler_name
        ,bowler_nationality
        ,bowling_style
        ,bowler_icc_rating
    from
        source
    qualify row_number() over(
                            partition by batsman_name,batsman_nationality
                            order by batsman_dob)=1
),
union_data as(
    select 
       coalesce(batsman_id,bowler_id) as player_id
        ,batsman_name as name
        ,TO_NUMBER(TO_CHAR(batsman_dob, 'YYYYMMDD')) AS dob_date_key
        {# ,batsman_dob as dob #}
        ,batsman_nationality as nationality
        ,batting_hand as batting_hand
        ,batsman_role as role
        ,batsman_email as email
        ,batsman_phone as phone
        ,batsman_icc_rating 
        ,contract_id
        ,bowling_style
        ,bowler_icc_rating
     
    from 
        batsman_data bat full outer join bowler_data boll
        on bat.batsman_id=boll.bowler_id
        {# and bat.batsman_nationality=boll.bowler_nationality #}
    qualify row_number() over(
                            partition by coalesce(batsman_id,bowler_id)
                            order by coalesce(batsman_icc_rating,bowler_icc_rating)
                            )=1
)
select * from union_data
