{{ config(
    materialized='incremental',
    schema='gold',
    unique_key=['batsman_id','hkey']
) }}
with source as(
    select 
        *
    from
        {{ ref('cricket_clean')}}
    {% if is_incremental() %}
    where
        delivery_timestamp >= (select max(delivery_timestamp) from {{ this }})
    {% endif %}
),
hash_data as (
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
        ,delivery_timestamp
        ,md5(
            concat(batsman_email,batsman_phone,batsman_icc_rating,contract_id)
            ) as hkey
    from
        source
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
        ,delivery_timestamp
        ,hkey
        ,row_number() over(
            partition by batsman_id, hkey
            order by delivery_timestamp
        ) as rn
    from hash_data
    where delivery_timestamp is not null
),
latest as (
    select  
        *,
        row_number() over(
            partition by batsman_id, rn 
            order by delivery_timestamp desc) as rn2
    from batsman_data
    where rn=1
        
),
final as (
    select 
        *,
        case when rn2=1 then 1 else 0
        end as is_active,
        lead(delivery_timestamp) over(partition by batsman_id, rn  order by rn) as velid_from,
        lag(delivery_timestamp) over(partition by batsman_id, rn  order by rn) as velid_to
    from    
        latest
)select * from final