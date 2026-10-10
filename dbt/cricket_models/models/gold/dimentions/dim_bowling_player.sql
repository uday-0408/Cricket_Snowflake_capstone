{{ config(
    materialized='incremental',
    schema='gold',
    unique_key=['bowler_id','hkey']
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
hash_data as(
    select
         bowler_id
        ,bowler_name
        ,bowler_nationality
        ,bowling_style
        ,bowler_icc_rating
        ,delivery_timestamp
        ,md5(concat(bowling_style,bowler_icc_rating)) as hkey
    from
        source
),
bawler_data as (
    select
         bowler_id
        ,bowler_name
        ,bowler_nationality
        ,bowling_style
        ,bowler_icc_rating
        ,delivery_timestamp
        ,hkey
        ,row_number() over(
            partition by 
                bowler_id,hkey
            order by delivery_timestamp
        ) as rn
    from hash_data
    
),
latest as (
    select  
        *,
        row_number() over(
            partition by bowler_id, rn 
            order by delivery_timestamp desc) as rn2
    from bawler_data
    where rn=1
        
),
final as (
    select 
        *,
        case when rn2=1 then 1 else 0
        end as is_active
        , lead(delivery_timestamp) over(partition by bowler_id, rn  order by rn) as velid_from,
        lag(delivery_timestamp) over(partition by bowler_id, rn  order by rn) as velid_to
 
    from    
        latest
)select * from final